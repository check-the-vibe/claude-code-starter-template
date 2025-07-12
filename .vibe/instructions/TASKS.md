# Project Tasks

## Current Sprint

Let's add the ability to handle environment variables inside of a running session. Ideally i should be able to pass an .env file, and within that session the environment variables should be exported and available. 

Think through how you can accomplish this best, research the best way to use environment variables inside of a tmux session, including how to read them from a file like a .env file. 

## Completed Tasks

### Repository Structure Overhaul (Completed: 2025-07-12)

**Restructuring Tasks:**
- [x] Remove all template folders
- [x] Remove all shell scripts in root (kept .vibe scripts)
- [x] Rename vibe-* scripts to action names on filesystem
- [x] Update init script to maintain vibe-* command names
- [x] Remove all tests in root
- [x] Create new README.md focused on vibe CLI
- [x] Move .md files to .vibe/instructions
- [x] Update CLAUDE.md with new paths
- [x] Remove LOG.txt references
- [x] Move LINKS.csv to .vibe/docs

**Results:**
- Clean repository structure with focus on vibe CLI
- All documentation properly organized
- Vibe scripts renamed but maintain original command interface
- New README.md provides clear installation and usage instructions

### vibe CLI Documentation and Testing Sprint (Completed: 2025-07-12)

**Documentation Tasks:**
- [x] Document vibe CLI commands in README.md for users
- [x] Create internal documentation for vibe CLI in .vibe/docs/vibe-cli-internal.md
- [x] Update CLAUDE.md to reference internal vibe documentation

**Testing Tasks:**
- [x] Create test plan documentation in .vibe/docs/vibe-cli-test-plan.md
- [x] Test short-lived command with immediate feedback
- [x] Test short-lived command where logs are read
- [x] Test long-running task where Claude polls until completion
- [x] Test long-running task where Claude initiates, user continues action, Claude completes action
- [x] Create test results summary in .vibe/docs/vibe-cli-test-results.md

**Deliverables Created:**
1. User documentation added to README.md (comprehensive vibe CLI section)
2. Technical documentation: `.vibe/docs/vibe-cli-internal.md`
3. Test plan: `.vibe/docs/vibe-cli-test-plan.md`
4. Test results: `.vibe/docs/vibe-cli-test-results.md`
5. Updated CLAUDE.md with reference to internal docs

**Test Results Summary:**
- Total Tests: 10
- Passed: 9
- Issues Found: 1 (sessions don't auto-terminate after command completion)

## Backlog
_Future tasks and ideas_
