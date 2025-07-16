# JPA Entity Code Review Guide
## Java 11 & Spring Boot 2.7

---

## 🎯 QUICK REFERENCE CHECKLIST

### Critical Issues (Immediate Attention Required)
- [ ] **Missing `@Entity` annotation**
- [ ] **No primary key (`@Id`) defined**
- [ ] **Using `@Data` on JPA entities** (breaks persistence logic)
- [ ] **Mutable collections exposed directly** (security risk)
- [ ] **Lazy-loaded fields in `equals()`/`hashCode()`** (triggers queries)
- [ ] **Missing `@JsonIgnore` on bidirectional relationships** (serialization cycles)
- [ ] **Sensitive data in `toString()`** (password, tokens, etc.)

### Required Annotations
- [ ] `@Entity` and `@Table(name = "table_name")`
- [ ] `@Id` with appropriate `@GeneratedValue` strategy
- [ ] `@Column` for non-default mappings
- [ ] `@NoArgsConstructor` (required by JPA)
- [ ] `@Version` for optimistic locking (if applicable)

---

## 🔍 ANNOTATION PATTERNS

### Core JPA Annotations
```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "email_address", unique = true, length = 100)
    private String email;
    
    @Version
    private Long version; // Optimistic locking
}
```

### Java 11 & Spring Boot 2.7 Specific
```java
// ✅ Validation (spring-boot-starter-validation)
import javax.validation.constraints.*;

@NotBlank(message = "Email cannot be blank")
@Email
private String email;

// ✅ Audit fields
@CreationTimestamp
private LocalDateTime createdAt;

@UpdateTimestamp
private LocalDateTime updatedAt;
```

### Enum Handling
```java
// ✅ Always use STRING for enums
@Enumerated(EnumType.STRING)
@Column(name = "status")
private UserStatus status;

// ❌ Avoid ORDINAL (breaks with enum reordering)
@Enumerated(EnumType.ORDINAL) // DON'T USE
```

### Collections & Relationships
```java
// ✅ Proper collection mapping
@OneToMany(mappedBy = "user", fetch = FetchType.LAZY, cascade = CascadeType.PERSIST)
@BatchSize(size = 20) // Performance optimization
private Set<Order> orders = new HashSet<>();

// ✅ Defensive collection access
public Set<Order> getOrders() {
    return Collections.unmodifiableSet(orders);
}
```

---

## 🚨 CRITICAL SMELLS

### Security Issues
- **🔐 Sensitive Data Exposure**: Password, tokens, or PII in `toString()`
  ```java
  // ❌ BAD
  @ToString
  public class User {
      private String password; // Exposed in logs!
  }
  
  // ✅ GOOD
  @ToString(exclude = {"password", "apiKey"})
  public class User {
      private String password;
  }
  ```

- **🗃️ Mutable Collection Exposure**: Direct access to internal collections
  ```java
  // ❌ BAD - Caller can modify internal state
  public List<Order> getOrders() {
      return orders;
  }
  
  // ✅ GOOD - Defensive copy
  public List<Order> getOrders() {
      return Collections.unmodifiableList(orders);
  }
  ```

### Performance Issues
- **🐌 N+1 Query Triggers**: Lazy loading in utility methods
  ```java
  // ❌ BAD - Will trigger queries
  @Override
  public String toString() {
      return "User{orders=" + orders.size() + "}"; // Lazy loading!
  }
  
  // ✅ GOOD - Exclude lazy fields
  @ToString(exclude = "orders")
  ```

- **⚡ Missing Optimistic Locking**: No version control for concurrent updates
  ```java
  // ✅ REQUIRED for frequently updated entities
  @Version
  private Long version;
  ```

### Data Integrity Issues
- **🧟‍♂️ Zombie Entities**: Using generated IDs in `equals()` before persistence
  ```java
  // ❌ BAD - ID is null before save
  @Override
  public boolean equals(Object o) {
      return id != null && id.equals(((User) o).id);
  }
  
  // ✅ GOOD - Use business key
  @Override
  public boolean equals(Object o) {
      return Objects.equals(email, ((User) o).email);
  }
  ```

---

## 🧠 STRUCTURAL PATTERNS

### Entity Design Principles
- **Single Responsibility**: Entity represents one business concept
- **Pure Data Model**: No business logic, only data and simple validation
- **Immutable Where Possible**: Use final fields and builders for creation

### Field Organization
```java
@Entity
@Table(name = "users")
@NoArgsConstructor
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = {"orders", "password"})
public class User {
    // 1. Primary Key
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;
    
    // 2. Business Keys
    @Column(unique = true, nullable = false)
    @EqualsAndHashCode.Include
    private String email;
    
    // 3. Regular Fields
    @Column(name = "first_name")
    private String firstName;
    
    // 4. Audit Fields
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    // 5. Relationships
    @OneToMany(mappedBy = "user")
    private Set<Order> orders = new HashSet<>();
}
```

### Constructor Patterns
```java
// ✅ Required no-arg constructor
@NoArgsConstructor
protected User() {} // Protected prevents external instantiation

// ✅ Builder for creation (Java 11 compatible)
@AllArgsConstructor
@Builder
public static class UserBuilder {
    // Lombok generates builder
}

// ✅ Factory method pattern
public static User createUser(String email, String firstName) {
    User user = new User();
    user.email = email;
    user.firstName = firstName;
    // Validation logic here
    return user;
}
```

---

## 🧪 BEHAVIORAL PATTERNS

### Equals & HashCode Implementation
```java
// ✅ BEST: Business key approach
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @EqualsAndHashCode.Include
    private String email; // Stable business identifier
}

// ✅ ALTERNATIVE: Safe ID approach
@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof User)) return false;
    User user = (User) o;
    return id != null && Objects.equals(id, user.id);
}

@Override
public int hashCode() {
    return getClass().hashCode(); // Stable across persistence
}
```

### Relationship Management
```java
// ✅ Bidirectional relationship helpers
public void addOrder(Order order) {
    orders.add(order);
    order.setUser(this);
}

public void removeOrder(Order order) {
    orders.remove(order);
    order.setUser(null);
}
```

### Java 11 Specific Patterns
```java
// ✅ Use var in methods (not fields - JPA limitation)
public Optional<String> getDisplayName() {
    var name = firstName;
    return name != null && !name.isBlank() 
        ? Optional.of(name) 
        : Optional.empty();
}

// ✅ Collection factory methods for defaults
@Builder.Default
private Set<Role> roles = Set.of(); // Java 11 immutable collections
```

---

## 🛡️ LOMBOK SAFETY PATTERNS

### Safe Lombok Usage
```java
@Entity
@NoArgsConstructor // Required by JPA
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = {"orders", "password", "apiKeys"})
public class User {
    @EqualsAndHashCode.Include
    private String email;
    
    @ToString.Exclude // Sensitive data
    private String password;
    
    @ToString.Exclude // Prevent lazy loading
    @OneToMany(mappedBy = "user")
    private Set<Order> orders;
}
```

### Dangerous Lombok Patterns
```java
// ❌ NEVER use @Data on entities
@Data // Includes @EqualsAndHashCode, @ToString - breaks JPA
public class User {} // DON'T DO THIS

// ❌ NEVER use @EqualsAndHashCode without exclusions
@EqualsAndHashCode // Includes ALL fields by default
public class User {
    private Set<Order> orders; // Will trigger lazy loading!
}
```

---

## 🧭 VALIDATION PATTERNS

### Field-Level Validation
```java
// Spring Boot 2.7 - javax.validation
@NotNull(message = "Email is required")
@Email(message = "Invalid email format")
@Column(unique = true)
private String email;

@Size(min = 2, max = 50, message = "Name must be 2-50 characters")
private String firstName;

@Past(message = "Birth date must be in the past")
private LocalDate birthDate;
```

### Custom Validation
```java
@Entity
@Table(name = "users")
public class User {
    @Column(name = "phone_number")
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Invalid phone format")
    private String phoneNumber;
    
    // Business validation in setters
    public void setEmail(String email) {
        if (email != null && email.isBlank()) {
            throw new IllegalArgumentException("Email cannot be blank");
        }
        this.email = email;
    }
}
```

---

## 🎨 EMBEDDED TYPES & VALUE OBJECTS

### Extracting Value Objects
```java
// ❌ Primitive obsession
@Entity
public class User {
    private String street;
    private String city;
    private String zipCode;
    private String country;
}

// ✅ Value object extraction
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
@Getter
public class Address {
    @Column(name = "street")
    private String street;
    
    @Column(name = "city")
    private String city;
    
    @Column(name = "zip_code")
    private String zipCode;
    
    @Column(name = "country")
    private String country;
}

@Entity
public class User {
    @Embedded
    private Address address;
}
```

### Money Value Object
```java
@Embeddable
public class Money {
    @Column(name = "amount", precision = 19, scale = 2)
    private BigDecimal amount;
    
    @Column(name = "currency", length = 3)
    private String currency;
    
    // Business methods
    public Money add(Money other) {
        if (!currency.equals(other.currency)) {
            throw new IllegalArgumentException("Currency mismatch");
        }
        return new Money(amount.add(other.amount), currency);
    }
}
```

---

## 📋 AUDIT & METADATA PATTERNS

### Standard Audit Fields
```java
@MappedSuperclass
@Getter
@Setter
public abstract class AuditableEntity {
    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "created_by")
    private String createdBy;
    
    @Column(name = "updated_by")
    private String updatedBy;
    
    @Version
    private Long version;
}

@Entity
@Table(name = "users")
public class User extends AuditableEntity {
    // Entity-specific fields only
}
```

### Soft Delete Pattern
```java
@Entity
@Table(name = "users")
@Where(clause = "deleted = false") // Hibernate-specific
public class User {
    @Builder.Default
    @Column(name = "deleted")
    private Boolean deleted = false;
    
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;
    
    public void markDeleted() {
        this.deleted = true;
        this.deletedAt = LocalDateTime.now();
    }
}
```

---

## 🔧 PERFORMANCE OPTIMIZATION

### Query Optimization Hints
```java
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_email", columnList = "email"),
    @Index(name = "idx_status_created", columnList = "status, created_at")
})
public class User {
    // Frequently queried fields should be indexed
}
```

### Lazy Loading Optimization
```java
@OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
@BatchSize(size = 20) // Optimize N+1 queries
private Set<Order> orders;

@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "department_id")
private Department department;
```

### Projection Interfaces
```java
// For read-only operations
public interface UserSummary {
    String getEmail();
    String getFirstName();
    LocalDateTime getCreatedAt();
}

// In repository
List<UserSummary> findAllProjectedBy();
```

---

## 🧹 REFACTORING PATTERNS

### God Entity Splitting
```java
// ❌ BAD - Too many responsibilities
@Entity
public class User {
    // Profile data
    private String firstName, lastName, email;
    // Preferences
    private String theme, language, timezone;
    // Security
    private String password, salt, lastLogin;
    // Billing
    private String creditCard, billingAddress;
}

// ✅ GOOD - Split by concern
@Entity
public class User {
    private String email;
    
    @OneToOne(cascade = CascadeType.ALL)
    private UserProfile profile;
    
    @OneToOne(cascade = CascadeType.ALL)
    private UserPreferences preferences;
    
    @OneToOne(cascade = CascadeType.ALL)
    private UserSecurity security;
}
```

### Extract Constants
```java
// ❌ Magic strings scattered
@Column(name = "status", length = 20)
private String status;

@Table(name = "user_profiles")
public class UserProfile {}

// ✅ Centralized constants
public final class DatabaseConstants {
    public static final class User {
        public static final String TABLE_NAME = "users";
        public static final String STATUS_COLUMN = "status";
        public static final int STATUS_LENGTH = 20;
    }
}

@Table(name = DatabaseConstants.User.TABLE_NAME)
@Column(name = DatabaseConstants.User.STATUS_COLUMN, 
        length = DatabaseConstants.User.STATUS_LENGTH)
```

---

## 🎯 COMMON ANTI-PATTERNS

### Repository Anti-Patterns in Entities
```java
// ❌ DON'T expose repository methods in entities
@Entity
public class User {
    public static List<User> findAllActive() {
        // Entity shouldn't know about persistence
    }
}

// ✅ Keep entities pure
@Entity
public class User {
    // Only data and simple business rules
    public boolean isActive() {
        return status == UserStatus.ACTIVE;
    }
}
```

### Cascade Misuse
```java
// ❌ Dangerous - can delete unintended data
@OneToMany(cascade = CascadeType.ALL)
private Set<Order> orders;

// ✅ Explicit about what cascades
@OneToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
private Set<Order> orders;
```

### Serialization Cycles
```java
// ❌ Creates infinite loops in JSON
@Entity
public class User {
    @OneToMany(mappedBy = "user")
    private Set<Order> orders;
}

@Entity  
public class Order {
    @ManyToOne
    private User user; // Bidirectional without @JsonIgnore
}

// ✅ Break the cycle
@Entity
public class User {
    @OneToMany(mappedBy = "user")
    @JsonIgnore // Or use @JsonManagedReference
    private Set<Order> orders;
}
```

---

## 📝 FINAL CHECKLIST

### Before Code Review Submission
- [ ] All fields have appropriate JPA annotations
- [ ] No business logic in entity (moved to services)
- [ ] Safe `equals()` and `hashCode()` implementation
- [ ] Lazy-loaded fields excluded from `toString()`
- [ ] Sensitive data excluded from `toString()`
- [ ] Collections return defensive copies
- [ ] Validation annotations present and correct
- [ ] Optimistic locking considered (`@Version`)
- [ ] Proper cascade types specified
- [ ] Index annotations for query performance
- [ ] No Lombok `@Data` usage
- [ ] `@JsonIgnore` on bidirectional relationships

### Performance Considerations
- [ ] Large text fields use `@Lob` appropriately
- [ ] Enum fields use `STRING` strategy
- [ ] Frequently queried fields are indexed
- [ ] `@BatchSize` on collections if needed
- [ ] Lazy loading configured correctly

### Security Review
- [ ] No sensitive data in logs (`toString()`)
- [ ] Password fields properly excluded
- [ ] API keys/tokens not serialized
- [ ] Input validation on setters
- [ ] SQL injection prevention in custom queries