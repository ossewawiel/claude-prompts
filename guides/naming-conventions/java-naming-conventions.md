# Java Naming Conventions - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Classes and Interfaces
```java
// Classes: PascalCase
public class UserService
public class DatabaseManager
public class PaymentProcessor

// Interfaces: PascalCase (no 'I' prefix)
public interface UserRepository
public interface PaymentGateway
public interface NotificationService

// Abstract classes: PascalCase
public abstract class BaseEntity
public abstract class AbstractValidator

// Records: PascalCase
public record User(Long id, String name, String email) {}
public record ApiResponse<T>(T data, boolean success) {}
```

### Methods and Variables
```java
// Methods: camelCase
public User getUserById(Long id) { }
public boolean validateEmailAddress(String email) { }
public BigDecimal calculateTotalPrice(List<Item> items) { }

// Variables: camelCase
private String userName;
private boolean isActive;
private LocalDateTime createdAt;
private LocalDateTime lastLoginTime;

// Boolean variables: use 'is' or 'has' prefix
private boolean isValid;
private boolean hasPermission;
private boolean canEdit;
```

## IMPLEMENTATION STRATEGY

### Constants and Enums
```java
// Constants: SCREAMING_SNAKE_CASE
public static final int MAX_RETRY_COUNT = 3;
public static final int DEFAULT_TIMEOUT_SECONDS = 30;
public static final String API_BASE_URL = "https://api.example.com";

// Class constants
public class UserService {
    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int MAX_USERNAME_LENGTH = 50;
}

// Enums: PascalCase for enum class, SCREAMING_SNAKE_CASE for values
public enum UserStatus {
    ACTIVE,
    INACTIVE,
    SUSPENDED,
    PENDING_VERIFICATION
}

public enum PaymentMethod {
    CREDIT_CARD,
    DEBIT_CARD,
    PAYPAL,
    BANK_TRANSFER
}
```

### Packages
```java
// Packages: lowercase with dots
package com.company.userservice;
package com.company.userservice.domain;
package com.company.userservice.repository;
package com.company.userservice.controller;

// Avoid abbreviations
package com.company.userservice.configuration; // Good
package com.company.userservice.config;        // Avoid

// Use descriptive names
package com.company.userservice.exception;     // Good
package com.company.userservice.exc;          // Avoid
```

### Variables and Parameters
```java
// Local variables: camelCase
public void processUser() {
    User currentUser = getCurrentUser();
    List<Permission> userPermissions = getPermissions(currentUser.getId());
    int attemptCount = 0;
}

// Method parameters: camelCase
public User createUser(
    String userName,
    String emailAddress,
    boolean isActive,
    Long createdBy
) {
    // Implementation
}

// Generic type parameters: Single uppercase letter
public class Repository<T> { }
public class ApiResponse<T, E> { }
public <T> List<T> processItems(List<T> items) { }
```

### Files and Directories
```java
// File names: PascalCase matching public class
UserService.java          // contains public class UserService
UserRepository.java       // contains public interface UserRepository
UserControllerTest.java   // contains public class UserControllerTest

// Utility classes: descriptive + Utils suffix
StringUtils.java          // String utility methods
DateUtils.java           // Date utility methods
ValidationUtils.java     // Validation utility methods
```

### Spring Boot Specific
```java
// Controllers: PascalCase + Controller suffix
@RestController
public class UserController { }

@RestController  
public class PaymentController { }

// Services: PascalCase + Service suffix
@Service
public class UserService { }

@Service
public class EmailService { }

// Repositories: PascalCase + Repository suffix
@Repository
public interface UserRepository extends JpaRepository<User, Long> { }

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> { }

// Configuration classes: PascalCase + Configuration suffix
@Configuration
public class DatabaseConfiguration { }

@Configuration
public class SecurityConfiguration { }

// DTOs: PascalCase + Dto suffix
public class UserDto {
    private Long id;
    private String name;
    private String email;
}

public record UserCreateDto(String name, String email) { }
```

### Test Classes
```java
// Test classes: ClassName + Test suffix
public class UserServiceTest { }
public class UserControllerTest { }
public class PaymentProcessorTest { }

// Test methods: descriptive camelCase
public class UserServiceTest {
    @Test
    public void shouldReturnUserWhenValidIdProvided() { }
    
    @Test
    public void shouldThrowExceptionWhenUserNotFound() { }
    
    @Test
    public void shouldValidateEmailFormatCorrectly() { }
}

// Test data builders: ClassName + Builder suffix
public class UserTestDataBuilder {
    private String name = "John Doe";
    private String email = "john@example.com";
    
    public UserTestDataBuilder withName(String name) {
        this.name = name;
        return this;
    }
    
    public User build() {
        return new User(name, email);
    }
}
```

### Exception Classes
```java
// Custom exceptions: descriptive + Exception suffix
public class UserNotFoundException extends RuntimeException { }
public class InvalidEmailException extends RuntimeException { }
public class PaymentProcessingException extends RuntimeException { }

// Validation exceptions: ValidationException suffix
public class UserValidationException extends RuntimeException { }
public class PaymentValidationException extends RuntimeException { }
```

## CLAUDE_CODE_COMMANDS

```bash
# Check naming conventions with Checkstyle
mvn checkstyle:check

# Generate SpotBugs report
mvn spotbugs:check

# Run PMD analysis
mvn pmd:check
```

## VALIDATION_CHECKLIST
- [ ] All classes use PascalCase
- [ ] All methods use camelCase
- [ ] All variables use camelCase
- [ ] Constants use SCREAMING_SNAKE_CASE
- [ ] Packages use lowercase
- [ ] Boolean variables use is/has/can prefix
- [ ] Test methods use descriptive names
- [ ] File names match public class names
- [ ] No abbreviations in names
- [ ] Spring annotations follow naming patterns