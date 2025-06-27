# Kotlin Best Practices - Code Analysis Guide

## Document Information
- **Purpose**: Comprehensive Kotlin best practices for automated code analysis and Claude Code development assistance
- **Last Updated**: June 26, 2025
- **Document Version**: 2.0.0
- **Target Frameworks**: Spring Boot 3.x, Kotlin 2.1+, Android, Vaadin
- **Integration**: Designed for Claude Code analysis and validation

## Table of Contents
1. [Naming Conventions](#naming-conventions)
2. [Null Handling](#null-handling)
3. [Library Usage Standards](#library-usage-standards)
4. [Error Handling](#error-handling)
5. [Code Organization](#code-organization)
6. [Testing Requirements](#testing-requirements)
7. [Performance Guidelines](#performance-guidelines)
8. [Security Practices](#security-practices)
9. [Documentation Standards](#documentation-standards)
10. [Analysis Checklist](#analysis-checklist)

---

## Naming Conventions

### Classes and Interfaces
```kotlin
// ✅ CORRECT: PascalCase for classes
class UserService
class DatabaseManager
class PaymentProcessor

// ✅ CORRECT: Interface naming (no 'I' prefix)
interface UserRepository
interface PaymentGateway
interface NotificationService

// ✅ CORRECT: Abstract classes
abstract class BaseEntity
abstract class AbstractValidator

// ✅ CORRECT: Data classes
data class User(val id: Long, val name: String, val email: String)
data class ApiResponse<T>(val data: T?, val success: Boolean, val message: String?)

// ✅ CORRECT: Sealed classes for state management
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Throwable, val message: String? = null) : Result<Nothing>()
    data class Loading(val message: String? = null) : Result<Nothing>()
}

// ❌ INCORRECT: Avoid abbreviations
class UsrSvc // Should be UserService
class DbMgr  // Should be DatabaseManager
```

### Functions and Properties
```kotlin
class UserService {
    // ✅ CORRECT: Functions in camelCase
    fun getUserById(id: Long): User?
    fun validateEmailAddress(email: String): Boolean
    fun calculateTotalPrice(items: List<Item>): BigDecimal
    
    // ✅ CORRECT: Properties in camelCase
    private val userName: String = ""
    private val createdAt: LocalDateTime = LocalDateTime.now()
    private var lastLoginTime: LocalDateTime? = null
    
    // ✅ CORRECT: Boolean properties with proper prefixes
    val isValid: Boolean = true
    val hasPermission: Boolean = false
    val canEdit: Boolean = true
    val shouldProcess: Boolean = false
    
    // ✅ CORRECT: Constants in companion objects
    companion object {
        const val MAX_RETRY_COUNT = 3
        const val DEFAULT_TIMEOUT_SECONDS = 30
        const val API_BASE_URL = "https://api.example.com"
    }
}
```

### Packages and Modules
```kotlin
// ✅ CORRECT: Lowercase with descriptive names
package com.company.userservice.domain
package com.company.userservice.repository
package com.company.userservice.controller
package com.company.userservice.configuration

// ❌ INCORRECT: Avoid abbreviations
package com.company.userservice.config  // Should be configuration
package com.company.userservice.repo    // Should be repository
package com.company.userservice.ctrl    // Should be controller
```

### Spring Boot Specific Naming
```kotlin
// Controllers: PascalCase + Controller suffix
@RestController
class UserController

// Services: PascalCase + Service suffix
@Service
class UserService

// Repositories: PascalCase + Repository suffix
@Repository
interface UserRepository : JpaRepository<User, Long>

// Configuration classes: PascalCase + Config suffix
@Configuration
class DatabaseConfig
```

### Android Specific Naming
```kotlin
// Activities: PascalCase + Activity suffix
class MainActivity : ComponentActivity()

// ViewModels: PascalCase + ViewModel suffix
class LoginViewModel : ViewModel()

// Composables: PascalCase
@Composable
fun LoginScreen() { }

@Composable
fun UserCard(user: User) { }

// Database entities: PascalCase + Entity suffix
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: Long,
    val name: String,
    val email: String
)
```

---

## Null Handling

### Mandatory Null Safety Practices
```kotlin
// ✅ CORRECT: Use nullable types explicitly
fun findUserByEmail(email: String): User? {
    return userRepository.findByEmail(email)
}

// ✅ CORRECT: Safe calls with elvis operator
val userName = user?.name ?: "Unknown"
val userAge = user?.age ?: 0

// ✅ CORRECT: Safe calls with let
user?.let { processUser(it) }

// ✅ CORRECT: Safe casting
val stringValue = value as? String

// ✅ CORRECT: Use requireNotNull for validation
fun processUser(user: User?) {
    requireNotNull(user) { "User cannot be null" }
    // user is now smart-cast to non-null
}

// ❌ INCORRECT: Avoid !! unless absolutely certain
val result = getData()!! // Risky - can throw KotlinNullPointerException

// ✅ CORRECT: Use checkNotNull for state validation
fun calculateTotal(items: List<Item>?) {
    val validItems = checkNotNull(items) { "Items list cannot be null" }
    return validItems.sumOf { it.price }
}
```

### Null Handling in Data Classes
```kotlin
// ✅ CORRECT: Explicit nullable properties
data class UserUpdateRequest(
    val firstName: String? = null,
    val lastName: String? = null,
    val email: String? = null,
    val phoneNumber: String? = null
) {
    fun hasValidUpdates(): Boolean = 
        firstName != null || lastName != null || email != null || phoneNumber != null
}

// ✅ CORRECT: Validation functions
data class User(
    val id: Long,
    val email: String,
    val firstName: String?,
    val lastName: String?
) {
    val fullName: String
        get() = "${firstName ?: ""} ${lastName ?: ""}".trim()
    
    fun hasCompleteName(): Boolean = firstName != null && lastName != null
}
```

### Spring Boot Null Handling
```kotlin
// ✅ CORRECT: Use Spring's validation annotations
data class CreateUserRequest(
    @field:NotBlank(message = "Email is required")
    val email: String,
    
    @field:Size(min = 2, max = 50, message = "Name must be between 2 and 50 characters")
    val name: String,
    
    @field:Min(value = 18, message = "Age must be at least 18")
    val age: Int? = null
)
```

---

## Library Usage Standards

### Core Kotlin Libraries
```kotlin
// ✅ CORRECT: Standard library usage
import kotlinx.coroutines.*
import kotlinx.serialization.Serializable
import kotlinx.datetime.LocalDateTime

// ✅ CORRECT: Collections usage
val users = listOf<User>()
val userMap = mapOf<String, User>()
val userSet = setOf<User>()

// ✅ CORRECT: Immutable collections for data classes
@Serializable
data class UserGroup(
    val id: Long,
    val name: String,
    val members: List<User> = emptyList() // Immutable by default
)
```

### Spring Boot Libraries
```kotlin
// ✅ CORRECT: Spring Boot dependencies
implementation("org.springframework.boot:spring-boot-starter-web")
implementation("org.springframework.boot:spring-boot-starter-data-jpa")
implementation("org.springframework.boot:spring-boot-starter-security")
implementation("org.springframework.boot:spring-boot-starter-validation")

// ✅ CORRECT: Kotlin-specific Spring dependencies
implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
implementation("org.jetbrains.kotlin:kotlin-reflect")

// ✅ CORRECT: Testing dependencies
testImplementation("org.springframework.boot:spring-boot-starter-test")
testImplementation("io.mockk:mockk:1.13.5")
testImplementation("org.testcontainers:junit-jupiter")
```

### Android Libraries
```kotlin
// ✅ CORRECT: Core Android dependencies
implementation("androidx.core:core-ktx:1.13.1")
implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.3")
implementation("androidx.activity:activity-compose:1.9.0")

// ✅ CORRECT: Compose dependencies
implementation(platform("androidx.compose:compose-bom:2024.06.00"))
implementation("androidx.compose.ui:ui")
implementation("androidx.compose.material3:material3")

// ✅ CORRECT: Architecture components
implementation("androidx.lifecycle:lifecycle-viewmodel-compose")
implementation("androidx.navigation:navigation-compose")
implementation("com.google.dagger:hilt-android:2.52")
kapt("com.google.dagger:hilt-compiler:2.52")
```

### Recommended Third-Party Libraries
```kotlin
// Networking
implementation("com.squareup.retrofit2:retrofit:2.11.0")
implementation("com.squareup.retrofit2:converter-gson:2.11.0")
implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")

// JSON Processing
implementation("com.google.code.gson:gson:2.10.1")
implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")

// Database
implementation("org.jetbrains.exposed:exposed-core:0.50.1")
implementation("org.jetbrains.exposed:exposed-dao:0.50.1")
implementation("org.jetbrains.exposed:exposed-jdbc:0.50.1")

// Functional Programming
implementation("io.arrow-kt:arrow-core:1.2.4")
implementation("io.arrow-kt:arrow-fx-coroutines:1.2.4")

// Validation
implementation("io.konform:konform:0.6.1")
```

---

## Error Handling

### Sealed Classes for Result Types
```kotlin
// ✅ CORRECT: Comprehensive Result sealed class
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Throwable, val message: String? = null) : Result<Nothing>()
    data class Loading(val message: String? = null) : Result<Nothing>()
    
    // Utility functions
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
    
    fun getOrNull(): T? = when (this) {
        is Success -> data
        else -> null
    }
    
    fun getOrThrow(): T = when (this) {
        is Success -> data
        is Error -> throw exception
        is Loading -> throw IllegalStateException("Result is still loading")
    }
}
```

### Custom Exception Hierarchy
```kotlin
// ✅ CORRECT: Domain-specific exception hierarchy
sealed class UserServiceException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    class UserNotFoundException(userId: Long) : UserServiceException("User with ID $userId not found")
    class InvalidEmailException(email: String) : UserServiceException("Invalid email format: $email")
    class DuplicateUserException(email: String) : UserServiceException("User with email $email already exists")
    class UserValidationException(message: String) : UserServiceException(message)
}

// ✅ CORRECT: Infrastructure exception hierarchy
sealed class DatabaseException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    class ConnectionException(message: String, cause: Throwable) : DatabaseException(message, cause)
    class QueryException(message: String, cause: Throwable) : DatabaseException(message, cause)
    class TransactionException(message: String, cause: Throwable) : DatabaseException(message, cause)
}
```

### Error Handling in Services
```kotlin
@Service
class UserService {
    
    // ✅ CORRECT: Repository pattern with Result
    fun findUserSafely(id: Long): Result<User> = try {
        val user = userRepository.findById(id)
            ?: return Result.Error(UserServiceException.UserNotFoundException(id))
        Result.Success(user)
    } catch (e: Exception) {
        logger.error("Failed to find user with ID: $id", e)
        Result.Error(DatabaseException.QueryException("Database error while finding user", e))
    }
    
    // ✅ CORRECT: Validation with custom exceptions
    fun createUser(request: CreateUserRequest): Result<User> {
        return try {
            validateCreateUserRequest(request)
            val user = userRepository.save(request.toEntity())
            Result.Success(user)
        } catch (e: UserServiceException) {
            Result.Error(e)
        } catch (e: Exception) {
            logger.error("Unexpected error creating user", e)
            Result.Error(e, "Failed to create user")
        }
    }
    
    private fun validateCreateUserRequest(request: CreateUserRequest) {
        if (!request.email.isValidEmail()) {
            throw UserServiceException.InvalidEmailException(request.email)
        }
        if (userRepository.existsByEmail(request.email)) {
            throw UserServiceException.DuplicateUserException(request.email)
        }
    }
}
```

### Global Error Handling (Spring Boot)
```kotlin
@ControllerAdvice
class GlobalExceptionHandler {
    
    private val logger = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)
    
    @ExceptionHandler(UserServiceException.UserNotFoundException::class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    fun handleUserNotFound(ex: UserServiceException.UserNotFoundException): ErrorResponse {
        return ErrorResponse(
            error = "USER_NOT_FOUND",
            message = ex.message ?: "User not found",
            timestamp = LocalDateTime.now()
        )
    }
    
    @ExceptionHandler(UserServiceException.DuplicateUserException::class)
    @ResponseStatus(HttpStatus.CONFLICT)
    fun handleDuplicateUser(ex: UserServiceException.DuplicateUserException): ErrorResponse {
        return ErrorResponse(
            error = "DUPLICATE_USER",
            message = ex.message ?: "User already exists",
            timestamp = LocalDateTime.now()
        )
    }
    
    @ExceptionHandler(Exception::class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    fun handleGenericException(ex: Exception): ErrorResponse {
        logger.error("Unhandled exception", ex)
        return ErrorResponse(
            error = "INTERNAL_SERVER_ERROR",
            message = "An unexpected error occurred",
            timestamp = LocalDateTime.now()
        )
    }
}

data class ErrorResponse(
    val error: String,
    val message: String,
    val timestamp: LocalDateTime,
    val details: Map<String, Any> = emptyMap()
)
```

---

## Code Organization

### Package Structure (Spring Boot)
```
src/main/kotlin/com/company/app/
├── config/                     # Configuration classes
│   ├── DatabaseConfig.kt
│   ├── SecurityConfig.kt
│   └── WebConfig.kt
├── controller/                 # REST controllers
│   ├── UserController.kt
│   └── AuthController.kt
├── service/                    # Business logic
│   ├── UserService.kt
│   ├── AuthService.kt
│   └── impl/
│       ├── UserServiceImpl.kt
│       └── AuthServiceImpl.kt
├── repository/                 # Data access
│   ├── UserRepository.kt
│   └── custom/
│       ├── CustomUserRepository.kt
│       └── CustomUserRepositoryImpl.kt
├── domain/                     # Domain models
│   ├── entity/
│   │   ├── User.kt
│   │   └── Role.kt
│   ├── dto/
│   │   ├── UserRequest.kt
│   │   ├── UserResponse.kt
│   │   └── AuthRequest.kt
│   └── mapper/
│       ├── UserMapper.kt
│       └── AuthMapper.kt
├── security/                   # Security components
│   ├── JwtTokenProvider.kt
│   ├── SecurityUserDetails.kt
│   └── AuthenticationFilter.kt
├── exception/                  # Custom exceptions
│   ├── UserServiceException.kt
│   ├── AuthException.kt
│   └── GlobalExceptionHandler.kt
└── util/                      # Utility classes
    ├── Extensions.kt
    ├── Constants.kt
    └── Validators.kt
```

### File Organization Best Practices
```kotlin
// ✅ CORRECT: File structure
// UserService.kt
package com.company.app.service

import com.company.app.domain.entity.User
import com.company.app.domain.dto.UserRequest
import com.company.app.repository.UserRepository
import com.company.app.exception.UserServiceException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class UserService(
    private val userRepository: UserRepository,
    private val userMapper: UserMapper
) {
    // Implementation
}
```

---

## Testing Requirements

### Unit Test Structure
```kotlin
// ✅ CORRECT: Test class structure
@ExtendWith(MockKExtension::class)
class UserServiceTest {
    
    @MockK
    private lateinit var userRepository: UserRepository
    
    @MockK
    private lateinit var userMapper: UserMapper
    
    private lateinit var userService: UserService
    
    @BeforeEach
    fun setup() {
        userService = UserService(userRepository, userMapper)
    }
    
    @Test
    fun `should return user when valid id provided`() {
        // Given
        val userId = 1L
        val expectedUser = createTestUser(userId)
        every { userRepository.findById(userId) } returns expectedUser
        
        // When
        val result = userService.findUserSafely(userId)
        
        // Then
        assertThat(result).isInstanceOf(Result.Success::class.java)
        assertThat((result as Result.Success).data).isEqualTo(expectedUser)
        verify { userRepository.findById(userId) }
    }
    
    @Test
    fun `should return error when user not found`() {
        // Given
        val userId = 999L
        every { userRepository.findById(userId) } returns null
        
        // When
        val result = userService.findUserSafely(userId)
        
        // Then
        assertThat(result).isInstanceOf(Result.Error::class.java)
        val error = (result as Result.Error).exception
        assertThat(error).isInstanceOf(UserServiceException.UserNotFoundException::class.java)
    }
    
    private fun createTestUser(id: Long) = User(
        id = id,
        email = "test@example.com",
        firstName = "John",
        lastName = "Doe"
    )
}
```

### Integration Test Structure
```kotlin
@SpringBootTest
@TestPropertySource(properties = ["spring.profiles.active=test"])
@Testcontainers
class UserRepositoryIntegrationTest {
    
    @Container
    companion object {
        @JvmStatic
        val postgres: PostgreSQLContainer<*> = PostgreSQLContainer("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test")
    }
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Test
    fun `should save and retrieve user correctly`() {
        // Given
        val user = User(
            email = "test@example.com",
            firstName = "John",
            lastName = "Doe"
        )
        
        // When
        val savedUser = userRepository.save(user)
        val retrievedUser = userRepository.findById(savedUser.id)
        
        // Then
        assertThat(retrievedUser).isNotNull
        assertThat(retrievedUser?.email).isEqualTo("test@example.com")
        assertThat(retrievedUser?.firstName).isEqualTo("John")
    }
}
```

---

## Performance Guidelines

### Efficient Kotlin Patterns
```kotlin
// ✅ CORRECT: Use sequence for large collections
fun processLargeDataset(items: List<Item>): List<ProcessedItem> {
    return items.asSequence()
        .filter { it.isValid }
        .map { processItem(it) }
        .filter { it.isSuccessful }
        .toList()
}

// ✅ CORRECT: Use lazy initialization
class ExpensiveService {
    private val expensiveResource by lazy {
        createExpensiveResource()
    }
    
    fun useResource() {
        expensiveResource.doSomething()
    }
}

// ✅ CORRECT: Use inline functions for higher-order functions
inline fun <T> measureTime(block: () -> T): Pair<T, Long> {
    val start = System.currentTimeMillis()
    val result = block()
    val end = System.currentTimeMillis()
    return result to (end - start)
}
```

### Database Performance
```kotlin
// ✅ CORRECT: Use pagination for large datasets
@Repository
interface UserRepository : JpaRepository<User, Long> {
    
    @Query("SELECT u FROM User u WHERE u.isActive = true")
    fun findActiveUsers(pageable: Pageable): Page<User>
    
    @Query("SELECT u FROM User u WHERE u.email = :email")
    fun findByEmailOptimized(@Param("email") email: String): Optional<User>
}

// ✅ CORRECT: Use batch operations
@Service
class UserBatchService {
    
    @Transactional
    fun createUsersInBatch(users: List<CreateUserRequest>): List<User> {
        val entities = users.map { it.toEntity() }
        return userRepository.saveAll(entities)
    }
}
```

---

## Security Practices

### Input Validation
```kotlin
// ✅ CORRECT: Comprehensive validation
data class CreateUserRequest(
    @field:NotBlank(message = "Email is required")
    @field:Email(message = "Invalid email format")
    @field:Size(max = 255, message = "Email too long")
    val email: String,
    
    @field:NotBlank(message = "Password is required")
    @field:Size(min = 8, max = 128, message = "Password must be 8-128 characters")
    @field:Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]",
        message = "Password must contain uppercase, lowercase, digit, and special character"
    )
    val password: String,
    
    @field:Size(min = 2, max = 50, message = "Name must be 2-50 characters")
    val firstName: String,
    
    @field:Size(min = 2, max = 50, message = "Name must be 2-50 characters")
    val lastName: String
)
```

### Secure Coding Practices
```kotlin
// ✅ CORRECT: Password hashing
@Service
class AuthService(
    private val passwordEncoder: PasswordEncoder
) {
    
    fun createUser(request: CreateUserRequest): User {
        val hashedPassword = passwordEncoder.encode(request.password)
        return User(
            email = request.email.lowercase(),
            passwordHash = hashedPassword,
            firstName = request.firstName.trim(),
            lastName = request.lastName.trim()
        )
    }
}

// ✅ CORRECT: SQL injection prevention with JPA
@Repository
interface UserRepository : JpaRepository<User, Long> {
    
    @Query("SELECT u FROM User u WHERE u.email = :email AND u.isActive = true")
    fun findActiveUserByEmail(@Param("email") email: String): Optional<User>
}
```

---

## Documentation Standards

### KDoc Documentation
```kotlin
/**
 * Service for managing user-related operations.
 * 
 * This service handles user creation, updates, authentication, and provides
 * business logic for user management across the application.
 * 
 * @property userRepository Repository for user data access
 * @property passwordEncoder Service for password hashing and validation
 * @since 1.0.0
 * @author Development Team
 */
@Service
class UserService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder
) {
    
    /**
     * Creates a new user with the provided information.
     * 
     * Validates the input, checks for duplicate emails, and creates a new user
     * with a securely hashed password.
     * 
     * @param request The user creation request containing user details
     * @return Result containing the created user or an error
     * @throws UserServiceException.DuplicateUserException if email already exists
     * @throws UserServiceException.InvalidEmailException if email format is invalid
     * 
     * @sample
     * ```kotlin
     * val request = CreateUserRequest(
     *     email = "john@example.com",
     *     password = "SecurePass123!",
     *     firstName = "John",
     *     lastName = "Doe"
     * )
     * val result = userService.createUser(request)
     * ```
     */
    fun createUser(request: CreateUserRequest): Result<User> {
        // Implementation
    }
}
```

---

## Analysis Checklist

### Code Quality Checks
- [ ] **Naming Conventions**
  - [ ] Classes use PascalCase
  - [ ] Functions use camelCase
  - [ ] Properties use camelCase
  - [ ] Constants use SCREAMING_SNAKE_CASE
  - [ ] Packages use lowercase
  - [ ] Boolean properties use is/has/can prefix
  - [ ] No abbreviations in names

- [ ] **Null Safety**
  - [ ] Explicit nullable types used
  - [ ] Safe calls (?.) used instead of !!
  - [ ] Elvis operator (?:) used for defaults
  - [ ] let/run/apply used for null-safe operations
  - [ ] requireNotNull/checkNotNull used for validation

- [ ] **Error Handling**
  - [ ] Custom exception hierarchy defined
  - [ ] Result/sealed classes used for error states
  - [ ] Global exception handler implemented
  - [ ] Proper logging in catch blocks
  - [ ] Meaningful error messages provided

- [ ] **Library Usage**
  - [ ] Standard library used efficiently
  - [ ] Framework-specific libraries used correctly
  - [ ] No deprecated libraries used
  - [ ] Proper dependency injection patterns
  - [ ] Thread-safe usage of libraries

- [ ] **Code Organization**
  - [ ] Proper package structure followed
  - [ ] Single responsibility principle applied
  - [ ] Dependency injection used properly
  - [ ] Configuration externalized
  - [ ] Separation of concerns maintained

- [ ] **Testing**
  - [ ] Unit tests have 90%+ coverage
  - [ ] Integration tests for critical paths
  - [ ] Proper test naming conventions
  - [ ] Mock usage is appropriate
  - [ ] Test data is isolated

- [ ] **Performance**
  - [ ] Lazy initialization used where appropriate
  - [ ] Sequences used for large collections
  - [ ] Database queries optimized
  - [ ] Caching implemented where needed
  - [ ] Resource management proper

- [ ] **Security**
  - [ ] Input validation implemented
  - [ ] SQL injection prevention in place
  - [ ] Password hashing used
  - [ ] Authorization checks present
  - [ ] Sensitive data handling secure

## Reference URLs for Claude Code

### Official Documentation
- **Kotlin Language**: https://kotlinlang.org/docs/home.html
- **Kotlin Coding Conventions**: https://kotlinlang.org/docs/coding-conventions.html
- **Kotlin Coroutines**: https://kotlinlang.org/docs/coroutines-overview.html

### Spring Boot with Kotlin
- **Spring Boot Kotlin Guide**: https://spring.io/guides/tutorials/spring-boot-kotlin/
- **Spring Framework Kotlin Support**: https://docs.spring.io/spring-framework/docs/current/reference/html/languages.html#kotlin
- **Spring Boot Documentation**: https://docs.spring.io/spring-boot/docs/current/reference/html/

### Android with Kotlin
- **Android Kotlin Guide**: https://developer.android.com/kotlin
- **Jetpack Compose**: https://developer.android.com/jetpack/compose
- **Android Architecture Guide**: https://developer.android.com/topic/architecture

### Testing
- **Kotlin Testing**: https://kotlinlang.org/docs/jvm-test-using-junit.html
- **MockK Framework**: https://mockk.io/
- **Spring Boot Testing**: https://docs.spring.io/spring-boot/docs/current/reference/html/spring-boot-features.html#boot-features-testing

### Tools and Analysis
- **ktlint**: https://ktlint.github.io/
- **detekt**: https://detekt.github.io/detekt/
- **Gradle Kotlin DSL**: https://docs.gradle.org/current/userguide/kotlin_dsl.html

### Best Practices
- **Clean Code Kotlin**: https://github.com/Kotlin/KEEP
- **Arrow Functional Programming**: https://arrow-kt.io/
- **Kotlin Style Guide by Google**: https://developer.android.com/kotlin/style-guide

---

**Note**: This document should be used as the primary reference for Kotlin code analysis and development standards. Regular updates should be made to reflect new Kotlin features and evolving best practices.