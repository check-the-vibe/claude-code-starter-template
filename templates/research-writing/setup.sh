#!/bin/bash

# Claude Code Research & Writing Template - Standalone Setup Script
# This script contains all template content embedded directly
# Can be run via: curl -sL <url> | bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
TEMPLATE_NAME="research-writing"
TEMPLATE_VERSION="1.0.0"
VIBE_DIR=".vibe"
CLAUDE_FILE="CLAUDE.md"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Function to print section headers
print_header() {
    echo
    print_color "$PURPLE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_color "$PURPLE" " $1"
    print_color "$PURPLE" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to check if running in a git repository
check_git_repo() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to create a file with content and report status
create_file() {
    local file_path=$1
    local content=$2
    local description=$3
    
    if echo "$content" > "$file_path"; then
        print_color "$GREEN" "  ✓ Created: $description"
    else
        print_color "$RED" "  ✗ Failed to create: $description"
        return 1
    fi
}

# Function to prompt user for confirmation
confirm() {
    local prompt=$1
    local default=${2:-N}
    
    if [[ $default == "Y" ]]; then
        prompt="$prompt [Y/n]: "
    else
        prompt="$prompt [y/N]: "
    fi
    
    read -p "$prompt" response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Function to check for existing .vibe directory
check_existing_vibe() {
    if [[ -d "$VIBE_DIR" ]]; then
        print_color "$YELLOW" "⚠️  Warning: $VIBE_DIR directory already exists!"
        
        if confirm "Do you want to backup the existing directory?"; then
            # Create backups directory if it doesn't exist
            mkdir -p "${VIBE_DIR}/backups"
            
            local backup_name="backups/backup_$(date +%Y%m%d_%H%M%S)"
            local backup_path="${VIBE_DIR}/${backup_name}"
            
            # Create the specific backup directory
            mkdir -p "$backup_path"
            
            # Copy all files except the backups directory itself
            find "$VIBE_DIR" -maxdepth 1 -mindepth 1 ! -name 'backups' -exec cp -r {} "$backup_path/" \;
            
            print_color "$GREEN" "✓ Backed up to: $backup_path"
        elif ! confirm "Do you want to overwrite the existing directory?" "N"; then
            print_color "$RED" "✗ Setup cancelled by user"
            exit 1
        fi
        
        # Remove existing directory (except backups)
        find "$VIBE_DIR" -maxdepth 1 -mindepth 1 ! -name 'backups' -exec rm -rf {} \;
    fi
}

# Function to setup git repository
setup_git() {
    print_header "Git Setup"
    
    local git_initialized=false
    
    if ! check_git_repo; then
        if confirm "Initialize a new git repository?" "Y"; then
            if git init; then
                print_color "$GREEN" "✓ Git repository initialized"
                git_initialized=true
            else
                print_color "$RED" "✗ Failed to initialize git repository"
            fi
        fi
    else
        print_color "$GREEN" "✓ Git repository detected"
        print_color "$BLUE" "  Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    fi
    
    # Create or update .gitignore
    local gitignore_content="# Editor directories and files
.idea/
.vscode/
*.swp
*.swo
*~
.DS_Store

# Research & Writing specific
.vibe/backups/
.vibe/LOG.txt
drafts/versions/
*.tmp
*.bak
~$*

# Bibliography and citation tools
*.bbl
*.blg
*.aux
*.log
*.out

# Temporary files
*.temp
*.draft
.~lock.*

# Sensitive research data
*/confidential/
*/private/
*/interviews/*_raw.*

# Large data files
*.csv
*.xlsx
*.xls
data/raw/*

# OS generated files
Thumbs.db
.Spotlight-V100
.Trashes"

    if [[ -f .gitignore ]]; then
        # Append our entries if they don't exist
        local our_section="# Research & Writing specific"
        if ! grep -q "$our_section" .gitignore; then
            echo -e "\n$gitignore_content" >> .gitignore
            print_color "$GREEN" "✓ Updated existing .gitignore"
        else
            print_color "$BLUE" "  .gitignore already configured"
        fi
    else
        create_file ".gitignore" "$gitignore_content" ".gitignore"
    fi
    
    # Add backup directory to gitignore if not already there
    if ! grep -q "^.vibe/backups/" .gitignore 2>/dev/null; then
        echo ".vibe/backups/" >> .gitignore
    fi
    
    # Offer to create initial commit
    if [[ "$git_initialized" == true ]] || confirm "Create an initial commit?" "Y"; then
        if git add -A && git commit -m "feat: Initialize Claude Code research-writing template

- Add .vibe directory structure for research projects
- Configure CLAUDE.md with writing guidelines
- Set up research and documentation workflows
- Add writing templates and rubrics" 2>/dev/null; then
            print_color "$GREEN" "✓ Created initial commit"
        else
            print_color "$YELLOW" "⚠️  No changes to commit or commit failed"
        fi
    fi
}

# Main setup function
main() {
    print_header "Claude Code Research & Writing Template Setup v$TEMPLATE_VERSION"
    
    # Check for git
    if check_git_repo; then
        print_color "$GREEN" "✓ Git repository detected"
        print_color "$BLUE" "  Current branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
    fi
    
    # Check for existing .vibe directory
    check_existing_vibe
    
    # Get system information
    local os_info=$(uname -s)
    local current_dir=$(pwd)
    local user_name=$(whoami)
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    print_header "Creating Directory Structure"
    
    # Create directory structure
    mkdir -p "$VIBE_DIR/docs/templates"
    mkdir -p "$VIBE_DIR/docs/rubrics"
    mkdir -p "$VIBE_DIR/docs/guides"
    mkdir -p "$VIBE_DIR/backups"
    
    print_color "$GREEN" "✓ Created directory structure"
    
    print_header "Creating Configuration Files"
    
    # Create PERSONA.md
    create_file "$VIBE_DIR/PERSONA.md" "# Research & Writing Expert

You are an experienced research analyst and technical writer specializing in creating high-quality documentation, research papers, and written content. Your expertise spans academic research, technical documentation, content strategy, and various writing methodologies.

## Core Competencies
- **Research Methods**: Qualitative and quantitative research, literature reviews, data analysis
- **Writing Styles**: Technical writing, academic writing, creative writing, journalistic writing
- **Documentation**: API documentation, user guides, white papers, research reports
- **Content Strategy**: Information architecture, content planning, audience analysis
- **Quality Assurance**: Editing, proofreading, fact-checking, peer review processes

## Your Role
You assist with:
- Planning and structuring research projects
- Developing comprehensive documentation
- Creating clear, engaging written content
- Implementing best practices for technical and academic writing
- Establishing quality standards and assessment criteria
- Guiding effective research methodologies
- Ensuring proper citation and academic integrity

## Research Expertise
- **Primary Research**: Interviews, surveys, experiments, observations
- **Secondary Research**: Literature reviews, meta-analyses, systematic reviews
- **Data Analysis**: Qualitative coding, statistical analysis, trend identification
- **Source Evaluation**: Credibility assessment, bias detection, fact verification

## Writing Expertise
- **Technical Writing**: Clear, precise documentation for technical audiences
- **Academic Writing**: Research papers, dissertations, literature reviews
- **Business Writing**: Reports, proposals, executive summaries
- **Creative Writing**: Engaging narratives, compelling storytelling
- **Web Writing**: SEO-optimized content, user-focused documentation

## Approach
1. Always begin with thorough research and planning
2. Define clear objectives and target audiences
3. Create structured outlines before writing
4. Use evidence-based arguments and proper citations
5. Apply appropriate style guides consistently
6. Iterate based on feedback and peer review
7. Maintain high standards for accuracy and clarity" "PERSONA.md"
    
    # Create TASKS.md
    create_file "$VIBE_DIR/TASKS.md" "# Research & Writing Project Tasks

## Current Sprint
_Define your research objectives and writing deliverables_

### 🔍 Research Phase
- [ ] Define research questions and objectives
- [ ] Conduct literature review
- [ ] Identify and evaluate sources
- [ ] Gather primary research data
- [ ] Analyze findings and identify patterns

### 📝 Planning Phase
- [ ] Define target audience
- [ ] Create document outline
- [ ] Establish writing style and tone
- [ ] Set quality criteria and standards
- [ ] Plan review and revision cycles

### ✍️ Writing Phase
- [ ] Write first draft following outline
- [ ] Integrate research findings
- [ ] Add citations and references
- [ ] Create supporting visuals/diagrams
- [ ] Ensure consistent style and voice

### 📊 Review Phase
- [ ] Self-review for content accuracy
- [ ] Check citations and references
- [ ] Peer review for clarity
- [ ] Technical review if applicable
- [ ] Proofread for grammar and style

### ✅ Finalization Phase
- [ ] Incorporate feedback
- [ ] Final fact-checking
- [ ] Format according to guidelines
- [ ] Create executive summary
- [ ] Prepare for publication/submission

## Completed Tasks
_Move completed tasks here with timestamps_

## Research Log
_Track research activities and findings_

## Writing Progress
_Monitor drafts and revisions_" "TASKS.md"
    
    # Create ERRORS.md
    create_file "$VIBE_DIR/ERRORS.md" "<!-- Track writing and research issues for continuous improvement -->

# Research & Writing Error Log

_Document issues encountered during research and writing for process improvement_

## Common Issues to Track:
- Source access problems
- Citation format errors
- Style guide violations
- Fact-checking discrepancies
- Review feedback patterns
- Revision requirements

## Error Format:
\`\`\`
[Date] Issue Type: [Category]
Description: [Detailed description]
Impact: [How it affected the project]
Resolution: [How it was resolved]
Prevention: [Steps to avoid recurrence]
\`\`\`" "ERRORS.md"
    
    # Create LINKS.csv
    create_file "$VIBE_DIR/LINKS.csv" "title,url
Writing Well - Clear and Simple,https://www.plainlanguage.gov/guidelines/
Technical Writing Guide - Google,https://developers.google.com/tech-writing
Microsoft Writing Style Guide,https://learn.microsoft.com/en-us/style-guide/welcome/
Chicago Manual of Style,https://www.chicagomanualofstyle.org/
APA Style Guide,https://apastyle.apa.org/
MLA Style Center,https://style.mla.org/
IEEE Author Center,https://ieeeauthorcenter.ieee.org/
Nature Research Writing Guide,https://www.nature.com/nature-research/editorial-policies
Purdue OWL - Writing Lab,https://owl.purdue.edu/
Google Scholar,https://scholar.google.com/
Research Methods Knowledge Base,https://conjointly.com/kb/
SAGE Research Methods,https://methods.sagepub.com/
Zotero Documentation,https://www.zotero.org/support/
Mendeley Reference Manager,https://www.mendeley.com/guides
Academic Phrasebank,https://www.phrasebank.manchester.ac.uk/
They Say / I Say Templates,https://www.theysayiblog.com/
Hemingway Editor,http://www.hemingwayapp.com/
Grammarly Handbook,https://www.grammarly.com/blog/category/handbook/
Plain English Campaign,http://www.plainenglish.co.uk/
Write Like You Talk - Paul Graham,http://paulgraham.com/talk.html" "LINKS.csv"
    
    # Create LOG.txt
    create_file "$VIBE_DIR/LOG.txt" "[$timestamp] Project initialized with Claude Code $TEMPLATE_NAME template v$TEMPLATE_VERSION
[$timestamp] Created .vibe directory structure for research and writing projects
[$timestamp] Added writing guidelines, research templates, and documentation rubrics" "LOG.txt"
    
    # Create ENVIRONMENT.md
    create_file "$VIBE_DIR/ENVIRONMENT.md" "<!-- Environment context for research and writing projects -->

# Environment Information

## System Details
- **Operating System**: $os_info
- **Current Directory**: $current_dir
- **User**: $user_name
- **Date Initialized**: $timestamp

## Project Context
- **Git Repository**: $(if check_git_repo; then echo "Yes"; else echo "No"; fi)
- **Template**: Research & Writing
- **Focus**: Documentation, research papers, and written content

## Available Tools
- Document processing (Markdown, LaTeX, etc.)
- Reference management integration
- Version control for documents
- Collaboration workflows
- Export to multiple formats

## Writing Standards
- Follow established style guides
- Maintain consistent voice and tone
- Use clear, concise language
- Properly cite all sources
- Regular peer review process" "ENVIRONMENT.md"
    
    # Create docs subdirectory files
    create_file "$VIBE_DIR/docs/README.md" "# Research & Writing Documentation

This directory contains templates, guides, and rubrics for research and writing projects.

## Directory Structure

- **templates/**: Document templates for various writing types
- **rubrics/**: Assessment criteria and quality standards
- **guides/**: Writing and research methodology guides

## Quick Start

1. Choose appropriate templates from the templates/ directory
2. Review relevant guides for your writing type
3. Use rubrics to ensure quality standards
4. Follow the established workflow in TASKS.md

## Best Practices

- Always start with an outline
- Use version control for all documents
- Get peer reviews before finalizing
- Maintain a consistent style throughout
- Keep detailed research notes" "docs/README.md"
    
    # Create writing rubric
    create_file "$VIBE_DIR/docs/rubrics/writing-quality-rubric.md" "# Writing Quality Assessment Rubric

## Content Quality (40%)

### Excellent (90-100%)
- Comprehensive coverage exceeding requirements
- Deep insights and original thinking
- Expertly synthesized information
- Compelling arguments with strong evidence

### Good (70-89%)
- Thorough coverage meeting all requirements
- Clear understanding demonstrated
- Well-integrated information
- Solid arguments with adequate evidence

### Satisfactory (50-69%)
- Adequate coverage of main points
- Basic understanding shown
- Some integration of sources
- Arguments present but may lack depth

### Needs Improvement (0-49%)
- Incomplete or superficial coverage
- Limited understanding evident
- Poor integration of information
- Weak or unsupported arguments

## Writing Clarity (30%)

### Excellent (90-100%)
- Exceptionally clear and engaging prose
- Perfect grammar and syntax
- Varied sentence structure
- Precise word choice throughout

### Good (70-89%)
- Clear and well-organized writing
- Minor grammatical errors (1-2)
- Good sentence variety
- Appropriate vocabulary

### Satisfactory (50-69%)
- Generally clear with some confusion
- Several grammatical errors (3-5)
- Some sentence variety
- Adequate vocabulary

### Needs Improvement (0-49%)
- Unclear or confusing writing
- Many grammatical errors (6+)
- Repetitive sentence structure
- Poor vocabulary choices

## Research Quality (20%)

### Excellent (90-100%)
- Extensive, authoritative sources
- Perfect citation formatting
- Excellent source integration
- Critical evaluation of sources

### Good (70-89%)
- Good variety of credible sources
- Minor citation errors (1-2)
- Well-integrated sources
- Some source evaluation

### Satisfactory (50-69%)
- Adequate number of sources
- Some citation errors (3-4)
- Basic source integration
- Limited source evaluation

### Needs Improvement (0-49%)
- Insufficient or poor sources
- Many citation errors (5+)
- Poor source integration
- No source evaluation

## Format & Structure (10%)

### Excellent (90-100%)
- Perfect adherence to guidelines
- Excellent organization
- Professional presentation
- All required elements included

### Good (70-89%)
- Minor formatting issues (1-2)
- Good organization
- Clean presentation
- Most elements included

### Satisfactory (50-69%)
- Some formatting issues (3-4)
- Adequate organization
- Acceptable presentation
- Some elements missing

### Needs Improvement (0-49%)
- Major formatting problems (5+)
- Poor organization
- Unprofessional presentation
- Many elements missing

## Scoring Guide
- Total Score = (Content × 0.4) + (Clarity × 0.3) + (Research × 0.2) + (Format × 0.1)
- A: 90-100% | B: 80-89% | C: 70-79% | D: 60-69% | F: Below 60%" "docs/rubrics/writing-quality-rubric.md"
    
    # Create research template
    create_file "$VIBE_DIR/docs/templates/research-paper-template.md" "# [Research Paper Title]

**Author:** [Your Name]  
**Date:** [Date]  
**Version:** [Version Number]

## Abstract
[150-250 word summary of your research including purpose, methodology, key findings, and conclusions]

## Keywords
[5-7 keywords separated by commas]

## 1. Introduction

### 1.1 Background
[Provide context and background information]

### 1.2 Problem Statement
[Clearly define the problem your research addresses]

### 1.3 Research Questions
1. [Primary research question]
2. [Secondary research question]
3. [Additional questions if applicable]

### 1.4 Objectives
- [Objective 1]
- [Objective 2]
- [Objective 3]

### 1.5 Significance
[Explain why this research matters]

## 2. Literature Review

### 2.1 Theoretical Framework
[Discuss relevant theories]

### 2.2 Previous Research
[Summarize and analyze related work]

### 2.3 Research Gap
[Identify what's missing in current knowledge]

## 3. Methodology

### 3.1 Research Design
[Describe your overall approach]

### 3.2 Data Collection
[Explain how you gathered information]

### 3.3 Data Analysis
[Describe analytical methods]

### 3.4 Limitations
[Acknowledge research constraints]

## 4. Results

### 4.1 Findings Overview
[Summarize key findings]

### 4.2 Detailed Results
[Present results with supporting data]

### 4.3 Data Visualization
[Include charts, graphs, tables as needed]

## 5. Discussion

### 5.1 Interpretation
[Explain what the results mean]

### 5.2 Implications
[Discuss practical applications]

### 5.3 Comparison with Literature
[Relate to previous research]

## 6. Conclusion

### 6.1 Summary
[Recap main points]

### 6.2 Contributions
[Highlight your research contributions]

### 6.3 Future Research
[Suggest areas for further study]

## References
[List all cited sources in appropriate format]

## Appendices
[Include supplementary materials]" "docs/templates/research-paper-template.md"
    
    # Create writing guide
    create_file "$VIBE_DIR/docs/guides/effective-writing-guide.md" "# Effective Writing Guide

## Writing Process Overview

### 1. Pre-Writing Phase
- **Brainstorm**: Generate ideas freely
- **Research**: Gather relevant information
- **Audience Analysis**: Know who you're writing for
- **Purpose Definition**: Clear objective for writing
- **Outline Creation**: Structure your thoughts

### 2. Drafting Phase
- **Follow Outline**: Use your structure as a guide
- **Write Freely**: Don't edit while drafting
- **Focus on Ideas**: Grammar comes later
- **Use Placeholders**: Mark areas needing research
- **Complete Sections**: Finish thoughts before moving on

### 3. Revision Phase
- **Content Review**: Check completeness and accuracy
- **Structure Check**: Ensure logical flow
- **Argument Strength**: Verify evidence supports claims
- **Clarity Enhancement**: Simplify complex ideas
- **Transition Improvement**: Connect ideas smoothly

### 4. Editing Phase
- **Grammar Check**: Fix mechanical errors
- **Style Consistency**: Maintain uniform voice
- **Word Choice**: Use precise language
- **Sentence Variety**: Mix lengths and structures
- **Paragraph Structure**: Topic sentences and support

### 5. Proofreading Phase
- **Spelling Errors**: Use tools and manual review
- **Punctuation**: Check all marks
- **Formatting**: Ensure consistency
- **Citations**: Verify accuracy
- **Final Read**: Out loud if possible

## Writing Best Practices

### Clarity
1. Use simple words when possible
2. Define technical terms on first use
3. Write short sentences (15-20 words average)
4. One idea per paragraph
5. Use active voice predominantly

### Conciseness
1. Eliminate redundancy
2. Remove filler words
3. Combine related sentences
4. Use strong verbs
5. Avoid nominalizations

### Coherence
1. Use transitional phrases
2. Maintain consistent tense
3. Follow logical order
4. Use parallel structure
5. Connect to thesis throughout

### Engagement
1. Start with a hook
2. Use concrete examples
3. Include relevant anecdotes
4. Ask rhetorical questions
5. Vary sentence beginnings

## Common Writing Errors to Avoid

### Content Errors
- Unsupported claims
- Logical fallacies
- Plagiarism
- Factual inaccuracies
- Off-topic tangents

### Style Errors
- Wordiness
- Passive voice overuse
- Clichés
- Jargon without explanation
- Inconsistent tone

### Mechanical Errors
- Run-on sentences
- Sentence fragments
- Subject-verb disagreement
- Pronoun ambiguity
- Comma splices

## Quick Writing Tips

1. **Write daily**: Build the habit
2. **Read widely**: Learn from others
3. **Seek feedback**: Fresh perspectives help
4. **Revise multiple times**: First drafts are rough
5. **Know your purpose**: Every piece needs a goal
6. **Consider your reader**: Write for them, not you
7. **Use strong openings**: Hook readers immediately
8. **End memorably**: Leave lasting impressions
9. **Show, don't tell**: Use examples and evidence
10. **Practice regularly**: Writing improves with practice" "docs/guides/effective-writing-guide.md"
    
    # Create clean.sh script
    local clean_script="#!/bin/bash

# Clean script for Claude Code $TEMPLATE_NAME template

echo \"⚠️  This will remove the .vibe directory and $CLAUDE_FILE\"
read -p \"Are you sure you want to clean the Claude Code setup? [y/N]: \" confirm

if [[ \"\$confirm\" =~ ^[Yy]$ ]]; then
    rm -rf \"$VIBE_DIR\"
    rm -f \"$CLAUDE_FILE\"
    echo \"✓ Cleaned Claude Code setup\"
else
    echo \"✗ Clean cancelled\"
fi"

    create_file "clean.sh" "$clean_script" "clean.sh"
    chmod +x clean.sh
    
    # Create main CLAUDE.md file
    local claude_content="# Research & Writing Project Guidelines

This file provides guidance to Claude Code for research, writing, and documentation projects.

## Project Overview

This is a research and writing focused project that emphasizes structured methodologies, clear documentation, and high-quality written deliverables. The template provides frameworks for various types of research and writing tasks.

## Writing Standards

### Core Principles
- **Clarity**: Use clear, precise language to convey information accurately
- **Objectivity**: Maintain objectivity by relying on facts and evidence
- **Consistency**: Use uniform grammar, style, and formatting throughout
- **Accuracy**: Ensure all information is accurate, current, and properly cited
- **Accessibility**: Write for your defined audience using appropriate language levels

### Language Guidelines
- Use active voice for engagement and clarity
- Avoid jargon unless necessary for the audience
- Define technical terms on first use
- Keep sentences concise (10-20 words ideal)
- Limit paragraphs to 4-6 lines

### Structure Standards
- Use clear, descriptive headings and subheadings
- Provide executive summaries for longer documents
- Include tables of contents for documents over 10 pages
- Use numbered lists for sequential items
- Use bullet points for non-sequential items

## Research Methodology

### Information Gathering
1. **Primary Research**
   - Interviews and surveys
   - Direct observation
   - Original experiments or analysis

2. **Secondary Research**
   - Academic journals and papers
   - Industry reports and whitepapers
   - Credible online sources
   - Books and reference materials

### Source Evaluation
- Verify credibility and authority of sources
- Check publication dates for currency
- Cross-reference important facts
- Document all sources meticulously

### Citation Standards
- Use consistent citation format (APA, MLA, Chicago, etc.)
- Include all necessary bibliographic information
- Maintain a working bibliography throughout the project
- Use citation management tools when appropriate

## Documentation Process

### Planning Phase
1. Define the document's purpose and audience
2. Create a detailed outline
3. Establish timelines and milestones
4. Identify required resources and SMEs

### Development Phase
1. Conduct thorough research
2. Draft content following the outline
3. Integrate feedback from reviews
4. Refine and polish the text

### Review Phase
1. Self-review for content accuracy
2. Peer review for clarity and completeness
3. Technical review for factual correctness
4. Final proofreading for grammar and style

## Quality Rubric

### Content Quality (40%)
- **Excellent**: Comprehensive, insightful, goes beyond requirements
- **Good**: Thorough coverage, meets all requirements
- **Satisfactory**: Adequate coverage, meets most requirements
- **Needs Improvement**: Incomplete or superficial coverage

### Writing Quality (30%)
- **Excellent**: Exceptionally clear, engaging, error-free
- **Good**: Clear and well-organized, minimal errors
- **Satisfactory**: Generally clear, some minor errors
- **Needs Improvement**: Unclear or poorly organized, multiple errors

### Research Quality (20%)
- **Excellent**: Extensive, authoritative sources, excellent synthesis
- **Good**: Good variety of credible sources, well-integrated
- **Satisfactory**: Adequate sources, basic integration
- **Needs Improvement**: Limited or questionable sources

### Format & Presentation (10%)
- **Excellent**: Professional formatting, perfect adherence to guidelines
- **Good**: Clean formatting, follows most guidelines
- **Satisfactory**: Acceptable formatting, some deviations
- **Needs Improvement**: Poor formatting, doesn't follow guidelines

## Writing Workflow Commands

\`\`\`bash
# Document Management
find ./drafts -name \"*.md\" -mtime -7  # Find recently modified drafts
grep -r \"TODO\\|FIXME\" ./              # Find action items
wc -w document.md                     # Word count

# Version Control
git add -A && git commit -m \"Draft: [description]\"
git tag -a v1.0 -m \"First complete draft\"
git diff HEAD~1 document.md           # Compare with previous version

# Conversion Tools
pandoc input.md -o output.pdf         # Convert Markdown to PDF
pandoc input.md -o output.docx        # Convert Markdown to Word

# Bibliography Management
pandoc --citeproc --bibliography=refs.bib input.md -o output.pdf
\`\`\`

## Research Tools Integration

### Recommended Tools
- **Reference Management**: Zotero, Mendeley, EndNote
- **Note-Taking**: Obsidian, Notion, Roam Research
- **Writing**: Google Docs, Microsoft Word, LaTeX
- **Version Control**: Git, Google Docs version history
- **Collaboration**: Google Docs, Dropbox Paper, SharePoint

## Best Practices Reminders

### Before Writing
- Always start with research and planning
- Define your audience clearly
- Create a comprehensive outline
- Gather all necessary resources

### During Writing
- Follow the established style guide
- Maintain consistent voice and tone
- Save versions frequently
- Take breaks to maintain quality

### After Writing
- Always proofread before submitting
- Get peer reviews when possible
- Update documentation based on feedback
- Archive final versions properly

## Important Notes

- Quality over quantity - focus on clear, effective communication
- Always cite sources to avoid plagiarism
- Maintain academic integrity in all research
- Keep detailed notes for transparency
- Regular backups are essential
- Version control helps track changes over time"
    
    create_file "$CLAUDE_FILE" "$claude_content" "CLAUDE.md"
    
    # Git setup
    setup_git
    
    print_header "Setup Complete!"
    print_color "$GREEN" "✅ Successfully created Claude Code $TEMPLATE_NAME template!"
    
    print_color "$BLUE" "\n📁 Created structure:"
    echo "  .vibe/"
    echo "  ├── PERSONA.md        # Research & writing expertise"
    echo "  ├── TASKS.md          # Research and writing workflow"
    echo "  ├── ERRORS.md         # Error tracking"
    echo "  ├── LINKS.csv         # Writing and research resources"
    echo "  ├── LOG.txt           # Activity log"
    echo "  ├── ENVIRONMENT.md    # System context"
    echo "  ├── backups/          # Backup directory"
    echo "  └── docs/             # Templates and guides"
    echo "      ├── README.md"
    echo "      ├── templates/    # Document templates"
    echo "      │   └── research-paper-template.md"
    echo "      ├── rubrics/      # Assessment criteria"
    echo "      │   └── writing-quality-rubric.md"
    echo "      └── guides/       # Writing guides"
    echo "          └── effective-writing-guide.md"
    echo "  CLAUDE.md             # Main guidance file"
    echo "  clean.sh              # Cleanup script"
    
    print_color "$YELLOW" "\n🚀 Next steps:"
    echo "  1. Review .vibe/PERSONA.md for your research role"
    echo "  2. Check .vibe/docs/ for templates and guides"
    echo "  3. Update .vibe/TASKS.md with your research goals"
    echo "  4. Explore .vibe/LINKS.csv for writing resources"
    echo "  5. Start your research and writing project!"
    
    print_color "$CYAN" "\n💡 Pro tips:"
    echo "  - Use templates in .vibe/docs/templates/"
    echo "  - Apply rubrics in .vibe/docs/rubrics/ for quality"
    echo "  - Follow guides in .vibe/docs/guides/"
    echo "  - Track progress in .vibe/TASKS.md"
    echo "  - Reset with: ./clean.sh"
}

# Run main function
main "$@"