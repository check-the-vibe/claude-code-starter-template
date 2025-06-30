# Research & Writing Project Guidelines

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

```bash
# Document Management
find ./drafts -name "*.md" -mtime -7  # Find recently modified drafts
grep -r "TODO\|FIXME" ./              # Find action items
wc -w document.md                     # Word count

# Version Control
git add -A && git commit -m "Draft: [description]"
git tag -a v1.0 -m "First complete draft"
git diff HEAD~1 document.md           # Compare with previous version

# Conversion Tools
pandoc input.md -o output.pdf         # Convert Markdown to PDF
pandoc input.md -o output.docx        # Convert Markdown to Word

# Bibliography Management
pandoc --citeproc --bibliography=refs.bib input.md -o output.pdf
```

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
- Version control helps track changes over time