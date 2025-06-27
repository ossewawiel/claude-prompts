# Integration Testing Best Practices - Comprehensive Guide

## Document Information
- **Purpose**: Technology-agnostic integration testing best practices for code analysis and development
- **Last Updated**: June 26, 2025
- **Document Version**: 1.0.0
- **Scope**: Universal integration testing principles applicable across programming languages and frameworks
- **Integration**: Designed for Claude Code analysis and project validation

## Table of Contents
1. [Integration Testing Overview](#integration-testing-overview)
2. [Test Organization and Structure](#test-organization-and-structure)
3. [Naming Conventions](#naming-conventions)
4. [Test Types and Levels](#test-types-and-levels)
5. [What to Test in Integration Tests](#what-to-test-in-integration-tests)
6. [What NOT to Test in Integration Tests](#what-not-to-test-in-integration-tests)
7. [Test Coverage Guidelines](#test-coverage-guidelines)
8. [Test Structure and Layout](#test-structure-and-layout)
9. [Test Data Management](#test-data-management)
10. [Test Environment Management](#test-environment-management)
11. [When to Run Integration Tests](#when-to-run-integration-tests)
12. [Performance and Timing](#performance-and-timing)
13. [Error Handling and Resilience Testing](#error-handling-and-resilience-testing)
14. [Test Isolation and Independence](#test-isolation-and-independence)
15. [CI/CD Integration](#cicd-integration)
16. [Best Practices by Technology Stack](#best-practices-by-technology-stack)

---

## Integration Testing Overview

### Definition and Purpose
Integration testing verifies that different components, services, or systems work correctly when combined. Unlike unit tests that test individual components in isolation, integration tests validate the interaction between multiple components, data flow, and end-to-end functionality.

### Types of Integration Tests
- **Component Integration**: Testing interaction between internal application components
- **Service Integration**: Testing interaction with external services and APIs
- **Database Integration**: Testing data persistence, transactions, and database interactions
- **System Integration**: Testing complete workflows across multiple systems
- **Contract Testing**: Verifying API contracts between services

### Integration Test Pyramid
```
    /\
   /  \  End-to-End Tests (Few, Slow, Expensive)
  /____\
 /      \  Integration Tests (Some, Medium Speed)
/________\
Unit Tests (Many, Fast, Cheap)
```

---

## Test Organization and Structure

### Directory Structure Principles
```
Project Root/
├── src/
│   ├── main/
│   │   └── [source code]
│   └── test/
│       ├── unit/                    # Pure unit tests
│       ├── integration/             # Integration tests
│       │   ├── component/           # Component integration tests
│       │   ├── service/             # Service integration tests
│       │   ├── database/            # Database integration tests
│       │   ├── api/                 # API integration tests
│       │   └── end-to-end/          # End-to-end tests
│       ├── fixtures/                # Test data and utilities
│       ├── helpers/                 # Test helper functions
│       └── containers/              # Container configurations (TestContainers)
└── docs/
    └── testing/
        ├── integration-test-strategy.md
        ├── test-data-management.md
        └── test-environment-setup.md
```

### Test File Organization Patterns

#### Mirror Source Structure
Integration test files should mirror the structure of source code but be organized by integration scope:
```
src/
├── main/
│   └── com/company/app/
│       ├── controller/
│       ├── service/
│       └── repository/
└── test/
    └── integration/
        ├── controller/              # Controller integration tests
        ├── service/                 # Service integration tests
        ├── repository/              # Repository integration tests
        └── workflow/                # End-to-end workflow tests
```

#### Group by Integration Scope
```
test/integration/
├── api/                            # API endpoint tests
├── database/                       # Database integration tests
├── external-services/              # External service integration
├── messaging/                      # Message queue integration
└── security/                       # Security integration tests
```

---

## Naming Conventions

### Test Class Naming
```
// Component Integration Tests
[ComponentName]IntegrationTest
UserServiceIntegrationTest
PaymentProcessorIntegrationTest

// API Integration Tests  
[ControllerName]ApiIntegrationTest
UserControllerApiIntegrationTest
PaymentApiIntegrationTest

// Database Integration Tests
[EntityName]RepositoryIntegrationTest
UserRepositoryIntegrationTest
OrderRepositoryIntegrationTest

// Workflow Integration Tests
[WorkflowName]WorkflowIntegrationTest
UserRegistrationWorkflowIntegrationTest
PaymentProcessingWorkflowIntegrationTest

// External Service Integration Tests
[ServiceName]ExternalIntegrationTest
EmailServiceExternalIntegrationTest
PaymentGatewayExternalIntegrationTest
```

### Test Method Naming
Use descriptive names that indicate the integration scenario being tested:

```
// Pattern: should_[expected_behavior]_when_[integration_scenario]
should_save_user_and_send_email_when_registration_successful()
should_rollback_transaction_when_payment_service_fails()
should_return_cached_data_when_database_unavailable()

// Pattern: [scenario]_should_[expected_outcome]
user_registration_workflow_should_create_account_and_send_welcome_email()
payment_processing_should_handle_gateway_timeout_gracefully()
order_creation_should_update_inventory_and_send_confirmation()

// Pattern: given_[precondition]_when_[action]_then_[outcome]
given_user_exists_when_updating_profile_then_should_persist_changes_and_audit()
given_external_service_down_when_processing_request_then_should_fallback_gracefully()
```

### Test File Naming
```
// Integration test files
UserServiceIntegrationTest.java
PaymentControllerApiIT.java               # IT suffix alternative
OrderWorkflowIntegrationTest.kt
DatabaseMigrationIntegrationTest.py

// Test configuration files
integration-test-config.yml
test-containers-config.properties
integration-test.properties
```

---

## Test Types and Levels

### 1. Component Integration Tests
**Scope**: Test interaction between internal application components (services, repositories, controllers)

**Characteristics**:
- Use real application context but mock external dependencies
- Test component wiring and dependency injection
- Validate data flow between layers
- Test transaction boundaries

**Example Scenarios**:
```
UserService + UserRepository + EmailService (mocked)
OrderService + InventoryService + PaymentService (mocked external gateway)
AuthenticationService + UserRepository + TokenService
```

### 2. Service Integration Tests  
**Scope**: Test interaction with external services and APIs

**Characteristics**:
- Test real HTTP communication patterns
- Validate request/response handling
- Test error scenarios and resilience patterns
- Use contract testing where appropriate

**Example Scenarios**:
```
Payment Gateway Integration
Email Service Integration  
Third-party API Integration
Message Queue Integration
```

### 3. Database Integration Tests
**Scope**: Test data persistence, transactions, and database operations

**Characteristics**:
- Use real database instances (often containerized)
- Test complex queries and transactions
- Validate data integrity and constraints
- Test migration scripts and schema changes

**Example Scenarios**:
```
Multi-table Transaction Tests
Database Migration Validation
Complex Query Performance Tests
Data Integrity Constraint Tests
```

### 4. API Integration Tests
**Scope**: Test complete API endpoints and their behavior

**Characteristics**:
- Test HTTP request/response cycles
- Validate API contracts and documentation
- Test authentication and authorization
- Validate error responses and status codes

**Example Scenarios**:
```
REST API Endpoint Tests
GraphQL API Tests
WebSocket Communication Tests
API Authentication Flow Tests
```

### 5. End-to-End Integration Tests
**Scope**: Test complete user workflows across multiple systems

**Characteristics**:
- Test realistic user scenarios
- Use real or production-like environments
- Validate complete business workflows
- Test cross-system integrations

**Example Scenarios**:
```
User Registration to First Purchase Workflow
Order Processing to Fulfillment Workflow
User Authentication to Resource Access Workflow
```

---

## What to Test in Integration Tests

### Primary Integration Points
1. **Data Flow Between Components**
   - Service-to-service communication
   - Data transformation and mapping
   - Message passing and event handling

2. **Database Operations**
   - Complex transactions involving multiple tables
   - Data integrity across related entities
   - Performance of complex queries
   - Migration scripts and schema changes

3. **External Service Integration**
   - HTTP API communication
   - Authentication and authorization flows
   - Error handling and retry mechanisms
   - Circuit breaker patterns

4. **Configuration and Environment**
   - Configuration loading and validation
   - Environment-specific behavior
   - Feature flag integration
   - Security configuration

### Business Workflow Testing
1. **Complete User Journeys**
   - User registration and onboarding
   - Purchase and payment processing
   - Content creation and publication workflows

2. **Cross-System Processes**
   - Order fulfillment processes
   - Reporting and analytics workflows
   - Batch processing and data synchronization

3. **Integration Contracts**
   - API contract compliance
   - Message format validation
   - Schema compatibility

### Error and Edge Cases
1. **Failure Scenarios**
   - Network timeouts and failures
   - Database connection issues
   - External service unavailability

2. **Recovery Mechanisms**
   - Retry logic validation
   - Fallback behavior
   - Circuit breaker functionality

3. **Data Consistency**
   - Transaction rollback scenarios
   - Eventual consistency validation
   - Conflict resolution

---

## What NOT to Test in Integration Tests

### Avoid Testing in Integration Tests
1. **Pure Business Logic**
   - Complex algorithms (use unit tests)
   - Validation rules (use unit tests)
   - Mathematical calculations (use unit tests)

2. **UI-Specific Behavior**
   - Component rendering (use unit tests)
   - User interaction handling (use unit tests)
   - Styling and layout (use visual tests)

3. **Third-Party Library Functionality**
   - Well-tested external libraries
   - Framework-provided functionality
   - Standard library operations

4. **Simple CRUD Operations**
   - Basic database operations (use unit tests)
   - Simple REST endpoints (use unit tests)
   - Basic validation (use unit tests)

### Anti-Patterns to Avoid
1. **Over-Integration**
   - Testing too many components together
   - Complex test setups that are hard to maintain
   - Tests that duplicate unit test coverage

2. **Under-Mocking**
   - Not mocking expensive external services
   - Using real external services in CI/CD
   - Dependent on external service availability

3. **Over-Mocking**
   - Mocking components that should be tested together
   - Mocking database operations in database integration tests
   - Mocking internal application components unnecessarily

---

## Test Coverage Guidelines

### Coverage Targets by Integration Type

#### Component Integration Tests
- **Target Coverage**: 70-85% of integration paths
- **Focus Areas**: Component wiring, data flow, transaction boundaries
- **Measurement**: Integration path coverage rather than line coverage

#### Service Integration Tests  
- **Target Coverage**: 80-95% of external service interactions
- **Focus Areas**: Happy path, error scenarios, timeout handling
- **Measurement**: Scenario coverage for each external dependency

#### Database Integration Tests
- **Target Coverage**: 90-100% of complex queries and transactions
- **Focus Areas**: Multi-table operations, constraints, migrations
- **Measurement**: Query scenario coverage and transaction path coverage

#### API Integration Tests
- **Target Coverage**: 95-100% of public API endpoints
- **Focus Areas**: All HTTP methods, authentication, error responses
- **Measurement**: Endpoint coverage with scenario variations

### Coverage Quality Guidelines
1. **Meaningful Scenarios**: Test realistic business scenarios
2. **Error Path Coverage**: Include failure and recovery scenarios
3. **Performance Validation**: Include performance expectations
4. **Security Validation**: Test authentication and authorization

### Coverage Measurement
```
Integration Test Coverage Report:
├── Component Integration: 78% (Target: 70-85%)
├── Service Integration: 92% (Target: 80-95%)  
├── Database Integration: 88% (Target: 90-100%)
├── API Integration: 96% (Target: 95-100%)
└── End-to-End Workflows: 85% (Target: 80-90%)
```

---

## Test Structure and Layout

### Test Structure Patterns

#### 1. Arrange-Act-Assert (AAA) Pattern
```java
@Test
void should_create_user_and_send_welcome_email_when_registration_successful() {
    // Arrange
    var registrationData = UserRegistrationBuilder.valid()
        .withEmail("user@example.com")
        .withName("John Doe")
        .build();
    
    // Act
    var result = userRegistrationService.registerUser(registrationData);
    
    // Assert
    assertThat(result.isSuccess()).isTrue();
    assertThat(userRepository.findByEmail("user@example.com"))
        .isPresent()
        .hasValueSatisfying(user -> {
            assertThat(user.getName()).isEqualTo("John Doe");
            assertThat(user.getStatus()).isEqualTo(UserStatus.ACTIVE);
        });
    
    verify(emailService).sendWelcomeEmail("user@example.com", "John Doe");
}
```

#### 2. Given-When-Then (BDD) Pattern
```java
@Test
void payment_processing_workflow() {
    // Given
    var user = givenActiveUser();
    var cart = givenCartWithItems(user, item1, item2);
    var paymentMethod = givenValidPaymentMethod(user);
    
    // When
    var result = whenProcessingPayment(cart, paymentMethod);
    
    // Then
    thenPaymentShouldBeSuccessful(result);
    thenOrderShouldBeCreated(cart);
    thenInventoryShouldBeUpdated(item1, item2);
    thenConfirmationEmailShouldBeSent(user);
}
```

#### 3. Test Class Organization
```java
@SpringBootTest
@Testcontainers
@TestMethodOrder(OrderAnnotation.class)
class UserRegistrationWorkflowIntegrationTest {
    
    // Setup and configuration
    @Container
    static PostgreSQLContainer<?> database = new PostgreSQLContainer<>("postgres:15");
    
    @Autowired
    private UserRegistrationService userRegistrationService;
    
    @MockBean
    private EmailService emailService;
    
    // Happy path tests
    @Nested
    @DisplayName("Successful Registration Scenarios")
    class SuccessfulRegistrationTests {
        
        @Test
        void should_register_user_with_valid_data() { }
        
        @Test  
        void should_handle_duplicate_email_gracefully() { }
    }
    
    // Error scenario tests
    @Nested
    @DisplayName("Error Handling Scenarios")
    class ErrorHandlingTests {
        
        @Test
        void should_rollback_on_email_service_failure() { }
        
        @Test
        void should_handle_database_constraint_violations() { }
    }
    
    // Performance tests
    @Nested
    @DisplayName("Performance Requirements")
    class PerformanceTests {
        
        @Test
        void should_complete_registration_within_time_limit() { }
    }
}
```

### Test Documentation
```java
/**
 * Integration test for user registration workflow.
 * 
 * Tests the complete user registration process including:
 * - User data validation and persistence
 * - Welcome email sending
 * - Account activation
 * - Error handling and rollback scenarios
 * 
 * External Dependencies:
 * - PostgreSQL database (TestContainers)
 * - Email service (mocked)
 * 
 * Test Data:
 * - Uses UserRegistrationBuilder for test data creation
 * - Database is reset between test methods
 */
@SpringBootTest
class UserRegistrationWorkflowIntegrationTest {
    // Test implementation
}
```

---

## Test Data Management

### Test Data Strategies

#### 1. Test Data Builders
```java
public class UserRegistrationBuilder {
    private String email = "default@example.com";
    private String name = "Default User";
    private String password = "defaultPassword123";
    
    public static UserRegistrationBuilder valid() {
        return new UserRegistrationBuilder();
    }
    
    public UserRegistrationBuilder withEmail(String email) {
        this.email = email;
        return this;
    }
    
    public UserRegistrationBuilder withName(String name) {
        this.name = name;
        return this;
    }
    
    public UserRegistrationData build() {
        return new UserRegistrationData(email, name, password);
    }
}
```

#### 2. Test Fixtures and Object Mothers
```java
public class TestFixtures {
    
    public static User createActiveUser() {
        return User.builder()
            .email("active.user@example.com")
            .name("Active User")
            .status(UserStatus.ACTIVE)
            .createdAt(LocalDateTime.now())
            .build();
    }
    
    public static Order createPendingOrder(User user) {
        return Order.builder()
            .user(user)
            .status(OrderStatus.PENDING)
            .items(List.of(createOrderItem()))
            .total(BigDecimal.valueOf(99.99))
            .build();
    }
    
    public static Product createActiveProduct() {
        return Product.builder()
            .name("Test Product")
            .price(BigDecimal.valueOf(29.99))
            .inventory(100)
            .status(ProductStatus.ACTIVE)
            .build();
    }
}
```

#### 3. Database Test Data Management
```java
@TestConfiguration
public class IntegrationTestDataConfig {
    
    @Bean
    @Primary
    public TestDataManager testDataManager(JdbcTemplate jdbcTemplate) {
        return new TestDataManager(jdbcTemplate);
    }
}

public class TestDataManager {
    
    @Transactional
    public void setupTestData() {
        // Insert test data
        insertUsers();
        insertProducts();
        insertOrders();
    }
    
    @Transactional
    public void cleanupTestData() {
        // Clean up in reverse dependency order
        deleteOrders();
        deleteProducts();
        deleteUsers();
    }
}
```

### Test Data Best Practices
1. **Isolation**: Each test should have independent test data
2. **Cleanup**: Always clean up test data after tests complete
3. **Realistic Data**: Use realistic data that represents production scenarios
4. **Minimal Data**: Create only the data needed for the specific test
5. **Reusability**: Create reusable test data builders and fixtures

---

## Test Environment Management

### Environment Configuration

#### 1. Test-Specific Configuration
```yaml
# application-test.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  jpa:
    hibernate:
      ddl-auto: create-drop
  
server:
  port: 0  # Random port for parallel execution

logging:
  level:
    com.company.app: DEBUG
    org.springframework.web: DEBUG

external-services:
  payment-gateway:
    url: http://localhost:${wiremock.server.port}
    timeout: 5s
  email-service:
    enabled: false  # Mock in tests
```

#### 2. TestContainers Configuration
```java
@TestConfiguration
public class TestContainersConfig {
    
    @Bean
    @ServiceConnection
    static PostgreSQLContainer<?> postgresContainer() {
        return new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("integration_test")
            .withUsername("test")
            .withPassword("test");
    }
    
    @Bean
    @ServiceConnection  
    static RedisContainer redisContainer() {
        return new RedisContainer("redis:7-alpine");
    }
    
    @Bean
    static GenericContainer<?> wiremockContainer() {
        return new GenericContainer<>("wiremock/wiremock:3.0.1")
            .withExposedPorts(8080)
            .withCommand("--port", "8080");
    }
}
```

#### 3. Mock Service Configuration
```java
@TestConfiguration
public class MockServiceConfig {
    
    @Bean
    @Primary
    public EmailService mockEmailService() {
        return Mockito.mock(EmailService.class);
    }
    
    @Bean
    @Primary
    public PaymentGateway stubPaymentGateway() {
        PaymentGateway gateway = Mockito.mock(PaymentGateway.class);
        
        // Configure default successful responses
        when(gateway.processPayment(any()))
            .thenReturn(PaymentResult.success("txn-12345"));
            
        return gateway;
    }
}
```

### Environment Isolation
1. **Database Isolation**: Use separate databases or schemas for each test
2. **Port Isolation**: Use random ports to avoid conflicts
3. **Cache Isolation**: Clear caches between tests
4. **File System Isolation**: Use temporary directories for file operations

---

## When to Run Integration Tests

### Execution Strategy

#### 1. Development Workflow
```bash
# Fast feedback loop - unit tests only
./gradlew test

# Integration validation - component integration
./gradlew componentIntegrationTest

# Full validation - all integration tests  
./gradlew integrationTest

# Complete test suite
./gradlew check
```

#### 2. CI/CD Pipeline Integration
```yaml
# Example GitHub Actions workflow
name: CI Pipeline

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Unit Tests
        run: ./gradlew test
        
  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v3
      - name: Run Integration Tests
        run: ./gradlew integrationTest
        
  end-to-end-tests:
    runs-on: ubuntu-latest
    needs: integration-tests
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Run E2E Tests
        run: ./gradlew e2eTest
```

#### 3. Build Tool Configuration
```gradle
// Gradle configuration for test separation
tasks.register('componentIntegrationTest', Test) {
    useJUnitPlatform {
        includeTags 'component-integration'
    }
    group = 'verification'
    description = 'Runs component integration tests'
    mustRunAfter 'test'
}

tasks.register('serviceIntegrationTest', Test) {
    useJUnitPlatform {
        includeTags 'service-integration'
    }
    group = 'verification'  
    description = 'Runs service integration tests'
    mustRunAfter 'componentIntegrationTest'
}

tasks.register('integrationTest', Test) {
    useJUnitPlatform {
        includeTags 'integration'
    }
    group = 'verification'
    description = 'Runs all integration tests'
    mustRunAfter 'test'
}

// Exclude integration tests from default build
tasks.test {
    useJUnitPlatform {
        excludeTags 'integration'
    }
}
```

### Timing Guidelines
1. **During Development**: Run relevant integration tests for changed components
2. **Before Commit**: Run unit tests and related integration tests
3. **Pull Request**: Run full integration test suite
4. **Pre-deployment**: Run all tests including end-to-end tests
5. **Production Deployment**: Run smoke tests and health checks

---

## Performance and Timing

### Performance Expectations

#### Test Execution Time Targets
```
Test Type                    | Target Time | Max Acceptable
----------------------------|-------------|---------------
Component Integration       | 2-5 seconds | 10 seconds
Service Integration         | 3-8 seconds | 15 seconds  
Database Integration        | 1-3 seconds | 8 seconds
API Integration            | 5-10 seconds| 20 seconds
End-to-End Workflow        | 10-30 seconds| 60 seconds
```

#### Performance Optimization Strategies
1. **Parallel Execution**
   - Run independent tests in parallel
   - Use separate test databases for parallel tests
   - Configure optimal thread pools

2. **Resource Management**
   - Reuse expensive resources (containers, connections)
   - Pool database connections
   - Cache test data where appropriate

3. **Test Scope Optimization**
   - Test minimal necessary components
   - Use mocks for expensive operations
   - Optimize test data creation

#### Performance Monitoring
```java
@ExtendWith(PerformanceTestExtension.class)
class UserServiceIntegrationTest {
    
    @Test
    @PerformanceTest(maxDurationMs = 5000)
    void should_complete_user_registration_within_time_limit() {
        // Test implementation
    }
}

// Custom extension for performance monitoring
public class PerformanceTestExtension implements TestWatcher, BeforeEachCallback, AfterEachCallback {
    
    private long startTime;
    
    @Override
    public void beforeEach(ExtensionContext context) {
        startTime = System.currentTimeMillis();
    }
    
    @Override
    public void afterEach(ExtensionContext context) {
        long duration = System.currentTimeMillis() - startTime;
        PerformanceTest annotation = context.getRequiredTestMethod()
            .getAnnotation(PerformanceTest.class);
            
        if (annotation != null && duration > annotation.maxDurationMs()) {
            fail(String.format("Test exceeded time limit: %dms > %dms", 
                duration, annotation.maxDurationMs()));
        }
        
        System.out.printf("Test %s completed in %dms%n", 
            context.getDisplayName(), duration);
    }
}
```

---

## Error Handling and Resilience Testing

### Error Scenario Testing

#### 1. Network and Connectivity Issues
```java
@Test
void should_handle_external_service_timeout_gracefully() {
    // Arrange - Configure service to timeout
    stubFor(post(urlEqualTo("/api/payment"))
        .willReturn(aResponse()
            .withFixedDelay(10000)  // 10 second delay
            .withStatus(200)));
    
    // Act & Assert
    assertThatThrownBy(() -> paymentService.processPayment(paymentRequest))
        .isInstanceOf(PaymentTimeoutException.class)
        .hasMessageContaining("Payment service timeout");
}

@Test
void should_retry_failed_requests_with_exponential_backoff() {
    // Arrange - Service fails first two times, succeeds third time
    stubFor(post(urlEqualTo("/api/payment"))
        .inScenario("Retry Scenario")
        .whenScenarioStateIs(STARTED)
        .willReturn(aResponse().withStatus(500))
        .willSetStateTo("First Retry"));
        
    stubFor(post(urlEqualTo("/api/payment"))
        .inScenario("Retry Scenario")
        .whenScenarioStateIs("First Retry")
        .willReturn(aResponse().withStatus(500))
        .willSetStateTo("Second Retry"));
        
    stubFor(post(urlEqualTo("/api/payment"))
        .inScenario("Retry Scenario") 
        .whenScenarioStateIs("Second Retry")
        .willReturn(aResponse()
            .withStatus(200)
            .withBody("{\"status\":\"success\"}")));
    
    // Act
    var result = paymentService.processPayment(paymentRequest);
    
    // Assert
    assertThat(result.isSuccess()).isTrue();
    verify(exactly(3), postRequestedFor(urlEqualTo("/api/payment")));
}
```

#### 2. Database and Transaction Failures
```java
@Test
@Transactional
@Rollback
void should_rollback_transaction_when_email_service_fails() {
    // Arrange
    var userData = UserRegistrationBuilder.valid().build();
    doThrow(new EmailServiceException("Service unavailable"))
        .when(emailService).sendWelcomeEmail(any(), any());
    
    // Act & Assert
    assertThatThrownBy(() -> userRegistrationService.registerUser(userData))
        .isInstanceOf(RegistrationException.class);
    
    // Verify rollback occurred
    assertThat(userRepository.findByEmail(userData.getEmail()))
        .isEmpty();
}

@Test  
void should_handle_database_constraint_violations_gracefully() {
    // Arrange - Create user with existing email
    var existingUser = userRepository.save(TestFixtures.createActiveUser());
    var duplicateUserData = UserRegistrationBuilder.valid()
        .withEmail(existingUser.getEmail())
        .build();
    
    // Act & Assert
    assertThatThrownBy(() -> userRegistrationService.registerUser(duplicateUserData))
        .isInstanceOf(DuplicateUserException.class)
        .hasMessageContaining("User already exists");
}
```

#### 3. Circuit Breaker Testing
```java
@Test
void should_open_circuit_breaker_after_consecutive_failures() {
    // Arrange - Configure external service to always fail
    stubFor(any(anyUrl())
        .willReturn(aResponse().withStatus(500)));
    
    // Act - Make requests until circuit opens
    for (int i = 0; i < 5; i++) {
        try {
            externalService.makeRequest();
        } catch (Exception e) {
            // Expected failures
        }
    }
    
    // Assert - Circuit should be open, next call should fail fast
    long startTime = System.currentTimeMillis();
    assertThatThrownBy(() -> externalService.makeRequest())
        .isInstanceOf(CircuitBreakerOpenException.class);
    long duration = System.currentTimeMillis() - startTime;
    
    // Should fail fast (< 100ms) rather than timing out
    assertThat(duration).isLessThan(100);
}
```

### Resilience Pattern Testing
1. **Retry Mechanisms**: Test retry logic with various failure scenarios
2. **Circuit Breakers**: Validate circuit breaker state transitions
3. **Fallback Strategies**: Test fallback behavior when services are unavailable
4. **Bulkhead Isolation**: Test resource isolation between components
5. **Rate Limiting**: Validate rate limiting and throttling behavior

---

## Test Isolation and Independence

### Isolation Strategies

#### 1. Database Isolation
```java
@SpringBootTest
@Testcontainers
@TestMethodOrder(OrderAnnotation.class)
class DatabaseIsolationIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> database = new PostgreSQLContainer<>("postgres:15")
        .withDatabaseName("test_db")
        .withUsername("test")
        .withPassword("test");
    
    @Autowired
    private TestEntityManager entityManager;
    
    @BeforeEach
    void setupTestData() {
        // Clean database before each test
        entityManager.getEntityManager()
            .createNativeQuery("TRUNCATE TABLE users, orders, products CASCADE")
            .executeUpdate();
        entityManager.flush();
    }
    
    @Test
    @Transactional
    void test_isolated_from_other_tests() {
        // This test runs with clean database state
        var user = new User("test@example.com", "Test User");
        entityManager.persistAndFlush(user);
        
        assertThat(entityManager.find(User.class, user.getId()))
            .isNotNull();
    }
}
```

#### 2. Test Configuration Isolation
```java
@TestConfiguration
public class IsolatedTestConfig {
    
    @Bean
    @Primary
    @Scope("prototype")  // New instance for each test
    public ExternalServiceClient testExternalServiceClient() {
        return new MockExternalServiceClient();
    }
    
    @Bean
    @Primary
    public CacheManager testCacheManager() {
        // Use simple cache manager for tests
        return new ConcurrentMapCacheManager();
    }
}
```

#### 3. Port and Resource Isolation
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class ApiIntegrationTest {
    
    @LocalServerPort
    private int port;
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void should_handle_concurrent_requests() {
        // Tests can run in parallel without port conflicts
        String url = "http://localhost:" + port + "/api/users";
        
        var response = restTemplate.getForEntity(url, String.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
}
```

### Independence Best Practices
1. **No Shared State**: Tests should not depend on execution order
2. **Clean Setup/Teardown**: Reset state before and after each test
3. **Isolated Resources**: Use separate databases, ports, and file systems
4. **Independent Data**: Each test creates its own test data
5. **Parallel Execution**: Tests should be able to run concurrently

---

## CI/CD Integration

### Pipeline Configuration

#### 1. Multi-Stage Pipeline
```yaml
# GitLab CI example
stages:
  - unit-test
  - component-integration
  - service-integration
  - api-integration
  - deploy-staging
  - e2e-test
  - deploy-production

unit-test:
  stage: unit-test
  script:
    - ./gradlew test
  artifacts:
    reports:
      junit: build/test-results/test/TEST-*.xml
    paths:
      - build/reports/tests/

component-integration:
  stage: component-integration
  needs: ["unit-test"]
  script:
    - ./gradlew componentIntegrationTest
  services:
    - postgres:15
    - redis:7
  artifacts:
    reports:
      junit: build/test-results/componentIntegrationTest/TEST-*.xml

service-integration:
  stage: service-integration
  needs: ["component-integration"]
  script:
    - ./gradlew serviceIntegrationTest
  artifacts:
    reports:
      junit: build/test-results/serviceIntegrationTest/TEST-*.xml

api-integration:
  stage: api-integration
  needs: ["service-integration"]
  script:
    - ./gradlew apiIntegrationTest
  artifacts:
    reports:
      junit: build/test-results/apiIntegrationTest/TEST-*.xml

e2e-test:
  stage: e2e-test
  needs: ["deploy-staging"]
  script:
    - ./gradlew e2eTest -PtargetEnvironment=staging
  only:
    - main
    - develop
```

#### 2. GitHub Actions Configuration
```yaml
name: Integration Test Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Cache Gradle packages
        uses: actions/cache@v3
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
      
      - name: Run Unit Tests
        run: ./gradlew test
      
      - name: Publish Test Results
        uses: dorny/test-reporter@v1
        if: success() || failure()
        with:
          name: Unit Test Results
          path: build/test-results/test/TEST-*.xml
          reporter: java-junit

  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    strategy:
      matrix:
        test-type: [component, service, database, api]
    
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Cache Gradle packages
        uses: actions/cache@v3
        with:
          path: |
            ~/.gradle/caches
            ~/.gradle/wrapper
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
      
      - name: Run Integration Tests
        run: ./gradlew ${{ matrix.test-type }}IntegrationTest
      
      - name: Publish Test Results
        uses: dorny/test-reporter@v1
        if: success() || failure()
        with:
          name: ${{ matrix.test-type }} Integration Test Results
          path: build/test-results/${{ matrix.test-type }}IntegrationTest/TEST-*.xml
          reporter: java-junit

  coverage-report:
    runs-on: ubuntu-latest
    needs: [unit-tests, integration-tests]
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Generate Coverage Report
        run: ./gradlew jacocoTestReport
      
      - name: Upload Coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: build/reports/jacoco/test/jacocoTestReport.xml
```

### Quality Gates
```gradle
// Gradle configuration for quality gates
jacoco {
    toolVersion = "0.8.8"
}

jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = 0.80  // 80% minimum coverage
            }
        }
        
        rule {
            element = 'CLASS'
            limit {
                counter = 'BRANCH'
                value = 'COVEREDRATIO'
                minimum = 0.75  // 75% branch coverage
            }
        }
    }
}

// Fail build if coverage is below threshold
check.dependsOn jacocoTestCoverageVerification
```

---

## Best Practices by Technology Stack

### Spring Boot (Java/Kotlin)

#### Test Configuration
```java
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = {
        "spring.datasource.url=jdbc:h2:mem:testdb",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "logging.level.org.springframework.web=DEBUG"
    }
)
@TestPropertySource("/application-test.properties")
@ActiveProfiles("test")
@Testcontainers
class SpringBootIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}
```

#### Service Layer Testing
```java
@SpringBootTest
@Transactional
class UserServiceIntegrationTest {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private UserRepository userRepository;
    
    @MockBean
    private EmailService emailService;
    
    @Test
    void should_create_user_and_send_notification() {
        // Test implementation
    }
}
```

#### Web Layer Testing
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserControllerIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void should_create_user_via_api() {
        var request = new CreateUserRequest("test@example.com", "Test User");
        
        var response = restTemplate.postForEntity("/api/users", request, UserResponse.class);
        
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody().getEmail()).isEqualTo("test@example.com");
    }
}
```

### Node.js/Express

#### Test Setup
```javascript
// test/integration/setup.js
const { MongoMemoryServer } = require('mongodb-memory-server');
const mongoose = require('mongoose');
const app = require('../../src/app');

let mongoServer;

beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();
    await mongoose.connect(mongoUri);
});

afterAll(async () => {
    await mongoose.disconnect();
    await mongoServer.stop();
});

beforeEach(async () => {
    const collections = mongoose.connection.collections;
    for (const key in collections) {
        await collections[key].deleteMany({});
    }
});

module.exports = { app };
```

#### API Integration Testing
```javascript
// test/integration/user.test.js
const request = require('supertest');
const { app } = require('./setup');
const User = require('../../src/models/User');

describe('User API Integration', () => {
    describe('POST /api/users', () => {
        it('should create user and return 201', async () => {
            const userData = {
                email: 'test@example.com',
                name: 'Test User',
                password: 'password123'
            };
            
            const response = await request(app)
                .post('/api/users')
                .send(userData)
                .expect(201);
            
            expect(response.body).toMatchObject({
                email: userData.email,
                name: userData.name
            });
            
            const savedUser = await User.findOne({ email: userData.email });
            expect(savedUser).toBeTruthy();
        });
    });
});
```

### .NET Core

#### Test Configuration
```csharp
// IntegrationTestFixture.cs
public class IntegrationTestFixture : IDisposable
{
    public WebApplicationFactory<Program> Factory { get; private set; }
    public HttpClient Client { get; private set; }
    
    public IntegrationTestFixture()
    {
        Factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    // Remove real database
                    services.RemoveDbContext<ApplicationDbContext>();
                    
                    // Add in-memory database
                    services.AddDbContext<ApplicationDbContext>(options =>
                        options.UseInMemoryDatabase("TestDb"));
                    
                    // Mock external services
                    services.AddScoped<IEmailService, MockEmailService>();
                });
            });
            
        Client = Factory.CreateClient();
    }
    
    public void Dispose()
    {
        Client?.Dispose();
        Factory?.Dispose();
    }
}
```

#### Integration Test Example
```csharp
// UserControllerIntegrationTests.cs
public class UserControllerIntegrationTests : IClassFixture<IntegrationTestFixture>
{
    private readonly IntegrationTestFixture _fixture;
    
    public UserControllerIntegrationTests(IntegrationTestFixture fixture)
    {
        _fixture = fixture;
    }
    
    [Fact]
    public async Task CreateUser_ShouldReturn201_WhenValidData()
    {
        // Arrange
        var userData = new CreateUserRequest
        {
            Email = "test@example.com",
            Name = "Test User"
        };
        
        var json = JsonSerializer.Serialize(userData);
        var content = new StringContent(json, Encoding.UTF8, "application/json");
        
        // Act
        var response = await _fixture.Client.PostAsync("/api/users", content);
        
        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        
        var responseBody = await response.Content.ReadAsStringAsync();
        var user = JsonSerializer.Deserialize<UserResponse>(responseBody);
        user.Email.Should().Be(userData.Email);
    }
}
```

### Python/Django

#### Test Configuration
```python
# conftest.py
import pytest
from django.test import override_settings
from django.core.management import call_command

@pytest.fixture(scope='session')
def django_db_setup():
    """Setup test database."""
    call_command('migrate', verbosity=0, interactive=False)

@pytest.fixture
def api_client():
    """API client for integration tests."""
    from rest_framework.test import APIClient
    return APIClient()

@pytest.fixture
def user_factory():
    """Factory for creating test users."""
    import factory
    from django.contrib.auth.models import User
    
    class UserFactory(factory.django.DjangoModelFactory):
        class Meta:
            model = User
        
        username = factory.Sequence(lambda n: f"user{n}")
        email = factory.LazyAttribute(lambda obj: f"{obj.username}@example.com")
        first_name = factory.Faker('first_name')
        last_name = factory.Faker('last_name')
    
    return UserFactory
```

#### Integration Test Example
```python
# test_user_integration.py
import pytest
from django.urls import reverse
from rest_framework import status

@pytest.mark.django_db
class TestUserIntegration:
    
    def test_create_user_should_return_201(self, api_client):
        """Test user creation via API."""
        url = reverse('user-list')
        data = {
            'username': 'testuser',
            'email': 'test@example.com',
            'password': 'testpass123'
        }
        
        response = api_client.post(url, data, format='json')
        
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['username'] == data['username']
        assert response.data['email'] == data['email']
        
    def test_user_workflow_integration(self, api_client, user_factory):
        """Test complete user workflow."""
        # Create user
        user = user_factory()
        
        # Login
        login_url = reverse('token_obtain_pair')
        login_data = {'username': user.username, 'password': 'testpass'}
        login_response = api_client.post(login_url, login_data)
        
        # Use token for authenticated request
        token = login_response.data['access']
        api_client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        
        # Make authenticated request
        profile_url = reverse('user-profile')
        response = api_client.get(profile_url)
        
        assert response.status_code == status.HTTP_200_OK
```

---

## Reference URLs for Claude Code Integration

### Official Testing Documentation
- **Spring Boot Testing**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing
- **TestContainers**: https://www.testcontainers.org/
- **JUnit 5**: https://junit.org/junit5/docs/current/user-guide/
- **Mockito**: https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html
- **WireMock**: https://wiremock.org/docs/
- **RestAssured**: https://rest-assured.io/
- **Testcontainers Spring Boot**: https://www.testcontainers.org/modules/spring_boot/

### Integration Testing Resources
- **Martin Fowler - Integration Testing**: https://martinfowler.com/bliki/IntegrationTest.html
- **Google Testing Blog**: https://testing.googleblog.com/
- **Microsoft Testing Guidelines**: https://docs.microsoft.com/en-us/dotnet/core/testing/
- **Test Pyramid**: https://martinfowler.com/bliki/TestPyramid.html

### Framework-Specific Resources
- **Spring Boot Test Slices**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing.spring-boot-applications.autoconfigured-tests
- **Jest Integration Testing**: https://jestjs.io/docs/testing-frameworks
- **pytest Integration**: https://docs.pytest.org/en/stable/
- **NUnit Integration**: https://docs.nunit.org/

### CI/CD Integration
- **GitHub Actions**: https://docs.github.com/en/actions
- **GitLab CI**: https://docs.gitlab.com/ee/ci/
- **Jenkins Pipeline**: https://www.jenkins.io/doc/book/pipeline/
- **Azure DevOps**: https://docs.microsoft.com/en-us/azure/devops/pipelines/

### Performance Testing
- **JMeter**: https://jmeter.apache.org/
- **Gatling**: https://gatling.io/docs/
- **K6**: https://k6.io/docs/
- **Artillery**: https://artillery.io/docs/

### Contract Testing
- **Pact**: https://docs.pact.io/
- **Spring Cloud Contract**: https://spring.io/projects/spring-cloud-contract
- **WireMock**: https://wiremock.org/docs/verifying/

---

## Analysis Checklist for Claude Code

### Integration Test Quality Assessment

#### ✅ Test Organization Compliance
- [ ] Integration tests separated from unit tests
- [ ] Tests organized by integration scope (component, service, API, etc.)
- [ ] Test files follow naming conventions: `[Component]IntegrationTest`
- [ ] Test packages mirror source code structure
- [ ] Shared test utilities properly organized

#### ✅ Test Coverage Compliance
- [ ] Component integration coverage: 70-85%
- [ ] Service integration coverage: 80-95%
- [ ] Database integration coverage: 90-100%
- [ ] API integration coverage: 95-100%
- [ ] Critical business workflows tested end-to-end

#### ✅ Test Structure Compliance
- [ ] Tests follow AAA or Given-When-Then structure
- [ ] Proper test setup and teardown implemented
- [ ] Test methods have descriptive names describing scenarios
- [ ] Tests are organized in logical groups/nested classes
- [ ] Test documentation explains integration scope

#### ✅ Test Environment Compliance
- [ ] TestContainers used for database integration
- [ ] External services properly mocked or stubbed
- [ ] Test-specific configuration files present
- [ ] Environment isolation implemented
- [ ] Random ports used to avoid conflicts

#### ✅ Test Data Management Compliance
- [ ] Test data builders and fixtures used appropriately
- [ ] Test data cleanup implemented
- [ ] Independent test data for each test
- [ ] Realistic test data that represents production scenarios
- [ ] Minimal test data creation (only what's needed)

#### ✅ Performance Compliance
- [ ] Integration tests complete within acceptable time limits
- [ ] Parallel execution capability where appropriate
- [ ] Resource management optimized (connection pooling, etc.)
- [ ] Performance monitoring implemented for critical tests
- [ ] Test execution time tracking and alerting

#### ✅ Error Handling Compliance
- [ ] Failure scenarios tested (timeouts, service unavailability)
- [ ] Recovery mechanisms validated (retry, circuit breaker)
- [ ] Transaction rollback scenarios tested
- [ ] Error propagation and handling verified
- [ ] Resilience patterns implementation tested

#### ✅ CI/CD Integration Compliance
- [ ] Integration tests separated into appropriate build stages
- [ ] Quality gates implemented with coverage thresholds
- [ ] Test results properly reported and archived
- [ ] Integration tests run in appropriate pipeline stages
- [ ] Parallel test execution configured where beneficial

#### ✅ Technology-Specific Compliance
- [ ] Framework-specific testing patterns followed
- [ ] Appropriate test annotations and configurations used
- [ ] Mock/stub libraries used correctly
- [ ] Test slicing implemented where applicable
- [ ] Security testing integrated appropriately

---

This comprehensive integration testing best practices guide provides technology-agnostic principles and specific implementation examples for creating, organizing, and maintaining high-quality integration tests that validate component interactions, data flow, and end-to-end functionality across software systems.