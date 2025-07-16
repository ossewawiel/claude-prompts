# Entity Method Extraction Refactoring

## Purpose
Identify methods that should be extracted from entities to improve separation of concerns and maintainability.

## Method Extraction Patterns

### CRITICAL Issues

#### 1. Complex Business Logic Methods
**Pattern**: Methods containing complex business rules
```java
// SMELL: Complex business logic in entity
@Entity
public class Order {
    public BigDecimal calculateTotalWithDiscounts() {
        BigDecimal total = items.stream()
            .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
            
        if (customer.isPremium()) {
            total = total.multiply(BigDecimal.valueOf(0.9));
        }
        
        if (total.compareTo(BigDecimal.valueOf(100)) > 0) {
            total = total.subtract(BigDecimal.valueOf(10));
        }
        
        return total;
    }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Extract business logic to service class
// Fix: Create OrderCalculationService with calculateTotal() method
// Reason: Business logic belongs in service layer, not entity
```

#### 2. Database Query Methods
**Pattern**: Methods performing database queries
```java
// SMELL: Database queries in entity
@Entity
public class User {
    @Transient
    @Autowired
    private OrderRepository orderRepository;
    
    public List<Order> getRecentOrders() {
        return orderRepository.findByUserIdAndCreatedAtAfter(
            this.id, LocalDateTime.now().minusDays(30));
    }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Move query methods to repository/service layer
// Fix: Create method in UserService or OrderRepository
// Reason: Entities should not perform database operations
```

#### 3. External Service Integration Methods
**Pattern**: Methods calling external services
```java
// SMELL: External service calls in entity
@Entity
public class User {
    public void sendWelcomeEmail() {
        EmailService emailService = ApplicationContext.getBean(EmailService.class);
        emailService.sendWelcomeEmail(this.email, this.name);
    }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Move external service calls to service layer
// Fix: Create UserNotificationService with sendWelcomeEmail() method
// Reason: Entities should not depend on external services
```

### HIGH Priority Issues

#### 4. Formatting and Presentation Methods
**Pattern**: Methods for UI formatting or presentation
```java
// SMELL: Presentation logic in entity
@Entity
public class User {
    public String getFormattedName() {
        return firstName + " " + lastName;
    }
    
    public String getDisplayStatus() {
        return status.equals("ACTIVE") ? "Active User" : "Inactive User";
    }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Extract formatting methods to utility class
// Fix: Create UserFormatter utility class
// Reason: Presentation logic should be separate from data model
```

#### 5. Complex Validation Methods
**Pattern**: Methods with complex validation logic
```java
// SMELL: Complex validation in entity
@Entity
public class Product {
    public boolean isValidForSale() {
        if (price == null || price.compareTo(BigDecimal.ZERO) <= 0) {
            return false;
        }
        
        if (category == null || category.isBlank()) {
            return false;
        }
        
        if (inventory != null && inventory < 1) {
            return false;
        }
        
        return !isDiscontinued();
    }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Extract validation to validator class
// Fix: Create ProductValidator with isValidForSale() method
// Reason: Complex validation logic belongs in dedicated validators
```

#### 6. State Transition Methods
**Pattern**: Methods managing complex state changes
```java
// SMELL: Complex state management in entity
@Entity
public class Order {
    public void processPayment() {
        if (status != OrderStatus.PENDING) {
            throw new IllegalStateException("Order not in pending state");
        }
        
        // Complex payment processing logic
        status = OrderStatus.PROCESSING;
        processedAt = LocalDateTime.now();
        
        // Audit trail creation
        // Email notifications
        // Inventory updates
    }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Extract state transition to service class
// Fix: Create OrderProcessingService with processPayment() method
// Reason: State transitions often involve multiple concerns
```

### MEDIUM Priority Issues

#### 7. Calculation Helper Methods
**Pattern**: Methods performing calculations
```java
// SMELL: Calculation methods in entity
@Entity
public class Invoice {
    public BigDecimal calculateTax() {
        return subtotal.multiply(TAX_RATE);
    }
    
    public BigDecimal calculateDiscount() {
        return subtotal.multiply(discountPercentage.divide(BigDecimal.valueOf(100)));
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Extract calculations to utility class
// Fix: Create InvoiceCalculator utility class
// Reason: Improves reusability and testability of calculations
```

#### 8. Collection Manipulation Methods
**Pattern**: Methods manipulating entity collections
```java
// SMELL: Collection manipulation in entity
@Entity
public class User {
    public void addRole(Role role) {
        if (roles == null) {
            roles = new ArrayList<>();
        }
        
        if (!roles.contains(role)) {
            roles.add(role);
            role.getUsers().add(this);
        }
    }
    
    public void removeRole(Role role) {
        if (roles != null) {
            roles.remove(role);
            role.getUsers().remove(this);
        }
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Extract collection management to service class
// Fix: Create UserRoleService with addRole/removeRole methods
// Reason: Bidirectional relationship management is complex business logic
```

#### 9. Conversion Methods
**Pattern**: Methods converting entity to other formats
```java
// SMELL: Conversion logic in entity
@Entity
public class User {
    public UserDTO toDTO() {
        return UserDTO.builder()
            .id(this.id)
            .name(this.name)
            .email(this.email)
            .build();
    }
    
    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<>();
        map.put("id", this.id);
        map.put("name", this.name);
        map.put("email", this.email);
        return map;
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Extract conversion methods to mapper class
// Fix: Create UserMapper with toDTO() and toMap() methods
// Reason: Conversion logic belongs in dedicated mapper classes
```

### LOW Priority Issues

#### 10. Utility Helper Methods
**Pattern**: Simple utility methods that could be extracted
```java
// SMELL: Utility methods in entity
@Entity
public class User {
    public boolean hasEmail() {
        return email != null && !email.isBlank();
    }
    
    public boolean isActive() {
        return status == UserStatus.ACTIVE;
    }
}
```
**TODO Template**:
```java
// TODO: [LOW] Consider extracting utility methods to helper class
// Fix: Create UserUtils class for simple utility methods
// Reason: Improves reusability, though not critical for simple methods
```

## Method Extraction Guidelines

### Methods That Should Stay in Entity
- Simple getters/setters
- Basic property checks (`hasX()`, `isEmpty()`)
- Simple state queries (`isActive()`, `isValid()`)
- Basic equals/hashCode/toString
- JPA lifecycle callbacks

### Methods That Should Be Extracted

#### To Service Layer
- Complex business logic
- State transitions
- External service calls
- Multi-entity operations
- Transaction-requiring operations

#### To Utility Classes
- Static calculations
- Formatting methods
- Simple conversions
- Common algorithms

#### To Validator Classes
- Complex validation logic
- Multi-field validations
- Business rule validations

#### To Mapper Classes
- DTO conversions
- Data transformations
- Format conversions

## Extraction Strategy Examples

### Business Logic Extraction
```java
// BEFORE: Business logic in entity
@Entity
public class Order {
    public boolean canBeCancelled() {
        return status == OrderStatus.PENDING && 
               createdAt.isAfter(LocalDateTime.now().minusHours(24));
    }
}

// AFTER: Business logic in service
@Service
public class OrderService {
    public boolean canBeCancelled(Order order) {
        return order.getStatus() == OrderStatus.PENDING && 
               order.getCreatedAt().isAfter(LocalDateTime.now().minusHours(24));
    }
}
```

### Validation Extraction
```java
// BEFORE: Validation in entity
@Entity
public class User {
    public boolean isValidForRegistration() {
        return email != null && email.contains("@") && 
               password != null && password.length() >= 8;
    }
}

// AFTER: Validation in validator
@Component
public class UserValidator {
    public boolean isValidForRegistration(User user) {
        return isValidEmail(user.getEmail()) && 
               isValidPassword(user.getPassword());
    }
}
```

### Calculation Extraction
```java
// BEFORE: Calculation in entity
@Entity
public class Invoice {
    public BigDecimal calculateTotal() {
        return items.stream()
            .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}

// AFTER: Calculation in utility
@Component
public class InvoiceCalculator {
    public BigDecimal calculateTotal(List<InvoiceItem> items) {
        return items.stream()
            .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
```

## Detection Patterns for Claude Code

### Complexity Indicators
- Methods with >10 lines
- Methods with >3 conditional statements
- Methods with >2 levels of nesting
- Methods with external dependencies

### Dependency Indicators
- Methods calling static methods on other classes
- Methods accessing Spring beans
- Methods performing I/O operations
- Methods with complex exception handling

### Business Logic Indicators
- Methods with multiple calculation steps
- Methods with business rule conditions
- Methods combining multiple entity properties
- Methods with time-based logic

### Extraction Priority Matrix
| Method Type | Complexity | Dependencies | Priority |
|-------------|------------|--------------|----------|
| Business Logic | High | External | CRITICAL |
| Database Queries | Any | Database | CRITICAL |
| External Services | Any | External | CRITICAL |
| Formatting | Medium | None | HIGH |
| Validation | High | None | HIGH |
| State Transition | High | Internal | HIGH |
| Calculations | Medium | None | MEDIUM |
| Collections | Medium | Internal | MEDIUM |
| Conversions | Low | None | MEDIUM |
| Utilities | Low | None | LOW |