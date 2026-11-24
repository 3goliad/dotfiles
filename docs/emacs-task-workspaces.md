# Proposal: Emacs task workspaces

Use Emacs as the entrypoint for tracking, pausing, and resuming development
tasks. A task represents independent issue-spanning work across one or more
repositories. The goal is to switch among 6-10 tasks without rebuilding the
environment or reconstructing the previous train of thought.

Org is the source of truth for task records, state, blockers, and time
spent. The taskspace package manages the live Emacs state associated with one
active task.

## Concepts

### Task

A task is an independent unit of work with a stable issue identifier and an
Org record. The record contains:

- a stable Org ID and issue identifier;
- a TODO state;
- an optional blocker message;
- issue and PR links;
- repository and worktree paths;
- Notes;
- Org clock entries recording time worked.

Task records live in `~/Work/org/`, one file per issue, such as `ABC-123.org`.
Completed and blocked tasks remain in the active directory until they are
archived.

### Task state

Use the existing Org TODO states, but give the active state a useful distinction:

| State | Meaning |
| --- | --- |
| `TODO` | The task is ready to be started. |
| `ACTIVE` | It is the active task and should have an open Org clock. |
| `WAIT` | External work is blocking useful progress. |
| `DONE` | No more work is required. |

Only one task should be `ACTIVE` at a time. Switching tasks closes the clock on
the previous task and, when switching to a task that is not `DONE`, sets it to
`ACTIVE` and starts a new clock. Switching to `WAIT` automatically clears its
blocker and returns it to `TODO` before activation.

`WAIT` means the task cannot currently be usefully resumed. An optional
`BLOCKER` property contains a short description visible in task overviews:

```org
:PROPERTIES:
:ID:       <generated Org ID>
:ISSUE:    ABC-123
:BLOCKER:  Waiting for the API PR to merge
:END:
```

The blocker property is cleared when a task leaves `WAIT`. Blocking a task can
be done with or without a taskspace being active.

### Org clock log

Org clocking is the task time log. Clocking in on the `ACTIVE` heading creates
an entry in the task's CLOCK drawer:

```org
* ACTIVE Controller upgrade
:PROPERTIES:
:ID:       <generated Org ID>
:ISSUE:    ABC-123
:END:

:LOGBOOK:
CLOCK: [2026-11-24 Tue 13:30]--[2026-11-24 Tue 13:45] =>  0:15
CLOCK: [2026-11-24 Tue 15:00]--
:END:
```

Clock entries record actual working periods. A switch or close operation
clock-out is enough to end the period; it should not generate a "went to lunch"
or other artificial log message. If the user opens the task file later, they
can add progress and Notes normally.

The user may leave `Notes`, Resources, and plain Org text in the task file at
any time.

### Taskspace

A taskspace is the live editor state associated with a task: worktrees, buffers,
terminals, and window layout. At most one task is active.

With no active task, Emacs behaves as a plain editor over regular checkouts.
Switching to another task:

1. stops the clock for the old task;
2. preserves the old taskspace and saves modified buffers when requested;
3. optionally changes the old task to `WAIT` and records `BLOCKER`;
4. starts or restores the destination taskspace;
5. sets the destination task to `ACTIVE`; and
6. starts its Org clock.

Switching away without a blocker leaves the previous task as `TODO` or its
previous actionable state and records no explanatory log message.

Taskspaces are session state. Live workspaces preserve running processes while
Emacs remains alive. Recovery after an Emacs restart is a separate concern.

## Task overview

An overview is available at all times, whether or not a taskspace is active.
It shows tasks grouped by state and includes a short blocker description for
tasks in `WAIT`.

The overview supports:

- switching to a task;
- opening a task record;
- blocking or unblocking a task;
- marking a task `DONE`; and
- archiving a task.

Selecting a task from the overview switches taskspaces. Opening a task record
alone should not change the active task.

### Archiving

Archiving is available for `DONE` tasks. It means:

- the task no longer appears in the overview;
- the task record is moved to `~/Work/org/archive/`; and
- its taskspace is destroyed.

Destroying a taskspace removes:

- associated Git worktrees;
- owned live buffers and terminals;
- saved window/layout state; and
- task ownership metadata.

Archiving must refuse to overwrite an existing archive file and must confirm
destruction of worktrees and live state.

Worktrees are never removed automatically during ordinary task switches.

## Org and custom-code boundaries

### Well supported by Org

Org already provides most of the task record:

- one file per task;
- stable Org IDs;
- TODO states;
- heading properties;
- notes and resources;
- custom agenda views;
- clock in, clock out, clock persistence, and CLOCK drawers;
- moving completed files to an archive subdirectory.

Org custom agenda commands can show TODO groups. A custom agenda
prefix-format or column view can display `BLOCKER`, because it is an ordinary
Org property.

Org state history and clock entries should remain in the task file rather than
being duplicated in custom data structures.

### Custom taskspaces code

Custom Elisp is required for behavior outside the task file:

- choosing and activating a task;
- maintaining one global active-task value;
- preserving and restoring window configurations;
- assigning buffers to taskspaces;
- filtering ordinary buffer switching;
- saving modified buffers and offering to park them;
- clocking in and clocking out in the task lifecycle;
- setting and clearing task state/properties during switches;
- removing worktrees and owned live state during archive;
- detecting or recreating missing worktrees.

This package should coordinate Org rather than replace it. Org remains the
source of truth for task state, blockers, notes, and time.

## Task record format

```org
#+title: ABC-123 Controller upgrade
#+filetags: :work:

* ACTIVE Controller upgrade
:PROPERTIES:
:ID:       <generated Org ID>
:ISSUE:    ABC-123
:END:

** Resources
- Issue: https://example.com/ABC-123
- Worktree: /path/to/worktree (branch ABC-123-controller-upgrade)

** Notes
Healthy pods might still be running the old image.

** Log
:LOGBOOK:
CLOCK: [2026-11-24 Tue 13:30]--[2026-11-24 Tue 13:45] =>  0:15
:END:
```

The top-level heading is the task heading. `BLOCKER` belongs in properties only
while the heading state is `WAIT`; when leaving `WAIT`, custom code should remove
or blank it rather than leave stale blocker text.

Capturing a task starts it in `TODO`, with blank Resources and Notes sections.
No blocker or clock entry is required until the task is first activated.

## Commands and actions

### Tasks

| Command | Action |
| --- | --- |
| `taskspaces-new-task` | Capture a new task. |
| `taskspaces-show-task` | Open the active task file in the current taskspace. |
| `taskspaces-agenda` | Show the task overview. |
| `taskspaces-switch-task` | Switch taskspaces and clock states. |
| `taskspaces-block-task` | Set `WAIT` and optionally set `BLOCKER`. |
| `taskspaces-unblock-task` | Clear `BLOCKER` and return to `TODO` or `ACTIVE`. |
| `taskspaces-finish-task` | Mark the task `DONE` and clock out. |
| `taskspaces-archive-task` | Confirm archiving and destroy the taskspace. |

### Workspaces

| Command | Action |
| --- | --- |
| `taskspaces-switch-project` | Open or create the active task's worktree for a project. |
| `taskspaces-terminal` | Summon or dismiss a task terminal; a prefix creates another. |

`C-c p p` (`project-switch-project`) is remapped to
`taskspaces-switch-project`.

## Perspective integration

The existing implementation should be compared with `perspective.el` and
`persp-mode.el` before further taskspace code is written.

These packages may already provide useful primitives:

- named workspaces/perspectives;
- preserving window and buffer state;
- switching away and restoring state;
- killing or destroying a perspective;
- configuration persistence behavior.

The taskspaces package should remain a thin task lifecycle layer over whichever
perspective package proves suitable, rather than maintaining a second
perspective implementation. If neither package maps cleanly to the required
task ownership rules, the existing Emacs window/buffer model should remain
unchanged rather than adopting a partially fitting dependency.

Likely package-boundary decisions:

- task ownership and blocker/state transitions remain in taskspaces;
- perspective names correspond to stable task IDs;
- task buffers and worktrees may inform ownership, but perspective membership
  should not become the source of truth;
- archive is the only operation that should deliberately destroy perspective
  state;
- Org clocks and task files remain independent of the perspective package.

## Worktrees

Each task gets `~/Work/taskspaces/<ISSUE>/`. The task directory contains a
`task.org` symlink to `~/Work/org/<ISSUE>.org` and worktrees mirroring paths
under `~/Work`. For example:

- `~/Work/taskspaces/EKS-6171/task.org`
- `~/Work/taskspaces/EKS-6171/bb/FLUX/base-governance`

This mirrors `~/Work/bb/FLUX/base-governance` and keeps the task record and all
of its repositories together. The task terminal opens at the task directory,
while project switching opens the corresponding repository worktree.

A missing worktree is created after prompting for a branch, defaulting to
`<ISSUE>-<title-slug>`. A new branch starts from the remote's default branch,
fetched first, without tracking it. An existing local branch is reused after
confirmation.

The worktree path and branch are appended to the task's Resources. Worktrees
are not removed by ordinary switching or close actions.

## Layouts and buffers

A buffer belongs to a task when:

- its file or directory is under that task's worktree directory; or
- it is a task application buffer started while the task was active.

Application buffers started with no task are shared. Org task records and other
buffers are shared.

Buffer switching should normally offer shared buffers and buffers belonging to
the active task. Consult integration may offer a way to override this
restriction.

Layouts are not required to survive Emacs restarts. No task should remain active
after a restart unless the user explicitly resumes it.

## Boundaries

Switching tasks must not automatically check out branches, merge changes,
deploy anything, or change a shared Kubernetes context. Cluster access should
be scoped to task-specific commands or shells if that integration is later
implemented.

Browser automation and external status polling are out of scope. Issue links
remain in Org, and external blockers are confirmed manually rather than
inferred from GitHub or Kubernetes.
