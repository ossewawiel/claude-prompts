# Project Structure & Naming Conventions

## Overview

Proper project structure and consistent naming conventions are crucial for maintainable Spring Boot applications. This document outlines recommended approaches for organizing code and naming conventions based on current best practices.

## Recommended Project Structure

### Option 1: Layer-Based Structure

```
src/main/java/com/company/project/
├── Application.java
├── config/
│   ├── DatabaseConfig.java
│   ├── SecurityConfig.java
│   └── WebConfig.java
├── controller/
│   ├── UserController.java
│   ├── ProductController.java
│   └── OrderController.java
├── service/
│   ├── UserService.java
│   ├── ProductService.java
│   ├── OrderService.java
│   └── impl/
│       ├── UserServiceImpl.java
│       ├── ProductServiceImpl.java
│       └── OrderServiceImpl.java
├── repository/
│   ├── UserRepository.java
│   ├── ProductRepository.java
│   └── OrderRepository.java
├── entity/
│   ├── User.java
│   ├── Product.java
│   └── Order.java
├── dto/
│   ├── request/
│   │   ├── CreateUserRequest.java
│   │   └── UpdateUserRequest.java
│   └── response/
│       ├── UserResponse.java
│       └── UserListResponse.java
├── mapper/
│   ├── UserMapper.java
│   └── ProductMapper.java
├── exception/
│   ├── BusinessException.java
│   ├── UserNotFoundException.java
│   └── handler/
│       └── GlobalExceptionHandler.java
└── util/
    ├── DateUtil.java
    └── ValidationUtil.java
```

### Option 2: Feature-Based Structure (Recommended for Larger Projects)

```
src/main/java/com/company/project/
├── Application.java
├── config/
│   └── [shared configurations]
├── shared/
│   ├── exception/
│   ├── util/
│   └── dto/
├── user/
│   ├── UserController.java
│   ├── UserService.java
│   ├── UserServiceImpl.java
│   ├── UserRepository.java
│   ├── User.java (entity)
│   └── dto/
│       ├── UserRequest.java
│       └── UserResponse.java
├── product/
│   ├── ProductController.java
│   ├── ProductService.java
│   ├── ProductServiceImpl.java
│   ├── ProductRepository.java
│   ├── Product.java
│   └── dto/
└── order/
    ├── OrderController.java
    ├── OrderService.java
    ├── OrderServiceImpl.java
    ├── OrderRepository.java
    ├── Order.java
    └── dto/
```

## Package Naming Conventions

### 1. Base Package Structure

```java
// Use reverse domain naming
com.company.project
com.example.ecommerce
com.acme.inventory
```

### 2. Subpackage Organization

```java
// Good examples
com.company.project.user.service
com.company.project.order.controller
com.company.project.shared.exception

// Avoid generic technical terms as the primary package
com.company.project.service.user  // Less preferred
com.company.project.controller.order  // Less preferred
```

## Class Naming Conventions

### 1. Service Layer Classes

```java
// Interface naming (noun or capability-based)
public interface UserService {
    // Business capability focused naming
}

public interface PaymentProcessor {
    // Capability/behavior focused naming
}

// Implementation naming
@Service
public class UserServiceImpl implements UserService {
    // Standard implementation suffix
}

@Service
public class DatabaseUserService implements UserService {
    // Implementation-specific naming
}

@Service
public class CachedUserService implements UserService {
    // Behavior-specific implementation
}
```

### 2. Entity and DTO Naming

```java
// Entity classes - singular nouns
@Entity
@Table(name = "users")
public class User {
    // Entity represents a single domain object
}

// DTO classes - descriptive and purpose-driven
@Data
public class UserRegistrationRequest {
    // Clear purpose and direction
}

@Data
public class UserProfileResponse {
    // Indicates response data
}

@Data
public class UserSearchCriteria {
    // Indicates search/filter parameters
}
```

### 3. Repository Naming

```java
// Repository interfaces
public interface UserRepository extends JpaRepository<User, Long> {
    // Standard repository suffix
}

// Custom repository implementations
@Repository
public class UserRepositoryImpl implements UserRepositoryCustom {
    // Implementation suffix for custom repositories
}
```

## Method Naming Conventions

### 1. Service Method Naming

```java
@Service
public class UserService {
    
    // CRUD operations - clear and consistent
    public User createUser(CreateUserRequest request) { }
    public Optional<User> findUserById(Long id) { }
    public User updateUser(Long id, UpdateUserRequest request) { }
    public void deleteUser(Long id) { }
    
    // Business operations - verb-based, intention-revealing
    public void activateUser(Long userId) { }
    public void deactivateUser(Long userId) { }
    public boolean isUserEligibleForPromotion(Long userId) { }
    public List<User> findActiveUsersCreatedAfter(LocalDate date) { }
    
    // Query methods - descriptive of what they return
    public List<User> findUsersByRole(String role) { }
    public long countActiveUsers() { }
    public boolean existsUserWithEmail(String email) { }
    
    // Processing methods - action-oriented
    public UserReport generateUserReport(ReportCriteria criteria) { }
    public void processUserRegistration(RegistrationData data) { }
    public ValidationResult validateUserData(UserData data) { }
}
```

### 2. Repository Method Naming

```java
public interface UserRepository extends JpaRepository<User, Long> {
    
    // Spring Data query methods - follow naming conventions
    Optional<User> findByEmail(String email);
    List<User> findByActiveTrue();
    List<User> findByRoleAndActiveTrue(String role);
    boolean existsByEmail(String email);
    long countByActive(boolean active);
    
    // Custom query methods with @Query
    @Query("SELECT u FROM User u WHERE u.lastLoginDate < :date")
    List<User> findInactiveUsersSince(@Param("date") LocalDate date);
}
```

## Variable and Field Naming

### 1. Local Variables

```java
@Service
public class OrderService {
    
    public OrderSummary processOrder(OrderRequest request) {
        // Descriptive variable names
        List<OrderItem> validItems = validateOrderItems(request.getItems());
        BigDecimal totalAmount = calculateTotalAmount(validItems);
        BigDecimal discountAmount = calculateDiscount(totalAmount, request.getCouponCode());
        BigDecimal finalAmount = totalAmount.subtract(discountAmount);
        
        // Use 'var' for complex generic types
        var orderItemsByCategory = validItems.stream()
            .collect(Collectors.groupingBy(OrderItem::getCategory));
            
        return OrderSummary.builder()
            .totalAmount(finalAmount)
            .itemCount(validItems.size())
            .build();
    }
}
```

### 2. Fields and Constants

```java
@Service
@Slf4j
public class NotificationService {
    
    // Constants - UPPER_CASE with underscores
    private static final int MAX_RETRY_ATTEMPTS = 3;
    private static final Duration DEFAULT_TIMEOUT = Duration.ofSeconds(30);
    private static final String EMAIL_TEMPLATE_PATH = "/templates/email/";
    
    // Final fields - camelCase
    private final EmailSender emailSender;
    private final TemplateEngine templateEngine;
    private final NotificationRepository notificationRepository;
    
    // Regular fields - camelCase (avoid if possible, prefer constructor injection)
    private final Map<String, Template> templateCache = new ConcurrentHashMap<>();
}
```

## Bean Naming Conventions

### 1. Component Naming

```java
// Default bean names (automatically generated)
@Service // Bean name: "userService"
public class UserService { }

@Repository // Bean name: "userRepository"
public class UserRepository { }

@Controller // Bean name: "userController"
public class UserController { }

// Custom bean names
@Service("customUserService")
public class UserService { }

@Configuration
public class ServiceConfig {
    
    @Bean("primaryUserService")
    public UserService primaryUserService() {
        return new DatabaseUserService();
    }
    
    @Bean("cachingUserService")
    public UserService cachingUserService() {
        return new CachedUserService();
    }
}
```

### 2. Qualifier Naming

```java
@Service
@Qualifier("database")
public class DatabaseUserService implements UserService { }

@Service
@Qualifier("cached")
public class CachedUserService implements UserService { }

// Usage
@Service
public class UserManagementService {
    
    private final UserService databaseUserService;
    private final UserService cachedUserService;
    
    public UserManagementService(
            @Qualifier("database") UserService databaseUserService,
            @Qualifier("cached") UserService cachedUserService) {
        this.databaseUserService = databaseUserService;
        this.cachedUserService = cachedUserService;
    }
}
```

## Configuration and Property Naming

### 1. Application Properties

```yaml
# application.yml - use kebab-case
spring:
  application:
    name: user-management-service
  datasource:
    driver-class-name: org.postgresql.Driver
    
# Custom properties - group related settings
app:
  security:
    jwt-secret-key: ${JWT_SECRET:default-secret}
    token-expiration-hours: 24
  notification:
    email-enabled: true
    sms-enabled: false
    max-retry-attempts: 3
```

### 2. Configuration Classes

```java
@ConfigurationProperties(prefix = "app.notification")
@Data
public class NotificationProperties {
    
    // Use camelCase for fields
    private boolean emailEnabled = true;
    private boolean smsEnabled = false;
    private int maxRetryAttempts = 3;
    private Duration retryDelay = Duration.ofSeconds(5);
    
    // Nested configuration
    @Data
    public static class Email {
        private String smtpHost;
        private int smtpPort = 587;
        private String username;
        private String password;
    }
    
    private Email email = new Email();
}
```

## File and Resource Naming

### 1. Template and Resource Files

```
src/main/resources/
├── application.yml
├── application-dev.yml
├── application-prod.yml
├── templates/
│   ├── email/
│   │   ├── user-registration.html
│   │   ├── password-reset.html
│   │   └── order-confirmation.html
│   └── pdf/
│       └── invoice-template.html
├── static/
│   ├── css/
│   ├── js/
│   └── images/
└── db/migration/
    ├── V1__create_user_table.sql
    ├── V2__add_user_indexes.sql
    └── V3__create_order_table.sql
```

### 2. Test Class Naming

```java
// Unit tests
public class UserServiceTest { }
public class UserServiceImplTest { }

// Integration tests
@SpringBootTest
public class UserControllerIntegrationTest { }

@DataJpaTest
public class UserRepositoryIntegrationTest { }

// Test method naming - descriptive and behavior-focused
public class UserServiceTest {
    
    @Test
    void shouldCreateUserWhenValidDataProvided() { }
    
    @Test
    void shouldThrowExceptionWhenEmailAlreadyExists() { }
    
    @Test
    void shouldReturnEmptyWhenUserNotFound() { }
}
```

## Anti-Patterns to Avoid

### 1. Poor Naming Examples

```java
// Avoid these patterns:

// Generic or meaningless names
public class Manager { } // Too generic
public class Handler { } // Too generic
public class Util { } // Too generic

// Hungarian notation
public class strUserService { } // Don't use type prefixes

// Misleading names
public class UserController {
    public void saveUser() { } // Should be in service, not controller
}

// Inconsistent naming
public class UserService {
    public User getUser(Long id) { } // Inconsistent with findUser
    public User findUser(String email) { } // Should be consistent
}
```

### 2. Package Structure Anti-Patterns

```java
// Avoid putting everything in one package
com.company.project.everything

// Avoid deep nesting without purpose
com.company.project.service.impl.user.database.postgresql

// Avoid mixing layers in same package
com.company.project.user.UserController
com.company.project.user.UserEntity  // Should be separate from controller
```

## Summary

Key principles for naming and structure:

1. **Consistency** - Follow the same patterns throughout the project
2. **Clarity** - Names should clearly indicate purpose and responsibility
3. **Convention** - Follow established Java and Spring Boot conventions
4. **Context** - Package structure should reflect business domains
5. **Maintainability** - Structure should support easy navigation and understanding

Next: [Lombok Integration & Best Practices](lombok-practices)
