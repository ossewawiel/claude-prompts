# Entity Equals/HashCode Analysis

## CRITICAL Issues
- Using @Data without @EqualsAndHashCode configuration on JPA entities
- @EqualsAndHashCode including mutable fields
- Lombok-generated equals/hashCode accessing lazy-loaded collections
- Missing @EqualsAndHashCode.Include on business identity fields

## HIGH Priority Issues
- @EqualsAndHashCode including all fields instead of business identity
- Using @EqualsAndHashCode without onlyExplicitlyIncluded = true
- Custom equals/hashCode not following JPA entity contracts
- @EqualsAndHashCode including sensitive fields

## MEDIUM Priority Issues
- Inconsistent equals/hashCode between entity and its DTOs
- @EqualsAndHashCode.Include on auto-generated ID field only
- Missing equals/hashCode for embedded value objects
- @EqualsAndHashCode including transient fields

## LOW Priority Issues
- Not overriding equals/hashCode when extending entity classes
- Missing @EqualsAndHashCode.Include on natural business keys
- Inconsistent equals/hashCode performance characteristics
- No custom equals/hashCode for specific business requirements

## TODO Templates

### @Data without @EqualsAndHashCode config
```java
// TODO: [CRITICAL] Configure @EqualsAndHashCode for JPA entity
// Fix: Use onlyExplicitlyIncluded = true and mark business identity fields
@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @Id
    @EqualsAndHashCode.Include
    private Long id;
    
    @EqualsAndHashCode.Include
    private String email; // Natural business key
}
```

### @EqualsAndHashCode including mutable fields
```java
// TODO: [CRITICAL] Exclude mutable fields from equals/hashCode
// Fix: Only include immutable business identity fields
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @EqualsAndHashCode.Include
    private String email; // Include business key
    
    // Exclude mutable fields
    private String firstName; // Don't include - can change
    private String lastName;  // Don't include - can change
}
```

### Lombok accessing lazy collections
```java
// TODO: [CRITICAL] Prevent equals/hashCode from accessing lazy collections
// Fix: Exclude collections from equals/hashCode
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = {"orders", "roles"})
public class User {
    @EqualsAndHashCode.Include
    private Long id;
    
    // Exclude to prevent lazy loading
    private List<Order> orders;
    private Set<Role> roles;
}
```

### Missing business identity inclusion
```java
// TODO: [CRITICAL] Include business identity fields in equals/hashCode
// Fix: Mark natural business keys with @EqualsAndHashCode.Include
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @Id
    @EqualsAndHashCode.Include
    private Long id;
    
    @EqualsAndHashCode.Include
    private String email; // Natural business key
    
    @EqualsAndHashCode.Include
    private String username; // Another business key
}
```

### Including all fields in equals/hashCode
```java
// TODO: [HIGH] Use business identity instead of all fields
// Fix: Only include fields that define business identity
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Product {
    @EqualsAndHashCode.Include
    private String sku; // Business identity
    
    // Exclude descriptive fields
    private String name;
    private String description;
    private BigDecimal price;
}
```

### Custom equals/hashCode not following JPA contracts
```java
// TODO: [HIGH] Implement JPA-compliant equals/hashCode
// Fix: Follow JPA entity identity contracts
@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof User)) return false;
    User user = (User) o;
    // Use business key, not ID for new entities
    return Objects.equals(email, user.email);
}

@Override
public int hashCode() {
    // Use business key that doesn't change
    return Objects.hash(email);
}
```

### Including sensitive fields
```java
// TODO: [HIGH] Exclude sensitive fields from equals/hashCode
// Fix: Never include passwords or sensitive data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @EqualsAndHashCode.Include
    private String email;
    
    @EqualsAndHashCode.Exclude // Explicit exclusion
    private String password;
    
    @EqualsAndHashCode.Exclude
    private String ssn;
}
```

### Only using ID in equals/hashCode
```java
// TODO: [MEDIUM] Include natural business keys in equals/hashCode
// Fix: Use business identity for better semantics
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @Id
    @EqualsAndHashCode.Include
    private Long id;
    
    @EqualsAndHashCode.Include
    private String email; // Add natural business key
}
```

### Missing equals/hashCode for embedded objects
```java
// TODO: [MEDIUM] Add equals/hashCode for embedded value objects
// Fix: @EqualsAndHashCode on embedded objects
@Embeddable
@EqualsAndHashCode
public class Address {
    private String street;
    private String city;
    private String country;
}
```

### Including transient fields
```java
// TODO: [MEDIUM] Exclude transient fields from equals/hashCode
// Fix: Transient fields shouldn't participate in equality
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    @EqualsAndHashCode.Include
    private String email;
    
    @Transient
    private String displayName; // Exclude transient fields
}
```

## When to Use Custom equals/hashCode Instead of Lombok

### Complex Business Identity
```java
// TODO: Consider custom equals/hashCode for complex business rules
// Fix: Custom implementation when business identity is complex
@Entity
public class User {
    @Id
    private Long id;
    
    private String email;
    private String username;
    private String domain;
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User)) return false;
        User user = (User) o;
        
        // Complex business rule: email@domain uniqueness
        return Objects.equals(email, user.email) && 
               Objects.equals(domain, user.domain);
    }
    
    @Override
    public int hashCode() {
        // Hash based on composite business key
        return Objects.hash(email, domain);
    }
}
```

### Hierarchical Entities
```java
// TODO: Custom equals/hashCode for entity inheritance
// Fix: Handle inheritance properly in equals/hashCode
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
public abstract class Person {
    @Id
    protected Long id;
    
    protected String email;
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Person)) return false;
        Person person = (Person) o;
        return Objects.equals(email, person.email);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(email);
    }
}
```

### Performance-Critical Scenarios
```java
// TODO: Custom equals/hashCode for performance optimization
// Fix: Optimize for specific use cases
@Entity
public class HighVolumeEntity {
    @Id
    private Long id;
    
    private String businessKey;
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof HighVolumeEntity)) return false;
        
        // Fast path for same business key
        HighVolumeEntity that = (HighVolumeEntity) o;
        return Objects.equals(businessKey, that.businessKey);
    }
    
    @Override
    public int hashCode() {
        // Pre-computed hash for performance
        return businessKey != null ? businessKey.hashCode() : 0;
    }
}
```

## Recommended Patterns

### Standard JPA Entity with Lombok
```java
@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = {"orders", "password"})
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;
    
    @Column(unique = true, nullable = false)
    @EqualsAndHashCode.Include
    private String email;
    
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private String password;
    
    @OneToMany(mappedBy = "user")
    @Builder.Default
    private List<Order> orders = new ArrayList<>();
}
```

### Natural Business Key Entity
```java
@Entity
@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class Product {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    @EqualsAndHashCode.Include
    private String sku; // Natural business key
    
    @Column(nullable = false)
    @EqualsAndHashCode.Include
    private String manufacturer; // Part of business identity
    
    private String name;
    private BigDecimal price;
}
```

### Composite Business Key Entity
```java
@Entity
@Data
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class OrderItem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @EqualsAndHashCode.Include
    private Order order;
    
    @ManyToOne
    @EqualsAndHashCode.Include
    private Product product;
    
    // Quantity and price are not part of identity
    private Integer quantity;
    private BigDecimal price;
}
```

## Decision Matrix: Lombok vs Custom equals/hashCode

### Use Lombok @EqualsAndHashCode when:
- ✅ Simple business identity (1-2 fields)
- ✅ Standard JPA entity patterns
- ✅ No complex inheritance hierarchy
- ✅ Performance is not critical
- ✅ Business rules are straightforward

### Use Custom equals/hashCode when:
- ✅ Complex business identity rules
- ✅ Entity inheritance hierarchies
- ✅ Performance-critical scenarios
- ✅ Composite keys with custom logic
- ✅ Integration with legacy systems
- ✅ Custom null handling requirements

## Equals/HashCode Checklist
- [ ] @EqualsAndHashCode(onlyExplicitlyIncluded = true) on entities
- [ ] @EqualsAndHashCode.Include on ID field
- [ ] @EqualsAndHashCode.Include on natural business keys
- [ ] @EqualsAndHashCode.Exclude on sensitive fields
- [ ] @EqualsAndHashCode.Exclude on collections/relationships
- [ ] @EqualsAndHashCode.Exclude on mutable descriptive fields
- [ ] @EqualsAndHashCode.Exclude on transient fields
- [ ] @ToString.Exclude on collections to prevent lazy loading
- [ ] Custom equals/hashCode for complex business identity
- [ ] Consistent equals/hashCode in entity hierarchies
- [ ] Performance optimization for high-volume entities
- [ ] Business key immutability consideration
- [ ] Null safety in custom implementations
- [ ] Symmetric and transitive equality contracts
- [ ] Consistent hashCode with equals implementation