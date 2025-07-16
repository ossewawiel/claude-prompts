# Entity Single Responsibility Refactoring

## Purpose
Identify Single Responsibility Principle violations in JPA entities and suggest refactoring strategies to improve entity design.

## Single Responsibility Violations

### CRITICAL Issues

#### 1. Entity Combining Multiple Business Concepts
**Pattern**: Single entity representing multiple distinct business concepts
```java
// SMELL: Multiple business concepts in one entity
@Entity
public class UserAccount {
    // User profile data
    private String firstName;
    private String lastName;
    private String email;
    
    // Account settings
    private boolean notificationsEnabled;
    private String theme;
    private String language;
    
    // Billing information
    private String billingAddress;
    private String creditCardNumber;
    private String billingEmail;
    
    // Security settings
    private String passwordHash;
    private LocalDateTime lastLogin;
    private int failedLoginAttempts;
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Split entity into separate business concepts
// Fix: Create User, AccountSettings, BillingInfo, and SecurityCredentials entities
// Reason: Each entity should represent a single business concept
```

#### 2. Entity Acting as Data Transfer Object
**Pattern**: Entity with methods specifically for data transfer
```java
// SMELL: Entity acting as DTO
@Entity
public class Product {
    private String name;
    private BigDecimal price;
    
    // DTO-like methods
    public ProductResponse toResponse() { }
    public ProductSummary toSummary() { }
    public ProductListItem toListItem() { }
    
    // API-specific methods
    public void fromCreateRequest(CreateProductRequest request) { }
    public void fromUpdateRequest(UpdateProductRequest request) { }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Remove DTO conversion methods from entity
// Fix: Create separate ProductMapper class for conversions
// Reason: Entities should not handle data transfer concerns
```

#### 3. Entity with Audit and Business Logic
**Pattern**: Entity mixing audit concerns with business logic
```java
// SMELL: Mixed audit and business concerns
@Entity
public class Order {
    // Business fields
    private String orderNumber;
    private BigDecimal total;
    private OrderStatus status;
    
    // Audit fields
    private String createdBy;
    private LocalDateTime createdAt;
    private String lastModifiedBy;
    private LocalDateTime lastModifiedAt;
    private String changeLog;
    
    // Business methods
    public void processPayment() { }
    public void ship() { }
    
    // Audit methods
    public void recordChange(String change) { }
    public List<AuditEntry> getAuditHistory() { }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Separate audit concerns from business logic
// Fix: Use @Audited or create separate OrderAudit entity
// Reason: Audit and business logic are separate concerns
```

### HIGH Priority Issues

#### 4. Entity Handling Multiple Lifecycle States
**Pattern**: Entity managing multiple unrelated lifecycle states
```java
// SMELL: Multiple lifecycle concerns
@Entity
public class Document {
    // Document content
    private String title;
    private String content;
    
    // Workflow state
    private WorkflowStatus workflowStatus;
    private String approver;
    
    // Publishing state
    private PublishStatus publishStatus;
    private LocalDateTime publishedAt;
    
    // Version control state
    private int versionNumber;
    private boolean isLatestVersion;
    
    // Methods for each concern
    public void submitForApproval() { }
    public void publish() { }
    public void createNewVersion() { }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Separate lifecycle concerns into focused entities
// Fix: Create DocumentWorkflow, DocumentPublication, and DocumentVersion entities
// Reason: Each lifecycle has different responsibilities and rules
```

#### 5. Entity with Multiple Collection Types
**Pattern**: Entity managing multiple unrelated collections
```java
// SMELL: Multiple collection responsibilities
@Entity
public class User {
    private String name;
    private String email;
    
    // Multiple unrelated collections
    @OneToMany
    private List<Order> orders;
    
    @OneToMany
    private List<Review> reviews;
    
    @OneToMany
    private List<Notification> notifications;
    
    @OneToMany
    private List<LoginHistory> loginHistory;
    
    // Methods for each collection
    public void addOrder(Order order) { }
    public void addReview(Review review) { }
    public void addNotification(Notification notification) { }
    public void recordLogin(LoginHistory login) { }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Extract collection management to separate entities or services
// Fix: Create UserOrders, UserReviews, UserNotifications services
// Reason: Each collection represents a different aspect of user behavior
```

#### 6. Entity with Calculation and Storage
**Pattern**: Entity storing both raw data and calculated values
```java
// SMELL: Mixed calculation and storage responsibilities
@Entity
public class Invoice {
    // Raw data
    private BigDecimal subtotal;
    private BigDecimal discountPercent;
    private BigDecimal taxRate;
    
    // Calculated values (stored)
    private BigDecimal discountAmount;
    private BigDecimal taxAmount;
    private BigDecimal total;
    
    // Calculation methods
    public void recalculateAmounts() {
        this.discountAmount = calculateDiscount();
        this.taxAmount = calculateTax();
        this.total = calculateTotal();
    }
    
    private BigDecimal calculateDiscount() { }
    private BigDecimal calculateTax() { }
    private BigDecimal calculateTotal() { }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Separate calculation logic from data storage
// Fix: Create InvoiceCalculator service, store only necessary calculated values
// Reason: Calculation logic and data storage are separate concerns
```

### MEDIUM Priority Issues

#### 7. Entity with Configuration and Data
**Pattern**: Entity mixing configuration with business data
```java
// SMELL: Configuration mixed with business data
@Entity
public class EmailTemplate {
    // Business data
    private String name;
    private String subject;
    private String body;
    
    // Configuration data
    private String smtpServer;
    private int smtpPort;
    private String senderEmail;
    private String senderName;
    
    // Mixed methods
    public void sendEmail(String recipient) { }
    public void validateTemplate() { }
    public void updateConfiguration() { }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Separate configuration from business data
// Fix: Create EmailConfiguration entity and EmailTemplateService
// Reason: Configuration and business data have different lifecycles
```

#### 8. Entity with Validation and Business Logic
**Pattern**: Entity mixing validation rules with business operations
```java
// SMELL: Validation mixed with business logic
@Entity
public class Product {
    private String name;
    private BigDecimal price;
    
    // Validation methods
    public boolean isValidName() { }
    public boolean isValidPrice() { }
    public boolean isValidCategory() { }
    
    // Business methods
    public void applyDiscount(BigDecimal discount) { }
    public void updateInventory(int quantity) { }
    public void discontinue() { }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Separate validation from business logic
// Fix: Create ProductValidator class and ProductService
// Reason: Validation rules and business operations are separate concerns
```

### LOW Priority Issues

#### 9. Entity with Formatting and Data
**Pattern**: Entity handling both data storage and presentation formatting
```java
// SMELL: Formatting mixed with data storage
@Entity
public class User {
    private String firstName;
    private String lastName;
    private LocalDate birthDate;
    
    // Formatting methods
    public String getFormattedName() {
        return firstName + " " + lastName;
    }
    
    public String getFormattedBirthDate() {
        return birthDate.format(DateTimeFormatter.ofPattern("MM/dd/yyyy"));
    }
    
    public String getAgeDisplay() {
        return Period.between(birthDate, LocalDate.now()).getYears() + " years old";
    }
}
```
**TODO Template**:
```java
// TODO: [LOW] Extract formatting methods to utility class
// Fix: Create UserFormatter utility class
// Reason: Formatting and data storage are separate concerns
```

## Refactoring Strategies

### 1. Extract Related Concepts
```java
// BEFORE: Multiple concepts in one entity
@Entity
public class UserProfile {
    private String name;
    private String email;
    private String address;
    private String phone;
    private String preferences;
    private String securitySettings;
}

// AFTER: Separate entities for each concept
@Entity
public class User {
    private String name;
    private String email;
    
    @OneToOne
    private ContactInfo contactInfo;
    
    @OneToOne
    private UserPreferences preferences;
    
    @OneToOne
    private SecuritySettings securitySettings;
}
```

### 2. Extract Service Responsibilities
```java
// BEFORE: Business logic in entity
@Entity
public class Order {
    public void processPayment() { /* complex logic */ }
    public void calculateShipping() { /* complex logic */ }
    public void sendNotifications() { /* complex logic */ }
}

// AFTER: Service handles business logic
@Service
public class OrderService {
    public void processPayment(Order order) { /* complex logic */ }
    public void calculateShipping(Order order) { /* complex logic */ }
    public void sendNotifications(Order order) { /* complex logic */ }
}
```

### 3. Extract Lifecycle Management
```java
// BEFORE: Multiple lifecycle states in entity
@Entity
public class Document {
    private WorkflowStatus workflowStatus;
    private PublishStatus publishStatus;
    private VersionStatus versionStatus;
    
    public void submitForApproval() { }
    public void publish() { }
    public void createNewVersion() { }
}

// AFTER: Separate lifecycle entities
@Entity
public class Document {
    private String title;
    private String content;
    
    @OneToOne
    private DocumentWorkflow workflow;
    
    @OneToOne
    private DocumentPublication publication;
    
    @OneToMany
    private List<DocumentVersion> versions;
}
```

## Single Responsibility Guidelines

### Entity Should Focus On
- **Single Business Concept**: One clear domain concept
- **Data Integrity**: Basic validation and constraints
- **State Management**: Simple state transitions
- **Relationship Management**: Direct associations only

### Entity Should Not Handle
- **Multiple Business Domains**: Different business concepts
- **Cross-Cutting Concerns**: Logging, security, auditing
- **Complex Calculations**: Business rule calculations
- **External Integration**: API calls, file operations
- **Presentation Logic**: Formatting, display rules

## Detection Patterns for Claude Code

### Multiple Responsibility Indicators
- **Field Count**: >15 fields may indicate multiple concepts
- **Method Count**: >20 methods may indicate multiple responsibilities
- **Collection Count**: >3 collections may indicate multiple concerns
- **Annotation Diversity**: Mixed JPA, validation, and business annotations

### Naming Pattern Analysis
- Fields with different naming patterns (userXxx, accountXxx, billingXxx)
- Methods with different verb patterns (validate, calculate, format, send)
- Multiple status/state fields

### Complexity Indicators
- **Cyclomatic Complexity**: High complexity in single entity
- **Dependency Count**: Too many imports and dependencies
- **Test Complexity**: Difficult to test due to multiple concerns

## Refactoring Decision Matrix

| Responsibility Type | Extraction Target | Priority | Effort |
|-------------------|------------------|----------|---------|
| Business Logic | Service Layer | CRITICAL | Medium |
| Data Transfer | Mapper/DTO | CRITICAL | Low |
| Audit Concerns | Audit Entity | CRITICAL | High |
| Lifecycle States | State Entities | HIGH | High |
| Collections | Service Layer | HIGH | Medium |
| Calculations | Calculator Service | HIGH | Medium |
| Configuration | Config Entity | MEDIUM | Medium |
| Validation | Validator Service | MEDIUM | Low |
| Formatting | Utility Class | LOW | Low |

## Best Practices for Single Responsibility

### Keep Entities Focused
- One entity = One business concept
- Clear, single-purpose naming
- Minimal method count per entity
- Related fields grouped together

### Use Composition Over Inheritance
- Prefer @OneToOne relationships for different concerns
- Use value objects for complex data types
- Aggregate related entities in services

### Separate Concerns Properly
- Business logic → Service layer
- Data transfer → DTO/Mapper
- Validation → Validator classes
- Formatting → Utility classes