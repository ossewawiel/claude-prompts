# Spring Boot Kotlin Integration Testing Best Practices

## Document Information
- **Purpose**: Spring Boot Kotlin-specific integration testing patterns and libraries
- **Target Framework**: Spring Boot 3.x with Kotlin 1.9+
- **Testing Framework**: JUnit 5 + Spring Boot Test + MockK
- **Integration**: Claude Code friendly for generating integration tests
- **Last Updated**: June 27, 2025
- **Document Version**: 1.0.0
- **Complements**: [integration_testing_best_practices.md](practice/integration_testing_best_practices.md)

## Essential Libraries and Dependencies

### Gradle Kotlin DSL Configuration
```kotlin
dependencies {
    // Spring Boot Test Starter (MANDATORY)
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.mockito", module = "mockito-core") // Use MockK instead
    }
    
    // Kotlin Testing Libraries (MANDATORY)
    testImplementation("io.mockk:mockk:1.13.7")
    testImplementation("com.ninja-squad:springmockk:4.0.2")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    
    // TestContainers (MANDATORY for database integration)
    testImplementation("org.testcontainers:junit-jupiter:1.19.0")
    testImplementation("org.testcontainers:postgresql:1.19.0")
    testImplementation("org.testcontainers:redis:1.19.0")
    testImplementation("org.testcontainers:kafka:1.19.0")
    
    // Spring Security Testing
    testImplementation("org.springframework.security:spring-security-test")
    
    // JSON and Web Testing
    testImplementation("com.jayway.jsonpath:json-path:2.8.0")
    testImplementation("org.springframework.boot:spring-boot-starter-webflux") // For WebTestClient
    
    // External Service Mocking
    testImplementation("com.github.tomakehurst:wiremock-jre8:3.0.1")
    
    // Coroutines Testing
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    
    // Test Data Generation
    testImplementation("net.datafaker:datafaker:2.0.1")
}

tasks.test {
    useJUnitPlatform()
    systemProperty("spring.profiles.active", "integration-test")
    testLogging {
        events("passed", "skipped", "failed")
        exceptionFormat = org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
    }
}
```

## Spring Boot Test Slice Annotations for Kotlin

### 1. @WebMvcTest - Controller Layer Testing
```kotlin
@WebMvcTest(UserController::class)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UserControllerIntegrationTest {
    
    @Autowired
    private lateinit var mockMvc: MockMvc
    
    @MockkBean
    private lateinit var userService: UserService
    
    @Test
    fun `should create user when valid request provided`() {
        // Given
        val createRequest = CreateUserRequest(
            email = "test@example.com",
            name = "Test User"
        )
        val expectedUser = User(1L, "test@example.com", "Test User")
        
        every { userService.createUser(any()) } returns expectedUser
        
        // When & Then
        mockMvc.perform(
            post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(createRequest))
        )
        .andExpect(status().isCreated)
        .andExpect(jsonPath("$.id").value(1))
        .andExpect(jsonPath("$.email").value("test@example.com"))
        .andExpect(jsonPath("$.name").value("Test User"))
        
        verify(exactly = 1) { userService.createUser(any()) }
    }
}
```

### 2. @DataJpaTest - Repository Layer Testing
```kotlin
@DataJpaTest
@Testcontainers
class UserRepositoryIntegrationTest {
    
    companion object {
        @Container
        @JvmStatic
        val postgres = PostgreSQLContainer("postgres:15-alpine")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test")
    }
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Autowired
    private lateinit var testEntityManager: TestEntityManager
    
    @Test
    fun `should find user by email when user exists`() {
        // Given
        val user = User(email = "test@example.com", name = "Test User")
        testEntityManager.persistAndFlush(user)
        
        // When
        val foundUser = userRepository.findByEmail("test@example.com")
        
        // Then
        assertThat(foundUser).isNotNull
        assertThat(foundUser?.email).isEqualTo("test@example.com")
        assertThat(foundUser?.name).isEqualTo("Test User")
    }
    
    @Test
    fun `should return null when user does not exist`() {
        // When
        val foundUser = userRepository.findByEmail("nonexistent@example.com")
        
        // Then
        assertThat(foundUser).isNull()
    }
}
```

### 3. @SpringBootTest - Full Integration Testing
```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@ActiveProfiles("integration-test")
class UserWorkflowIntegrationTest {
    
    companion object {
        @Container
        @JvmStatic
        val postgres = PostgreSQLContainer("postgres:15-alpine")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test")
        
        @Container
        @JvmStatic
        val redis = GenericContainer<Nothing>("redis:7-alpine")
            .withExposedPorts(6379)
    }
    
    @Autowired
    private lateinit var restTemplate: TestRestTemplate
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @LocalServerPort
    private var port: Int = 0
    
    @Test
    fun `should complete user registration workflow successfully`() {
        // Given
        val createRequest = CreateUserRequest(
            email = "workflow@example.com",
            name = "Workflow User"
        )
        
        // When - Create user
        val createResponse = restTemplate.postForEntity(
            "/api/users",
            createRequest,
            UserResponse::class.java
        )
        
        // Then - Verify creation
        assertThat(createResponse.statusCode).isEqualTo(HttpStatus.CREATED)
        assertThat(createResponse.body?.email).isEqualTo("workflow@example.com")
        
        val userId = createResponse.body?.id
        assertThat(userId).isNotNull()
        
        // When - Retrieve user
        val getResponse = restTemplate.getForEntity(
            "/api/users/$userId",
            UserResponse::class.java
        )
        
        // Then - Verify retrieval
        assertThat(getResponse.statusCode).isEqualTo(HttpStatus.OK)
        assertThat(getResponse.body?.email).isEqualTo("workflow@example.com")
        
        // Verify database persistence
        val persistedUser = userRepository.findById(userId!!)
        assertThat(persistedUser).isPresent()
        assertThat(persistedUser.get().email).isEqualTo("workflow@example.com")
    }
}
```

## TestContainers Configuration for Kotlin

### Database Container Setup
```kotlin
@Component
@TestConfiguration
class TestContainerConfig {
    
    companion object {
        @Container
        @JvmStatic
        val postgres: PostgreSQLContainer<*> = PostgreSQLContainer("postgres:15-alpine")
            .withDatabaseName("integration_test")
            .withUsername("test_user")
            .withPassword("test_password")
            .withReuse(true) // Reuse container across tests
        
        init {
            postgres.start()
        }
    }
    
    @Bean
    @Primary
    @DirtiesContext
    fun dataSource(): DataSource {
        val config = HikariConfig()
        config.jdbcUrl = postgres.jdbcUrl
        config.username = postgres.username
        config.password = postgres.password
        config.driverClassName = postgres.driverClassName
        return HikariDataSource(config)
    }
}
```

### Redis Container for Caching Tests
```kotlin
@TestConfiguration
class RedisTestConfiguration {
    
    companion object {
        @Container
        @JvmStatic
        val redis: GenericContainer<Nothing> = GenericContainer<Nothing>("redis:7-alpine")
            .withExposedPorts(6379)
            .withReuse(true)
        
        init {
            redis.start()
        }
    }
    
    @Bean
    @Primary
    fun redisConnectionFactory(): LettuceConnectionFactory {
        return LettuceConnectionFactory(redis.host, redis.getMappedPort(6379))
    }
}
```

## Correct vs Incorrect Patterns

### ✅ CORRECT: MockK Usage in Integration Tests
```kotlin
@SpringBootTest
class UserServiceIntegrationTest {
    
    @MockkBean // Use @MockkBean for Spring integration
    private lateinit var emailService: EmailService
    
    @Autowired
    private lateinit var userService: UserService
    
    @Test
    fun `should send welcome email after user creation`() {
        // Given
        every { emailService.sendWelcomeEmail(any()) } just Runs
        
        // When
        userService.createUser(CreateUserRequest("test@example.com", "Test"))
        
        // Then
        verify(exactly = 1) { emailService.sendWelcomeEmail(any()) }
    }
}
```

### ❌ INCORRECT: Mockito Usage with Kotlin
```kotlin
@SpringBootTest
class UserServiceIntegrationTest {
    
    @MockBean // DON'T USE Mockito annotations with Kotlin
    private lateinit var emailService: EmailService
    
    @Test
    fun badTest() {
        // This will cause issues with Kotlin null safety and final classes
        when(emailService.sendWelcomeEmail(any())).thenReturn(Unit)
    }
}
```

### ✅ CORRECT: Null Safety in Integration Tests
```kotlin
@Test
fun `should handle nullable responses correctly`() {
    // Given
    val nonExistentId = 999L
    
    // When
    val response = restTemplate.getForEntity(
        "/api/users/$nonExistentId",
        String::class.java
    )
    
    // Then
    assertThat(response.statusCode).isEqualTo(HttpStatus.NOT_FOUND)
    assertThat(response.body).isNull() // Explicit null check
}
```

### ❌ INCORRECT: Unsafe Null Handling
```kotlin
@Test
fun badNullHandling() {
    val response = restTemplate.getForEntity("/api/users/999", UserResponse::class.java)
    assertThat(response.body.email).isEqualTo("test@example.com") // NPE risk!
}
```

### ✅ CORRECT: Transaction Testing
```kotlin
@SpringBootTest
@Transactional
@Rollback
class UserTransactionIntegrationTest {
    
    @Autowired
    private lateinit var userService: UserService
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Test
    fun `should rollback transaction when exception occurs`() {
        // Given
        val initialCount = userRepository.count()
        val invalidRequest = CreateUserRequest("", "") // Invalid data
        
        // When & Then
        assertThrows<ValidationException> {
            userService.createUserWithValidation(invalidRequest)
        }
        
        // Verify rollback
        assertThat(userRepository.count()).isEqualTo(initialCount)
    }
}
```

## Security Integration Testing

### JWT Authentication Testing
```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class AuthenticationIntegrationTest {
    
    @Autowired
    private lateinit var restTemplate: TestRestTemplate
    
    @Autowired
    private lateinit var jwtTokenProvider: JwtTokenProvider
    
    @Test
    fun `should allow access with valid JWT token`() {
        // Given
        val token = jwtTokenProvider.generateToken("test@example.com", listOf("USER"))
        val headers = HttpHeaders()
        headers.setBearerAuth(token)
        val entity = HttpEntity<Any>(headers)
        
        // When
        val response = restTemplate.exchange(
            "/api/users/profile",
            HttpMethod.GET,
            entity,
            UserProfile::class.java
        )
        
        // Then
        assertThat(response.statusCode).isEqualTo(HttpStatus.OK)
    }
    
    @Test
    @WithMockUser(roles = ["ADMIN"])
    fun `should allow admin access to protected endpoint`() {
        // Given - Mock user configured via annotation
        
        // When
        val response = restTemplate.getForEntity(
            "/api/admin/users",
            Array<UserResponse>::class.java
        )
        
        // Then
        assertThat(response.statusCode).isEqualTo(HttpStatus.OK)
    }
}
```

## External Service Integration Testing

### WireMock Configuration
```kotlin
@SpringBootTest
class ExternalServiceIntegrationTest {
    
    companion object {
        @RegisterExtension
        @JvmStatic
        val wireMock: WireMockExtension = WireMockExtension.newInstance()
            .options(wireMockConfig().port(8089))
            .build()
    }
    
    @Autowired
    private lateinit var paymentService: PaymentService
    
    @Test
    fun `should handle payment service success response`() {
        // Given
        wireMock.stubFor(
            post(urlEqualTo("/payments"))
                .willReturn(
                    aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", "application/json")
                        .withBody("""{"transactionId": "txn_123", "status": "success"}""")
                )
        )
        
        // When
        val result = paymentService.processPayment(
            PaymentRequest(amount = 100.0, currency = "USD")
        )
        
        // Then
        assertThat(result.transactionId).isEqualTo("txn_123")
        assertThat(result.status).isEqualTo(PaymentStatus.SUCCESS)
    }
}
```

## Performance Integration Testing

### Response Time Testing
```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class PerformanceIntegrationTest {
    
    @Autowired
    private lateinit var restTemplate: TestRestTemplate
    
    @Test
    fun `should respond within acceptable time limits`() {
        // Given
        val startTime = System.currentTimeMillis()
        
        // When
        val response = restTemplate.getForEntity("/api/users", Array<UserResponse>::class.java)
        
        // Then
        val endTime = System.currentTimeMillis()
        val responseTime = endTime - startTime
        
        assertThat(response.statusCode).isEqualTo(HttpStatus.OK)
        assertThat(responseTime).isLessThan(500) // Must respond within 500ms
    }
}
```

## Test Configuration Files

### application-integration-test.yml
```yaml
spring:
  datasource:
    url: jdbc:tc:postgresql:15:///integration_test
    driver-class-name: org.testcontainers.jdbc.ContainerDatabaseDriver
  
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
    properties:
      hibernate:
        format_sql: true
  
  redis:
    host: localhost
    port: 6379
  
  security:
    jwt:
      secret: test-secret-key-for-integration-testing
      expiration: 3600000
  
logging:
  level:
    org.springframework.web: DEBUG
    org.springframework.security: DEBUG
    org.testcontainers: INFO
    org.hibernate.SQL: DEBUG
```

## Claude Code Generation Patterns

### Integration Test Method Template
```kotlin
// Template for integration test methods
@Test
fun `should [expected behavior] when [integration scenario]`() {
    // Given - Test data setup
    val input = [test data]
    
    // When - Execute integration scenario
    val result = [integration action]
    
    // Then - Verify integration results
    assertThat(result.[property]).isEqualTo([expected value])
    verify { [dependency interaction] }
}
```

### Test Class Structure Template
```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@ActiveProfiles("integration-test")
class [ComponentName]IntegrationTest {
    
    companion object {
        @Container
        @JvmStatic
        val [container] = [ContainerType]("[image]")
            .with[Configuration]([parameters])
    }
    
    @Autowired
    private lateinit var [component]: [ComponentType]
    
    @MockkBean
    private lateinit var [dependency]: [DependencyType]
    
    @Test
    fun `should [behavior] when [condition]`() {
        // Given
        every { [dependency].[method](any()) } returns [mock response]
        
        // When
        val result = [component].[methodUnderTest]([input])
        
        // Then
        assertThat(result).isEqualTo([expected])
        verify(exactly = 1) { [dependency].[method](any()) }
    }
}
```

## Online Resources

### Spring Boot Testing Documentation
- **Spring Boot Testing Features**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing
- **Spring Boot Test Annotations**: https://docs.spring.io/spring-boot/docs/current/reference/html/test-auto-configuration.html
- **Spring Boot Testing Guide**: https://spring.io/guides/gs/testing-web/

### Kotlin Testing Resources
- **MockK Documentation**: https://mockk.io/
- **SpringMockK**: https://github.com/Ninja-Squad/springmockk
- **Kotlin Testing Guide**: https://kotlinlang.org/docs/jvm-test-using-junit.html
- **Coroutines Testing**: https://kotlinlang.org/docs/coroutines-testing.html

### TestContainers Integration
- **TestContainers Documentation**: https://testcontainers.com/
- **Spring Boot TestContainers**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing.testcontainers
- **TestContainers with Spring Data JPA**: https://testcontainers.com/guides/testing-spring-boot-rest-api-using-testcontainers/

### Security Testing
- **Spring Security Testing**: https://docs.spring.io/spring-security/reference/servlet/test/index.html
- **JWT Testing with Spring Boot**: https://auth0.com/blog/implementing-jwt-authentication-on-spring-boot/

### Performance and Monitoring
- **Spring Boot Actuator**: https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html
- **Micrometer Metrics**: https://micrometer.io/docs/registry/prometheus

---

**Note**: This document specifically addresses Spring Boot Kotlin integration testing patterns and should be used alongside the general [integration_testing_best_practices.md](practice/integration_testing_best_practices.md) document for comprehensive coverage.