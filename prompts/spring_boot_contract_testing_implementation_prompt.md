# Contract Testing Implementation Prompt for Claude Code

## CONTEXT
You are tasked with implementing a comprehensive Contract Testing framework for a Spring Boot application undergoing tech stack upgrade. This framework will compare API responses between the existing (old) service and the upgraded (new) service to ensure compatibility.

## REQUIRED ANALYSIS AND SETUP

### PHASE 1: CODEBASE ANALYSIS (CRITICAL PRIORITY)

**Analyze the existing Spring Boot application and provide:**

1. **Service Endpoint Discovery**
   - Scan all `@RestController` classes and identify endpoints
   - List all `@RequestMapping`, `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, `@PatchMapping` annotations
   - Document path variables, query parameters, request bodies, and response types
   - Identify security requirements (@Secured, @PreAuthorize annotations)
   - Check for GraphQL endpoints and schema definitions

2. **API Surface Analysis**
   - Create inventory of all public endpoints with their signatures
   - Identify endpoints that require authentication/authorization
   - Document request/response data models and DTOs
   - List all path parameters and their types/constraints
   - Identify query parameters and their validation rules

3. **Configuration Assessment**
   - Locate application.yml/properties files
   - Identify server port configurations
   - Check for profile-specific configurations
   - Document security configurations
   - Identify database connection settings

4. **Dependency Analysis**
   - List all Spring Boot starters and versions
   - Identify testing dependencies already present
   - Check for JSON processing libraries (Jackson, etc.)
   - Document any existing test configurations

### PHASE 2: CRITICAL INFRASTRUCTURE SETUP

**Create the following components in priority order:**

#### PRIORITY 1: Core Configuration Setup
```markdown
**TASK**: Create ContractTestConfig.java
- Configuration class with @ConfigurationProperties
- Properties for old/new service URLs
- Timeout and concurrency settings
- Ignored fields configuration
- Excluded endpoints configuration

**DELIVERABLE**: ContractTestConfig.java + contract-test.yml
**DEPENDENCIES**: None
**VALIDATION**: Configuration loads properly with @Test
```

#### PRIORITY 2: Service Endpoint Configuration
```markdown
**TASK**: Create ServiceEndpointConfig.java
- RestTemplate beans for old and new services
- HTTP client configuration with timeouts
- Authentication setup (if required)
- SSL/TLS configuration (if needed)

**DELIVERABLE**: ServiceEndpointConfig.java
**DEPENDENCIES**: ContractTestConfig
**VALIDATION**: RestTemplate beans can connect to services
```

#### PRIORITY 3: Endpoint Discovery Framework
```markdown
**TASK**: Create RestControllerAnalyzer.java
- Scan @RestController classes using reflection
- Extract RequestMappingInfo from HandlerMapping
- Generate EndpointDefinition objects
- Handle path variables and query parameters

**DELIVERABLE**: RestControllerAnalyzer.java + EndpointDefinition.java
**DEPENDENCIES**: Spring context scanning
**VALIDATION**: Discovers all endpoints correctly with @Test
```

### PHASE 3: TEST GENERATION ENGINE

#### PRIORITY 4: Test Data Factory
```markdown
**TASK**: Create TestDataFactory.java
- Generate test data based on parameter types
- Handle primitive types, strings, collections
- Integration with Faker library for realistic data
- Boundary value generation (nulls, empty, max values)

**DELIVERABLE**: TestDataFactory.java + supporting data classes
**DEPENDENCIES**: JavaFaker dependency
**VALIDATION**: Generates appropriate test data for each type
```

#### PRIORITY 5: Permutation Generator
```markdown
**TASK**: Create PermutationGenerator.java
- Generate parameter combinations using Cartesian product
- Create positive, negative, and edge case scenarios
- Handle optional vs required parameters
- Generate request body variations

**DELIVERABLE**: PermutationGenerator.java + TestCase.java
**DEPENDENCIES**: TestDataFactory
**VALIDATION**: Generates comprehensive test permutations
```

### PHASE 4: EXECUTION ENGINE

#### PRIORITY 6: Response Comparison Logic
```markdown
**TASK**: Create ResponseComparator.java
- Deep JSON comparison with configurable ignored fields
- Status code comparison
- Headers comparison (selective)
- Custom comparison rules for timestamps, IDs

**DELIVERABLE**: ResponseComparator.java + ComparisonResult.java
**DEPENDENCIES**: Jackson ObjectMapper
**VALIDATION**: Accurately compares responses with edge cases
```

#### PRIORITY 7: Parallel Test Runner
```markdown
**TASK**: Create ParallelTestRunner.java
- Execute requests against both services concurrently
- Manage thread pool and execution limits
- Handle timeouts and retries
- Aggregate results from parallel executions

**DELIVERABLE**: ParallelTestRunner.java
**DEPENDENCIES**: ResponseComparator, Service configurations
**VALIDATION**: Executes tests in parallel without race conditions
```

### PHASE 5: REPORTING AND ANALYSIS

#### PRIORITY 8: Test Reporting
```markdown
**TASK**: Create ContractTestReport.java
- Generate HTML reports with difference highlighting
- Create JSON output for CI/CD integration
- Generate CSV data for analysis
- Summary statistics and pass/fail metrics

**DELIVERABLE**: ContractTestReport.java + HTML templates
**DEPENDENCIES**: All test execution components
**VALIDATION**: Generates readable reports with sample data
```

#### PRIORITY 9: Main Test Suite
```markdown
**TASK**: Create ContractTestSuite.java
- Integration test that orchestrates all components
- JUnit 5 test methods for different scenarios
- Maven/Gradle integration for build pipeline
- Command-line execution capability

**DELIVERABLE**: ContractTestSuite.java
**DEPENDENCIES**: All previous components
**VALIDATION**: Full end-to-end contract testing execution
```

### PHASE 6: ADVANCED FEATURES (LOWER PRIORITY)

#### PRIORITY 10: GraphQL Support (If Applicable)
```markdown
**TASK**: Create GraphQLSchemaAnalyzer.java
- Parse GraphQL schema definitions
- Generate query/mutation test cases
- Handle GraphQL-specific comparison logic
- Integration with existing framework

**DELIVERABLE**: GraphQLSchemaAnalyzer.java + GraphQLTestCase.java
**DEPENDENCIES**: GraphQL Java library
**VALIDATION**: Generates GraphQL tests correctly
```

#### PRIORITY 11: Advanced Test Data Management
```markdown
**TASK**: Enhance TestDataFactory with external data sources
- Load test data from JSON/CSV files
- Database seeding for complex scenarios
- User-defined test scenarios
- Test data templates

**DELIVERABLE**: Enhanced TestDataFactory + data loading utilities
**DEPENDENCIES**: File I/O and database access
**VALIDATION**: Loads and uses external test data correctly
```

## IMPLEMENTATION PROMPTS FOR CLAUDE CODE

### PROMPT 1: Core Configuration (CRITICAL)
```markdown
# Contract Testing Configuration Setup

## Context
Set up the foundational configuration for contract testing framework in Spring Boot.

## Task
1. Analyze the existing application.yml/properties files
2. Create ContractTestConfig.java with @ConfigurationProperties
3. Create contract-test.yml with base configuration
4. Add Maven dependencies for testing framework

## Required Components
- ContractTestConfig.java with validation annotations
- contract-test.yml with service URLs and settings
- Maven dependencies: spring-boot-starter-test, javafaker, jsonassert
- Basic validation test to ensure configuration loads

## Acceptance Criteria
- Configuration class properly binds to YAML properties
- Service URLs are configurable for different environments
- Timeout and concurrency settings are parameterized
- Configuration validates with @Valid annotations
```

### PROMPT 2: Endpoint Discovery (CRITICAL)
```markdown
# REST Endpoint Discovery Implementation

## Context
Create a system to automatically discover all REST endpoints in the Spring Boot application.

## Task
1. Analyze all @RestController classes in the codebase
2. Create RestControllerAnalyzer to scan and extract endpoint information
3. Create EndpointDefinition data model
4. Generate comprehensive endpoint inventory

## Required Analysis
- Scan all classes with @RestController annotation
- Extract method mappings (@GetMapping, @PostMapping, etc.)
- Identify path variables and query parameters with types
- Document request/response body types
- Handle security annotations and requirements

## Deliverables
- RestControllerAnalyzer.java with full scanning capability
- EndpointDefinition.java with complete endpoint metadata
- ParameterDefinition.java for parameter details
- Unit tests validating endpoint discovery accuracy
```

### PROMPT 3: Test Data Generation (HIGH PRIORITY)
```markdown
# Test Data Factory Implementation

## Context
Create intelligent test data generation for all endpoint parameters and request bodies.

## Task
1. Analyze all parameter types used in discovered endpoints
2. Create TestDataFactory for generating realistic test data
3. Implement PermutationGenerator for test case combinations
4. Handle edge cases and boundary values

## Required Features
- Type-based data generation (String, Integer, Long, Boolean, etc.)
- Realistic data using JavaFaker
- Boundary value testing (nulls, empty, max values)
- Custom object generation for request bodies
- Parameter combination logic (Cartesian product)

## Deliverables
- TestDataFactory.java with comprehensive type support
- PermutationGenerator.java for test case creation
- TestCase.java data model
- Edge case and boundary value tests
```

### PROMPT 4: Parallel Execution Engine (HIGH PRIORITY)
```markdown
# Parallel Test Execution Implementation

## Context
Create a robust parallel execution engine for running contract tests against both services.

## Task
1. Create ParallelTestRunner for concurrent request execution
2. Implement ResponseComparator for deep JSON comparison
3. Handle timeouts, retries, and error scenarios
4. Aggregate results from parallel executions

## Required Features
- Concurrent execution with configurable thread pool
- CompletableFuture-based async processing
- Comprehensive response comparison with ignored fields
- Error handling and classification
- Progress monitoring and logging

## Deliverables
- ParallelTestRunner.java with async execution
- ResponseComparator.java with deep JSON comparison
- ComparisonResult.java for storing comparison outcomes
- Difference.java for documenting specific differences
- Comprehensive error handling and retry logic
```

### PROMPT 5: Reporting Framework (MEDIUM PRIORITY)
```markdown
# Contract Test Reporting Implementation

## Context
Create comprehensive reporting for contract test results with multiple output formats.

## Task
1. Create ContractTestReport for generating test reports
2. Implement HTML report with difference highlighting
3. Generate JSON output for CI/CD integration
4. Create summary statistics and failure analysis

## Required Features
- HTML reports with visual difference highlighting
- JSON output for automated processing
- CSV data export for analysis
- Summary statistics (pass rate, failure breakdown)
- Failure categorization and trending

## Deliverables
- ContractTestReport.java with multiple output formats
- HTML templates for report generation
- ContractTestSummary.java for statistics
- CI/CD integration utilities
- Report validation and testing
```

### PROMPT 6: Main Test Suite Integration (MEDIUM PRIORITY)
```markdown
# Contract Test Suite Integration

## Context
Create the main test suite that orchestrates all contract testing components.

## Task
1. Create ContractTestSuite as the main JUnit test class
2. Integrate all components into cohesive test execution
3. Add Maven/Gradle build integration
4. Implement command-line execution options

## Required Features
- JUnit 5 integration with @SpringBootTest
- Component orchestration and dependency injection
- Build tool integration (Maven Surefire/Gradle)
- Command-line execution with parameters
- CI/CD pipeline integration

## Deliverables
- ContractTestSuite.java as main test class
- Maven/Gradle configuration updates
- Command-line runner utility
- CI/CD pipeline examples
- Documentation for test execution
```

## SUCCESS CRITERIA

### Minimum Viable Product (MVP)
- [ ] Configuration framework loads and validates correctly
- [ ] Endpoint discovery finds all REST endpoints accurately
- [ ] Test data generation creates appropriate test cases
- [ ] Parallel execution runs tests against both services
- [ ] Response comparison identifies differences correctly
- [ ] Basic reporting shows pass/fail status

### Complete Implementation
- [ ] All components integrate seamlessly
- [ ] GraphQL support (if applicable)
- [ ] Advanced test data management
- [ ] Comprehensive error handling
- [ ] CI/CD integration working
- [ ] Performance optimizations implemented
- [ ] Full documentation and examples

## VALIDATION STEPS

1. **Unit Tests**: Each component has comprehensive unit tests
2. **Integration Tests**: Components work together correctly
3. **End-to-End Tests**: Full contract testing workflow executes
4. **Performance Tests**: Parallel execution meets performance criteria
5. **Documentation**: All components are properly documented

## DEPENDENCIES TO ADD

```xml
<!-- Add to pom.xml -->
<dependencies>
    <dependency>
        <groupId>com.github.javafaker</groupId>
        <artifactId>javafaker</artifactId>
        <version>1.0.2</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.skyscreamer</groupId>
        <artifactId>jsonassert</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
    </dependency>
</dependencies>
```

## OUTPUT REQUIREMENTS

For each implemented component, provide:
1. **Complete source code** with proper documentation
2. **Unit tests** with good coverage
3. **Configuration examples** for different scenarios
4. **Usage documentation** with examples
5. **Integration instructions** for build pipeline

This prompt serves as both specification and implementation guide for creating a robust contract testing framework for Spring Boot service upgrades.