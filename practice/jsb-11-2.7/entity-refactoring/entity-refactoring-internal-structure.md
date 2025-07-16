# Entity Internal Structure Refactoring

## Purpose
Identify internal structure improvements for JPA entities focusing on field organization, method placement, and constructor patterns.

## Internal Structure Patterns

### CRITICAL Issues

#### 1. Fields Not Grouped by Purpose
**Pattern**: Mixed field types without logical grouping
```java
// SMELL: Poor field organization
@Entity
public class User {
    private String name;
    private LocalDateTime createdAt;
    private String email;
    private Long version;
    private String phone;
    private LocalDateTime updatedAt;
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Group fields by purpose and type
// Fix: Group business fields, audit fields, and technical fields
// Structure: ID -> Business fields -> Audit fields -> Technical fields
```

#### 2. Missing Constructor Hierarchy
**Pattern**: Only default constructor or single all-args constructor
```java
// SMELL: Poor constructor design
@Entity
public class User {
    // Only default constructor
    public User() {}
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Add proper constructor hierarchy
// Fix: Add @NoArgsConstructor(access = PROTECTED) and @RequiredArgsConstructor
// Reason: JPA needs no-args, application needs required fields constructor
```

### HIGH Priority Issues

#### 3. Methods Not Ordered by Access Level
**Pattern**: Private methods mixed with public methods
```java
// SMELL: Poor method organization
@Entity
public class User {
    public String getName() { return name; }
    private void validateEmail() { }
    public void setEmail(String email) { }
    private String formatName() { }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Reorder methods by access level
// Fix: public methods first, then protected, then private
// Reason: Improves readability and follows Java conventions
```

#### 4. Static Methods in Entity
**Pattern**: Static utility methods inside entity
```java
// SMELL: Static methods in entity
@Entity
public class User {
    public static boolean isValidEmail(String email) {
        // validation logic
    }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Move static methods to utility class
// Fix: Create UserUtils class for static utility methods
// Reason: Entities should focus on instance state and behavior
```

#### 5. Inconsistent Field Initialization
**Pattern**: Some fields initialized inline, others in constructor
```java
// SMELL: Inconsistent initialization
@Entity
public class User {
    private List<Role> roles = new ArrayList<>(); // Inline
    private LocalDateTime createdAt; // Constructor
    private String status; // Constructor
}
```
**TODO Template**:
```java
// TODO: [HIGH] Standardize field initialization approach
// Fix: Use @Builder.Default for collections or initialize in constructor
// Reason: Consistent initialization pattern improves maintainability
```

### MEDIUM Priority Issues

#### 6. Package-Private Fields Without Reason
**Pattern**: Fields with package visibility without clear purpose
```java
// SMELL: Unclear access modifiers
@Entity
public class User {
    String name; // Package-private without reason
    private String email;
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Clarify field access modifiers
// Fix: Make fields private unless package access is specifically needed
// Reason: Encapsulation and clear access intentions
```

#### 7. Redundant Final Keywords
**Pattern**: Final on fields that don't need it
```java
// SMELL: Unnecessary final
@Entity
public class User {
    private final String name; // Will be set by JPA
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Remove unnecessary final keywords
// Fix: Remove final from JPA-managed fields
// Reason: JPA requires field mutability for hydration
```

#### 8. Methods Without Clear Naming
**Pattern**: Ambiguous method names
```java
// SMELL: Unclear method names
@Entity
public class User {
    public void process() { } // What does this process?
    public boolean check() { } // Check what?
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Use descriptive method names
// Fix: Rename to processPasswordReset(), checkEmailVerification()
// Reason: Clear method names improve code readability
```

### LOW Priority Issues

#### 9. Inconsistent Spacing in Field Declarations
**Pattern**: Mixed spacing patterns
```java
// SMELL: Inconsistent spacing
@Entity
public class User {
    private String name;
    private String        email;
    private   LocalDateTime createdAt;
}
```
**TODO Template**:
```java
// TODO: [LOW] Standardize field declaration spacing
// Fix: Use consistent spacing pattern throughout entity
// Reason: Improves visual consistency and readability
```

#### 10. Mixed Annotation Styles
**Pattern**: Some annotations on same line, others on separate lines
```java
// SMELL: Inconsistent annotation style
@Entity
public class User {
    @Column(name = "user_name") private String name;
    
    @Column(name = "email_address")
    private String email;
}
```
**TODO Template**:
```java
// TODO: [LOW] Standardize annotation placement
// Fix: Place annotations on separate lines consistently
// Reason: Improves readability and follows Java conventions
```

## Internal Structure Best Practices

### Recommended Field Order
1. **Static fields** (constants first, then variables)
2. **ID field** (`@Id` annotated)
3. **Business fields** (core entity data)
4. **Relationship fields** (`@OneToMany`, `@ManyToOne`, etc.)
5. **Audit fields** (`createdAt`, `updatedAt`, `version`)
6. **Technical fields** (flags, status, etc.)

### Recommended Method Order
1. **Static methods** (if any, consider moving to utility class)
2. **Constructors** (no-args, then by parameter count)
3. **Public methods** (getters, setters, business methods)
4. **Protected methods**
5. **Private methods**
6. **equals() and hashCode()**
7. **toString()**

### Constructor Patterns
```java
// GOOD: Proper constructor hierarchy
@Entity
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@RequiredArgsConstructor
public class User {
    @NonNull
    private String name;
    @NonNull
    private String email;
    private LocalDateTime createdAt;
}
```

### Field Grouping Example
```java
// GOOD: Well-organized fields
@Entity
public class User {
    // ID
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    // Business fields
    @NonNull
    private String name;
    @NonNull
    private String email;
    private String phone;
    
    // Relationships
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private List<Order> orders = new ArrayList<>();
    
    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    @Version
    private Long version;
    
    // Technical fields
    private boolean active = true;
    private String status = "PENDING";
}
```

## Detection Patterns for Claude Code

### Field Organization Checks
- Fields not grouped by type/purpose
- ID field not at top
- Audit fields scattered throughout
- Mixed initialization patterns

### Method Organization Checks
- Methods not ordered by access level
- Static methods in entity
- equals/hashCode not at end
- toString not at end

### Constructor Validation
- Missing @NoArgsConstructor(access = PROTECTED)
- Missing @RequiredArgsConstructor
- Public no-args constructor (should be protected)
- All-args constructor without @Builder

### Access Modifier Patterns
- Package-private fields without documentation
- Public fields (should be private with getters)
- Inconsistent access patterns