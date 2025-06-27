# Spring Boot REST API Best Practices - Kotlin/Java Code Analysis Guide

## Document Information
- **Purpose**: Comprehensive REST API best practices for Spring Boot with Java and Kotlin
- **Last Updated**: June 26, 2025
- **Document Version**: 2.0.0
- **Target Frameworks**: Spring Boot 3.x, Java 17+, Kotlin 2.1+
- **Integration**: Designed for Claude Code analysis and project validation

## Table of Contents
1. [API Design Principles](#api-design-principles)
2. [HTTP Status Codes](#http-status-codes)
3. [Request/Response Patterns](#requestresponse-patterns)
4. [Error Handling](#error-handling)
5. [Validation and Feedback](#validation-and-feedback)
6. [Security Practices](#security-practices)
7. [Performance Optimization](#performance-optimization)
8. [Documentation Standards](#documentation-standards)
9. [Testing Requirements](#testing-requirements)
10. [Code Analysis Checklist](#code-analysis-checklist)

---

## API Design Principles

### RESTful Resource Design
**✅ CORRECT Patterns:**
```kotlin
// Resource-based URLs
GET    /api/v1/users           // Get all users
GET    /api/v1/users/{id}      // Get specific user
POST   /api/v1/users           // Create new user
PUT    /api/v1/users/{id}      // Update entire user
PATCH  /api/v1/users/{id}      // Partial user update
DELETE /api/v1/users/{id}      // Delete user

// Nested resources
GET    /api/v1/users/{id}/orders        // Get user's orders
POST   /api/v1/users/{id}/orders        // Create order for user
GET    /api/v1/users/{id}/orders/{orderId}  // Get specific order
```

**❌ INCORRECT Patterns:**
```kotlin
// Avoid verb-based URLs
POST /api/v1/createUser
GET  /api/v1/getUserById/{id}
POST /api/v1/deleteUser/{id}

// Avoid deep nesting (max 2 levels)
GET /api/v1/users/{id}/orders/{orderId}/items/{itemId}/reviews
```

### API Versioning Strategy
```kotlin
@RestController
@RequestMapping("/api/v1/users")
class UserControllerV1 {
    // Implementation
}

@RestController
@RequestMapping("/api/v2/users")
class UserControllerV2 {
    // Implementation with breaking changes
}

// Header-based versioning (alternative)
@GetMapping(value = "/users", headers = "API-Version=1")
fun getUsersV1(): ResponseEntity<List<UserDto>> { }

@GetMapping(value = "/users", headers = "API-Version=2")
fun getUsersV2(): ResponseEntity<List<UserDtoV2>> { }
```

---

## HTTP Status Codes

### Standard Status Code Usage
```kotlin
@RestController
class UserController {
    
    // 200 OK - Successful GET, PUT, PATCH
    @GetMapping("/{id}")
    fun getUser(@PathVariable id: Long): ResponseEntity<UserDto> {
        val user = userService.findById(id)
        return ResponseEntity.ok(user)
    }
    
    // 201 Created - Successful POST
    @PostMapping
    fun createUser(@Valid @RequestBody request: CreateUserRequest): ResponseEntity<UserDto> {
        val user = userService.createUser(request)
        return ResponseEntity.status(HttpStatus.CREATED)
            .location(URI.create("/api/v1/users/${user.id}"))
            .body(user)
    }
    
    // 204 No Content - Successful DELETE
    @DeleteMapping("/{id}")
    fun deleteUser(@PathVariable id: Long): ResponseEntity<Void> {
        userService.deleteUser(id)
        return ResponseEntity.noContent().build()
    }
    
    // 400 Bad Request - Validation errors
    @PostMapping
    fun createUser(@Valid @RequestBody request: CreateUserRequest): ResponseEntity<*> {
        try {
            val user = userService.createUser(request)
            return ResponseEntity.status(HttpStatus.CREATED).body(user)
        } catch (e: ValidationException) {
            return ResponseEntity.badRequest().body(
                ErrorResponse("VALIDATION_ERROR", e.message)
            )
        }
    }
    
    // 404 Not Found - Resource not found
    @GetMapping("/{id}")
    fun getUser(@PathVariable id: Long): ResponseEntity<*> {
        return try {
            val user = userService.findById(id)
            ResponseEntity.ok(user)
        } catch (e: UserNotFoundException) {
            ResponseEntity.notFound().build<Any>()
        }
    }
    
    // 409 Conflict - Business rule violation
    @PostMapping
    fun createUser(@Valid @RequestBody request: CreateUserRequest): ResponseEntity<*> {
        return try {
            val user = userService.createUser(request)
            ResponseEntity.status(HttpStatus.CREATED).body(user)
        } catch (e: DuplicateEmailException) {
            ResponseEntity.status(HttpStatus.CONFLICT).body(
                ErrorResponse("DUPLICATE_EMAIL", e.message)
            )
        }
    }
}
```

### Status Code Reference
| Code | Usage | Description |
|------|-------|-------------|
| 200 | GET, PUT, PATCH success | Request successful |
| 201 | POST success | Resource created |
| 204 | DELETE success | No content to return |
| 400 | Validation error | Bad request/invalid input |
| 401 | Authentication failure | Unauthorized |
| 403 | Authorization failure | Forbidden |
| 404 | Resource not found | Not found |
| 409 | Business rule violation | Conflict |
| 422 | Semantic validation error | Unprocessable entity |
| 500 | Server error | Internal server error |

---

## Request/Response Patterns

### Request DTOs (Java)
```java
// Create request
public record CreateUserRequest(
    @NotBlank(message = "First name is required")
    @Size(max = 100, message = "First name must not exceed 100 characters")
    String firstName,
    
    @NotBlank(message = "Last name is required")
    @Size(max = 100, message = "Last name must not exceed 100 characters")
    String lastName,
    
    @Email(message = "Invalid email format")
    @NotBlank(message = "Email is required")
    String email,
    
    @Size(min = 8, message = "Password must be at least 8 characters")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*$", 
             message = "Password must contain uppercase, lowercase, and digit")
    String password
) {}

// Update request (partial)
public record UpdateUserRequest(
    @Size(max = 100, message = "First name must not exceed 100 characters")
    Optional<String> firstName,
    
    @Size(max = 100, message = "Last name must not exceed 100 characters")
    Optional<String> lastName,
    
    @Email(message = "Invalid email format")
    Optional<String> email
) {}
```

### Request DTOs (Kotlin)
```kotlin
// Create request
data class CreateUserRequest(
    @field:NotBlank(message = "First name is required")
    @field:Size(max = 100, message = "First name must not exceed 100 characters")
    val firstName: String,
    
    @field:NotBlank(message = "Last name is required")
    @field:Size(max = 100, message = "Last name must not exceed 100 characters")
    val lastName: String,
    
    @field:Email(message = "Invalid email format")
    @field:NotBlank(message = "Email is required")
    val email: String,
    
    @field:Size(min = 8, message = "Password must be at least 8 characters")
    @field:Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*$",
        message = "Password must contain uppercase, lowercase, and digit"
    )
    val password: String
)

// Update request (partial)
data class UpdateUserRequest(
    @field:Size(max = 100, message = "First name must not exceed 100 characters")
    val firstName: String? = null,
    
    @field:Size(max = 100, message = "Last name must not exceed 100 characters")
    val lastName: String? = null,
    
    @field:Email(message = "Invalid email format")
    val email: String? = null
) {
    fun hasValidUpdates(): Boolean = firstName != null || lastName != null || email != null
}
```

### Response DTOs
```kotlin
// Standard response wrapper
data class ApiResponse<T>(
    val data: T? = null,
    val success: Boolean = true,
    val message: String? = null,
    val timestamp: Instant = Instant.now(),
    val path: String? = null
) {
    companion object {
        fun <T> success(data: T, message: String? = null): ApiResponse<T> =
            ApiResponse(data = data, message = message)
            
        fun <T> error(message: String, path: String? = null): ApiResponse<T> =
            ApiResponse(success = false, message = message, path = path)
    }
}

// User response DTO
data class UserDto(
    val id: Long,
    val firstName: String,
    val lastName: String,
    val email: String,
    val status: UserStatus,
    val createdAt: Instant,
    val updatedAt: Instant
) {
    val fullName: String
        get() = "$firstName $lastName"
}

// Paginated response
data class PagedResponse<T>(
    val content: List<T>,
    val page: Int,
    val size: Int,
    val totalElements: Long,
    val totalPages: Int,
    val first: Boolean,
    val last: Boolean,
    val hasNext: Boolean,
    val hasPrevious: Boolean
)
```

---

## Error Handling

### Custom Exception Hierarchy
```kotlin
// Domain exceptions
sealed class UserServiceException(message: String, cause: Throwable? = null) : RuntimeException(message, cause) {
    class UserNotFoundException(userId: Long) : UserServiceException("User with ID $userId not found")
    class DuplicateEmailException(email: String) : UserServiceException("User with email $email already exists")
    class InvalidUserStatusException(status: String) : UserServiceException("Invalid user status: $status")
    class UserValidationException(field: String, message: String) : UserServiceException("Validation error for $field: $message")
}

// Infrastructure exceptions
sealed class DatabaseException(message: String, cause: Throwable? = null) : RuntimeException(message, cause) {
    class ConnectionException(message: String, cause: Throwable) : DatabaseException(message, cause)
    class QueryException(message: String, cause: Throwable) : DatabaseException(message, cause)
    class TransactionException(message: String, cause: Throwable) : DatabaseException(message, cause)
}
```

### Global Exception Handler
```kotlin
@RestControllerAdvice
class GlobalExceptionHandler {
    
    private val logger = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)
    
    @ExceptionHandler(UserServiceException.UserNotFoundException::class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    fun handleUserNotFound(
        ex: UserServiceException.UserNotFoundException,
        request: HttpServletRequest
    ): ApiResponse<Nothing> {
        logger.warn("User not found: {}", ex.message)
        return ApiResponse.error(
            message = ex.message ?: "User not found",
            path = request.requestURI
        )
    }
    
    @ExceptionHandler(UserServiceException.DuplicateEmailException::class)
    @ResponseStatus(HttpStatus.CONFLICT)
    fun handleDuplicateEmail(
        ex: UserServiceException.DuplicateEmailException,
        request: HttpServletRequest
    ): ApiResponse<Nothing> {
        logger.warn("Duplicate email attempt: {}", ex.message)
        return ApiResponse.error(
            message = ex.message ?: "Email already exists",
            path = request.requestURI
        )
    }
    
    @ExceptionHandler(MethodArgumentNotValidException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleValidationErrors(
        ex: MethodArgumentNotValidException,
        request: HttpServletRequest
    ): ValidationErrorResponse {
        logger.warn("Validation error: {}", ex.message)
        
        val errors = ex.bindingResult.fieldErrors.map { error ->
            FieldError(
                field = error.field,
                message = error.defaultMessage ?: "Invalid value",
                rejectedValue = error.rejectedValue?.toString()
            )
        }
        
        return ValidationErrorResponse(
            message = "Validation failed",
            errors = errors,
            path = request.requestURI,
            timestamp = Instant.now()
        )
    }
    
    @ExceptionHandler(ConstraintViolationException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun handleConstraintViolation(
        ex: ConstraintViolationException,
        request: HttpServletRequest
    ): ValidationErrorResponse {
        logger.warn("Constraint violation: {}", ex.message)
        
        val errors = ex.constraintViolations.map { violation ->
            FieldError(
                field = violation.propertyPath.toString(),
                message = violation.message,
                rejectedValue = violation.invalidValue?.toString()
            )
        }
        
        return ValidationErrorResponse(
            message = "Validation failed",
            errors = errors,
            path = request.requestURI,
            timestamp = Instant.now()
        )
    }
    
    @ExceptionHandler(Exception::class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    fun handleGenericException(
        ex: Exception,
        request: HttpServletRequest
    ): ApiResponse<Nothing> {
        logger.error("Unhandled exception", ex)
        return ApiResponse.error(
            message = "An unexpected error occurred",
            path = request.requestURI
        )
    }
}

// Error response DTOs
data class ValidationErrorResponse(
    val message: String,
    val errors: List<FieldError>,
    val path: String,
    val timestamp: Instant,
    val success: Boolean = false
)

data class FieldError(
    val field: String,
    val message: String,
    val rejectedValue: String? = null
)
```

---

## Validation and Feedback

### Input Validation Best Practices
```kotlin
@RestController
@RequestMapping("/api/v1/users")
@Validated
class UserController(private val userService: UserService) {
    
    // Method-level validation for path variables
    @GetMapping("/{id}")
    fun getUser(
        @PathVariable 
        @Min(value = 1, message = "User ID must be positive")
        id: Long
    ): ResponseEntity<UserDto> {
        val user = userService.findById(id)
        return ResponseEntity.ok(user)
    }
    
    // Request body validation
    @PostMapping
    fun createUser(
        @Valid @RequestBody request: CreateUserRequest
    ): ResponseEntity<UserDto> {
        val user = userService.createUser(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(user)
    }
    
    // Query parameter validation
    @GetMapping
    fun getUsers(
        @RequestParam(defaultValue = "0")
        @Min(value = 0, message = "Page number must not be negative")
        page: Int,
        
        @RequestParam(defaultValue = "20")
        @Min(value = 1, message = "Page size must be positive")
        @Max(value = 100, message = "Page size must not exceed 100")
        size: Int,
        
        @RequestParam(required = false)
        @Pattern(regexp = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", 
                 message = "Invalid email format")
        email: String?
    ): ResponseEntity<PagedResponse<UserDto>> {
        val users = userService.findUsers(page, size, email)
        return ResponseEntity.ok(users)
    }
}
```

### Custom Validators
```kotlin
// Custom validation annotation
@Target(AnnotationTarget.FIELD, AnnotationTarget.VALUE_PARAMETER)
@Retention(AnnotationRetention.RUNTIME)
@Constraint(validatedBy = [UniqueEmailValidator::class])
@MustBeDocumented
annotation class UniqueEmail(
    val message: String = "Email already exists",
    val groups: Array<KClass<*>> = [],
    val payload: Array<KClass<out Payload>> = []
)

// Custom validator implementation
@Component
class UniqueEmailValidator(
    private val userRepository: UserRepository
) : ConstraintValidator<UniqueEmail, String> {
    
    override fun isValid(email: String?, context: ConstraintValidatorContext): Boolean {
        if (email.isNullOrBlank()) return true // Let @NotBlank handle this
        return !userRepository.existsByEmail(email)
    }
}

// Usage in DTO
data class CreateUserRequest(
    @field:NotBlank(message = "Email is required")
    @field:Email(message = "Invalid email format")
    @field:UniqueEmail
    val email: String,
    // ... other fields
)
```

### Feedback Mechanisms
```kotlin
// Service layer with detailed feedback
@Service
class UserService(
    private val userRepository: UserRepository,
    private val emailService: EmailService
) {
    
    fun createUser(request: CreateUserRequest): UserCreationResult {
        // Business validation with detailed feedback
        val validationResult = validateUserCreation(request)
        if (!validationResult.isValid) {
            return UserCreationResult.ValidationFailed(validationResult.errors)
        }
        
        try {
            val user = userRepository.save(request.toEntity())
            emailService.sendWelcomeEmail(user.email)
            
            return UserCreationResult.Success(
                user = user.toDto(),
                message = "User created successfully. Welcome email sent."
            )
        } catch (e: DataIntegrityViolationException) {
            return UserCreationResult.Failed("Email already exists")
        } catch (e: Exception) {
            logger.error("Failed to create user", e)
            return UserCreationResult.Failed("Failed to create user")
        }
    }
    
    private fun validateUserCreation(request: CreateUserRequest): ValidationResult {
        val errors = mutableListOf<String>()
        
        // Business rule validations
        if (userRepository.existsByEmail(request.email)) {
            errors.add("Email already exists")
        }
        
        if (!isValidEmailDomain(request.email)) {
            errors.add("Email domain not allowed")
        }
        
        return ValidationResult(errors.isEmpty(), errors)
    }
}

// Result types for detailed feedback
sealed class UserCreationResult {
    data class Success(val user: UserDto, val message: String) : UserCreationResult()
    data class ValidationFailed(val errors: List<String>) : UserCreationResult()
    data class Failed(val message: String) : UserCreationResult()
}

data class ValidationResult(
    val isValid: Boolean,
    val errors: List<String>
)
```

---

## Security Practices

### Authentication and Authorization
```kotlin
@RestController
@RequestMapping("/api/v1/users")
@PreAuthorize("hasRole('USER')")
class UserController {
    
    // Public endpoint (override class-level security)
    @GetMapping("/public/count")
    @PreAuthorize("permitAll()")
    fun getUserCount(): ResponseEntity<Long> {
        val count = userService.getUserCount()
        return ResponseEntity.ok(count)
    }
    
    // User can only access their own data
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or #id == authentication.principal.id")
    fun getUser(@PathVariable id: Long): ResponseEntity<UserDto> {
        val user = userService.findById(id)
        return ResponseEntity.ok(user)
    }
    
    // Admin only
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    fun deleteUser(@PathVariable id: Long): ResponseEntity<Void> {
        userService.deleteUser(id)
        return ResponseEntity.noContent().build()
    }
    
    // Current user's profile
    @GetMapping("/me")
    fun getCurrentUser(authentication: Authentication): ResponseEntity<UserDto> {
        val userId = authentication.principal as Long
        val user = userService.findById(userId)
        return ResponseEntity.ok(user)
    }
}
```

### Input Sanitization
```kotlin
@Component
class InputSanitizer {
    
    private val policy = AntiSamy.Policy.getInstance(
        javaClass.getResourceAsStream("/antisamy-policy.xml")
    )
    private val antiSamy = AntiSamy()
    
    fun sanitizeHtml(input: String?): String? {
        if (input.isNullOrBlank()) return input
        
        return try {
            val cleanResults = antiSamy.scan(input, policy)
            cleanResults.cleanHtml
        } catch (e: Exception) {
            logger.warn("Failed to sanitize input", e)
            "" // Return empty string for invalid input
        }
    }
    
    fun sanitizeString(input: String?): String? {
        return input?.trim()
            ?.replace(Regex("[<>\"'&]"), "")
            ?.take(1000) // Limit length
    }
}
```

---

## Performance Optimization

### Pagination and Filtering
```kotlin
@RestController
@RequestMapping("/api/v1/users")
class UserController(private val userService: UserService) {
    
    @GetMapping
    fun getUsers(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "20") size: Int,
        @RequestParam(required = false) search: String?,
        @RequestParam(required = false) status: UserStatus?,
        @RequestParam(defaultValue = "createdAt") sortBy: String,
        @RequestParam(defaultValue = "DESC") sortDirection: String
    ): ResponseEntity<PagedResponse<UserDto>> {
        
        val pageable = PageRequest.of(
            page, 
            size, 
            Sort.by(Sort.Direction.fromString(sortDirection), sortBy)
        )
        
        val criteria = UserSearchCriteria(
            search = search,
            status = status
        )
        
        val users = userService.findUsers(criteria, pageable)
        return ResponseEntity.ok(users.toPagedResponse())
    }
}

// Service implementation with specifications
@Service
class UserService(private val userRepository: UserRepository) {
    
    fun findUsers(criteria: UserSearchCriteria, pageable: Pageable): Page<UserDto> {
        val specification = UserSpecifications.buildSpecification(criteria)
        return userRepository.findAll(specification, pageable)
            .map { it.toDto() }
    }
}

// Specification builder
object UserSpecifications {
    
    fun buildSpecification(criteria: UserSearchCriteria): Specification<User> {
        return Specification.where(null)
            .and(hasSearchTerm(criteria.search))
            .and(hasStatus(criteria.status))
    }
    
    private fun hasSearchTerm(search: String?): Specification<User>? {
        return if (search.isNullOrBlank()) null
        else Specification { root, _, cb ->
            val searchTerm = "%${search.lowercase()}%"
            cb.or(
                cb.like(cb.lower(root.get("firstName")), searchTerm),
                cb.like(cb.lower(root.get("lastName")), searchTerm),
                cb.like(cb.lower(root.get("email")), searchTerm)
            )
        }
    }
    
    private fun hasStatus(status: UserStatus?): Specification<User>? {
        return if (status == null) null
        else Specification { root, _, cb ->
            cb.equal(root.get<UserStatus>("status"), status)
        }
    }
}
```

### Caching Strategy
```kotlin
@Service
@CacheConfig(cacheNames = ["users"])
class UserService {
    
    @Cacheable(key = "#id")
    fun findById(id: Long): UserDto {
        return userRepository.findById(id)
            ?.toDto()
            ?: throw UserNotFoundException(id)
    }
    
    @CacheEvict(key = "#userDto.id")
    fun updateUser(userDto: UserDto): UserDto {
        // Update logic
        return updatedUser
    }
    
    @CacheEvict(key = "#id")
    fun deleteUser(id: Long) {
        userRepository.deleteById(id)
    }
    
    @Cacheable(
        key = "#criteria.hashCode() + '_' + #pageable.pageNumber + '_' + #pageable.pageSize",
        condition = "#criteria.search == null"
    )
    fun findUsers(criteria: UserSearchCriteria, pageable: Pageable): Page<UserDto> {
        // Search logic
    }
}
```

---

## Documentation Standards

### OpenAPI/Swagger Configuration
```kotlin
@Configuration
@EnableWebMvc
class OpenApiConfig {
    
    @Bean
    fun openApi(): OpenAPI {
        return OpenAPI()
            .info(
                Info()
                    .title("User Management API")
                    .description("REST API for user management system")
                    .version("v1.0.0")
                    .contact(
                        Contact()
                            .name("API Support")
                            .email("api-support@company.com")
                            .url("https://company.com/support")
                    )
                    .license(
                        License()
                            .name("MIT License")
                            .url("https://opensource.org/licenses/MIT")
                    )
            )
            .servers(
                listOf(
                    Server()
                        .url("https://api.company.com")
                        .description("Production server"),
                    Server()
                        .url("https://staging-api.company.com")
                        .description("Staging server")
                )
            )
    }
}
```

### API Documentation Annotations
```kotlin
@RestController
@RequestMapping("/api/v1/users")
@Tag(name = "User Management", description = "Operations related to user management")
class UserController {
    
    @Operation(
        summary = "Get user by ID",
        description = "Retrieves a specific user by their unique identifier"
    )
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "User found successfully",
                content = [Content(
                    mediaType = "application/json",
                    schema = Schema(implementation = UserDto::class)
                )]
            ),
            ApiResponse(
                responseCode = "404",
                description = "User not found",
                content = [Content(
                    mediaType = "application/json",
                    schema = Schema(implementation = ApiResponse::class)
                )]
            ),
            ApiResponse(
                responseCode = "401",
                description = "Unauthorized access"
            )
        ]
    )
    @GetMapping("/{id}")
    fun getUser(
        @Parameter(
            description = "User unique identifier",
            required = true,
            example = "123"
        )
        @PathVariable id: Long
    ): ResponseEntity<UserDto> {
        val user = userService.findById(id)
        return ResponseEntity.ok(user)
    }
    
    @Operation(
        summary = "Create new user",
        description = "Creates a new user account with the provided information"
    )
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "201",
                description = "User created successfully"
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid input data"
            ),
            ApiResponse(
                responseCode = "409",
                description = "User with email already exists"
            )
        ]
    )
    @PostMapping
    fun createUser(
        @Parameter(
            description = "User creation data",
            required = true
        )
        @Valid @RequestBody request: CreateUserRequest
    ): ResponseEntity<UserDto> {
        val user = userService.createUser(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(user)
    }
}
```

---

## Testing Requirements

### Controller Testing
```kotlin
@WebMvcTest(UserController::class)
@MockBean(UserService::class)
class UserControllerTest {
    
    @Autowired
    private lateinit var mockMvc: MockMvc
    
    @MockBean
    private lateinit var userService: UserService
    
    @Test
    fun `should return user when valid id provided`() {
        // Given
        val userId = 1L
        val userDto = UserDto(
            id = userId,
            firstName = "John",
            lastName = "Doe",
            email = "john.doe@example.com",
            status = UserStatus.ACTIVE,
            createdAt = Instant.now(),
            updatedAt = Instant.now()
        )
        
        every { userService.findById(userId) } returns userDto
        
        // When & Then
        mockMvc.perform(
            post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(invalidRequest)
        )
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.success").value(false))
            .andExpect(jsonPath("$.errors").isArray)
            .andExpect(jsonPath("$.errors", hasSize(4)))
            .andExpect(jsonPath("$.errors[*].field", containsInAnyOrder(
                "firstName", "lastName", "email", "password"
            )))
    }
    
    @Test
    fun `should return 404 when user not found`() {
        // Given
        val userId = 999L
        every { userService.findById(userId) } throws UserServiceException.UserNotFoundException(userId)
        
        // When & Then
        mockMvc.perform(get("/api/v1/users/$userId"))
            .andExpect(status().isNotFound)
            .andExpect(jsonPath("$.success").value(false))
            .andExpect(jsonPath("$.message").value("User with ID $userId not found"))
        
        verify { userService.findById(userId) }
    }
}
```

### Integration Testing
```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@TestPropertySource(properties = [
    "spring.datasource.url=jdbc:tc:postgresql:13:///testdb",
    "spring.jpa.hibernate.ddl-auto=create-drop"
])
class UserControllerIntegrationTest {
    
    @Autowired
    private lateinit var restTemplate: TestRestTemplate
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    companion object {
        @Container
        val postgres = PostgreSQLContainer<Nothing>("postgres:13").apply {
            withDatabaseName("testdb")
            withUsername("test")
            withPassword("test")
        }
    }
    
    @BeforeEach
    fun setUp() {
        userRepository.deleteAll()
    }
    
    @Test
    fun `should create user successfully`() {
        // Given
        val request = CreateUserRequest(
            firstName = "John",
            lastName = "Doe",
            email = "john.doe@example.com",
            password = "SecurePass123"
        )
        
        // When
        val response = restTemplate.postForEntity(
            "/api/v1/users",
            request,
            UserDto::class.java
        )
        
        // Then
        assertThat(response.statusCode).isEqualTo(HttpStatus.CREATED)
        assertThat(response.body).isNotNull
        assertThat(response.body!!.email).isEqualTo("john.doe@example.com")
        
        // Verify database state
        val savedUser = userRepository.findByEmail("john.doe@example.com")
        assertThat(savedUser).isNotNull
        assertThat(savedUser!!.firstName).isEqualTo("John")
    }
    
    @Test
    fun `should handle duplicate email gracefully`() {
        // Given
        val existingUser = User(
            firstName = "Jane",
            lastName = "Smith",
            email = "duplicate@example.com",
            password = "encoded-password"
        )
        userRepository.save(existingUser)
        
        val request = CreateUserRequest(
            firstName = "John",
            lastName = "Doe",
            email = "duplicate@example.com",
            password = "SecurePass123"
        )
        
        // When
        val response = restTemplate.postForEntity(
            "/api/v1/users",
            request,
            ApiResponse::class.java
        )
        
        // Then
        assertThat(response.statusCode).isEqualTo(HttpStatus.CONFLICT)
        assertThat(response.body!!.success).isFalse
        assertThat(response.body!!.message).contains("already exists")
    }
}
```

---

## Code Analysis Checklist

### ✅ API Design Compliance
- [ ] RESTful resource-based URLs (nouns, not verbs)
- [ ] Proper HTTP methods for operations (GET, POST, PUT, PATCH, DELETE)
- [ ] Consistent API versioning strategy implemented
- [ ] Resource nesting limited to 2 levels maximum
- [ ] Proper use of HTTP status codes for all scenarios
- [ ] Location header included in 201 Created responses

### ✅ Request/Response Patterns Compliance
- [ ] Request DTOs with proper validation annotations
- [ ] Response DTOs follow consistent structure
- [ ] Pagination implemented for list endpoints
- [ ] Filtering and sorting capabilities provided
- [ ] Proper content negotiation support (JSON primary)
- [ ] Optional fields handled correctly in update requests

### ✅ Error Handling Compliance
- [ ] Custom exception hierarchy defined for domain errors
- [ ] Global exception handler (@RestControllerAdvice) implemented
- [ ] Consistent error response format across all endpoints
- [ ] Appropriate HTTP status codes for different error types
- [ ] Detailed validation error responses with field-level feedback
- [ ] Security-sensitive information not exposed in error messages
- [ ] Proper logging of errors with appropriate levels

### ✅ Validation and Feedback Compliance
- [ ] Input validation using Bean Validation annotations
- [ ] Method-level validation for path variables and query parameters
- [ ] Custom validators for business rules
- [ ] Meaningful validation error messages
- [ ] Input sanitization for security
- [ ] Business rule validation in service layer
- [ ] Detailed feedback mechanisms for complex operations

### ✅ Security Compliance
- [ ] Authentication and authorization properly implemented
- [ ] Method-level security annotations used appropriately
- [ ] Input sanitization to prevent injection attacks
- [ ] Sensitive data not logged or exposed in responses
- [ ] CORS configuration appropriate for environment
- [ ] Rate limiting implemented for sensitive endpoints
- [ ] Security headers configured

### ✅ Performance Compliance
- [ ] Pagination implemented for large datasets
- [ ] Efficient query patterns (no N+1 problems)
- [ ] Appropriate caching strategies implemented
- [ ] Database queries optimized with proper indexing
- [ ] Lazy loading used appropriately
- [ ] Connection pooling configured
- [ ] Async processing for long-running operations

### ✅ Documentation Compliance
- [ ] OpenAPI/Swagger configuration complete
- [ ] All endpoints documented with @Operation annotations
- [ ] Request/response schemas documented
- [ ] Error responses documented
- [ ] Authentication requirements specified
- [ ] Example requests and responses provided
- [ ] API versioning documented

### ✅ Testing Compliance
- [ ] Unit tests for all controller methods (90%+ coverage)
- [ ] Integration tests for complete API workflows
- [ ] Validation testing for all input constraints
- [ ] Error scenario testing comprehensive
- [ ] Security testing for authentication/authorization
- [ ] Performance testing for critical endpoints
- [ ] Contract testing with consumer services

### ✅ Code Quality Compliance
- [ ] Consistent naming conventions followed
- [ ] Single Responsibility Principle applied
- [ ] Dependency injection used properly
- [ ] No business logic in controllers
- [ ] Proper exception handling throughout
- [ ] Code duplication minimized
- [ ] Configuration externalized appropriately

---

## Reference URLs for Claude Code

### Official Documentation
- **Spring Boot Reference**: https://docs.spring.io/spring-boot/docs/current/reference/html/
- **Spring Web MVC**: https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#mvc
- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
- **Spring Security**: https://docs.spring.io/spring-security/reference/
- **Bean Validation**: https://beanvalidation.org/2.0/spec/

### API Design and Standards
- **REST API Tutorial**: https://restfulapi.net/
- **OpenAPI Specification**: https://swagger.io/specification/
- **Spring REST Docs**: https://docs.spring.io/spring-restdocs/docs/current/reference/html5/
- **HTTP Status Codes**: https://httpstatuses.com/
- **JSON:API Specification**: https://jsonapi.org/

### Testing Resources
- **Spring Boot Testing**: https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing
- **TestContainers**: https://www.testcontainers.org/
- **MockMvc Documentation**: https://docs.spring.io/spring-framework/docs/current/reference/html/testing.html#spring-mvc-test-framework
- **AssertJ**: https://assertj.github.io/doc/

### Performance and Security
- **Spring Cache**: https://docs.spring.io/spring-framework/docs/current/reference/html/integration.html#cache
- **OWASP REST Security**: https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html
- **Spring Security Testing**: https://docs.spring.io/spring-security/reference/servlet/test/index.html

### Validation and Error Handling
- **Bean Validation Reference**: https://docs.jboss.org/hibernate/validator/6.2/reference/en-US/html_single/
- **Spring Validation**: https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#validation
- **Exception Handling**: https://spring.io/blog/2013/11/01/exception-handling-in-spring-mvc

---

**Note**: This comprehensive document serves as the authoritative guide for Spring Boot REST API development and code analysis. Use this as a reference for both implementation and validation of REST API projects.get("/api/v1/users/$userId"))
            .andExpect(status().isOk)
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.id").value(userId))
            .andExpect(jsonPath("$.firstName").value("John"))
            .andExpect(jsonPath("$.lastName").value("Doe"))
            .andExpect(jsonPath("$.email").value("john.doe@example.com"))
        
        verify { userService.findById(userId) }
    }
    
    @Test
    fun `should return validation errors when invalid data provided`() {
        // Given
        val invalidRequest = """
            {
                "firstName": "",
                "lastName": "",
                "email": "invalid-email",
                "password": "123"
            }
        """.trimIndent()
        
        // When & Then
        mockMvc.perform(