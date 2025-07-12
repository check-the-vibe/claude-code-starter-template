# Project Tasks

## Current Sprint - vibe CLI, a tmux-based shell management system. 

The outcome of this sprint should be a system that is easily transferable and resuable in different development environments. We can assume that we are running in a Linux shell, with tmux installed. 

There should be two parts of this system, the first is a set of shell scripts that will be found in the .vibe/* folder of the project root. Each of the commands should be their own shell scripts that are executable. The purpose of these scripts are to manage a set of tmux 'sessions', which allows claude code to be able to execte a number of short-or-long running tasks, and organize them by session. This will allow Claude to work on more than one task at once, and check on the progress by running a command to get the current logs. A user should be able to easily check a session, see all sessions, store the active sessions in a file, and attach/detach from these sessions. Both claude and the user should also be able to access the last log lines from a running session. 

Each of the files in the .vibe/* folder should be accessible and runnable by the user and by claude. 
CLAUDE.md will need to be updated to explain how to use these commands. 
CLAUDE.md will need to be updated to add strict instructions to run all shell commands using this session-based method. 
There should be a shell script that a user can easily source which aliases each of these scripts, to make it easier to use. 

Think through your approach, search for best practice with TMUX, sessions, environment variables, and other key topics. Design your system, build your DSL/commands, make it as easy as possible, and transportable as possible. 

### 🔍 Research Phase
- [ ] Understand project requirements
- [ ] Research necessary technologies
- [ ] Identify potential challenges

### 📐 Design Phase
- [ ] Plan architecture
- [ ] Create component structure
- [ ] Define data flow

### 💻 Development Phase
- [ ] Implement core functionality
- [ ] Add error handling
- [ ] Write documentation

### 🧪 Testing Phase
- [ ] Write unit tests
- [ ] Perform integration testing
- [ ] User acceptance testing

### ✅ Confirmation Phase
- [ ] Code review
- [ ] Performance optimization
- [ ] Final deployment checks

## Completed Tasks
_Move completed tasks here with timestamps_

## Backlog
_Future tasks and ideas_
