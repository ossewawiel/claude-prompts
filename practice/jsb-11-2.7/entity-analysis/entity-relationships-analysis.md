# Entity Relationships Analysis

## CRITICAL Issues
- @OneToMany without mappedBy causing extra join table
- @ManyToOne without @JoinColumn specification
- Bidirectional relationships without proper back-reference management
- @ManyToMany without @JoinTable configuration

## HIGH Priority Issues
- @OneToMany with CascadeType.ALL on parent-child relationships
- Missing orphanRemoval = true for owned entities
- @ManyToOne with EAGER fetching by default
- Circular references in bidirectional relationships

## MEDIUM Priority Issues
- @OneToMany without @OrderBy or @OrderColumn
- @ManyToMany without cascade configuration
- Missing @JoinColumn name specification

## LOW Priority Issues
- Collection interface instead of List for ordered relationships
- Missing @LazyCollection configuration
- No @Where clause for soft-deleted entities
- Generic types missing on relationship collections

## TODO Templates

### @OneToMany without mappedBy
```java
// TODO: [CRITICAL] Add mappedBy to avoid extra join table
// Fix: @OneToMany(mappedBy = "parentField")
@OneToMany(mappedBy = "user")
private List<Order> orders;
```

### @ManyToOne without @JoinColumn
```java
// TODO: [CRITICAL] Add @JoinColumn to specify foreign key
// Fix: @JoinColumn(name = "user_id")
@ManyToOne
@JoinColumn(name = "user_id")
private User user;
```

### Missing back-reference management
```java
// TODO: [CRITICAL] Add helper methods for bidirectional relationships
// Fix: Add addOrder() and removeOrder() methods
public void addOrder(Order order) {
    orders.add(order);
    order.setUser(this);
}

public void removeOrder(Order order) {
    orders.remove(order);
    order.setUser(null);
}
```

### @ManyToMany without @JoinTable
```java
// TODO: [CRITICAL] Configure @JoinTable for many-to-many
// Fix: Specify join table and column names
@ManyToMany
@JoinTable(
    name = "user_roles",
    joinColumns = @JoinColumn(name = "user_id"),
    inverseJoinColumns = @JoinColumn(name = "role_id")
)
private Set<Role> roles;
```

### Missing CascadeType.ALL on parent-child
```java
// TODO: [HIGH] Add cascade operations for parent-child relationships
// Fix: @OneToMany(cascade = CascadeType.ALL)
@OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
private List<Order> orders;
```

### Missing orphanRemoval
```java
// TODO: [HIGH] Add orphanRemoval for owned entities
// Fix: orphanRemoval = true for owned child entities
@OneToMany(mappedBy = "user", orphanRemoval = true)
private List<Address> addresses;
```

### @ManyToOne with EAGER fetching
```java
// TODO: [HIGH] Use LAZY fetching for @ManyToOne
// Fix: fetch = FetchType.LAZY (default should be explicit)
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "category_id")
private Category category;
```

### Circular references in toString/equals
```java
// TODO: [HIGH] Exclude relationship fields from toString
// Fix: @ToString(exclude = {"orders", "user"})
@ToString(exclude = {"orders", "user"})
```

### Missing @OrderBy
```java
// TODO: [MEDIUM] Add @OrderBy for consistent ordering
// Fix: @OrderBy("createdAt DESC")
@OneToMany(mappedBy = "user")
@OrderBy("createdAt DESC")
private List<Order> orders;
```


### @ManyToMany without cascade
```java
// TODO: [MEDIUM] Configure cascade for many-to-many
// Fix: cascade = {CascadeType.PERSIST, CascadeType.MERGE}
@ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
private Set<Role> roles;
```

### Missing @JoinColumn name
```java
// TODO: [MEDIUM] Specify @JoinColumn name explicitly
// Fix: @JoinColumn(name = "parent_id")
@ManyToOne
@JoinColumn(name = "parent_id")
private Parent parent;
```

### Using Collection instead of List
```java
// TODO: [LOW] Use List for ordered relationships
// Fix: List<Order> instead of Collection<Order>
private List<Order> orders; // instead of Collection<Order>
```

### Missing generic types on collections
```java
// TODO: [LOW] Add generic types to relationship collections
// Fix: List<Order> instead of List
private List<Order> orders; // instead of List orders
```

## Relationship Best Practices

### OneToMany Pattern
```java
@OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
@OrderBy("createdAt DESC")
@BatchSize(size = 25)
private List<Order> orders = new ArrayList<>();

// Helper methods
public void addOrder(Order order) {
    orders.add(order);
    order.setUser(this);
}
```

### ManyToOne Pattern
```java
@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "user_id", nullable = false)
private User user;
```

### ManyToMany Pattern
```java
@ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
@JoinTable(
    name = "user_roles",
    joinColumns = @JoinColumn(name = "user_id"),
    inverseJoinColumns = @JoinColumn(name = "role_id")
)
private Set<Role> roles = new HashSet<>();
```

### OneToOne Pattern
```java
@OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
@JoinColumn(name = "profile_id")
private UserProfile profile;
```

## Relationship Configuration Checklist
- [ ] @OneToMany has mappedBy for bidirectional
- [ ] @ManyToOne has @JoinColumn with name
- [ ] @ManyToMany has @JoinTable configuration
- [ ] Cascade operations configured appropriately
- [ ] orphanRemoval = true for owned entities
- [ ] FetchType.LAZY for all relationships (explicit)
- [ ] @OrderBy or @OrderColumn for ordered collections
- [ ] @BatchSize for performance optimization
- [ ] Helper methods for bidirectional relationships
- [ ] @ToString excludes relationship fields
- [ ] Generic types on all collections
- [ ] Proper collection initialization (ArrayList/HashSet)
- [ ] Set for many-to-many, List for one-to-many