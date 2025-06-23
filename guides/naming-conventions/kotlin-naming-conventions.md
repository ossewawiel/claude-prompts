# Kotlin Naming Conventions - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Classes and Interfaces
```kotlin
// Classes: PascalCase
class UserService
class DatabaseManager
class PaymentProcessor

// Interfaces: PascalCase (no 'I' prefix)
interface UserRepository
interface PaymentGateway
interface NotificationService

// Abstract classes: PascalCase
abstract class BaseEntity
abstract class AbstractValidator

// Data classes: PascalCase
data class User(val id: Long, val name: String)
data class ApiResponse<T>(val data: T, val success: Boolean)
```

### Functions and Properties
```kotlin
// Functions: camelCase
fun getUserById(id: Long): User?
fun validateEmailAddress(email: String): Boolean
fun calculateTotalPrice(items: List<Item>): BigDecimal

// Properties: camelCase
val userName: String
val isActive: Boolean
val createdAt: LocalDateTime
var lastLoginTime: LocalDateTime?

// Boolean properties: use 'is' or 'has' prefix
val isValid: Boolean
val hasPermission: Boolean
val canEdit: Boolean
```

## IMPLEMENTATION STRATEGY

### Constants and Enums
```kotlin
// Constants: SCREAMING_SNAKE_CASE
const val MAX_RETRY_COUNT = 3
const val DEFAULT_TIMEOUT_SECONDS = 30
const val API_BASE_URL = "https://api.example.com"

// Companion object constants
class UserService {
    companion object {
        const val DEFAULT_PAGE_SIZE = 20
        const val MAX_USERNAME_LENGTH = 50
    }
}

// Enums: PascalCase for enum class, SCREAMING_SNAKE_CASE for values
enum class UserStatus {
    ACTIVE,
    INACTIVE,
    SUSPENDED,
    PENDING_VERIFICATION
}

enum class PaymentMethod {
    CREDIT_CARD,
    DEBIT_CARD,
    PAYPAL,
    BANK_TRANSFER
}
```

### Packages and Modules
```kotlin
// Packages: lowercase with dots
package com.company.userservice
package com.company.userservice.domain
package com.company.userservice.repository
package com.company.userservice.controller

// Avoid abbreviations
package com.company.userservice.configuration // Good
package com.company.userservice.config        // Avoid

// Use descriptive names
package com.company.userservice.exception     // Good
package com.company.userservice.exc          // Avoid
```

### Variables and Parameters
```kotlin
// Local variables: camelCase
fun processUser() {
    val currentUser = getCurrentUser()
    val userPermissions = getPermissions(currentUser.id)
    var attemptCount = 0
}

// Function parameters: camelCase
fun createUser(
    userName: String,
    emailAddress: String,
    isActive: Boolean = true,
    createdBy: Long
): User

// Generic type parameters: Single uppercase letter
class Repository<T>
class ApiResponse<T, E>
fun <T> processItems(items: List<T>): List<T>
```

### Files and Directories
```kotlin
// File names: PascalCase matching main class
UserService.kt          // contains class UserService
UserRepository.kt       // contains interface UserRepository
UserControllerTest.kt   // contains class UserControllerTest

// Extension files: descriptive + Extensions
StringExtensions.kt     // String extension functions
CollectionExtensions.kt // Collection extension functions
DateExtensions.kt       // Date utility extensions
```

### Spring Boot Specific
```kotlin
// Controllers: PascalCase + Controller suffix
@RestController
class UserController

@RestController  
class PaymentController

// Services: PascalCase + Service suffix
@Service
class UserService

@Service
class EmailService

// Repositories: PascalCase + Repository suffix
@Repository
interface UserRepository : JpaRepository<User, Long>

@Repository
interface OrderRepository : JpaRepository<Order, Long>

// Configuration classes: PascalCase + Config suffix
@Configuration
class DatabaseConfig

@Configuration
class SecurityConfig
```

### Test Classes
```kotlin
// Test classes: ClassName + Test suffix
class UserServiceTest

class UserControllerTest

class PaymentProcessorTest

// Test methods: descriptive with backticks for readability
class UserServiceTest {
    @Test
    fun `should return user when valid id provided`() { }
    
    @Test
    fun `should throw exception when user not found`() { }
    
    @Test
    fun `should validate email format correctly`() { }
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Check naming conventions with ktlint
./ktlint "src/**/*.kt" --reporter=checkstyle

# Auto-fix naming issues
./ktlint -F "src/**/*.kt"

# Generate detekt report for naming conventions
./gradlew detekt
```

## VALIDATION_CHECKLIST
- [ ] All classes use PascalCase
- [ ] All functions use camelCase  
- [ ] All properties use camelCase
- [ ] Constants use SCREAMING_SNAKE_CASE
- [ ] Packages use lowercase
- [ ] Boolean properties use is/has/can prefix
- [ ] Test methods use descriptive names
- [ ] File names match main class names
- [ ] No abbreviations in names