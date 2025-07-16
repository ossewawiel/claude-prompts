# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains comprehensive documentation and best practices for Java Spring Boot 2.7 enterprise application development, focusing on Java 11 features, service architecture, testing strategies, and modern development practices.

## Repository Structure

This is a documentation-focused repository with the following key areas:

- **Core Architecture**: Service layer patterns, dependency injection, and transaction management
- **Java 11 Features**: Modern Java features and their practical applications
- **Testing**: Unit testing, integration testing, and repository testing strategies
- **Data Management**: JPA entities, DTOs, mapping strategies, and database optimization
- **Performance & Security**: Security best practices and performance optimization
- **Code Quality**: Lombok integration, error handling, and async/multithreading patterns

## Key Documentation Files

### Core Development Guides
- `project-structure.md` - Project organization and naming conventions
- `service-architecture.md` - Service layer design patterns and transaction management
- `java11-features.md` - Java 11 features and their practical applications
- `java11-overview.md` - Overview of Java 11 capabilities

### Testing Documentation
- `testing-docs.md` - Comprehensive testing strategies with JUnit 5 and Mockito
- `concise_testing_guide.md` - Concise testing best practices
- `updated_unit_testing_guide.md` - Updated unit testing approaches
- `java_repository_test_best_practices.md` - Repository layer testing patterns

### Data and Entity Management
- `jpa_repository_guide.md` - JPA repository patterns and custom queries
- `jpa-entity-review-guide.md` - Entity design and review guidelines
- `dto-mapping.md` - DTO mapping strategies and best practices

### Quality and Practices
- `lombok-practices.md` - Lombok integration and best practices
- `error-handling.md` - Error handling patterns and exception management
- `async-multithreading.md` - Asynchronous processing and multithreading
- `performance-security.md` - Security and performance optimization

## Development Context

This repository focuses on:

1. **Enterprise Spring Boot Development** - Production-ready patterns and practices
2. **Java 11 Modern Features** - Leveraging newer Java capabilities
3. **Testing Excellence** - Comprehensive testing strategies across all layers
4. **Code Quality** - Maintainable, well-structured code patterns
5. **Performance & Security** - Production-ready security and performance considerations

## Architecture Patterns

The documentation emphasizes:

- **Service Layer Architecture** - Interface-based services with proper transaction boundaries
- **Feature-Based Structure** - Organizing code by business domains rather than technical layers
- **Constructor Injection** - Immutable dependencies using Lombok `@RequiredArgsConstructor`
- **Domain-Driven Design** - Clear separation of concerns and business logic encapsulation
- **Event-Driven Patterns** - Asynchronous processing and domain events

## Testing Approach

Testing documentation covers:

- **Unit Testing** - JUnit 5 with Mockito for service layer testing
- **Integration Testing** - `@SpringBootTest` for full application context testing
- **Repository Testing** - `@DataJpaTest` for focused data layer testing
- **Test Organization** - Nested test classes and descriptive naming
- **Test Data Management** - Builder patterns and test fixtures

## Common Patterns and Conventions

### Package Structure
```
com.company.project/
├── config/          # Configuration classes
├── user/            # Feature-based organization
│   ├── User.java    # Entity
│   ├── UserService.java
│   ├── UserController.java
│   └── dto/         # DTOs specific to user feature
├── shared/          # Shared components
│   ├── exception/
│   ├── util/
│   └── dto/
```

### Service Layer Pattern
- Use `@Service` with `@Transactional(readOnly = true)` as default
- Override with `@Transactional` for write operations
- Constructor injection with `@RequiredArgsConstructor`
- Interface-based design for testability

### Testing Patterns
- Use `@ExtendWith(MockitoExtension.class)` for unit tests
- Use `@SpringBootTest` for integration tests
- Use `@DataJpaTest` for repository tests
- Organize tests with `@Nested` classes and descriptive names

## Java 11 Features Usage

The documentation emphasizes modern Java 11 features:
- `var` for local variable type inference
- String methods (`isBlank()`, `lines()`, `strip()`)
- Optional enhancements
- Stream API improvements
- HTTP Client API

## Code Quality Standards

- **Lombok Integration** - Reduce boilerplate with `@Data`, `@Builder`, `@RequiredArgsConstructor`
- **Error Handling** - Custom exceptions with proper error codes and messages
- **JavaDoc Standards** - Comprehensive documentation with examples
- **Validation** - JSR-303 bean validation with custom validators
- **Async Processing** - `@Async` methods for non-blocking operations

## When Working with This Repository

1. **Focus on Documentation Quality** - This is a documentation repository, so emphasis should be on clear, comprehensive documentation
2. **Follow Established Patterns** - Use the documented patterns consistently
3. **Maintain Code Examples** - Keep code examples current and functional
4. **Test Documentation** - Ensure all code examples compile and work correctly
5. **Cross-Reference Documentation** - Maintain consistency across related documentation files

## Key Technologies and Frameworks

- **Spring Boot 2.7** - Main framework
- **Java 11** - Language version and features
- **JPA/Hibernate** - Data persistence
- **JUnit 5** - Testing framework
- **Mockito** - Mocking framework
- **Lombok** - Code generation
- **MapStruct** - DTO mapping (referenced in documentation)
- **Spring Security** - Security framework
- **Spring Data JPA** - Data access layer