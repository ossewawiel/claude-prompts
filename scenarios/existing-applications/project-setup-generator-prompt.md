# Project Setup Generator Prompt - Claude Code Instructions

## CONTEXT
- **Project Type**: scenario
- **Complexity**: advanced
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Purpose
This prompt generates all necessary Claude Code project files, folder structure, and documentation after project analysis is complete. It creates the proper directory structure with standards, best practices, and memory-loaded documents for optimal Claude Code assistance.

### Usage Instructions
Execute this prompt immediately after completing the project analysis prompt to set up the complete Claude Code project environment.

## IMPLEMENTATION STRATEGY

### PROJECT SETUP GENERATOR PROMPT TEMPLATE

```markdown
# Project Setup Generator Request

Based on the completed project analysis, I need you to generate all necessary Claude Code project files and folder structure for optimal development assistance.

## Required Directory Structure Creation

### 1. Core Documentation Folder
Create `docs/` folder with the following structure:
```
docs/
├── system-summary.md           # Comprehensive system documentation
├── architecture/
│   ├── overview.md            # High-level architecture
│   ├── database-schema.md     # Database design documentation
│   └── api-documentation.md   # API endpoint documentation
├── development/
│   ├── setup-guide.md         # Local development setup
│   ├── coding-standards.md    # Project-specific coding standards
│   ├── testing-guide.md       # Testing procedures and standards
│   └── deployment-guide.md    # Build and deployment procedures
└── references/
    ├── external-apis.md       # Third-party integration documentation
    ├── troubleshooting.md     # Common issues and solutions
    └── team-contacts.md       # Team and contact information
```

### 2. Claude Code Memory Folder
Create `.claude-code/` folder with automatically loaded documents:
```
.claude-code/
├── project-context.md         # Project-specific context for Claude
├── development-patterns.md    # Common patterns used in this project
├── testing-patterns.md        # Testing approaches and examples
├── database-patterns.md       # Database usage patterns
├── security-patterns.md       # Security implementation patterns
└── troubleshooting-quick-ref.md # Quick troubleshooting reference
```

### 3. Standards and Best Practices Integration
Create project-specific standards documents that reference global templates:

#### Coding Standards Document
Location: `docs/development/coding-standards.md`
Content should include:
- Reference to appropriate global coding standards from `/mnt/d/sourcecode/claude-prompts/guides/coding-standards/`
- Project-specific naming conventions
- Code organization patterns used in this project
- Exception handling patterns
- Logging standards
- Documentation requirements

#### Testing Standards Document  
Location: `docs/development/testing-guide.md`
Content should include:
- Reference to appropriate testing strategies from `/mnt/d/sourcecode/claude-prompts/testing/strategies/`
- Project-specific test organization
- Test data management
- Mock service patterns
- Coverage requirements
- Performance testing procedures

#### Database Standards Document
Location: `docs/architecture/database-schema.md`
Content should include:
- Reference to database guides from `/mnt/d/sourcecode/claude-prompts/guides/database/`
- Current schema documentation
- Migration procedures
- Performance optimization guidelines
- Indexing strategies

## Required Document Generation

### 1. Enhanced CLAUDE.md (Project Root)
Update the project's CLAUDE.md with:

```markdown
# CLAUDE.md

## Project Context
- **Project Name**: [Project Name]
- **Technology Stack**: [Technologies identified in analysis]
- **Architecture Pattern**: [Pattern identified]
- **Database**: [Database technology and version]
- **Last Updated**: [Current date]

## Global Template Library Integration
This project uses the global Claude Code template library located at:
`/mnt/d/sourcecode/claude-prompts/`

### Referenced Global Templates
- **Coding Standards**: [Link to applicable standards]
- **Testing Strategy**: [Link to testing approaches]
- **Database Integration**: [Link to database guides]
- **Architecture Patterns**: [Link to architectural patterns]

## Project-Specific Documentation
### Core Documentation
- **System Summary**: `docs/system-summary.md`
- **Architecture Overview**: `docs/architecture/overview.md`
- **Setup Guide**: `docs/development/setup-guide.md`
- **Testing Guide**: `docs/development/testing-guide.md`

### Claude Code Memory Documents
Located in `.claude-code/` folder (automatically loaded):
- **Project Context**: `.claude-code/project-context.md`
- **Development Patterns**: `.claude-code/development-patterns.md`
- **Testing Patterns**: `.claude-code/testing-patterns.md`
- **Database Patterns**: `.claude-code/database-patterns.md`
- **Security Patterns**: `.claude-code/security-patterns.md`

## Development Commands
### Build Commands
```bash
[Project-specific build commands]
```

### Test Commands
```bash
[Project-specific test commands]
```

### Code Quality Commands
```bash
[Linting, formatting, static analysis commands]
```

## Common Development Tasks
- **Adding New Features**: [Reference to development patterns]
- **Database Changes**: [Reference to migration procedures]
- **API Changes**: [Reference to API documentation standards]
- **Testing New Code**: [Reference to testing guide]

## Troubleshooting
- **Quick Reference**: `.claude-code/troubleshooting-quick-ref.md`
- **Detailed Guide**: `docs/references/troubleshooting.md`
- **Team Contacts**: `docs/references/team-contacts.md`
```

### 2. Claude Code Memory Documents
Generate these documents in `.claude-code/` folder:

#### Project Context (.claude-code/project-context.md)
```markdown
# Project Context for Claude Code

## Project Overview
[Brief description of what this project does]

## Technology Stack
[Detailed technology breakdown]

## Architecture Summary
[High-level architecture description]

## Key Components
[List of main components with file paths]

## Business Logic Areas
[Main functional areas of the application]

## External Dependencies
[Third-party services, APIs, databases]

## Development Conventions
[Naming conventions, code organization patterns]
```

#### Development Patterns (.claude-code/development-patterns.md)
```markdown
# Development Patterns for Claude Code

## Code Organization Patterns
[How code is structured in this project]

## Common Implementation Patterns
[Frequently used patterns with examples]

## Configuration Patterns
[How configuration is managed]

## Error Handling Patterns
[Standard error handling approaches]

## Logging Patterns
[Logging implementation standards]

## Integration Patterns
[How external systems are integrated]
```

#### Testing Patterns (.claude-code/testing-patterns.md)
```markdown
# Testing Patterns for Claude Code

## Test Organization
[How tests are structured and organized]

## Unit Testing Patterns
[Common unit testing approaches with examples]

## Integration Testing Patterns
[Integration testing strategies used]

## Mock Service Patterns
[How external services are mocked]

## Test Data Patterns
[Test data creation and management]

## Performance Testing Patterns
[Performance testing approaches]
```

#### Database Patterns (.claude-code/database-patterns.md)
```markdown
# Database Patterns for Claude Code

## Entity Patterns
[Common entity design patterns]

## Repository Patterns
[Data access layer patterns]

## Migration Patterns
[Database migration strategies]

## Query Patterns
[Common query patterns and optimizations]

## Transaction Patterns
[Transaction management approaches]

## Caching Patterns
[Database caching strategies]
```

#### Security Patterns (.claude-code/security-patterns.md)
```markdown
# Security Patterns for Claude Code

## Authentication Patterns
[How authentication is implemented]

## Authorization Patterns
[Authorization and access control patterns]

## Input Validation Patterns
[Validation strategies and implementations]

## Security Headers Patterns
[HTTP security header configurations]

## Data Protection Patterns
[Sensitive data handling approaches]

## API Security Patterns
[API endpoint security measures]
```

#### Troubleshooting Quick Reference (.claude-code/troubleshooting-quick-ref.md)
```markdown
# Troubleshooting Quick Reference

## Common Build Issues
[Quick fixes for build problems]

## Common Runtime Issues
[Quick fixes for runtime problems]

## Database Issues
[Quick database troubleshooting]

## Performance Issues
[Quick performance diagnostics]

## Security Issues
[Quick security checks]

## Diagnostic Commands
[Key commands for troubleshooting]
```

## File Generation Requirements

### 1. Directory Structure Creation
Execute commands to create all required directories:
```bash
# Create main documentation structure
mkdir -p docs/{architecture,development,references}

# Create Claude Code memory folder
mkdir -p .claude-code

# Verify structure
tree docs .claude-code
```

### 2. Document Population
For each document, ensure:
- **Complete Content**: All sections filled with project-specific information
- **Global Template References**: Proper links to global template library
- **File Path References**: Include specific file paths and line numbers where applicable
- **Command Examples**: Working examples of project-specific commands
- **Troubleshooting**: Practical solutions for common issues

### 3. Cross-Reference Integration
Ensure all documents reference each other appropriately:
- CLAUDE.md points to all relevant documents
- Memory documents reference detailed documentation
- Troubleshooting guides reference relevant patterns
- Standards documents reference global templates

## Validation Requirements

### 1. File System Validation
```bash
# Verify all directories exist
ls -la docs/
ls -la .claude-code/

# Verify all required files exist
find docs -name "*.md" | wc -l
find .claude-code -name "*.md" | wc -l
```

### 2. Content Validation
- [ ] All documents contain project-specific information (not template placeholders)
- [ ] All global template references are correct and accessible
- [ ] All file path references are accurate
- [ ] All commands have been tested and work
- [ ] All troubleshooting steps are verified

### 3. Integration Validation
- [ ] CLAUDE.md properly references all documents
- [ ] Claude Code memory documents are automatically loadable
- [ ] Cross-references between documents work correctly
- [ ] Global template integration is functional

## Success Criteria

After executing this prompt, the project should have:
- [ ] Complete documentation structure in `docs/` folder
- [ ] All Claude Code memory documents in `.claude-code/` folder
- [ ] Updated CLAUDE.md with proper references
- [ ] Project-specific standards that reference global templates
- [ ] Comprehensive troubleshooting documentation
- [ ] Working development commands and procedures
- [ ] Proper integration with global template library
- [ ] All documents contain actual project information (not placeholders)

## Post-Generation Tasks

### 1. Verification Steps
```bash
# Test that all build commands work
[Execute build commands from CLAUDE.md]

# Test that all test commands work
[Execute test commands from CLAUDE.md]

# Verify global template references
[Check that referenced templates exist and are accessible]
```

### 2. Documentation Review
- Review all generated documents for accuracy
- Verify that all project-specific information is correct
- Ensure troubleshooting guides address actual project issues
- Confirm that development patterns match actual codebase patterns

### 3. Team Integration
- Share location of documentation with team members
- Ensure team understands how to update documentation
- Establish review process for documentation updates
- Set up automated checks for documentation consistency
```

## CLAUDE_CODE_COMMANDS

### Directory Setup
```bash
# Create complete directory structure
mkdir -p docs/{architecture,development,references}
mkdir -p .claude-code
touch .claude-code/.gitkeep  # Ensure folder is tracked in git
```

### Template Integration
```bash
# Verify global template library access
ls -la /mnt/d/sourcecode/claude-prompts/
find /mnt/d/sourcecode/claude-prompts/ -name "*.md" | grep -E "(coding-standards|testing|database)"
```

### Documentation Generation
```bash
# Generate file list for documentation
find . -name "*.md" | sort > docs/references/documentation-index.md
```

### Validation Commands
```bash
# Validate directory structure
tree docs .claude-code 2>/dev/null || find docs .claude-code -type d
# Validate document count
echo "docs files: $(find docs -name '*.md' | wc -l)"
echo "claude-code files: $(find .claude-code -name '*.md' | wc -l)"
```

## VALIDATION_CHECKLIST
- [ ] All required directories created
- [ ] All required documents generated with project-specific content
- [ ] CLAUDE.md updated with proper references
- [ ] Global template library properly integrated
- [ ] Claude Code memory documents contain relevant patterns
- [ ] All file paths and references are accurate
- [ ] All commands tested and verified working
- [ ] Documentation cross-references are functional
- [ ] Troubleshooting guides address actual project issues
- [ ] Team has access to and understands documentation structure