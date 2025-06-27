# Java Best Practices for Code Analysis - Claude Code Integration

## Document Information
- **Purpose**: Comprehensive Java best practices for automated code analysis and Claude Code development assistance
- **Last Updated**: June 26, 2025
- **Document Version**: 2.0.0
- **Target Frameworks**: Spring Boot 3.x, Java 17+, JUnit 5
- **Integration**: Designed for Claude Code analysis and validation

## Table of Contents
1. [Naming Conventions](#naming-conventions)
2. [Null Handling](#null-handling)
3. [Library Usage Standards](#library-usage-standards)
4. [Error Handling](#error-handling)
5. [Code Organization](#code-organization)
6. [Testing Requirements](#testing-requirements)
7. [Security Practices](#security-practices)
8. [Performance Guidelines](#performance-guidelines)
9. [Documentation Standards](#documentation-standards)
10. [Analysis Checklist](#analysis-checklist)

---

## Naming Conventions

### Classes and Interfaces
```java
// ✅ CORRECT: PascalCase for classes
public class UserService { }
public class DatabaseManager { }
public class PaymentProcessor { }

// ✅ CORRECT: Interface naming (no 'I' prefix)
public interface UserRepository { }
public interface PaymentGateway { }

// ✅ CORRECT: Abstract classes
public abstract class BaseEntity { }
public abstract class AbstractValidator { }

// ✅ CORRECT: Records
public record UserDto(Long id, String name, String email) { }
public record ApiResponse<T>(T data, boolean success, String message) { }

// ❌ INCORRECT: Avoid abbreviations
public class UsrSvc { }  // Should be UserService
public class DbMgr { }   // Should be DatabaseManager
```

### Methods and Variables
```java
public class UserService {
    // ✅ CORRECT: Methods in camelCase
    public User getUserById(Long id) { }
    public boolean validateEmailAddress(String email) { }
    public BigDecimal calculateTotalPrice(List<Item> items) { }
    
    // ✅ CORRECT: Variables in camelCase
    private String userName;
    private LocalDateTime createdAt;
    private LocalDateTime lastLoginTime;
    
    // ✅ CORRECT: Boolean variables with proper prefixes
    private boolean isValid;
    private boolean hasPermission;
    private boolean canEdit;
    private boolean shouldProcess;
    
    // ✅ CORRECT: Constants in SCREAMING_SNAKE_CASE
    private static final int MAX_RETRY_COUNT = 3;
    private static final int DEFAULT_TIMEOUT_SECONDS = 30;
    private static final String API_BASE_URL = "https://api.example.com";
}
```

### Packages
```java
// ✅ CORRECT: Lowercase with descriptive names
package com.company.userservice.domain;
package com.company.userservice.repository;
package com.company.userservice.controller;
package com.company.userservice.configuration;

// ❌ INCORRECT: Avoid abbreviations
package com.company.userservice.config;  // Should be configuration
package com.company.userservice.repo;    // Should be repository
package com.company.userservice.ctrl;    // Should be controller
```

---

## Null Handling

### Mandatory Use of Optional
```java
// ✅ CORRECT: Always use Optional for nullable returns
public Optional<User> findUserByEmail(String email) {
    return userRepository.findByEmail(email);
}

public Optional<String> extractUserName(User user) {
    return Optional.ofNullable(user)
        .map(User::getName)
        .filter(name -> !name.trim().isEmpty());
}

// ✅ CORRECT: Optional chaining
public String getUserDisplayName(Long userId) {
    return findUserById(userId)
        .map(User::getName)
        .orElse("Anonymous User");
}

// ❌ INCORRECT: Never return null from public methods
public User findUserByEmail(String email) {
    return userRepository.findByEmail(email); // Could return null
}
```

### Input Validation
```java
// ✅ CORRECT: Validate inputs early with clear messages
public User createUser(String name, String email) {
    Objects.requireNonNull(name, "User name cannot be null");
    Objects.requireNonNull(email, "User email cannot be null");
    
    if (name.trim().isEmpty()) {
        throw new IllegalArgumentException("User name cannot be empty");
    }
    
    if (!isValidEmail(email)) {
        throw new IllegalArgumentException("Invalid email format: " + email);
    }
    
    return new User(name.trim(), email.toLowerCase());
}

// ✅ CORRECT: Use @NonNull annotations for documentation
public void processUser(@NonNull User user, @Nullable String additionalInfo) {
    // Method implementation
}
```

---

## Library Usage Standards

### Spring Framework Dependencies
```xml
<!-- ✅ MANDATORY: Core Spring Boot starters -->
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

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>

<!-- ✅ REQUIRED: Testing dependencies -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

### Dependency Injection Best Practices
```java
// ✅ CORRECT: Constructor injection (mandatory)
@Service
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }
}

// ✅ CORRECT: Lombok for reducing boilerplate
@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
}

// ❌ INCORRECT: Field injection (never use)
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository; // Avoid field injection
}
```

### Utility Libraries
```java
// ✅ APPROVED: Standard utility libraries
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.collections4.CollectionUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDateTime;
import java.time.ZonedDateTime;

// ✅ CORRECT: Proper usage examples
public boolean isValidString(String input) {
    return StringUtils.isNotBlank(input);
}

public boolean hasElements(List<?> list) {
    return CollectionUtils.isNotEmpty(list);
}
```

---

## Error Handling

### Exception Hierarchy
```java
// ✅ CORRECT: Custom exception hierarchy
public class BusinessException extends RuntimeException {
    private final String errorCode;
    
    public BusinessException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }
    
    public BusinessException(String errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }
}

public class UserNotFoundException extends BusinessException {
    public UserNotFoundException(Long userId) {
        super("USER_NOT_FOUND", "User not found with ID: " + userId);
    }
}

public class ValidationException extends BusinessException {
    public ValidationException(String field, String message) {
        super("VALIDATION_ERROR", String.format("Validation failed for %s: %s", field, message));
    }
}
```

### Exception Handling Patterns
```java
// ✅ CORRECT: Service layer exception handling
@Service
public class UserService {
    
    public User getUserById(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
    
    public User createUser(CreateUserRequest request) {
        try {
            validateUserRequest(request);
            return userRepository.save(mapToUser(request));
        } catch (DataIntegrityViolationException ex) {
            if (ex.getMessage().contains("email")) {
                throw new ValidationException("email", "Email already exists");
            }
            throw new BusinessException("DATA_ERROR", "Failed to create user", ex);
        }
    }
}

// ✅ CORRECT: Controller exception handling
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(UserNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleUserNotFound(UserNotFoundException ex) {
        return new ErrorResponse(ex.getErrorCode(), ex.getMessage());
    }
    
    @ExceptionHandler(ValidationException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleValidation(ValidationException ex) {
        return new ErrorResponse(ex.getErrorCode(), ex.getMessage());
    }
}
```

### Resource Management
```java
// ✅ CORRECT: Try-with-resources for auto-cleanup
public String readFileContent(String filename) throws IOException {
    try (FileInputStream fis = new FileInputStream(filename);
         BufferedReader reader = new BufferedReader(new InputStreamReader(fis))) {
        
        return reader.lines()
            .collect(Collectors.joining(System.lineSeparator()));
    }
}

// ✅ CORRECT: Database transaction handling
@Transactional
public void transferFunds(Long fromAccountId, Long toAccountId, BigDecimal amount) {
    try {
        Account fromAccount = getAccountById(fromAccountId);
        Account toAccount = getAccountById(toAccountId);
        
        fromAccount.withdraw(amount);
        toAccount.deposit(amount);
        
        accountRepository.save(fromAccount);
        accountRepository.save(toAccount);
        
    } catch (InsufficientFundsException ex) {
        throw new BusinessException("INSUFFICIENT_FUNDS", 
            "Transfer failed: insufficient funds", ex);
    }
}
```

---

## Code Organization

### Layer Architecture
```java
// ✅ CORRECT: Clear separation of concerns

// Controller Layer - HTTP handling only
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    
    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
        UserDto user = userService.getUserById(id);
        return ResponseEntity.ok(user);
    }
}

// Service Layer - Business logic
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    
    public UserDto getUserById(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
        return userMapper.toDto(user);
    }
    
    @Transactional
    public UserDto createUser(CreateUserRequest request) {
        // Business logic here
    }
}

// Repository Layer - Data access only
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findByActiveTrue();
    
    @Query("SELECT u FROM User u WHERE u.lastLoginDate < :date")
    List<User> findInactiveUsers(@Param("date") LocalDateTime date);
}
```

### File Organization
```
src/main/java/com/company/app/
├── controller/          # REST controllers
├── service/            # Business logic services  
├── repository/         # Data access repositories
├── domain/             # Entity and domain objects
│   ├── entity/         # JPA entities
│   ├── dto/           # Data transfer objects
│   └── mapper/        # Entity-DTO mappers
├── configuration/     # Spring configuration classes
├── exception/         # Custom exceptions
└── util/              # Utility classes

src/main/resources/
├── application.yml    # Application configuration
├── application-dev.yml
├── application-prod.yml
└── db/migration/      # Flyway migration scripts
```

---

## Testing Requirements

### Mandatory Testing Framework (JUnit 5)
```java
// ✅ MANDATORY: Always use JUnit 5 (Jupiter)
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.extension.ExtendWith;

// ✅ MANDATORY: Use AssertJ for assertions
import static org.assertj.core.api.Assertions.*;

// ✅ MANDATORY: Use Mockito for mocking
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.*;

// ❌ FORBIDDEN: Never use JUnit 4
// import org.junit.Test;  // JUnit 4 - DO NOT USE
// import org.junit.Before; // JUnit 4 - DO NOT USE
```

### Unit Test Structure
```java
@ExtendWith(MockitoExtension.class)
@DisplayName("UserService Tests")
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private EmailService emailService;
    
    private UserService userService;
    
    @BeforeEach
    void setUp() {
        userService = new UserService(userRepository, emailService);
    }
    
    @Nested
    @DisplayName("getUserById Tests")
    class GetUserByIdTests {
        
        @Test
        @DisplayName("Should return user when valid ID provided")
        void shouldReturnUser_whenValidIdProvided() {
            // Given
            Long userId = 1L;
            User expectedUser = createTestUser(userId, "john@example.com");
            when(userRepository.findById(userId)).thenReturn(Optional.of(expectedUser));
            
            // When
            UserDto result = userService.getUserById(userId);
            
            // Then
            assertThat(result).isNotNull();
            assertThat(result.id()).isEqualTo(userId);
            assertThat(result.email()).isEqualTo("john@example.com");
        }
        
        @Test
        @DisplayName("Should throw UserNotFoundException when user does not exist")
        void shouldThrowUserNotFoundException_whenUserDoesNotExist() {
            // Given
            Long userId = 999L;
            when(userRepository.findById(userId)).thenReturn(Optional.empty());
            
            // When & Then
            assertThatThrownBy(() -> userService.getUserById(userId))
                .isInstanceOf(UserNotFoundException.class)
                .hasMessage("User not found with ID: 999");
        }
    }
    
    private User createTestUser(Long id, String email) {
        User user = new User();
        user.setId(id);
        user.setEmail(email);
        user.setName("Test User");
        return user;
    }
}
```

### Integration Tests
```java
@SpringBootTest
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
class UserServiceIntegrationTest {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    @Transactional
    @Rollback
    void shouldCreateAndRetrieveUser() {
        // Given
        CreateUserRequest request = new CreateUserRequest("John Doe", "john@example.com");
        
        // When
        UserDto createdUser = userService.createUser(request);
        UserDto retrievedUser = userService.getUserById(createdUser.id());
        
        // Then
        assertThat(retrievedUser)
            .usingRecursiveComparison()
            .isEqualTo(createdUser);
    }
}
```

---

## Security Practices

### Input Validation
```java
// ✅ CORRECT: Bean Validation annotations
public class CreateUserRequest {
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;
    
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{8,}$",
             message = "Password must contain at least 8 characters, one uppercase, one lowercase, and one digit")
    private String password;
}

// ✅ CORRECT: Controller validation
@RestController
@Validated
public class UserController {
    
    @PostMapping("/users")
    public ResponseEntity<UserDto> createUser(@Valid @RequestBody CreateUserRequest request) {
        UserDto user = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(user);
    }
}
```

### Security Configuration
```java
// ✅ CORRECT: Security configuration
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/users").hasRole("USER")
                .requestMatchers(HttpMethod.POST, "/api/users").hasRole("ADMIN")
                .anyRequest().authenticated())
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(withDefaults()))
            .build();
    }
}
```

---

## Performance Guidelines

### Database Optimization
```java
// ✅ CORRECT: Efficient queries with proper indexing
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email", unique = true),
    @Index(name = "idx_user_status", columnList = "status"),
    @Index(name = "idx_user_created_date", columnList = "created_date")
})
public class User {
    // Entity definition
}

// ✅ CORRECT: Use appropriate fetch strategies
@Entity
public class User {
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Order> orders = new ArrayList<>();
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;
}

// ✅ CORRECT: Batch operations
@Repository
public class UserRepository extends JpaRepository<User, Long> {
    
    @Modifying
    @Query("UPDATE User u SET u.lastLoginDate = :date WHERE u.id IN :userIds")
    int updateLastLoginDateForUsers(@Param("userIds") List<Long> userIds, 
                                   @Param("date") LocalDateTime date);
}
```

### Caching Strategy
```java
// ✅ CORRECT: Appropriate caching
@Service
public class UserService {
    
    @Cacheable(value = "users", key = "#id")
    public UserDto getUserById(Long id) {
        // Implementation
    }
    
    @CacheEvict(value = "users", key = "#user.id")
    public UserDto updateUser(UserDto user) {
        // Implementation
    }
    
    @CacheEvict(value = "users", allEntries = true)
    public void clearUserCache() {
        // Clear all user cache entries
    }
}
```

---

## Documentation Standards

### JavaDoc Requirements
```java
/**
 * Service class for managing user operations.
 * 
 * <p>This service provides CRUD operations for users and handles
 * business logic related to user management including validation,
 * authentication, and authorization checks.</p>
 * 
 * @author Development Team
 * @version 1.0
 * @since 1.0
 */
@Service
public class UserService {
    
    /**
     * Retrieves a user by their unique identifier.
     * 
     * @param id the unique identifier of the user, must not be null
     * @return the user data transfer object containing user information
     * @throws UserNotFoundException if no user is found with the given ID
     * @throws IllegalArgumentException if the ID is null
     */
    public UserDto getUserById(Long id) {
        Objects.requireNonNull(id, "User ID cannot be null");
        
        return userRepository.findById(id)
            .map(userMapper::toDto)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
    
    /**
     * Creates a new user with the provided information.
     * 
     * <p>This method validates the user information, checks for duplicate
     * email addresses, and sends a welcome email upon successful creation.</p>
     * 
     * @param request the user creation request containing name and email
     * @return the created user as a DTO
     * @throws ValidationException if the request contains invalid data
     * @throws DuplicateEmailException if the email already exists
     */
    @Transactional
    public UserDto createUser(CreateUserRequest request) {
        // Implementation
    }
}
```

---

## Analysis Checklist

### Automated Code Analysis Points

#### ✅ Naming Convention Compliance
- [ ] All classes use PascalCase
- [ ] All methods use camelCase  
- [ ] All variables use camelCase
- [ ] Constants use SCREAMING_SNAKE_CASE
- [ ] Packages use lowercase with dots
- [ ] Boolean variables use is/has/can/should prefix
- [ ] No abbreviations in names
- [ ] File names match public class names

#### ✅ Null Safety Compliance
- [ ] All public methods return Optional for nullable values
- [ ] Input parameters validated with Objects.requireNonNull()
- [ ] No methods return null directly
- [ ] @NonNull/@Nullable annotations used where appropriate
- [ ] Optional chaining used instead of null checks

#### ✅ Dependency Injection Compliance
- [ ] Constructor injection used exclusively
- [ ] No @Autowired field injection
- [ ] All dependencies declared as final
- [ ] Lombok @RequiredArgsConstructor used appropriately

#### ✅ Exception Handling Compliance
- [ ] Custom exception hierarchy implemented
- [ ] Specific exception types for different scenarios
- [ ] Try-with-resources used for resource management
- [ ] Global exception handler implemented
- [ ] Meaningful error messages provided

#### ✅ Testing Compliance (CRITICAL)
- [ ] JUnit 5 (Jupiter) used exclusively - NO JUnit 4
- [ ] Test imports use org.junit.jupiter.api.*
- [ ] AssertJ used for all assertions
- [ ] Mockito used for mocking
- [ ] @DisplayName annotations for readable test names
- [ ] @Nested classes for test organization
- [ ] Test coverage > 80% for service layer

#### ✅ Security Compliance
- [ ] Input validation with Bean Validation
- [ ] SQL injection prevention (parameterized queries)
- [ ] Authorization checks at method level
- [ ] Sensitive data properly secured
- [ ] HTTPS enforcement in production

#### ✅ Performance Compliance
- [ ] Database queries optimized
- [ ] Appropriate caching strategy
- [ ] Lazy loading for collections
- [ ] Batch operations for bulk updates
- [ ] Connection pooling configured

#### ✅ Documentation Compliance
- [ ] JavaDoc for all public APIs
- [ ] Method documentation includes parameters and return values
- [ ] Exception documentation included
- [ ] Class-level documentation explains purpose

---

## External Resources for Claude Code

### Official Documentation Links
- **Spring Boot Reference**: https://docs.spring.io/spring-boot/docs/current/reference/html/
- **Spring Framework Documentation**: https://docs.spring.io/spring-framework/docs/current/reference/html/
- **JUnit 5 User Guide**: https://junit.org/junit5/docs/current/user-guide/
- **AssertJ Documentation**: https://assertj.github.io/doc/
- **Mockito Documentation**: https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html

### Code Quality Tools Integration
- **Checkstyle Configuration**: https://checkstyle.sourceforge.io/config.html
- **SpotBugs Rules**: https://spotbugs.readthedocs.io/en/stable/
- **SonarQube Java Rules**: https://docs.sonarqube.org/latest/user-guide/rules/

### Best Practices References
- **Google Java Style Guide**: https://google.github.io/styleguide/javaguide.html
- **Oracle Java Code Conventions**: https://www.oracle.com/java/technologies/javase/codeconventions-contents.html
- **Spring Boot Best Practices**: https://springframework.guru/spring-boot-best-practices/

---

## Claude Code Integration Commands

### Code Analysis Commands
```bash
# Format code with Google Java Format
java -jar google-java-format-1.17.0-all-deps.jar --replace **/*.java

# Run Checkstyle analysis
mvn checkstyle:check

# Run SpotBugs analysis
mvn spotbugs:check

# Run tests with coverage
mvn test jacoco:report

# Build and validate
mvn clean compile test-compile
```

### Validation Scripts
```bash
# Check for JUnit 4 imports (should return empty)
grep -r "import org.junit.Test" src/test/

# Check for field injection (should return empty)
grep -r "@Autowired.*private.*=" src/main/

# Verify Optional usage in return types
grep -r "public.*Optional" src/main/
```

---

This comprehensive best practices document serves as the authoritative guide for Java code analysis and development standards. It's specifically designed to help Claude Code understand project requirements and assist with maintaining consistent, high-quality code throughout the development process.