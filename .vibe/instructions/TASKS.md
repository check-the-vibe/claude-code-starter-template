# Project Tasks

## Current Sprint - Multi-tasking

Update the CLAUDE.md file with instructions that enable Claude to do more than one task at once. When there are more than one task that are related to each other, claude should execute both commands first, in separate sessions, and then iterate through each task's session to complete, this should allow work to be going on behind the scenes in prep for the next action that is coming up. 

In order to accomplish this, you will need to be sure that when claude is executing a command that it can immediately detach from the session and continue on with the multi-tasking it is looking to do. 

think through how you are going to accomplish this, plot out the right course, test out your actions when you're done. 

## Completed Tasks

### Anthropic Recommendations Implementation (Completed: 2025-07-12)

**Research & Analysis:**
- [x] Clone Anthropic prompt engineering tutorial repo
- [x] Read through Anthropic 1P folder notebooks
- [x] Extract key recommendations and best practices
- [x] Create anthropic-recommendations.md with comprehensive list

**CLAUDE.md Updates:**
- [x] Add Core Principles section based on Anthropic best practices
- [x] Emphasize being clear and direct in instructions
- [x] Add XML tag usage guidelines for data/instruction separation
- [x] Implement step-by-step thinking pattern for complex tasks
- [x] Add role prompting section
- [x] Add section on avoiding hallucinations
- [x] Document the recommended complex prompt structure
- [x] Include guidelines on output formatting with XML tags
- [x] Add section on using few-shot examples effectively

**Documentation Created:**
- [x] Created .vibe/docs/prompt-patterns.md with example templates
- [x] Added comprehensive examples of good prompting patterns
- [x] Documented common XML tags and their usage
- [x] Included examples for file analysis, code generation, debugging, refactoring, and documentation

**Key Improvements:**
- Clear separation of instructions and data using XML tags
- Emphasis on explicit, direct communication
- Step-by-step thinking for complex tasks
- Role context for better responses
- Structured approach to complex prompts

### Environment Variable Support (Completed: 2025-07-12)

**Implementation Tasks:**
- [x] Research tmux environment variable handling
- [x] Design .env file integration approach  
- [x] Implement env var support in session script with `-e` flag
- [x] Test single and multiple env file loading
- [x] Update documentation for env var feature

**Features Added:**
- Added `-e` or `--env-file` option to vibe-session command
- Support for loading multiple env files (later files override earlier)
- Automatic variable export using `set -a` mechanism
- Validation of env file existence before session creation
- Clear documentation and examples in README and CLAUDE.md

### Script Updates (Completed: 2025-07-12)

**Changes:**
- [x] Renamed logs viewer script from `logs-viewer` to `tail`
- [x] Updated all references in init script
- [x] Updated CLAUDE.md with new development workflow pattern
- [x] Fixed dead session cleanup in kill script
- [x] Fixed script references (vibe-list → list) in multiple scripts

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
