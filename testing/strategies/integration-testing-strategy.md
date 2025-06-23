# Integration Testing Strategy - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Dependencies
```kotlin
// build.gradle.kts
dependencies {
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.testcontainers:junit-jupiter:1.19.3")
    testImplementation("org.testcontainers:postgresql:1.19.3")
    testImplementation("org.testcontainers:mariadb:1.19.3")
    testImplementation("com.github.tomakehurst:wiremock-jre8:2.35.1")
    testImplementation("io.rest-assured:rest-assured:5.3.2")
    testImplementation("io.rest-assured:spring-mock-mvc:5.3.2")
    testImplementation("org.awaitility:awaitility:4.2.0")
}
```

### Test Configuration
```kotlin
@TestConfiguration
class IntegrationTestConfig {
    
    @Bean
    @Primary
    fun testEmailService(): EmailService = mock()
    
    @Bean
    @Primary
    fun testNotificationService(): NotificationService = mock()
    
    @TestPropertySource(properties = [
        "spring.datasource.url=jdbc:tc:postgresql:15:///testdb",
        "spring.jpa.hibernate.ddl-auto=create-drop",
        "spring.flyway.enabled=false",
        "logging.level.org.springframework.web=DEBUG",
        "server.error.include-stacktrace=always"
    ])
    class DatabaseTestConfig
}
```

## IMPLEMENTATION STRATEGY

### Database Integration Tests
```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@Transactional
class UserServiceIntegrationTest {
    
    companion object {
        @Container
        @JvmStatic
        val postgres = PostgreSQLContainer<Nothing>("postgres:15").apply {
            withDatabaseName("testdb")
            withUsername("test")
            withPassword("test")
        }
    }
    
    @Autowired
    private lateinit var userService: UserService
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Autowired
    private lateinit var testEntityManager: TestEntityManager
    
    @Test
    fun `should create user and persist to database`() {
        val userDto = UserCreateDto(
            firstName = "John",
            lastName = "Doe",
            emailAddress = "john.doe@example.com"
        )
        
        val createdUser = userService.createUser(userDto)
        
        // Flush to database and clear persistence context
        testEntityManager.flush()
        testEntityManager.clear()
        
        // Verify user was persisted
        val persistedUser = userRepository.findById(createdUser.id!!)
        assertThat(persistedUser).isPresent
        assertThat(persistedUser.get().emailAddress).isEqualTo("john.doe@example.com")
        assertThat(persistedUser.get().status).isEqualTo(UserStatus.PENDING_VERIFICATION)
    }
    
    @Test
    fun `should handle duplicate email constraint violation`() {
        // Create first user
        val user1 = User().apply {
            firstName = "John"
            lastName = "Doe"
            emailAddress = "john.doe@example.com"
        }
        userRepository.save(user1)
        testEntityManager.flush()
        
        // Try to create second user with same email
        val userDto = UserCreateDto(
            firstName = "Jane",
            lastName = "Smith",
            emailAddress = "john.doe@example.com"
        )
        
        assertThatThrownBy { userService.createUser(userDto) }
            .isInstanceOf(DuplicateEmailException::class.java)
            .hasMessageContaining("Email already exists")
    }
    
    @Test
    fun `should update user preferences and maintain audit fields`() {
        // Create user
        val user = User().apply {
            firstName = "John"
            lastName = "Doe"
            emailAddress = "john.doe@example.com"
        }
        val savedUser = userRepository.save(user)
        testEntityManager.flush()
        
        val originalCreatedAt = savedUser.createdAt
        val originalUpdatedAt = savedUser.updatedAt
        
        // Wait to ensure different timestamp
        Thread.sleep(100)
        
        // Update preferences
        val preferences = mapOf("theme" to "dark", "notifications" to true)
        val updatedUser = userService.updateUserPreferences(savedUser.id!!, preferences)
        
        testEntityManager.flush()
        testEntityManager.clear()
        
        // Verify update
        val retrievedUser = userRepository.findById(updatedUser.id!!)
        assertThat(retrievedUser.get().preferences).isEqualTo(preferences)
        assertThat(retrievedUser.get().createdAt).isEqualTo(originalCreatedAt)
        assertThat(retrievedUser.get().updatedAt).isAfter(originalUpdatedAt)
    }
}
```

### REST API Integration Tests
```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class UserControllerIntegrationTest {
    
    @Autowired
    private lateinit var restTemplate: TestRestTemplate
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @LocalServerPort
    private var port: Int = 0
    
    companion object {
        @Container
        @JvmStatic
        val postgres = PostgreSQLContainer<Nothing>("postgres:15")
    }
    
    @BeforeEach
    fun setUp() {
        userRepository.deleteAll()
    }
    
    @Test
    fun `should create user via REST API`() {
        val userRequest = UserCreateRequest(
            firstName = "John",
            lastName = "Doe",
            emailAddress = "john.doe@example.com"
        )
        
        val response = restTemplate.postForEntity(
            "/api/users",
            userRequest,
            UserResponse::class.java
        )
        
        assertThat(response.statusCode).isEqualTo(HttpStatus.CREATED)
        assertThat(response.body).isNotNull
        assertThat(response.body!!.emailAddress).isEqualTo("john.doe@example.com")
        
        // Verify in database
        val users = userRepository.findAll()
        assertThat(users).hasSize(1)
        assertThat(users[0].emailAddress).isEqualTo("john.doe@example.com")
    }
    
    @Test
    fun `should return validation errors for invalid user data`() {
        val invalidRequest = UserCreateRequest(
            firstName = "",
            lastName = "",
            emailAddress = "invalid-email"
        )
        
        val response = restTemplate.postForEntity(
            "/api/users",
            invalidRequest,
            ErrorResponse::class.java
        )
        
        assertThat(response.statusCode).isEqualTo(HttpStatus.BAD_REQUEST)
        assertThat(response.body).isNotNull
        assertThat(response.body!!.errors).hasSize(3)
        assertThat(response.body!!.errors).anyMatch { it.field == "firstName" }
        assertThat(response.body!!.errors).anyMatch { it.field == "lastName" }
        assertThat(response.body!!.errors).anyMatch { it.field == "emailAddress" }
    }
    
    @Test
    fun `should get user by id`() {
        // Create user in database
        val user = User().apply {
            firstName = "John"
            lastName = "Doe"
            emailAddress = "john.doe@example.com"
        }
        val savedUser = userRepository.save(user)
        
        val response = restTemplate.getForEntity(
            "/api/users/${savedUser.id}",
            UserResponse::class.java
        )
        
        assertThat(response.statusCode).isEqualTo(HttpStatus.OK)
        assertThat(response.body).isNotNull
        assertThat(response.body!!.id).isEqualTo(savedUser.id)
        assertThat(response.body!!.emailAddress).isEqualTo("john.doe@example.com")
    }
    
    @Test
    fun `should return 404 for non-existent user`() {
        val response = restTemplate.getForEntity(
            "/api/users/999",
            ErrorResponse::class.java
        )
        
        assertThat(response.statusCode).isEqualTo(HttpStatus.NOT_FOUND)
    }
    
    @Test
    fun `should search users with pagination`() {
        // Create test data
        val users = (1..15).map { i ->
            User().apply {
                firstName = "User$i"
                lastName = "Test$i"
                emailAddress = "user$i@test.com"
            }
        }
        userRepository.saveAll(users)
        
        val response = restTemplate.getForEntity(
            "/api/users?page=0&size=10",
            PagedUserResponse::class.java
        )
        
        assertThat(response.statusCode).isEqualTo(HttpStatus.OK)
        assertThat(response.body).isNotNull
        assertThat(response.body!!.content).hasSize(10)
        assertThat(response.body!!.totalElements).isEqualTo(15)
        assertThat(response.body!!.totalPages).isEqualTo(2)
    }
}
```

### External Service Integration Tests
```kotlin
@SpringBootTest
class ExternalServiceIntegrationTest {
    
    @RegisterExtension
    static val wireMockServer = WireMockExtension.newInstance()
        .options(wireMockConfig().port(8089))
        .build()
    
    @Autowired
    private lateinit var paymentService: PaymentService
    
    @Test
    fun `should process payment via external service`() {
        // Setup WireMock stub
        wireMockServer.stubFor(
            post(urlEqualTo("/api/payments"))
                .withHeader("Content-Type", equalTo("application/json"))
                .withRequestBody(matchingJsonPath("$.amount"))
                .willReturn(
                    aResponse()
                        .withStatus(200)
                        .withHeader("Content-Type", "application/json")
                        .withBody("""
                            {
                                "transactionId": "txn_123456",
                                "status": "COMPLETED",
                                "amount": 100.00
                            }
                        """.trimIndent())
                )
        )
        
        val paymentRequest = PaymentRequest(
            amount = BigDecimal("100.00"),
            currency = "USD",
            paymentMethod = "credit_card"
        )
        
        val result = paymentService.processPayment(paymentRequest)
        
        assertThat(result.transactionId).isEqualTo("txn_123456")
        assertThat(result.status).isEqualTo(PaymentStatus.COMPLETED)
        
        // Verify request was made
        wireMockServer.verify(
            postRequestedFor(urlEqualTo("/api/payments"))
                .withRequestBody(matchingJsonPath("$.amount", equalTo("100.0")))
        )
    }
    
    @Test
    fun `should handle external service timeout`() {
        wireMockServer.stubFor(
            post(urlEqualTo("/api/payments"))
                .willReturn(
                    aResponse()
                        .withFixedDelay(5000) // 5 second delay
                        .withStatus(200)
                )
        )
        
        val paymentRequest = PaymentRequest(
            amount = BigDecimal("100.00"),
            currency = "USD",
            paymentMethod = "credit_card"
        )
        
        assertThatThrownBy { paymentService.processPayment(paymentRequest) }
            .isInstanceOf(PaymentServiceException::class.java)
            .hasMessageContaining("timeout")
    }
    
    @Test
    fun `should handle external service error responses`() {
        wireMockServer.stubFor(
            post(urlEqualTo("/api/payments"))
                .willReturn(
                    aResponse()
                        .withStatus(400)
                        .withHeader("Content-Type", "application/json")
                        .withBody("""
                            {
                                "error": "INSUFFICIENT_FUNDS",
                                "message": "Card has insufficient funds"
                            }
                        """.trimIndent())
                )
        )
        
        val paymentRequest = PaymentRequest(
            amount = BigDecimal("100.00"),
            currency = "USD",
            paymentMethod = "credit_card"
        )
        
        assertThatThrownBy { paymentService.processPayment(paymentRequest) }
            .isInstanceOf(InsufficientFundsException::class.java)
            .hasMessageContaining("insufficient funds")
    }
}
```

### Async Processing Integration Tests
```kotlin
@SpringBootTest
@TestPropertySource(properties = ["spring.task.execution.pool.core-size=1"])
class AsyncProcessingIntegrationTest {
    
    @Autowired
    private lateinit var emailService: EmailService
    
    @Autowired
    private lateinit var userService: UserService
    
    @MockBean
    private lateinit var mailSender: JavaMailSender
    
    @Test
    fun `should send welcome email asynchronously after user creation`() {
        val userDto = UserCreateDto(
            firstName = "John",
            lastName = "Doe",
            emailAddress = "john.doe@example.com"
        )
        
        userService.createUser(userDto)
        
        // Wait for async processing to complete
        await().atMost(Duration.ofSeconds(5))
            .untilAsserted {
                verify(mailSender, times(1)).send(any<SimpleMailMessage>())
            }
    }
    
    @Test
    fun `should handle email sending failures gracefully`() {
        whenever(mailSender.send(any<SimpleMailMessage>()))
            .thenThrow(MailException("SMTP server unavailable"))
        
        val userDto = UserCreateDto(
            firstName = "John",
            lastName = "Doe",
            emailAddress = "john.doe@example.com"
        )
        
        // User creation should still succeed even if email fails
        val user = userService.createUser(userDto)
        assertThat(user.id).isNotNull()
        
        // Verify email was attempted
        await().atMost(Duration.ofSeconds(5))
            .untilAsserted {
                verify(mailSender, times(1)).send(any<SimpleMailMessage>())
            }
    }
}
```

### Transaction Integration Tests
```kotlin
@SpringBootTest
@Transactional
class TransactionIntegrationTest {
    
    @Autowired
    private lateinit var userService: UserService
    
    @Autowired
    private lateinit var orderService: OrderService
    
    @Autowired
    private lateinit var testEntityManager: TestEntityManager
    
    @Test
    fun `should rollback transaction when service throws exception`() {
        val userDto = UserCreateDto(
            firstName = "John",
            lastName = "Doe",
            emailAddress = "john.doe@example.com"
        )
        
        // Mock order service to throw exception
        val orderService = mock<OrderService>()
        whenever(orderService.createWelcomeOrder(any()))
            .thenThrow(RuntimeException("Order service failed"))
        
        val userServiceWithFailingOrder = UserService(
            userRepository = userService.userRepository,
            orderService = orderService
        )
        
        assertThatThrownBy { userServiceWithFailingOrder.createUserWithWelcomeOrder(userDto) }
            .isInstanceOf(RuntimeException::class.java)
        
        // Verify no user was created due to rollback
        val users = userService.findAllUsers()
        assertThat(users).isEmpty()
    }
    
    @Test
    fun `should commit transaction when all operations succeed`() {
        val userDto = UserCreateDto(
            firstName = "John",
            lastName = "Doe",
            emailAddress = "john.doe@example.com"
        )
        
        val result = userService.createUserWithWelcomeOrder(userDto)
        
        testEntityManager.flush()
        testEntityManager.clear()
        
        // Verify both user and order were created
        assertThat(result.user.id).isNotNull()
        assertThat(result.order.id).isNotNull()
        assertThat(result.order.userId).isEqualTo(result.user.id)
    }
}
```

### Performance Integration Tests
```kotlin
@SpringBootTest
class PerformanceIntegrationTest {
    
    @Autowired
    private lateinit var userService: UserService
    
    @Test
    fun `should handle bulk operations within time limit`() {
        val users = (1..1000).map { i ->
            UserCreateDto(
                firstName = "User$i",
                lastName = "Test$i",
                emailAddress = "user$i@test.com"
            )
        }
        
        val startTime = System.currentTimeMillis()
        
        userService.createUsersInBatch(users)
        
        val executionTime = System.currentTimeMillis() - startTime
        
        // Should complete within 10 seconds
        assertThat(executionTime).isLessThan(10000)
        
        // Verify all users were created
        val savedUsers = userService.findAllUsers()
        assertThat(savedUsers).hasSize(1000)
    }
    
    @Test
    fun `should maintain performance under concurrent load`() {
        val numberOfThreads = 10
        val usersPerThread = 100
        val executor = Executors.newFixedThreadPool(numberOfThreads)
        val futures = mutableListOf<Future<*>>()
        
        val startTime = System.currentTimeMillis()
        
        repeat(numberOfThreads) { threadIndex ->
            val future = executor.submit {
                val users = (1..usersPerThread).map { i ->
                    UserCreateDto(
                        firstName = "User${threadIndex}_$i",
                        lastName = "Test${threadIndex}_$i",
                        emailAddress = "user${threadIndex}_$i@test.com"
                    )
                }
                userService.createUsersInBatch(users)
            }
            futures.add(future)
        }
        
        // Wait for all threads to complete
        futures.forEach { it.get() }
        executor.shutdown()
        
        val executionTime = System.currentTimeMillis() - startTime
        
        // Should complete within 30 seconds under load
        assertThat(executionTime).isLessThan(30000)
        
        // Verify all users were created
        val totalUsers = userService.countUsers()
        assertThat(totalUsers).isEqualTo(numberOfThreads * usersPerThread)
    }
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Run integration tests
mvn test -Dtest="*IntegrationTest"

# Run with specific profile
mvn test -Dtest="*IntegrationTest" -Dspring.profiles.active=integration

# Run with TestContainers
mvn test -Dtest="*IntegrationTest" -Dtestcontainers.reuse.enable=true

# Run performance tests
mvn test -Dtest="*PerformanceIntegrationTest" -Xmx2g

# Generate integration test report
mvn surefire-report:report -Dtest="*IntegrationTest"
```

## VALIDATION_CHECKLIST
- [ ] Database integration tests use TestContainers
- [ ] REST API endpoints tested end-to-end
- [ ] External service interactions mocked with WireMock
- [ ] Transaction boundaries tested for rollback scenarios
- [ ] Async processing verified with proper wait conditions
- [ ] Error handling tested for all failure scenarios
- [ ] Performance benchmarks established and tested
- [ ] Concurrent access patterns tested
- [ ] Data persistence verified across service layers
- [ ] Integration tests isolated and repeatable