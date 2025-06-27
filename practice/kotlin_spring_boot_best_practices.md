# Kotlin Spring Boot Project Structure and Architecture Best Practices

## Document Information
- **Document Type**: Best Practices Guide
- **Last Updated**: June 26, 2025
- **Document Version**: 1.0.0
- **Scope**: Project Structure, Naming Conventions, Architecture (Kotlin-specific)
- **Build Tools**: Maven & Gradle
- **Target**: Claude Code analysis and validation

## Table of Contents
1. [Project Structure](#project-structure)
2. [Naming Conventions](#naming-conventions)
3. [Package Organization](#package-organization)
4. [Configuration Management](#configuration-management)
5. [Build Tool Specifics](#build-tool-specifics)
6. [Architecture Patterns](#architecture-patterns)
7. [Resource Organization](#resource-organization)
8. [Testing Structure](#testing-structure)
9. [Kotlin-Specific Best Practices](#kotlin-specific-best-practices)
10. [External References](#external-references)

## Project Structure

### Standard Maven/Gradle Project Layout

```
project-root/
├── src/
│   ├── main/
│   │   ├── kotlin/
│   │   │   └── com/company/application/
│   │   │       ├── Application.kt                    # Main application class
│   │   │       ├── config/                           # Configuration classes
│   │   │       │   ├── SecurityConfig.kt
│   │   │       │   ├── DatabaseConfig.kt
│   │   │       │   ├── CacheConfig.kt
│   │   │       │   ├── WebConfig.kt
│   │   │       │   └── JacksonConfig.kt
│   │   │       ├── controller/                       # REST controllers
│   │   │       │   ├── UserController.kt
│   │   │       │   ├── ProductController.kt
│   │   │       │   └── AuthController.kt
│   │   │       ├── service/                          # Business logic
│   │   │       │   ├── UserService.kt
│   │   │       │   ├── ProductService.kt
│   │   │       │   ├── impl/                         # Service implementations
│   │   │       │   │   ├── UserServiceImpl.kt
│   │   │       │   │   └── ProductServiceImpl.kt
│   │   │       │   └── dto/                          # Data Transfer Objects
│   │   │       │       ├── UserDto.kt
│   │   │       │       ├── CreateUserRequest.kt
│   │   │       │       ├── UpdateUserRequest.kt
│   │   │       │       └── ApiResponse.kt
│   │   │       ├── repository/                       # Data access layer
│   │   │       │   ├── UserRepository.kt
│   │   │       │   ├── ProductRepository.kt
│   │   │       │   └── custom/                       # Custom repository implementations
│   │   │       │       ├── UserRepositoryCustom.kt
│   │   │       │       └── UserRepositoryCustomImpl.kt
│   │   │       ├── domain/                           # Domain entities and models
│   │   │       │   ├── entity/                       # JPA entities
│   │   │       │   │   ├── BaseEntity.kt
│   │   │       │   │   ├── User.kt
│   │   │       │   │   ├── Product.kt
│   │   │       │   │   └── AuditEntity.kt
│   │   │       │   ├── model/                        # Domain models (non-JPA)
│   │   │       │   │   ├── UserProfile.kt
│   │   │       │   │   └── ProductCatalog.kt
│   │   │       │   └── enums/                        # Domain enumerations
│   │   │       │       ├── UserStatus.kt
│   │   │       │       ├── ProductCategory.kt
│   │   │       │       └── OrderStatus.kt
│   │   │       ├── exception/                        # Custom exceptions
│   │   │       │   ├── GlobalExceptionHandler.kt
│   │   │       │   ├── UserNotFoundException.kt
│   │   │       │   ├── ValidationException.kt
│   │   │       │   └── BusinessLogicException.kt
│   │   │       ├── security/                         # Security components
│   │   │       │   ├── JwtAuthenticationFilter.kt
│   │   │       │   ├── CustomUserDetailsService.kt
│   │   │       │   ├── JwtTokenProvider.kt
│   │   │       │   └── SecurityUtils.kt
│   │   │       ├── util/                             # Utility classes
│   │   │       │   ├── DateUtils.kt
│   │   │       │   ├── ValidationUtils.kt
│   │   │       │   ├── StringExtensions.kt
│   │   │       │   └── CollectionExtensions.kt
│   │   │       ├── constant/                         # Application constants
│   │   │       │   ├── AppConstants.kt
│   │   │       │   ├── SecurityConstants.kt
│   │   │       │   └── CacheConstants.kt
│   │   │       └── mapper/                           # Entity-DTO mappers
│   │   │           ├── UserMapper.kt
│   │   │           ├── ProductMapper.kt
│   │   │           └── BaseMapper.kt
│   │   └── resources/
│   │       ├── application.yml                       # Main configuration
│   │       ├── application-dev.yml                   # Development profile
│   │       ├── application-prod.yml                  # Production profile
│   │       ├── application-test.yml                  # Test profile
│   │       ├── db/migration/                         # Database migrations (Flyway)
│   │       │   ├── V1__Create_users_table.sql
│   │       │   ├── V2__Create_products_table.sql
│   │       │   ├── V3__Add_user_audit_columns.sql
│   │       │   └── R__Create_reporting_views.sql
│   │       ├── static/                               # Static web assets
│   │       │   ├── css/
│   │       │   ├── js/
│   │       │   └── images/
│   │       ├── templates/                            # Template files
│   │       │   ├── email/
│   │       │   │   ├── welcome.html
│   │       │   │   └── password-reset.html
│   │       │   └── error/
│   │       │       ├── 404.html
│   │       │       └── 500.html
│   │       └── messages/                             # Internationalization
│   │           ├── messages.properties
│   │           ├── messages_en.properties
│   │           └── messages_es.properties
│   └── test/
│       ├── kotlin/
│       │   └── com/company/application/
│       │       ├── controller/                       # Controller tests
│       │       │   ├── UserControllerTest.kt
│       │       │   └── ProductControllerTest.kt
│       │       ├── service/                          # Service tests
│       │       │   ├── UserServiceTest.kt
│       │       │   └── ProductServiceTest.kt
│       │       ├── repository/                       # Repository tests
│       │       │   ├── UserRepositoryTest.kt
│       │       │   └── ProductRepositoryTest.kt
│       │       ├── integration/                      # Integration tests
│       │       │   ├── UserIntegrationTest.kt
│       │       │   ├── DatabaseIntegrationTest.kt
│       │       │   └── SecurityIntegrationTest.kt
│       │       ├── util/                             # Utility tests
│       │       │   ├── DateUtilsTest.kt
│       │       │   └── ValidationUtilsTest.kt
│       │       └── TestApplication.kt                # Test configuration
│       └── resources/
│           ├── application-test.yml                  # Test configuration
│           ├── test-data/                            # Test data files
│           │   ├── users.json
│           │   └── products.json
│           └── logback-test.xml                      # Test logging config
├── docs/                                             # Project documentation
│   ├── api/                                          # API documentation
│   ├── architecture/                                 # Architecture diagrams
│   ├── deployment/                                   # Deployment guides
│   └── development/                                  # Development setup
├── scripts/                                          # Build and deployment scripts
│   ├── build.sh
│   ├── deploy.sh
│   └── database/
│       ├── init.sql
│       └── cleanup.sql
├── docker/                                           # Docker configurations
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── docker-compose.override.yml
├── build.gradle.kts / pom.xml                       # Build configuration
├── gradle/wrapper/ or .mvn/wrapper/                 # Wrapper files
├── gradlew / mvnw                                   # Wrapper scripts
├── .gitignore                                       # Git ignore rules
├── README.md                                        # Project overview
├── CHANGELOG.md                                     # Version history
└── CONTRIBUTING.md                                  # Contribution guidelines
```

## Naming Conventions

### Package Names
- **Format**: All lowercase, separated by dots
- **Pattern**: `com.company.application.module`
- **Examples**:
  - `com.company.userservice.domain.entity`
  - `com.company.orderservice.service.impl`
  - `com.company.paymentservice.controller`

### Class Names (Kotlin-specific)
```kotlin
// Classes: PascalCase
class UserService
class DatabaseConfiguration
class PaymentProcessor

// Data classes: PascalCase
data class User(val id: Long, val name: String)
data class CreateUserRequest(val name: String, val email: String)
data class ApiResponse<T>(val data: T, val success: Boolean, val message: String?)

// Sealed classes: PascalCase
sealed class Result<out T>
data class Success<T>(val data: T) : Result<T>()
data class Error(val exception: Throwable) : Result<Nothing>()

// Object declarations: PascalCase
object DatabaseConstants
object SecurityUtils

// Companion objects: use class name context
class UserService {
    companion object {
        const val DEFAULT_PAGE_SIZE = 20
        const val MAX_USERS_PER_REQUEST = 100
    }
}
```

### Function Names
```kotlin
// Functions: camelCase
fun createUser(request: CreateUserRequest): User
fun findUserById(id: Long): User?
fun validateEmailAddress(email: String): Boolean
fun calculateOrderTotal(items: List<OrderItem>): BigDecimal

// Boolean functions: descriptive names
fun isValidEmail(email: String): Boolean
fun hasPermission(user: User, permission: Permission): Boolean
fun canAccessResource(user: User, resource: Resource): Boolean

// Extension functions: camelCase
fun String.isValidEmail(): Boolean
fun List<User>.findByStatus(status: UserStatus): List<User>
fun LocalDateTime.toFormattedString(): String
```

### Property Names
```kotlin
// Properties: camelCase
val firstName: String
val lastName: String
val createdAt: LocalDateTime
var isActive: Boolean

// Boolean properties: descriptive prefixes
val isValid: Boolean
val hasPermissions: Boolean
val canEdit: Boolean
val shouldNotify: Boolean

// Private properties: leading underscore optional, prefer private modifier
private val userRepository: UserRepository
private val _cache = mutableMapOf<String, Any>()
```

### Constants
```kotlin
// Constants: SCREAMING_SNAKE_CASE
const val MAX_RETRY_COUNT = 3
const val DEFAULT_TIMEOUT_SECONDS = 30
const val API_VERSION = "v1"

// In companion objects
class ApiController {
    companion object {
        const val BASE_PATH = "/api/v1"
        const val MAX_PAGE_SIZE = 100
        const val DEFAULT_PAGE_SIZE = 20
    }
}

// In object declarations
object CacheConstants {
    const val USER_CACHE = "users"
    const val PRODUCT_CACHE = "products"
    const val DEFAULT_TTL = 3600L
}
```

### Enum Classes
```kotlin
// Enum class: PascalCase, values: SCREAMING_SNAKE_CASE
enum class UserStatus {
    ACTIVE,
    INACTIVE,
    SUSPENDED,
    PENDING_VERIFICATION;
    
    fun isActive() = this == ACTIVE
}

enum class OrderStatus(val displayName: String) {
    PENDING("Pending"),
    PROCESSING("Processing"),
    SHIPPED("Shipped"),
    DELIVERED("Delivered"),
    CANCELLED("Cancelled")
}
```

### File Names
- **Kotlin files**: PascalCase matching primary class name
- **Examples**:
  - `UserService.kt` (contains class UserService)
  - `UserRepository.kt` (contains interface UserRepository)
  - `StringExtensions.kt` (contains String extension functions)
  - `ApplicationConstants.kt` (contains object ApplicationConstants)

## Package Organization

### Domain-Driven Organization
```
com.company.application/
├── domain/                    # Core domain logic
│   ├── entity/               # JPA entities
│   ├── model/                # Domain models (non-JPA)
│   ├── enums/                # Domain enumerations
│   └── repository/           # Repository interfaces
├── application/              # Application services
│   ├── service/              # Business logic services
│   ├── dto/                  # Data transfer objects
│   └── mapper/               # Entity-DTO mappers
├── infrastructure/           # Infrastructure concerns
│   ├── persistence/          # Database implementations
│   ├── external/             # External service clients
│   └── messaging/            # Message queue handling
└── presentation/             # Presentation layer
    ├── controller/           # REST controllers
    ├── security/             # Security configurations
    └── exception/            # Exception handlers
```

### Feature-Based Organization (Alternative)
```
com.company.application/
├── user/                     # User feature
│   ├── UserController.kt
│   ├── UserService.kt
│   ├── UserRepository.kt
│   ├── User.kt
│   └── UserDto.kt
├── product/                  # Product feature
│   ├── ProductController.kt
│   ├── ProductService.kt
│   ├── ProductRepository.kt
│   ├── Product.kt
│   └── ProductDto.kt
├── order/                    # Order feature
│   └── ... (similar structure)
├── config/                   # Shared configurations
├── security/                 # Shared security components
└── util/                     # Shared utilities
```

## Configuration Management

### Application Configuration Files
```yaml
# application.yml (main configuration)
server:
  port: 8080
  servlet:
    context-path: /api

spring:
  application:
    name: user-service
  profiles:
    active: dev
  datasource:
    url: jdbc:postgresql://localhost:5432/userdb
    username: ${DB_USERNAME:user}
    password: ${DB_PASSWORD:password}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true

logging:
  level:
    com.company.application: INFO
    org.springframework.security: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
```

### Configuration Classes
```kotlin
@Configuration
@ConfigurationProperties(prefix = "app")
data class ApplicationProperties(
    val security: SecurityProperties = SecurityProperties(),
    val cache: CacheProperties = CacheProperties(),
    val external: ExternalServiceProperties = ExternalServiceProperties()
) {
    data class SecurityProperties(
        val jwtSecret: String = "default-secret",
        val jwtExpirationMs: Long = 86400000, // 24 hours
        val allowedOrigins: List<String> = listOf("http://localhost:3000")
    )
    
    data class CacheProperties(
        val ttl: Duration = Duration.ofHours(1),
        val maxSize: Long = 1000
    )
    
    data class ExternalServiceProperties(
        val userServiceUrl: String = "http://localhost:8081",
        val timeout: Duration = Duration.ofSeconds(30)
    )
}
```

## Build Tool Specifics

### Gradle Configuration (build.gradle.kts)
```kotlin
plugins {
    id("org.springframework.boot") version "3.3.0"
    id("io.spring.dependency-management") version "1.1.5"
    kotlin("jvm") version "2.0.0"
    kotlin("plugin.spring") version "2.0.0"
    kotlin("plugin.jpa") version "2.0.0"
    kotlin("plugin.allopen") version "2.0.0"
    kotlin("plugin.noarg") version "2.0.0"
    id("org.jlleitschuh.gradle.ktlint") version "12.1.1"
    id("io.gitlab.arturbosch.detekt") version "1.23.6"
    id("org.sonarqube") version "5.0.0.4638"
    id("jacoco")
}

group = "com.company"
version = "1.0.0"

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

kotlin {
    jvmToolchain(21)
}

allOpen {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}

noArg {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}

dependencies {
    // Spring Boot starters
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-cache")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    
    // Kotlin specific
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    
    // Database
    implementation("org.postgresql:postgresql")
    implementation("org.flywaydb:flyway-core")
    implementation("org.flywaydb:flyway-database-postgresql")
    
    // Redis cache
    implementation("org.springframework.boot:spring-boot-starter-data-redis")
    
    // JWT
    implementation("io.jsonwebtoken:jjwt-api:0.12.5")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.5")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.5")
    
    // Documentation
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.5.0")
    
    // Monitoring
    implementation("io.micrometer:micrometer-registry-prometheus")
    
    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.security:spring-security-test")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:postgresql")
    testImplementation("io.mockk:mockk:1.13.11")
    testImplementation("com.ninja-squad:springmockk:4.0.2")
}

tasks.withType<KotlinCompile> {
    kotlinOptions {
        freeCompilerArgs += "-Xjsr305=strict"
        jvmTarget = "21"
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
    finalizedBy(tasks.jacocoTestReport)
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
        xml.required = true
        html.required = true
    }
}

ktlint {
    version.set("1.3.0")
    debug.set(false)
    verbose.set(true)
    android.set(false)
    outputToConsole.set(true)
    outputColorName.set("RED")
    ignoreFailures.set(false)
}

detekt {
    toolVersion = "1.23.6"
    config.setFrom("$projectDir/config/detekt/detekt.yml")
    buildUponDefaultConfig = true
}
```

### Maven Configuration (pom.xml)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.3.0</version>
        <relativePath/>
    </parent>

    <groupId>com.company</groupId>
    <artifactId>user-service</artifactId>
    <version>1.0.0</version>
    <name>user-service</name>
    <description>User Management Service</description>

    <properties>
        <java.version>21</java.version>
        <kotlin.version>2.0.0</kotlin.version>
        <kotlin.code.style>official</kotlin.code.style>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- Spring Boot Dependencies -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        
        <!-- Kotlin Dependencies -->
        <dependency>
            <groupId>com.fasterxml.jackson.module</groupId>
            <artifactId>jackson-module-kotlin</artifactId>
        </dependency>
        <dependency>
            <groupId>org.jetbrains.kotlin</groupId>
            <artifactId>kotlin-reflect</artifactId>
        </dependency>
        <dependency>
            <groupId>org.jetbrains.kotlin</groupId>
            <artifactId>kotlin-stdlib</artifactId>
        </dependency>
        
        <!-- Database -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        
        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>io.mockk</groupId>
            <artifactId>mockk-jvm</artifactId>
            <version>1.13.11</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <sourceDirectory>${project.basedir}/src/main/kotlin</sourceDirectory>
        <testSourceDirectory>${project.basedir}/src/test/kotlin</testSourceDirectory>
        
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
            <plugin>
                <groupId>org.jetbrains.kotlin</groupId>
                <artifactId>kotlin-maven-plugin</artifactId>
                <configuration>
                    <args>
                        <arg>-Xjsr305=strict</arg>
                    </args>
                    <compilerPlugins>
                        <plugin>spring</plugin>
                        <plugin>jpa</plugin>
                        <plugin>all-open</plugin>
                        <plugin>no-arg</plugin>
                    </compilerPlugins>
                    <pluginOptions>
                        <option>all-open:annotation=jakarta.persistence.Entity</option>
                        <option>all-open:annotation=jakarta.persistence.MappedSuperclass</option>
                        <option>all-open:annotation=jakarta.persistence.Embeddable</option>
                    </pluginOptions>
                </configuration>
                <dependencies>
                    <dependency>
                        <groupId>org.jetbrains.kotlin</groupId>
                        <artifactId>kotlin-maven-allopen</artifactId>
                        <version>${kotlin.version}</version>
                    </dependency>
                    <dependency>
                        <groupId>org.jetbrains.kotlin</groupId>
                        <artifactId>kotlin-maven-noarg</artifactId>
                        <version>${kotlin.version}</version>
                    </dependency>
                </dependencies>
            </plugin>
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.11</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

## Architecture Patterns

### Layered Architecture
```kotlin
// 1. Presentation Layer (Controllers)
@RestController
@RequestMapping("/api/v1/users")
class UserController(
    private val userService: UserService
) {
    @GetMapping("/{id}")
    fun getUser(@PathVariable id: Long): ResponseEntity<UserDto> {
        val user = userService.findById(id)
        return ResponseEntity.ok(user)
    }
}

// 2. Application Layer (Services)
@Service
@Transactional
class UserService(
    private val userRepository: UserRepository,
    private val userMapper: UserMapper
) {
    fun findById(id: Long): UserDto {
        val user = userRepository.findById(id)
            ?: throw UserNotFoundException("User with id $id not found")
        return userMapper.toDto(user)
    }
}

// 3. Domain Layer (Entities)
@Entity
@Table(name = "users")
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,
    
    @Column(nullable = false)
    val firstName: String,
    
    @Column(nullable = false)
    val lastName: String,
    
    @Column(unique = true, nullable = false)
    val email: String,
    
    @Enumerated(EnumType.STRING)
    val status: UserStatus = UserStatus.ACTIVE
) : BaseEntity()

// 4. Infrastructure Layer (Repositories)
@Repository
interface UserRepository : JpaRepository<User, Long> {
    fun findByEmail(email: String): User?
    fun findByStatus(status: UserStatus): List<User>
}
```

### Domain-Driven Design Patterns
```kotlin
// Value Objects
@Embeddable
data class Address(
    val street: String,
    val city: String,
    val zipCode: String,
    val country: String
) {
    init {
        require(street.isNotBlank()) { "Street cannot be blank" }
        require(city.isNotBlank()) { "City cannot be blank" }
        require(zipCode.matches(Regex("\\d{5}"))) { "Invalid zip code format" }
    }
}

// Domain Services
@Service
class UserDomainService {
    fun canUserAccessResource(user: User, resource: Resource): Boolean {
        return when (user.status) {
            UserStatus.ACTIVE -> user.hasPermissionFor(resource)
            UserStatus.SUSPENDED -> false
            UserStatus.INACTIVE -> false
            UserStatus.PENDING_VERIFICATION -> resource.isPublic
        }
    }
}

// Repository Pattern with Custom Implementation
interface UserRepositoryCustom {
    fun findUsersWithComplexCriteria(criteria: UserSearchCriteria): List<User>
}

@Repository
class UserRepositoryCustomImpl(
    private val entityManager: EntityManager
) : UserRepositoryCustom {
    override fun findUsersWithComplexCriteria(criteria: UserSearchCriteria): List<User> {
        val cb = entityManager.criteriaBuilder
        val cq = cb.createQuery(User::class.java)
        val root = cq.from(User::class.java)
        
        val predicates = mutableListOf<Predicate>()
        
        criteria.name?.let { name ->
            predicates.add(cb.like(cb.lower(root.get("firstName")), "%${name.lowercase()}%"))
        }
        
        criteria.status?.let { status ->
            predicates.add(cb.equal(root.get<UserStatus>("status"), status))
        }
        
        if (predicates.isNotEmpty()) {
            cq.where(cb.and(*predicates.toTypedArray()))
        }
        
        return entityManager.createQuery(cq).resultList
    }
}
```

## Resource Organization

### Database Migrations (Flyway)
```sql
-- V1__Create_users_table.sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    version BIGINT DEFAULT 0
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);

-- V2__Create_user_roles_table.sql
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

INSERT INTO roles (name, description) VALUES 
('ADMIN', 'Administrator with full access'),
('USER', 'Regular user with limited access'),
('MODERATOR', 'Moderator with content management access');
```

### Configuration Properties
```yaml
# application-dev.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/userdb_dev
    username: dev_user
    password: dev_password
  jpa:
    show-sql: true
    properties:
      hibernate:
        format_sql: true
  h2:
    console:
      enabled: true

logging:
  level:
    com.company.application: DEBUG
    org.springframework.web: DEBUG
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE

# application-prod.yml
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
  jpa:
    show-sql: false
    hibernate:
      ddl-auto: none

logging:
  level:
    com.company.application: INFO
    org.springframework.security: WARN
  file:
    name: /var/log/application.log

management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus
```

## Testing Structure

### Unit Tests
```kotlin
@ExtendWith(MockKExtension::class)
class UserServiceTest {
    
    @MockK
    private lateinit var userRepository: UserRepository
    
    @MockK
    private lateinit var userMapper: UserMapper
    
    @InjectMockKs
    private lateinit var userService: UserService
    
    @Test
    fun `should return user when valid id provided`() {
        // Given
        val userId = 1L
        val user = createTestUser(id = userId)
        val userDto = createTestUserDto(id = userId)
        
        every { userRepository.findById(userId) } returns user
        every { userMapper.toDto(user) } returns userDto
        
        // When
        val result = userService.findById(userId)
        
        // Then
        result shouldBe userDto
        verify { userRepository.findById(userId) }
        verify { userMapper.toDto(user) }
    }
    
    @Test
    fun `should throw exception when user not found`() {
        // Given
        val userId = 999L
        every { userRepository.findById(userId) } returns null
        
        // When & Then
        val exception = shouldThrow<UserNotFoundException> {
            userService.findById(userId)
        }
        
        exception.message shouldBe "User with id $userId not found"
    }
    
    private fun createTestUser(
        id: Long = 1L,
        firstName: String = "John",
        lastName: String = "Doe",
        email: String = "john.doe@example.com"
    ) = User(
        id = id,
        firstName = firstName,
        lastName = lastName,
        email = email
    )
    
    private fun createTestUserDto(
        id: Long = 1L,
        firstName: String = "John",
        lastName: String = "Doe",
        email: String = "john.doe@example.com"
    ) = UserDto(
        id = id,
        firstName = firstName,
        lastName = lastName,
        email = email
    )
}
```

### Integration Tests
```kotlin
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class UserRepositoryIntegrationTest {
    
    companion object {
        @Container
        @JvmStatic
        val postgresql: PostgreSQLContainer<*> = PostgreSQLContainer("postgres:16")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test")
    }
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Autowired
    private lateinit var testEntityManager: TestEntityManager
    
    @Test
    @Transactional
    @Rollback
    fun `should find user by email`() {
        // Given
        val user = User(
            firstName = "Jane",
            lastName = "Smith",
            email = "jane.smith@example.com"
        )
        testEntityManager.persistAndFlush(user)
        
        // When
        val foundUser = userRepository.findByEmail("jane.smith@example.com")
        
        // Then
        foundUser shouldNotBe null
        foundUser?.firstName shouldBe "Jane"
        foundUser?.lastName shouldBe "Smith"
    }
    
    @Test
    @Transactional
    @Rollback
    fun `should find users by status`() {
        // Given
        val activeUser = User(
            firstName = "Active",
            lastName = "User",
            email = "active@example.com",
            status = UserStatus.ACTIVE
        )
        val inactiveUser = User(
            firstName = "Inactive",
            lastName = "User",
            email = "inactive@example.com",
            status = UserStatus.INACTIVE
        )
        
        testEntityManager.persistAndFlush(activeUser)
        testEntityManager.persistAndFlush(inactiveUser)
        
        // When
        val activeUsers = userRepository.findByStatus(UserStatus.ACTIVE)
        
        // Then
        activeUsers.size shouldBe 1
        activeUsers.first().status shouldBe UserStatus.ACTIVE
    }
    
    @DynamicPropertySource
    companion object {
        @JvmStatic
        fun configureProperties(registry: DynamicPropertyRegistry) {
            registry.add("spring.datasource.url", postgresql::getJdbcUrl)
            registry.add("spring.datasource.username", postgresql::getUsername)
            registry.add("spring.datasource.password", postgresql::getPassword)
        }
    }
}
```

### Controller Tests
```kotlin
@WebMvcTest(UserController::class)
class UserControllerTest {
    
    @Autowired
    private lateinit var mockMvc: MockMvc
    
    @MockkBean
    private lateinit var userService: UserService
    
    @Test
    fun `should return user when valid id provided`() {
        // Given
        val userId = 1L
        val userDto = UserDto(
            id = userId,
            firstName = "John",
            lastName = "Doe",
            email = "john.doe@example.com"
        )
        
        every { userService.findById(userId) } returns userDto
        
        // When & Then
        mockMvc.perform(get("/api/v1/users/$userId"))
            .andExpect(status().isOk)
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.id").value(userId))
            .andExpect(jsonPath("$.firstName").value("John"))
            .andExpect(jsonPath("$.lastName").value("Doe"))
            .andExpect(jsonPath("$.email").value("john.doe@example.com"))
        
        verify { userService.findById(userId) }
    }
    
    @Test
    fun `should return 404 when user not found`() {
        // Given
        val userId = 999L
        every { userService.findById(userId) } throws UserNotFoundException("User not found")
        
        // When & Then
        mockMvc.perform(get("/api/v1/users/$userId"))
            .andExpect(status().isNotFound)
        
        verify { userService.findById(userId) }
    }
}
```

## Kotlin-Specific Best Practices

### Data Classes and DTOs
```kotlin
// Data classes for DTOs
data class UserDto(
    val id: Long,
    val firstName: String,
    val lastName: String,
    val email: String,
    val status: UserStatus,
    val createdAt: LocalDateTime
) {
    val fullName: String
        get() = "$firstName $lastName"
}

// Request/Response classes
data class CreateUserRequest(
    @field:NotBlank(message = "First name is required")
    @field:Size(max = 100, message = "First name must not exceed 100 characters")
    val firstName: String,
    
    @field:NotBlank(message = "Last name is required")
    @field:Size(max = 100, message = "Last name must not exceed 100 characters")
    val lastName: String,
    
    @field:Email(message = "Invalid email format")
    @field:NotBlank(message = "Email is required")
    val email: String,
    
    @field:Size(min = 8, message = "Password must be at least 8 characters")
    val password: String
)

data class UpdateUserRequest(
    val firstName: String?,
    val lastName: String?,
    val email: String?
) {
    fun hasValidUpdates(): Boolean = firstName != null || lastName != null || email != null
}

// Generic API response wrapper
data class ApiResponse<T>(
    val data: T? = null,
    val success: Boolean = true,
    val message: String? = null,
    val errors: List<String> = emptyList(),
    val timestamp: LocalDateTime = LocalDateTime.now()
) {
    companion object {
        fun <T> success(data: T, message: String? = null): ApiResponse<T> =
            ApiResponse(data = data, message = message)
        
        fun <T> error(message: String, errors: List<String> = emptyList()): ApiResponse<T> =
            ApiResponse(success = false, message = message, errors = errors)
    }
}
```

### Sealed Classes for Result Handling
```kotlin
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Throwable, val message: String? = null) : Result<Nothing>()
    data class Loading(val message: String? = null) : Result<Nothing>()
    
    inline fun <R> map(transform: (T) -> R): Result<R> = when (this) {
        is Success -> Success(transform(data))
        is Error -> this
        is Loading -> this
    }
    
    inline fun onSuccess(action: (T) -> Unit): Result<T> {
        if (this is Success) action(data)
        return this
    }
    
    inline fun onError(action: (Throwable) -> Unit): Result<T> {
        if (this is Error) action(exception)
        return this
    }
}

// Usage in service
@Service
class UserService {
    fun findUserSafely(id: Long): Result<UserDto> = try {
        val user = userRepository.findById(id)
            ?: return Result.Error(UserNotFoundException("User not found"))
        Result.Success(userMapper.toDto(user))
    } catch (e: Exception) {
        Result.Error(e, "Failed to retrieve user")
    }
}
```

### Extension Functions
```kotlin
// String extensions
fun String.isValidEmail(): Boolean = 
    this.matches(Regex("^[A-Za-z0-9+_.-]+@([A-Za-z0-9.-]+\\.[A-Za-z]{2,})$"))

fun String.toSlug(): String = 
    this.lowercase()
        .replace(Regex("[^a-z0-9\\s-]"), "")
        .replace(Regex("\\s+"), "-")
        .trim('-')

// Collection extensions
fun <T> List<T>.findByProperty(predicate: (T) -> Boolean): T? = 
    this.firstOrNull(predicate)

fun <T, K> List<T>.groupByProperty(keySelector: (T) -> K): Map<K, List<T>> = 
    this.groupBy(keySelector)

// LocalDateTime extensions
fun LocalDateTime.toFormattedString(): String = 
    this.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))

fun LocalDateTime.isToday(): Boolean = 
    this.toLocalDate() == LocalDate.now()

// Entity extensions
fun User.isActive(): Boolean = this.status == UserStatus.ACTIVE
fun User.canLogin(): Boolean = this.isActive() && this.emailVerified
```

### Coroutines for Async Operations
```kotlin
@Service
class AsyncUserService(
    private val userRepository: UserRepository,
    private val emailService: EmailService
) {
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    
    suspend fun createUserWithWelcomeEmail(request: CreateUserRequest): UserDto = coroutineScope {
        val user = async { createUser(request) }
        val emailResult = async { emailService.sendWelcomeEmail(request.email) }
        
        val createdUser = user.await()
        emailResult.await() // Ensure email is sent
        
        createdUser
    }
    
    fun processUsersInBatch(userIds: List<Long>): Flow<UserDto> = flow {
        userIds.forEach { id ->
            val user = userRepository.findById(id)
            if (user != null) {
                emit(userMapper.toDto(user))
            }
        }
    }.flowOn(Dispatchers.IO)
}
```

### Custom Annotations and Validation
```kotlin
// Custom validation annotation
@Target(AnnotationTarget.FIELD)
@Retention(AnnotationRetention.RUNTIME)
@Constraint(validatedBy = [UniqueEmailValidator::class])
annotation class UniqueEmail(
    val message: String = "Email already exists",
    val groups: Array<KClass<*>> = [],
    val payload: Array<KClass<out Payload>> = []
)

// Validator implementation
@Component
class UniqueEmailValidator(
    private val userRepository: UserRepository
) : ConstraintValidator<UniqueEmail, String> {
    
    override fun isValid(email: String?, context: ConstraintValidatorContext): Boolean {
        if (email == null) return true
        return userRepository.findByEmail(email) == null
    }
}

// Usage in DTO
data class CreateUserRequest(
    @field:NotBlank
    @field:Email
    @field:UniqueEmail
    val email: String,
    // ... other fields
)
```

## External References

### Official Documentation Links
- **Spring Boot Reference**: https://docs.spring.io/spring-boot/docs/current/reference/html/
- **Kotlin Documentation**: https://kotlinlang.org/docs/home.html
- **Spring with Kotlin**: https://docs.spring.io/spring-framework/docs/current/reference/html/languages.html#kotlin
- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
- **Gradle Kotlin DSL**: https://docs.gradle.org/current/userguide/kotlin_dsl.html
- **Maven Kotlin Plugin**: https://kotlinlang.org/docs/maven.html

### Code Quality Tools
- **ktlint**: https://pinterest.github.io/ktlint/
- **Detekt**: https://detekt.dev/
- **JaCoCo**: https://www.jacoco.org/jacoco/trunk/doc/
- **SonarQube Kotlin**: https://docs.sonarqube.org/latest/analysis/languages/kotlin/

### Testing Resources
- **JUnit 5**: https://junit.org/junit5/docs/current/user-guide/
- **MockK**: https://mockk.io/
- **Testcontainers**: https://www.testcontainers.org/
- **Spring Boot Test**: https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-testing

### Kotlin-Specific Resources
- **Kotlin Style Guide**: https://kotlinlang.org/docs/coding-conventions.html
- **Kotlin Coroutines**: https://kotlinlang.org/docs/coroutines-overview.html
- **Kotlin Serialization**: https://kotlinlang.org/docs/serialization.html
- **Arrow (Functional Programming)**: https://arrow-kt.io/

### Spring Boot Kotlin References
- **Spring Boot with Kotlin Tutorial**: https://spring.io/guides/tutorials/spring-boot-kotlin/
- **Building Spring Boot Applications with Kotlin**: https://spring.io/blog/2017/01/04/introducing-kotlin-support-in-spring-framework-5-0
- **Kotlin Spring Extensions**: https://docs.spring.io/spring-framework/docs/current/reference/html/languages.html#kotlin-spring-extensions

### Claude Code Integration
For Claude Code analysis and development assistance, this document should be referenced to ensure:
- Consistent Kotlin project structure validation
- Proper Kotlin naming convention adherence
- Spring Boot with Kotlin best practices compliance
- Code quality standard enforcement for Kotlin projects
- Integration testing with Kotlin-specific tools

## Validation Checklist

### Project Structure Validation
- [ ] Proper Maven/Gradle Kotlin project structure followed
- [ ] Source directories use `kotlin/` instead of `java/`
- [ ] Test directories properly organized with Kotlin test structure
- [ ] Configuration files in appropriate locations
- [ ] Documentation files present and up-to-date
- [ ] Build tool supports Kotlin plugins and configurations

### Kotlin Naming Convention Compliance
- [ ] Package names in lowercase with proper hierarchy
- [ ] Class names in PascalCase with appropriate suffixes
- [ ] Function names in camelCase
- [ ] Property names in camelCase
- [ ] Constants in SCREAMING_SNAKE_CASE in companion objects
- [ ] Boolean properties properly prefixed (is/has/can)
- [ ] File names match primary class names

### Kotlin-Specific Architecture Compliance
- [ ] Data classes used for DTOs and value objects
- [ ] Sealed classes used for state representation
- [ ] Extension functions used appropriately
- [ ] Null safety properly implemented
- [ ] Companion objects used for constants and factory methods
- [ ] Coroutines used for asynchronous operations where appropriate

### Spring Boot Kotlin Integration
- [ ] Kotlin Spring plugins properly configured
- [ ] Jackson Kotlin module included for JSON serialization
- [ ] JPA entities properly configured with Kotlin
- [ ] All-open and no-arg plugins configured for JPA entities
- [ ] Spring annotations work correctly with Kotlin classes

### Code Quality Standards
- [ ] ktlint formatting rules followed
- [ ] Detekt static analysis passes
- [ ] KDoc documentation for public APIs
- [ ] Unit tests with >80% coverage using MockK
- [ ] Integration tests with Testcontainers
- [ ] Consistent Kotlin idioms used throughout codebase

### Build Configuration
- [ ] Kotlin version compatibility across all modules
- [ ] Proper JVM target version (21)
- [ ] Kotlin compiler arguments configured correctly
- [ ] All necessary Kotlin dependencies included
- [ ] Build scripts use Kotlin DSL for Gradle projects

This document serves as the authoritative guide for Kotlin Spring Boot project structure and architecture best practices, supporting both Maven and Gradle build systems while maintaining Kotlin-specific standards and quality requirements.