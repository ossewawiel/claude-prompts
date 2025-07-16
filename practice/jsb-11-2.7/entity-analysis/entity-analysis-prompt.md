# Entity Analysis Prompt

name: "analyze-entity"
description: "Comprehensive JPA entity analysis with TODO comments for Spring Boot 2.7 Java 11"
parameters:
  - name: "entity_path"
    description: "Path to the JPA entity class file (e.g., src/main/java/com/example/User.java)"
    required: true
  - name: "database_type"
    description: "Database type: postgresql, mariadb, h2, or generic"
    required: false
    default: "generic"

---

You are an expert Java developer performing comprehensive JPA entity analysis for Spring Boot 2.7 projects using Java 11.

## Task Overview
Analyze the JPA entity class at `{{entity_path}}` for database type `{{database_type}}` and add `// TODO:` comments directly in the code where issues are found.

## Analysis Process
Present each analysis category below and ask the developer to confirm (y/n) before proceeding. Only read the specified documentation files for confirmed categories.

### 1. JPA Annotations & Configuration
**Confirm analysis:** Should I check JPA annotations and configuration? (y/n)
**Documentation:** Read `entity-analysis/entity-jpa-annotations-checklist.md`

### 2. Lombok Integration
**Confirm analysis:** Should I check Lombok integration patterns? (y/n)
**Documentation:** Read `entity-analysis/entity-lombok-integration.md`

### 3. Java 11 Modernization
**Confirm analysis:** Should I check Java 11 feature usage? (y/n)
**Documentation:** Read `entity-analysis/entity-java11-modernization.md`

### 4. Entity Relationships
**Confirm analysis:** Should I check entity relationships and associations? (y/n)
**Documentation:** Read `entity-analysis/entity-relationships-analysis.md`

### 5. Performance Optimization
**Confirm analysis:** Should I check performance optimizations? (y/n)
**Documentation:** Read `entity-analysis/entity-performance-optimization.md`

### 6. Validation & Security
**Confirm analysis:** Should I check validation and security patterns? (y/n)
**Documentation:** Read `entity-analysis/entity-validation-security.md`

### 7. Lifecycle Management
**Confirm analysis:** Should I check entity lifecycle management? (y/n)
**Documentation:** Read `entity-analysis/entity-lifecycle-management.md`

### 8. Testing Compatibility
**Confirm analysis:** Should I check testing compatibility? (y/n)
**Documentation:** Read `entity-analysis/entity-testing-compatibility.md`

### 9. Documentation Standards
**Confirm analysis:** Should I check documentation standards? (y/n)
**Documentation:** Read `entity-analysis/entity-documentation-standards.md`

### 10. Equals/HashCode Analysis
**Confirm analysis:** Should I check equals/hashCode implementation? (y/n)
**Documentation:** Read `entity-analysis/entity-equals-hashcode-analysis.md`

### 11. Database-Specific Optimization
**Confirm analysis:** Should I check database-specific optimizations for {{database_type}}? (y/n)
**Documentation:** 
- If database_type = "postgresql": Read `entity-analysis/entity-postgresql-optimizations.md`
- If database_type = "mariadb": Read `entity-analysis/entity-mariadb-optimizations.md`
- If database_type = "generic": Skip this analysis

## Analysis Execution
For each confirmed analysis category:

1. **Read the entity file** at `{{entity_path}}`
2. **Read the specified documentation** for that category
3. **Analyze the entity** against the criteria in the documentation
4. **Collect all issues** found with their severity levels
5. **Present findings** in this format:

```
Analysis: [Category Name]
Issues Found:
CRITICAL (C): [count] issues
HIGH (H): [count] issues  
MEDIUM (M): [count] issues
LOW (L): [count] issues

Issue Summary:
- [CRITICAL] Missing @Entity annotation
- [HIGH] No @Index on frequently queried fields
- [MEDIUM] Missing @PrePersist callbacks
- [LOW] Missing JavaDoc comments
```

6. **Ask for severity inclusion:** "Include which severity levels? (c)ritical, (h)igh, (m)edium, (l)ow (e.g., 'ch' for critical and high)"

7. **Add TODO comments** only for selected severity levels using this format:
```java
// TODO: [SEVERITY] Issue description - Fix: specific solution
```

## TODO Comment Format
- **CRITICAL**: `// TODO: [CRITICAL] Issue description - Fix: specific solution`
- **HIGH**: `// TODO: [HIGH] Issue description - Fix: specific solution`
- **MEDIUM**: `// TODO: [MEDIUM] Issue description - Fix: specific solution`
- **LOW**: `// TODO: [LOW] Issue description - Fix: specific solution`

## Example TODO Comments
```java
@Entity
public class User {
    // TODO: [CRITICAL] Add @Table annotation - Fix: @Table(name = "users")
    
    @Id
    // TODO: [HIGH] Add database indexes - Fix: @Table(indexes = @Index(name = "idx_user_email", columnList = "email"))
    private Long id;
    
    // TODO: [MEDIUM] Add @Column length specification - Fix: @Column(length = 255)
    private String email;
    
    // TODO: [LOW] Add field documentation - Fix: Add JavaDoc comment explaining field purpose
    private String firstName;
}
```

## Output Requirements
1. **Preserve all existing code** and formatting
2. **Add TODO comments** only for selected severity levels
3. **Place TODOs** immediately before the relevant code line
4. **Use exact TODO format** specified above
5. **Return complete modified file** content
6. **Group related TODOs** when multiple issues affect the same code element

## Final Instructions
- Only analyze confirmed categories
- Only read documentation files for confirmed categories
- Present findings summary before adding TODOs
- Allow developer to select severity levels to include
- Add TODOs directly in the code at appropriate locations
- Return the complete enhanced entity file

Begin by asking: "Which analysis categories should I perform? I'll present each one for your confirmation."