# Entity Refactoring Code Smells Detection

## Purpose
Identify common code smells in JPA entities for Spring Boot 2.7 Java 11 applications that indicate refactoring opportunities.

## Code Smell Patterns

### CRITICAL Issues

#### 1. Entity Contains Business Logic
**Pattern**: Methods with complex business rules inside entity
```java
// SMELL: Business logic in entity
public class User {
    public boolean canPurchase(Product product) {
        // Complex business logic here
    }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Move business logic to service layer
// Fix: Extract business logic to UserService.canPurchase()
// Reason: Entities should only contain data and basic validation
```

#### 2. Direct Repository/Service Injection
**Pattern**: `@Autowired` fields in entities
```java
// SMELL: Service injection in entity
@Entity
public class Order {
    @Autowired
    private PaymentService paymentService;
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Remove service injection from entity
// Fix: Move service calls to service layer
// Reason: Entities should be POJOs without Spring dependencies
```

### HIGH Priority Issues

#### 3. Bloated Entity (God Object)
**Pattern**: Entity with >15 fields or >20 methods
```java
// SMELL: Too many responsibilities
@Entity
public class User {
    // 20+ fields
    // 25+ methods
}
```
**TODO Template**:
```java
// TODO: [HIGH] Split bloated entity into smaller entities
// Fix: Extract related fields into separate entities or value objects
// Reason: Violates Single Responsibility Principle
```

#### 4. Inappropriate toString() with Sensitive Data
**Pattern**: toString() exposing passwords, tokens, etc.
```java
// SMELL: Sensitive data in toString
public class User {
    private String password;
    // toString includes password
}
```
**TODO Template**:
```java
// TODO: [HIGH] Exclude sensitive fields from toString
// Fix: Use @ToString.Exclude or custom toString implementation
// Reason: Prevents sensitive data exposure in logs
```

#### 5. Mutable Collections Without Defensive Copy
**Pattern**: Exposed mutable collections
```java
// SMELL: Direct collection exposure
public class User {
    private List<Role> roles = new ArrayList<>();
    
    public List<Role> getRoles() {
        return roles; // Direct reference
    }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Return defensive copy of collections
// Fix: return new ArrayList<>(roles) or Collections.unmodifiableList(roles)
// Reason: Prevents external modification of internal state
```

### MEDIUM Priority Issues

#### 6. Magic Numbers/Strings
**Pattern**: Hardcoded values in constraints
```java
// SMELL: Magic numbers
@Column(length = 255)
private String email;

@Size(max = 50)
private String name;
```
**TODO Template**:
```java
// TODO: [MEDIUM] Replace magic numbers with named constants
// Fix: Create static final constants or enum values
// Reason: Improves maintainability and readability
```

#### 7. Inconsistent Null Handling
**Pattern**: Mixed null checks and Optional usage
```java
// SMELL: Inconsistent null handling
public class User {
    public String getName() {
        return name != null ? name : "Unknown";
    }
    
    public Optional<String> getEmail() {
        return Optional.ofNullable(email);
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Standardize null handling approach
// Fix: Use consistent Optional pattern or null checks throughout
// Reason: Improves code consistency and reduces bugs
```

#### 8. Primitive Obsession
**Pattern**: Using primitives for complex concepts
```java
// SMELL: Primitive obsession
public class Product {
    private double price; // Should be Money value object
    private String currency; // Should be part of Money
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Replace primitives with value objects
// Fix: Create Money value object combining price and currency
// Reason: Better type safety and domain modeling
```

### LOW Priority Issues

#### 9. Unnecessary Mutability
**Pattern**: Setters for fields that shouldn't change
```java
// SMELL: Unnecessary mutability
public class User {
    private String id;
    
    public void setId(String id) { // ID shouldn't change
        this.id = id;
    }
}
```
**TODO Template**:
```java
// TODO: [LOW] Remove unnecessary setters for immutable fields
// Fix: Remove setter or make field final with constructor initialization
// Reason: Prevents accidental modification of immutable data
```

#### 10. Verbose Constructor Parameters
**Pattern**: Constructors with >5 parameters
```java
// SMELL: Too many constructor parameters
public User(String name, String email, String phone, 
           String address, String city, String country, 
           LocalDateTime created) {
}
```
**TODO Template**:
```java
// TODO: [LOW] Use builder pattern for complex construction
// Fix: Add @Builder annotation or parameter objects
// Reason: Improves readability and reduces parameter errors
```

## Detection Patterns for Claude Code

### Entity Size Metrics
- **Field Count**: >15 fields = HIGH priority
- **Method Count**: >20 methods = HIGH priority
- **Line Count**: >300 lines = MEDIUM priority

### Dependency Indicators
- `@Autowired` annotations = CRITICAL
- `@Service`, `@Repository` imports = CRITICAL
- Static method calls to utility classes = MEDIUM

### Complexity Indicators
- Nested if/else blocks >3 levels = HIGH
- Method cyclomatic complexity >10 = HIGH
- Multiple return statements = MEDIUM

### Data Exposure Patterns
- Public fields without getters = HIGH
- Mutable collection returns = HIGH
- toString() with all fields = MEDIUM

## Refactoring Priority Matrix

| Code Smell | Severity | Impact | Effort | Priority |
|-------------|----------|---------|---------|----------|
| Business Logic | CRITICAL | High | Medium | 1 |
| Service Injection | CRITICAL | High | Low | 2 |
| Bloated Entity | HIGH | High | High | 3 |
| Sensitive toString | HIGH | Medium | Low | 4 |
| Mutable Collections | HIGH | Medium | Low | 5 |
| Magic Numbers | MEDIUM | Low | Low | 6 |
| Inconsistent Nulls | MEDIUM | Medium | Medium | 7 |
| Primitive Obsession | MEDIUM | Medium | High | 8 |
| Unnecessary Mutability | LOW | Low | Low | 9 |
| Verbose Constructors | LOW | Low | Medium | 10 |