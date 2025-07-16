# Entity Performance Optimization Analysis

## CRITICAL Issues
- Missing @Index on frequently queried fields
- EAGER fetching on @OneToMany/@ManyToMany
- Missing database constraints causing full table scans

## HIGH Priority Issues
- @Column without length specification causing TEXT fields
- Missing @Query hints for complex queries
- No @Cacheable annotation for read-heavy entities
- @ManyToOne without LAZY fetching

## MEDIUM Priority Issues
- Collections not initialized properly
- Missing @OrderBy causing random ordering
- No @LazyCollection configuration
- Large objects in entity causing memory issues

## LOW Priority Issues
- Missing @Basic(fetch = FetchType.LAZY) for large fields
- No @DynamicUpdate for partial updates
- Missing @SelectBeforeUpdate optimization
- No @Immutable for read-only entities

## TODO Templates

### Missing @Index
```java
// TODO: [CRITICAL] Add database indexes for frequently queried fields
// Fix: @Index in @Table annotation
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_status", columnList = "status"),
    @Index(name = "idx_user_created_at", columnList = "created_at")
})
```

### EAGER fetching on collections
```java
// TODO: [CRITICAL] Use LAZY fetching for collections
// Fix: fetch = FetchType.LAZY (should be explicit)
@OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
private List<Order> orders;
```


### Missing database constraints
```java
// TODO: [CRITICAL] Add database constraints
// Fix: @Column(nullable = false, unique = true)
@Column(nullable = false, unique = true)
private String email;
```

### @Column without length
```java
// TODO: [HIGH] Specify column length to avoid TEXT fields
// Fix: @Column(length = 255)
@Column(length = 255)
private String description;
```

### Missing @Query hints
```java
// TODO: [HIGH] Add query hints for performance
// Fix: @QueryHints(@QueryHint(name = "org.hibernate.cacheable", value = "true"))
@QueryHints(@QueryHint(name = "org.hibernate.cacheable", value = "true"))
```

### Missing @Cacheable
```java
// TODO: [HIGH] Add @Cacheable for read-heavy entities
// Fix: @Cacheable for entities that are read frequently
@Entity
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class User {
```

### @ManyToOne without LAZY
```java
// TODO: [HIGH] Use LAZY fetching for @ManyToOne
// Fix: fetch = FetchType.LAZY
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "category_id")
private Category category;
```

### Collections not initialized
```java
// TODO: [MEDIUM] Initialize collections to prevent NullPointerException
// Fix: = new ArrayList<>()
@OneToMany(mappedBy = "user")
private List<Order> orders = new ArrayList<>();
```

### Missing @OrderBy
```java
// TODO: [MEDIUM] Add @OrderBy for consistent performance
// Fix: @OrderBy("createdAt DESC")
@OneToMany(mappedBy = "user")
@OrderBy("createdAt DESC")
private List<Order> orders;
```

### No @LazyCollection
```java
// TODO: [MEDIUM] Configure @LazyCollection for better control
// Fix: @LazyCollection(LazyCollectionOption.EXTRA)
@OneToMany(mappedBy = "user")
@LazyCollection(LazyCollectionOption.EXTRA)
private List<Order> orders;
```

### Large objects in entity
```java
// TODO: [MEDIUM] Move large objects to separate entity
// Fix: Create separate entity for large fields
// Move large BLOB/CLOB fields to separate entity
```

### Missing @Basic(fetch = LAZY)
```java
// TODO: [LOW] Use LAZY fetching for large fields
// Fix: @Basic(fetch = FetchType.LAZY)
@Basic(fetch = FetchType.LAZY)
@Lob
private String largeDescription;
```

### No @DynamicUpdate
```java
// TODO: [LOW] Add @DynamicUpdate for partial updates
// Fix: @DynamicUpdate generates UPDATE with only changed fields
@Entity
@DynamicUpdate
public class User {
```

### Missing @SelectBeforeUpdate
```java
// TODO: [LOW] Add @SelectBeforeUpdate optimization
// Fix: @SelectBeforeUpdate(false) if entity is always dirty
@Entity
@SelectBeforeUpdate(false)
public class User {
```

### No @Immutable for read-only
```java
// TODO: [LOW] Add @Immutable for read-only entities
// Fix: @Immutable for entities that never change
@Entity
@Immutable
public class Country {
```

## Performance Optimization Patterns

### Optimized Entity Structure
```java
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_status", columnList = "status")
})
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
@DynamicUpdate
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true, length = 255)
    private String email;
    
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    @BatchSize(size = 25)
    @OrderBy("createdAt DESC")
    private List<Order> orders = new ArrayList<>();
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;
    
    @Basic(fetch = FetchType.LAZY)
    @Lob
    private String biography;
}
```

### Collection Performance
```java
// Use appropriate collection types
@OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
@BatchSize(size = 25)
@LazyCollection(LazyCollectionOption.EXTRA)
@OrderBy("priority DESC, createdAt DESC")
private List<Task> tasks = new ArrayList<>();

// Use Set for unique collections
@ManyToMany(fetch = FetchType.LAZY)
@BatchSize(size = 10)
@JoinTable(name = "user_roles")
private Set<Role> roles = new HashSet<>();
```

### Query Performance
```java
// Add indexes for common query patterns
@Table(indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_status_created", columnList = "status, created_at"),
    @Index(name = "idx_user_department", columnList = "department_id")
})
```

## Performance Checklist
- [ ] @Index on all frequently queried fields
- [ ] @BatchSize on all collections
- [ ] FetchType.LAZY on all relationships
- [ ] @Column(length = X) for all String fields
- [ ] @Cacheable for read-heavy entities
- [ ] Collections initialized (new ArrayList<>())
- [ ] @OrderBy for consistent ordering
- [ ] @LazyCollection for size() operations
- [ ] @Basic(fetch = LAZY) for large fields
- [ ] @DynamicUpdate for entities with many fields
- [ ] @SelectBeforeUpdate(false) where appropriate
- [ ] @Immutable for read-only entities
- [ ] Proper database constraints (nullable, unique)
- [ ] Query hints for complex queries
- [ ] Separate entities for large BLOB/CLOB fields