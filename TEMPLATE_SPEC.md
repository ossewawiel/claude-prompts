# Claude Code Template Format Specification

## Overview

This document defines the standardized format for all Claude Code templates to ensure consistency and optimal performance when working with Claude.

## Template Categories

- **Scenarios** (`scenarios/`): Complete application blueprints for new projects
- **Components** (`components/`): Reusable features for existing projects  
- **Stacks** (`stacks/`): Technology combinations and configurations
- **Patterns** (`patterns/`): Implementation patterns and best practices
- **Integrations** (`integrations/`): Third-party service connections

## Universal Template Structure

Every template MUST follow this structure:

```markdown
# {{template_title}} - Claude Code Instructions

## CONTEXT
- **Project Type**: [web-app|mobile-app|api-service|desktop-app|library|tool]
- **Complexity**: [simple|medium|complex]
- **Last Updated**: YYYY-MM-DD
- **Template Version**: [semantic_version]

## MANDATORY REQUIREMENTS

### Technology Stack
- **Primary Framework**: [specific version]
- **Language**: [specific version]
- **Required Dependencies**: [list with exact versions]

### Project Structure
```
{{project_name}}/
├── [exact folder structure]
└── [configuration files]
```

## IMPLEMENTATION STRATEGY

### Phase 1: Foundation
- [ ] [Specific, actionable tasks]

### Phase 2: Core Features  
- [ ] [Ordered implementation steps]

### Phase 3: Testing & Polish
- [ ] [Production readiness checklist]

## CLAUDE_CODE_COMMANDS

```bash
# Initial setup commands
[command_with_versions]

# Development workflow commands
[standardized_scripts]
```

## PROJECT_VARIABLES
- **{{variable_name}}**: [description and constraints]

## VALIDATION_CHECKLIST
- [ ] [Specific validation criteria]
- [ ] [Production readiness requirements]
```

## Key Requirements

### Required Sections
- **CONTEXT**: Project metadata and versioning
- **MANDATORY REQUIREMENTS**: Technology stack and project structure
- **IMPLEMENTATION STRATEGY**: Phased development approach
- **CLAUDE_CODE_COMMANDS**: Executable setup and development commands
- **VALIDATION_CHECKLIST**: Specific validation criteria

### Optional Sections
- **PROJECT_VARIABLES**: Template customization variables
- **CONDITIONAL_REQUIREMENTS**: Configuration options based on conditions
- **INCLUDE_MODULES**: References to other templates (@include: template.md)

## Naming Conventions

### File Naming
Format: `[technology]-[type]-[descriptor].md`
- `react-typescript-spa.md`
- `spring-boot-kotlin-enterprise.md`
- `stripe-payment-integration.md`

### Template Titles
Format: `[Technology Stack] [Application Type] - Claude Code Instructions`

## Variable System

### Variable Format
- Use `{{variable_name}}` format
- Lowercase with underscores
- Include description and constraints
- Support string, enum, boolean, and number types

## Template References

### Include Syntax
```markdown
@include: template-name.md
@include: components/authentication.md
```

## Quality Standards

Templates must:
1. Use valid markdown syntax
2. Include all required sections
3. Provide working code examples
4. Use semantic versioning
5. Include clear validation criteria

## Best Practices

- Keep instructions clear and unambiguous
- Use logical section ordering
- Minimize cross-references for simplicity
- Include common error scenarios and solutions
- Provide progress tracking capabilities