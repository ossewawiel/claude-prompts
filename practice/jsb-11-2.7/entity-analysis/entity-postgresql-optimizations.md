# Entity PostgreSQL Optimization Analysis

## CRITICAL Issues
- Using GenerationType.AUTO instead of IDENTITY for PostgreSQL
- String fields without explicit length causing TEXT columns
- Missing @SequenceGenerator for custom sequences
- ENUM fields without @Enumerated(EnumType.STRING)

## HIGH Priority Issues
- No @Index on JSONB columns for queries
- Missing @Column(columnDefinition = "jsonb") for JSON fields
- UUID fields without proper PostgreSQL UUID type
- Missing database-specific constraints in @Column

## MEDIUM Priority Issues
- Not using PostgreSQL-specific data types
- Missing @Check constraints for business rules
- No @Formula for calculated columns
- Missing array type support

## LOW Priority Issues
- Not using PostgreSQL full-text search annotations
- Missing @Where clauses for partial indexes
- No custom @Type for PostgreSQL-specific types
- Missing @ColumnTransformer for case-insensitive searches

## TODO Templates

### Wrong ID generation strategy
```java
// TODO: [CRITICAL] Use IDENTITY strategy for PostgreSQL
// Fix: PostgreSQL works best with IDENTITY, not AUTO
@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
private Long id;
```

### String without length causing TEXT
```java
// TODO: [CRITICAL] Specify column length to avoid TEXT type
// Fix: @Column(length = 255) creates VARCHAR instead of TEXT
@Column(length = 255)
private String description;
```

### Missing sequence generator
```java
// TODO: [CRITICAL] Add @SequenceGenerator for PostgreSQL sequences
// Fix: Use PostgreSQL sequences for better performance
@Id
@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "user_seq")
@SequenceGenerator(name = "user_seq", sequenceName = "user_id_seq", allocationSize = 1)
private Long id;
```

### ENUM without STRING type
```java
// TODO: [CRITICAL] Use EnumType.STRING for PostgreSQL compatibility
// Fix: PostgreSQL ENUM support is better with STRING
@Enumerated(EnumType.STRING)
private Status status;
```

### Missing JSONB optimization
```java
// TODO: [HIGH] Use JSONB column type for JSON data
// Fix: @Column(columnDefinition = "jsonb") for better performance
@Column(columnDefinition = "jsonb")
private String preferences;
```

### Missing JSONB index
```java
// TODO: [HIGH] Add GIN index for JSONB columns
// Fix: @Index with PostgreSQL GIN index for JSON queries
@Table(indexes = {
    @Index(name = "idx_user_preferences_gin", columnList = "preferences", 
           columnDefinition = "USING gin (preferences)")
})
```

### UUID without proper type
```java
// TODO: [HIGH] Use PostgreSQL UUID type
// Fix: @Column(columnDefinition = "uuid") for native UUID support
@Column(columnDefinition = "uuid")
private UUID externalId;
```

### Missing database constraints
```java
// TODO: [HIGH] Add database-level constraints
// Fix: @Column with PostgreSQL-specific constraints
@Column(nullable = false, columnDefinition = "varchar(255) check (length(email) > 0)")
private String email;
```

### Not using PostgreSQL arrays
```java
// TODO: [MEDIUM] Use PostgreSQL array types
// Fix: @Column(columnDefinition = "text[]") for array support
@Column(columnDefinition = "text[]")
private String[] tags;
```

### Missing @Check constraints
```java
// TODO: [MEDIUM] Add @Check constraints for business rules
// Fix: @Check annotation for database-level validation
@Entity
@Check(constraints = "age >= 0 AND age <= 150")
public class User {
```

### Missing @Formula for calculated fields
```java
// TODO: [MEDIUM] Use @Formula for calculated columns
// Fix: @Formula with PostgreSQL functions
@Formula("(first_name || ' ' || last_name)")
private String fullName;
```

### Missing full-text search
```java
// TODO: [LOW] Add full-text search support
// Fix: @Column with tsvector for full-text search
@Column(columnDefinition = "tsvector")
private String searchVector;
```

## PostgreSQL-Specific Entity Pattern

```java
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_preferences_gin", columnList = "preferences", 
           columnDefinition = "USING gin (preferences)"),
    @Index(name = "idx_user_search", columnList = "search_vector",
           columnDefinition = "USING gin (search_vector)")
})
@Check(constraints = "age >= 0 AND age <= 150")
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(columnDefinition = "uuid", unique = true)
    private UUID externalId;
    
    @Column(length = 255, nullable = false)
    private String email;
    
    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "varchar(50)")
    private UserStatus status;
    
    @Column(columnDefinition = "jsonb")
    private String preferences;
    
    @Column(columnDefinition = "text[]")
    private String[] tags;
    
    @Formula("(first_name || ' ' || last_name)")
    private String fullName;
    
    @Column(columnDefinition = "tsvector")
    private String searchVector;
    
    @Column(columnDefinition = "timestamp with time zone")
    private LocalDateTime createdAt;
}
```

## PostgreSQL Checklist
- [ ] GenerationType.IDENTITY for ID generation
- [ ] @Column(length = X) for VARCHAR instead of TEXT
- [ ] @Enumerated(EnumType.STRING) for enums
- [ ] @Column(columnDefinition = "jsonb") for JSON data
- [ ] GIN indexes for JSONB columns
- [ ] @Column(columnDefinition = "uuid") for UUID fields
- [ ] @Check constraints for business rules
- [ ] @Formula for calculated columns
- [ ] PostgreSQL array types where appropriate
- [ ] Full-text search with tsvector
- [ ] Timezone-aware timestamp columns
- [ ] Case-insensitive indexes where needed
- [ ] Partial indexes with @Where clauses
- [ ] Custom @Type for PostgreSQL-specific types
- [ ] @SequenceGenerator for custom sequences