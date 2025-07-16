# Entity Dependency Issues Refactoring

## Purpose
Identify dependency and coupling problems in JPA entities that violate clean architecture principles.

## Dependency Issue Patterns

### CRITICAL Issues

#### 1. Spring Framework Dependencies in Entity
**Pattern**: Entities with Spring annotations beyond JPA
```java
// SMELL: Spring dependencies in entity
@Entity
@Component
@Scope("prototype")
public class User {
    @Autowired
    private UserService userService;
    
    @Value("${app.default.status}")
    private String defaultStatus;
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Remove Spring dependencies from entity
// Fix: Remove @Component, @Autowired, @Value annotations
// Reason: Entities should be POJOs without framework dependencies
```

#### 2. Static Service Access in Entity
**Pattern**: Entities accessing services through static methods
```java
// SMELL: Static service access
@Entity
public class Order {
    public void processPayment() {
        PaymentService paymentService = ApplicationContext.getBean(PaymentService.class);
        paymentService.processPayment(this);
    }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Remove static service access from entity
// Fix: Move service calls to service layer
// Reason: Entities should not access Spring context or services
```

#### 3. Circular Dependencies Between Entities
**Pattern**: Entities that reference each other in problematic ways
```java
// SMELL: Circular entity dependencies
@Entity
public class User {
    @OneToOne
    private Profile profile;
    
    public String getDisplayName() {
        return profile.getUser().getName(); // Circular reference
    }
}

@Entity
public class Profile {
    @OneToOne
    private User user;
    
    public boolean isComplete() {
        return user.getProfile().getCompletionStatus(); // Circular reference
    }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Break circular dependencies between entities
// Fix: Avoid accessing back-references in entity methods
// Reason: Circular dependencies can cause infinite loops and stack overflow
```

### HIGH Priority Issues

#### 4. Utility Class Dependencies
**Pattern**: Entities depending on utility classes inappropriately
```java
// SMELL: Inappropriate utility dependencies
@Entity
public class User {
    public boolean isValidEmail() {
        return EmailValidator.isValid(this.email) && 
               SecurityUtils.isSafeEmail(this.email) &&
               CompanyPolicyUtils.isAllowedDomain(this.email);
    }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Move utility class dependencies to service layer
// Fix: Create UserValidationService with validation logic
// Reason: Reduces entity coupling and improves testability
```

#### 5. Configuration Class Dependencies
**Pattern**: Entities accessing configuration directly
```java
// SMELL: Configuration access in entity
@Entity
public class Product {
    public BigDecimal getPriceWithTax() {
        TaxConfiguration config = ConfigurationManager.getTaxConfig();
        return price.multiply(config.getTaxRate());
    }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Remove configuration access from entity
// Fix: Pass configuration values through service layer
// Reason: Entities should not depend on configuration management
```

#### 6. Logger Dependencies
**Pattern**: Entities with logging dependencies
```java
// SMELL: Logging in entity
@Entity
public class User {
    private static final Logger logger = LoggerFactory.getLogger(User.class);
    
    public void activate() {
        logger.info("Activating user: {}", this.email);
        this.status = UserStatus.ACTIVE;
    }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Remove logging from entity
// Fix: Move logging to service layer
// Reason: Entities should not handle cross-cutting concerns like logging
```

### MEDIUM Priority Issues

#### 7. Exception Handling Dependencies
**Pattern**: Entities throwing custom exceptions
```java
// SMELL: Custom exception handling in entity
@Entity
public class Order {
    public void cancel() {
        if (status == OrderStatus.SHIPPED) {
            throw new OrderCannotBeCancelledException("Order already shipped");
        }
        status = OrderStatus.CANCELLED;
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Move exception handling to service layer
// Fix: Return boolean or status enum, handle exceptions in service
// Reason: Exception handling logic belongs in service layer
```

#### 8. Date/Time Utility Dependencies
**Pattern**: Entities using date/time utilities unnecessarily
```java
// SMELL: Date utility dependencies
@Entity
public class Event {
    public boolean isUpcoming() {
        return DateUtils.isAfter(eventDate, DateUtils.now()) &&
               DateUtils.isBefore(eventDate, DateUtils.addDays(DateUtils.now(), 7));
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Simplify date/time operations in entity
// Fix: Use LocalDateTime.now() directly or move to service
// Reason: Reduces unnecessary utility dependencies
```

#### 9. Validation Framework Dependencies
**Pattern**: Entities with complex validation framework usage
```java
// SMELL: Complex validation framework usage
@Entity
public class User {
    public boolean validateProfile() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        Validator validator = factory.getValidator();
        Set<ConstraintViolation<User>> violations = validator.validate(this);
        return violations.isEmpty();
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Move validation framework usage to service layer
// Fix: Use JSR-303 annotations and validate in service
// Reason: Reduces entity complexity and improves separation of concerns
```

### LOW Priority Issues

#### 10. Constant Class Dependencies
**Pattern**: Entities referencing constant classes
```java
// SMELL: Constant class dependencies
@Entity
public class User {
    public boolean isDefaultStatus() {
        return status.equals(UserConstants.DEFAULT_STATUS);
    }
}
```
**TODO Template**:
```java
// TODO: [LOW] Consider inlining constants or using enums
// Fix: Define constants locally or use enum values
// Reason: Reduces external dependencies for simple constants
```

## Dependency Resolution Strategies

### 1. Dependency Injection Removal
```java
// BEFORE: Service injection in entity
@Entity
public class Order {
    @Autowired
    private PaymentService paymentService;
    
    public void processPayment() {
        paymentService.process(this);
    }
}

// AFTER: Service handles entity
@Service
public class OrderService {
    private final PaymentService paymentService;
    
    public void processPayment(Order order) {
        paymentService.process(order);
    }
}
```

### 2. Circular Dependency Breaking
```java
// BEFORE: Circular references
@Entity
public class User {
    @OneToOne
    private Profile profile;
    
    public String getDisplayName() {
        return profile.getUser().getName();
    }
}

// AFTER: Direct access only
@Entity
public class User {
    @OneToOne
    private Profile profile;
    
    public String getDisplayName() {
        return name; // Use own fields only
    }
}
```

### 3. Utility Dependency Extraction
```java
// BEFORE: Utility dependencies in entity
@Entity
public class Product {
    public boolean isValidPrice() {
        return PriceValidator.isValid(price) && 
               CurrencyUtils.isSupported(currency);
    }
}

// AFTER: Validation in service
@Service
public class ProductService {
    private final PriceValidator priceValidator;
    private final CurrencyUtils currencyUtils;
    
    public boolean isValidPrice(Product product) {
        return priceValidator.isValid(product.getPrice()) && 
               currencyUtils.isSupported(product.getCurrency());
    }
}
```

## Clean Entity Design Principles

### Allowed Dependencies
- JPA annotations (`@Entity`, `@Column`, etc.)
- JSR-303 validation annotations (`@NotNull`, `@Size`, etc.)
- Java standard library (Collections, time APIs, etc.)
- Lombok annotations for code generation
- Domain-specific value objects and enums

### Forbidden Dependencies
- Spring Framework classes (except JPA)
- Service layer classes
- Repository layer classes
- Configuration classes
- Utility classes with static methods
- Logging frameworks
- External libraries for business logic

### Dependency Direction Rules
```
Controller → Service → Repository → Entity
     ↑                              ↓
    DTO ←─────── Mapper ←─────── Entity
```

## Detection Patterns for Claude Code

### Import Analysis
- Spring imports beyond JPA
- Service/Repository imports
- Static utility imports
- Configuration imports

### Annotation Analysis
- `@Autowired`, `@Value`, `@Component`
- `@Service`, `@Repository`
- Custom validation annotations

### Method Analysis
- Static method calls to utility classes
- Service method calls
- Configuration access
- Exception throwing patterns

### Field Analysis
- Non-JPA annotated fields
- Service/Repository fields
- Logger fields
- Configuration fields

## Refactoring Priority Matrix

| Dependency Type | Risk Level | Refactoring Effort | Priority |
|----------------|------------|-------------------|----------|
| Spring Services | CRITICAL | Medium | 1 |
| Static Service Access | CRITICAL | Low | 2 |
| Circular References | CRITICAL | High | 3 |
| Utility Classes | HIGH | Low | 4 |
| Configuration | HIGH | Medium | 5 |
| Logging | HIGH | Low | 6 |
| Exception Handling | MEDIUM | Medium | 7 |
| Date Utilities | MEDIUM | Low | 8 |
| Validation Framework | MEDIUM | High | 9 |
| Constants | LOW | Low | 10 |

## Best Practices for Entity Dependencies

### Keep Entities Simple
- Entities should be data holders with minimal behavior
- Avoid complex business logic in entities
- Use simple validation and state checking only

### Use Proper Layering
- Services orchestrate entity operations
- Repositories handle entity persistence
- Controllers handle HTTP concerns

### Favor Composition Over Inheritance
- Use value objects for complex data types
- Prefer aggregation over deep inheritance hierarchies
- Keep entity hierarchies shallow and focused