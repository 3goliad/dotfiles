# Emacs task workspaces

Use Emacs to switch among independent development tasks. A task represents
work spanning one or more repositories and 6-10 taskspaces.

## Org is the source of truth

Active work tasks live as TODO headings in `~/Work/org/tasks.org`, one regular
Org file. Capture creates a heading with:

- a stable Org `ID`;
- a `:work:` tag;
- an optional `ISSUE` property;
- a TODO state;
- a blocker property while blocked;
- notes and clock entries.

The file is configured with the usual Org archive location:

```org
#+title: Work Tasks
#+filetags: :work:
#+ARCHIVE: ~/Work/org/tasks.org_archive::

* Tasks
** TODO Upgrade controller
:PROPERTIES:
:ID:       11111111-1111-1111-1111-111111111111
:ISSUE:    ABC-123
:END:
*** TODO Prepare production plan
:PROPERTIES:
:ID:       22222222-2222-2222-2222-222222222222
:ISSUE:    ABC-123-PRODUCTION
:END:
```

Child tasks are ordinary nested Org subheadings. They have their own stable ID
and can be selected independently.

## TODO states

There is no separate `ACTIVE` TODO state. The Org TODO states are:

| State | Meaning |
| --- | --- |
| `TODO` | Ready to resume |
| `WAIT` | External work prevents useful progress |
| `DONE` | No more work is required |

A task can be marked `WAIT` with an optional `BLOCKER` property. Clocking into a
WAIT task clears `BLOCKER` and changes it to `TODO`.

## The running Org clock is active-task state

There is at most one running Org clock. It is the active-task mechanism:

- clocking into a task clocks out the previous task;
- clocking out closes the taskspace;
- canceling or suspending the clock closes the taskspace;
- clocking into a personal or otherwise unrecognized heading produces no
  taskspace;
- no running clock means no active task.

The taskspaces package synchronizes live state from the running clock. It does
not maintain an independent ACTIVE state or set TODO keywords when a task is
selected.

The existing Org agenda already highlights the running clock. The custom work
agenda adds an explicit `[ACTIVE]` prefix for the clocked heading.

Clock persistence is ordinary Org clock behavior. At startup, the taskspaces
package may restore a live taskspace if Org restores the matching work-task
clock.

## Task switcher

`taskspaces-switch-task` finds TODO headings in `tasks.org` that:

- inherit or carry the `:work:` tag;
- have a non-empty `ID`;
- are in `TODO` or `WAIT` state.

The candidates show issue, title, hierarchy, state, and blocker text. Selecting
a task clocks it in. Selecting `DONE` or an archived heading is not allowed.

`taskspaces-show-task` opens the clocked heading. With no active task, it opens
the task switcher.

## Capture

`taskspaces-new-task` captures a top-level task beneath the `Tasks` heading.
`taskspaces-new-child-task` captures beneath the current task or a selected
task. Captured headings receive a generated Org ID and `:work:` tag.

Org IDs and hierarchy replace custom PARENT properties and generated Children
sections.

## Worktrees

Each task has a live workspace under
`~/Work/taskspaces/<stable-org-id>/`. Worktree paths mirror paths below
`~/Work`.

For example:

```text
~/Work/taskspaces/11111111-1111-1111-1111-111111111111/
  bb/FLUX/base-governance
```

When `taskspaces-switch-project` is used:

1. the active task's worktree is selected or created;
2. a missing worktree prompts for a branch;
3. new branches start from the remote's default branch;
4. the worktree path and branch are appended to the task heading's Resources.

Taskspaces do not switch branches, merge changes, deploy anything, or change
shared cluster context. Switching away preserves worktrees and layouts.

## Layouts and buffers

A buffer belongs to a task when:

- its file or directory is under that task's worktree directory; or
- it is a task application buffer started while the task was active.

Application buffers started without a task are shared. `tasks.org` and unrelated
buffers are shared.

The taskspace package preserves window configurations per stable task ID while
Emacs remains alive. Layouts are not required to survive an Emacs restart.

## Terminals

`taskspaces-terminal` summons or dismisses the active task's terminal. A prefix
argument creates another terminal. With no active task, it uses the shared
terminal.

## Blocking and finishing

`taskspaces-block-task` clocks out and marks the current task `WAIT`, optionally
recording `BLOCKER`.

`taskspaces-unblock-task` clears `BLOCKER` and returns the task to `TODO`.

`taskspaces-finish-task` clocks out and marks the task `DONE`.

## Archiving

`taskspaces-archive-task` requires `DONE`, confirms the action, and calls
Org's standard `org-archive-subtree`. Subtrees may be archived normally and
may contain nested task headings. Archived entries go to
`tasks.org_archive`, with no custom collision protection.

Direct Org archiving is also supported. Org's archive hook schedules
`taskspaces--cleanup-taskspaces`, which:

1. scans stable IDs in the active task file;
2. leaves live taskspaces for IDs still present;
3. clocks out archived active tasks;
4. removes worktrees and owned live buffers;
5. deletes the taskspace layout and directory.
