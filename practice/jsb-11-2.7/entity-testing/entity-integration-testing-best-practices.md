# Entity Integration Testing Best Practices - Spring Boot 2.7 Java 11

## Overview
This document provides specific guidance for integration testing JPA entity classes in Spring Boot 2.7 applications, focusing on database persistence, repository operations, and entity relationships.

**Cross-References:**
- [Entity Unit Testing Best Practices](entity-unit-testing-best-practices.md) - Unit testing patterns
- [Entity Test Refactoring and Data Management](entity-test-refactoring-and-data-management.md) - Test data builders and refactoring patterns

## Test Framework Setup

For complete dependencies setup including integration testing dependencies (H2, TestContainers), see [Entity Test Refactoring and Data Management](entity-test-refactoring-and-data-management.md#dependencies-and-setup).

### Test Class Structure
```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class UserEntityIntegrationTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    @Nested
    @DisplayName("Entity Persistence Tests")
    class EntityPersistenceTests {
        // Persistence tests here
    }
    
    @Nested
    @DisplayName("Repository Query Tests")
    class RepositoryQueryTests {
        // Repository tests here
    }
    
    @Nested
    @DisplayName("Entity Relationship Tests")
    class EntityRelationshipTests {
        // Relationship tests here
    }
}
```

## Core Testing Areas

### 1. Basic Entity Persistence
Test save, update, and delete operations:

```java
@Test
@DisplayName("Should persist entity to database")
void shouldPersistEntityToDatabase() {
    var user = User.builder().email("john.doe@example.com").firstName("John").lastName("Doe").build();
    var savedUser = userRepository.save(user);
    entityManager.flush();
    
    assertThat(savedUser.getId()).isNotNull();
    assertThat(savedUser.getCreatedAt()).isNotNull();
    
    var foundUser = entityManager.find(User.class, savedUser.getId());
    assertThat(foundUser).isNotNull();
    assertThat(foundUser.getEmail()).isEqualTo("john.doe@example.com");
}

@Test
@DisplayName("Should update existing entity")
void shouldUpdateExistingEntity() {
    // Given
    var user = User.builder()
        .email("john.doe@example.com")
        .firstName("John")
        .lastName("Doe")
        .build();
    var savedUser = entityManager.persistAndFlush(user);
    
    // When
    savedUser.setFirstName("Jane");
    var updatedUser = userRepository.save(savedUser);
    entityManager.flush();
    
    // Then
    assertThat(updatedUser.getFirstName()).isEqualTo("Jane");
    assertThat(updatedUser.getUpdatedAt()).isNotNull();
}
```

### 2. Database Constraints Testing
Test unique constraints, foreign keys, and database-level validations:

```java
@Test
@DisplayName("Should enforce unique email constraint")
void shouldEnforceUniqueEmailConstraint() {
    // Given
    var user1 = User.builder()
        .email("duplicate@example.com")
        .firstName("John")
        .lastName("Doe")
        .build();
    var user2 = User.builder()
        .email("duplicate@example.com")
        .firstName("Jane")
        .lastName("Smith")
        .build();
    
    // When
    entityManager.persistAndFlush(user1);
    
    // Then
    assertThatThrownBy(() -> {
        entityManager.persistAndFlush(user2);
    }).isInstanceOf(PersistenceException.class);
}

@Test
@DisplayName("Should enforce not null constraint")
void shouldEnforceNotNullConstraint() {
    // Given
    var user = User.builder()
        .firstName("John")
        .lastName("Doe")
        // email is null
        .build();
    
    // When & Then
    assertThatThrownBy(() -> {
        entityManager.persistAndFlush(user);
    }).isInstanceOf(ConstraintViolationException.class);
}
```

### 3. Entity Lifecycle Events Testing
Test @PrePersist, @PreUpdate, @PostLoad callbacks:

```java
@Test
@DisplayName("Should trigger pre-persist callback")
void shouldTriggerPrePersistCallback() {
    // Given
    var user = User.builder()
        .email("test@example.com")
        .firstName("John")
        .lastName("Doe")
        .build();
    
    // When
    var savedUser = entityManager.persistAndFlush(user);
    
    // Then
    assertThat(savedUser.getCreatedAt()).isNotNull();
    assertThat(savedUser.getCreatedAt()).isBeforeOrEqualTo(LocalDateTime.now());
}

@Test
@DisplayName("Should trigger pre-update callback")
void shouldTriggerPreUpdateCallback() {
    // Given
    var user = User.builder()
        .email("test@example.com")
        .firstName("John")
        .lastName("Doe")
        .build();
    var savedUser = entityManager.persistAndFlush(user);
    entityManager.clear();
    
    // When
    var foundUser = entityManager.find(User.class, savedUser.getId());
    foundUser.setFirstName("Jane");
    entityManager.flush();
    
    // Then
    assertThat(foundUser.getUpdatedAt()).isNotNull();
    assertThat(foundUser.getUpdatedAt()).isAfter(foundUser.getCreatedAt());
}
```

### 4. Entity Relationships Testing
Test OneToMany, ManyToOne, ManyToMany relationships:

```java
@Test
@DisplayName("Should cascade persist to related entities")
void shouldCascadePersistToRelatedEntities() {
    // Given
    var user = User.builder()
        .email("user@example.com")
        .firstName("John")
        .lastName("Doe")
        .build();
    
    var address = Address.builder()
        .street("123 Main St")
        .city("Anytown")
        .zipCode("12345")
        .user(user)
        .build();
    
    user.setAddresses(List.of(address));
    
    // When
    var savedUser = entityManager.persistAndFlush(user);
    entityManager.clear();
    
    // Then
    var foundUser = entityManager.find(User.class, savedUser.getId());
    assertThat(foundUser.getAddresses()).hasSize(1);
    assertThat(foundUser.getAddresses().get(0).getStreet()).isEqualTo("123 Main St");
}

@Test
@DisplayName("Should handle lazy loading correctly")
void shouldHandleLazyLoadingCorrectly() {
    // Given
    var user = createAndPersistUserWithAddresses();
    entityManager.clear();
    
    // When
    var foundUser = entityManager.find(User.class, user.getId());
    
    // Then
    assertThat(foundUser).isNotNull();
    // Addresses should be lazily loaded
    assertThat(foundUser.getAddresses()).hasSize(2);
}
```

### 5. Repository Custom Queries Testing
Test custom repository methods and queries:

```java
@Test
@DisplayName("Should find users by email domain")
void shouldFindUsersByEmailDomain() {
    // Given
    var user1 = createAndPersistUser("user1@company.com");
    var user2 = createAndPersistUser("user2@company.com");
    var user3 = createAndPersistUser("user3@other.com");
    
    // When
    var companyUsers = userRepository.findByEmailDomain("company.com");
    
    // Then
    assertThat(companyUsers)
        .hasSize(2)
        .extracting(User::getEmail)
        .containsExactlyInAnyOrder("user1@company.com", "user2@company.com");
}

@Test
@DisplayName("Should find active users created after date")
void shouldFindActiveUsersCreatedAfterDate() {
    // Given
    var yesterday = LocalDateTime.now().minusDays(1);
    var activeUser = createAndPersistUserWithStatus(UserStatus.ACTIVE);
    var inactiveUser = createAndPersistUserWithStatus(UserStatus.INACTIVE);
    
    // When
    var activeUsers = userRepository.findActiveUsersCreatedAfter(yesterday);
    
    // Then
    assertThat(activeUsers)
        .hasSize(1)
        .contains(activeUser);
}
```

### 6. Transaction Testing
Test transaction boundaries and rollback behavior:

```java
@Test
@DisplayName("Should rollback transaction on exception")
@Transactional
@Rollback
void shouldRollbackTransactionOnException() {
    // Given
    var user = User.builder()
        .email("test@example.com")
        .firstName("John")
        .lastName("Doe")
        .build();
    
    // When & Then
    assertThatThrownBy(() -> {
        userRepository.save(user);
        // Simulate exception
        throw new RuntimeException("Test exception");
    }).isInstanceOf(RuntimeException.class);
    
    // Verify rollback
    var users = userRepository.findAll();
    assertThat(users).isEmpty();
}
```

### 7. Performance Testing
Test N+1 queries and batch operations:

```java
@Test
@DisplayName("Should avoid N+1 query problem")
void shouldAvoidNPlusOneQueryProblem() {
    // Given
    createMultipleUsersWithAddresses(10);
    
    // When
    var users = userRepository.findAllWithAddresses();
    
    // Then
    assertThat(users).hasSize(10);
    // Verify addresses are loaded in batch
    users.forEach(user -> {
        assertThat(user.getAddresses()).isNotEmpty();
    });
}

@Test
@DisplayName("Should batch insert multiple entities")
void shouldBatchInsertMultipleEntities() {
    // Given
    var users = IntStream.range(0, 100)
        .mapToObj(i -> User.builder()
            .email("user" + i + "@example.com")
            .firstName("User" + i)
            .lastName("LastName")
            .build())
        .toList();
    
    // When
    var savedUsers = userRepository.saveAll(users);
    entityManager.flush();
    
    // Then
    assertThat(savedUsers).hasSize(100);
    assertThat(userRepository.count()).isEqualTo(100);
}
```

## Test Configuration

### Application Properties for Testing
```properties
# application-test.properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.jdbc.batch_size=20
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true
```

### TestContainers Configuration
```java
@TestConfiguration
public class TestContainersConfig {
    
    @Bean
    @Primary
    public DataSource dataSource() {
        var postgres = new PostgreSQLContainer<>("postgres:13")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
        
        postgres.start();
        
        var dataSource = new HikariDataSource();
        dataSource.setJdbcUrl(postgres.getJdbcUrl());
        dataSource.setUsername(postgres.getUsername());
        dataSource.setPassword(postgres.getPassword());
        
        return dataSource;
    }
}
```

## Test Data Management

### Test Data Management

For comprehensive test data factories, caching strategies, and data management patterns, see [Entity Test Refactoring and Data Management](entity-test-refactoring-and-data-management.md#test-data-management-strategies).

## Coverage Guidelines

- **Entity persistence**: Test save, update, delete operations
- **Database constraints**: Test all unique and foreign key constraints
- **Entity relationships**: Test all relationship mappings and cascading
- **Custom queries**: Test all repository methods
- **Transaction behavior**: Test rollback and commit scenarios
- **Performance**: Test for N+1 queries and batch operations
- **Lifecycle events**: Test all JPA lifecycle callbacks

For comprehensive best practices, refactoring patterns, and test maintenance strategies, see [Entity Test Refactoring and Data Management](entity-test-refactoring-and-data-management.md#best-practices-summary).