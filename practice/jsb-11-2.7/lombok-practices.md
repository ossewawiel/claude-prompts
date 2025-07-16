# Lombok Integration & Best Practices

## Overview

Project Lombok is a Java library that reduces boilerplate code through annotations. This document covers setup, best practices, recommended usage patterns, and anti-patterns to avoid when using Lombok with Spring Boot 2.7.

## Setup and Configuration

### 1. Maven Dependencies

```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.24</version>
    <scope>provided</scope>
</dependency>

<!-- For annotation processing in tests -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.24</version>
    <scope>test</scope>
</dependency>
```

### 2. Gradle Dependencies

```gradle
dependencies {
    compileOnly 'org.projectlombok:lombok:1.18.24'
    annotationProcessor 'org.projectlombok:lombok:1.18.24'
    
    testCompileOnly 'org.projectlombok:lombok:1.18.24'
    testAnnotationProcessor 'org.projectlombok:lombok:1.18.24'
}
```

### 3. IDE Configuration

#### IntelliJ IDEA
1. Install Lombok plugin
2. Enable annotation processing: Settings → Build → Compiler → Annotation Processors
3. Check "Enable annotation processing"

#### VS Code
1. Install "Java Extension Pack"
2. Lombok support is included automatically

## Core Lombok Annotations

### 1. @Data - Comprehensive Class Generation

```java
// Basic DTO with @Data
@Data
public class UserDto {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private LocalDateTime createdAt;
    
    // Lombok generates:
    // - All getters and setters
    // - toString() method
    // - equals() and hashCode()
    // - Constructor for final fields (if any)
}

// Better approach for DTOs - use @Value for immutability
@Value
@Builder
public class UserResponse {
    Long id;
    String firstName;
    String lastName;
    String email;
    LocalDateTime createdAt;
    
    // Generates immutable class with:
    // - All fields final
    // - Only getters (no setters)
    // - All-args constructor
    // - Builder pattern
    // - toString(), equals(), hashCode()
}
```

### 2. Constructor Annotations

```java
@Service
@RequiredArgsConstructor // Generates constructor for final fields
@Slf4j
public class UserService {
    
    // Final fields - will be included in constructor
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final UserMapper userMapper;
    
    // Non-final fields - not included in constructor
    private final Map<String, Object> cache = new ConcurrentHashMap<>();
    
    public UserResponse createUser(CreateUserRequest request) {
        log.info("Creating user with email: {}", request.getEmail());
        
        User user = userMapper.toEntity(request);
        User savedUser = userRepository.save(user);
        
        // Send welcome email asynchronously
        emailService.sendWelcomeEmail(savedUser.getEmail());
        
        return userMapper.toResponse(savedUser);
    }
}
```

### 3. Logging Annotations

```java
// @Slf4j - Most commonly used (SLF4J with Logback)
@Service
@Slf4j
@RequiredArgsConstructor
public class OrderService {
    
    private final OrderRepository orderRepository;
    private final PaymentService paymentService;
    
    public OrderResponse processOrder(CreateOrderRequest request) {
        log.info("Processing order for user: {}", request.getUserId());
        log.debug("Order details: {}", request);
        
        try {
            Order order = createOrder(request);
            PaymentResult payment = paymentService.processPayment(order);
            
            if (payment.isSuccessful()) {
                log.info("Order {} processed successfully", order.getId());
                return orderMapper.toResponse(order);
            } else {
                log.warn("Payment failed for order: {}", order.getId());
                throw new PaymentFailedException("Payment processing failed");
            }
        } catch (Exception e) {
            log.error("Error processing order for user {}: {}", request.getUserId(), e.getMessage(), e);
            throw new OrderProcessingException("Failed to process order", e);
        }
    }
}

// Other logging annotations (less common)
@Service
@Log4j2  // For Log4j2
public class AuditService { }

@Service
@CommonsLog  // For Apache Commons Logging
public class LegacyService { }
```

## Best Practices for Service Layer

### 1. Immutable DTOs and Value Objects

```java
// Request DTOs - Use @Value for immutability
@Value
@Builder
@JsonDeserialize(builder = CreateUserRequest.CreateUserRequestBuilder.class)
public class CreateUserRequest {
    @NotBlank
    String firstName;
    
    @NotBlank
    String lastName;
    
    @Email
    @NotBlank
    String email;
    
    @NotBlank
    String password;
    
    @Valid
    Address address;
    
    // Builder class for Jackson deserialization
    @JsonPOJOBuilder(withPrefix = "")
    public static class CreateUserRequestBuilder { }
}

// Response DTOs - Always immutable
@Value
@Builder
public class UserResponse {
    Long id;
    String firstName;
    String lastName;
    String email;
    String status;
    LocalDateTime createdAt;
    LocalDateTime lastLoginAt;
    
    // Custom getter with business logic
    public String getFullName() {
        return firstName + " " + lastName;
    }
    
    @JsonIgnore
    public boolean isActive() {
        return "ACTIVE".equals(status);
    }
}
```

### 2. Service Implementation with Lombok

```java
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final UserMapper userMapper;
    
    @Override
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        log.info("Creating new user with email: {}", request.getEmail());
        
        // Validate unique email
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException("User with email already exists: " + request.getEmail());
        }
        
        // Create user entity
        User user = User.builder()
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .email(request.getEmail())
            .password(passwordEncoder.encode(request.getPassword()))
            .status(UserStatus.ACTIVE)
            .createdAt(LocalDateTime.now())
            .build();
            
        User savedUser = userRepository.save(user);
        
        // Send welcome email asynchronously
        emailService.sendWelcomeEmailAsync(savedUser.getEmail(), savedUser.getFirstName());
        
        log.info("User created successfully with ID: {}", savedUser.getId());
        return userMapper.toResponse(savedUser);
    }
    
    @Override
    public Optional<UserResponse> findUserById(Long id) {
        log.debug("Finding user by ID: {}", id);
        
        return userRepository.findById(id)
            .map(userMapper::toResponse);
    }
    
    @Override
    @Transactional
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        log.info("Updating user with ID: {}", id);
        
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException("User not found with ID: " + id));
            
        // Update fields - using builder for immutability
        User updatedUser = user.toBuilder()
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .updatedAt(LocalDateTime.now())
            .build();
            
        User savedUser = userRepository.save(updatedUser);
        
        log.info("User updated successfully: {}", savedUser.getId());
        return userMapper.toResponse(savedUser);
    }
}
```

### 3. Entity Classes with Lombok

```java
@Entity
@Table(name = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;
    
    @Column(name = "first_name", nullable = false)
    private String firstName;
    
    @Column(name = "last_name", nullable = false)
    private String lastName;
    
    @Column(name = "email", nullable = false, unique = true)
    @EqualsAndHashCode.Include
    private String email;
    
    @Column(name = "password", nullable = false)
    @ToString.Exclude  // Exclude password from toString
    private String password;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private UserStatus status;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;
    
    // One-to-many relationship
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @ToString.Exclude  // Prevent lazy loading in toString
    @Builder.Default
    private List<Order> orders = new ArrayList<>();
    
    // Custom builder method
    public static UserBuilder builder() {
        return new UserBuilder()
            .status(UserStatus.ACTIVE)
            .createdAt(LocalDateTime.now());
    }
    
    // Helper method for creating a copy with updates
    public UserBuilder toBuilder() {
        return User.builder()
            .id(this.id)
            .firstName(this.firstName)
            .lastName(this.lastName)
            .email(this.email)
            .password(this.password)
            .status(this.status)
            .createdAt(this.createdAt)
            .updatedAt(LocalDateTime.now())
            .lastLoginAt(this.lastLoginAt);
    }
}
```

## Advanced Lombok Features

### 1. Custom Builder Patterns

```java
@Value
@Builder
public class SearchCriteria {
    String keyword;
    List<String> categories;
    BigDecimal minPrice;
    BigDecimal maxPrice;
    LocalDate startDate;
    LocalDate endDate;
    SortOrder sortOrder;
    
    @Builder.Default
    int page = 0;
    
    @Builder.Default
    int size = 20;
    
    @Builder.Default
    List<String> categories = new ArrayList<>();
    
    // Custom builder method
    public static SearchCriteriaBuilder forKeyword(String keyword) {
        return SearchCriteria.builder()
            .keyword(keyword)
            .sortOrder(SortOrder.RELEVANCE);
    }
    
    // Validation in builder
    public static class SearchCriteriaBuilder {
        public SearchCriteriaBuilder priceRange(BigDecimal min, BigDecimal max) {
            if (min.compareTo(max) > 0) {
                throw new IllegalArgumentException("Min price cannot be greater than max price");
            }
            this.minPrice = min;
            this.maxPrice = max;
            return this;
        }
        
        public SearchCriteriaBuilder dateRange(LocalDate start, LocalDate end) {
            if (start.isAfter(end)) {
                throw new IllegalArgumentException("Start date cannot be after end date");
            }
            this.startDate = start;
            this.endDate = end;
            return this;
        }
    }
}
```

### 2. Delegation Pattern

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class CachingUserService implements UserService {
    
    @Delegate
    private final UserService delegate;  // Actual implementation
    
    private final CacheManager cacheManager;
    
    // Override only methods that need caching
    @Override
    @Cacheable(value = "users", key = "#id")
    public Optional<UserResponse> findUserById(Long id) {
        log.debug("Cache miss for user ID: {}", id);
        return delegate.findUserById(id);
    }
    
    @Override
    @CacheEvict(value = "users", key = "#result.id")
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        return delegate.updateUser(id, request);
    }
    
    // All other methods are automatically delegated
}
```

### 3. Configuration Properties with Lombok

```java
@ConfigurationProperties(prefix = "app.notification")
@Data
@Validated
public class NotificationProperties {
    
    @NotNull
    private Email email = new Email();
    
    @NotNull
    private Sms sms = new Sms();
    
    @Min(1)
    @Max(10)
    private int maxRetryAttempts = 3;
    
    @NotNull
    private Duration retryDelay = Duration.ofSeconds(5);
    
    @Data
    public static class Email {
        
        @NotBlank
        private String host;
        
        @Range(min = 1, max = 65535)
        private int port = 587;
        
        @NotBlank
        private String username;
        
        @NotBlank
        private String password;
        
        private boolean tlsEnabled = true;
        
        @Builder.Default
        private Duration timeout = Duration.ofSeconds(30);
    }
    
    @Data
    public static class Sms {
        
        @NotBlank
        private String apiKey;
        
        @NotBlank
        private String apiUrl;
        
        @Builder.Default
        private boolean enabled = false;
        
        @Builder.Default
        private Duration timeout = Duration.ofSeconds(10);
    }
}
```

## Anti-Patterns and Pitfalls

### 1. JPA Entity Anti-Patterns

```java
// ❌ WRONG: Using @Data with JPA entities
@Entity
@Data  // DON'T DO THIS - can cause issues with JPA
public class BadUser {
    @Id
    private Long id;
    
    @OneToMany(mappedBy = "user")
    private List<Order> orders;  // Can cause N+1 queries in toString()
}

// ✅ CORRECT: Explicit annotations for JPA entities
@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = {"orders"})  // Exclude collections from toString
public class GoodUser {
    
    @Id
    @EqualsAndHashCode.Include
    private Long id;
    
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    @ToString.Exclude
    private List<Order> orders = new ArrayList<>();
}
```

### 2. Circular Reference Issues

```java
// ❌ WRONG: Can cause StackOverflowError
@Data
public class User {
    private String name;
    private List<Order> orders;
}

@Data
public class Order {
    private String number;
    private User user;  // Circular reference in toString()
}

// ✅ CORRECT: Break circular references
@Data
public class User {
    private String name;
    
    @ToString.Exclude
    private List<Order> orders;
}

@Data
public class Order {
    private String number;
    
    @ToString.Exclude
    private User user;
}
```

### 3. Builder Pattern Misuse

```java
// ❌ WRONG: Mutable builder for immutable objects
@Data
@Builder
public class BadProduct {
    private String name;
    private List<String> tags;  // Mutable list in immutable object
}

// ✅ CORRECT: Properly immutable with defensive copying
@Value
@Builder
public class GoodProduct {
    String name;
    
    @Singular  // Creates immutable list
    List<String> tags;
    
    // Or with defensive copying
    public List<String> getTags() {
        return tags == null ? List.of() : List.copyOf(tags);
    }
}
```

## Performance Considerations

### 1. Lazy Initialization

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class ReportService {
    
    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    
    // Expensive computation - use lazy initialization
    @Getter(lazy = true)
    private final Map<String, Object> expensiveConfig = computeExpensiveConfig();
    
    private Map<String, Object> computeExpensiveConfig() {
        log.info("Computing expensive configuration...");
        // Expensive computation here
        return Map.of("key", "value");
    }
    
    public ReportData generateReport() {
        // Configuration is computed only when first accessed
        Map<String, Object> config = getExpensiveConfig();
        // Use config for report generation
        return new ReportData();
    }
}
```

### 2. Efficient String Operations

```java
@Value
@Builder
public class LogMessage {
    String level;
    String message;
    String className;
    String methodName;
    LocalDateTime timestamp;
    
    // Use @ToString for efficient string representation
    // instead of manual concatenation
    @Override
    public String toString() {
        return String.format("[%s] %s - %s.%s(): %s", 
            level, timestamp, className, methodName, message);
    }
}
```

## IDE Integration and Debugging

### 1. Debugging Generated Code

```java
@Service
@Slf4j
@RequiredArgsConstructor
public class DebuggableService {
    
    private final SomeRepository repository;
    
    // When debugging, you can step into Lombok-generated methods
    // Set breakpoints in the actual business logic methods
    public void processData(String input) {
        log.debug("Processing input: {}", input);  // Can set breakpoint here
        
        // Lombok-generated constructor and field access work normally in debugger
        var result = repository.findByName(input);
        
        if (result.isPresent()) {
            log.info("Found result: {}", result.get());  // toString() generated by Lombok
        }
    }
}
```

### 2. Compilation and Build Integration

```xml
<!-- Maven Compiler Plugin Configuration -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.8.1</version>
    <configuration>
        <source>11</source>
        <target>11</target>
        <annotationProcessorPaths>
            <path>
                <groupId>org.projectlombok</groupId>
                <artifactId>lombok</artifactId>
                <version>1.18.24</version>
            </path>
            <!-- Other annotation processors -->
        </annotationProcessorPaths>
    </configuration>
</plugin>
```

## Summary

Lombok best practices for Spring Boot service layer:

1. **Use `@RequiredArgsConstructor`** for dependency injection
2. **Use `@Slf4j`** for consistent logging across services
3. **Use `@Value` and `@Builder`** for immutable DTOs
4. **Be careful with JPA entities** - avoid `@Data`, use explicit annotations
5. **Exclude sensitive fields** from `toString()` using `@ToString.Exclude`
6. **Handle circular references** properly in bidirectional relationships
7. **Use `@Singular`** for immutable collections in builders
8. **Leverage IDE plugins** for better development experience

Next: [Service Layer Architecture](service-architecture)