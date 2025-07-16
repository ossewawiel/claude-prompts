# Spring Boot Java Unit Testing Best Practices

## Document Information
- **Purpose**: Spring Boot specific unit testing patterns and practices for Java projects
- **Target Framework**: Spring Boot 3.x with Java 21+
- **Testing Framework**: JUnit 5 (Jupiter) - MANDATORY
- **Integration**: Designed for Claude Code analysis and test generation
- **Last Updated**: June 27, 2025
- **Document Version**: 1.0.0

## Required Libraries and Dependencies

### Gradle Dependencies (build.gradle)
```gradle
dependencies {
    // Spring Boot Test Starter (includes JUnit 5, AssertJ, Mockito)
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    
    // Spring Security Testing
    testImplementation 'org.springframework.security:spring-security-test'
    
    // TestContainers for integration tests
    testImplementation 'org.testcontainers:junit-jupiter'
    testImplementation 'org.testcontainers:postgresql'
    
    // Enhanced assertions
    testImplementation 'org.assertj:assertj-core:3.24.2'
    
    // JSON testing
    testImplementation 'com.jayway.jsonpath:json-path'
    
    // WireMock for external service mocking
    testImplementation 'com.github.tomakehurst:wiremock-jre8:3.0.1'
    
    // Test data builders
    testImplementation 'net.datafaker:datafaker:2.0.1'
}

// NEVER exclude JUnit Jupiter
configurations {
    testImplementation {
        exclude group: 'org.junit.vintage', module: 'junit-vintage-engine'
    }
}
```

### Maven Dependencies (pom.xml)
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
        <exclusions>
            <exclusion>
                <groupId>org.junit.vintage</groupId>
                <artifactId>junit-vintage-engine</artifactId>
            </exclusion>
        </exclusions>
    </dependency>
    
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-test</artifactId>
        <scope>test</scope>
    </dependency>
    
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Spring Boot Testing Annotations

### Layer-Specific Test Slices

#### @WebMvcTest - Controller Layer Testing
```java
@WebMvcTest(UserController.class)
@Import(SecurityConfig.class)
class UserControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    @WithMockUser
    void shouldReturnUser_whenValidIdProvided() throws Exception {
        // Given
        User user = createTestUser();
        when(userService.findById(1L)).thenReturn(user);
        
        // When & Then
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.name").value("John Doe"));
    }
}
```

#### @DataJpaTest - Repository Layer Testing
```java
@DataJpaTest
@TestPropertySource(properties = {
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
class UserRepositoryTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void shouldFindByEmail_whenUserExists() {
        // Given
        User user = new User("john@example.com", "John Doe");
        entityManager.persistAndFlush(user);
        
        // When
        Optional<User> found = userRepository.findByEmail("john@example.com");
        
        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getName()).isEqualTo("John Doe");
    }
}
```

#### @JsonTest - JSON Serialization Testing
```java
@JsonTest
class UserDtoJsonTest {
    
    @Autowired
    private JacksonTester<UserDto> json;
    
    @Test
    void shouldSerializeUserDto() throws Exception {
        // Given
        UserDto user = new UserDto(1L, "john@example.com", "John Doe");
        
        // When & Then
        assertThat(this.json.write(user))
            .hasJsonPathNumberValue("@.id", 1L)
            .hasJsonPathStringValue("@.email", "john@example.com")
            .hasJsonPathStringValue("@.name", "John Doe");
    }
}
```

## Service Layer Testing Patterns

### Complete Service Test Example
```java
@ExtendWith(MockitoExtension.class)
@DisplayName("UserService Tests")
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private EmailService emailService;
    
    @Mock
    private UserMapper userMapper;
    
    private UserService userService;
    
    @BeforeEach
    void setUp() {
        userService = new UserService(userRepository, emailService, userMapper);
    }
    
    @Nested
    @DisplayName("createUser Tests")
    class CreateUserTests {
        
        @Test
        @DisplayName("Should create user and send welcome email when valid request")
        void shouldCreateUserAndSendWelcomeEmail_whenValidRequest() {
            // Given
            CreateUserRequest request = createValidUserRequest();
            User user = createTestUser();
            UserDto expectedDto = createUserDto();
            
            when(userRepository.existsByEmail(request.email())).thenReturn(false);
            when(userRepository.save(any(User.class))).thenReturn(user);
            when(userMapper.toDto(user)).thenReturn(expectedDto);
            
            // When
            UserDto result = userService.createUser(request);
            
            // Then
            assertThat(result).isEqualTo(expectedDto);
            verify(userRepository).save(any(User.class));
            verify(emailService).sendWelcomeEmail(user.getEmail());
        }
        
        @Test
        @DisplayName("Should throw EmailAlreadyExistsException when email already exists")
        void shouldThrowEmailAlreadyExistsException_whenEmailExists() {
            // Given
            CreateUserRequest request = createValidUserRequest();
            when(userRepository.existsByEmail(request.email())).thenReturn(true);
            
            // When & Then
            assertThatThrownBy(() -> userService.createUser(request))
                .isInstanceOf(EmailAlreadyExistsException.class)
                .hasMessage("Email already exists: " + request.email());
                
            verify(userRepository, never()).save(any());
            verify(emailService, never()).sendWelcomeEmail(anyString());
        }
    }
    
    @Nested
    @DisplayName("findById Tests")  
    class FindByIdTests {
        
        @Test
        @DisplayName("Should return user when valid ID provided")
        void shouldReturnUser_whenValidIdProvided() {
            // Given
            Long userId = 1L;
            User user = createTestUser();
            UserDto expectedDto = createUserDto();
            
            when(userRepository.findById(userId)).thenReturn(Optional.of(user));
            when(userMapper.toDto(user)).thenReturn(expectedDto);
            
            // When
            UserDto result = userService.findById(userId);
            
            // Then
            assertThat(result).isEqualTo(expectedDto);
        }
        
        @Test
        @DisplayName("Should throw UserNotFoundException when user not found")
        void shouldThrowUserNotFoundException_whenUserNotFound() {
            // Given
            Long userId = 999L;
            when(userRepository.findById(userId)).thenReturn(Optional.empty());
            
            // When & Then
            assertThatThrownBy(() -> userService.findById(userId))
                .isInstanceOf(UserNotFoundException.class)
                .hasMessage("User not found with ID: 999");
        }
    }
    
    // Test data builders
    private CreateUserRequest createValidUserRequest() {
        return new CreateUserRequest("john@example.com", "John Doe");
    }
    
    private User createTestUser() {
        User user = new User();
        user.setId(1L);
        user.setEmail("john@example.com");
        user.setName("John Doe");
        return user;
    }
    
    private UserDto createUserDto() {
        return new UserDto(1L, "john@example.com", "John Doe");
    }
}
```

## Common Anti-Patterns to Avoid

### ❌ Incorrect Patterns

#### Wrong Framework Usage
```java
// ❌ NEVER use JUnit 4
import org.junit.Test;
import org.junit.Before;

// ❌ NEVER use kotlin.test assertions
import kotlin.test.assertEquals;

// ❌ NEVER use @SpringBootTest for unit tests
@SpringBootTest
class UserServiceTest {
    @Autowired
    private UserService userService; // This loads entire Spring context
}
```

#### Poor Test Structure
```java
// ❌ Bad: Testing multiple behaviors in one test
@Test
void testUserOperations() {
    // Creating user
    User user = userService.create(request);
    assertThat(user).isNotNull();
    
    // Updating user
    user.setName("Updated Name");
    User updated = userService.update(user);
    assertThat(updated.getName()).isEqualTo("Updated Name");
    
    // Deleting user - TOO MUCH IN ONE TEST
    userService.delete(user.getId());
}

// ❌ Bad: Unclear test names
@Test
void test1() { /* ... */ }

@Test
void userTest() { /* ... */ }
```

#### Inefficient Mocking
```java
// ❌ Bad: Over-mocking
@Mock
private String someString; // Don't mock primitives/simple types

// ❌ Bad: Mocking classes you own
@Mock
private UserDto userDto; // This is your DTO, create real instance

// ❌ Bad: Not verifying important interactions
userService.createUser(request);
// Missing: verify(emailService).sendWelcomeEmail(...);
```

### ✅ Correct Patterns

#### Proper Framework Usage
```java
// ✅ Correct: JUnit 5 with proper imports
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.assertj.core.api.Assertions.*;

// ✅ Correct: Pure unit test with mocks
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock
    private UserRepository userRepository;
    
    private UserService userService;
}
```

#### Clear Test Structure
```java
// ✅ Good: One behavior per test with clear naming
@Test
@DisplayName("Should create user successfully when valid request provided")
void shouldCreateUser_whenValidRequestProvided() {
    // Given - test setup
    CreateUserRequest request = createValidRequest();
    
    // When - action under test
    UserDto result = userService.createUser(request);
    
    // Then - verification
    assertThat(result).isNotNull();
    assertThat(result.email()).isEqualTo(request.email());
}
```

## Test Data Management

### Test Data Builders Pattern
```java
// UserTestDataBuilder.java
public class UserTestDataBuilder {
    private String email = "default@example.com";
    private String name = "Default User";
    private LocalDateTime createdDate = LocalDateTime.now();
    private boolean active = true;
    
    public UserTestDataBuilder withEmail(String email) {
        this.email = email;
        return this;
    }
    
    public UserTestDataBuilder withName(String name) {
        this.name = name;
        return this;
    }
    
    public UserTestDataBuilder inactive() {
        this.active = false;
        return this;
    }
    
    public User build() {
        User user = new User();
        user.setEmail(email);
        user.setName(name);
        user.setCreatedDate(createdDate);
        user.setActive(active);
        return user;
    }
}

// Usage in tests
@Test
void shouldReturnActiveUsers_whenSearchingActiveUsers() {
    // Given
    User activeUser = new UserTestDataBuilder()
        .withEmail("active@example.com")
        .build();
        
    User inactiveUser = new UserTestDataBuilder()
        .withEmail("inactive@example.com")
        .inactive()
        .build();
        
    when(userRepository.findByActiveTrue()).thenReturn(List.of(activeUser));
    
    // When & Then
    List<UserDto> result = userService.findActiveUsers();
    assertThat(result).hasSize(1);
    assertThat(result.get(0).email()).isEqualTo("active@example.com");
}
```

### Object Mother Pattern
```java
// UserMother.java
public class UserMother {
    public static User johnDoe() {
        return new UserTestDataBuilder()
            .withEmail("john@example.com")
            .withName("John Doe")
            .build();
    }
    
    public static User janeSmith() {
        return new UserTestDataBuilder()
            .withEmail("jane@example.com")
            .withName("Jane Smith")
            .build();
    }
    
    public static User inactiveUser() {
        return new UserTestDataBuilder()
            .withEmail("inactive@example.com")
            .inactive()
            .build();
    }
}

// Usage
@Test
void shouldFindUser_whenSearchingByEmail() {
    // Given
    User user = UserMother.johnDoe();
    when(userRepository.findByEmail("john@example.com")).thenReturn(Optional.of(user));
    
    // When & Then
    Optional<UserDto> result = userService.findByEmail("john@example.com");
    assertThat(result).isPresent();
}
```

## Security Testing

### Testing with Spring Security
```java
@WebMvcTest(UserController.class)
class UserControllerSecurityTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    @WithMockUser(roles = "USER")
    void shouldAllowAccess_whenUserHasValidRole() throws Exception {
        // Given
        when(userService.findById(1L)).thenReturn(createUserDto());
        
        // When & Then
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isOk());
    }
    
    @Test
    @WithMockUser(roles = "GUEST")
    void shouldDenyAccess_whenUserLacksRequiredRole() throws Exception {
        // When & Then
        mockMvc.perform(get("/api/admin/users"))
            .andExpect(status().isForbidden());
    }
    
    @Test
    void shouldRequireAuthentication_whenNotAuthenticated() throws Exception {
        // When & Then
        mockMvc.perform(get("/api/users/1"))
            .andExpect(status().isUnauthorized());
    }
}
```

### Custom Security Test Annotations
```java
// @WithMockAdmin.java
@Retention(RetentionPolicy.RUNTIME)
@WithMockUser(
    username = "admin@example.com",
    roles = {"ADMIN", "USER"},
    authorities = {"ROLE_ADMIN", "ROLE_USER"}
)
public @interface WithMockAdmin {
}

// Usage
@Test
@WithMockAdmin
void shouldAllowAdminAccess_whenUserIsAdmin() throws Exception {
    mockMvc.perform(delete("/api/users/1"))
        .andExpect(status().isNoContent());
}
```

## Performance Testing Guidelines

### Test Execution Performance
```java
@TestMethodOrder(OrderAnnotation.class)
class PerformanceAwareTest {
    
    private static final Duration MAX_EXECUTION_TIME = Duration.ofMillis(100);
    
    @Test
    @Order(1)
    @Timeout(value = 100, unit = TimeUnit.MILLISECONDS)
    void shouldExecuteQuickly_fastTest() {
        // Fast test - should complete under 100ms
        assertTimeout(MAX_EXECUTION_TIME, () -> {
            userService.findById(1L);
        });
    }
    
    @Test
    @Order(2)
    void shouldMeasurePerformance_complexOperation() {
        // Given
        List<CreateUserRequest> requests = createLargeUserList(1000);
        
        // When & Then - ensure operation completes within reasonable time
        assertTimeout(Duration.ofSeconds(1), () -> {
            List<UserDto> results = userService.createUsers(requests);
            assertThat(results).hasSize(1000);
        });
    }
}
```

## Exception Testing Patterns

### Comprehensive Exception Testing
```java
@Nested
@DisplayName("Exception Handling Tests")
class ExceptionHandlingTests {
    
    @Test
    @DisplayName("Should throw ValidationException with detailed message when invalid email")
    void shouldThrowValidationException_whenInvalidEmail() {
        // Given
        CreateUserRequest request = new CreateUserRequest("invalid-email", "John Doe");
        
        // When & Then
        ValidationException exception = assertThatThrownBy(() -> 
            userService.createUser(request)
        )
        .isInstanceOf(ValidationException.class)
        .extracting(ValidationException.class::cast)
        .satisfies(ex -> {
            assertThat(ex.getMessage()).contains("Invalid email format");
            assertThat(ex.getField()).isEqualTo("email");
            assertThat(ex.getValue()).isEqualTo("invalid-email");
        })
        .returnResult();
    }
    
    @Test
    @DisplayName("Should handle repository exception gracefully")
    void shouldHandleRepositoryException_gracefully() {
        // Given
        CreateUserRequest request = createValidRequest();
        when(userRepository.save(any())).thenThrow(new DataAccessException("DB Error") {});
        
        // When & Then
        assertThatThrownBy(() -> userService.createUser(request))
            .isInstanceOf(ServiceException.class)
            .hasMessageContaining("Failed to save user")
            .hasCauseInstanceOf(DataAccessException.class);
    }
}
```

## Claude Code Integration Patterns

### Test Generation Helpers
```java
// TestMethodSignature.java - Helper for Claude Code
public class TestMethodSignature {
    public static String buildTestMethodName(String behavior, String condition) {
        return String.format("should_%s_when_%s", 
            behavior.replace(" ", "_").toLowerCase(),
            condition.replace(" ", "_").toLowerCase());
    }
    
    public static String buildDisplayName(String behavior, String condition) {
        return String.format("Should %s when %s", behavior, condition);
    }
}

// Usage example for Claude Code generation
// Method: createUser
// Scenario: valid request provided
// Generated: should_create_user_when_valid_request_provided()
// Display: "Should create user when valid request provided"
```

### Standard Test Templates for Claude Code
```java
// Template for Service Layer Tests
/*
@ExtendWith(MockitoExtension.class)
@DisplayName("[ClassName] Tests")
class [ClassName]Test {
    
    // Dependencies as @Mock
    [MOCK_DEPENDENCIES]
    
    private [ClassName] [instanceName];
    
    @BeforeEach
    void setUp() {
        [instanceName] = new [ClassName]([CONSTRUCTOR_PARAMS]);
    }
    
    @Nested
    @DisplayName("[methodName] Tests")
    class [MethodName]Tests {
        
        @Test
        @DisplayName("[TEST_DISPLAY_NAME]")
        void [TEST_METHOD_NAME]() {
            // Given
            [TEST_SETUP]
            
            // When
            [METHOD_CALL]
            
            // Then
            [ASSERTIONS]
            [VERIFICATIONS]
        }
    }
    
    // Test data builders
    [TEST_DATA_METHODS]
}
*/
```

## Configuration and Properties

### Test Configuration
```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: false
    properties:
      hibernate:
        format_sql: true
        
  h2:
    console:
      enabled: true
      
logging:
  level:
    com.company.app: DEBUG
    org.springframework.security: DEBUG
    org.hibernate.SQL: DEBUG
```

### JaCoCo Configuration
```gradle
// jacoco.gradle
jacoco {
    toolVersion = '0.8.10'
}

jacocoTestReport {
    dependsOn test
    
    reports {
        xml.required = true
        html.required = true
        csv.required = false
    }
    
    afterEvaluate {
        classDirectories.setFrom(files(classDirectories.files.collect {
            fileTree(dir: it, exclude: [
                '**/config/**',
                '**/dto/**',
                '**/entity/**',
                '**/*Application.class'
            ])
        }))
    }
}

jacocoTestCoverageVerification {
    dependsOn jacocoTestReport
    
    violationRules {
        rule {
            limit {
                counter = 'LINE'
                value = 'COVEREDRATIO'
                minimum = 0.85
            }
        }
        
        rule {
            element = 'CLASS'
            includes = ['com.company.app.service.*']
            limit {
                counter = 'LINE'
                value = 'COVEREDRATIO'  
                minimum = 0.90
            }
        }
    }
}

check.dependsOn jacocoTestCoverageVerification
```

## Online Resources

### Official Documentation
- **Spring Boot Testing**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing
- **JUnit 5 User Guide**: https://junit.org/junit5/docs/current/user-guide/
- **Mockito Documentation**: https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html
- **AssertJ Fluent Assertions**: https://assertj.github.io/doc/
- **Spring Security Testing**: https://docs.spring.io/spring-security/reference/servlet/test/index.html

### Best Practices Guides
- **Spring Boot Testing Best Practices**: https://reflectoring.io/spring-boot-testing/
- **JUnit 5 Best Practices**: https://phauer.com/2019/junit5-tips/
- **Mockito Best Practices**: https://github.com/mockito/mockito/wiki/FAQ
- **TestContainers Spring Boot**: https://testcontainers.com/guides/testing-spring-boot-rest-api-using-testcontainers/

### Tools and Libraries
- **JaCoCo Coverage**: https://www.jacoco.org/jacoco/trunk/doc/
- **WireMock**: https://wiremock.org/docs/junit-jupiter/
- **DataFaker**: https://www.datafaker.net/
- **Spring Test Documentation**: https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html

## Quick Reference Checklist

### Unit Test Quality Checklist
- [ ] Uses JUnit 5 (Jupiter) with correct imports
- [ ] Test class named `[ClassName]Test`
- [ ] Test methods follow `should_[behavior]_when_[condition]` pattern
- [ ] Uses `@ExtendWith(MockitoExtension.class)`
- [ ] All dependencies are properly mocked with `@Mock`
- [ ] Uses AssertJ for fluent assertions
- [ ] Follows Given-When-Then structure
- [ ] Tests are isolated and independent
- [ ] Verifies important mock interactions
- [ ] Exception scenarios are tested
- [ ] Test data builders are used for complex objects
- [ ] Tests execute under 100ms each
- [ ] Coverage meets target thresholds (85%+ line coverage)
- [ ] Display names are descriptive
- [ ] Nested classes group related test scenarios

### Common Import Template
```java
// Standard unit test imports for Spring Boot Java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.mockito.Mockito.*;
import static org.assertj.core.api.Assertions.*;

// Spring Boot specific test imports
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.TestPropertySource;
import org.springframework.security.test.context.support.WithMockUser;
```

---

This document provides Spring Boot specific unit testing patterns that complement the existing general unit testing best practices documentation, focusing on framework-specific annotations, patterns, and Claude Code integration for optimal test generation.