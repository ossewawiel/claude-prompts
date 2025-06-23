# Kotlin Coding Standards - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Code Formatting
- **Formatter**: ktlint 0.50+
- **Line Length**: 120 characters
- **Indentation**: 4 spaces (no tabs)

### File Organization
```kotlin
// File header (optional)
package com.company.module

// Imports (grouped and sorted)
import android.content.*
import java.util.*
import kotlin.collections.*

// Class declaration
class MyClass {
    // Constants
    companion object {
        private const val MAX_SIZE = 100
    }
    
    // Properties
    private val privateProperty = "value"
    val publicProperty: String get() = privateProperty
    
    // Functions
    fun publicFunction() { }
    private fun privateFunction() { }
}
```

## IMPLEMENTATION STRATEGY

### Naming Conventions
- **Classes**: PascalCase (`UserService`, `DatabaseManager`)
- **Functions**: camelCase (`getUserById`, `validateInput`)
- **Properties**: camelCase (`userName`, `isValid`)
- **Constants**: SCREAMING_SNAKE_CASE (`MAX_RETRY_COUNT`)
- **Packages**: lowercase with dots (`com.company.feature`)

### Function Design
```kotlin
// Good: Short, descriptive functions
fun calculateTotalPrice(items: List<Item>, taxRate: Double): BigDecimal {
    return items.sumOf { it.price } * (1 + taxRate)
}

// Use expression body for simple functions
fun isValidEmail(email: String): Boolean = email.contains("@")

// Use default parameters instead of overloads
fun createUser(name: String, age: Int = 18, isActive: Boolean = true): User
```

### Null Safety
```kotlin
// Prefer safe calls over explicit null checks
val length = text?.length ?: 0

// Use let for null-safe operations
user?.let { processUser(it) }

// Avoid !! unless absolutely certain
val result = getData()!! // Only if you're 100% sure it's not null
```

### Data Classes
```kotlin
// Use data classes for DTOs and simple data holders
data class User(
    val id: Long,
    val name: String,
    val email: String,
    val createdAt: LocalDateTime = LocalDateTime.now()
)
```

### Testing Standards
```kotlin
// MANDATORY: Always use JUnit 5 (Jupiter) for testing
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Assertions.assertFalse
import org.assertj.core.api.Assertions.assertThat
import io.mockk.mockk
import io.mockk.every

// NEVER use kotlin.test - always JUnit 5
class UserServiceTest {
    
    @Test
    fun `should create user with valid data`() {
        // Given
        val userService = UserService()
        val userData = UserData("John", "john@example.com")
        
        // When
        val result = userService.createUser(userData)
        
        // Then - Use JUnit 5 + AssertJ
        assertTrue(result.isSuccess)
        assertThat(result.user.name).isEqualTo("John")
        assertThat(result.user.email).isEqualTo("john@example.com")
    }
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Install ktlint
curl -sSLO https://github.com/pinterest/ktlint/releases/latest/download/ktlint
chmod a+x ktlint

# Format code
./ktlint -F "src/**/*.kt"

# Check code style
./ktlint "src/**/*.kt"
```

## VALIDATION_CHECKLIST
- [ ] All classes follow PascalCase naming
- [ ] All functions follow camelCase naming
- [ ] No lines exceed 120 characters
- [ ] Null safety practices applied
- [ ] ktlint passes without errors
- [ ] Import statements are organized and sorted
- [ ] Tests use JUnit 5 (Jupiter) - never kotlin.test
- [ ] Test assertions use JUnit 5 + AssertJ
- [ ] Test imports use org.junit.jupiter.api.*