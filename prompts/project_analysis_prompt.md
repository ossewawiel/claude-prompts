# Existing Project Analysis Prompt

## Objective
Analyze an existing project to understand its current state, technology stack, architecture, and create a comprehensive project summary. This analysis should produce only documentation—no code changes or new features.

---

## Analysis Request

I need you to perform a comprehensive analysis of this existing project and create a concise project summary document. **Focus on understanding and documenting what currently exists—do not create new features or modify existing code.**

### Phase 1: Project Discovery & Technology Stack Analysis

**Examine the project structure and identify:**

1. **Technology Stack Detection**
   - Programming languages and versions used
   - Frameworks and their versions (React, Spring Boot, Django, etc.)
   - Build tools (npm, Maven, Gradle, etc.)
   - Package managers and dependency files
   - Runtime environments (Node.js, JVM, Python, etc.)

2. **Database & Data Layer**
   - Database technology (MySQL, PostgreSQL, MongoDB, etc.)
   - ORM/ODM libraries (Hibernate, Sequelize, Mongoose, etc.)
   - Migration systems in use
   - Configuration files for data connections

3. **Architecture Pattern Identification**
   - Overall architecture style (monolith, microservices, serverless)
   - Design patterns in use (MVC, Repository, Factory, etc.)
   - Project structure and module organization
   - Service layer organization

4. **Development Environment**
   - IDE configuration files present
   - Containerization (Docker, docker-compose)
   - Environment configuration management
   - Build and deployment scripts

### Phase 2: Codebase Structure Analysis

**Document the current codebase organization:**

1. **Entry Points & Main Components**
   - Application startup/bootstrap files
   - Main controllers, services, or components
   - Configuration and setup files
   - Key business logic modules

2. **External Integrations**
   - Third-party APIs being used
   - External service connections
   - Authentication providers
   - Payment or messaging systems

3. **Current Features & Functionality**
   - Core business features implemented
   - User-facing functionality
   - Admin or management features
   - Background jobs or scheduled tasks

### Phase 3: Development Patterns & Quality Assessment

**Identify existing patterns and standards:**

1. **Code Organization**
   - Naming conventions used
   - File and folder structure patterns
   - Import/dependency organization

2. **Testing Approach**
   - Testing frameworks in use
   - Test coverage and organization
   - Types of tests (unit, integration, e2e)

3. **Security Implementation**
   - Authentication mechanisms
   - Authorization patterns
   - Security configuration

4. **Performance & Monitoring**
   - Caching strategies
   - Logging framework and patterns
   - Monitoring or metrics collection

---

## Expected Deliverable

Create a single markdown file: **`PROJECT_SUMMARY.md`** with the following structure:

```markdown
# Project Analysis Summary

## Project Overview
- **Project Name**: [Detected or inferred project name]
- **Project Type**: [Web app, API service, mobile app, etc.]
- **Primary Language**: [Main programming language]
- **Analysis Date**: [Current date]

## Technology Stack
### Core Technologies
- **Language**: [Language and version]
- **Framework**: [Primary framework and version]
- **Runtime**: [Runtime environment and version]

### Database & Data
- **Database**: [Database type and version if detectable]
- **ORM/ODM**: [Data access library]
- **Migration Tool**: [If present]

### Build & Dependencies
- **Build Tool**: [Build system used]
- **Package Manager**: [Dependency management]
- **Key Dependencies**: [List 5-10 most important dependencies]

## Architecture Overview
### Structure Type
[Monolith/Microservices/Serverless/etc.]

### Module Organization
[How the code is organized - by feature, by layer, etc.]

### Key Components
- **Entry Point**: [Main application file]
- **Controllers/Routes**: [API endpoints or route handlers]
- **Services**: [Business logic layer]
- **Data Layer**: [Database interaction layer]
- **Configuration**: [Config management approach]

## Current Features
### Core Functionality
[List main features currently implemented]

### External Integrations
[Third-party services, APIs, or systems integrated]

## Development Standards
### Code Organization
[Naming conventions, structure patterns observed]

### Testing Strategy
[Testing approach and frameworks used]

### Security Approach
[Authentication, authorization, security measures]

## Build & Deployment
### Build Process
[How to build the application]

### Environment Configuration
[Environment variables, config files, deployment setup]

### Common Commands
```bash
# Build commands
[Detected build commands]

# Test commands  
[Detected test commands]

# Development commands
[Detected dev server or local run commands]
```

## Recommendations for Claude Code Integration
### Missing Documentation
[Areas that need documentation]

### Potential Improvements
[Technical debt or enhancement opportunities identified]

### Claude Code Setup Suggestions
[Recommendations for optimal Claude Code assistance]
```

---

## Analysis Guidelines

1. **Be Thorough but Concise**: Cover all major aspects but keep descriptions brief and actionable
2. **Focus on Facts**: Document what exists, not what should exist
3. **Include Versions**: Where possible, identify specific versions of technologies
4. **Identify Patterns**: Look for consistent patterns in code organization and naming
5. **Note Gaps**: Identify missing documentation or unclear areas
6. **Practical Commands**: Include actual commands that work with this project

## Success Criteria

✅ **Technology stack completely identified with versions**  
✅ **Architecture pattern clearly documented**  
✅ **Current features and functionality mapped**  
✅ **Development workflow and build process documented**  
✅ **External dependencies and integrations catalogued**  
✅ **Single comprehensive markdown file created**  
✅ **No new code written or existing code modified**