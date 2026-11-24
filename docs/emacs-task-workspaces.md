# Proposal: Emacs task workspaces

Use Emacs as the entrypoint for tracking, parking, and resuming development
tasks. A task represents an issue spanning multiple repositories, not a single
project. The goal is to switch among 6-10 tasks without rebuilding the environment
or reconstructing the previous train of thought.

File-per-task Org tracking and single-task workspaces ("taskspaces") are
implemented. Browser integration, Kubernetes context scoping, restart recovery,
and automatic unblock detection remain proposals, not current behavior.

## Task record

Keep Org as the source of truth, with one file per issue in `~/Work/org/`.
Separate files let an agent read and update one task without having to navigate
a shared heading tree or consume unrelated task context. Locating them under
`~/Work` also makes permissions easier to grant alongside the repositories.
Separate files reduce unrelated context; they are not an access-control boundary.

Each active task has an issue identifier,
status, issue and PR links, repository worktree paths, and references to its
workspace and Copilot sessions. Record the intended Kubernetes context and
namespace explicitly.

Keep a short handoff alongside those references:

- Where I stopped.
- What I am waiting for, if anything.
- The next concrete action, when known.

Capture first; fill in the handoff as you work or park the task. Keep caveats in
Notes and schedule a recheck when useful.

Carry unfinished tasks across sprint boundaries; archive completed tasks.

## Workspace

See [Taskspaces](#taskspaces) for the implemented design. At most one task is
active at a time, so switching is explicit and always parks the previous task.

Use a separate Git worktree for each task/repository pair so switching tasks
does not require checking out branches or disturbing unfinished changes.
Task-specific terminals retain their working directories and can host Copilot
sessions. Browser tabs remain in Chrome, grouped by issue identifier, with
important links also saved in Org.

## Daily workflow (planned)

1. Invoke an Emacs task picker showing active, paused, and waiting tasks,
   including rechecks that are due.
2. Select a task and read its handoff. Focus its existing workspace, or offer to
   recreate missing pieces from the saved references.
3. Work normally across its repositories, terminals, and browser tabs.
4. Park the task by updating its status and short handoff, then select another
   task. Leave the parked workspace alive.

A due recheck is not proof that a task is unblocked. Initially, confirm external
conditions manually rather than duplicating PR and deployment status in Org.

## Boundaries and first increment

Switching tasks must not automatically check out branches, merge changes, or
deploy anything. Cluster access must be scoped to task-specific commands or
shells rather than changing a shared global context.

Live workspaces preserve running state while Emacs and their processes remain
alive. Recovery after a restart is a separate concern: saved references can
reopen files and resume saved Copilot conversations, but cannot restore arbitrary
running processes.

Try the implemented tracking with two tasks before adding workspace automation.
Keep browser navigation manual through saved links. Defer browser automation,
external-status polling, and elaborate restart recovery until the basic workflow
proves useful. Workspace packages, additional resource properties, and terminal
integration are still to be decided.

## First draft: task tracking

Task records live in `~/Work/org/`, one file per issue, such as `ABC-123.org`.
This is separate from the existing personal Org directory. Files contain a
top-level TODO heading, stable Org ID, issue identifier, Handoff, Resources, and
Notes. Files are created when needed, not during Emacs startup.

Records use ordinary Org syntax:

```org
#+title: ABC-123 Controller upgrade
#+filetags: :work:

* WAIT Controller upgrade
:PROPERTIES:
:ID:       <generated Org ID>
:ISSUE:    ABC-123
:END:

** Handoff
Stopped: App PR merged.
Waiting for: GitOps PR approval.
Next: Merge GitOps PR, then verify the deployed image digest.

** Resources
- Issue: https://example.com/ABC-123

** Notes
Healthy pods might still be running the old image.
```

Only the top-level heading needs a TODO state. Handoff, Resources, and Notes
are sections, not additional tasks. The ID is stable when the file is moved or
its heading is renamed; ISSUE connects it to the external issue identifier.

The task commands are available under `C-c i t`. Press that prefix and pause to
see the available keys through which-key, or invoke the command with `M-x`.

| Key after `C-c i t` | Command | Action |
| --- | --- | --- |
| `n` | `work-task-new` | Capture a new task with an identifier, title, and optional URL. |
| `r` | `work-task-open` | Choose an unarchived task and open its handoff without changing its state. |
| `a` | `work-task-agenda` | Show today's and overdue rechecks, work in progress, ready tasks, and waiting tasks. |
| `p` | `work-task-park` | Update the handoff, choose a state, optionally schedule a recheck, and save. |
| `t` | `work-task-state` | Change the task's state from anywhere in its file and save. |
| `s` | `work-task-schedule` | Schedule a recheck on the task heading and save. |
| `f` | `work-task-finish` | Mark the task DONE and save, leaving the file available. |
| `x` | `work-task-archive` | Confirm moving a DONE task file into `~/Work/org/archive/`. |

New task uses the `w` template, also available through `M-x org-capture`.
It is a plain capture of a complete file, including file metadata and the task
heading. A small helper chooses the filename and prevents duplicates; Org
handles prompting, editing, and finalization. No additional Org packages are
required.

After answering the prompts, edit the complete record in the capture buffer.
Use `C-c C-c` to finalize, save, and visit the new file, or `C-c C-k` to abort
without creating a task file, provided it has not been manually saved during
capture. The identifier determines the filename and may contain letters,
numbers, hyphens, and underscores; existing files and unsaved task content are
never overwritten.
Capture starts with `Stopped: Not started.` and blank `Waiting for` and `Next`
lines. No next action is prompted for or required; leave it blank until you know
what to do next. The title and Stopped field are checked when finalizing; a
task captured as WAIT also needs a waiting condition. These can be corrected in
the capture buffer. A validation error leaves capture open.

Use `TODO` for not-yet-started work, `STARTED` for work begun and still
actionable, `WAIT` for external blockers, and `DONE` for completed work.
Selecting a task does not mark it STARTED; use the state command when beginning.
The resume picker includes DONE files until they are archived.

In the dashboard, use `RET` on a task to visit its record before running the
park, state, schedule, finish, or archive commands. These commands operate on
the current task file, not on whichever task was most recently selected.
State, schedule, and finish operations target the top-level task even when point
is inside Notes or a narrowed subsection. Timestamp-only Org state logs are
included when the commands save, rather than leaving a pending log unsaved.

The park command edits only the three single-line Handoff fields: `Stopped`,
`Waiting for`, and `Next`. Keep those labels and the `Handoff`
heading intact. Put longer explanations, history, and agent findings in Notes;
put PR links, worktree paths, and session references in Resources.
Stopped must be nonempty; WAIT also requires a waiting condition. Next is
optional even when parking: fill it in if the action is clear, or leave it blank.
Prompts use existing values as editable defaults. Existing `Watch out` lines
are left untouched but are no longer required or prompted for; move any useful
caveats to Notes when convenient.

A recheck is an Org scheduled date/time, not a deadline or proof of being
unblocked. Date prompts support input such as `+1d` or an explicit time like
`14:30`. In Org date input, `+15m` means 15 months, not 15 minutes; use an
explicit clock time for short reconciliation waits. The dashboard shows today's
scheduled checks, including upcoming times, and overdue checks. Scheduling does
not implement a notification or external-status watcher.
Declining to set a date while parking preserves any existing schedule.
Use `C-u C-c i t s` to remove a recheck. The dedicated dashboard excludes personal
tasks and archived files; the normal Org agenda can still include both personal
and active work records.

Archiving moves the whole completed file into `~/Work/org/archive/`, refuses
to overwrite another file, and updates its Org ID location. Org scans the active
directory's `.org` files nonrecursively, so this subdirectory stays out of the
active agenda. Unfinished tasks remain in place across sprint boundaries.

For agents, provide the exact task file path and ask them to preserve the
structure and update the handoff and Notes. Task records remain outside this
dotfiles repository. No browser control, status polling, or cluster context
changes are implemented yet.

## Taskspaces

A taskspace is the live editor state of the single active task: its worktrees,
terminals, agents, and window layout. With no active task, Emacs behaves as a
plain editor over your regular checkouts. The active issue is shown in the
mode line.

Commands are under `C-c i w`:

| Key after `C-c i w` | Command | Action |
| --- | --- | --- |
| `s` | `taskspace-switch` | Choose a task, park the active one, then show the new task's layout. |
| `c` | `taskspace-clear` | Park the active task and return to the no-task layout. |
| `o` | `taskspace-open-task` | Show the active task's handoff. |
| `p` | `taskspace-project` | Pick a repository; visit or create the task's worktree, or the regular checkout with no task. |
| `t` | `taskspace-terminal` | Summon or dismiss the task's terminal (also `C-\`); `C-u` creates another. |
| `a` | `taskspace-agent` | Show or start the task's agent-shell (`C-u` starts another). |
| `b` | `taskspace-switch-to-any-buffer` | Choose among all buffers, including other tasks'. |

`C-c p p` (`project-switch-project`) is remapped to `taskspace-project`.

**Switching.** Leaving a task always runs `work-task-park`, so you are prompted
for its state and handoff; quitting the prompt cancels the switch. You are then
offered to save that task's modified files. Its buffers and processes stay
alive but hidden, and its window layout is remembered for the session. The
first visit to a task shows its handoff beside a Dired view of its worktree
directory; later visits restore its layout, and the handoff summary is echoed.

**Buffer ownership.** A buffer belongs to a task when its file or directory is
under that task's worktree directory, or when it is an application buffer
(`taskspace-application-modes`: ghostel, agent-shell, shells, compilation)
started while the task was active. Application buffers started with no task
are shared. Org task records and other buffers are shared. `consult-buffer`,
`other-buffer`, and window buffer history only offer shared buffers and the
active task's buffers; in `consult-buffer`, narrow with `o SPC` to see the rest.

**Worktrees.** Each task gets `~/Work/worktrees/<ISSUE>/`, mirroring paths under
`~/Work`, e.g. `~/Work/worktrees/EKS-6171/bb/FLUX/base-governance`. The project
picker lists known projects (add them with `C-c p a` or `C-c p u`) other than
task worktrees. A missing worktree is created after prompting for a branch,
defaulting to `<ISSUE>-<title-slug>`. A new branch starts from the remote's
default branch (`main`, `develop`, ...), fetched first, without tracking it; an
existing local branch is reused after confirmation. The worktree path and
branch are appended to the task's Resources. Worktrees are never removed
automatically.

**Terminals and agents.** The task terminal starts in the current task worktree,
or otherwise in the task directory, and opens in an ordinary window at the
bottom that can be split or resized. Dismissing quits that window; the
terminal keeps running. With no task, `C-\` toggles a shared terminal.
`taskspace-agent` starts agent-shell in the task directory so it can see all of
the task's worktrees; it reports an error until agent-shell is installed.

Layouts are not saved across Emacs restarts, and no task is active after a
restart.

## Activation

The implementation is the `taskspaces` package in
`private_dot_config/emacs/user-lisp/taskspaces/taskspaces.el`. Emacs
byte-compiles `user-lisp/` and scrapes its autoloads at startup; `init.el`
configures it with `use-package`. Commands and the `C-c i t` and `C-c i w`
prefixes are autoloaded, so they work before Org or the package is loaded.
Loading Org also loads the package, so the `w` capture template, `W` agenda
command, and task agenda files are available from `org-capture` and
`org-agenda`. Deploy it and its keybindings with:

```sh
chezmoi apply ~/.config/emacs
```

Restart Emacs, then use `C-c i t n` to create the first task. Existing personal
Org files are neither moved nor replaced. The documentation directory is
excluded from chezmoi deployment.
