# Project Tasks

## Current Sprint
Add a basic search, keep a list of all templates in the setup scripts, allow the user to autocomplete a search based on the name of each folder available in templates/. 



### 🐛 Bug Fixes Needed
- [x] Fix template listing when script is run from subdirectories (SCRIPT_DIR issue)
- [x] Fix BASH_SOURCE errors when running via curl-to-bash
- [x] Fix template selection parsing error messages as options
- [x] Ensure templates are found when running from any directory
- [x] Fix the GitHub API template download functionality

### 🔧 Improvements
- [x] Add better error handling for missing templates directory
- [x] Improve the is_curl_bash detection method
- [x] Add option to specify template via command line (e.g., --template python)
- [x] Add --non-interactive flag for automation
- [ ] Add README.md with clear instructions and examples
- [ ] Test full curl-to-bash workflow with remote templates

### 🧪 Testing Needed
- [x] Test setup.sh from project root
- [x] Test setup.sh from subdirectories
- [ ] Test curl-to-bash installation
- [x] Test template selection with all templates
- [ ] Test --save-template functionality
- [ ] Test on different shells (bash, zsh)

### 📚 Documentation
- [ ] Create comprehensive README.md
- [ ] Add troubleshooting section
- [ ] Document all command-line options
- [ ] Add examples for each use case
- [ ] Create a demo GIF/video

## Completed Tasks
[2025-06-29] ✓ Created enhanced setup script with template system
[2025-06-29] ✓ Added multiple templates (default, python, nodejs-react)
[2025-06-29] ✓ Implemented --save-template functionality
[2025-06-29] ✓ Added backup management in .vibe/backups/
[2025-06-29] ✓ Made script curl-to-bash ready
[2025-06-29] ✓ Fixed SCRIPT_DIR path resolution for subdirectories
[2025-06-29] ✓ Fixed BASH_SOURCE errors in curl-to-bash mode
[2025-06-29] ✓ Fixed template listing to avoid parsing errors as options
[2025-06-29] ✓ Enhanced GitHub API template download with better error handling
[2025-06-29] ✓ Added --template option for command-line template selection
[2025-06-29] ✓ Added --non-interactive flag for automation

## Known Issues
1. ~~Template directory path resolution fails when script runs from subdirectories~~ ✓ Fixed
2. ~~BASH_SOURCE is unbound when running via curl pipe~~ ✓ Fixed
3. ~~list_templates() returns error message that gets parsed as template names~~ ✓ Fixed
4. ~~GitHub API template download not implemented correctly~~ ✓ Fixed
5. ~~No way to bypass interactive prompts for automation~~ ✓ Fixed with --non-interactive

## Backlog
- Create more specialized templates (Django, FastAPI, Vue, etc.)
- Add template versioning
- Create online template gallery
- Add update mechanism for templates
- Support for .vibe plugins/extensions