# Anthropic Prompt Engineering Recommendations

Based on the Anthropic Prompt Engineering Interactive Tutorial, here are the key recommendations to incorporate into our approach:

## Core Principles

### 1. **Be Clear and Direct**
- Claude responds best to clear and direct instructions
- Claude has no context on what to do aside from what you literally tell it
- Follow the Golden Rule: Show your prompt to a colleague - if they're confused, Claude's confused
- Ask for exactly what you want in a straightforward manner

### 2. **Use Proper Message Structure**
- Messages must alternate between `user` and `assistant` roles
- Messages must start with a `user` turn
- Use the Messages API format correctly with role and content fields

### 3. **System Prompts Are Powerful**
- Use system prompts to provide context, instructions, and guidelines
- A well-written system prompt can improve Claude's performance
- System prompts help Claude follow rules and instructions better

### 4. **XML Tags for Organization**
- Use XML tags as separators (Claude was trained specifically to recognize them)
- XML tags help Claude know where variables/data start and end
- Use tags like `<example>`, `<data>`, `<instructions>`, etc.
- No "special sauce" XML tags - Claude is customizable

### 5. **Role Prompting**
- Give Claude specific roles with necessary context
- The more detail in the role context, the better
- Can be in system prompt or user message
- Consider the intended audience

### 6. **Separate Data from Instructions**
- Make clear distinctions between instructions and data
- Use XML tags or other delimiters
- Small details matter - scrub for typos and errors
- Claude is more likely to make mistakes when you make mistakes

### 7. **Output Formatting**
- Be explicit about desired output format
- Use XML tags to structure output
- Can "speak for Claude" by prefilling the assistant response
- Put the first XML tag in the assistant turn to guide format

### 8. **Think Step-by-Step**
- Allow Claude to think through problems before answering
- Spell out the steps Claude should take
- For complex tasks, have Claude work through a process
- Use thinking/reasoning sections before final answers

### 9. **Few-Shot Examples**
- Provide correctly-formatted examples
- Claude can extrapolate from examples
- Examples are especially useful for formatting
- Include edge cases in examples

### 10. **Avoid Hallucinations**
- Many methods exist to reduce hallucinations
- Put questions/tasks AFTER any reference text
- Be specific about what Claude should and shouldn't do
- Tell Claude to say "I don't know" when appropriate

## Complex Prompt Structure

For complex prompts, use this recommended structure (order matters):

1. **Task Context** - Role and goals
2. **Tone Context** - How Claude should communicate
3. **Detailed Task Description** - What Claude needs to do
4. **Rules and Guidelines** - Important rules for the interaction
5. **Examples** - Enclosed in `<example>` tags
6. **Input Data** - Enclosed in appropriate XML tags
7. **Immediate Task Description** - The specific ask
8. **Thinking/Scratchpad** - For multi-step tasks
9. **Output Formatting** - How to structure the response

## Best Practices

- It's best to use many prompt elements to get your prompt working first, then refine and slim down
- Experiment to find your own prompt engineering style
- Not all prompts need every element of the complex structure
- Always verify prompts produce desired results
- Claude is sensitive to patterns - be consistent

## Implementation Actions

Based on these recommendations, we should update our approach to:

1. Always use XML tags for data/instruction separation
2. Be more explicit and direct in instructions
3. Use system prompts more effectively
4. Provide examples when asking for specific formats
5. Allow Claude to think step-by-step for complex tasks
6. Use role prompting to give better context
7. Structure complex prompts using the recommended format
8. Be careful about typos and formatting
9. Put questions/tasks after reference material
10. Use output formatting instructions with prefilled responses