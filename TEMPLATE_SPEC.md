# Claude Code Template Format Specification

## Overview

This document defines the standardized format for all Claude Code templates to ensure consistency, reusability, and optimal performance when working with Claude. All templates in the `claude-code-prompts/` repository must follow this specification.

## Template Categories

### 1. Scenario Templates
Complete application specifications for end-to-end development.
- **Location**: `scenarios/`
- **Purpose**: Full project blueprints with all components
- **Complexity**: High (2000-5000+ lines)
- **Usage**: Primary template for new projects

### 2. Component Templates  
Reusable modular components for specific functionality.
- **Location**: `components/`
- **Purpose**: Standalone features that can be integrated
- **Complexity**: Medium (500-1500 lines)
- **Usage**: Add specific capabilities to existing projects

### 3. Stack Templates
Technology combinations and configurations.
- **Location**: `stacks/`
- **Purpose**: Define technology ecosystems and dependencies
- **Complexity**: Medium (800-2000 lines)
- **Usage**: Technology foundation for projects

### 4. Pattern Templates
Architectural and design patterns.
- **Location**: `patterns/`
- **Purpose**: Implementation patterns and best practices
- **Complexity**: Low-Medium (300-1000 lines)
- **Usage**: Guide implementation approaches

### 5. Integration Templates
Third-party service integrations.
- **Location**: `integrations/`
- **Purpose**: External service connection specifications
- **Complexity**: Low-Medium (200-800 lines)
- **Usage**: Add external service capabilities

## Universal Template Structure

Every template MUST follow this exact structure:

```markdown
# {{template_title}} - Claude Code Instructions

## CONTEXT
**Project Type**: [web-app|mobile-app|api-service|desktop-app|library|tool]
**Complexity**: [simple|medium|complex]
**Timeline**: [sprint|mvp|production]
**Last Updated**: YYYY-MM-DD
**Template Version**: [semantic_version]

## MANDATORY REQUIREMENTS

### Technology Stack
- **Primary Framework**: [specific version]
- **Runtime**: [specific version]
- **Build Tool**: [specific version]
- **Language**: [specific version]
- **Required Dependencies**: [list with exact versions]

### Project Structure
```
{{project_name}}/
├── [exact folder structure]
│   ├── [subfolder]/
│   │   └── [file patterns]
└── [configuration files]
```

### Documentation Sources
- **Framework Docs**: [exact URLs to official documentation]
- **API References**: [exact URLs to API docs]
- **Best Practices**: [URLs to authoritative guides]

## STRICT GUIDELINES

### Code Standards
- [Specific linting rules with configuration]
- [Formatting requirements with tool versions]
- [Naming conventions with examples]
- [File organization rules]

### Testing Requirements
- **Unit Tests**: [coverage threshold and tools]
- **Integration Tests**: [required scenarios and tools]
- **E2E Tests**: [critical paths and frameworks]

### Security Practices
- [Authentication requirements]
- [Authorization patterns]
- [Data validation rules]
- [Security scanning requirements]

## IMPLEMENTATION STRATEGY

### Phase 1: Foundation
- [ ] [Specific, actionable tasks]
- [ ] [With clear acceptance criteria]

### Phase 2: Core Features
- [ ] [Ordered implementation steps]
- [ ] [With dependencies clearly marked]

### Phase 3: Testing & Polish
- [ ] [Validation and optimization tasks]
- [ ] [Production readiness checklist]

## CLAUDE_CODE_COMMANDS

### Initial Setup
```bash
# Exact commands to initialize project
[command_with_versions]
```

### Development Commands
```bash
# Commands for development workflow
[standardized_npm_scripts]
```

## VALIDATION_SCRIPTS

```[language]
// Automated validation code
// To verify template compliance
```

## PROJECT_VARIABLES
- **VARIABLE_NAME**: {{variable_placeholder}}
- **DESCRIPTION**: [purpose and constraints]

## CONDITIONAL_REQUIREMENTS

### IF condition == "value"
```[language]
// Conditional configuration
// Based on user choices
```

## INCLUDE_MODULES
- @include: [referenced_template.md]
- @include: [another_component.md]

## VALIDATION_CHECKLIST
- [ ] [Specific validation criteria]
- [ ] [That can be automatically checked]
- [ ] [Production readiness requirements]
```

## Section Specifications

### CONTEXT Section (Required)
Provides essential metadata about the template.

**Required Fields:**
- `Project Type`: One of predefined categories
- `Complexity`: simple/medium/complex based on size and difficulty
- `Timeline`: Expected development duration category
- `Last Updated`: ISO date format (YYYY-MM-DD)
- `Template Version`: Semantic versioning (major.minor.patch)

**Optional Fields:**
- `Architecture`: Architectural pattern description
- `Target Audience`: Developer skill level required
- `Prerequisites`: Required knowledge or setup

### MANDATORY REQUIREMENTS Section (Required)

#### Technology Stack Subsection
- **Exact Versions**: All dependencies must specify exact versions
- **Compatibility Matrix**: Document version compatibility constraints
- **Alternative Options**: Provide alternatives with trade-offs

#### Project Structure Subsection
- **ASCII Tree**: Visual folder structure representation
- **File Descriptions**: Purpose of key files and folders
- **Naming Patterns**: Consistent naming conventions

#### Documentation Sources Subsection
- **Official Sources Only**: Link to authoritative documentation
- **Version-Specific Links**: Ensure links match specified versions
- **Fallback References**: Provide alternative documentation sources

### STRICT GUIDELINES Section (Required)

#### Code Standards Subsection
```yaml
required_elements:
  - linting_configuration: "ESLint/Prettier configs with exact rules"
  - formatting_rules: "Automated formatting specifications"
  - naming_conventions: "With examples for each case type"
  - file_organization: "Maximum file sizes and organization rules"
```

#### Testing Requirements Subsection
```yaml
coverage_requirements:
  unit_tests: "minimum_percentage_with_tools"
  integration_tests: "required_scenarios_list"
  e2e_tests: "critical_user_paths"
  performance_tests: "benchmarks_and_thresholds"
```

### IMPLEMENTATION STRATEGY Section (Required)
Must provide clear, ordered phases with:
- Specific, actionable tasks
- Estimated timeframes
- Clear dependencies between phases
- Acceptance criteria for each phase

### CLAUDE_CODE_COMMANDS Section (Required)
Exact commands that Claude Code will execute:

```bash
# Commands must be:
# - Copy-pasteable
# - Version-specific
# - Cross-platform compatible (or provide alternatives)
# - Include all necessary flags and options
```

### VALIDATION_SCRIPTS Section (Required)
Automated checks for template compliance:

```javascript
// Must include:
// - File structure validation
// - Dependency verification
// - Configuration validation
// - Code standard compliance checks
```

### PROJECT_VARIABLES Section (Required)
Template customization system:

```yaml
variable_specification:
  name: "{{variable_name}}"
  type: "[string|number|boolean|enum]"
  required: "[true|false]"
  default: "[default_value]"
  description: "[purpose_and_constraints]"
  validation: "[validation_rules]"
```

### CONDITIONAL_REQUIREMENTS Section (Optional)
For templates with multiple configuration options:

```yaml
condition_format:
  trigger: "IF variable_name == 'value'"
  content: "[language-specific configuration]"
  alternatives: "[other condition branches]"
```

### INCLUDE_MODULES Section (Optional)
References to other templates and components:

```markdown
syntax: "@include: template-name.md"
purpose: "Modular composition of templates"
validation: "Referenced templates must exist"
```

### VALIDATION_CHECKLIST Section (Required)
Concrete validation criteria:
- Must be specific and testable
- Should cover functionality, performance, security
- Include both automated and manual checks
- Define production readiness criteria

## Template Naming Conventions

### File Naming
```
format: [technology]-[type]-[descriptor].md
examples:
  - react-typescript-spa.md
  - spring-boot-kotlin-enterprise.md
  - stripe-payment-integration.md
  - jwt-authentication.md
```

### Template Title Format
```
format: [Technology Stack] [Application Type] - Claude Code Instructions
examples:
  - "React TypeScript SPA - Claude Code Instructions"
  - "Spring Boot Kotlin Enterprise Application - Claude Code Instructions"
  - "Payment Integration with Stripe - Claude Code Instructions"
```

## Variable System Specification

### Variable Naming
```yaml
format: "{{variable_name}}"
conventions:
  - lowercase_with_underscores
  - descriptive_and_clear
  - no_abbreviations_unless_standard
examples:
  - "{{project_name}}"
  - "{{api_base_url}}"
  - "{{database_type}}"
  - "{{deployment_target}}"
```

### Variable Types
```yaml
string: "{{project_name}}"
enum: "{{database_type}}" # [postgresql|mysql|mongodb]
boolean: "{{enable_authentication}}" # [true|false]
number: "{{port_number}}" # 3000
list: "{{additional_features}}" # [feature1,feature2,feature3]
```

### Variable Validation
```javascript
const validation = {
  project_name: {
    pattern: /^[a-z][a-z0-9-]*$/,
    max_length: 50,
    reserved_words: ['test', 'admin', 'api']
  },
  port_number: {
    min: 1000,
    max: 65535,
    type: 'integer'
  }
}
```

## Cross-Reference System

### Include Syntax
```markdown
@include: template-name.md
@include: components/authentication.md
@include: integrations/stripe-payment.md
```

### Extend Syntax
```markdown
@extends: base-template.md
@overrides: 
  - section: TECHNOLOGY_STACK
  - section: PROJECT_STRUCTURE
```

### Reference Syntax
```markdown
@see-also: related-template.md
@requires: prerequisite-template.md
@conflicts-with: incompatible-template.md
```

## Quality Assurance Requirements

### Template Validation
Every template must pass:
1. **Markdown Linting**: Valid markdown syntax
2. **Structure Validation**: All required sections present
3. **Link Validation**: All URLs accessible and current
4. **Code Validation**: All code blocks syntactically correct
5. **Variable Validation**: All variables properly defined
6. **Cross-Reference Validation**: All @include references valid

### Testing Requirements
Templates must include:
1. **Example Implementation**: Working code example
2. **Test Cases**: Validation test scenarios
3. **Integration Tests**: Template combination testing
4. **User Acceptance Tests**: Real-world usage validation

### Maintenance Standards
1. **Version Control**: Semantic versioning for all templates
2. **Deprecation Policy**: Clear deprecation and migration paths
3. **Update Frequency**: Regular updates for dependency versions
4. **Community Feedback**: Incorporation of user feedback

## Template Lifecycle

### Development Process
1. **Draft**: Initial template creation with basic structure
2. **Review**: Peer review for compliance and quality
3. **Testing**: Validation with Claude Code in test scenarios
4. **Release**: Publication to template library
5. **Maintenance**: Regular updates and improvements

### Version Management
```yaml
versioning_scheme: "semantic_versioning"
major_changes: "Breaking changes to template structure"
minor_changes: "New features or significant improvements"
patch_changes: "Bug fixes and dependency updates"
```

### Deprecation Process
1. **Notice**: 90-day advance notice for breaking changes
2. **Migration Guide**: Clear upgrade path documentation
3. **Legacy Support**: Continued support during transition
4. **Retirement**: Final removal with archived access

## Integration with Claude Code

### Performance Optimization
Templates should be optimized for Claude Code processing:
- Clear, unambiguous instructions
- Logical section ordering
- Comprehensive but concise content
- Minimal cross-references to reduce complexity

### Error Handling
Templates must include:
- Common error scenarios and solutions
- Debugging guidance
- Fallback options for failed operations
- Recovery procedures for partial implementations

### Feedback Loop
Templates should facilitate:
- Progress tracking and reporting
- Quality validation at each phase
- User feedback collection
- Continuous improvement based on usage data

This specification ensures all Claude Code templates maintain high quality, consistency, and effectiveness for development teams.