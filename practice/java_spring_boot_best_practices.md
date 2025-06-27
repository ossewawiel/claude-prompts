# Java Spring Boot Project Structure and Architecture Best Practices

## Document Information
- **Document Type**: Best Practices Guide
- **Last Updated**: June 26, 2025
- **Document Version**: 1.0.0
- **Scope**: Project Structure, Naming Conventions, Architecture
- **Build Tools**: Maven & Gradle

## Table of Contents
1. [Project Structure](#project-structure)
2. [Naming Conventions](#naming-conventions)
3. [Package Organization](#package-organization)
4. [Configuration Management](#configuration-management)
5. [Build Tool Specifics](#build-tool-specifics)
6. [Architecture Patterns](#architecture-patterns)
7. [Resource Organization](#resource-organization)
8. [Testing Structure](#testing-structure)
9. [Documentation Requirements](#documentation-requirements)
10. [External References](#external-references)

## Project Structure

### Standard Maven/Gradle Project Layout

```
project-root/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/company/application/
│   │   │       ├── Application.java              # Main application class
│   │   │       ├── config/                       # Configuration classes
│   │   │       │   ├── SecurityConfig.java
│   │   │       │   ├── DatabaseConfig.java
│   │   │       │   ├── CacheConfig.java
│   │   │       │   └── WebConfig.java
│   │   │       ├── controller/                   # REST controllers
│   │   │       │   ├── UserController.java
│   │   │       │   └── ProductController.java
│   │   │       ├── service/                      # Business logic
│   │   │       │   ├── UserService.java
│   │   │       │   ├── impl/                     # Service implementations
│   │   │       │   │   └── UserServiceImpl.java
│   │   │       │   └── dto/                      # Data Transfer Objects
│   │   │       │       ├── UserDto.java
│   │   │       │       └── CreateUserRequest.java
│   │   │       ├── repository/                   # Data access layer
│   │   │       │   ├── UserRepository.java
│   │   │       │   └── custom/                   # Custom repository implementations
│   │   │       │       └── UserRepositoryCustomImpl.java
│   │   │       ├── domain/                       # Domain entities
│   │   │       │   ├── entity/                   # JPA entities
│   │   │       │   │   ├── User.java
│   │   │       │   │   └── Product.java
│   │   │       │   └── enums/                    # Domain enumerations
│   │   │       │       └── UserStatus.java
│   │   │       ├── exception/                    # Custom exceptions
│   │   │       │   ├── GlobalExceptionHandler.java
│   │   │       │   ├── UserNotFoundException.java
│   │   │       │   └── ValidationException.java
│   │   │       ├── security/                     # Security components
│   │   │       │   ├── JwtAuthenticationFilter.java
│   │   │       │   └── CustomUserDetailsService.java
│   │   │       ├── util/                         # Utility classes
│   │   │       │   ├── DateUtils.java
│   │   │       │   └── ValidationUtils.java
│   │   │       └── constant/                     # Application constants
│   │   │           └── AppConstants.java
│   │   └── resources/
│   │       ├── application.yml                   # Main configuration
│   │       ├── application-dev.yml               # Development profile
│   │       ├── application-prod.yml              # Production profile
│   │       ├── application-test.yml              # Test profile
│   │       ├── db/migration/                     # Database migrations (Flyway)
│   │       │   ├── V1__Create_users_table.sql
│   │       │   └── V2__Add_user_roles.sql
│   │       ├── static/                           # Static web assets
│   │       └── templates/                        # Template files (Thymeleaf)
│   └── test/
│       ├── java/
│       │   └── com/company/application/
│       │       ├── controller/                   # Controller tests
│       │       ├── service/                      # Service tests
│       │       ├── repository/                   # Repository tests
│       │       ├── integration/                  # Integration tests
│       │       │   ├── UserIntegrationTest.java
│       │       │   └── DatabaseIntegrationTest.java
│       │       └── TestApplication.java          # Test configuration
│       └── resources/
│           ├── application-test.yml              # Test configuration
│           └── test-data/                        # Test data files
├── docs/                                         # Project documentation
│   ├── api/                                      # API documentation
│   ├── architecture/                             # Architecture diagrams
│   └── setup/                                    # Setup instructions
├── scripts/                                      # Build and deployment scripts
├── build.gradle / pom.xml                       # Build configuration
├── gradle/wrapper/ or .mvn/wrapper/             # Wrapper files
├── gradlew / mvnw                               # Wrapper scripts
├── .gitignore                                   # Git ignore rules
├── README.md                                    # Project overview
└── CHANGELOG.md                                 # Version history
```

## Naming Conventions

### Package Names
- **Format**: All lowercase, separated by dots
- **Pattern**: `com.company.application.module`
- **Examples**:
  ```java
  com.company.userservice
  com.company.userservice.controller
  com.company.userservice.domain.entity
  ```
- **Avoid**: Abbreviations, underscores, camelCase

### Class Names
- **Format**: PascalCase (UpperCamelCase)
- **Patterns**:
  ```java
  // Entities
  User.java, Product.java, OrderItem.java
  
  // Controllers
  UserController.java, ProductController.java
  
  // Services
  UserService.java, EmailService.java
  
  // Repositories
  UserRepository.java, ProductRepository.java
  
  // DTOs
  UserDto.java, CreateUserRequest.java, UserResponse.java
  
  // Configuration
  SecurityConfig.java, DatabaseConfig.java
  
  // Exceptions
  UserNotFoundException.java, ValidationException.java
  ```

### Method and Variable Names
- **Format**: camelCase
- **Examples**:
  ```java
  // Methods
  public User findUserById(Long userId) { }
  public List<User> findActiveUsers() { }
  
  // Variables
  private final UserService userService;
  private String userName;
  private boolean isActive;
  ```

### Constants
- **Format**: SCREAMING_SNAKE_CASE
- **Examples**:
  ```java
  public static final String DEFAULT_USER_ROLE = "USER";
  public static final int MAX_LOGIN_ATTEMPTS = 3;
  private static final Logger LOGGER = LoggerFactory.getLogger(UserService.class);
  ```

### Boolean Variables and Methods
- **Prefix with**: `is`, `has`, `can`, `should`
- **Examples**:
  ```java
  private boolean isActive;
  private boolean hasPermission;
  public boolean canAccess() { }
  public boolean shouldValidate() { }
  ```

## Package Organization

### Domain-Driven Design Approach
```java
com.company.application
├── Application.java                    # Main class
├── config/                            # Cross-cutting configuration
├── shared/                            # Shared utilities and common code
│   ├── dto/                          # Shared DTOs
│   ├── exception/                    # Common exceptions
│   └── util/                         # Utility classes
├── user/                             # User domain
│   ├── controller/                   # User-specific controllers
│   ├── service/                      # User business logic
│   ├── repository/                   # User data access
│   ├── domain/                       # User entities and value objects
│   └── dto/                          # User-specific DTOs
└── product/                          # Product domain
    ├── controller/
    ├── service/
    ├── repository/
    └── domain/
```

### Layered Architecture Approach
```java
com.company.application
├── Application.java
├── presentation/                     # Presentation layer
│   ├── controller/                   # REST controllers
│   ├── dto/                         # Request/Response DTOs
│   └── config/                      # Web configuration
├── application/                     # Application layer
│   ├── service/                     # Application services
│   └── facade/                      # Application facades
├── domain/                          # Domain layer
│   ├── entity/                      # Domain entities
│   ├── service/                     # Domain services
│   ├── repository/                  # Repository interfaces
│   └── valueobject/                 # Value objects
├── infrastructure/                  # Infrastructure layer
│   ├── repository/                  # Repository implementations
│   ├── config/                      # Infrastructure configuration
│   └── external/                    # External service integrations
└── shared/                          # Shared components
    ├── exception/
    ├── util/
    └── constant/
```

## Configuration Management

### Application Configuration Files
```yaml
# application.yml (Base configuration)
spring:
  application:
    name: user-service
  profiles:
    active: dev

server:
  port: 8080

---
# application-dev.yml (Development)
spring:
  config:
    activate:
      on-profile: dev
  datasource:
    url: jdbc:h2:mem:devdb
    username: sa
    password: 
  jpa:
    show-sql: true
    hibernate:
      ddl-auto: create-drop

logging:
  level:
    com.company: DEBUG

---
# application-prod.yml (Production)
spring:
  config:
    activate:
      on-profile: prod
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate

logging:
  level:
    root: WARN
    com.company: INFO
```

### Configuration Classes Organization
```java
// Main configuration package
com.company.application.config/
├── SecurityConfig.java              # Security configuration
├── DatabaseConfig.java              # Database configuration
├── CacheConfig.java                 # Caching configuration
├── WebConfig.java                   # Web MVC configuration
├── OpenApiConfig.java               # API documentation
├── MessagingConfig.java             # Messaging configuration
└── properties/                      # Configuration properties
    ├── DatabaseProperties.java
    ├── SecurityProperties.java
    └── ApplicationProperties.java
```

## Build Tool Specifics

### Maven Configuration (pom.xml)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.3.0</version>
        <relativePath/>
    </parent>
    
    <groupId>com.company</groupId>
    <artifactId>user-service</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>jar</packaging>
    
    <name>User Service</name>
    <description>User management microservice</description>
    
    <properties>
        <java.version>21</java.version>
        <spring-cloud.version>2023.0.2</spring-cloud.version>
    </properties>
    
    <!-- Build configuration -->
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
            
            <!-- Code quality plugins -->
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.10</version>
            </plugin>
            
            <plugin>
                <groupId>com.github.spotbugs</groupId>
                <artifactId>spotbugs-maven-plugin</artifactId>
                <version>4.8.5.0</version>
            </plugin>
        </plugins>
    </build>
</project>
```

### Gradle Configuration (build.gradle)
```gradle
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.3.0'
    id 'io.spring.dependency-management' version '1.1.5'
    id 'org.flywaydb.flyway' version '10.15.0'
    id 'jacoco'
    id 'checkstyle'
    id 'com.github.spotbugs' version '6.0.18'
}

group = 'com.company'
version = '1.0.0-SNAPSHOT'
sourceCompatibility = '21'

configurations {
    compileOnly {
        extendsFrom annotationProcessor
    }
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot starters
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-security'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    
    // Database
    runtimeOnly 'org.postgresql:postgresql'
    implementation 'org.flywaydb:flyway-core'
    
    // Testing
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testImplementation 'org.springframework.security:spring-security-test'
    testImplementation 'org.testcontainers:junit-jupiter'
    testImplementation 'org.testcontainers:postgresql'
}

// Source sets for integration tests
sourceSets {
    integrationTest {
        java.srcDir 'src/integration-test/java'
        resources.srcDir 'src/integration-test/resources'
        compileClasspath += main.output + test.output
        runtimeClasspath += main.output + test.output
    }
}

// Tasks
tasks.named('test') {
    useJUnitPlatform()
    finalizedBy jacocoTestReport
}

task integrationTest(type: Test) {
    useJUnitPlatform()
    testClassesDirs = sourceSets.integrationTest.output.classesDirs
    classpath = sourceSets.integrationTest.runtimeClasspath
}

jacocoTestReport {
    dependsOn test
    reports {
        xml.required = true
        html.required = true
    }
}

checkstyle {
    toolVersion = '10.17.0'
    configFile = file('config/checkstyle/checkstyle.xml')
}
```

## Architecture Patterns

### Layered Architecture
```java
// Controller Layer - Handles HTTP requests
@RestController
@RequestMapping("/api/users")
@Validated
public class UserController {
    
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
        return ResponseEntity.ok(userService.findById(id));
    }
}

// Service Layer - Contains business logic
@Service
@Transactional
public class UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    
    public UserService(UserRepository userRepository, UserMapper userMapper) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }
    
    @Transactional(readOnly = true)
    public UserDto findById(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
        return userMapper.toDto(user);
    }
}

// Repository Layer - Handles data access
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    @Query("SELECT u FROM User u WHERE u.email = :email AND u.active = true")
    Optional<User> findActiveUserByEmail(@Param("email") String email);
    
    List<User> findByLastLoginBefore(LocalDateTime date);
}
```

### Clean Architecture with Hexagonal Pattern
```java
// Domain Layer
public class User {
    private final UserId id;
    private final Email email;
    private final UserName name;
    
    // Domain methods
    public void activate() { /* business logic */ }
    public void deactivate() { /* business logic */ }
}

// Application Layer
@UseCase
@Transactional
public class CreateUserUseCase {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    public User execute(CreateUserCommand command) {
        // Use case implementation
    }
}

// Infrastructure Layer - Adapters
@Repository
@Adapter
public class JpaUserRepository implements UserRepository {
    
    private final UserJpaRepository jpaRepository;
    
    @Override
    public User save(User user) {
        UserEntity entity = UserMapper.toEntity(user);
        UserEntity saved = jpaRepository.save(entity);
        return UserMapper.toDomain(saved);
    }
}
```

## Resource Organization

### Database Migration Scripts (Flyway)
```
src/main/resources/db/migration/
├── V1__Create_users_table.sql
├── V2__Add_user_roles.sql
├── V3__Create_audit_tables.sql
├── V4__Add_indexes_for_performance.sql
└── R__Create_user_report_view.sql         # Repeatable migration
```

### Static Resources
```
src/main/resources/
├── static/                               # Static web content
│   ├── css/
│   ├── js/
│   ├── images/
│   └── favicon.ico
├── templates/                            # Template files
│   ├── email/                           # Email templates
│   │   ├── welcome.html
│   │   └── password-reset.html
│   └── error/                           # Error page templates
│       ├── 404.html
│       └── 500.html
└── messages/                            # Internationalization
    ├── messages.properties              # Default locale
    ├── messages_en.properties           # English
    └── messages_es.properties           # Spanish
```

## Testing Structure

### Test Organization
```
src/test/java/
├── unit/                               # Unit tests
│   ├── service/
│   │   └── UserServiceTest.java
│   ├── repository/
│   │   └── UserRepositoryTest.java
│   └── util/
│       └── ValidationUtilsTest.java
├── integration/                        # Integration tests
│   ├── controller/
│   │   └── UserControllerIntegrationTest.java
│   ├── repository/
│   │   └── UserRepositoryIntegrationTest.java
│   └── TestcontainersConfiguration.java
├── e2e/                               # End-to-end tests
│   └── UserWorkflowTest.java
└── testutils/                         # Test utilities
    ├── TestDataBuilder.java
    ├── TestConfigurationUtils.java
    └── MockServerConfiguration.java
```

### Test Naming Conventions
```java
// Test class naming: [ClassName]Test
public class UserServiceTest { }

// Test method naming: should[ExpectedBehavior]When[StateUnderTest]
@Test
public void shouldReturnUserWhenValidIdProvided() { }

@Test
public void shouldThrowExceptionWhenUserNotFound() { }

@Test
public void shouldValidateEmailFormatCorrectly() { }

// Integration test naming: [ClassName]IntegrationTest
public class UserControllerIntegrationTest { }

// End-to-end test naming: [Feature]E2ETest
public class UserRegistrationE2ETest { }
```

## Documentation Requirements

### README.md Structure
```markdown
# Project Name

## Overview
Brief description of the project's purpose and functionality.

## Technology Stack
- Java 21
- Spring Boot 3.3.0
- PostgreSQL 16
- Maven/Gradle

## Prerequisites
- JDK 21 or higher
- Maven 3.9+ / Gradle 8.0+
- Docker (for local development)

## Local Development Setup
Step-by-step instructions for setting up the development environment.

## Build and Run
Instructions for building and running the application.

## Testing
How to run different types of tests.

## API Documentation
Link to API documentation (Swagger/OpenAPI).

## Contributing
Guidelines for contributing to the project.
```

### JavaDoc Standards
```java
/**
 * Service class for managing user operations.
 * 
 * <p>This service provides CRUD operations for users and handles
 * business logic related to user management including validation,
 * authentication, and authorization checks.</p>
 * 
 * @author John Doe
 * @version 1.0
 * @since 1.0
 */
@Service
public class UserService {
    
    /**
     * Finds a user by their unique identifier.
     * 
     * @param id the unique identifier of the user, must not be null
     * @return the user data transfer object containing user information
     * @throws UserNotFoundException if no user is found with the given ID
     * @throws IllegalArgumentException if the ID is null
     */
    public UserDto findById(Long id) {
        // Implementation
    }
}
```

## External References

### Official Documentation Links
- **Spring Boot Reference**: https://docs.spring.io/spring-boot/docs/current/reference/html/
- **Spring Framework Documentation**: https://docs.spring.io/spring-framework/docs/current/reference/html/
- **Maven Official Guide**: https://maven.apache.org/guides/
- **Gradle User Manual**: https://docs.gradle.org/current/userguide/userguide.html

### Code Quality Tools
- **Checkstyle Configuration**: https://checkstyle.sourceforge.io/config.html
- **SpotBugs Rules**: https://spotbugs.readthedocs.io/en/stable/
- **JaCoCo Documentation**: https://www.jacoco.org/jacoco/trunk/doc/

### Testing Resources
- **JUnit 5 User Guide**: https://junit.org/junit5/docs/current/user-guide/
- **Mockito Documentation**: https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html
- **Testcontainers Documentation**: https://www.testcontainers.org/

### Database Tools
- **Flyway Documentation**: https://flywaydb.org/documentation/
- **Spring Data JPA Reference**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/

### Best Practices References
- **Google Java Style Guide**: https://google.github.io/styleguide/javaguide.html
- **Oracle Java Code Conventions**: https://www.oracle.com/java/technologies/javase/codeconventions-contents.html
- **Spring Boot Best Practices**: https://springframework.guru/spring-boot-best-practices/

### Claude Code Integration
For Claude Code analysis and development assistance, this document should be referenced to ensure:
- Consistent project structure validation
- Proper naming convention adherence
- Architecture pattern compliance
- Code quality standard enforcement

## Validation Checklist

### Project Structure Validation
- [ ] Proper Maven/Gradle project structure followed
- [ ] Source and test directories correctly organized
- [ ] Configuration files in appropriate locations
- [ ] Documentation files present and up-to-date

### Naming Convention Compliance
- [ ] Package names in lowercase with proper hierarchy
- [ ] Class names in PascalCase with appropriate suffixes
- [ ] Method and variable names in camelCase
- [ ] Constants in SCREAMING_SNAKE_CASE
- [ ] Boolean variables properly prefixed

### Architecture Compliance
- [ ] Clear separation of concerns between layers
- [ ] Dependency injection properly implemented
- [ ] Business logic contained in service layer
- [ ] Data access through repository pattern
- [ ] Exception handling consistently applied

### Code Quality Standards
- [ ] JavaDoc documentation for public APIs
- [ ] Unit tests with >80% coverage
- [ ] Integration tests for critical workflows
- [ ] Consistent code formatting
- [ ] No code quality violations (Checkstyle, SpotBugs)

This document serves as the authoritative guide for Java Spring Boot project structure and architecture best practices, supporting both Maven and Gradle build systems while maintaining consistency and quality standards.