# Entity Refactoring Documentation

## Purpose
Comprehensive documentation for identifying and refactoring Java 11 Spring Boot 2.7 JPA entities to improve code quality, maintainability, and adherence to clean code principles.

## Overview
This documentation provides Claude Code with specific patterns to identify code smells and refactoring opportunities in JPA entities. Each document focuses on a specific aspect of entity refactoring with actionable TODO templates and prioritized recommendations.

## Documentation Structure

### 1. **Code Smells Detection**
- **File**: `entity-refactoring-code-smells.md`
- **Focus**: Common anti-patterns and code smells in entities
- **Output**: Prioritized TODO comments with specific fixes
- **Key Areas**: Business logic in entities, inappropriate dependencies, bloated entities

### 2. **Internal Structure Refactoring**
- **File**: `entity-refactoring-internal-structure.md`
- **Focus**: Field organization, method ordering, constructor patterns
- **Output**: Structural improvement recommendations
- **Key Areas**: Field grouping, method organization, access modifiers

### 3. **Usage Pattern Analysis**
- **File**: `entity-refactoring-usage-patterns.md`
- **Focus**: How entities are used across application layers
- **Output**: Separation of concerns improvements
- **Key Areas**: Controller exposure, service integration, repository patterns

### 4. **Method Extraction**
- **File**: `entity-refactoring-method-extraction.md`
- **Focus**: Methods that should be extracted from entities
- **Output**: Service layer and utility class extraction recommendations
- **Key Areas**: Business logic, validation, formatting, calculations

### 5. **Dependency Issues**
- **File**: `entity-refactoring-dependency-issues.md`
- **Focus**: Coupling and dependency problems
- **Output**: Decoupling strategies and dependency removal
- **Key Areas**: Spring dependencies, circular references, utility coupling

### 6. **Single Responsibility**
- **File**: `entity-refactoring-single-responsibility.md`
- **Focus**: Single Responsibility Principle violations
- **Output**: Entity splitting and responsibility separation
- **Key Areas**: Multiple business concepts, mixed concerns, lifecycle management

## Usage Instructions for Claude Code

### Analysis Process
1. **Load Relevant Documentation**: Based on developer selection or detected issues
2. **Scan Entity Code**: Apply detection patterns from each document
3. **Generate TODO Comments**: Use templates with specific fixes
4. **Prioritize Issues**: CRITICAL → HIGH → MEDIUM → LOW
5. **Provide Refactoring Roadmap**: Structured improvement plan

### TODO Comment Format
```java
// TODO: [PRIORITY] Brief description of issue
// Fix: Specific solution with implementation guidance
// Reason: Why this refactoring improves the code
```

### Priority Levels
- **CRITICAL**: Must fix immediately (compilation/runtime errors, security issues)
- **HIGH**: Important for functionality and maintainability
- **MEDIUM**: Best practices and code quality improvements
- **LOW**: Minor optimizations and refinements

## Integration with Entity Analysis

### Complementary Relationship
- **entity-analysis/**: Focuses on correct implementation and initial setup
- **entity-refactoring/**: Focuses on improving existing code and identifying smells

### Avoid Duplication
- JPA annotations → Covered in entity-analysis
- Lombok integration → Covered in entity-analysis
- Java 11 features → Covered in entity-analysis
- Performance optimization → Covered in entity-analysis

### Refactoring Focus Areas
- Code smell identification
- Structural improvements
- Responsibility separation
- Dependency management
- Usage pattern optimization

## Detection Patterns Summary

### Code Smell Indicators
- Business logic in entities
- Service/repository dependencies
- Bloated entity classes (>15 fields, >20 methods)
- Inappropriate toString() implementations
- Mutable collection exposure

### Structural Issues
- Poor field organization
- Inconsistent method ordering
- Missing constructor hierarchy
- Unclear access modifiers
- Mixed annotation styles

### Usage Problems
- Entity exposure in controllers
- Entity passed between services
- Unbounded collection queries
- Validation in multiple layers
- Conversion logic in controllers

### Extraction Candidates
- Complex business logic methods
- Database query methods
- External service integration
- Formatting and presentation logic
- Complex validation methods

### Dependency Problems
- Spring framework dependencies
- Static service access
- Circular entity references
- Utility class coupling
- Configuration dependencies

### Responsibility Violations
- Multiple business concepts in one entity
- Mixed audit and business logic
- Multiple lifecycle states
- Configuration mixed with data
- Validation mixed with business logic

## Refactoring Strategies

### Layer Separation
```
Controller (DTOs) → Service (Entities) → Repository (Entities) → Database
```

### Responsibility Allocation
- **Entities**: Data + Basic validation + Simple state
- **Services**: Business logic + Orchestration + Complex validation
- **Repositories**: Data access + Custom queries
- **Utilities**: Stateless operations + Formatting
- **DTOs**: Data transfer + API contracts

### Extraction Patterns
- **Service Extraction**: Complex business logic, state transitions
- **Utility Extraction**: Formatting, calculations, static operations
- **Validator Extraction**: Complex validation logic
- **Mapper Extraction**: Entity ↔ DTO conversions

## Best Practices Enforcement

### Entity Design Rules
1. **Single Responsibility**: One business concept per entity
2. **Minimal Dependencies**: JPA + validation annotations only
3. **Clear Structure**: Logical field/method organization
4. **Proper Encapsulation**: Private fields with controlled access
5. **Immutable Where Possible**: Final fields for unchanging data

### Anti-Patterns to Avoid
- Business logic in entities
- Service dependencies in entities
- Complex validation in entities
- Presentation logic in entities
- Multiple concerns in single entity

## Maintenance and Updates

### Version Compatibility
- Keep aligned with Spring Boot 2.7 features
- Maintain Java 11 compatibility
- Update based on JPA specification changes

### Documentation Updates
- Add new code smell patterns as discovered
- Update TODO templates based on effectiveness
- Refine priority levels based on impact analysis
- Include new refactoring strategies

### Quality Metrics
- **Detection Accuracy**: How well patterns identify real issues
- **Fix Effectiveness**: How well TODO templates resolve issues
- **Priority Accuracy**: How well priority levels guide developer effort
- **Refactoring Success**: How well strategies improve code quality

## Example Refactoring Workflow

### 1. Code Smell Detection
```java
// Original problematic entity
@Entity
public class UserAccount {
    private String name;
    private String email;
    
    @Autowired
    private EmailService emailService;
    
    public void sendWelcomeEmail() {
        emailService.sendWelcome(this.email);
    }
}
```

### 2. TODO Generation
```java
// TODO: [CRITICAL] Remove service dependency from entity
// Fix: Move sendWelcomeEmail() to UserService
// Reason: Entities should not depend on services
```

### 3. Refactored Solution
```java
// Refactored entity
@Entity
public class User {
    private String name;
    private String email;
    // Clean entity with no service dependencies
}

// Service handles business logic
@Service
public class UserService {
    private final EmailService emailService;
    
    public void sendWelcomeEmail(User user) {
        emailService.sendWelcome(user.getEmail());
    }
}
```

This documentation enables Claude Code to systematically identify and provide refactoring guidance for JPA entities, improving code quality and maintainability through structured analysis and actionable recommendations.