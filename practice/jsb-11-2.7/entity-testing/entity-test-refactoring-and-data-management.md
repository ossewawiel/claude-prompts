# Entity Test Refactoring and Data Management - Spring Boot 2.7 Java 11

## Overview
This document provides comprehensive guidance on refactoring entity tests, managing test data, and maintaining test code quality in Spring Boot 2.7 Java 11 applications.

**Cross-References:**
- [Entity Unit Testing Best Practices](entity-unit-testing-best-practices.md) - Unit testing specific patterns
- [Entity Integration Testing Best Practices](entity-integration-testing-best-practices.md) - Integration testing specific patterns

## Dependencies and Setup

### Unit Testing Dependencies
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-core</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>jakarta.validation</groupId>
        <artifactId>jakarta.validation-api</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Integration Testing Dependencies
```xml
<dependencies>
    <!-- Include all unit testing dependencies above, plus: -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>postgresql</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Test Code Refactoring Patterns

### 1. Extract Common Test Setup
Refactor repetitive test setup into reusable methods:

```java
@TestMethodOrder(OrderAnnotation.class)
class UserEntityTest {
    
    private Validator validator;
    private User validUser;
    
    @BeforeEach
    void setUp() {
        validator = Validation.buildDefaultValidatorFactory().getValidator();
        validUser = createValidUser();
    }
    
    // Extract common user creation
    private User createValidUser() {
        return User.builder()
            .email("john.doe@example.com")
            .firstName("John")
            .lastName("Doe")
            .status(UserStatus.ACTIVE)
            .build();
    }
    
    // Extract common validation logic
    private void assertValidationFailure(User user, String expectedField, String expectedMessage) {
        var violations = validator.validate(user);
        assertThat(violations).hasSize(1);
        var violation = violations.iterator().next();
        assertThat(violation.getPropertyPath().toString()).isEqualTo(expectedField);
        assertThat(violation.getMessage()).contains(expectedMessage);
    }
}
```

### 2. Consolidate Repetitive Assertions
Create reusable assertion methods:

```java
public class EntityAssertions {
    
    public static void assertValidUser(User user) {
        assertThat(user.getEmail()).isNotBlank();
        assertThat(user.getFirstName()).isNotBlank();
        assertThat(user.getLastName()).isNotBlank();
        assertThat(user.getStatus()).isNotNull();
        assertThat(user.getCreatedAt()).isNotNull();
    }
    
    public static void assertUserEquality(User expected, User actual) {
        assertThat(actual.getId()).isEqualTo(expected.getId());
        assertThat(actual.getEmail()).isEqualTo(expected.getEmail());
        assertThat(actual.getFirstName()).isEqualTo(expected.getFirstName());
        assertThat(actual.getLastName()).isEqualTo(expected.getLastName());
    }
    
    public static void assertValidationViolation(Set<ConstraintViolation<User>> violations, 
                                               String field, String messageContains) {
        assertThat(violations)
            .extracting(ConstraintViolation::getPropertyPath)
            .extracting(Path::toString)
            .contains(field);
        
        assertThat(violations)
            .extracting(ConstraintViolation::getMessage)
            .anyMatch(message -> message.contains(messageContains));
    }
}
```

### 3. Shared Test Base Classes
Create base classes for common functionality:

```java
@ExtendWith(MockitoExtension.class)
public abstract class EntityTestBase {
    
    protected Validator validator;
    
    @BeforeEach
    void setUpValidator() {
        validator = Validation.buildDefaultValidatorFactory().getValidator();
    }
    
    protected <T> void assertNoValidationViolations(T entity) {
        var violations = validator.validate(entity);
        assertThat(violations).isEmpty();
    }
    
    protected <T> void assertValidationViolation(T entity, String field) {
        var violations = validator.validate(entity);
        assertThat(violations).isNotEmpty();
        assertThat(violations)
            .extracting(ConstraintViolation::getPropertyPath)
            .extracting(Path::toString)
            .contains(field);
    }
}

// Usage in test classes
class UserEntityTest extends EntityTestBase {
    
    @Test
    void shouldPassValidationWithValidUser() {
        var user = UserTestDataBuilder.aValidUser().build();
        assertNoValidationViolations(user);
    }
}
```

## Test Data Management Strategies

### 1. Hierarchical Test Data Builders
Create builder hierarchy for complex entities:

```java
public abstract class EntityTestDataBuilder<T, B extends EntityTestDataBuilder<T, B>> {
    
    @SuppressWarnings("unchecked")
    protected B self() {
        return (B) this;
    }
    
    public abstract T build();
}

public class UserTestDataBuilder extends EntityTestDataBuilder<User, UserTestDataBuilder> {
    
    private String email = "default@example.com";
    private String firstName = "John";
    private String lastName = "Doe";
    private UserStatus status = UserStatus.ACTIVE;
    private List<Address> addresses = new ArrayList<>();
    
    public static UserTestDataBuilder aUser() {
        return new UserTestDataBuilder();
    }
    
    public static UserTestDataBuilder aValidUser() {
        return aUser()
            .withEmail("valid@example.com")
            .withName("John", "Doe")
            .withStatus(UserStatus.ACTIVE);
    }
    
    public static UserTestDataBuilder anInvalidUser() {
        return aUser()
            .withEmail("invalid-email")
            .withName("", "");
    }
    
    public UserTestDataBuilder withEmail(String email) {
        this.email = email;
        return self();
    }
    
    public UserTestDataBuilder withName(String firstName, String lastName) {
        this.firstName = firstName;
        this.lastName = lastName;
        return self();
    }
    
    public UserTestDataBuilder withStatus(UserStatus status) {
        this.status = status;
        return self();
    }
    
    public UserTestDataBuilder withAddresses(Address... addresses) {
        this.addresses = Arrays.asList(addresses);
        return self();
    }
    
    @Override
    public User build() {
        var user = User.builder()
            .email(email)
            .firstName(firstName)
            .lastName(lastName)
            .status(status)
            .build();
        
        addresses.forEach(address -> {
            address.setUser(user);
            user.getAddresses().add(address);
        });
        
        return user;
    }
}
```

### 2. Test Data Factories with Caching
Implement efficient test data creation with caching:

```java
@Component
public class TestDataFactory {
    
    private final Map<String, User> userCache = new ConcurrentHashMap<>();
    private final Map<String, Address> addressCache = new ConcurrentHashMap<>();
    
    public User createUser(String email) {
        return userCache.computeIfAbsent(email, this::buildUser);
    }
    
    public User createUserWithAddresses(String email, int addressCount) {
        var user = createUser(email);
        for (int i = 0; i < addressCount; i++) {
            var address = createAddress("address-" + i + "-" + email);
            user.addAddress(address);
        }
        return user;
    }
    
    private User buildUser(String email) {
        return User.builder()
            .email(email)
            .firstName("Test")
            .lastName("User")
            .status(UserStatus.ACTIVE)
            .build();
    }
    
    private Address createAddress(String key) {
        return addressCache.computeIfAbsent(key, this::buildAddress);
    }
    
    private Address buildAddress(String key) {
        return Address.builder()
            .street("123 Test St")
            .city("Test City")
            .zipCode("12345")
            .build();
    }
    
    @PreDestroy
    public void clearCache() {
        userCache.clear();
        addressCache.clear();
    }
}
```

### 3. Parameterized Test Data
Create reusable parameterized test data:

```java
public class UserTestData {
    
    public static Stream<Arguments> validUserData() {
        return Stream.of(
            Arguments.of("john.doe@example.com", "John", "Doe", UserStatus.ACTIVE),
            Arguments.of("jane.smith@test.com", "Jane", "Smith", UserStatus.PENDING),
            Arguments.of("bob.wilson@domain.org", "Bob", "Wilson", UserStatus.INACTIVE)
        );
    }
    
    public static Stream<Arguments> invalidEmailData() {
        return Stream.of(
            Arguments.of("", "Email cannot be empty"),
            Arguments.of("invalid-email", "Email must be valid format"),
            Arguments.of("@example.com", "Email must have username"),
            Arguments.of("user@", "Email must have domain")
        );
    }
    
    public static Stream<Arguments> nameValidationData() {
        return Stream.of(
            Arguments.of("", "Name cannot be empty"),
            Arguments.of("A", "Name must be at least 2 characters"),
            Arguments.of("A".repeat(51), "Name cannot exceed 50 characters")
        );
    }
}

// Usage in tests
@ParameterizedTest
@MethodSource("com.example.UserTestData#validUserData")
void shouldAcceptValidUserData(String email, String firstName, String lastName, UserStatus status) {
    var user = UserTestDataBuilder.aUser()
        .withEmail(email)
        .withName(firstName, lastName)
        .withStatus(status)
        .build();
    
    assertNoValidationViolations(user);
}
```

## Test Maintenance Practices

### 1. Test Data Evolution Strategies
Handle entity changes gracefully:

```java
public class UserTestDataBuilder {
    
    private static final String DEFAULT_EMAIL = "test@example.com";
    private static final String DEFAULT_FIRST_NAME = "John";
    private static final String DEFAULT_LAST_NAME = "Doe";
    
    // Use constants for default values to maintain consistency
    private String email = DEFAULT_EMAIL;
    private String firstName = DEFAULT_FIRST_NAME;
    private String lastName = DEFAULT_LAST_NAME;
    
    // Version-specific builders for backward compatibility
    public static UserTestDataBuilder aUserV1() {
        return aUser()
            .withEmail(DEFAULT_EMAIL)
            .withName(DEFAULT_FIRST_NAME, DEFAULT_LAST_NAME);
    }
    
    public static UserTestDataBuilder aUserV2() {
        return aUserV1()
            .withStatus(UserStatus.ACTIVE)
            .withCreatedAt(LocalDateTime.now());
    }
    
    // Migration helper for test data
    public UserTestDataBuilder migrateFromV1() {
        return this.withStatus(UserStatus.ACTIVE)
                  .withCreatedAt(LocalDateTime.now());
    }
}
```

### 2. Test Fixture Management
Organize test fixtures for maintainability:

```java
@TestConfiguration
public class TestFixtureConfig {
    
    @Bean
    @Primary
    public TestFixtureManager testFixtureManager() {
        return new TestFixtureManager();
    }
}

public class TestFixtureManager {
    
    private final Map<Class<?>, Object> fixtures = new ConcurrentHashMap<>();
    
    @SuppressWarnings("unchecked")
    public <T> T getFixture(Class<T> type, Supplier<T> supplier) {
        return (T) fixtures.computeIfAbsent(type, k -> supplier.get());
    }
    
    public void clearFixtures() {
        fixtures.clear();
    }
    
    public User getStandardUser() {
        return getFixture(User.class, () -> 
            UserTestDataBuilder.aValidUser().build());
    }
    
    public User getAdminUser() {
        return getFixture(User.class, () -> 
            UserTestDataBuilder.aValidUser()
                .withEmail("admin@example.com")
                .withStatus(UserStatus.ADMIN)
                .build());
    }
}
```

### 3. Test Data Cleanup Strategies
Implement proper cleanup patterns:

```java
public abstract class IntegrationTestBase {
    
    @Autowired
    protected TestEntityManager entityManager;
    
    protected List<Object> testEntities = new ArrayList<>();
    
    protected <T> T persistAndTrack(T entity) {
        var persisted = entityManager.persistAndFlush(entity);
        testEntities.add(persisted);
        return persisted;
    }
    
    @AfterEach
    void cleanupTestData() {
        testEntities.forEach(entity -> {
            try {
                entityManager.remove(entity);
            } catch (Exception e) {
                // Entity might already be removed
            }
        });
        testEntities.clear();
        entityManager.flush();
    }
}
```

## Java 11 Specific Enhancements

### 1. Modern Collection Usage
```java
public class UserTestDataBuilder {
    
    public UserTestDataBuilder withRoles(String... roles) {
        this.roles = List.of(roles); // Java 11 immutable collections
        return this;
    }
    
    public UserTestDataBuilder withTags(String... tags) {
        this.tags = Set.of(tags); // Java 11 immutable sets
        return this;
    }
}
```

### 2. String Processing
```java
public class TestDataValidator {
    
    public static boolean isValidEmail(String email) {
        return email != null && 
               !email.isBlank() && // Java 11 string method
               email.contains("@") && 
               !email.strip().isEmpty(); // Java 11 string method
    }
    
    public static List<String> parseMultilineInput(String input) {
        return input.lines() // Java 11 string method
                   .map(String::strip)
                   .filter(line -> !line.isBlank())
                   .collect(Collectors.toList());
    }
}
```

### 3. var Usage in Tests
```java
@Test
void shouldCreateUserWithBuilder() {
    // Use var for improved readability
    var user = UserTestDataBuilder.aUser()
        .withEmail("test@example.com")
        .withName("John", "Doe")
        .build();
    
    var violations = validator.validate(user);
    
    assertThat(violations).isEmpty();
}
```

## Best Practices Summary

### Test Code Refactoring
1. **Extract common setup** into reusable methods
2. **Create assertion utilities** for repetitive validations
3. **Use base classes** for shared functionality
4. **Eliminate duplicate code** across test classes

### Test Data Management
1. **Use hierarchical builders** for complex entities
2. **Implement caching** for expensive test data creation
3. **Create parameterized data** for reusable test scenarios
4. **Version test data** for backward compatibility

### Test Maintenance
1. **Use constants** for default test values
2. **Implement fixture management** for shared test data
3. **Provide cleanup strategies** for test isolation
4. **Document test data evolution** patterns

### Java 11 Integration
1. **Use modern collections** (List.of, Set.of)
2. **Leverage string methods** (isBlank, strip, lines)
3. **Apply var** for improved readability
4. **Use Optional enhancements** where appropriate

This approach ensures maintainable, efficient, and scalable entity testing in Spring Boot 2.7 Java 11 applications.