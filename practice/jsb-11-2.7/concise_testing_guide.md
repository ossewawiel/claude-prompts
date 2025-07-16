# Java 11 Spring Boot 2.7 Entity Unit Testing Best Practices

## Overview
Comprehensive guide for testing Spring Data JPA repositories in Java 11 Spring Boot 2.7 using `@DataJpaTest` for integration testing of the persistence layer.

## Dependencies
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Test Setup
```java
@DataJpaTest
@DisplayName("User Repository Tests")
class UserRepositoryTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    @DisplayName("Should find user by email")
    void shouldFindUser_whenValidEmailProvided() {
        // Given
        User user = User.builder()
            .email("test@example.com")
            .firstName("John")
            .build();
        entityManager.persistAndFlush(user);
        
        // When
        Optional<User> found = userRepository.findByEmail("test@example.com");
        
        // Then
        assertThat(found).isPresent();
        assertThat(found.get().getEmail()).isEqualTo("test@example.com");
    }
}
```

## Testing Philosophy

### Test These:
- ✅ Custom `@Query` methods (JPQL/Native SQL)
- ✅ Complex derived queries with multiple parameters
- ✅ Repository methods with relationships
- ✅ Pagination and sorting
- ✅ Data integrity constraints
- ✅ Bulk operations

### Don't Test These:
- ❌ Simple derived queries (`findByEmail`)
- ❌ Basic CRUD operations from `JpaRepository`
- ❌ JPA framework functionality
- ❌ Entity getters/setters

## Common Patterns

### Custom Query Testing
```java
@Test
void shouldFindActiveUsers_whenStatusActive() {
    // Given
    User activeUser = createUser("active@test.com", "ACTIVE");
    User inactiveUser = createUser("inactive@test.com", "INACTIVE");
    entityManager.persistAndFlush(activeUser);
    entityManager.persistAndFlush(inactiveUser);
    
    // When
    List<User> activeUsers = userRepository.findByStatus("ACTIVE");
    
    // Then
    assertThat(activeUsers).hasSize(1);
    assertThat(activeUsers.get(0).getStatus()).isEqualTo("ACTIVE");
}
```

### Relationship Testing
```java
@Test
void shouldFindUsersWithOrders() {
    // Given
    User user = createUser("user@test.com", "ACTIVE");
    Order order = Order.builder().user(user).amount(100.0).build();
    user.getOrders().add(order);
    entityManager.persistAndFlush(user);
    
    // When
    List<User> usersWithOrders = userRepository.findUsersWithOrders();
    
    // Then
    assertThat(usersWithOrders).hasSize(1);
    assertThat(usersWithOrders.get(0).getOrders()).hasSize(1);
}
```

### Edge Case Testing
```java
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

## Naming Conventions
- **Class**: `{RepositoryName}Test`
- **Method**: `should{ExpectedBehavior}_when{StateUnderTest}`
- **Examples**: `shouldReturnUser_whenValidEmailProvided()`

## Common Pitfalls

### ❌ Wrong - Testing Framework
```java
@Test
void shouldSaveUser() {
    User user = new User("test@example.com");
    User saved = userRepository.save(user);
    assertThat(saved.getId()).isNotNull(); // Tests Spring Data, not your code
}
```

### ✅ Correct - Testing Business Logic
```java
@Test
void shouldFindUsersByCustomQuery() {
    userRepository.findActiveUsersCreatedAfter(LocalDateTime.now().minusDays(30));
    // Test your actual custom query methods
}
```

## Test Configuration
```properties
# src/test/resources/application-test.properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.jpa.show-sql=true
spring.jpa.hibernate.ddl-auto=create-drop
```

## Best Practices Checklist
- [ ] Use `@DataJpaTest` for repository slice testing
- [ ] Test custom queries and complex derived queries
- [ ] Use `TestEntityManager` for test data setup
- [ ] Test edge cases and error scenarios
- [ ] Keep tests independent and isolated
- [ ] Use descriptive test names with `@DisplayName`
- [ ] Focus on business logic, not framework functionality
- [ ] Test relationships and cascading operations

## Test Data Builder Pattern
```java
public class UserTestDataBuilder {
    private String email = "default@test.com";
    private String status = "ACTIVE";
    
    public static UserTestDataBuilder aUser() {
        return new UserTestDataBuilder();
    }
    
    public UserTestDataBuilder withEmail(String email) {
        this.email = email;
        return this;
    }
    
    public UserTestDataBuilder withStatus(String status) {
        this.status = status;
        return this;
    }
    
    public User build() {
        return User.builder()
            .email(email)
            .status(status)
            .createdAt(LocalDateTime.now())
            .build();
    }
}
```

This guide provides focused testing practices for Spring Boot 2.7 repository layer testing with emphasis on business logic verification over framework testing.