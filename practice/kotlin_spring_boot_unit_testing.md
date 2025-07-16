# Kotlin Spring Boot Unit Testing Best Practices

## Document Information
- **Purpose**: Kotlin-specific unit testing patterns for Spring Boot web services
- **Last Updated**: June 27, 2025
- **Document Version**: 1.0.0
- **Scope**: Spring Boot applications written in Kotlin
- **Integration**: Claude Code friendly for generating unit tests

## Required Dependencies

### Gradle Kotlin DSL Configuration
```kotlin
dependencies {
    // Core Spring Boot Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.mockito", module = "mockito-core")
    }
    
    // Kotlin Testing Libraries (MANDATORY)
    testImplementation("io.mockk:mockk:1.13.7")
    testImplementation("com.ninja-squad:springmockk:4.0.2")
    testImplementation("org.assertj:assertj-core:3.24.2")
    
    // JUnit 5 with Kotlin support
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    
    // Spring Boot Test Slices
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.security:spring-security-test")
    
    // TestContainers for integration tests
    testImplementation("org.testcontainers:junit-jupiter:1.19.0")
    testImplementation("org.testcontainers:postgresql:1.19.0")
    
    // Coroutines testing
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
}

tasks.test {
    useJUnitPlatform()
    systemProperty("spring.profiles.active", "test")
    testLogging {
        events("passed", "skipped", "failed")
        exceptionFormat = org.gradle.api.tasks.testing.logging.TestExceptionFormat.FULL
    }
}
```

## Core Testing Libraries

### 1. MockK (Kotlin Mocking - MANDATORY)
**Never use Mockito with Kotlin** - MockK is designed for Kotlin and handles language features correctly.

```kotlin
// ✅ CORRECT: Use MockK for all mocking
@ExtendWith(MockKExtension::class)
class UserServiceTest {
    @MockK
    private lateinit var userRepository: UserRepository
    
    @InjectMocks
    private lateinit var userService: UserService
}

// ❌ INCORRECT: Never use Mockito annotations with Kotlin
@ExtendWith(MockitoExtension::class) // DON'T DO THIS
class UserServiceTest {
    @Mock // DON'T DO THIS
    private lateinit var userRepository: UserRepository
}
```

### 2. SpringMockK Integration
Bridges MockK with Spring's DI container:

```kotlin
@SpringBootTest
@MockkBean
class UserServiceIntegrationTest {
    @MockkBean
    private lateinit var emailService: EmailService
    
    @Autowired
    private lateinit var userService: UserService
    
    @Test
    fun `should send welcome email when user created`() {
        every { emailService.sendWelcomeEmail(any()) } just Runs
        
        userService.createUser("test@example.com")
        
        verify { emailService.sendWelcomeEmail(any()) }
    }
}
```

### 3. AssertJ (MANDATORY Assertions)
**Never use kotlin.test assertions** - Use AssertJ for consistency:

```kotlin
// ✅ CORRECT: Use AssertJ assertions
import org.assertj.core.api.Assertions.assertThat

@Test
fun `should return user when found`() {
    val user = userService.findById(1L)
    
    assertThat(user).isNotNull
    assertThat(user.email).isEqualTo("test@example.com")
    assertThat(user.roles).hasSize(2).containsExactly("USER", "ADMIN")
}

// ❌ INCORRECT: Don't use kotlin.test
import kotlin.test.assertEquals // DON'T USE
```

## Spring Boot Test Slices for Kotlin

### 1. Controller Layer Testing (@WebMvcTest)

```kotlin
@WebMvcTest(UserController::class)
@Import(SecurityConfig::class)
class UserControllerTest {
    
    @Autowired
    private lateinit var mockMvc: MockMvc
    
    @MockkBean
    private lateinit var userService: UserService
    
    @Test
    @WithMockUser(roles = ["ADMIN"])
    fun `should return user when valid ID provided`() {
        // Given
        val userId = 1L
        val expectedUser = User(
            id = userId,
            email = "john@example.com",
            fullName = "John Doe"
        )
        every { userService.findById(userId) } returns expectedUser
        
        // When & Then
        mockMvc.perform(get("/api/users/$userId"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.id").value(1))
            .andExpect(jsonPath("$.email").value("john@example.com"))
            .andExpect(jsonPath("$.fullName").value("John Doe"))
    }
    
    @Test
    fun `should return 404 when user not found`() {
        // Given
        val userId = 999L
        every { userService.findById(userId) } throws UserNotFoundException("User not found")
        
        // When & Then
        mockMvc.perform(get("/api/users/$userId"))
            .andExpect(status().isNotFound)
            .andExpect(jsonPath("$.message").value("User not found"))
    }
    
    @Test
    fun `should validate request body when creating user`() {
        // Given
        val invalidRequest = """{"email": "invalid-email", "fullName": ""}"""
        
        // When & Then
        mockMvc.perform(
            post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(invalidRequest)
        )
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.errors").isArray)
    }
}
```

### 2. Service Layer Testing (Pure Unit Tests)

```kotlin
@ExtendWith(MockKExtension::class)
class UserServiceTest {
    
    @MockK
    private lateinit var userRepository: UserRepository
    
    @MockK
    private lateinit var emailService: EmailService
    
    @MockK
    private lateinit var passwordEncoder: PasswordEncoder
    
    @InjectMocks
    private lateinit var userService: UserService
    
    @Test
    fun `should create user with encoded password`() {
        // Given
        val request = CreateUserRequest(
            email = "john@example.com",
            fullName = "John Doe",
            password = "plainPassword"
        )
        val encodedPassword = "encodedPassword123"
        val savedUser = User(
            id = 1L,
            email = request.email,
            fullName = request.fullName,
            password = encodedPassword
        )
        
        every { passwordEncoder.encode("plainPassword") } returns encodedPassword
        every { userRepository.existsByEmail(request.email) } returns false
        every { userRepository.save(any<User>()) } returns savedUser
        every { emailService.sendWelcomeEmail(any()) } just Runs
        
        // When
        val result = userService.createUser(request)
        
        // Then
        assertThat(result.id).isEqualTo(1L)
        assertThat(result.email).isEqualTo("john@example.com")
        assertThat(result.password).isEqualTo(encodedPassword)
        
        verify(exactly = 1) { passwordEncoder.encode("plainPassword") }
        verify(exactly = 1) { userRepository.save(any<User>()) }
        verify(exactly = 1) { emailService.sendWelcomeEmail(savedUser) }
    }
    
    @Test
    fun `should throw exception when email already exists`() {
        // Given
        val request = CreateUserRequest(
            email = "existing@example.com",
            fullName = "John Doe",
            password = "password"
        )
        every { userRepository.existsByEmail(request.email) } returns true
        
        // When & Then
        assertThatThrownBy { userService.createUser(request) }
            .isInstanceOf(EmailAlreadyExistsException::class.java)
            .hasMessage("Email already exists: existing@example.com")
        
        verify(exactly = 0) { userRepository.save(any<User>()) }
        verify(exactly = 0) { emailService.sendWelcomeEmail(any()) }
    }
    
    @Test
    fun `should find users by role with pagination`() {
        // Given
        val role = "ADMIN"
        val pageable = PageRequest.of(0, 10)
        val users = listOf(
            User(1L, "admin1@example.com", "Admin One"),
            User(2L, "admin2@example.com", "Admin Two")
        )
        val page = PageImpl(users, pageable, 2)
        
        every { userRepository.findByRole(role, pageable) } returns page
        
        // When
        val result = userService.findUsersByRole(role, pageable)
        
        // Then
        assertThat(result.content).hasSize(2)
        assertThat(result.totalElements).isEqualTo(2)
        assertThat(result.content[0].email).isEqualTo("admin1@example.com")
    }
}
```

### 3. Repository Layer Testing (@DataJpaTest)

```kotlin
@DataJpaTest
@TestPropertySource(properties = [
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.H2Dialect"
])
class UserRepositoryTest {
    
    @Autowired
    private lateinit var testEntityManager: TestEntityManager
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Test
    fun `should find user by email when exists`() {
        // Given
        val user = User(
            email = "test@example.com",
            fullName = "Test User",
            password = "hashedPassword"
        )
        testEntityManager.persistAndFlush(user)
        
        // When
        val found = userRepository.findByEmail("test@example.com")
        
        // Then
        assertThat(found).isPresent
        assertThat(found.get().fullName).isEqualTo("Test User")
    }
    
    @Test
    fun `should return empty when user email not found`() {
        // When
        val found = userRepository.findByEmail("nonexistent@example.com")
        
        // Then
        assertThat(found).isEmpty
    }
    
    @Test
    fun `should find users by role with custom query`() {
        // Given
        val adminUser = User(
            email = "admin@example.com",
            fullName = "Admin User",
            role = "ADMIN"
        )
        val regularUser = User(
            email = "user@example.com",
            fullName = "Regular User",
            role = "USER"
        )
        testEntityManager.persistAndFlush(adminUser)
        testEntityManager.persistAndFlush(regularUser)
        
        // When
        val admins = userRepository.findByRole("ADMIN", PageRequest.of(0, 10))
        
        // Then
        assertThat(admins.content).hasSize(1)
        assertThat(admins.content[0].email).isEqualTo("admin@example.com")
    }
    
    @Test
    fun `should check if email exists`() {
        // Given
        val user = User(email = "existing@example.com", fullName = "Existing User")
        testEntityManager.persistAndFlush(user)
        
        // When & Then
        assertThat(userRepository.existsByEmail("existing@example.com")).isTrue
        assertThat(userRepository.existsByEmail("nonexistent@example.com")).isFalse
    }
}
```

### 4. JSON Serialization Testing (@JsonTest)

```kotlin
@JsonTest
class UserDtoJsonTest {
    
    @Autowired
    private lateinit var json: JacksonTester<UserDto>
    
    @Test
    fun `should serialize user dto correctly`() {
        // Given
        val userDto = UserDto(
            id = 1L,
            email = "john@example.com",
            fullName = "John Doe",
            roles = listOf("USER", "ADMIN"),
            createdAt = Instant.parse("2024-01-01T10:00:00Z")
        )
        
        // When
        val result = json.write(userDto)
        
        // Then
        assertThat(result).hasJsonPath("$.id")
        assertThat(result).extractingJsonPathNumberValue("$.id").isEqualTo(1)
        assertThat(result).extractingJsonPathStringValue("$.email").isEqualTo("john@example.com")
        assertThat(result).extractingJsonPathStringValue("$.fullName").isEqualTo("John Doe")
        assertThat(result).extractingJsonPathArrayValue("$.roles").containsExactly("USER", "ADMIN")
        assertThat(result).extractingJsonPathStringValue("$.createdAt").isEqualTo("2024-01-01T10:00:00Z")
    }
    
    @Test
    fun `should deserialize user dto correctly`() {
        // Given
        val jsonContent = """
            {
                "id": 1,
                "email": "john@example.com",
                "fullName": "John Doe",
                "roles": ["USER", "ADMIN"],
                "createdAt": "2024-01-01T10:00:00Z"
            }
        """.trimIndent()
        
        // When
        val result = json.parse(jsonContent)
        
        // Then
        assertThat(result.getObject().id).isEqualTo(1L)
        assertThat(result.getObject().email).isEqualTo("john@example.com")
        assertThat(result.getObject().fullName).isEqualTo("John Doe")
        assertThat(result.getObject().roles).containsExactly("USER", "ADMIN")
        assertThat(result.getObject().createdAt).isEqualTo(Instant.parse("2024-01-01T10:00:00Z"))
    }
}
```

## Kotlin-Specific Testing Patterns

### 1. Data Class Testing
```kotlin
@Test
fun `should create user with proper data class behavior`() {
    // Given
    val user1 = User(1L, "john@example.com", "John Doe")
    val user2 = User(1L, "john@example.com", "John Doe")
    val user3 = User(2L, "jane@example.com", "Jane Doe")
    
    // When & Then - Test data class equality
    assertThat(user1).isEqualTo(user2)
    assertThat(user1).isNotEqualTo(user3)
    assertThat(user1.hashCode()).isEqualTo(user2.hashCode())
    
    // Test copy functionality
    val modifiedUser = user1.copy(fullName = "John Smith")
    assertThat(modifiedUser.id).isEqualTo(user1.id)
    assertThat(modifiedUser.email).isEqualTo(user1.email)
    assertThat(modifiedUser.fullName).isEqualTo("John Smith")
}
```

### 2. Nullable Testing Patterns
```kotlin
@Test
fun `should handle nullable values correctly`() {
    // Given
    val userWithNullAddress = User(
        id = 1L,
        email = "john@example.com",
        fullName = "John Doe",
        address = null
    )
    
    // When
    val addressInfo = userService.getAddressInfo(userWithNullAddress)
    
    // Then
    assertThat(addressInfo).isEqualTo("No address provided")
}

@Test
fun `should return null when user not found`() {
    // Given
    every { userRepository.findById(999L) } returns null
    
    // When
    val result = userService.findById(999L)
    
    // Then
    assertThat(result).isNull()
}
```

### 3. Extension Function Testing
```kotlin
// Extension function to test
fun User.isAdmin(): Boolean = this.roles.contains("ADMIN")

@Test
fun `should identify admin users correctly`() {
    // Given
    val adminUser = User(
        id = 1L,
        email = "admin@example.com",
        fullName = "Admin User",
        roles = listOf("USER", "ADMIN")
    )
    val regularUser = User(
        id = 2L,
        email = "user@example.com",
        fullName = "Regular User",
        roles = listOf("USER")
    )
    
    // When & Then
    assertThat(adminUser.isAdmin()).isTrue
    assertThat(regularUser.isAdmin()).isFalse
}
```

### 4. Coroutines Testing
```kotlin
@ExtendWith(MockKExtension::class)
class AsyncUserServiceTest {
    
    @MockK
    private lateinit var userRepository: UserRepository
    
    @MockK
    private lateinit var emailService: EmailService
    
    @InjectMocks
    private lateinit var asyncUserService: AsyncUserService
    
    @Test
    fun `should process users asynchronously`() = runTest {
        // Given
        val users = listOf(
            User(1L, "user1@example.com", "User One"),
            User(2L, "user2@example.com", "User Two")
        )
        every { userRepository.findAll() } returns users
        coEvery { emailService.sendNotificationAsync(any()) } just Runs
        
        // When
        asyncUserService.notifyAllUsers()
        
        // Then
        coVerify(exactly = 2) { emailService.sendNotificationAsync(any()) }
    }
    
    @Test
    fun `should handle async exceptions gracefully`() = runTest {
        // Given
        val user = User(1L, "user@example.com", "User")
        coEvery { emailService.sendNotificationAsync(user) } throws RuntimeException("Email service down")
        
        // When & Then
        assertThatThrownBy { 
            runBlocking { asyncUserService.notifyUser(user) }
        }.isInstanceOf(RuntimeException::class.java)
            .hasMessage("Email service down")
    }
}
```

## Testing Configuration Classes

### 1. Configuration Class Testing
```kotlin
@SpringBootTest
@TestConfiguration
class SecurityConfigTest {
    
    @TestConfiguration
    class TestConfig {
        @Bean
        @Primary
        fun testPasswordEncoder(): PasswordEncoder = MockkPasswordEncoder()
    }
    
    @Autowired
    private lateinit var webSecurity: WebSecurity
    
    @Test
    fun `should configure security properly`() {
        // Test security configuration
        assertThat(webSecurity).isNotNull
        // Add specific security configuration tests
    }
}
```

### 2. Custom Auto-Configuration Testing
```kotlin
@ExtendWith(MockKExtension::class)
class UserAutoConfigurationTest {
    
    private val contextRunner = ApplicationContextRunner()
        .withConfiguration(AutoConfigurations.of(UserAutoConfiguration::class.java))
    
    @Test
    fun `should auto-configure user service when properties present`() {
        contextRunner
            .withPropertyValues("app.user.service.enabled=true")
            .run { context ->
                assertThat(context).hasSingleBean(UserService::class.java)
                assertThat(context).hasSingleBean(UserRepository::class.java)
            }
    }
    
    @Test
    fun `should not auto-configure when disabled`() {
        contextRunner
            .withPropertyValues("app.user.service.enabled=false")
            .run { context ->
                assertThat(context).doesNotHaveBean(UserService::class.java)
            }
    }
}
```

## Test Data Builders (Kotlin-Specific)

### 1. Data Class Builder Pattern
```kotlin
class UserTestDataBuilder {
    private var id: Long = 1L
    private var email: String = "test@example.com"
    private var fullName: String = "Test User"
    private var roles: List<String> = listOf("USER")
    private var createdAt: Instant = Instant.now()
    
    fun withId(id: Long) = apply { this.id = id }
    fun withEmail(email: String) = apply { this.email = email }
    fun withFullName(fullName: String) = apply { this.fullName = fullName }
    fun withRoles(vararg roles: String) = apply { this.roles = roles.toList() }
    fun withCreatedAt(createdAt: Instant) = apply { this.createdAt = createdAt }
    
    fun build() = User(
        id = id,
        email = email,
        fullName = fullName,
        roles = roles,
        createdAt = createdAt
    )
}

// Usage in tests
@Test
fun `should handle admin users differently`() {
    // Given
    val adminUser = UserTestDataBuilder()
        .withRoles("USER", "ADMIN")
        .build()
    
    val regularUser = UserTestDataBuilder()
        .withId(2L)
        .withEmail("regular@example.com")
        .build()
    
    // When & Then
    assertThat(userService.isAdmin(adminUser)).isTrue
    assertThat(userService.isAdmin(regularUser)).isFalse
}
```

### 2. Object Mother Pattern
```kotlin
object UserMother {
    fun defaultUser() = User(
        id = 1L,
        email = "default@example.com",
        fullName = "Default User",
        roles = listOf("USER")
    )
    
    fun adminUser() = User(
        id = 2L,
        email = "admin@example.com",
        fullName = "Admin User",
        roles = listOf("USER", "ADMIN")
    )
    
    fun userWithEmail(email: String) = defaultUser().copy(email = email)
    
    fun userWithRoles(vararg roles: String) = defaultUser().copy(roles = roles.toList())
}

// Usage in tests
@Test
fun `should send admin notifications only to admins`() {
    // Given
    val admin = UserMother.adminUser()
    val regularUser = UserMother.defaultUser()
    
    every { userRepository.findAll() } returns listOf(admin, regularUser)
    every { emailService.sendAdminNotification(any()) } just Runs
    
    // When
    userService.sendAdminNotifications()
    
    // Then
    verify(exactly = 1) { emailService.sendAdminNotification(admin) }
    verify(exactly = 0) { emailService.sendAdminNotification(regularUser) }
}
```

## Common Anti-Patterns to Avoid

### ❌ DON'T: Use Mockito with Kotlin
```kotlin
// ❌ WRONG - Mockito doesn't work well with Kotlin
@ExtendWith(MockitoExtension::class)
class BadUserServiceTest {
    @Mock
    private lateinit var userRepository: UserRepository // DON'T DO THIS
}
```

### ❌ DON'T: Use kotlin.test assertions
```kotlin
// ❌ WRONG - Inconsistent with Spring Boot conventions
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

@Test
fun badTest() {
    assertEquals("expected", actual) // DON'T DO THIS
    assertNotNull(result) // DON'T DO THIS
}
```

### ❌ DON'T: Mix testing libraries
```kotlin
// ❌ WRONG - Don't mix MockK and Mockito
class BadMixedTest {
    @MockK
    private lateinit var mockKService: Service1
    
    @Mock // DON'T MIX
    private lateinit var mockitoService: Service2
}
```

### ❌ DON'T: Ignore null safety in tests
```kotlin
// ❌ WRONG - Not testing null safety properly
@Test
fun badNullTest() {
    val user: User = userService.findById(1L) // Could be null!
    assertThat(user.email).isEqualTo("test@example.com") // NullPointerException risk
}

// ✅ CORRECT - Proper null handling
@Test
fun goodNullTest() {
    val user: User? = userService.findById(1L)
    assertThat(user).isNotNull
    assertThat(user!!.email).isEqualTo("test@example.com")
}
```

## Essential Online Resources

### Official Documentation
- **Spring Boot Testing**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing
- **Spring Boot Test Slices**: https://docs.spring.io/spring-boot/docs/current/reference/html/test-auto-configuration.html
- **Kotlin Testing**: https://kotlinlang.org/docs/jvm-test-using-junit.html
- **JUnit 5 User Guide**: https://junit.org/junit5/docs/current/user-guide/

### Kotlin-Specific Testing Libraries
- **MockK Documentation**: https://mockk.io/
- **SpringMockK**: https://github.com/Ninja-Squad/springmockk
- **Kotlin Coroutines Testing**: https://kotlinlang.org/docs/coroutines-testing.html
- **AssertJ Documentation**: https://assertj.github.io/doc/

### Best Practices & Guides
- **Spring Boot Kotlin Guide**: https://spring.io/guides/tutorials/spring-boot-kotlin/
- **Kotlin Test Style Guide**: https://kotlinlang.org/docs/coding-conventions.html#unit-tests
- **TestContainers Kotlin**: https://testcontainers.com/guides/testing-spring-boot-rest-api-using-testcontainers/
- **Spring Security Testing**: https://docs.spring.io/spring-security/reference/servlet/test/index.html

### Testing Tools & Coverage
- **JaCoCo with Kotlin**: https://docs.gradle.org/current/userguide/jacoco_plugin.html
- **Gradle Kotlin DSL**: https://docs.gradle.org/current/userguide/kotlin_dsl.html
- **Spring Boot Gradle Plugin**: https://docs.spring.io/spring-boot/docs/current/gradle-plugin/reference/htmlsingle/
- **Ktlint**: https://ktlint.github.io/

## Claude Code Generation Patterns

### Method Naming Template
```kotlin
// Template for test method names
fun `should [expected behavior] when [condition]`()
fun `should throw [exception] when [invalid condition]`()
fun `should return [result] given [input condition]`()

// Examples
fun `should create user when valid data provided`()
fun `should throw EmailAlreadyExistsException when email already exists`()
fun `should return empty list given no users exist`()
```

### Test Class Structure Template
```kotlin
@ExtendWith(MockKExtension::class) // For unit tests
class [ClassUnderTest]Test {
    
    @MockK
    private lateinit var dependency: Dependency
    
    @InjectMocks
    private lateinit var subjectUnderTest: SubjectUnderTest
    
    @Test
    fun `should [behavior] when [condition]`() {
        // Given
        val input = [test data]
        every { dependency.method(any()) } returns [mock response]
        
        // When
        val result = subjectUnderTest.methodUnderTest(input)
        
        // Then
        assertThat(result).isEqualTo([expected])
        verify(exactly = 1) { dependency.method(any()) }
    }
}
```

---

**Note**: This document is optimized for Claude Code generation of Kotlin Spring Boot unit tests. Always use MockK instead of Mockito, AssertJ for assertions, and follow the naming conventions for consistent test generation.