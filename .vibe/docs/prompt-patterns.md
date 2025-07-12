# Prompt Pattern Examples

Based on Anthropic's recommendations, here are effective prompt patterns for common tasks:

## 1. File Analysis Pattern

```
<instructions>
Analyze the provided file and identify all functions that handle user authentication.
</instructions>

<data>
[File contents here]
</data>

<thinking>
Let me examine this file systematically:
1. First, I'll identify all function definitions
2. Then check which ones relate to authentication
3. Look for keywords like 'auth', 'login', 'user', 'token'
</thinking>

<output>
Found authentication-related functions:
- `validateUser()` at line 45
- `generateToken()` at line 78
- `checkPermissions()` at line 123
</output>
```

## 2. Code Generation Pattern

```
<role>
You are an experienced Python developer who writes clean, well-documented code.
</role>

<task>
Create a function that validates email addresses according to RFC 5322.
</task>

<requirements>
- Use regex for validation
- Include docstring with examples
- Handle edge cases gracefully
- Return boolean result
</requirements>

<example>
def validate_phone(phone_number):
    """
    Validates US phone numbers.
    
    Args:
        phone_number (str): Phone number to validate
        
    Returns:
        bool: True if valid, False otherwise
        
    Examples:
        >>> validate_phone("555-123-4567")
        True
        >>> validate_phone("invalid")
        False
    """
    pattern = r'^\d{3}-\d{3}-\d{4}$'
    return bool(re.match(pattern, phone_number))
</example>
```

## 3. Debugging Pattern

```
<context>
The application crashes when processing large CSV files (>1GB).
</context>

<error>
MemoryError: Unable to allocate array with shape (10000000, 50)
</error>

<code>
def process_csv(filename):
    df = pd.read_csv(filename)
    return df.groupby('category').sum()
</code>

<task>
1. Identify the cause of the memory error
2. Suggest a solution that handles large files efficiently
3. Provide updated code with explanation
</task>
```

## 4. Refactoring Pattern

```
<instructions>
Refactor this code to follow SOLID principles and improve maintainability.
</instructions>

<current_code>
[Original code here]
</current_code>

<guidelines>
- Separate concerns into different classes
- Use dependency injection
- Add appropriate interfaces/protocols
- Maintain backward compatibility
</guidelines>

<output_format>
1. Explanation of issues with current code
2. Refactoring plan
3. New code implementation
4. Migration notes
</output_format>
```

## 5. Documentation Pattern

```
<task>
Document this API endpoint comprehensively.
</task>

<endpoint_details>
POST /api/users/
Body: { "email": string, "name": string, "role": string }
Returns: { "id": number, "created_at": string }
</endpoint_details>

<requirements>
- Include request/response examples
- Document all possible error codes
- Explain authentication requirements
- Add usage notes
</requirements>

<format>
Use OpenAPI 3.0 specification format
</format>
```

## Key Principles

1. **Always separate instructions from data** using XML tags
2. **Be explicit about output format** requirements
3. **Provide examples** when asking for specific formats
4. **Include thinking steps** for complex analysis
5. **Specify role/context** when it affects the response style

## Common XML Tags

- `<instructions>` - What needs to be done
- `<data>` - Input data to process
- `<thinking>` - Step-by-step reasoning
- `<output>` - Final formatted result
- `<example>` - Examples to follow
- `<context>` - Background information
- `<requirements>` - Specific requirements
- `<format>` - Output format specification