# Java Coding Standards - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Code Formatting
- **Formatter**: Google Java Format or Checkstyle
- **Line Length**: 120 characters
- **Indentation**: 4 spaces (no tabs)
- **Java Version**: 17+ (LTS)

### File Organization
```java
// File header (optional)
package com.company.module;

// Imports (grouped and sorted)
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.company.domain.User;

/**
 * Service for managing user operations.
 */
@Service
public class UserService {
    
    // Constants
    private static final int MAX_RETRY_COUNT = 3;
    private static final String DEFAULT_ROLE = "USER";
    
    // Fields
    private final UserRepository userRepository;
    
    // Constructor
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
    
    // Methods
    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }
}
```

## IMPLEMENTATION STRATEGY

### Naming Conventions
- **Classes**: PascalCase (`UserService`, `DatabaseManager`)
- **Methods**: camelCase (`getUserById`, `validateInput`)
- **Variables**: camelCase (`userName`, `isValid`)
- **Constants**: SCREAMING_SNAKE_CASE (`MAX_RETRY_COUNT`)
- **Packages**: lowercase with dots (`com.company.feature`)

### Method Design
```java
// Good: Short, descriptive methods
public BigDecimal calculateTotalPrice(List<Item> items, double taxRate) {
    return items.stream()
        .map(Item::getPrice)
        .reduce(BigDecimal.ZERO, BigDecimal::add)
        .multiply(BigDecimal.valueOf(1 + taxRate));
}

// Use Optional for nullable returns
public Optional<User> findUserByEmail(String email) {
    return userRepository.findByEmail(email);
}

// Prefer immutable objects
public record UserDto(Long id, String name, String email) {}
```

### Exception Handling
```java
// Specific exception types
public void validateUser(User user) throws ValidationException {
    if (user.getName() == null || user.getName().trim().isEmpty()) {
        throw new ValidationException("User name cannot be empty");
    }
}

// Use try-with-resources for resource management
try (FileInputStream input = new FileInputStream(file)) {
    // Process file
} catch (IOException e) {
    log.error("Failed to process file: {}", file.getName(), e);
    throw new ProcessingException("File processing failed", e);
}
```

### Spring Boot Specific
```java
// Use constructor injection
@Service
public class UserService {
    private final UserRepository userRepository;
    
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }
}

// Use @Slf4j for logging
@Slf4j
@RestController
public class UserController {
    
    @GetMapping("/users/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
        log.info("Fetching user with id: {}", id);
        // Implementation
    }
}
```

### Testing Standards
```java
// MANDATORY: Always use JUnit 5 (Jupiter) for testing
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Assertions.*;
import org.assertj.core.api.Assertions.assertThat;
import org.mockito.Mock;
import org.mockito.MockitoExtension;
import org.junit.jupiter.api.extension.ExtendWith;

// NEVER use JUnit 4 - always JUnit 5
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    private UserService userService;
    
    @BeforeEach
    void setUp() {
        userService = new UserService(userRepository);
    }
    
    @Test
    void shouldCreateUserWithValidData() {
        // Given
        CreateUserRequest request = new CreateUserRequest("john@example.com", "John Doe");
        User expectedUser = new User("john@example.com", "John Doe");
        
        when(userRepository.save(any(User.class))).thenReturn(expectedUser);
        
        // When
        User result = userService.createUser(request);
        
        // Then - Use JUnit 5 + AssertJ
        assertTrue(result != null);
        assertThat(result.getEmail()).isEqualTo("john@example.com");
        assertThat(result.getName()).isEqualTo("John Doe");
    }
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Format code with Google Java Format
java -jar google-java-format-1.17.0-all-deps.jar --replace **/*.java

# Run Checkstyle
mvn checkstyle:check

# Run SpotBugs
mvn spotbugs:check
```

## VALIDATION_CHECKLIST
- [ ] All classes follow PascalCase naming
- [ ] All methods follow camelCase naming
- [ ] No lines exceed 120 characters
- [ ] Constructor injection used in Spring components
- [ ] Optional used for nullable returns
- [ ] Proper exception handling implemented
- [ ] Checkstyle passes without errors
- [ ] Tests use JUnit 5 (Jupiter) - never JUnit 4
- [ ] Test assertions use JUnit 5 + AssertJ
- [ ] Test imports use org.junit.jupiter.api.*