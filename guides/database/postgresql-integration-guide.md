# PostgreSQL Integration Guide - Claude Code Instructions

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
    implementation("org.postgresql:postgresql:42.7.1")
    implementation("com.zaxxer:HikariCP:5.0.1")
    implementation("org.flywaydb:flyway-core:9.22.3")
    
    // Optional: for JSON support
    implementation("com.vladmihalcea:hibernate-types-60:2.21.1")
}
```

### Configuration
```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/${DB_NAME:myapp}
    username: ${DB_USERNAME:postgres}
    password: ${DB_PASSWORD:password}
    driver-class-name: org.postgresql.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 300000
      connection-timeout: 20000
      leak-detection-threshold: 60000

  jpa:
    database-platform: org.hibernate.dialect.PostgreSQLDialect
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
@Table(name = "users")
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
    
    // JSON field support
    @Type(JsonType::class)
    @Column(name = "preferences", columnDefinition = "jsonb")
    var preferences: Map<String, Any> = emptyMap()
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
    
    @Query("SELECT u FROM User u WHERE u.firstName ILIKE %:name% OR u.lastName ILIKE %:name%")
    fun findByNameContainingIgnoreCase(@Param("name") name: String): List<User>
    
    @Query(
        value = "SELECT * FROM users WHERE preferences @> :preferences::jsonb",
        nativeQuery = true
    )
    fun findByPreferences(@Param("preferences") preferences: String): List<User>
    
    @Modifying
    @Query("UPDATE User u SET u.isActive = false WHERE u.id = :id")
    fun deactivateUser(@Param("id") id: Long): Int
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
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_address VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_users_email_address ON users(email_address);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_name ON users(first_name, last_name);
CREATE INDEX idx_users_preferences ON users USING GIN(preferences);

-- Constraints
ALTER TABLE users ADD CONSTRAINT ck_users_email_format 
    CHECK (email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

ALTER TABLE users ADD CONSTRAINT ck_users_status_valid 
    CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'PENDING_VERIFICATION'));

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
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
            
            // PostgreSQL specific optimizations
            addDataSourceProperty("cachePrepStmts", "true")
            addDataSourceProperty("prepStmtCacheSize", "250")
            addDataSourceProperty("prepStmtCacheSqlLimit", "2048")
            addDataSourceProperty("useServerPrepStmts", "true")
            addDataSourceProperty("useLocalSessionState", "true")
            addDataSourceProperty("rewriteBatchedStatements", "true")
            addDataSourceProperty("cacheResultSetMetadata", "true")
            addDataSourceProperty("cacheServerConfiguration", "true")
            addDataSourceProperty("elideSetAutoCommits", "true")
            addDataSourceProperty("maintainTimeStats", "false")
        }
    }
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Start PostgreSQL with Docker
docker run --name postgres-dev -e POSTGRES_PASSWORD=password -e POSTGRES_DB=myapp -p 5432:5432 -d postgres:15

# Connect to PostgreSQL
psql -h localhost -U postgres -d myapp

# Run Flyway migrations
mvn flyway:migrate

# Generate JPA entities from existing database
mvn hibernate3:hbm2java

# Run application with PostgreSQL profile
mvn spring-boot:run -Dspring-boot.run.profiles=postgresql
```

## VALIDATION_CHECKLIST
- [ ] PostgreSQL driver dependency added
- [ ] HikariCP connection pool configured
- [ ] Flyway migrations setup
- [ ] Entities use appropriate PostgreSQL types
- [ ] Indexes created for frequently queried columns
- [ ] JSONB support configured for JSON fields
- [ ] Connection pool settings optimized
- [ ] Transaction boundaries properly defined
- [ ] Database constraints implemented
- [ ] Audit fields (created_at, updated_at) included