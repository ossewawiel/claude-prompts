# MariaDB Integration Guide - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Dependencies (Spring Boot + Kotlin)
```kotlin
// build.gradle.kts
dependencies {
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.mariadb.jdbc:mariadb-java-client:3.3.2")
    implementation("com.zaxxer:HikariCP:5.0.1")
    implementation("org.flywaydb:flyway-core:9.22.3")
    implementation("org.flywaydb:flyway-mysql:9.22.3")
    
    // Optional: for JSON support
    implementation("com.vladmihalcea:hibernate-types-60:2.21.1")
}
```

### Configuration
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:mariadb://localhost:3306/${DB_NAME:myapp}?useUnicode=true&characterEncoding=utf8&useSSL=false&allowPublicKeyRetrieval=true
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:password}
    driver-class-name: org.mariadb.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 300000
      connection-timeout: 20000
      leak-detection-threshold: 60000

  jpa:
    database-platform: org.hibernate.dialect.MariaDBDialect
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        format_sql: true
        jdbc:
          time_zone: UTC
        temp:
          use_jdbc_metadata_defaults: false

  flyway:
    enabled: true
    baseline-on-migrate: true
    locations: classpath:db/migration
    table: flyway_schema_history
    mysql:
      transactional-lock: false
```

## IMPLEMENTATION STRATEGY

### Entity Configuration
```kotlin
// Base Entity
@MappedSuperclass
abstract class BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime? = null
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    val updatedAt: LocalDateTime? = null
}

// Domain Entity
@Entity
@Table(
    name = "users",
    indexes = [
        Index(name = "idx_users_email", columnList = "email_address"),
        Index(name = "idx_users_status", columnList = "status"),
        Index(name = "idx_users_name", columnList = "first_name,last_name")
    ]
)
class User : BaseEntity() {
    @Column(name = "first_name", nullable = false, length = 100)
    var firstName: String = ""
    
    @Column(name = "last_name", nullable = false, length = 100)
    var lastName: String = ""
    
    @Column(name = "email_address", nullable = false, unique = true, length = 255)
    var emailAddress: String = ""
    
    @Column(name = "is_active", nullable = false)
    var isActive: Boolean = true
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 50)
    var status: UserStatus = UserStatus.ACTIVE
    
    // JSON field support for MariaDB
    @Lob
    @Column(name = "preferences", columnDefinition = "JSON")
    var preferencesJson: String = "{}"
    
    // Transient property for object mapping
    @Transient
    var preferences: Map<String, Any>
        get() = ObjectMapper().readValue(preferencesJson, object : TypeReference<Map<String, Any>>() {})
        set(value) { preferencesJson = ObjectMapper().writeValueAsString(value) }
}

enum class UserStatus {
    ACTIVE, INACTIVE, SUSPENDED, PENDING_VERIFICATION
}
```

### Repository Layer
```kotlin
// Repository Interface
@Repository
interface UserRepository : JpaRepository<User, Long> {
    fun findByEmailAddress(emailAddress: String): Optional<User>
    fun findByIsActiveTrue(): List<User>
    fun findByStatus(status: UserStatus): List<User>
    
    @Query("SELECT u FROM User u WHERE u.firstName LIKE %:name% OR u.lastName LIKE %:name%")
    fun findByNameContainingIgnoreCase(@Param("name") name: String): List<User>
    
    @Query(
        value = "SELECT * FROM users WHERE JSON_EXTRACT(preferences, '$.theme') = :theme",
        nativeQuery = true
    )
    fun findByPreferenceTheme(@Param("theme") theme: String): List<User>
    
    @Query(
        value = "SELECT * FROM users WHERE JSON_CONTAINS(preferences, JSON_OBJECT('notifications', :enabled))",
        nativeQuery = true
    )
    fun findByNotificationPreference(@Param("enabled") enabled: Boolean): List<User>
    
    @Modifying
    @Query("UPDATE User u SET u.isActive = false WHERE u.id = :id")
    fun deactivateUser(@Param("id") id: Long): Int
    
    @Query(
        value = """
            SELECT u.*, COUNT(o.id) as order_count 
            FROM users u 
            LEFT JOIN orders o ON u.id = o.user_id 
            WHERE u.status = :status 
            GROUP BY u.id 
            HAVING COUNT(o.id) > :minOrders
        """,
        nativeQuery = true
    )
    fun findActiveUsersWithMinimumOrders(
        @Param("status") status: String,
        @Param("minOrders") minOrders: Int
    ): List<User>
}

// Custom Repository Implementation
@Repository
class UserRepositoryCustomImpl(
    @PersistenceContext private val entityManager: EntityManager
) : UserRepositoryCustom {
    
    override fun findUsersWithComplexCriteria(criteria: UserSearchCriteria): List<User> {
        val cb = entityManager.criteriaBuilder
        val query = cb.createQuery(User::class.java)
        val root = query.from(User::class.java)
        
        val predicates = mutableListOf<Predicate>()
        
        criteria.name?.let { name ->
            predicates.add(
                cb.or(
                    cb.like(cb.lower(root.get("firstName")), "%${name.lowercase()}%"),
                    cb.like(cb.lower(root.get("lastName")), "%${name.lowercase()}%")
                )
            )
        }
        
        criteria.status?.let { status ->
            predicates.add(cb.equal(root.get<UserStatus>("status"), status))
        }
        
        query.where(*predicates.toTypedArray())
        return entityManager.createQuery(query).resultList
    }
}
```

### Database Migrations (Flyway)
```sql
-- V1__Create_users_table.sql
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_address VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    preferences JSON DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indexes
CREATE INDEX idx_users_email_address ON users(email_address);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_name ON users(first_name, last_name);
CREATE INDEX idx_users_created_at ON users(created_at);

-- JSON indexes (MariaDB 10.3+)
ALTER TABLE users ADD INDEX idx_users_preferences_theme 
    ((CAST(JSON_EXTRACT(preferences, '$.theme') AS CHAR(50))));

-- Constraints
ALTER TABLE users ADD CONSTRAINT ck_users_email_format 
    CHECK (email_address REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$');

ALTER TABLE users ADD CONSTRAINT ck_users_status_valid 
    CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION'));

ALTER TABLE users ADD CONSTRAINT ck_users_preferences_valid 
    CHECK (JSON_VALID(preferences));
```

### Service Layer with Transactions
```kotlin
@Service
@Transactional
class UserService(
    private val userRepository: UserRepository,
    private val emailService: EmailService
) {
    
    @Transactional(readOnly = true)
    fun findById(id: Long): User {
        return userRepository.findById(id)
            .orElseThrow { UserNotFoundException("User with id $id not found") }
    }
    
    @Transactional(readOnly = true)
    fun findByEmail(emailAddress: String): User? {
        return userRepository.findByEmailAddress(emailAddress).orElse(null)
    }
    
    fun createUser(userDto: UserCreateDto): User {
        // Validate email uniqueness
        userRepository.findByEmailAddress(userDto.emailAddress)
            .ifPresent { throw DuplicateEmailException("Email already exists: ${userDto.emailAddress}") }
        
        val user = User().apply {
            firstName = userDto.firstName
            lastName = userDto.lastName
            emailAddress = userDto.emailAddress
            status = UserStatus.PENDING_VERIFICATION
            preferences = userDto.preferences ?: emptyMap()
        }
        
        val savedUser = userRepository.save(user)
        
        // Send welcome email (separate transaction)
        emailService.sendWelcomeEmail(savedUser.emailAddress)
        
        return savedUser
    }
    
    fun updateUserPreferences(id: Long, preferences: Map<String, Any>): User {
        val user = findById(id)
        user.preferences = preferences
        return userRepository.save(user)
    }
    
    @Transactional(readOnly = true)
    fun findUsersByThemePreference(theme: String): List<User> {
        return userRepository.findByPreferenceTheme(theme)
    }
    
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    fun deactivateUser(id: Long) {
        val rowsUpdated = userRepository.deactivateUser(id)
        if (rowsUpdated == 0) {
            throw UserNotFoundException("User with id $id not found")
        }
    }
}
```

### Connection Pool Optimization
```kotlin
@Configuration
class DatabaseConfiguration {
    
    @Bean
    @ConfigurationProperties("spring.datasource.hikari")
    fun hikariConfig(): HikariConfig {
        return HikariConfig().apply {
            // Pool sizing
            maximumPoolSize = 20
            minimumIdle = 5
            
            // Connection timeouts
            connectionTimeout = 20000  // 20 seconds
            idleTimeout = 300000      // 5 minutes
            maxLifetime = 1800000     // 30 minutes
            leakDetectionThreshold = 60000 // 1 minute
            
            // MariaDB specific optimizations
            addDataSourceProperty("cachePrepStmts", "true")
            addDataSourceProperty("prepStmtCacheSize", "250")
            addDataSourceProperty("prepStmtCacheSqlLimit", "2048")
            addDataSourceProperty("useServerPrepStmts", "true")
            addDataSourceProperty("rewriteBatchedStatements", "true")
            addDataSourceProperty("cacheResultSetMetadata", "true")
            addDataSourceProperty("cacheServerConfiguration", "true")
            addDataSourceProperty("useLocalSessionState", "true")
            addDataSourceProperty("maintainTimeStats", "false")
            addDataSourceProperty("useUnicode", "true")
            addDataSourceProperty("characterEncoding", "utf8mb4")
        }
    }
    
    @Bean
    fun transactionManager(entityManagerFactory: EntityManagerFactory): PlatformTransactionManager {
        return JpaTransactionManager(entityManagerFactory)
    }
}
```

### JSON Field Utilities
```kotlin
// JSON Converter for easier handling
@Component
class JsonConverter {
    private val objectMapper = ObjectMapper().apply {
        configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false)
        configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, false)
    }
    
    fun <T> toJson(obj: T): String = objectMapper.writeValueAsString(obj)
    
    fun <T> fromJson(json: String, clazz: Class<T>): T = objectMapper.readValue(json, clazz)
    
    fun <T> fromJson(json: String, typeRef: TypeReference<T>): T = objectMapper.readValue(json, typeRef)
}

// Custom JPA Attribute Converter for Maps
@Converter
class MapToJsonConverter : AttributeConverter<Map<String, Any>, String> {
    private val objectMapper = ObjectMapper()
    
    override fun convertToDatabaseColumn(attribute: Map<String, Any>?): String {
        return attribute?.let { objectMapper.writeValueAsString(it) } ?: "{}"
    }
    
    override fun convertToEntityAttribute(dbData: String?): Map<String, Any> {
        return dbData?.let { 
            objectMapper.readValue(it, object : TypeReference<Map<String, Any>>() {})
        } ?: emptyMap()
    }
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Start MariaDB with Docker
docker run --name mariadb-dev -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=myapp -p 3306:3306 -d mariadb:10.11

# Connect to MariaDB
mysql -h localhost -u root -p myapp

# Run Flyway migrations
mvn flyway:migrate

# Check MariaDB version and features
SELECT VERSION(), @@sql_mode;

# Run application with MariaDB profile
mvn spring-boot:run -Dspring-boot.run.profiles=mariadb
```

## VALIDATION_CHECKLIST
- [ ] MariaDB driver dependency added
- [ ] HikariCP connection pool configured
- [ ] Flyway migrations setup with MySQL compatibility
- [ ] Entities use appropriate MariaDB types
- [ ] Indexes created for frequently queried columns
- [ ] JSON support configured properly
- [ ] Connection pool settings optimized for MariaDB
- [ ] Transaction boundaries properly defined
- [ ] Database constraints implemented
- [ ] UTF8MB4 charset configured for emoji support