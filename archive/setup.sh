#!/bin/bash

# Setup .vibe folder structure for Claude Code project
# This script creates/overwrites the .vibe folder and CLAUDE.md file

echo "Setting up .vibe folder structure..."

# Create .vibe directory structure
mkdir -p .vibe/docs

# Create PERSONA.md
cat > .vibe/PERSONA.md << 'EOF'
<!-- This file contains your persona. It defines who you are, how you should act, how you think about the world, what you know, what you are great at. Follow all of the instructions here when defining how you should respond and act to user requests. -->

You are an experienced software developer, who helps other software developers get up and running with demonstration projects, "shows you by doing" software development tasks, and helps accelerate people's projects through the use of strategic pair programming. You are proficient at NodeJS, Python, Bash, Linux, and other relevant languages.
EOF

# Create TASKS.md
cat > .vibe/TASKS.md << 'EOF'
# Outcome

## Research 

## Design 

## Develop

## Test

## Confirm
EOF

# Create ERRORS.md
cat > .vibe/ERRORS.md << 'EOF'
<!-- Errors from the previous run go in this file. Use this, and the chat context to determine what the best next course of action would be. If there are no errors, assume this is the first run, or the previous run (if available) was successful -->
EOF

# Create LINKS.csv
cat > .vibe/LINKS.csv << 'EOF'
title,url
Claude Documentation, https://docs.anthropic.com/en/docs/claude-code/overview
EOF

# Create LOG.txt
touch .vibe/LOG.txt

# Create ENVIRONMENT.md
cat > .vibe/ENVIRONMENT.md << 'EOF'
<!-- This file gives any specific information about the environment that claude is running in, including any specific details about how code is executed, where a user is accessing this project, and whether there are any specific constraints (no write access, e.g). If the user is running in a known platform environment (e.g. Github Codespaces, Replit) this will be called out -->
EOF

# Create CLAUDE.md in project root
cat > CLAUDE.md << 'EOF'
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. When first using this project, the user will prompt with a request for a specific project type. Change this file accordingly to account for this request. 

## Project Overview

Focus on project root when performing your actions. The following files are meant to guide you while developing:
- .vibe/docs/
- .vibe/TASKS.md
- .vibe/ERRORS.md
- .vibe/PERSONA.md
- .vibe/LINKS.csv
- .vibe/LOG.txt
- .vibe/ENVIRONMENT.md

Read through .vibe/ENVIRONMENT.md to understand details about where claude is currently being executed, including any specific constraints, features, and capabilities. You may need to refer to documentation in .vibe/docs/* about the environment, or if you are unclear on specific details of this environment you may need to search to gain more context.

Assume the role that is defined in .vibe/PERSONA.md. This will define how you should respond to requests. Use this persona throughout the rest of your tasks. 

Any errors that occured in a previous development iteration are stored in ERRORS.md. If no errors are found,it is either the first iteration or no errors have occurred. Once you have completed your actions based on your TASKS and ERRORS, please clear the ERRORS.md file. 

Add any tasks that need actioning are in TASKS.md folder. By default there will be one TASKS.md file, however there may be more taks in this folder, read all tasks in the folder.  When a task is complete, update the relevant task file showing that this task is completed. Do so in a way that makes it easy to scan later for open and closed tasks. 

Relevant documentation can be found in the folder .vibe/docs. You will find different formats of document there, use this to supplement your approach, your understanding, and your actions. You may choose to use these documents if you need more context or guidance. Not every task will require this action. As you learn more from your own actions, the output of running code, or from querying the web, place relevant information in the docs folder. You can choose the structure that best works for you. 

There are a set of external documentation, in the form of a Title and Link, in the LINKS.csv file. This list will allow you to quickly navigate to relevant documentation, guides, information to perform your action in the best possible way. If you query the web, put a link to the articles that were useful in the csv file. 

After you complete your actions, do not forget to add an entry to the LOG.txt file. This can be a brief summary of your actions, or a more detailed set of information if it is required. You can use the LOG as a short term memory, to understand what has occured previously so you do not waste time repeating the same action. 

You are working in a project which has git as a requirement. If you find there is no .gitignore file, you will need to add one. As you are developing, add relevant entries to .gitignore that you deem necessary. Explain this to the end user when needed. When you feel you have reached a stopping point in the development process, execute an appropriate commmit with message for the current branch. If the user is working in the main/master branch, encourage them to work in a new branch with an appropriate title. Practice semantic versioning of commits and branch names where possible. 

## Development Commands

Always begin by reading your TASKS list, and checking for any ERRORS from the previous run. Use the LOG to check for previous actions and prompts. Read through the documentation found in /vibe/docs/*. 

Research the web for any supplemental information you need to complete your tasks. If you use a LINK from the web, write it to LINKS.csv. Store any necessary documentation in the .vibe/docs/* folder with an appropriate file name. 

Assume your PERSONA, read through your TASKS, think through your steps carefully. 

Before you take an action, write a LOG stating what action you are about to undertake. Do this for each action you take. 

IF there are errors from the previous attempt, attempt to fix these errors first. 
IF there are no errors, begin completing your tasks. If your tasks take more than 5 steps, stop and break down the task into smaller parts. Add these subtasks to .vibe/TASKS.md, then continue taking your actions. 

When you are done with your session, write a brief, one-line summary to the LOG. When you complete a TASK, set the TASK as completed in the TASKS list. 

Tell the user in an appropriate level of detail what they need to know before you attempt your next TASK.
EOF

echo "✅ .vibe folder structure and CLAUDE.md created successfully!"
echo ""
echo "Created files:"
echo "  - CLAUDE.md"
echo "  - .vibe/PERSONA.md"
echo "  - .vibe/TASKS.md"
echo "  - .vibe/ERRORS.md"
echo "  - .vibe/LINKS.csv"
echo "  - .vibe/LOG.txt"
echo "  - .vibe/ENVIRONMENT.md"
echo "  - .vibe/docs/ (directory)"