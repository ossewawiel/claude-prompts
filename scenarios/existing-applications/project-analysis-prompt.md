# Project Analysis Prompt - Claude Code Instructions

## CONTEXT
- **Project Type**: scenario
- **Complexity**: advanced
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Purpose
This prompt template analyzes existing projects, updates their CLAUDE.md file, imports relevant guides from the global template library, and creates a comprehensive system summary document.

### Usage Instructions
Use this prompt when you need to analyze an existing codebase and set up Claude Code for optimal development assistance.

## IMPLEMENTATION STRATEGY

### PROJECT ANALYSIS PROMPT TEMPLATE

```markdown
# Project Analysis Request

I need you to perform a comprehensive analysis of this existing project and set up Claude Code configuration for optimal development assistance.

## Analysis Tasks Required

### 1. Project Discovery
Please analyze the current project structure and identify:
- **Technology Stack**: Programming languages, frameworks, libraries in use
- **Architecture Pattern**: MVC, microservices, monolith, etc.
- **Database Technology**: Type of database and ORM/query libraries used
- **Build System**: Maven, Gradle, npm, CMake, etc.
- **Testing Framework**: Unit testing, integration testing tools
- **Package Management**: Dependencies and their versions
- **Development Environment**: IDE-specific files, containerization

### 2. Codebase Structure Analysis
Examine the project and document:
- **Module/Package Organization**: How code is structured and organized
- **Key Components**: Main classes, services, controllers, repositories
- **Configuration Files**: Application config, database config, build config
- **Entry Points**: Main application classes, startup procedures
- **External Integrations**: APIs, third-party services, databases
- **Business Logic Areas**: Core functionality domains

### 3. Development Patterns & Standards
Identify current patterns used in the project:
- **Coding Conventions**: Naming patterns, code organization
- **Design Patterns**: Architectural patterns in use
- **Security Implementation**: Authentication, authorization patterns
- **Error Handling**: How errors and exceptions are managed
- **Logging Strategy**: Logging framework and patterns used
- **Performance Optimizations**: Caching, database optimization

### 4. Global Template Integration
Based on the identified technology stack, import and reference relevant templates from `/mnt/d/sourcecode/claude-prompts/`:

**Required Actions:**
- Identify which coding standards apply to this project
- Reference appropriate testing strategies for the tech stack
- Include relevant database integration guides
- Reference applicable architectural patterns
- Include relevant component templates for future development

### 5. CLAUDE.md Setup
Create or update the project's CLAUDE.md file with:
- **Project Context**: Business purpose, team information, project status
- **Technology Stack**: Detailed breakdown of all technologies used
- **Architecture Overview**: High-level system design
- **Development Guidelines**: Project-specific coding standards and patterns
- **Build & Deploy Instructions**: How to build, test, and deploy the project
- **Global Template References**: Links to relevant claude-prompts templates
- **Common Commands**: Frequently used development commands
- **Testing Strategy**: How to run different types of tests
- **Troubleshooting**: Common issues and solutions

### 6. System Summary Document Creation
Create a comprehensive system summary document at `docs/system-summary.md` (or appropriate docs folder) using the system summary template. This document should include:
- Complete technical overview
- Component relationships and dependencies  
- Data flow diagrams (textual descriptions)
- API documentation summary
- Database schema overview
- Security model summary
- Deployment architecture
- Monitoring and logging setup

## Expected Deliverables

1. **Updated/Created CLAUDE.md** in project root
2. **System Summary Document** in docs folder
3. **Template References** integrated into project documentation
4. **Development Command Summary** for common operations
5. **Identified Gaps** - areas where development could be improved with additional templates

## Analysis Depth Required

### Code Analysis
- Examine at least 10-15 key files across different modules
- Identify common patterns and architectural decisions
- Document unusual or project-specific implementations
- Note technical debt or improvement opportunities

### Configuration Analysis  
- All build configuration files
- Database connection and migration setup
- Security configuration
- Environment-specific configurations
- CI/CD pipeline configuration (if present)

### Documentation Analysis
- Existing README files
- API documentation
- Database documentation  
- Deployment guides
- Architecture decision records

## Template Integration Guidelines

### Coding Standards Integration
Reference appropriate standards from:
- `/mnt/d/sourcecode/claude-prompts/guides/coding-standards/`
- Include project-specific deviations or additions

### Testing Strategy Integration
Reference relevant testing approaches from:
- `/mnt/d/sourcecode/claude-prompts/testing/strategies/`
- Document current test coverage and identify gaps

### Database Integration
Reference database guides from:
- `/mnt/d/sourcecode/claude-prompts/guides/database/`
- Document current database patterns and optimization opportunities

### Architecture Patterns
Reference relevant patterns from:
- `/mnt/d/sourcecode/claude-prompts/patterns/`
- Document how patterns are implemented in this specific project

## Success Criteria

- [ ] CLAUDE.md provides clear project context and development guidance
- [ ] System summary document gives comprehensive technical overview
- [ ] All relevant global templates are properly referenced
- [ ] Common development commands are documented and tested
- [ ] Future developers can quickly understand and contribute to the project
- [ ] Testing strategies are clearly documented and executable
- [ ] Build and deployment processes are clearly explained
```

## CLAUDE_CODE_COMMANDS

### Initial Project Scan
```bash
# Scan project structure
find . -type f -name "*.md" | head -20           # Find documentation
find . -name "pom.xml" -o -name "build.gradle*" -o -name "package.json" -o -name "CMakeLists.txt" # Build files
find . -name "application*.yml" -o -name "application*.properties" -o -name "*.config" # Config files
```

### Technology Detection
```bash
# Detect languages and frameworks
find . -name "*.kt" | wc -l                      # Kotlin files
find . -name "*.java" | wc -l                    # Java files  
find . -name "*.cpp" -o -name "*.cc" | wc -l     # C++ files
find . -name "*.js" -o -name "*.jsx" | wc -l     # JavaScript files
```

### Database Analysis
```bash
# Find database-related files
find . -name "*migration*" -o -name "*schema*"   # Database migrations
find . -name "*.sql"                             # SQL files
grep -r "spring.datasource" . 2>/dev/null       # Spring database config
```

### Build System Analysis
```bash
# Analyze build configuration
cat build.gradle* 2>/dev/null || cat pom.xml 2>/dev/null || cat package.json 2>/dev/null
ls -la | grep -E "(gradle|maven|npm|yarn)"      # Build tool indicators
```

## VALIDATION_CHECKLIST
- [ ] All major project components identified and documented
- [ ] Technology stack completely mapped
- [ ] Relevant global templates identified and referenced
- [ ] CLAUDE.md provides actionable development guidance
- [ ] System summary document is comprehensive and accurate
- [ ] Build and test commands verified to work
- [ ] Documentation structure supports future development
- [ ] Integration points with global template library established
- [ ] Project-specific patterns and conventions documented
- [ ] Development workflow clearly explained