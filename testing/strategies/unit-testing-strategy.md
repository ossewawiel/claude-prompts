# Spring Boot Unit Testing Strategy - Claude Code Instructions

## CONTEXT
**Project Type**: web-app|api-service|enterprise-app
**Complexity**: Medium-Complex
**Timeline**: Production
**Last Updated**: 2025-06-18
**Template Version**: 1.0.0
**Target Framework**: Spring Boot 3.3.x with Java 21 / Kotlin 2.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Testing Framework**: JUnit 5 (Jupiter) 5.10.x - MANDATORY (never use JUnit 4 or kotlin.test)
- **Mocking Framework**: Mockito 5.x (Java) / MockK 1.13.x (Kotlin)
- **Spring Test**: Spring Boot Test 3.3.x with @SpringBootTest
- **Test Containers**: Testcontainers 1.19.x for integration tests
- **Assertion Library**: JUnit 5 Assertions + AssertJ 3.24.x (NEVER use kotlin.test assertions)
- **Coverage Tool**: JaCoCo 0.8.x
- **Vaadin Testing**: Vaadin TestBench JUnit5 (for Vaadin projects)
- **Database Testing**: H2 2.x / TestContainers PostgreSQL/MariaDB
- **Spring Security Test**: Spring Security Test 6.x

### CRITICAL TESTING REQUIREMENTS
- **JUnit 5 MANDATORY**: Always use JUnit 5 (Jupiter), never JUnit 4 or kotlin.test
- **Imports**: Use org.junit.jupiter.api.* imports, never kotlin.test.*
- **Assertions**: Use JUnit 5 assertTrue/assertFalse + AssertJ assertThat

### Project Structure
```
{{project_name}}/
├── src/
│   ├── main/
│   │   ├── java/ (or kotlin/)
│   │   │   └── {{base_package}}/
│   │   │       ├── domain/
│   │   │       │   ├── entity/
│   │   │       │   ├── repository/
│   │   │       │   └── service/
│   │   │       ├── presentation/
│   │   │       │   ├── controller/
│   │   │       │   └── view/ (Vaadin)
│   │   │       └── config/
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-test.yml
│   │       └── db/migration/
│   └── test/
│       ├── java/ (or kotlin/)
│       │   └── {{base_package}}/
│       │       ├── unit/
│       │       │   ├── domain/
│       │       │   │   ├── entity/
│       │       │   │   ├── repository/
│       │       │   │   └── service/
│       │       │   ├── presentation/
│       │       │   │   ├── controller/
│       │       │   │   └── view/
│       │       │   └── config/
│       │       ├── integration/
│       │       │   ├── repository/
│       │       │   ├── service/
│       │       │   ├── controller/
│       │       │   └── view/
│       │       ├── testutil/
│       │       │   ├── builders/
│       │       │   ├── fixtures/
│       │       │   └── mothers/
│       │       └── AbstractIntegrationTest.java
│       └── resources/
│           ├── application-test.yml
│           ├── test-data/
│           │   ├── sql/
│           │   └── json/
│           └── testcontainers/
├── build.gradle.kts (or pom.xml)
└── jacoco.gradle (or jacoco plugin config)
```

### Documentation Sources
- **JUnit 5 Documentation**: https://junit.org/junit5/docs/current/user-guide/
- **Mockito Documentation**: https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html
- **MockK Documentation**: https://mockk.io/
- **Spring Boot Testing**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing
- **TestContainers**: https://testcontainers.com/guides/testing-spring-boot-rest-api-using-testcontainers/
- **Vaadin TestBench**: https://vaadin.com/docs/latest/testing

## STRICT GUIDELINES

### Code Standards
- **Test File Naming**: `*Test.java/.kt` for unit tests, `*IT.java/.kt` for integration tests
- **Test Location**: Mirror main source structure in test directories
- **Test Method Naming**: `should_[expected_behavior]_when_[condition]()` or Given-When-Then
- **Test Organization**: Use `@Nested` classes for logical grouping
- **Mock Organization**: Create mocks in setup methods, reset in teardown
- **Test Data**: Use TestDataBuilder pattern or Object Mother pattern

### Testing Requirements
- **Unit Test Coverage**: Minimum 85% line coverage, 90% for service layer
- **Integration Test Coverage**: All public APIs and critical business flows
- **Test Categories**: 
  - Unit tests: Repository, Service, Controller, Component logic
  - Integration tests: Database operations, API endpoints, security
  - Slice tests: @WebMvcTest, @DataJpaTest, @JsonTest
- **Performance**: Unit tests under 100ms each, integration tests under 5s
- **Isolation**: Each test independent with proper cleanup

### Security Practices
- **Test Data**: No production data, use synthetic test data only
- **Credentials**: Mock all external authentication and authorization
- **Test Environment**: Isolated test database and services
- **Security Testing**: Test authentication, authorization, and input validation

## IMPLEMENTATION STRATEGY

### Phase 1: Foundation Setup
- [ ] Configure JUnit 5 with Spring Boot Test
- [ ] Set up Mockito/MockK for Java/Kotlin projects
- [ ] Configure JaCoCo for code coverage reporting
- [ ] Create base test classes and utilities
- [ ] Set up TestContainers for integration tests
- [ ] Configure test application properties
- [ ] Establish testing profiles and data sources

### Phase 2: Unit Testing Implementation
- [ ] Create unit tests for all repository custom methods
- [ ] Test all service layer business logic with mocked dependencies
- [ ] Unit test all controller endpoints with @WebMvcTest
- [ ] Test validation logic and custom validators
- [ ] Create tests for configuration classes
- [ ] Test utility classes and helper methods
- [ ] Implement security unit tests

### Phase 3: Integration & Advanced Testing
- [ ] Create integration tests with @SpringBootTest
- [ ] Set up database integration tests with TestContainers
- [ ] Test Spring Security configuration end-to-end
- [ ] Create API integration tests with TestRestTemplate
- [ ] Implement Vaadin UI component tests (if applicable)
- [ ] Add performance benchmarks for critical paths
- [ ] Set up mutation testing for test quality validation

## CLAUDE_CODE_COMMANDS

### Initial Setup (Gradle Kotlin DSL)
```kotlin
// build.gradle.kts
dependencies {
    // Spring Boot Test Starters
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.mockito", module = "mockito-core")
    }
    testImplementation("org.springframework.security:spring-security-test")
    
    // For Kotlin projects
    testImplementation("io.mockk:mockk:1.13.11")
    testImplementation("com.ninja-squad:springmockk:4.0.2")
    testImplementation("io.kotest:kotest-assertions-core:5.7.2")
    
    // For Java projects
    testImplementation("org.mockito:mockito-core:5.5.0")
    testImplementation("org.mockito:mockito-junit-jupiter:5.5.0")
    testImplementation("org.assertj:assertj-core:3.24.2")
    
    // TestContainers
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:postgresql")
    testImplementation("org.testcontainers:redis")
    
    // For Vaadin projects
    testImplementation("com.vaadin:vaadin-testbench-junit5")
    
    // Test utilities
    testImplementation("com.github.tomakehurst:wiremock-jre8:3.0.1")
    testImplementation("org.awaitility:awaitility:4.2.1")
}

tasks.test {
    useJUnitPlatform()
    finalizedBy(tasks.jacocoTestReport)
    
    // JVM configuration for tests
    jvmArgs("-XX:+EnableDynamicAgentLoading")
    maxHeapSize = "2g"
    
    // Test execution configuration
    maxParallelForks = (Runtime.getRuntime().availableProcessors() / 2).takeIf { it > 0 } ?: 1
    
    // Test filtering
    systemProperty("spring.profiles.active", "test")
    systemProperty("junit.jupiter.execution.parallel.enabled", "true")
    systemProperty("junit.jupiter.execution.parallel.mode.default", "concurrent")
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
        xml.required.set(true)
        html.required.set(true)
        csv.required.set(false)
    }
    
    finalizedBy(tasks.jacocoTestCoverageVerification)
}

tasks.jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = "0.85".toBigDecimal()
            }
        }
        rule {
            element = "CLASS"
            includes = listOf("${project.group}.service.*")
            limit {
                counter = "LINE"
                minimum = "0.90".toBigDecimal()
            }
        }
    }
}
```

### Development Commands
```bash
# Run all tests
./gradlew test

# Run tests with coverage
./gradlew test jacocoTestReport

# Run only unit tests
./gradlew test --tests "*.unit.*"

# Run only integration tests  
./gradlew test --tests "*IT"

# Run specific test class
./gradlew test --tests "UserServiceTest"

# Run tests in continuous mode
./gradlew test --continuous

# Debug tests
./gradlew test --debug-jvm

# Generate test report
./gradlew test jacocoTestReport
open build/reports/jacoco/test/html/index.html
```

## VALIDATION_SCRIPTS

### Java Test Structure Validation
```java
// TestStructureValidator.java
@Component
public class TestStructureValidator {
    
    public void validateTestStructure() {
        // Validate test naming conventions
        validateTestNaming();
        
        // Validate test coverage requirements
        validateCoverageThresholds();
        
        // Validate test isolation
        validateTestIsolation();
    }
    
    private void validateTestNaming() {
        // Check for proper test method naming
        String pattern = "^(should|test|given|when|then).*";
        // Implementation for validation
    }
    
    private void validateCoverageThresholds() {
        // Verify JaCoCo coverage meets requirements
        double minimumCoverage = 0.85;
        // Implementation for coverage validation
    }
    
    private void validateTestIsolation() {
        // Check for proper test isolation and cleanup
        // Implementation for isolation validation
    }
}
```

### Kotlin Test Structure Validation
```kotlin
// TestStructureValidator.kt
@Component
class TestStructureValidator {
    
    fun validateTestStructure() {
        validateTestNaming()
        validateCoverageThresholds()
        validateTestIsolation()
    }
    
    private fun validateTestNaming() {
        val pattern = "^(should|test|given|when|then).*".toRegex()
        // Implementation for validation
    }
    
    private fun validateCoverageThresholds() {
        val minimumCoverage = 0.85
        // Implementation for coverage validation
    }
    
    private fun validateTestIsolation() {
        // Check for proper test isolation and cleanup
    }
}
```

## PROJECT_VARIABLES
- **PROJECT_NAME**: {{project_name}}
- **BASE_PACKAGE**: {{base_package}}
- **LANGUAGE**: {{java|kotlin}}
- **DATABASE_TYPE**: {{postgresql|mysql|h2}}
- **FRAMEWORK_ADDITIONS**: {{vaadin|rest_api|graphql}}
- **COVERAGE_THRESHOLD**: {{85|90|95}}

## CONDITIONAL_REQUIREMENTS

### IF language == "java"
```java
// Base test class for Java projects
@SpringBootTest
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
abstract class AbstractIntegrationTest {
    
    @Autowired
    protected TestRestTemplate restTemplate;
    
    @Autowired
    protected JdbcTemplate jdbcTemplate;
    
    @BeforeAll
    void setupTestData() {
        // Common test data setup
    }
    
    @AfterEach
    void cleanupTestData() {
        // Cleanup after each test
    }
}

// Service layer unit test example
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    void should_create_user_when_valid_data_provided() {
        // Given
        CreateUserRequest request = new CreateUserRequest("john@example.com", "John Doe");
        User expectedUser = User.builder()
                .email("john@example.com")
                .fullName("John Doe")
                .build();
        
        when(userRepository.save(any(User.class))).thenReturn(expectedUser);
        
        // When
        User result = userService.createUser(request);
        
        // Then
        assertThat(result.getEmail()).isEqualTo("john@example.com");
        assertThat(result.getFullName()).isEqualTo("John Doe");
        verify(userRepository).save(argThat(user -> 
            user.getEmail().equals("john@example.com") &&
            user.getFullName().equals("John Doe")
        ));
    }
}
```

### IF language == "kotlin"
```kotlin
// Base test class for Kotlin projects
@SpringBootTest
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
abstract class AbstractIntegrationTest {
    
    @Autowired
    protected lateinit var restTemplate: TestRestTemplate
    
    @Autowired
    protected lateinit var jdbcTemplate: JdbcTemplate
    
    @BeforeAll
    fun setupTestData() {
        // Common test data setup
    }
    
    @AfterEach
    fun cleanupTestData() {
        // Cleanup after each test
    }
}

// Service layer unit test example with MockK - JUnit 5 MANDATORY
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.assertj.core.api.Assertions.assertThat
import io.mockk.*

@ExtendWith(MockKExtension::class)
class UserServiceTest {
    
    @MockK
    private lateinit var userRepository: UserRepository
    
    @InjectMocks
    private lateinit var userService: UserService
    
    @Test
    fun `should create user when valid data provided`() {
        // Given
        val request = CreateUserRequest("john@example.com", "John Doe")
        val expectedUser = User(
            email = "john@example.com",
            fullName = "John Doe"
        )
        
        every { userRepository.save(any()) } returns expectedUser
        
        // When
        val result = userService.createUser(request)
        
        // Then - Use JUnit 5 + AssertJ, NEVER kotlin.test
        assertThat(result.email).isEqualTo("john@example.com")
        assertThat(result.fullName).isEqualTo("John Doe")
        
        verify { 
            userRepository.save(match { user ->
                user.email == "john@example.com" && 
                user.fullName == "John Doe"
            })
        }
    }
}
```

### IF framework_additions == "vaadin"
```java
// Vaadin view unit test
@ExtendWith(MockitoExtension.class)
class UserManagementViewTest {
    
    @Mock
    private UserService userService;
    
    private UserManagementView view;
    
    @BeforeEach
    void setUp() {
        view = new UserManagementView(userService);
    }
    
    @Test
    void should_display_users_when_view_initialized() {
        // Given
        List<User> users = Arrays.asList(
            User.builder().email("user1@test.com").fullName("User One").build(),
            User.builder().email("user2@test.com").fullName("User Two").build()
        );
        when(userService.findAll()).thenReturn(users);
        
        // When
        view.refreshGrid();
        
        // Then
        Grid<User> grid = view.getUserGrid();
        assertThat(grid.getListDataView().getItemCount()).isEqualTo(2);
        verify(userService).findAll();
    }
}

// Vaadin integration test with TestBench
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class UserManagementViewIT extends TestBenchTestCase {
    
    @BeforeAll
    void setupDriver() {
        setDriver(new ChromeDriver());
    }
    
    @Test
    void should_create_user_through_ui() {
        // Navigate to the view
        getDriver().get("http://localhost:8080/users");
        
        // Fill the form
        TextFieldElement emailField = $(TextFieldElement.class).caption("Email").first();
        TextFieldElement nameField = $(TextFieldElement.class).caption("Full Name").first();
        ButtonElement saveButton = $(ButtonElement.class).caption("Save").first();
        
        emailField.setValue("test@example.com");
        nameField.setValue("Test User");
        saveButton.click();
        
        // Verify the user appears in the grid
        GridElement grid = $(GridElement.class).first();
        assertThat(grid.getCell("test@example.com")).isNotNull();
    }
}
```

## INCLUDE_MODULES
- @include: test-data-builders.md
- @include: testcontainers-setup.md
- @include: spring-security-testing.md
- @include: vaadin-component-testing.md
- @include: performance-testing.md

## TESTING_PATTERNS

### 1. Test Data Builders (Java)
```java
// UserTestDataBuilder.java
public class UserTestDataBuilder {
    private String email = "default@example.com";
    private String fullName = "Default User";
    private UserRole role = UserRole.USER;
    private boolean active = true;
    
    public static UserTestDataBuilder aUser() {
        return new UserTestDataBuilder();
    }
    
    public UserTestDataBuilder withEmail(String email) {
        this.email = email;
        return this;
    }
    
    public UserTestDataBuilder withFullName(String fullName) {
        this.fullName = fullName;
        return this;
    }
    
    public UserTestDataBuilder withRole(UserRole role) {
        this.role = role;
        return this;
    }
    
    public UserTestDataBuilder inactive() {
        this.active = false;
        return this;
    }
    
    public User build() {
        return User.builder()
                .email(email)
                .fullName(fullName)
                .role(role)
                .active(active)
                .build();
    }
}

// Usage in tests
@Test
void should_find_active_users_only() {
    // Given
    User activeUser = aUser().withEmail("active@test.com").build();
    User inactiveUser = aUser().withEmail("inactive@test.com").inactive().build();
    
    when(userRepository.findByActiveTrue()).thenReturn(List.of(activeUser));
    
    // When
    List<User> result = userService.findActiveUsers();
    
    // Then
    assertThat(result).hasSize(1)
                     .extracting(User::getEmail)
                     .containsExactly("active@test.com");
}
```

### 2. Test Data Builders (Kotlin)
```kotlin
// UserTestDataBuilder.kt
class UserTestDataBuilder {
    private var email: String = "default@example.com"
    private var fullName: String = "Default User"
    private var role: UserRole = UserRole.USER
    private var active: Boolean = true
    
    companion object {
        fun aUser() = UserTestDataBuilder()
    }
    
    fun withEmail(email: String) = apply { this.email = email }
    
    fun withFullName(fullName: String) = apply { this.fullName = fullName }
    
    fun withRole(role: UserRole) = apply { this.role = role }
    
    fun inactive() = apply { this.active = false }
    
    fun build() = User(
        email = email,
        fullName = fullName,
        role = role,
        active = active
    )
}

// Usage in tests
@Test
fun `should find active users only`() {
    // Given
    val activeUser = aUser().withEmail("active@test.com").build()
    val inactiveUser = aUser().withEmail("inactive@test.com").inactive().build()
    
    every { userRepository.findByActiveTrue() } returns listOf(activeUser)
    
    // When
    val result = userService.findActiveUsers()
    
    // Then
    result shouldHaveSize 1
    result.map { it.email } shouldContainExactly listOf("active@test.com")
}
```

### 3. Repository Integration Tests
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class UserRepositoryIT {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void should_find_users_by_email_domain() {
        // Given
        User companyUser = aUser().withEmail("john@company.com").build();
        User externalUser = aUser().withEmail("jane@external.com").build();
        
        entityManager.persistAndFlush(companyUser);
        entityManager.persistAndFlush(externalUser);
        
        // When
        List<User> result = userRepository.findByEmailEndingWith("@company.com");
        
        // Then
        assertThat(result).hasSize(1)
                         .extracting(User::getEmail)
                         .containsExactly("john@company.com");
    }
}
```

## VALIDATION_CHECKLIST
- [ ] All service methods have unit tests with mocked dependencies
- [ ] All repository custom methods have integration tests
- [ ] All controller endpoints have @WebMvcTest slice tests
- [ ] All validation logic is thoroughly tested
- [ ] Security configuration is tested with proper authentication/authorization
- [ ] Code coverage meets minimum threshold (85% overall, 90% for services)
- [ ] Integration tests use TestContainers for real database testing
- [ ] Test data builders are used for complex object creation
- [ ] No hardcoded test data or production data in tests
- [ ] All tests are independent and can run in any order
- [ ] Performance tests validate critical path response times
- [ ] Vaadin UI components are tested (if applicable)
- [ ] Error scenarios and edge cases are covered
- [ ] Tests are properly organized with descriptive names
- [ ] Mock verification ensures correct interactions