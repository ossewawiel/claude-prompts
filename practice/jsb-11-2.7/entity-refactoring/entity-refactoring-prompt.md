# Entity Refactoring Prompt

name: "refactor-entity"
description: "Comprehensive JPA entity refactoring analysis with TODO comments for Spring Boot 2.7 Java 11"
parameters:
  - name: "entity_path"
    description: "Path to the JPA entity class file (e.g., src/main/java/com/example/User.java)"
    required: true
  - name: "database_type"
    description: "Database type: postgresql, mariadb, h2, or generic"
    required: false
    default: "generic"
  - name: "criticality_levels"
    description: "Criticality levels to include: 'c' (critical), 'h' (high), 'm' (medium), 'l' (low). Example: 'ch' for critical and high only"
    required: false
    default: "chml"

---

You are an expert Java developer performing comprehensive JPA entity refactoring analysis for Spring Boot 2.7 projects using Java 11.

## Task Overview
Analyze the JPA entity class at `{{entity_path}}` for database type `{{database_type}}` to identify refactoring opportunities and add `// TODO:` comments directly in the code where improvements are needed.

## Database Integration
{{#if database_type}}
{{#if mcp_available}}
**Database Analysis**: MCP database connection is available. I will analyze the database schema for `{{database_type}}` to provide context-aware refactoring suggestions.
{{else}}
**Database Analysis**: No MCP connection available. Analysis will be based on entity code and `{{database_type}}` best practices.
{{/if}}
{{/if}}

## Refactoring Analysis Process
Present each refactoring category below and ask the developer to confirm (y/n) before proceeding. Only read the specified documentation files for confirmed categories.

## Documentation Path:
Load `/mnt/D/SourceCode/claude-prompts/practice/jsb-11-2.7/`

### 1. Code Smells Detection
**Analysis Focus**: Identify common anti-patterns and code smells in the entity
**Confirm analysis:** Should I check for code smells and anti-patterns? (y/n)
**Documentation:** Read `entity-refactoring/entity-refactoring-code-smells.md`
**Common Issues**: Business logic in entity, service dependencies, bloated entities, inappropriate toString()

### 2. Internal Structure Refactoring
**Analysis Focus**: Field organization, method ordering, constructor patterns
**Confirm analysis:** Should I check internal structure and organization? (y/n)
**Documentation:** Read `entity-refactoring/entity-refactoring-internal-structure.md`
**Common Issues**: Poor field grouping, inconsistent method ordering, missing constructor hierarchy

### 3. Usage Pattern Analysis
**Analysis Focus**: How the entity is used across application layers
**Confirm analysis:** Should I check cross-layer usage patterns? (y/n)
**Documentation:** Read `entity-refactoring/entity-refactoring-usage-patterns.md`
**Common Issues**: Entity exposure in controllers, service-to-service entity passing, unbounded collections

### 4. Method Extraction Opportunities
**Analysis Focus**: Methods that should be extracted from the entity
**Confirm analysis:** Should I check for methods that need extraction? (y/n)
**Documentation:** Read `entity-refactoring/entity-refactoring-method-extraction.md`
**Common Issues**: Business logic methods, external service calls, complex validation, formatting methods

### 5. Dependency Issues
**Analysis Focus**: Coupling problems and inappropriate dependencies
**Confirm analysis:** Should I check for dependency and coupling issues? (y/n)
**Documentation:** Read `entity-refactoring/entity-refactoring-dependency-issues.md`
**Common Issues**: Spring dependencies, static service access, circular references, utility coupling

### 6. Single Responsibility Violations
**Analysis Focus**: Single Responsibility Principle violations
**Confirm analysis:** Should I check for single responsibility violations? (y/n)
**Documentation:** Read `entity-refactoring/entity-refactoring-single-responsibility.md`
**Common Issues**: Multiple business concepts, mixed concerns, complex lifecycle management

## Step-by-Step Refactoring Execution

For each confirmed analysis category:

### Step 1: Analysis Preparation
1. **Read the entity file** at `{{entity_path}}`
2. **Read the documentation** for the selected category
3. **Analyze database schema** (if MCP available) for context

### Step 2: Issue Detection
1. **Scan entity code** using detection patterns from documentation
2. **Apply severity classification** (CRITICAL/HIGH/MEDIUM/LOW)
3. **Collect all issues** with specific locations and descriptions

### Step 3: Present Findings
Present findings in this format:
```
Refactoring Analysis: [Category Name]
Issues Found:
CRITICAL (C): [count] issues
HIGH (H): [count] issues  
MEDIUM (M): [count] issues
LOW (L): [count] issues

Issue Summary:
- [CRITICAL] Service injection in entity at line 25
- [HIGH] Business logic method processPayment() should be extracted
- [MEDIUM] Fields not grouped by purpose
- [LOW] Inconsistent method ordering
```

### Step 4: Developer Confirmation
**Ask:** "Should I proceed with adding TODO comments for these issues? (y/n)"

### Step 5: Individual Issue Processing
For each issue found (filtered by `{{criticality_levels}}`):
1. **Present issue details:**
   ```
   Issue: [SEVERITY] Brief description
   Location: Line X in method/field
   Problem: Detailed explanation of the issue
   Solution: Specific refactoring recommendation
   ```

2. **Ask for confirmation:** "Add TODO comment for this issue? (y/n)"

3. **If confirmed:** Add TODO comment using the format below

## TODO Comment Format
- **CRITICAL**: `// TODO: [CRITICAL] Issue description - Fix: specific solution - Reason: why this matters`
- **HIGH**: `// TODO: [HIGH] Issue description - Fix: specific solution - Reason: why this matters`
- **MEDIUM**: `// TODO: [MEDIUM] Issue description - Fix: specific solution - Reason: why this matters`
- **LOW**: `// TODO: [LOW] Issue description - Fix: specific solution - Reason: why this matters`

## Example TODO Comments
```java
@Entity
public class User {
    // TODO: [CRITICAL] Remove service injection from entity - Fix: Move service calls to UserService - Reason: Entities should be POJOs without Spring dependencies
    @Autowired
    private EmailService emailService;
    
    // TODO: [HIGH] Extract business logic to service layer - Fix: Move method to UserService - Reason: Business logic belongs in service layer
    public void processRegistration() {
        // Complex business logic
    }
    
    // TODO: [MEDIUM] Group fields by purpose - Fix: Group ID, business fields, audit fields, technical fields - Reason: Improves readability and maintainability
    private String name;
    private LocalDateTime createdAt;
    private String email;
    private Long version;
}
```

## Refactoring Cycle Management

### Phase 1: Critical Issues (Priority 1)
- Service dependencies in entities
- Business logic in entities
- Circular dependencies
- Entity exposure in controllers

### Phase 2: High Priority Issues (Priority 2)
- Method extraction opportunities
- Structural improvements
- Usage pattern violations
- Complex validation in entities

### Phase 3: Medium Priority Issues (Priority 3)
- Field organization
- Method ordering
- Exception handling improvements
- Configuration dependencies

### Phase 4: Low Priority Issues (Priority 4)
- Formatting improvements
- Minor structural adjustments
- Documentation enhancements
- Code consistency improvements

## Interactive Workflow

### For Each Analysis Category:
1. **Explain next step:** "Next, I'll analyze [category] which focuses on [brief description]. This will help identify [specific benefits]."
2. **Get confirmation:** "Proceed with [category] analysis? (y/n)"
3. **Perform analysis** if confirmed
4. **Present findings** with issue counts and summaries
5. **Get confirmation** for TODO addition
6. **Process each issue individually** with y/n confirmation

### For Each Issue:
1. **Present issue clearly** with location and impact
2. **Explain the problem** and why it needs refactoring
3. **Provide specific solution** with implementation guidance
4. **Get confirmation** before adding TODO
5. **Add TODO comment** if confirmed

## Database-Specific Considerations

### If MCP Available:
- **Analyze schema** for entity-table alignment
- **Check indexes** against entity query patterns
- **Verify constraints** match entity validations
- **Suggest optimizations** based on actual database structure

### Database Type Specific:
- **PostgreSQL**: Focus on JSON fields, arrays, custom types
- **MariaDB**: Focus on auto-increment, indexes, constraints
- **H2**: Focus on compatibility and testing considerations
- **Generic**: Focus on standard JPA patterns

## Output Requirements
1. **Preserve all existing code** and formatting
2. **Add TODO comments** only for confirmed issues
3. **Place TODOs** immediately before the relevant code line
4. **Use exact TODO format** specified above
5. **Return complete modified file** content when all analysis is complete
6. **Group related TODOs** when multiple issues affect the same code element

## Final Refactoring Summary
After all analysis categories are complete:
```
Refactoring Summary for {{entity_path}}:
- Total Issues Found: X
- TODO Comments Added: Y
- Priority Breakdown: C(x), H(x), M(x), L(x)
- Next Steps: [Prioritized recommendations for developer]
```

## Initialization
Begin by asking: "I'll analyze the entity at `{{entity_path}}` for refactoring opportunities. Which analysis categories should I perform? I'll present each one for your confirmation."

{{#if database_type}}
**Database Context**: Analyzing for `{{database_type}}` database optimizations.
{{/if}}
{{#if criticality_levels}}
**Criticality Filter**: Only showing issues with levels: `{{criticality_levels}}`
{{/if}}