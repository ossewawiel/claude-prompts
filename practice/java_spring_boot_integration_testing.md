# Spring Boot Integration Testing Best Practices - Java

## Document Information
- **Purpose**: Spring Boot specific integration testing patterns for Java web services
- **Target Framework**: Spring Boot 3.x with Java 21+
- **Testing Framework**: JUnit 5 + Spring Boot Test
- **Integration**: Claude Code friendly for generating integration tests
- **Last Updated**: June 27, 2025
- **Document Version**: 1.0.0

## Essential Libraries and Dependencies

### Gradle Configuration (build.gradle)
```gradle
dependencies {
    // Spring Boot Test Starter (MANDATORY - includes JUnit 5, Testcontainers)
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    
    // TestContainers for real database testing (MANDATORY)
    testImplementation 'org.testcontainers:junit-jupiter:1.19.0'
    testImplementation 'org.testcontainers:postgresql:1.19.0'
    testImplementation 'org.testcontainers:redis:1.19.0'
    
    // WireMock for external service mocking
    testImplementation 'com.github.tomakehurst:wiremock-jre8:3.0.1'
    
    // Spring Security testing
    testImplementation 'org.springframework.security:spring-security-test'
    
    // JSON assertions
    testImplementation 'com.jayway.jsonpath:json-path:2.8.0'
    
    // Test data generation
    testImplementation 'net.datafaker:datafaker:2.0.1'
}

// Integration test source set
sourceSets {
    integrationTest {
        java.srcDir 'src/integration-test/java'
        resources.srcDir 'src/integration-test/resources'
        compileClasspath += main.output + test.output
        runtimeClasspath += main.output + test.output
    }
}

// Integration test task
task integrationTest(type: Test) {
    description = 'Runs integration tests'
    group = 'verification'
    testClassesDirs = sourceSets.integrationTest.output.classesDirs
    classpath = sourceSets.integrationTest.runtimeClasspath
    useJUnitPlatform()
    testLogging {
        events "passed", "skipped", "failed"
    }
}

check.dependsOn integrationTest
```

## Spring Boot Test Annotations Hierarchy

### 1. @SpringBootTest - Full Application Context
Use for end-to-end integration tests:

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@TestMethodOrder(OrderAnnotation.class)
class UserServiceIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private UserRepository userRepository;
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Test
    @Order(1)
    void shouldCreateUserWithCompleteWorkflow() {
        // Given
        CreateUserRequest request = new CreateUserRequest("test@example.com", "Test User");
        
        // When
        ResponseEntity<UserResponse> response = restTemplate.postForEntity(
            "/api/users", request, UserResponse.class);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody().email()).isEqualTo("test@example.com");
        
        // Verify database persistence
        Optional<User> savedUser = userRepository.findByEmail("test@example.com");
        assertThat(savedUser).isPresent();
    }
}
```

### 2. @WebMvcTest - Web Layer Testing
Use for controller integration tests:

```java
@WebMvcTest(UserController.class)
class UserControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private UserService userService;
    
    @Test
    void shouldReturnUserWhenValidIdProvided() throws Exception {
        // Given
        User user = new User(1L, "test@example.com", "Test User");
        when(userService.findById(1L)).thenReturn(user);
        
        // When & Then
        mockMvc.perform(get("/api/users/1")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("test@example.com"))
                .andExpect(jsonPath("$.name").value("Test User"));
                
        verify(userService).findById(1L);
    }
    
    @Test
    void shouldReturnBadRequestWhenInvalidEmailProvided() throws Exception {
        // Given
        String invalidUserJson = """
            {
                "email": "invalid-email",
                "name": "Test User"
            }
            """;
        
        // When & Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(invalidUserJson))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors").isArray())
                .andExpect(jsonPath("$.errors[0].field").value("email"));
    }
}
```

### 3. @DataJpaTest - Repository Layer Testing
Use for database integration tests:

```java
@DataJpaTest
@Testcontainers
class UserRepositoryIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Test
    void shouldFindUserByEmailIgnoreCase() {
        // Given
        User user = new User("TEST@EXAMPLE.COM", "Test User");
        entityManager.persistAndFlush(user);
        
        // When
        Optional<User> found = userRepository.findByEmailIgnoreCase("test@example.com");
        
        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("TEST@EXAMPLE.COM");
    }
    
    @Test
    void shouldReturnUsersCreatedAfterDate() {
        // Given
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(1);
        User oldUser = new User("old@example.com", "Old User");
        User newUser = new User("new@example.com", "New User");
        
        entityManager.persistAndFlush(oldUser);
        entityManager.persistAndFlush(newUser);
        
        // When
        List<User> recentUsers = userRepository.findByCreatedAtAfter(cutoffDate);
        
        // Then
        assertThat(recentUsers).hasSize(1);
        assertThat(recentUsers.get(0).getEmail()).isEqualTo("new@example.com");
    }
}
```

## TestContainers Patterns

### Database Container Configuration
```java
@Testcontainers
public abstract class DatabaseIntegrationTestBase {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
            .withDatabaseName("integration_test")
            .withUsername("testuser")
            .withPassword("testpass")
            .withReuse(true);  // Reuse container across test classes
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.jpa.hibernate.ddl-auto", () -> "create-drop");
    }
}

// Extend from base class for consistent setup
@SpringBootTest
class UserServiceIntegrationTest extends DatabaseIntegrationTestBase {
    // Test implementation
}
```

### Redis Container for Caching Tests
```java
@Testcontainers
class CacheIntegrationTest {
    
    @Container
    static GenericContainer<?> redis = new GenericContainer<>("redis:7-alpine")
            .withExposedPorts(6379);
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.data.redis.host", redis::getHost);
        registry.add("spring.data.redis.port", redis::getFirstMappedPort);
    }
    
    @Test
    void shouldCacheUserData() {
        // Test caching behavior
    }
}
```

## Security Integration Testing

### With Mock Authentication
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class SecurityIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldAllowAdminAccess() throws Exception {
        ResponseEntity<String> response = restTemplate.getForEntity("/api/admin/users", String.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
    
    @Test
    void shouldRequireAuthenticationForProtectedEndpoint() {
        ResponseEntity<String> response = restTemplate.getForEntity("/api/admin/users", String.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }
}
```

### JWT Authentication Testing
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class JwtAuthenticationIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private JwtTokenProvider tokenProvider;
    
    @Test
    void shouldAuthenticateWithValidJwtToken() {
        // Given
        String token = tokenProvider.generateToken("testuser", List.of("ROLE_USER"));
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        HttpEntity<String> entity = new HttpEntity<>(headers);
        
        // When
        ResponseEntity<String> response = restTemplate.exchange(
            "/api/profile", HttpMethod.GET, entity, String.class);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
}
```

## External Service Integration with WireMock

### Email Service Integration Test
```java
@SpringBootTest
@TestPropertySource(properties = "email.service.url=http://localhost:${wiremock.server.port}")
class EmailServiceIntegrationTest {
    
    @RegisterExtension
    static WireMockExtension wireMock = WireMockExtension.newInstance()
            .options(wireMockConfig().port(0))
            .build();
    
    @Autowired
    private EmailService emailService;
    
    @Test
    void shouldSendEmailSuccessfully() {
        // Given
        wireMock.stubFor(post(urlEqualTo("/api/email/send"))
                .willReturn(aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", "application/json")
                        .withBody("{\"status\":\"sent\"}")));
        
        // When
        EmailResult result = emailService.sendWelcomeEmail("test@example.com");
        
        // Then
        assertThat(result.isSuccessful()).isTrue();
        
        wireMock.verify(postRequestedFor(urlEqualTo("/api/email/send"))
                .withRequestBody(containingJson("{\"to\":\"test@example.com\"}")));
    }
    
    @Test
    void shouldHandleEmailServiceFailure() {
        // Given
        wireMock.stubFor(post(urlEqualTo("/api/email/send"))
                .willReturn(aResponse().withStatus(500)));
        
        // When & Then
        assertThatThrownBy(() -> emailService.sendWelcomeEmail("test@example.com"))
                .isInstanceOf(EmailServiceException.class)
                .hasMessageContaining("Failed to send email");
    }
}
```

## Transaction Testing Patterns

### Testing Rollback Scenarios
```java
@SpringBootTest
@Transactional
@Rollback
class TransactionIntegrationTest extends DatabaseIntegrationTestBase {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private OrderService orderService;
    
    @Test
    void shouldRollbackWhenServiceThrowsException() {
        // Given
        User user = userService.createUser(new CreateUserRequest("test@example.com", "Test User"));
        
        // When & Then
        assertThatThrownBy(() -> orderService.createOrderWithException(user.getId()))
                .isInstanceOf(OrderProcessingException.class);
        
        // Verify user still exists but no order was created
        assertThat(userService.findById(user.getId())).isPresent();
        assertThat(orderService.findByUserId(user.getId())).isEmpty();
    }
}
```

## Performance Testing Integration

### Response Time Testing
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class PerformanceIntegrationTest extends DatabaseIntegrationTestBase {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    @Timeout(value = 2, unit = TimeUnit.SECONDS)
    void shouldRespondWithinAcceptableTime() {
        // When
        ResponseEntity<String> response = restTemplate.getForEntity("/api/users", String.class);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
    
    @Test
    void shouldHandleConcurrentRequests() throws InterruptedException {
        int numberOfThreads = 10;
        CountDownLatch latch = new CountDownLatch(numberOfThreads);
        List<CompletableFuture<ResponseEntity<String>>> futures = new ArrayList<>();
        
        for (int i = 0; i < numberOfThreads; i++) {
            CompletableFuture<ResponseEntity<String>> future = CompletableFuture.supplyAsync(() -> {
                try {
                    return restTemplate.getForEntity("/api/users", String.class);
                } finally {
                    latch.countDown();
                }
            });
            futures.add(future);
        }
        
        latch.await(10, TimeUnit.SECONDS);
        
        for (CompletableFuture<ResponseEntity<String>> future : futures) {
            ResponseEntity<String> response = future.get();
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        }
    }
}
```

## Test Data Management

### Test Data Builders
```java
public class UserTestDataBuilder {
    private String email = "test@example.com";
    private String name = "Test User";
    private UserRole role = UserRole.USER;
    private LocalDateTime createdAt = LocalDateTime.now();
    
    public static UserTestDataBuilder aUser() {
        return new UserTestDataBuilder();
    }
    
    public UserTestDataBuilder withEmail(String email) {
        this.email = email;
        return this;
    }
    
    public UserTestDataBuilder withName(String name) {
        this.name = name;
        return this;
    }
    
    public UserTestDataBuilder withRole(UserRole role) {
        this.role = role;
        return this;
    }
    
    public UserTestDataBuilder createdAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
        return this;
    }
    
    public User build() {
        return new User(email, name, role, createdAt);
    }
    
    public CreateUserRequest buildRequest() {
        return new CreateUserRequest(email, name);
    }
}

// Usage in tests
@Test
void shouldCreateAdminUser() {
    User admin = UserTestDataBuilder.aUser()
            .withEmail("admin@example.com")
            .withRole(UserRole.ADMIN)
            .build();
            
    User saved = userService.save(admin);
    assertThat(saved.getRole()).isEqualTo(UserRole.ADMIN);
}
```

### Database Cleanup Utility
```java
@Component
@Profile("test")
public class DatabaseCleanupUtility {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @EventListener
    public void cleanupDatabase(TestExecutionEvent event) {
        if (event.getPhase() == TestExecutionEvent.Phase.AFTER_TEST_METHOD) {
            cleanupAllTables();
        }
    }
    
    private void cleanupAllTables() {
        jdbcTemplate.execute("TRUNCATE TABLE orders, users RESTART IDENTITY CASCADE");
    }
}
```

## Common Anti-Patterns to Avoid

### ❌ Incorrect: Using @MockBean in @SpringBootTest
```java
@SpringBootTest  // Full context but mocking core components
class BadIntegrationTest {
    
    @MockBean  // Don't mock what you're trying to integration test
    private UserRepository userRepository;
    
    @Test
    void badTest() {
        // This isn't testing integration - it's a unit test in disguise
    }
}
```

### ✅ Correct: Use Real Components or Slice Tests
```java
@SpringBootTest  // Test real integration
class GoodIntegrationTest extends DatabaseIntegrationTestBase {
    
    @Autowired  // Use real repository
    private UserRepository userRepository;
    
    @Test
    void goodTest() {
        // Tests actual database interaction
    }
}

// OR use slice tests for focused testing
@WebMvcTest(UserController.class)  // Test only web layer
class UserControllerTest {
    @MockBean  // Mock dependencies outside web layer
    private UserService userService;
}
```

### ❌ Incorrect: Test Interdependence
```java
@TestMethodOrder(OrderAnnotation.class)
class BadIntegrationTest {
    
    private static Long userId;  // Sharing state between tests
    
    @Test
    @Order(1)
    void createUser() {
        User user = userService.create("test@example.com");
        userId = user.getId();  // BAD: Tests depend on each other
    }
    
    @Test
    @Order(2)
    void updateUser() {
        userService.update(userId, "Updated Name");  // BAD: Depends on previous test
    }
}
```

### ✅ Correct: Independent Tests
```java
class GoodIntegrationTest {
    
    @Test
    void shouldCreateUser() {
        User user = userService.create("create@example.com");
        assertThat(user.getId()).isNotNull();
    }
    
    @Test
    void shouldUpdateUser() {
        // Given - Create test data independently
        User user = userService.create("update@example.com");
        
        // When
        User updated = userService.update(user.getId(), "Updated Name");
        
        // Then
        assertThat(updated.getName()).isEqualTo("Updated Name");
    }
}
```

## Essential Online Resources

### Official Spring Boot Documentation
- **Spring Boot Testing**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing
- **Test Slices**: https://docs.spring.io/spring-boot/docs/current/reference/html/test-auto-configuration.html
- **Spring Security Testing**: https://docs.spring.io/spring-security/reference/servlet/test/index.html
- **Spring Data JPA Testing**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#testing

### Testing Libraries
- **TestContainers**: https://testcontainers.com/guides/testing-spring-boot-rest-api-using-testcontainers/
- **WireMock**: https://wiremock.org/docs/spring-boot/
- **JUnit 5**: https://junit.org/junit5/docs/current/user-guide/
- **AssertJ**: https://assertj.github.io/doc/

### Best Practices & Guides
- **Spring Boot Testing Best Practices**: https://reflectoring.io/spring-boot-testing/
- **Integration Testing with TestContainers**: https://www.baeldung.com/spring-boot-testcontainers-integration-test
- **Testing Spring Security**: https://www.baeldung.com/spring-security-integration-tests
- **Spring Boot Test Configuration**: https://www.baeldung.com/spring-boot-testing

## Claude Code Generation Templates

### Integration Test Class Template
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class [FeatureName]IntegrationTest extends DatabaseIntegrationTestBase {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private [Repository] repository;
    
    @Test
    void should[ExpectedBehavior]When[Condition]() {
        // Given
        [TestDataSetup]
        
        // When
        ResponseEntity<[ResponseType]> response = restTemplate.[httpMethod](
            "[endpoint]", [requestBody], [ResponseType].class);
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.[EXPECTED_STATUS]);
        assertThat(response.getBody().[property]()).isEqualTo([expectedValue]);
        
        // Verify persistence
        [DatabaseVerification]
    }
}
```

### Repository Integration Test Template
```java
@DataJpaTest
@Testcontainers
class [Entity]RepositoryIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private [Entity]Repository repository;
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    @Test
    void should[ExpectedBehavior]When[QueryCondition]() {
        // Given
        [Entity] entity = [TestDataBuilder].build();
        entityManager.persistAndFlush(entity);
        
        // When
        [ResultType] result = repository.[methodName]([parameters]);
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.[property]()).isEqualTo([expectedValue]);
    }
}
```

---

This document provides Spring Boot specific integration testing patterns optimized for Claude Code generation, focusing on practical examples and avoiding duplication of general testing principles already covered in the existing documentation.