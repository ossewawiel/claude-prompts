# Entity Unit Testing Best Practices - Spring Boot 2.7 Java 11

## Overview
This document provides specific guidance for unit testing JPA entity classes in Spring Boot 2.7 applications using Java 11 features and modern testing practices.

**Cross-References:**
- [Entity Integration Testing Best Practices](entity-integration-testing-best-practices.md) - Integration testing patterns
- [Entity Test Refactoring and Data Management](entity-test-refactoring-and-data-management.md) - Test data builders and refactoring patterns

## Test Framework Setup

For dependencies and test data builders, see [Entity Test Refactoring and Data Management](entity-test-refactoring-and-data-management.md#dependencies-and-setup).

### Test Class Structure
```java
@ExtendWith(MockitoExtension.class)
class UserEntityTest {
    
    private Validator validator;
    
    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }
    
    @Nested
    @DisplayName("Entity Creation Tests")
    class EntityCreationTests {
        // Creation tests here
    }
    
    @Nested
    @DisplayName("Validation Tests")
    class ValidationTests {
        // Validation tests here
    }
    
    @Nested
    @DisplayName("Business Logic Tests")
    class BusinessLogicTests {
        // Business logic tests here
    }
}
```

## Core Testing Areas

### 1. Entity Validation Testing
Test JSR-303 bean validation annotations:

```java
@Test
@DisplayName("Should fail validation when email is invalid")
void shouldFailValidationWhenEmailIsInvalid() {
    var user = User.builder().email("invalid-email").firstName("John").lastName("Doe").build();
    var violations = validator.validate(user);
    
    assertThat(violations).hasSize(1);
    assertThat(violations.iterator().next().getPropertyPath().toString()).isEqualTo("email");
}

@Test
@DisplayName("Should pass validation with valid entity")
void shouldPassValidationWithValidEntity() {
    var user = User.builder().email("john.doe@example.com").firstName("John").lastName("Doe").build();
    var violations = validator.validate(user);
    
    assertThat(violations).isEmpty();
}
```

### 2. Equals and HashCode Testing
Test entity identity and equality:

```java
@Test
@DisplayName("Should be equal when entities have same ID")
void shouldBeEqualWhenEntitiesHaveSameId() {
    var user1 = User.builder().id(1L).email("test@example.com").build();
    var user2 = User.builder().id(1L).email("different@example.com").build();
    
    assertThat(user1).isEqualTo(user2);
    assertThat(user1.hashCode()).isEqualTo(user2.hashCode());
}

@Test
@DisplayName("Should not be equal when entities have different IDs")
void shouldNotBeEqualWhenEntitiesHaveDifferentIds() {
    var user1 = User.builder().id(1L).email("test@example.com").build();
    var user2 = User.builder().id(2L).email("test@example.com").build();
    
    assertThat(user1).isNotEqualTo(user2);
}
```

### 3. Builder Pattern Testing
Test Lombok @Builder functionality:

```java
@Test
@DisplayName("Should create entity using builder pattern")
void shouldCreateEntityUsingBuilderPattern() {
    // Given
    var email = "john.doe@example.com";
    var firstName = "John";
    var lastName = "Doe";
    
    // When
    var user = User.builder()
        .email(email)
        .firstName(firstName)
        .lastName(lastName)
        .build();
    
    // Then
    assertThat(user.getEmail()).isEqualTo(email);
    assertThat(user.getFirstName()).isEqualTo(firstName);
    assertThat(user.getLastName()).isEqualTo(lastName);
}
```

### 4. Entity Lifecycle Methods Testing
Test @PrePersist, @PreUpdate, etc.:

```java
@Test
@DisplayName("Should set created timestamp on pre-persist")
void shouldSetCreatedTimestampOnPrePersist() {
    // Given
    var user = User.builder()
        .email("test@example.com")
        .firstName("John")
        .lastName("Doe")
        .build();
    
    // When
    user.prePersist(); // Call lifecycle method directly
    
    // Then
    assertThat(user.getCreatedAt()).isNotNull();
    assertThat(user.getCreatedAt()).isBeforeOrEqualTo(LocalDateTime.now());
}
```

### 5. Business Logic Testing
Test domain logic within entities:

```java
@Test
@DisplayName("Should calculate full name correctly")
void shouldCalculateFullNameCorrectly() {
    // Given
    var user = User.builder()
        .firstName("John")
        .lastName("Doe")
        .build();
    
    // When
    var fullName = user.getFullName();
    
    // Then
    assertThat(fullName).isEqualTo("John Doe");
}

@Test
@DisplayName("Should activate user when status is pending")
void shouldActivateUserWhenStatusIsPending() {
    // Given
    var user = User.builder()
        .status(UserStatus.PENDING)
        .build();
    
    // When
    user.activate();
    
    // Then
    assertThat(user.getStatus()).isEqualTo(UserStatus.ACTIVE);
}
```

### 6. Custom Validation Testing
Test custom validation logic:

```java
@Test
@DisplayName("Should validate age constraint")
void shouldValidateAgeConstraint() {
    // Given
    var user = User.builder()
        .age(17) // Below minimum age
        .build();
    
    // When
    var violations = validator.validate(user);
    
    // Then
    assertThat(violations).hasSize(1);
    var violation = violations.iterator().next();
    assertThat(violation.getPropertyPath().toString()).isEqualTo("age");
}
```

### 7. Entity State Testing
Test entity state transitions:

```java
@Test
@DisplayName("Should transition from pending to active")
void shouldTransitionFromPendingToActive() {
    // Given
    var user = User.builder()
        .status(UserStatus.PENDING)
        .build();
    
    // When
    user.approve();
    
    // Then
    assertThat(user.getStatus()).isEqualTo(UserStatus.ACTIVE);
    assertThat(user.getApprovedAt()).isNotNull();
}
```

## Test Data Builders

For comprehensive test data builders and test data management strategies, see [Entity Test Refactoring and Data Management](entity-test-refactoring-and-data-management.md#test-data-management-strategies).

## Java 11 Features in Testing

### Using var for Local Variables
```java
@Test
void shouldUseVarForLocalVariables() {
    // Given
    var user = UserTestDataBuilder.aUser().build();
    
    // When
    var violations = validator.validate(user);
    
    // Then
    assertThat(violations).isEmpty();
}
```

### String Methods
```java
@Test
void shouldHandleBlankStrings() {
    // Given
    var user = User.builder()
        .firstName("  ") // Blank string
        .build();
    
    // When
    var isFirstNameBlank = user.getFirstName().isBlank();
    
    // Then
    assertThat(isFirstNameBlank).isTrue();
}
```

## Coverage Guidelines

- **Entity validation**: 100% coverage of all validation annotations
- **Business logic methods**: 100% coverage of all public methods
- **Equals/HashCode**: Test identity and equality contracts
- **Builder patterns**: Test all builder combinations
- **State transitions**: Test all valid state changes
- **Edge cases**: Test null values, empty strings, boundary values

For comprehensive best practices, refactoring patterns, and test maintenance strategies, see [Entity Test Refactoring and Data Management](entity-test-refactoring-and-data-management.md#best-practices-summary).