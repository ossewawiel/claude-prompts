# Entity MariaDB Optimization Analysis

## CRITICAL Issues
- Using GenerationType.IDENTITY on tables with high insert volume
- String fields without explicit length causing LONGTEXT
- Missing @Column(columnDefinition = "json") for JSON fields
- ENUM fields without proper MariaDB ENUM definition

## HIGH Priority Issues
- No charset specification for VARCHAR columns
- Missing @Index on JSON extraction paths
- UUID stored as VARCHAR instead of BINARY(16)
- Missing @Column collation for case-insensitive searches

## MEDIUM Priority Issues
- Not using MariaDB-specific data types optimally
- Missing @Check constraints (MariaDB 10.2+)
- No @Formula with MariaDB functions
- Missing AUTO_INCREMENT optimization

## LOW Priority Issues
- Not using MariaDB temporal data types
- Missing @ColumnTransformer for custom data handling
- No custom @Type for MariaDB-specific types
- Missing optimizer hints in @Formula

## TODO Templates

### Wrong ID generation for high volume
```java
// TODO: [CRITICAL] Consider TABLE generator for high insert volume
// Fix: GenerationType.TABLE for better performance with high concurrency
@Id
@GeneratedValue(strategy = GenerationType.TABLE, generator = "user_gen")
@TableGenerator(name = "user_gen", table = "id_generator", 
                pkColumnName = "gen_name", valueColumnName = "gen_val",
                pkColumnValue = "user_id", allocationSize = 50)
private Long id;
```

### String without length causing LONGTEXT
```java
// TODO: [CRITICAL] Specify column length to avoid LONGTEXT
// Fix: @Column(length = 255) creates VARCHAR instead of LONGTEXT
@Column(length = 255)
private String description;
```

### Missing JSON column type
```java
// TODO: [CRITICAL] Use JSON column type for MariaDB 10.2+
// Fix: @Column(columnDefinition = "json") for native JSON support
@Column(columnDefinition = "json")
private String preferences;
```

### ENUM without proper definition
```java
// TODO: [CRITICAL] Use MariaDB ENUM type or VARCHAR
// Fix: Define ENUM values or use VARCHAR with constraint
@Enumerated(EnumType.STRING)
@Column(columnDefinition = "enum('ACTIVE','INACTIVE','PENDING')")
private UserStatus status;
```

### Missing charset specification
```java
// TODO: [HIGH] Specify charset for VARCHAR columns
// Fix: @Column with charset specification
@Column(length = 255, columnDefinition = "varchar(255) character set utf8mb4 collate utf8mb4_unicode_ci")
private String name;
```

### Missing JSON index
```java
// TODO: [HIGH] Add index on JSON extraction paths
// Fix: @Index with MariaDB JSON path expression
@Table(indexes = {
    @Index(name = "idx_user_pref_theme", columnList = "preferences", 
           columnDefinition = "((json_extract(preferences, '$.theme')))")
})
```

### UUID as VARCHAR instead of BINARY
```java
// TODO: [HIGH] Use BINARY(16) for UUID storage efficiency
// Fix: @Column(columnDefinition = "binary(16)") for UUIDs
@Column(columnDefinition = "binary(16)", unique = true)
private UUID externalId;
```

### Missing collation for case-insensitive
```java
// TODO: [HIGH] Add collation for case-insensitive searches
// Fix: @Column with case-insensitive collation
@Column(length = 255, columnDefinition = "varchar(255) collate utf8mb4_unicode_ci")
private String email;
```

### Not using MariaDB temporal types
```java
// TODO: [MEDIUM] Use MariaDB temporal types optimally
// Fix: @Column with MariaDB-specific temporal types
@Column(columnDefinition = "datetime(6)")
private LocalDateTime createdAt;
```

### Missing @Check constraints
```java
// TODO: [MEDIUM] Add @Check constraints for MariaDB 10.2+
// Fix: @Check annotation for database-level validation
@Entity
@Check(constraints = "age >= 0 AND age <= 150")
public class User {
```

### Missing @Formula with MariaDB functions
```java
// TODO: [MEDIUM] Use @Formula with MariaDB functions
// Fix: @Formula with MariaDB-specific functions
@Formula("concat(first_name, ' ', last_name)")
private String fullName;
```

### Missing AUTO_INCREMENT optimization
```java
// TODO: [MEDIUM] Optimize AUTO_INCREMENT for bulk inserts
// Fix: @Column with AUTO_INCREMENT optimization
@Column(columnDefinition = "bigint auto_increment")
private Long id;
```

### Missing optimizer hints
```java
// TODO: [LOW] Add optimizer hints for complex formulas
// Fix: @Formula with MariaDB optimizer hints
@Formula("(select /*+ USE_INDEX(orders, idx_user_id) */ count(*) from orders where user_id = id)")
private Integer orderCount;
```

### Missing temporal data optimization
```java
// TODO: [LOW] Use MariaDB temporal data types optimally
// Fix: @Column with specific temporal precision
@Column(columnDefinition = "timestamp(3)")
private LocalDateTime lastLogin;
```

## MariaDB-Specific Entity Pattern

```java
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_pref_theme", columnList = "preferences", 
           columnDefinition = "((json_extract(preferences, '$.theme')))"),
    @Index(name = "idx_user_name_ft", columnList = "name", 
           columnDefinition = "fulltext")
})
@Check(constraints = "age >= 0 AND age <= 150")
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(columnDefinition = "binary(16)", unique = true)
    private UUID externalId;
    
    @Column(length = 255, columnDefinition = "varchar(255) character set utf8mb4 collate utf8mb4_unicode_ci")
    private String email;
    
    @Column(length = 100, columnDefinition = "varchar(100) character set utf8mb4 collate utf8mb4_unicode_ci")
    private String name;
    
    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "enum('ACTIVE','INACTIVE','PENDING')")
    private UserStatus status;
    
    @Column(columnDefinition = "json")
    private String preferences;
    
    @Formula("concat(first_name, ' ', last_name)")
    private String fullName;
    
    @Column(columnDefinition = "datetime(6)")
    private LocalDateTime createdAt;
    
    @Column(columnDefinition = "timestamp(3)")
    private LocalDateTime lastLogin;
    
    @Column(columnDefinition = "decimal(10,2)")
    private BigDecimal balance;
}
```

## MariaDB Performance Configurations

```java
// Table generator for high concurrency
@TableGenerator(
    name = "user_gen",
    table = "id_generator",
    pkColumnName = "gen_name",
    valueColumnName = "gen_val",
    pkColumnValue = "user_id",
    allocationSize = 50
)

// JSON column with index on extracted path
@Column(columnDefinition = "json")
private String metadata;

// UUID as BINARY(16) for storage efficiency
@Column(columnDefinition = "binary(16)")
private UUID uuid;

// VARCHAR with charset and collation
@Column(columnDefinition = "varchar(255) character set utf8mb4 collate utf8mb4_unicode_ci")
private String searchableText;

// Decimal with precision for financial data
@Column(columnDefinition = "decimal(19,4)")
private BigDecimal amount;

// Temporal with microsecond precision
@Column(columnDefinition = "datetime(6)")
private LocalDateTime timestamp;
```

## MariaDB Checklist
- [ ] GenerationType.IDENTITY or TABLE based on insert volume
- [ ] @Column(length = X) for VARCHAR instead of LONGTEXT
- [ ] @Column(columnDefinition = "json") for JSON data
- [ ] charset utf8mb4 for VARCHAR columns
- [ ] collate utf8mb4_unicode_ci for case-insensitive searches
- [ ] @Column(columnDefinition = "binary(16)") for UUIDs
- [ ] @Index on JSON extraction paths
- [ ] @Check constraints for MariaDB 10.2+
- [ ] @Formula with MariaDB-specific functions
- [ ] @Enumerated with MariaDB ENUM column definition
- [ ] Decimal precision for financial data
- [ ] Temporal precision for timestamps
- [ ] Fulltext indexes for search columns
- [ ] @TableGenerator for high concurrency scenarios
- [ ] Character set and collation specifications