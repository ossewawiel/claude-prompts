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
Go through each analysis category individually. For each category:

1. **Present the category** and ask for confirmation
2. **If confirmed (y)**: Read documentation, analyze entity, if database_type is specified and mcp server is available check the db entity for extra info, present findings, ask for severity levels, add TODOs
3. **If declined (n)**: Skip to next category
4. **Move to next category** only after completing current one

## Documentation Path:
Load `/mnt/D/SourceCode/claude-prompts/practice/jsb-11-2.7/`

### Available Analysis Categories:

1. **JPA Annotations & Configuration**
   - Documentation: `entity-analysis/entity-jpa-annotations-checklist.md`
   
2. **Lombok Integration**  
   - Documentation: `entity-analysis/entity-lombok-integration.md`
   
3. **Java 11 Modernization**
   - Documentation: `entity-analysis/entity-java11-modernization.md`
   
4. **Entity Relationships**
   - Documentation: `entity-analysis/entity-relationships-analysis.md`
   
5. **Performance Optimization**
   - Documentation: `entity-analysis/entity-performance-optimization.md`
   
6. **Validation & Security**
   - Documentation: `entity-analysis/entity-validation-security.md`
   
7. **Lifecycle Management**
   - Documentation: `entity-analysis/entity-lifecycle-management.md`
   
8. **Testing Compatibility**
   - Documentation: `entity-analysis/entity-testing-compatibility.md`
   
9. **Documentation Standards**
   - Documentation: `entity-analysis/entity-documentation-standards.md`
   
10. **Equals/HashCode Analysis**
    - Documentation: `entity-analysis/entity-equals-hashcode-analysis.md`
    
11. **Database-Specific Optimization**
    - Documentation: 
      - If database_type = "postgresql": `entity-analysis/entity-postgresql-optimizations.md`
      - If database_type = "mariadb": `entity-analysis/entity-mariadb-optimizations.md`
      - If database_type = "generic": Skip this analysis

## Per-Category Analysis Flow

For each confirmed category, follow this exact sequence:

### Step 1: Present Category
```
=== ANALYZING: [Category Name] ===
Should I analyze [Category Name]? (y/n):
```

### Step 2: If Yes - Perform Analysis
1. **Read the entity file** at `{{entity_path}}`
2. **Read the specified documentation** for that category
3. **Analyze the entity** against the criteria in the documentation
4. **Present findings** in this format:

```
📊 ANALYSIS RESULTS: [Category Name]
=====================================
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

### Step 3: Severity Selection and Fix Mode
```
Which severity levels should I process? 
Enter letters: (c)ritical, (h)igh, (m)edium, (l)ow 
Add 'f' after a space to enable fix mode: 'ch f' 

Examples:
- 'ch' = Add TODOs for critical and high issues
- 'ch f' = Auto-fix critical and high issues (with confirmation)
- 'chml f' = Auto-fix all issues (with confirmation)

Your selection:
```

### Step 4: Process Issues (TODOs or Fixes)

#### If NO 'f' specified: Add TODOs
Add TODO comments only for selected severity levels and show the updated code sections.

#### If 'f' specified: Interactive Fix Mode
For each issue in the selected severity levels:

1. **Present the issue and proposed fix:**
```
🔧 PROPOSED FIX [SEVERITY]
Issue: [Description of the problem]
Current Code:
[Show current problematic code]

Suggested Fix:
[Show the corrected code with explanation]

Apply this fix? (y/n):
```

2. **If 'y' selected**: Apply the fix directly to the code
3. **If 'n' selected**: Add TODO comment instead
4. **Continue with next issue** until all selected severity issues are processed

**Fix Mode Guidelines:**
- Show before/after code comparison for each fix
- Only apply fixes after developer confirmation
- If fix is declined, fall back to TODO comment
- Group related fixes when they affect the same code section
- Maintain all existing code formatting and structure

### Step 5: Move to Next Category
```
✅ [Category Name] analysis complete. Moving to next category...
```

## TODO Comment Format
- **CRITICAL**: `// TODO: [CRITICAL] Issue description - Fix: specific solution`
- **HIGH**: `// TODO: [HIGH] Issue description - Fix: specific solution`
- **MEDIUM**: `// TODO: [MEDIUM] Issue description - Fix: specific solution`
- **LOW**: `// TODO: [LOW] Issue description - Fix: specific solution`

## Example TODO Comments (when 'f' not specified)
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

## Example Interactive Fix Mode (when 'f' specified)
```
🔧 PROPOSED FIX [CRITICAL]
Issue: Missing @Table annotation
Current Code:
@Entity
public class User {

Suggested Fix:
@Entity
@Table(name = "users")
public class User {

Apply this fix? (y/n): y

✅ Fix applied!

🔧 PROPOSED FIX [HIGH]  
Issue: Missing database indexes for email field
Current Code:
@Entity
@Table(name = "users")
public class User {

Suggested Fix:
@Entity
@Table(name = "users", indexes = @Index(name = "idx_user_email", columnList = "email"))
public class User {

Apply this fix? (y/n): n

❌ Fix declined - Adding TODO comment instead
```

## Output Requirements

### For TODO Mode (no 'f' specified):
1. **Preserve all existing code** and formatting
2. **Add TODO comments** only for selected severity levels
3. **Place TODOs** immediately before the relevant code line
4. **Use exact TODO format** specified above
5. **Return complete modified file** content
6. **Group related TODOs** when multiple issues affect the same code element

### For Fix Mode ('f' specified):
1. **Apply fixes** only after developer confirmation (y/n)
2. **Preserve all existing code** and formatting for unchanged sections
3. **Show before/after comparison** for each proposed fix
4. **Fall back to TODO comments** if fix is declined
5. **Return complete modified file** content with all applied fixes
6. **Group related fixes** when they affect the same code section
7. **Maintain cumulative changes** across all confirmed fixes

## Final Instructions
- Go through categories **one by one** in sequential order
- Only analyze confirmed categories
- Only read documentation files for confirmed categories
- Complete each category fully before moving to next
- Present findings summary before processing issues for each category
- Allow developer to select severity levels and fix mode for each category
- **If 'f' specified**: Use interactive fix mode with y/n confirmation for each issue
- **If 'f' not specified**: Add TODO comments directly in the code
- Show updated code sections after each category
- Maintain cumulative changes across all categories and all applied fixes

## Starting Instructions
Begin by asking: "I'll analyze the entity categories one by one. Ready to start with the first category?"

Then proceed with:
```
=== ANALYZING: JPA Annotations & Configuration ===
Should I analyze JPA Annotations & Configuration? (y/n):
```