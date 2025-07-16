# Entity JPA Annotations Analysis

## CRITICAL Issues
- Missing @Entity annotation
- No @Id field present
- @GeneratedValue without strategy specified
- @Entity without @Table name specification

## HIGH Priority Issues
- No indexes defined for frequently queried fields
- @Column without nullable specification
- @Enumerated without EnumType.STRING
- Bidirectional relationships without mappedBy

## MEDIUM Priority Issues
- Missing @PrePersist/@PreUpdate callbacks for timestamps
- No @EqualsAndHashCode.Include on @Id field
- @OneToMany without cascade specification
- No @Index for foreign key fields

## LOW Priority Issues
- @Column without length specification for strings
- Missing @OrderBy for collections
- No @Temporal for Date fields (if using old Date API)

## TODO Templates

### Missing @Entity
```java
// TODO: [CRITICAL] Add @Entity annotation
// Fix: @Entity annotation required for JPA persistence
@Entity
```

### Missing @Table
```java
// TODO: [CRITICAL] Specify table name explicitly
// Fix: @Table(name = "table_name")
@Table(name = "your_table_name")
```

### Missing @Id
```java
// TODO: [CRITICAL] Add @Id annotation to primary key field
// Fix: Every entity must have exactly one @Id field
@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
private Long id;
```

### @GeneratedValue without strategy
```java
// TODO: [CRITICAL] Specify generation strategy
// Fix: @GeneratedValue(strategy = GenerationType.IDENTITY)
@GeneratedValue(strategy = GenerationType.IDENTITY)
```


### Missing indexes
```java
// TODO: [HIGH] Add database indexes for performance
// Fix: Add indexes for frequently queried fields
@Table(name = "table_name", indexes = {
    @Index(name = "idx_field_name", columnList = "fieldName")
})
```

### @Column without nullable
```java
// TODO: [HIGH] Specify nullable constraint
// Fix: @Column(nullable = false) or @Column(nullable = true)
@Column(nullable = false)
```

### @Enumerated without STRING
```java
// TODO: [HIGH] Use EnumType.STRING for database compatibility
// Fix: @Enumerated(EnumType.STRING)
@Enumerated(EnumType.STRING)
```

### Missing mappedBy
```java
// TODO: [HIGH] Add mappedBy for bidirectional relationships
// Fix: @OneToMany(mappedBy = "parentField")
@OneToMany(mappedBy = "parentField")
```

### Missing timestamp callbacks
```java
// TODO: [MEDIUM] Add lifecycle callbacks for timestamps
// Fix: Use @PrePersist and @PreUpdate
@PrePersist
protected void onCreate() {
    createdAt = LocalDateTime.now();
}

@PreUpdate
protected void onUpdate() {
    updatedAt = LocalDateTime.now();
}
```

### Missing cascade
```java
// TODO: [MEDIUM] Specify cascade operations
// Fix: @OneToMany(cascade = CascadeType.ALL)
@OneToMany(cascade = CascadeType.ALL)
```


## Required Annotations Checklist
- [ ] @Entity
- [ ] @Table(name = "explicit_name")
- [ ] @Id on primary key
- [ ] @GeneratedValue(strategy = GenerationType.IDENTITY)
- [ ] @Column(nullable = false/true) on all fields
- [ ] @Enumerated(EnumType.STRING) on enums
- [ ] @PrePersist/@PreUpdate for timestamps
- [ ] @Index in @Table for frequently queried fields
- [ ] mappedBy on bidirectional relationships