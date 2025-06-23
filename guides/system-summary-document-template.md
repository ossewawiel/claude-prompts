# System Summary Document Template - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: advanced
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Purpose
This template provides the structure for creating comprehensive system summary documents that give Claude Code complete project context for optimal development assistance.

### Document Location
Create system summary documents at: `docs/system-summary.md` or `documentation/system-summary.md`

## IMPLEMENTATION STRATEGY

### SYSTEM SUMMARY DOCUMENT STRUCTURE

```markdown
# [Project Name] - System Summary

## Document Information
- **Last Updated**: [Date]
- **Document Version**: [Version]
- **Project Version**: [Current project version]
- **Maintained By**: [Team/Person responsible]
- **Review Schedule**: [How often this should be updated]

## Project Overview

### Business Context
- **Purpose**: [What problem this system solves]
- **Target Users**: [Who uses this system]
- **Business Value**: [Why this system exists]
- **Project Status**: [Development phase, production status]
- **Team Information**: [Team size, key contacts, stakeholders]

### System Classification
- **System Type**: [Web application, mobile app, desktop app, web service, etc.]
- **Deployment Model**: [On-premise, cloud, hybrid]
- **User Base**: [Internal users, external customers, B2B, B2C]
- **Criticality Level**: [Mission critical, business critical, supporting]
- **Compliance Requirements**: [GDPR, HIPAA, SOX, industry standards]

## Technical Architecture

### Technology Stack
#### Backend Technologies
- **Primary Language**: [Java, Kotlin, C++, etc.]
- **Framework**: [Spring Boot, etc.]
- **Runtime Version**: [JVM version, Node version, etc.]
- **Build System**: [Maven, Gradle, CMake, etc.]
- **Dependencies**: [Key libraries and versions]

#### Frontend Technologies
- **Primary Language**: [JavaScript, TypeScript, etc.]
- **Framework**: [React, Vaadin, etc.]
- **UI Library**: [MUI, Bootstrap, etc.]
- **Build Tools**: [Next.js, Vite, Webpack, etc.]
- **Package Manager**: [npm, yarn, etc.]

#### Database & Storage
- **Primary Database**: [PostgreSQL, MariaDB, etc.]
- **Database Version**: [Specific version]
- **ORM/Data Access**: [JPA/Hibernate, Spring Data, etc.]
- **Caching**: [Redis, in-memory, etc.]
- **File Storage**: [Local, S3, etc.]

#### Infrastructure & DevOps
- **Deployment Platform**: [Docker, Kubernetes, VM, bare metal]
- **CI/CD Pipeline**: [GitHub Actions, GitLab CI, Jenkins]
- **Monitoring**: [Application monitoring tools]
- **Logging**: [Logging framework and aggregation]
- **Security**: [Authentication, authorization, encryption]

### System Architecture
#### High-Level Architecture
```
[Provide text-based architecture diagram]
Example:
┌─────────────┐    HTTP/REST    ┌─────────────┐    JDBC    ┌─────────────┐
│   Web UI    │ ←──────────────→ │   Backend   │ ←─────────→ │  Database   │
│ (React/MUI) │                 │ (Spring Boot)│            │(PostgreSQL) │
└─────────────┘                 └─────────────┘            └─────────────┘
```

#### Component Architecture
- **Presentation Layer**: [UI components, controllers]
- **Business Logic Layer**: [Services, domain models]
- **Data Access Layer**: [Repositories, DAOs]
- **Integration Layer**: [External API clients, message queues]
- **Cross-Cutting Concerns**: [Security, logging, monitoring]

### Data Architecture
#### Database Schema Overview
- **Core Entities**: [List main database tables/entities]
- **Relationships**: [Key foreign key relationships]
- **Indexing Strategy**: [Important indexes for performance]
- **Data Volume**: [Approximate record counts, growth rate]

#### Data Flow
```
[Describe how data flows through the system]
Example:
User Input → Validation → Business Logic → Database → Response
     ↓
External APIs ← Integration Layer ← Background Jobs
```

### Integration Points
#### External Systems
- **[System Name]**: [Purpose, protocol, authentication]
- **[API Name]**: [Purpose, rate limits, dependencies]
- **[Service Name]**: [Purpose, SLA, failure handling]

#### Internal Services
- **[Service Name]**: [Purpose, communication method]
- **[Component Name]**: [Purpose, interface definition]

## Development Information

### Project Structure
```
[Provide key directory/package structure]
Example:
src/
├── main/
│   ├── java/com/company/project/
│   │   ├── controller/     # REST controllers
│   │   ├── service/        # Business logic
│   │   ├── repository/     # Data access
│   │   ├── model/          # Entity classes
│   │   └── config/         # Configuration
│   └── resources/
│       ├── application.yml # Configuration
│       └── db/migration/   # Database migrations
└── test/                   # Test classes
```

### Key Components
#### Core Services
- **[Service Name]**: [Purpose, key methods, dependencies]
- **[Service Name]**: [Purpose, key methods, dependencies]

#### Important Classes/Components
- **[Class Name]** (`path/to/Class.java:123`): [Purpose and responsibility]
- **[Component Name]** (`path/to/Component.js:45`): [Purpose and responsibility]

#### Configuration Management
- **Environment Variables**: [List key environment variables]
- **Configuration Files**: [Location and purpose of config files]
- **Feature Flags**: [Any feature toggle implementations]

### API Documentation
#### REST Endpoints
- **GET /api/[resource]**: [Purpose, parameters, response format]
- **POST /api/[resource]**: [Purpose, request body, response]
- **PUT /api/[resource]/{id}**: [Purpose, parameters, request body]
- **DELETE /api/[resource]/{id}**: [Purpose, parameters, response]

#### Authentication & Authorization
- **Authentication Method**: [JWT, OAuth2, session-based]
- **Authorization Model**: [Role-based, permission-based]
- **Security Headers**: [CORS, CSP, etc.]

### Database Information
#### Connection Configuration
- **Connection Pool**: [HikariCP, etc.]
- **Connection Limits**: [Max connections, timeout settings]
- **Transaction Management**: [Isolation levels, timeout settings]

#### Migration Strategy
- **Migration Tool**: [Flyway, Liquibase, etc.]
- **Migration Location**: [Path to migration files]
- **Migration Naming**: [Convention used for migration files]

## Development Workflow

### Local Development Setup
```bash
# Prerequisites
[List required software, versions]

# Setup Commands
[Step-by-step setup instructions]

# Start Development Environment
[Commands to start local development]
```

### Build & Test Commands
```bash
# Build Commands
[Gradle, Maven, npm commands]

# Test Commands
[Unit tests, integration tests, e2e tests]

# Code Quality Commands
[Linting, static analysis, formatting]
```

### Common Development Tasks
- **Add New Feature**: [Typical workflow and files to modify]
- **Database Changes**: [How to create and apply migrations]
- **API Changes**: [Process for adding/modifying endpoints]
- **UI Changes**: [Component development workflow]

## Operational Information

### Deployment Process
- **Environment Promotion**: [Dev → Test → Prod workflow]
- **Deployment Method**: [Manual, automated, CI/CD]
- **Rollback Procedure**: [How to rollback deployments]
- **Environment Differences**: [Key differences between environments]

### Monitoring & Observability
#### Application Monitoring
- **Health Checks**: [Endpoint URLs, expected responses]
- **Performance Metrics**: [Key metrics to monitor]
- **Error Tracking**: [Error logging and alerting]

#### Logging
- **Log Levels**: [INFO, DEBUG, ERROR usage]
- **Log Locations**: [Where logs are stored/aggregated]
- **Log Format**: [Structured logging format used]

### Security Considerations
#### Security Controls
- **Input Validation**: [Validation strategies used]
- **Output Encoding**: [XSS prevention measures]
- **Authentication**: [Implementation details]
- **Authorization**: [Permission model]
- **Data Protection**: [Encryption, sensitive data handling]

#### Security Testing
- **Vulnerability Scanning**: [Tools and frequency]
- **Penetration Testing**: [Schedule and scope]
- **Code Security Review**: [Process and tools]

## Testing Strategy

### Test Coverage
- **Unit Tests**: [Coverage percentage, key areas tested]
- **Integration Tests**: [Test scenarios, external dependencies]
- **End-to-End Tests**: [User journeys covered]
- **Performance Tests**: [Load testing approach]

### Test Data Management
- **Test Data Strategy**: [How test data is created/managed]
- **Database Testing**: [TestContainers, H2, etc.]
- **Mock Services**: [External service mocking approach]

## Known Issues & Technical Debt

### Current Limitations
- **Performance Issues**: [Known bottlenecks]
- **Technical Debt**: [Areas needing refactoring]
- **Missing Features**: [Planned but not implemented]
- **Known Bugs**: [Issues being tracked]

### Future Improvements
- **Planned Upgrades**: [Technology upgrades planned]
- **Architecture Changes**: [Planned architectural improvements]
- **Feature Roadmap**: [Major features in development]

## Reference Information

### Global Template References
Reference relevant templates from `/mnt/d/sourcecode/claude-prompts/`:
- **Coding Standards**: [Link to applicable coding standards]
- **Testing Strategy**: [Link to testing strategy guides]
- **Database Integration**: [Link to database guides]
- **Architecture Patterns**: [Link to pattern implementations]

### Documentation Links
- **API Documentation**: [Link to full API docs]
- **User Documentation**: [Link to user guides]
- **Deployment Guide**: [Link to deployment documentation]
- **Architecture Decision Records**: [Link to ADR documentation]

### Emergency Contacts
- **Primary Developer**: [Contact information]
- **DevOps Contact**: [Contact information]
- **Business Owner**: [Contact information]
- **On-Call Information**: [Emergency procedures]

## Troubleshooting Guide

### Common Issues
#### Build Issues
- **Problem**: [Common build failure]
- **Solution**: [Step-by-step resolution]

#### Runtime Issues  
- **Problem**: [Common runtime error]
- **Solution**: [Diagnostic steps and resolution]

#### Database Issues
- **Problem**: [Common database problem]
- **Solution**: [Resolution steps]

### Diagnostic Commands
```bash
# Application Health
[Commands to check application status]

# Database Connectivity
[Commands to verify database connection]

# Performance Diagnostics
[Commands to check performance]
```

### Log Analysis
- **Error Patterns**: [Common error patterns to look for]
- **Performance Issues**: [Log indicators of performance problems]
- **Security Events**: [Security-related log entries]

## Appendices

### Glossary
- **[Term]**: [Definition specific to this project]
- **[Acronym]**: [What it stands for and meaning]

### Configuration Reference
- **Environment Variables**: [Complete list with descriptions]
- **Configuration Properties**: [Key configuration options]
- **Feature Flags**: [Available feature toggles]

### Database Schema
[Include current database schema diagram or description]

### API Schema
[Include key API request/response schemas]
```

## CLAUDE_CODE_COMMANDS

### Document Creation
```bash
# Create docs directory structure
mkdir -p docs
touch docs/system-summary.md

# Or alternative location
mkdir -p documentation  
touch documentation/system-summary.md
```

### Information Gathering
```bash
# Gather system information
java -version                    # Java version
node --version                   # Node version
cat build.gradle | grep version  # Project version
git log --oneline -10            # Recent changes
```

### Documentation Validation
```bash
# Verify document completeness
grep -c "TODO\|FIXME\|XXX" docs/system-summary.md  # Find incomplete sections
wc -l docs/system-summary.md                       # Document length check
```

## VALIDATION_CHECKLIST
- [ ] All major system components documented
- [ ] Technology stack completely identified
- [ ] Architecture diagrams provided (text-based)
- [ ] API endpoints documented with examples
- [ ] Database schema and relationships explained
- [ ] Security model clearly described
- [ ] Development workflow step-by-step instructions
- [ ] Troubleshooting guide covers common issues
- [ ] Global template references integrated
- [ ] Contact information and emergency procedures included
- [ ] Document structure follows template consistently
- [ ] All code references include file paths and line numbers where applicable