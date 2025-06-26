# Integration Testing Setup & Prompt Guide

## Overview
This document provides a step-by-step approach to setting up integration testing structures and generates specific prompts for creating integration tests at different levels (Service, Controller, API, UI). Each prompt includes detailed context, expected outcomes, and level-specific requirements.

---

## Part 1: Integration Testing Setup Steps

### Step 1: Foundation Setup Prompt

#### Prompt: "Set up Integration Testing Foundation"

**Context**: Establish the basic integration testing infrastructure for a Spring Boot project with proper TestContainers, database setup, and test configuration.

**Requirements**:
- Configure TestContainers for database integration
- Set up test application properties and profiles
- Create base integration test classes
- Configure test data management and cleanup
- Establish proper test execution separation from unit tests

**Expected Output**:
- Complete build configuration with integration test dependencies
- Base abstract integration test class with common setup
- Test application properties for isolated testing environment
- Docker compose configuration for local integration testing
- Gradle/Maven task configuration for separate integration test execution

**Reference Documents**: 
- `testing/strategies/integration-testing-strategy.md`
- `testing/strategies/unit-testing-strategy.md`
- Project build configuration patterns

---

### Step 2: Database Integration Setup Prompt

#### Prompt: "Configure Database Integration Testing Infrastructure"

**Context**: Set up comprehensive database integration testing with TestContainers, transaction management, and test data strategies.

**Requirements**:
- TestContainers PostgreSQL/MySQL setup with proper lifecycle management
- Test transaction configuration and rollback strategies
- Test data builders and fixtures for integration scenarios
- Database migration handling in test environment
- Performance optimization for database integration tests

**Expected Output**:
- TestContainers configuration with reusable containers
- Database integration test base class
- Test data management utilities
- Migration and schema handling for tests
- Connection pooling and performance optimization

**Reference Documents**:
- `testing/strategies/integration-testing-strategy.md`
- Database configuration from project knowledge
- Migration strategy documentation

---

### Step 3: Spring Context Integration Setup Prompt

#### Prompt: "Configure Spring Boot Integration Test Context"

**Context**: Establish proper Spring Boot test context configuration with appropriate test slices, mock strategies, and component integration.

**Requirements**:
- @SpringBootTest configuration with proper web environment setup
- Test slice configurations (@WebMvcTest, @DataJpaTest, @JsonTest)
- Mock strategy for external dependencies
- Security configuration for integration tests
- Test profile and property management

**Expected Output**:
- Spring Boot test configuration classes
- Test slice configurations for different layers
- Mock configuration for external services
- Security test setup and authentication handling
- Environment-specific test properties

**Reference Documents**:
- Spring Boot testing documentation
- Security configuration from project knowledge
- Application configuration patterns

---

### Step 4: External Service Integration Setup Prompt

#### Prompt: "Set up External Service Integration Testing"

**Context**: Configure integration testing for external APIs, message queues, and third-party services using WireMock and TestContainers.

**Requirements**:
- WireMock setup for external API mocking
- Message queue testing with TestContainers (RabbitMQ, Kafka)
- Redis integration testing setup
- Email service testing configuration
- HTTP client integration testing

**Expected Output**:
- WireMock configuration and utilities
- Message queue test setup with containers
- Cache integration test configuration
- Email service mock setup
- HTTP client integration test patterns

**Reference Documents**:
- External service configurations from project knowledge
- Message queue setup documentation
- API integration patterns

---

## Part 2: Integration Test Level Specifications

### Service Level Integration Testing

#### Test Scope
**What to Test**: Business logic integration across service boundaries, database transactions, and cross-cutting concerns.

**Components Involved**:
- Service classes with their dependencies
- Repository layer integration
- Transaction management
- Cache integration
- Event publishing/handling

**Expected Outcomes**:
- Verify business workflows end-to-end
- Validate transaction boundaries and rollback scenarios
- Confirm data persistence and retrieval accuracy
- Test service orchestration and choreography
- Validate business rule enforcement across services

#### Example Service Level Prompt Template

```markdown
**Prompt**: "Generate Service Level Integration Test for [ServiceName]"

**Context**: Test the integration of [ServiceName] with its dependencies including database operations, transaction management, and cross-service interactions.

**Service Details**:
- **Service**: [com.company.service.UserService]
- **Primary Operations**: [createUser, updateUser, deactivateUser]
- **Dependencies**: [UserRepository, EmailService, AuditService]
- **Transaction Boundaries**: [Multi-service operations with rollback scenarios]
- **Business Rules**: [Email uniqueness, user lifecycle rules]

**Test Scenarios Required**:
1. **Happy Path Workflows**: Complete business operations with all dependencies
2. **Transaction Testing**: Multi-operation transactions with success and rollback scenarios
3. **Data Consistency**: Verify data integrity across related entities
4. **Cross-Service Integration**: Service interaction and data flow validation
5. **Error Propagation**: Exception handling across service boundaries

**Expected Integration Points**:
- Database persistence through repositories
- Email notifications through external service
- Audit trail creation through audit service
- Cache updates and invalidation
- Event publishing for service notifications

**Mock Strategy**: Mock external services (EmailService) but use real database and internal services.

**Performance Expectations**: Tests should complete within 5 seconds, database operations should be optimized.
```

---

### Controller Level Integration Testing

#### Test Scope
**What to Test**: HTTP request/response handling, Spring Security integration, validation, and controller-service integration.

**Components Involved**:
- REST Controllers
- Request/Response DTOs
- Validation framework
- Security configuration
- Exception handling
- Content negotiation

**Expected Outcomes**:
- Verify HTTP method handling and routing
- Validate request/response serialization
- Confirm security enforcement (authentication/authorization)
- Test input validation and error responses
- Verify proper HTTP status codes and headers

#### Example Controller Level Prompt Template

```markdown
**Prompt**: "Generate Controller Level Integration Test for [ControllerName]"

**Context**: Test the HTTP layer integration including request handling, security, validation, and response formatting for [ControllerName].

**Controller Details**:
- **Controller**: [com.company.controller.UserController]
- **Endpoints**: [GET /users, POST /users, PUT /users/{id}, DELETE /users/{id}]
- **Security**: [Role-based access control, JWT authentication]
- **Validation**: [Request body validation, path variable validation]
- **Response Types**: [JSON, XML support with content negotiation]

**Test Scenarios Required**:
1. **Endpoint Functionality**: All HTTP methods with valid requests and responses
2. **Security Integration**: Authentication and authorization for each endpoint
3. **Validation Testing**: Invalid request handling and error responses
4. **Content Negotiation**: JSON/XML response format testing
5. **Error Handling**: Exception scenarios and proper HTTP status codes

**Expected Integration Points**:
- Spring Security filter chain
- Request validation framework
- Service layer integration
- Response serialization
- Global exception handling

**Mock Strategy**: Mock service layer dependencies, use real Spring MVC infrastructure.

**Test Framework**: @WebMvcTest with MockMvc for focused controller testing.
```

---

### API Level Integration Testing

#### Test Scope
**What to Test**: End-to-end API functionality, external client integration, API contract validation, and full request lifecycle.

**Components Involved**:
- Complete HTTP stack
- Database integration
- Security implementation
- External service calls
- Full application context

**Expected Outcomes**:
- Verify complete API workflows from request to response
- Validate API contracts and documentation accuracy
- Confirm database state changes from API calls
- Test real authentication and authorization flows
- Validate external service integrations

#### Example API Level Prompt Template

```markdown
**Prompt**: "Generate API Level Integration Test for [API Workflow]"

**Context**: Test complete API functionality including full application context, database operations, and external service integration for [specific API workflow].

**API Details**:
- **API Workflow**: [User Registration and Onboarding]
- **Endpoints Involved**: [POST /users/register, POST /users/verify-email, PUT /users/complete-profile]
- **Database Operations**: [User creation, email verification, profile completion]
- **External Services**: [Email service, payment gateway, notification service]
- **Security Flow**: [Registration → email verification → authenticated profile completion]

**Test Scenarios Required**:
1. **Complete Workflow**: End-to-end user journey from registration to active user
2. **Database State Validation**: Verify correct data persistence at each step
3. **External Service Integration**: Real email sending, payment processing
4. **Security Transitions**: Anonymous → verified → authenticated states
5. **Error Recovery**: Incomplete workflows and retry scenarios

**Expected Integration Points**:
- Full Spring Boot application context
- Real database with TestContainers
- External service calls (mocked with WireMock)
- Complete security configuration
- Transaction management across multiple operations

**Mock Strategy**: Use TestContainers for database, WireMock for external HTTP services, real application context.

**Test Framework**: @SpringBootTest with TestRestTemplate for full integration testing.
```

---

### UI Level Integration Testing (Vaadin/Web)

#### Test Scope
**What to Test**: User interface interactions, component behavior, navigation flows, and client-server communication.

**Components Involved**:
- Vaadin Views and Components
- Client-server communication
- Session management
- Navigation and routing
- UI state management

**Expected Outcomes**:
- Verify UI component rendering and behavior
- Validate user interaction flows
- Confirm data binding and validation
- Test navigation and routing
- Validate session and state management

#### Example UI Level Prompt Template

```markdown
**Prompt**: "Generate UI Level Integration Test for [UI Component/Flow]"

**Context**: Test user interface integration including component behavior, user interactions, and client-server communication for [specific UI component or user flow].

**UI Details**:
- **Component/View**: [UserListView with filtering and pagination]
- **User Interactions**: [Filter by role, search by name, pagination navigation, user selection]
- **Server Integration**: [Real-time data loading, lazy loading, server-side filtering]
- **Navigation**: [Navigate to user details, edit user, create new user]
- **State Management**: [Filter persistence, selected user state, pagination state]

**Test Scenarios Required**:
1. **Component Rendering**: Verify proper component initialization and display
2. **User Interactions**: Click, type, select, navigate interactions
3. **Data Loading**: Server communication and data display
4. **Validation**: Client-side and server-side validation integration
5. **Navigation Flows**: Multi-view user journeys

**Expected Integration Points**:
- Vaadin component lifecycle
- Server-side data providers
- Client-server communication
- Session management
- Browser state management

**Mock Strategy**: Use real Vaadin components, mock external services, use TestContainers for database.

**Test Framework**: Vaadin TestBench with browser automation for UI integration testing.
```

---

## Part 3: Standard Integration Test Prompts by Level

### Service Level Standard Prompts

#### 1. Service-Repository Integration Prompt
```markdown
**Generate Service-Repository Integration Tests**

**Scope**: Test service layer integration with repository layer including transaction management and data consistency.

**Template Application**: Apply to any service class that manages entities through repositories.

**Standard Test Scenarios**:
- CRUD operations with database persistence verification
- Transaction rollback scenarios on service method failures
- Cascade operations and relationship management
- Business rule enforcement with database constraints
- Concurrent access and optimistic locking scenarios

**Mock Strategy**: Real database with TestContainers, mock external services only.
```

#### 2. Service-Service Integration Prompt
```markdown
**Generate Service-Service Integration Tests**

**Scope**: Test integration between multiple service classes including cross-service transactions and event handling.

**Template Application**: Apply to orchestrating services that coordinate multiple business services.

**Standard Test Scenarios**:
- Multi-service business workflows
- Distributed transaction management
- Event publishing and handling between services
- Service dependency chains and error propagation
- Compensating actions and saga pattern implementation

**Mock Strategy**: Real services and database, mock external APIs and infrastructure services.
```

### Controller Level Standard Prompts

#### 3. REST Controller Integration Prompt
```markdown
**Generate REST Controller Integration Tests**

**Scope**: Test REST endpoints including request/response handling, validation, and security integration.

**Template Application**: Apply to any @RestController class with HTTP endpoints.

**Standard Test Scenarios**:
- All HTTP methods (GET, POST, PUT, DELETE, PATCH) with valid requests
- Request validation and error response handling
- Security enforcement (authentication and authorization)
- Content negotiation (JSON, XML) and custom headers
- Exception handling and proper HTTP status codes

**Mock Strategy**: @WebMvcTest with MockMvc, mock service layer dependencies.
```

#### 4. Vaadin View Integration Prompt
```markdown
**Generate Vaadin View Integration Tests**

**Scope**: Test Vaadin UI components and views including user interactions and server communication.

**Template Application**: Apply to any Vaadin View class with user interface components.

**Standard Test Scenarios**:
- Component initialization and rendering
- User interaction handling (clicks, form submission, navigation)
- Data binding and validation
- Server-side communication and data loading
- Navigation and routing between views

**Mock Strategy**: Real Vaadin components, mock service layer, use TestContainers for database.
```

### API Level Standard Prompts

#### 5. Complete API Workflow Prompt
```markdown
**Generate Complete API Workflow Integration Tests**

**Scope**: Test end-to-end API functionality including full application context and external integrations.

**Template Application**: Apply to complete user journeys or business processes that span multiple endpoints.

**Standard Test Scenarios**:
- Complete business workflow from start to finish
- Database state verification at each workflow step
- External service integration and error handling
- Security state transitions throughout the workflow
- Performance and timeout handling for complex operations

**Mock Strategy**: @SpringBootTest with full context, TestContainers for database, WireMock for external services.
```

#### 6. External API Integration Prompt
```markdown
**Generate External API Integration Tests**

**Scope**: Test integration with external APIs and services including error handling and resilience patterns.

**Template Application**: Apply to any service that integrates with external HTTP APIs or messaging systems.

**Standard Test Scenarios**:
- Successful external API communication
- External service failure handling and circuit breaker patterns
- Retry logic and timeout handling
- Data transformation and mapping for external APIs
- Authentication and authorization with external services

**Mock Strategy**: WireMock for external HTTP APIs, TestContainers for message queues, real application context.
```

---

## Part 4: Prompt Usage Guidelines

### When to Use Each Level

#### Service Level Integration Tests
**Use When**:
- Testing business logic that involves multiple components
- Validating transaction boundaries and data consistency
- Testing service orchestration and choreography
- Verifying cache integration and performance optimizations

**Avoid When**:
- Testing simple CRUD operations (use unit tests)
- Testing external API contracts (use API level tests)
- Testing UI interactions (use UI level tests)

#### Controller Level Integration Tests
**Use When**:
- Testing HTTP request/response handling
- Validating Spring Security integration
- Testing request validation and error responses
- Verifying content negotiation and serialization

**Avoid When**:
- Testing business logic (use service level tests)
- Testing complete workflows (use API level tests)
- Testing database operations directly (use service level tests)

#### API Level Integration Tests
**Use When**:
- Testing complete user journeys or business workflows
- Validating API contracts and documentation
- Testing external service integrations
- Performance testing under realistic conditions

**Avoid When**:
- Testing individual component behavior (use unit tests)
- Testing UI-specific interactions (use UI level tests)
- Simple validation testing (use controller level tests)

#### UI Level Integration Tests
**Use When**:
- Testing user interface components and interactions
- Validating client-server communication
- Testing navigation and routing flows
- Verifying UI state management and data binding

**Avoid When**:
- Testing business logic (use service level tests)
- Testing API contracts (use API level tests)
- Testing simple component behavior (use unit tests)

### Integration Test Execution Strategy

#### Test Categories and Tags
```kotlin
// Service Level
@Tag("integration")
@Tag("service")

// Controller Level  
@Tag("integration")
@Tag("controller")

// API Level
@Tag("integration") 
@Tag("api")

// UI Level
@Tag("integration")
@Tag("ui")
```

#### Gradle Task Configuration
```gradle
// All integration tests
tasks.register('integrationTest', Test) {
    useJUnitPlatform {
        includeTags 'integration'
    }
    group = 'verification'
    description = 'Runs all integration tests'
}

// Service level only
tasks.register('serviceIntegrationTest', Test) {
    useJUnitPlatform {
        includeTags 'integration', 'service'
    }
    group = 'verification'
    description = 'Runs service level integration tests'
}

// API level only  
tasks.register('apiIntegrationTest', Test) {
    useJUnitPlatform {
        includeTags 'integration', 'api'
    }
    group = 'verification'
    description = 'Runs API level integration tests'
}
```

### Performance Expectations by Level

| Test Level | Max Duration | Resource Usage | Parallel Execution |
|------------|-------------|----------------|-------------------|
| Service    | 5 seconds   | Medium         | Limited           |
| Controller | 3 seconds   | Low            | High              |
| API        | 10 seconds  | High           | Very Limited      |
| UI         | 15 seconds  | Very High      | Sequential        |

### Success Criteria

Each integration test should:
- ✅ Test realistic scenarios with proper data setup
- ✅ Verify expected outcomes and side effects
- ✅ Handle error scenarios and edge cases
- ✅ Execute within performance expectations
- ✅ Clean up resources and test data properly
- ✅ Be independent and order-agnostic
- ✅ Provide clear failure messages and debugging information