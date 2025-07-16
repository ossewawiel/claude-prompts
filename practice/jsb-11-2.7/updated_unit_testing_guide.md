# JPA Entity Unit Testing Guide for Claude Code
## Java 11 & Spring Boot 2.7

---

## 🎯 QUICK START REFERENCE

### Essential Dependencies
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
</dependencies>
```

### Test Class Template
```java
@DisplayName("User Entity Unit Tests")
class UserEntityUnitTest {
    
    private Validator validator;
    
    @BeforeEach
    void setUp() {
        validator = Validation.buildDefaultValidatorFactory().getValidator();
    }
    
    @Test
    @DisplayName("Should create valid user with required fields")
    void shouldCreateValidUser_whenAllRequiredFieldsProvided() {
        // Given
        User user = UserTestDataBuilder.aUser()
            .withEmail("test@example.com")
            .withFirstName("John")
            .build();
        
        // When
        Set<ConstraintViolation<User>> violations = validator.validate(user);
        
        // Then
        assertThat(violations).isEmpty();
        assertThat(user.getEmail()).isEqualTo("test@example.com");
    }
}
```

---

## 🧪 CORE TESTING PRINCIPLES

### What to Test (Entity Focus)
- **Field constraints** (`@NotNull`, `@Size`, `@Email`, etc.)
- **Custom validation logic** (cross-field validation)
- **Entity lifecycle callbacks** (`@PrePersist`, `@PostLoad`)
- **Relationship mappings** (bidirectional integrity)
- **Custom methods** (`equals()`, `hashCode()`, `toString()`)
- **Enum mappings** and converters
- **Business logic** within the entity

### What NOT to Test
- JPA framework behavior (persistence, queries)
- Database-specific operations
- Spring context bootstrapping
- Auto-generated getters/setters (unless custom logic)

---

## 🏗️ TEST DATA BUILDERS

### Builder Pattern Implementation
```java
public class UserTestDataBuilder {
    private String email = "default@example.com";
    private String firstName = "DefaultFirst";
    private String lastName = "DefaultLast";
    private UserStatus status = UserStatus.ACTIVE;
    private LocalDate birthDate = LocalDate.of(1990, 1, 1);
    private Set<Role> roles = new HashSet<>();
    
    public static UserTestDataBuilder aUser() {
        return new UserTestDataBuilder();
    }
    
    public UserTestDataBuilder withEmail(String email) {
        this.email = email;
        return this;
    }
    
    public UserTestDataBuilder withFirstName(String firstName) {
        this.firstName = firstName;
        return this;
    }
    
    public UserTestDataBuilder withInvalidEmail() {
        this.email = "invalid-email";
        return this;
    }
    
    public UserTestDataBuilder withRole(Role role) {
        this.roles.add(role);
        return this;
    }
    
    public User build() {
        User user = new User();
        user.setEmail(email);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setStatus(status);
        user.setBirthDate(birthDate);
        user.setRoles(new HashSet<>(roles));
        return user;
    }
}
```

### Factory Methods for Common Scenarios
```java
public class UserTestFactory {
    
    public static User validUser() {
        return UserTestDataBuilder.aUser().build();
    }
    
    public static User userWithInvalidEmail() {
        return UserTestDataBuilder.aUser().withInvalidEmail().build();
    }
    
    public static User adminUser() {
        return UserTestDataBuilder.aUser()
            .withRole(Role.ADMIN)
            .build();
    }
    
    public static User userWithoutRequiredFields() {
        return UserTestDataBuilder.aUser()
            .withEmail(null)
            .withFirstName(null)
            .build();
    }
}
```

---

## ✅ VALIDATION TESTING PATTERNS

### Constraint Validation Setup
```java
public class ValidationTestBase {
    protected Validator validator;
    
    @BeforeEach
    void setUpValidator() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }
    
    protected <T> void assertViolation(T entity, String propertyPath, String message) {
        Set<ConstraintViolation<T>> violations = validator.validate(entity);
        
        assertThat(violations)
            .extracting(ConstraintViolation::getPropertyPath)
            .extracting(Path::toString)
            .contains(propertyPath);
            
        assertThat(violations)
            .extracting(ConstraintViolation::getMessage)
            .contains(message);
    }
    
    protected <T> void assertNoViolations(T entity) {
        Set<ConstraintViolation<T>> violations = validator.validate(entity);
        assertThat(violations).isEmpty();
    }
}
```

### Specific Validation Tests
```java
@Nested
@DisplayName("Email Validation Tests")
class EmailValidationTests extends ValidationTestBase {
    
    @Test
    @DisplayName("Should reject null email")
    void shouldRejectNullEmail() {
        // Given
        User user = UserTestDataBuilder.aUser()
            .withEmail(null)
            .build();
        
        // When & Then
        assertViolation(user, "email", "Email is required");
    }
    
    @ParameterizedTest
    @DisplayName("Should reject invalid email formats")
    @ValueSource(strings = {"", "invalid", "test@", "@example.com", "test..test@example.com"})
    void shouldRejectInvalidEmailFormats(String invalidEmail) {
        // Given
        User user = UserTestDataBuilder.aUser()
            .withEmail(invalidEmail)
            .build();
        
        // When & Then
        assertViolation(user, "email", "Invalid email format");
    }
    
    @ParameterizedTest
    @DisplayName("Should accept valid email formats")
    @ValueSource(strings = {"test@example.com", "user.name@domain.co.uk", "user+tag@example.org"})
    void shouldAcceptValidEmailFormats(String validEmail) {
        // Given
        User user = UserTestDataBuilder.aUser()
            .withEmail(validEmail)
            .build();
        
        // When & Then
        assertNoViolations(user);
    }
}

@Nested
@DisplayName("Size Validation Tests")
class SizeValidationTests extends ValidationTestBase {
    
    @Test
    @DisplayName("Should reject first name that is too short")
    void shouldRejectShortFirstName() {
        // Given
        User user = UserTestDataBuilder.aUser()
            .withFirstName("a") // Less than minimum of 2
            .build();
        
        // When & Then
        assertViolation(user, "firstName", "First name must be between 2 and 50 characters");
    }
    
    @Test
    @DisplayName("Should reject first name that is too long")
    void shouldRejectLongFirstName() {
        // Given
        String longName = "a".repeat(51); // More than maximum of 50
        User user = UserTestDataBuilder.aUser()
            .withFirstName(longName)
            .build();
        
        // When & Then
        assertViolation(user, "firstName", "First name must be between 2 and 50 characters");
    }
}
```

---

## 🚨 EXCEPTION TESTING PATTERNS

### Testing Custom Exceptions
```java
@Nested
@DisplayName("Custom Exception Tests")
class CustomExceptionTests {
    
    @Test
    @DisplayName("Should throw UserValidationException for invalid age")
    void shouldThrowUserValidationException_whenAgeIsInvalid() {
        // Given
        User user = UserTestDataBuilder.aUser()
            .withBirthDate(LocalDate.now().plusYears(1)) // Future date
            .build();
        
        // When & Then
        assertThatThrownBy(() -> user.validateAge())
            .isInstanceOf(UserValidationException.class)
            .hasMessage("Birth date cannot be in the future");
    }
    
    @Test
    @DisplayName("Should throw IllegalArgumentException for null role")
    void shouldThrowIllegalArgumentException_whenRoleIsNull() {
        // Given
        User user = UserTestDataBuilder.aUser().build();
        
        // When & Then
        assertThatThrownBy(() -> user.addRole(null))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessage("Role cannot be null");
    }
}
```

### Testing Constraint Violations
```java
@Test
@DisplayName("Should throw ConstraintViolationException when validation fails")
void shouldThrowConstraintViolationException_whenValidationFails() {
    // Given
    User user = UserTestDataBuilder.aUser()
        .withEmail("invalid-email")
        .build();
    
    // When & Then
    assertThatThrownBy(() -> {
        Set<ConstraintViolation<User>> violations = validator.validate(user);
        if (!violations.isEmpty()) {
            throw new ConstraintViolationException(violations);
        }
    })
    .isInstanceOf(ConstraintViolationException.class)
    .hasMessageContaining("Invalid email format");
}
```

---

## 🧼 MOCKITO INTEGRATION PATTERNS

### Mocking JPA Dependencies
```java
@ExtendWith(MockitoExtension.class)
class UserServiceUnitTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private ValidationService validationService;
    
    @InjectMocks
    private UserService userService;
    
    @Test
    @DisplayName("Should save user when validation passes")
    void shouldSaveUser_whenValidationPasses() {
        // Given
        User user = UserTestDataBuilder.aUser().build();
        User savedUser = UserTestDataBuilder.aUser()
            .withId(1L)
            .build();
        
        when(validationService.validate(user)).thenReturn(Collections.emptySet());
        when(userRepository.save(user)).thenReturn(savedUser);
        
        // When
        User result = userService.createUser(user);
        
        // Then
        assertThat(result.getId()).isEqualTo(1L);
        verify(validationService).validate(user);
        verify(userRepository).save(user);
    }
}
```

### Mocking Entity Dependencies
```java
@Test
@DisplayName("Should calculate user summary correctly")
void shouldCalculateUserSummary_whenOrdersExist() {
    // Given
    User user = UserTestDataBuilder.aUser().build();
    Order order1 = mock(Order.class);
    Order order2 = mock(Order.class);
    
    when(order1.getTotalAmount()).thenReturn(BigDecimal.valueOf(100.00));
    when(order2.getTotalAmount()).thenReturn(BigDecimal.valueOf(200.00));
    
    user.addOrder(order1);
    user.addOrder(order2);
    
    // When
    UserSummary summary = user.calculateSummary();
    
    // Then
    assertThat(summary.getTotalOrderValue()).isEqualTo(BigDecimal.valueOf(300.00));
    assertThat(summary.getOrderCount()).isEqualTo(2);
}
```

---

## 🔄 LIFECYCLE CALLBACK TESTING

### Testing Entity Lifecycle Methods
```java
@Nested
@DisplayName("Entity Lifecycle Tests")
class EntityLifecycleTests {
    
    @Test
    @DisplayName("Should set creation timestamp in @PrePersist")
    void shouldSetCreationTimestamp_onPrePersist() {
        // Given
        User user = UserTestDataBuilder.aUser().build();
        assertThat(user.getCreatedAt()).isNull();
        
        // When
        user.prePersist(); // Manually call lifecycle method
        
        // Then
        assertThat(user.getCreatedAt()).isNotNull();
        assertThat(user.getCreatedAt()).isBeforeOrEqualTo(LocalDateTime.now());
    }
    
    @Test
    @DisplayName("Should update modified timestamp in @PreUpdate")
    void shouldUpdateModifiedTimestamp_onPreUpdate() {
        // Given
        User user = UserTestDataBuilder.aUser().build();
        user.setCreatedAt(LocalDateTime.now().minusDays(1));
        
        // When
        user.preUpdate(); // Manually call lifecycle method
        
        // Then
        assertThat(user.getUpdatedAt()).isNotNull();
        assertThat(user.getUpdatedAt()).isAfter(user.getCreatedAt());
    }
}
```

---

## 🔗 RELATIONSHIP TESTING

### Testing Bidirectional Relationships
```java
@Nested
@DisplayName("Relationship Management Tests")
class RelationshipTests {
    
    @Test
    @DisplayName("Should maintain bidirectional relationship when adding order")
    void shouldMaintainBidirectionalRelationship_whenAddingOrder() {
        // Given
        User user = UserTestDataBuilder.aUser().build();
        Order order = OrderTestDataBuilder.anOrder().build();
        
        // When
        user.addOrder(order);
        
        // Then
        assertThat(user.getOrders()).contains(order);
        assertThat(order.getUser()).isEqualTo(user);
    }
    
    @Test
    @DisplayName("Should maintain bidirectional relationship when removing order")
    void shouldMaintainBidirectionalRelationship_whenRemovingOrder() {
        // Given
        User user = UserTestDataBuilder.aUser().build();
        Order order = OrderTestDataBuilder.anOrder().build();
        user.addOrder(order);
        
        // When
        user.removeOrder(order);
        
        // Then
        assertThat(user.getOrders()).doesNotContain(order);
        assertThat(order.getUser()).isNull();
    }
}
```

---

## ⚡ PERFORMANCE CONSIDERATIONS

### Avoiding Expensive Operations in Unit Tests
```java
@Test
@DisplayName("Should validate email format efficiently")
void shouldValidateEmailFormatEfficiently() {
    // Given - Use pre-compiled pattern instead of regex validation
    User user = UserTestDataBuilder.aUser()
        .withEmail("test@example.com")
        .build();
    
    // When - Measure execution time for performance-critical validation
    long startTime = System.nanoTime();
    boolean isValid = user.isEmailValid();
    long endTime = System.nanoTime();
    
    // Then
    assertThat(isValid).isTrue();
    assertThat(endTime - startTime).isLessThan(1_000_000); // Less than 1ms
}

@Test
@DisplayName("Should avoid reflection in validation tests")
void shouldAvoidReflectionInValidationTests() {
    // Given - Use direct field access instead of reflection
    User user = UserTestDataBuilder.aUser().build();
    
    // When - Direct validation instead of reflection-based
    Set<ConstraintViolation<User>> violations = validator.validate(user);
    
    // Then - Fast assertion without reflection
    assertThat(violations).isEmpty();
}
```

---

## 🧹 TEST DATA CLEANUP

### Cleanup Strategies
```java
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class UserEntityCleanupTest {
    
    private static final List<User> TEST_USERS = new ArrayList<>();
    
    @AfterEach
    void cleanupTestData() {
        // Clear any static collections or caches
        TEST_USERS.clear();
        
        // Reset any static state
        User.resetStaticCounter();
    }
    
    @Test
    @DisplayName("Should handle cleanup properly")
    void shouldHandleCleanupProperly() {
        // Given
        User user = UserTestDataBuilder.aUser().build();
        TEST_USERS.add(user);
        
        // When
        user.performOperation();
        
        // Then
        assertThat(TEST_USERS).hasSize(1);
        // Cleanup happens automatically in @AfterEach
    }
}
```

### Using @DirtiesContext for Spring Context
```java
@DataJpaTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class UserRepositoryIntegrationTest {
    
    @Test
    @DisplayName("Should reset context after test")
    void shouldResetContextAfterTest() {
        // Test implementation
        // Context will be reset after this test
    }
}
```

---

## 📋 TESTING CHECKLIST

### Essential Test Coverage
- [ ] **Field Validation**: All `@NotNull`, `@Size`, `@Email`, `@Pattern` constraints
- [ ] **Custom Validation**: Cross-field validation and business rules
- [ ] **Lifecycle Callbacks**: `@PrePersist`, `@PreUpdate`, `@PostLoad` methods
- [ ] **Relationship Management**: Bidirectional relationship integrity
- [ ] **Equals/HashCode**: Proper implementation with entity identity
- [ ] **ToString**: Excludes sensitive data and prevents lazy loading
- [ ] **Enum Handling**: Proper persistence and retrieval of enum values
- [ ] **Exception Scenarios**: Custom exceptions and constraint violations
- [ ] **Builder Pattern**: Test data builders for complex entity creation
- [ ] **Performance**: No expensive operations in unit tests

### Code Quality Checks
- [ ] **Naming**: Descriptive test method names following convention
- [ ] **Structure**: Given-When-Then pattern for test organization
- [ ] **Assertions**: Using AssertJ for fluent and readable assertions
- [ ] **Parameterized Tests**: Multiple test cases for edge conditions
- [ ] **Nested Classes**: Logical grouping of related tests
- [ ] **Display Names**: Clear test descriptions for better reporting
- [ ] **Test Data**: Isolated test data without dependencies
- [ ] **Mocking**: Proper use of mocks for external dependencies

---

## 🎯 NAMING CONVENTIONS

### Test Class Naming
```java
// Pattern: {EntityName}UnitTest
UserUnitTest.java
OrderUnitTest.java
ProductUnitTest.java
```

### Test Method Naming
```java
// Pattern: should{ExpectedBehavior}_when{StateUnderTest}
@Test
void shouldReturnTrue_whenEmailIsValid() { }

@Test
void shouldThrowException_whenEmailIsNull() { }

@Test
void shouldMaintainBidirectionalRelationship_whenAddingOrder() { }
```

### Test Data Naming
```java
// Use descriptive variable names
User expectedUser = UserTestDataBuilder.aUser().build();
User actualUser = userService.createUser(inputUser);

// Prefix for clarity
String expectedEmail = "test@example.com";
String actualEmail = user.getEmail();
```

---

## 📊 RECOMMENDED TESTING LIBRARIES

### Core Dependencies
- **JUnit 5 (Jupiter)** - Modern testing framework
- **AssertJ** - Fluent assertions for readable test code
- **Mockito** - Mocking framework for unit testing
- **Spring Boot Test** - Testing support for Spring Boot applications
- **H2 Database** - In-memory database for testing
- **Hibernate Validator** - Bean validation for constraint testing

### Optional Libraries
- **Testcontainers** - Integration testing with real databases
- **WireMock** - HTTP service mocking
- **JSONassert** - JSON comparison in tests
- **Hamcrest** - Matcher library for assertions

---

## 🎓 BEST PRACTICES SUMMARY

1. **Keep Tests Small and Focused** - One logical assertion per test
2. **Use Test Data Builders** - Create reusable, maintainable test data
3. **Test Validation Thoroughly** - Cover all constraint scenarios
4. **Mock External Dependencies** - Isolate unit under test
5. **Use Descriptive Names** - Make tests self-documenting
6. **Follow Given-When-Then** - Structure tests clearly
7. **Avoid Integration Testing** - Keep tests focused on entity behavior
8. **Test Exception Scenarios** - Ensure proper error handling
9. **Clean Up Test Data** - Prevent test interference
10. **Optimize Performance** - Keep tests fast and efficient