# Java 11 Spring Boot 2.7 Repository Interface Unit Testing Best Practices

## 📋 Table of Contents

1. [Overview](#overview)
2. [Testing Philosophy](#testing-philosophy)
3. [Required Dependencies](#required-dependencies)
4. [Test Annotations and Configuration](#test-annotations-and-configuration)
5. [Test Structure and Organization](#test-structure-and-organization)
6. [Naming Conventions](#naming-conventions)
7. [Testing Categories](#testing-categories)
8. [Code Examples](#code-examples)
9. [Database Configuration Options](#database-configuration-options)
10. [Performance and Best Practices](#performance-and-best-practices)
11. [Common Pitfalls](#common-pitfalls)
12. [Tools and IDE Integration](#tools-and-ide-integration)

---

## 🎯 Overview

This document provides comprehensive guidelines for writing effective unit tests for Spring Data JPA repository interfaces in Java 11 Spring Boot 2.7 applications. The focus is on integration testing of the persistence layer using `@DataJpaTest` annotation.

### Key Principles
- **Integration Testing**: Repository tests are integration tests that verify database interactions
- **Slice Testing**: Use `@DataJpaTest` to load only JPA-related components
- **Transactional**: Tests run in transactions that roll back automatically
- **Focused**: Test repository methods, custom queries, and data integrity

### Target Coverage Goals
- **Custom Queries**: 100% coverage for `@Query` annotated methods
- **Complex Derived Queries**: Focus on business-critical finder methods
- **Repository Operations**: Test save, update, delete operations with relationships
- **Data Integrity**: Verify constraints and business rules

---

## 🧠 Testing Philosophy

### What to Test in Repository Interfaces
- ✅ Custom queries with `@Query` annotation (JPQL and Native SQL)
- ✅ Complex derived query methods (multiple parameters, joins)
- ✅ Repository methods that involve relationships (`@OneToMany`, `@ManyToOne`)
- ✅ Pagination and sorting functionality
- ✅ Data integrity constraints and validations
- ✅ Bulk operations (batch updates, deletes)
- ✅ Transaction behavior and rollback scenarios

### What NOT to Test
- ❌ Simple derived queries (Spring Data validates these at startup)
- ❌ Basic CRUD operations inherited from `JpaRepository`
- ❌ JPA framework functionality
- ❌ Entity field getters/setters (test in entity unit tests)

### Testing Strategy
Repository tests should focus on integration testing rather than unit testing, as we need to verify that queries retrieve expected data from a database and that operations maintain database consistency.

---

## 📦 Required Dependencies

### Maven Dependencies (Spring Boot 2.7)
```xml
<dependencies>
    <!-- Spring Boot Starter Test (includes JUnit 5, Mockito, AssertJ) -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- Spring Boot Data JPA -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    
    <!-- H2 Database for Testing -->
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>test</scope>
    </dependency>
    
    <!-- Optional: Testcontainers for real database testing -->
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
    
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>postgresql</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Gradle Dependencies
```gradle
dependencies {
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    testRuntimeOnly 'com.h2database:h2'
    
    // Optional: Testcontainers
    testImplementation 'org.testcontainers:junit-jupiter'
    testImplementation 'org.testcontainers:postgresql'
}
```

---

## 🏗️ Test Annotations and Configuration

### Core Annotation: @DataJpaTest
The `@DataJpaTest` annotation provides standard setup needed for testing the persistence layer, automatically configuring H2 database, scanning for `@Entity` classes, and configuring Spring Data JPA repositories.

```java
@DataJpaTest
class UserRepositoryTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    // Test methods here
}
```

### Key Features of @DataJpaTest
- **Auto-Configuration**: Configures only JPA-related components
- **Embedded Database**: Uses H2 by default for fast, isolated testing
- **Transaction Management**: Each test runs in a transaction that rolls back
- **SQL Logging**: Enables `spring.jpa.show-sql=true` by default
- **TestEntityManager**: Provides alternative to EntityManager for testing

### Additional Configuration Options

#### Disable SQL Logging
```java
@DataJpaTest(showSql = false)
class UserRepositoryTest {
    // Tests without SQL output
}
```

#### Disable Auto-Rollback
```java
@DataJpaTest
@Transactional(propagation = Propagation.NOT_SUPPORTED)
class UserRepositoryTest {
    // Tests without automatic rollback
}
```

#### Use Real Database
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UserRepositoryTest {
    // Tests with actual database configuration
}
```

---

## 🏗️ Test Structure and Organization

### File Organization
```
src/test/java/
├── com/company/project/
│   ├── repository/
│   │   ├── UserRepositoryTest.java
│   │   ├── OrderRepositoryTest.java
│   │   └── ProductRepositoryTest.java
│   ├── testdata/
│   │   ├── UserTestDataBuilder.java
│   │   └── TestDataFactory.java
│   └── config/
│       └── TestConfiguration.java
```

### Test Class Structure
```java
@DataJpaTest
@DisplayName("User Repository Integration Tests")
class UserRepositoryTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    private UserTestDataBuilder userBuilder;
    
    @BeforeEach
    void setUp() {
        userBuilder = UserTestDataBuilder.aUser();
    }
    
    @Nested
    @DisplayName("Save Operations")
    class SaveOperationsTests {
        // Save-related tests
    }
    
    @Nested
    @DisplayName("Find Operations") 
    class FindOperationsTests {
        // Query-related tests
    }
    
    @Nested
    @DisplayName("Custom Queries")
    class CustomQueriesTests {
        // @Query method tests
    }
    
    @Nested
    @DisplayName("Relationship Operations")
    class RelationshipOperationsTests {
        // Relationship-related tests
    }
}
```

---

## 📝 Naming Conventions

### Test Class Naming
- **Pattern**: `{RepositoryName}Test`
- **Examples**: `UserRepositoryTest`, `OrderRepositoryTest`, `CustomerRepositoryTest`

### Test Method Naming
- **Pattern**: `should{ExpectedBehavior}_when{StateUnderTest}`
- **Examples**:
  - `shouldReturnUser_whenValidEmailProvided()`
  - `shouldReturnEmptyOptional_whenEmailNotFound()`
  - `shouldFindActiveUsers_whenStatusIsActive()`
  - `shouldUpdateUserEmail_whenValidDataProvided()`

### Test Data Naming
```java
// Use descriptive variable names
User expectedUser = userBuilder.withEmail("test@example.com").build();
User savedUser = userRepository.save(expectedUser);

// Constants for test data
private static final String VALID_EMAIL = "test@example.com";
private static final String INVALID_EMAIL = "invalid@domain";
private static final String NON_EXISTENT_EMAIL = "notfound@example.com";
```

---

## 🧪 Testing Categories

### 1. Basic Repository Operations Tests

#### Save Operations
```java
@Nested
@DisplayName("Save Operations")
class SaveOperationsTests {
    
    @Test
    @DisplayName("Should save user and generate ID")
    void shouldSaveUserAndGenerateId() {
        // Given
        User user = userBuilder
            .withEmail("john@example.com")
            .withFirstName("John")
            .withLastName("Doe")
            .build();
        
        // When
        User savedUser = userRepository.save(user);
        
        // Then
        assertThat(savedUser.getId()).isNotNull();
        assertThat(savedUser.getEmail()).isEqualTo("john@example.com");
        assertThat(savedUser.getFirstName()).isEqualTo("John");
    }
    
    @Test
    @DisplayName("Should update existing user")
    void shouldUpdateExistingUser() {
        // Given
        User user = userBuilder.withEmail("john@example.com").build();
        User savedUser = entityManager.persistAndFlush(user);
        
        // When
        savedUser.setFirstName("Jane");
        User updatedUser = userRepository.save(savedUser);
        
        // Then
        assertThat(updatedUser.getId()).isEqualTo(savedUser.getId());
        assertThat(updatedUser.getFirstName()).isEqualTo("Jane");
    }
}
```

#### Find Operations
```java
@Nested
@DisplayName("Find Operations")
class FindOperationsTests {
    
    @Test
    @DisplayName("Should find user by email when exists")
    void shouldFindUserByEmail_whenExists() {
        // Given
        User user = userBuilder.withEmail("john@example.com").build();
        entityManager.persistAndFlush(user);
        
        // When
        Optional<User> found = userRepository.findByEmail("john@example.com");
        
        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("john@example.com");
    }
    
    @Test
    @DisplayName("Should return empty when email not found")
    void shouldReturnEmpty_whenEmailNotFound() {
        // When
        Optional<User> found = userRepository.findByEmail("nonexistent@example.com");
        
        // Then
        assertThat(found).isEmpty();
    }
    
    @Test
    @DisplayName("Should find all active users")
    void shouldFindAllActiveUsers() {
        // Given
        User activeUser1 = userBuilder.withEmail("active1@example.com").withStatus("ACTIVE").build();
        User activeUser2 = userBuilder.withEmail("active2@example.com").withStatus("ACTIVE").build();
        User inactiveUser = userBuilder.withEmail("inactive@example.com").withStatus("INACTIVE").build();
        
        entityManager.persist(activeUser1);
        entityManager.persist(activeUser2);
        entityManager.persist(inactiveUser);
        entityManager.flush();
        
        // When
        List<User> activeUsers = userRepository.findByStatus("ACTIVE");
        
        // Then
        assertThat(activeUsers).hasSize(2);
        assertThat(activeUsers)
            .extracting(User::getEmail)
            .containsExactlyInAnyOrder("active1@example.com", "active2@example.com");
    }
}
```

### 2. Custom Query Tests

#### JPQL Queries
```java
@Nested
@DisplayName("Custom JPQL Queries")
class CustomJpqlQueriesTests {
    
    @Test
    @DisplayName("Should find users by first and last name using JPQL")
    void shouldFindUsersByFirstAndLastName_usingJpql() {
        // Given
        User user = userBuilder
            .withFirstName("John")
            .withLastName("Doe")
            .withEmail("john.doe@example.com")
            .build();
        entityManager.persistAndFlush(user);
        
        // When
        User found = userRepository.findByFirstNameAndLastName("John", "Doe");
        
        // Then
        assertThat(found).isNotNull();
        assertThat(found.getEmail()).isEqualTo("john.doe@example.com");
    }
    
    @Test
    @DisplayName("Should find users created in date range")
    void shouldFindUsersCreatedInDateRange() {
        // Given
        LocalDateTime startDate = LocalDateTime.now().minusDays(7);
        LocalDateTime endDate = LocalDateTime.now();
        
        User recentUser = userBuilder
            .withEmail("recent@example.com")
            .withCreatedAt(LocalDateTime.now().minusDays(3))
            .build();
        User oldUser = userBuilder
            .withEmail("old@example.com")
            .withCreatedAt(LocalDateTime.now().minusDays(30))
            .build();
        
        entityManager.persist(recentUser);
        entityManager.persist(oldUser);
        entityManager.flush();
        
        // When
        List<User> usersInRange = userRepository.findUsersCreatedBetween(startDate, endDate);
        
        // Then
        assertThat(usersInRange).hasSize(1);
        assertThat(usersInRange.get(0).getEmail()).isEqualTo("recent@example.com");
    }
}
```

#### Native SQL Queries
```java
@Test
@DisplayName("Should count users by domain using native SQL")
void shouldCountUsersByDomain_usingNativeSQL() {
    // Given
    User companyUser1 = userBuilder.withEmail("john@company.com").build();
    User companyUser2 = userBuilder.withEmail("jane@company.com").build();
    User externalUser = userBuilder.withEmail("bob@external.com").build();
    
    entityManager.persist(companyUser1);
    entityManager.persist(companyUser2);
    entityManager.persist(externalUser);
    entityManager.flush();
    
    // When
    Long count = userRepository.countUsersByEmailDomain("company.com");
    
    // Then
    assertThat(count).isEqualTo(2L);
}
```

### 3. Pagination and Sorting Tests

```java
@Nested
@DisplayName("Pagination and Sorting")
class PaginationAndSortingTests {
    
    @Test
    @DisplayName("Should return paginated users sorted by email")
    void shouldReturnPaginatedUsersSortedByEmail() {
        // Given
        List<User> users = Arrays.asList(
            userBuilder.withEmail("charlie@example.com").build(),
            userBuilder.withEmail("alice@example.com").build(),
            userBuilder.withEmail("bob@example.com").build()
        );
        
        users.forEach(user -> entityManager.persist(user));
        entityManager.flush();
        
        // When
        Pageable pageable = PageRequest.of(0, 2, Sort.by("email"));
        Page<User> page = userRepository.findAll(pageable);
        
        // Then
        assertThat(page.getTotalElements()).isEqualTo(3);
        assertThat(page.getContent()).hasSize(2);
        assertThat(page.getContent().get(0).getEmail()).isEqualTo("alice@example.com");
        assertThat(page.getContent().get(1).getEmail()).isEqualTo("bob@example.com");
    }
    
    @Test
    @DisplayName("Should find active users with pagination")
    void shouldFindActiveUsersWithPagination() {
        // Given
        for (int i = 1; i <= 5; i++) {
            User user = userBuilder
                .withEmail("user" + i + "@example.com")
                .withStatus("ACTIVE")
                .build();
            entityManager.persist(user);
        }
        entityManager.flush();
        
        // When
        Pageable pageable = PageRequest.of(0, 3);
        Page<User> page = userRepository.findByStatus("ACTIVE", pageable);
        
        // Then
        assertThat(page.getTotalElements()).isEqualTo(5);
        assertThat(page.getContent()).hasSize(3);
        assertThat(page.hasNext()).isTrue();
    }
}
```

### 4. Relationship Tests

```java
@Nested
@DisplayName("Relationship Operations")
class RelationshipOperationsTests {
    
    @Test
    @DisplayName("Should save user with orders")
    void shouldSaveUserWithOrders() {
        // Given
        User user = userBuilder.withEmail("customer@example.com").build();
        Order order1 = orderBuilder.withAmount(BigDecimal.valueOf(100.00)).build();
        Order order2 = orderBuilder.withAmount(BigDecimal.valueOf(150.00)).build();
        
        user.addOrder(order1);
        user.addOrder(order2);
        
        // When
        User savedUser = userRepository.save(user);
        entityManager.flush();
        entityManager.clear(); // Clear persistence context
        
        // Then
        User foundUser = userRepository.findById(savedUser.getId()).orElseThrow();
        assertThat(foundUser.getOrders()).hasSize(2);
        assertThat(foundUser.getOrders())
            .extracting(Order::getAmount)
            .containsExactlyInAnyOrder(BigDecimal.valueOf(100.00), BigDecimal.valueOf(150.00));
    }
    
    @Test
    @DisplayName("Should find users with orders above amount")
    void shouldFindUsersWithOrdersAboveAmount() {
        // Given
        User userWithHighOrder = userBuilder.withEmail("rich@example.com").build();
        Order highOrder = orderBuilder.withAmount(BigDecimal.valueOf(1000.00)).build();
        userWithHighOrder.addOrder(highOrder);
        
        User userWithLowOrder = userBuilder.withEmail("poor@example.com").build();
        Order lowOrder = orderBuilder.withAmount(BigDecimal.valueOf(50.00)).build();
        userWithLowOrder.addOrder(lowOrder);
        
        entityManager.persist(userWithHighOrder);
        entityManager.persist(userWithLowOrder);
        entityManager.flush();
        
        // When
        List<User> users = userRepository.findUsersWithOrdersAbove(BigDecimal.valueOf(500.00));
        
        // Then
        assertThat(users).hasSize(1);
        assertThat(users.get(0).getEmail()).isEqualTo("rich@example.com");
    }
}
```

### 5. Constraint and Validation Tests

```java
@Nested
@DisplayName("Constraint Validation")
class ConstraintValidationTests {
    
    @Test
    @DisplayName("Should throw exception when saving user with duplicate email")
    void shouldThrowException_whenSavingUserWithDuplicateEmail() {
        // Given
        User user1 = userBuilder.withEmail("duplicate@example.com").build();
        User user2 = userBuilder.withEmail("duplicate@example.com").build();
        
        userRepository.save(user1);
        entityManager.flush();
        
        // When & Then
        assertThatThrownBy(() -> {
            userRepository.save(user2);
            entityManager.flush();
        }).isInstanceOf(DataIntegrityViolationException.class);
    }
    
    @Test
    @DisplayName("Should check if email exists")
    void shouldCheckIfEmailExists() {
        // Given
        User user = userBuilder.withEmail("existing@example.com").build();
        entityManager.persistAndFlush(user);
        
        // When & Then
        assertThat(userRepository.existsByEmail("existing@example.com")).isTrue();
        assertThat(userRepository.existsByEmail("nonexistent@example.com")).isFalse();
    }
}
```

---

## 🗄️ Database Configuration Options

### Option 1: H2 In-Memory Database (Default)
```java
@DataJpaTest
class UserRepositoryTest {
    // Uses H2 automatically - fastest option
}
```

**Pros**: Fast, isolated, no setup required
**Cons**: May not catch database-specific issues

### Option 2: Real Database with Testcontainers
```java
@DataJpaTest
@Testcontainers
class UserRepositoryIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
    
    // Test methods here
}
```

**Pros**: Tests against actual database, catches database-specific issues
**Cons**: Slower, requires Docker

### Option 3: Shared Test Database
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:postgresql://localhost:5432/test_db",
    "spring.datasource.username=test",
    "spring.datasource.password=test"
})
class UserRepositoryTest {
    // Uses configured database
}
```

**Pros**: Realistic testing environment
**Cons**: Requires database setup, potential test interference

---

## ⚡ Performance and Best Practices

### 1. Use TestEntityManager Effectively
TestEntityManager provides a subset of EntityManager methods useful for tests and helper methods for common testing tasks such as persist or find.

```java
@Test
void shouldTestWithOptimalEntityManager() {
    // Given - Use entityManager for test data setup
    User user = userBuilder.withEmail("test@example.com").build();
    entityManager.persistAndFlush(user); // Synchronize with database
    entityManager.clear(); // Clear persistence context
    
    // When - Test the repository method
    Optional<User> found = userRepository.findByEmail("test@example.com");
    
    // Then
    assertThat(found).isPresent();
}
```

### 2. Optimize Test Data Creation
```java
// Use @Sql for complex test data
@Test
@Sql("/test-data/users-with-orders.sql")
void shouldTestComplexScenario() {
    // Test with pre-loaded data
    List<User> users = userRepository.findUsersWithMultipleOrders();
    assertThat(users).isNotEmpty();
}

// Use TestDataBuilder for simple cases
@Test
void shouldTestSimpleScenario() {
    User user = userBuilder.withRandomData().build();
    entityManager.persistAndFlush(user);
    // Test logic
}
```

### 3. Test Performance Characteristics
```java
@Test
@DisplayName("Should perform bulk operations efficiently")
void shouldPerformBulkOperationsEfficiently() {
    // Given
    List<User> users = createLargeUserList(1000);
    
    // When
    long startTime = System.currentTimeMillis();
    userRepository.saveAll(users);
    long endTime = System.currentTimeMillis();
    
    // Then
    assertThat(endTime - startTime).isLessThan(5000); // 5 seconds max
    assertThat(userRepository.count()).isEqualTo(1000);
}
```

### 4. Verify SQL Query Generation
```java
@Test
@Sql(statements = "SET GLOBAL general_log = 'ON'") // MySQL example
void shouldGenerateOptimalQuery() {
    // Enable SQL logging to verify query performance
    userRepository.findUsersWithOrdersAbove(BigDecimal.valueOf(100));
    
    // Verify through logs that expected joins are used
    // Or use query counters in tests
}
```

---

## ⚠️ Common Pitfalls

### 1. Not Clearing Persistence Context
```java
// ❌ WRONG - May get cached entities
@Test
void wrongWayToTest() {
    User user = entityManager.persist(new User("test@example.com"));
    
    Optional<User> found = userRepository.findByEmail("test@example.com");
    // This might return cached entity, not test actual repository query
}

// ✅ CORRECT - Clear context to force database query
@Test
void correctWayToTest() {
    User user = entityManager.persistAndFlush(new User("test@example.com"));
    entityManager.clear(); // Force fresh fetch from database
    
    Optional<User> found = userRepository.findByEmail("test@example.com");
    // Now we're testing actual repository behavior
}
```

### 2. Testing Framework Methods
```java
// ❌ WRONG - Testing Spring Data framework
@Test
void shouldSaveUser() {
    User user = new User("test@example.com");
    User saved = userRepository.save(user);
    assertThat(saved.getId()).isNotNull();
}

// ✅ CORRECT - Testing business logic
@Test
void shouldFindUsersByCustomQuery() {
    // Test your custom query methods instead
    userRepository.findActiveUsersCreatedAfter(LocalDateTime.now().minusDays(30));
}
```

### 3. Ignoring Transaction Boundaries
```java
// ❌ WRONG - Assuming data persists across test methods
@Test
void testMethod1() {
    userRepository.save(new User("test@example.com"));
    // Data will be rolled back after this test
}

@Test
void testMethod2() {
    Optional<User> user = userRepository.findByEmail("test@example.com");
    // This will be empty - previous test data was rolled back
}

// ✅ CORRECT - Each test is independent
@Test
void testMethod() {
    // Setup data within each test
    User user = entityManager.persistAndFlush(new User("test@example.com"));
    
    // Perform test
    Optional<User> found = userRepository.findByEmail("test@example.com");
    assertThat(found).isPresent();
}
```

### 4. Not Testing Edge Cases
```java
// ✅ Test edge cases
@ParameterizedTest
@ValueSource(strings = {"", " ", "invalid-email", "test@", "@domain.com"})
void shouldHandleInvalidEmailFormats(String invalidEmail) {
    Optional<User> found = userRepository.findByEmail(invalidEmail);
    assertThat(found).isEmpty();
}

@Test
void shouldHandleNullParameters() {
    assertThatThrownBy(() -> userRepository.findByEmail(null))
        .isInstanceOf(IllegalArgumentException.class);
}
```

---

## 🛠️ Tools and IDE Integration

### Maven Configuration
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.7</version>
    <configuration>
        <excludes>
            <exclude>**/entity/**</exclude>
            <exclude>**/config/**</exclude>
        </excludes>
    </configuration>
</plugin>
```

### Test Properties Configuration
```properties
# src/test/resources/application-test.properties

# H2 Configuration
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

# Show SQL queries
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# DDL Configuration
spring.jpa.hibernate.ddl-auto=create-drop

# Disable Flyway/Liquibase in tests
spring.flyway.enabled=false
spring.liquibase.enabled=false
```

### Useful Test Utilities
```java
@Component
public class TestDataFactory {
    
    public User createRandomUser() {
        return User.builder()
            .email(generateRandomEmail())
            .firstName(generateRandomName())
            .lastName(generateRandomName())
            .status("ACTIVE")
            .createdAt(LocalDateTime.now())
            .build();
    }
    
    public List<User> createUsers(int count) {
        return IntStream.range(0, count)
            .mapToObj(i -> createRandomUser())
            .collect(Collectors.toList());
    }
    
    private String generateRandomEmail() {
        return "user" + UUID.randomUUID().toString().substring(0, 8) + "@test.com";
    }
}
```

---

## ✅ Best Practices Checklist

### Test Organization
- [ ] **Test Structure**: Use `@Nested` classes for logical grouping
- [ ] **Naming**: Follow consistent naming conventions
- [ ] **Data Setup**: Use `@BeforeEach` for common test data setup
- [ ] **Clean Tests**: Each test should be independent and isolated

### Repository Testing
- [ ] **Custom Queries**: Test all `@Query` annotated methods
- [ ] **Edge Cases**: Test null parameters, empty results, constraints
- [ ] **Relationships**: Test entity relationships and cascading
- [ ] **Pagination**: Test pagination and sorting behavior
- [ ] **Performance**: Test bulk operations and query efficiency

### Technical Implementation
- [ ] **TestEntityManager**: Use for test data setup and verification
- [ ] **Clear Context**: Clear persistence context when testing queries
- [ ] **Transaction Isolation**: Ensure tests don't interfere with each other
- [ ] **Database Choice**: Choose appropriate database for test scenarios

### Code Quality
- [ ] **Coverage**: Achieve target coverage for repository methods
- [ ] **Assertions**: Use AssertJ for fluent, readable assertions
- [ ] **Documentation**: Add meaningful test descriptions with `@DisplayName`
- [ ] **Maintainability**: Keep tests simple and focused

This comprehensive guide provides the foundation for writing effective repository layer tests in Spring Boot 2.7 applications.

---

## 📚 Advanced Testing Patterns

### 1. Testing Repository Specifications
When using JPA Criteria API with Spring Data JPA Specifications:

```java
@Nested
@DisplayName("Specification Tests")
class SpecificationTests {
    
    @Test
    @DisplayName("Should find users by complex criteria using specifications")
    void shouldFindUsersByComplexCriteria() {
        // Given
        User activeUser = userBuilder
            .withEmail("active@example.com")
            .withStatus("ACTIVE")
            .withCreatedAt(LocalDateTime.now().minusDays(5))
            .build();
        User inactiveUser = userBuilder
            .withEmail("inactive@example.com")
            .withStatus("INACTIVE")
            .withCreatedAt(LocalDateTime.now().minusDays(5))
            .build();
        
        entityManager.persist(activeUser);
        entityManager.persist(inactiveUser);
        entityManager.flush();
        
        // When
        Specification<User> spec = Specification
            .where(UserSpecifications.hasStatus("ACTIVE"))
            .and(UserSpecifications.createdAfter(LocalDateTime.now().minusDays(7)));
        
        List<User> users = userRepository.findAll(spec);
        
        // Then
        assertThat(users).hasSize(1);
        assertThat(users.get(0).getEmail()).isEqualTo("active@example.com");
    }
}
```

### 2. Testing Repository with @Modifying Queries
For bulk update and delete operations:

```java
@Nested
@DisplayName("Bulk Operations")
class BulkOperationsTests {
    
    @Test
    @DisplayName("Should update user status in bulk")
    void shouldUpdateUserStatusInBulk() {
        // Given
        List<User> users = Arrays.asList(
            userBuilder.withEmail("user1@example.com").withStatus("INACTIVE").build(),
            userBuilder.withEmail("user2@example.com").withStatus("INACTIVE").build(),
            userBuilder.withEmail("user3@example.com").withStatus("ACTIVE").build()
        );
        
        users.forEach(user -> entityManager.persist(user));
        entityManager.flush();
        entityManager.clear();
        
        // When
        int updatedCount = userRepository.updateStatusForInactiveUsers("ACTIVE");
        
        // Then
        assertThat(updatedCount).isEqualTo(2);
        
        // Verify the updates
        List<User> activeUsers = userRepository.findByStatus("ACTIVE");
        assertThat(activeUsers).hasSize(3);
    }
    
    @Test
    @DisplayName("Should delete users created before date")
    void shouldDeleteUsersCreatedBeforeDate() {
        // Given
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(30);
        
        User oldUser = userBuilder
            .withEmail("old@example.com")
            .withCreatedAt(cutoffDate.minusDays(10))
            .build();
        User newUser = userBuilder
            .withEmail("new@example.com")
            .withCreatedAt(cutoffDate.plusDays(10))
            .build();
        
        entityManager.persist(oldUser);
        entityManager.persist(newUser);
        entityManager.flush();
        
        // When
        int deletedCount = userRepository.deleteUsersCreatedBefore(cutoffDate);
        
        // Then
        assertThat(deletedCount).isEqualTo(1);
        assertThat(userRepository.findByEmail("old@example.com")).isEmpty();
        assertThat(userRepository.findByEmail("new@example.com")).isPresent();
    }
}
```

### 3. Testing Repository Projections
For DTO projections and interface-based projections:

```java
@Nested
@DisplayName("Projection Tests")
class ProjectionTests {
    
    @Test
    @DisplayName("Should return user summary projections")
    void shouldReturnUserSummaryProjections() {
        // Given
        User user = userBuilder
            .withEmail("john@example.com")
            .withFirstName("John")
            .withLastName("Doe")
            .build();
        entityManager.persistAndFlush(user);
        
        // When
        List<UserSummary> summaries = userRepository.findUserSummaries();
        
        // Then
        assertThat(summaries).hasSize(1);
        UserSummary summary = summaries.get(0);
        assertThat(summary.getFullName()).isEqualTo("John Doe");
        assertThat(summary.getEmail()).isEqualTo("john@example.com");
    }
    
    @Test
    @DisplayName("Should return user statistics")
    void shouldReturnUserStatistics() {
        // Given
        setupUserStatisticsTestData();
        
        // When
        UserStatistics stats = userRepository.getUserStatistics();
        
        // Then
        assertThat(stats.getTotalUsers()).isEqualTo(10);
        assertThat(stats.getActiveUsers()).isEqualTo(7);
        assertThat(stats.getInactiveUsers()).isEqualTo(3);
    }
    
    private void setupUserStatisticsTestData() {
        for (int i = 1; i <= 7; i++) {
            User user = userBuilder
                .withEmail("active" + i + "@example.com")
                .withStatus("ACTIVE")
                .build();
            entityManager.persist(user);
        }
        
        for (int i = 1; i <= 3; i++) {
            User user = userBuilder
                .withEmail("inactive" + i + "@example.com")
                .withStatus("INACTIVE")
                .build();
            entityManager.persist(user);
        }
        entityManager.flush();
    }
}
```

### 4. Testing Repository with Custom Implementations
For repositories with custom implementation classes:

```java
@Nested
@DisplayName("Custom Implementation Tests")
class CustomImplementationTests {
    
    @Test
    @DisplayName("Should perform complex search with custom implementation")
    void shouldPerformComplexSearchWithCustomImplementation() {
        // Given
        setupComplexSearchTestData();
        
        UserSearchCriteria criteria = UserSearchCriteria.builder()
            .emailDomain("company.com")
            .statusList(Arrays.asList("ACTIVE", "PENDING"))
            .createdAfter(LocalDateTime.now().minusDays(30))
            .hasOrders(true)
            .build();
        
        // When
        List<User> results = userRepository.findByCriteria(criteria);
        
        // Then
        assertThat(results).hasSize(2);
        assertThat(results)
            .allMatch(user -> user.getEmail().endsWith("company.com"))
            .allMatch(user -> Arrays.asList("ACTIVE", "PENDING").contains(user.getStatus()));
    }
}
```

---

## 🧪 Testing Strategies for Different Scenarios

### 1. Testing Repository Inheritance
```java
// Base repository interface
interface BaseRepository<T, ID> extends JpaRepository<T, ID> {
    List<T> findByStatus(String status);
}

// Specific repository
interface UserRepository extends BaseRepository<User, Long> {
    Optional<User> findByEmail(String email);
}

// Test both inherited and specific methods
@Test
@DisplayName("Should test inherited methods")
void shouldTestInheritedMethods() {
    // Test the inherited findByStatus method
    User user = userBuilder.withStatus("ACTIVE").build();
    entityManager.persistAndFlush(user);
    
    List<User> activeUsers = userRepository.findByStatus("ACTIVE");
    assertThat(activeUsers).hasSize(1);
}
```

### 2. Testing Repository with Auditing
```java
@Test
@DisplayName("Should populate audit fields automatically")
void shouldPopulateAuditFieldsAutomatically() {
    // Given
    User user = userBuilder.withEmail("audit@example.com").build();
    
    // When
    User savedUser = userRepository.save(user);
    entityManager.flush();
    
    // Then
    assertThat(savedUser.getCreatedDate()).isNotNull();
    assertThat(savedUser.getCreatedBy()).isNotNull();
    assertThat(savedUser.getLastModifiedDate()).isNotNull();
    assertThat(savedUser.getLastModifiedBy()).isNotNull();
}
```

### 3. Testing Repository with Soft Deletes
```java
@Test
@DisplayName("Should soft delete user and exclude from queries")
void shouldSoftDeleteUserAndExcludeFromQueries() {
    // Given
    User user = userBuilder.withEmail("delete@example.com").build();
    User savedUser = userRepository.save(user);
    entityManager.flush();
    
    // When
    userRepository.softDelete(savedUser.getId());
    entityManager.flush();
    entityManager.clear();
    
    // Then
    Optional<User> found = userRepository.findByEmail("delete@example.com");
    assertThat(found).isEmpty(); // Should not find soft-deleted user
    
    Optional<User> foundIncludingDeleted = userRepository.findByEmailIncludingDeleted("delete@example.com");
    assertThat(foundIncludingDeleted).isPresent();
    assertThat(foundIncludingDeleted.get().isDeleted()).isTrue();
}
```

---

## 🎯 Repository Testing Anti-Patterns to Avoid

### 1. Over-Testing Simple Queries
```java
// ❌ AVOID - Testing derived queries that Spring Data validates
@Test
void shouldFindByEmail() {
    // Spring Data already validates this at startup
    userRepository.findByEmail("test@example.com");
}

// ✅ PREFER - Testing complex business logic
@Test
void shouldFindActiveUsersWithRecentOrders() {
    // Test complex queries that involve business logic
    userRepository.findActiveUsersWithOrdersAfter(LocalDateTime.now().minusDays(30));
}
```

### 2. Testing Implementation Details
```java
// ❌ AVOID - Testing how Spring Data implements the query
@Test
void shouldCallEntityManagerFind() {
    // Don't test Spring Data's internal implementation
}

// ✅ PREFER - Testing the business outcome
@Test
void shouldReturnUserWhenValidIdProvided() {
    // Test what the method accomplishes, not how
}
```

### 3. Not Testing Exceptional Cases
```java
// ❌ INCOMPLETE - Only testing happy path
@Test
void shouldFindUser() {
    User user = userRepository.findByEmail("existing@example.com");
    assertThat(user).isNotNull();
}

// ✅ COMPLETE - Testing both success and failure cases
@Test
void shouldFindExistingUser() {
    // Setup existing user
    Optional<User> user = userRepository.findByEmail("existing@example.com");
    assertThat(user).isPresent();
}

@Test
void shouldReturnEmptyForNonExistentUser() {
    Optional<User> user = userRepository.findByEmail("nonexistent@example.com");
    assertThat(user).isEmpty();
}
```

---

## 📊 Test Data Management Strategies

### 1. Using @Sql for Complex Scenarios
```java
@Test
@Sql("/test-data/users-with-complex-relationships.sql")
@DisplayName("Should handle complex data relationships")
void shouldHandleComplexDataRelationships() {
    // Test with pre-loaded complex data
    List<User> usersWithMultipleRoles = userRepository.findUsersWithMultipleRoles();
    assertThat(usersWithMultipleRoles).isNotEmpty();
}
```

### 2. Using @SqlConfig for Custom Configuration
```java
@Test
@Sql(
    scripts = "/test-data/large-dataset.sql",
    config = @SqlConfig(
        encoding = "UTF-8",
        separator = "@@",
        commentPrefix = "--"
    )
)
void shouldHandleLargeDataset() {
    // Test with large dataset
}
```

### 3. Programmatic Test Data Creation
```java
@Component
public class RepositoryTestDataBuilder {
    
    public void createUserHierarchy(TestEntityManager entityManager) {
        // Create manager
        User manager = User.builder()
            .email("manager@example.com")
            .role("MANAGER")
            .build();
        entityManager.persist(manager);
        
        // Create employees reporting to manager
        for (int i = 1; i <= 5; i++) {
            User employee = User.builder()
                .email("employee" + i + "@example.com")
                .role("EMPLOYEE")
                .manager(manager)
                .build();
            entityManager.persist(employee);
        }
        
        entityManager.flush();
    }
}
```

---

## 🔧 Advanced Configuration and Customization

### 1. Custom Test Configuration
```java
@TestConfiguration
public class RepositoryTestConfig {
    
    @Bean
    @Primary
    public Clock testClock() {
        // Fixed clock for consistent test results
        return Clock.fixed(
            Instant.parse("2023-01-01T10:00:00Z"),
            ZoneId.systemDefault()
        );
    }
    
    @Bean
    public AuditorAware<String> auditorProvider() {
        return () -> Optional.of("test-user");
    }
}
```

### 2. Custom Test Slices
```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@DataJpaTest
@Import(RepositoryTestConfig.class)
@TestPropertySource(properties = {
    "spring.jpa.show-sql=true",
    "logging.level.org.hibernate.SQL=DEBUG"
})
public @interface CustomRepositoryTest {
}

// Usage
@CustomRepositoryTest
class UserRepositoryTest {
    // Your test class automatically gets custom configuration
}
```

### 3. Test Profiles for Different Databases
```yaml
# application-test-h2.yml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect

---
# application-test-postgres.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/testdb
    username: test
    password: test
  jpa:
    database-platform: org.hibernate.dialect.PostgreSQL10Dialect
```

---

## 📈 Monitoring and Metrics in Tests

### 1. Performance Testing
```java
@Test
@DisplayName("Should perform repository operations within acceptable time limits")
void shouldPerformOperationsWithinTimeLimit() {
    // Given
    int userCount = 1000;
    List<User> users = createLargeUserList(userCount);
    
    // When - Test batch save performance
    StopWatch stopWatch = new StopWatch();
    stopWatch.start();
    
    List<User> savedUsers = userRepository.saveAll(users);
    entityManager.flush();
    
    stopWatch.stop();
    
    // Then
    assertThat(savedUsers).hasSize(userCount);
    assertThat(stopWatch.getTotalTimeMillis()).isLessThan(5000); // 5 seconds max
    
    // Test query performance
    stopWatch = new StopWatch();
    stopWatch.start();
    
    List<User> foundUsers = userRepository.findByStatus("ACTIVE");
    
    stopWatch.stop();
    
    assertThat(stopWatch.getTotalTimeMillis()).isLessThan(1000); // 1 second max
}
```

### 2. SQL Query Counting
```java
@Test
@DisplayName("Should execute optimal number of SQL queries")
void shouldExecuteOptimalNumberOfQueries() {
    // Setup query counter (using custom implementation or library like Hibernate Statistics)
    QueryCountHolder.clear();
    
    // When
    List<User> users = userRepository.findUsersWithOrdersAndAddresses();
    
    // Force lazy loading
    users.forEach(user -> {
        user.getOrders().size();
        user.getAddresses().size();
    });
    
    // Then
    assertThat(QueryCountHolder.getCount()).isLessThanOrEqualTo(3); // 1 for users + 2 for collections
}
```

---

## 🎓 Testing Best Practices Summary

### Repository Testing Pyramid
1. **Unit Tests**: Entity validation, business logic methods
2. **Integration Tests**: Repository methods with `@DataJpaTest`
3. **End-to-End Tests**: Full application flow with real database

### Test Naming and Organization
- Use descriptive test names that explain business scenarios
- Group related tests with `@Nested` classes
- Use `@DisplayName` for better test reporting
- Follow the Given-When-Then pattern consistently

### Data Management
- Use `TestEntityManager` for test data setup
- Clear persistence context when testing queries
- Use `@Sql` for complex test scenarios
- Create reusable test data builders

### Performance Considerations
- Keep tests fast by using H2 for most scenarios
- Use Testcontainers only when database-specific testing is needed
- Monitor query count and execution time in performance-critical tests
- Use `@Transactional` rollback for test isolation

### Quality Assurance
- Achieve high test coverage for custom repository methods
- Test edge cases and error scenarios
- Verify constraint violations and data integrity
- Test pagination, sorting, and complex queries thoroughly

This comprehensive guide provides everything needed to implement effective repository testing in Spring Boot 2.7 applications, ensuring robust and maintainable persistence layer code.