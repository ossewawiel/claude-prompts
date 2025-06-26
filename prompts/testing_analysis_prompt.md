# Testing Structure Analysis Prompt

## Objective
Analyze the current testing structures for the project and generate a comprehensive Markdown document that evaluates the testing framework, identifies gaps, and provides recommendations for achieving optimal code coverage while ensuring proper separation of unit and integration tests.

## Analysis Requirements

### 1. Current Testing Framework Assessment
- **Testing Framework**: Identify the current testing framework in use (JUnit 5, TestNG, etc.)
- **Build Configuration**: Analyze build.gradle.kts/pom.xml for testing dependencies and configuration
- **Test Structure**: Examine the current test directory structure and organization
- **Naming Conventions**: Assess current test naming patterns (*Test.java/.kt vs *IT.java/.kt)
- **Test Categories**: Identify how unit vs integration tests are currently organized

### 2. Coverage Analysis
- **Current Coverage Metrics**: Extract JaCoCo coverage percentages by component
- **Coverage Configuration**: Review JaCoCo settings and thresholds in build configuration
- **Coverage Reports**: Analyze existing coverage reports location and format
- **Exclusions**: Document what is currently excluded from coverage analysis

### 3. Component Criticality Assessment
Analyze and rank components from most critical to least critical based on:
- **Business Logic Complexity**: Service layer components with core business rules
- **Data Integrity**: Repository and entity classes handling data persistence
- **Security Components**: Authentication, authorization, and validation logic
- **API Endpoints**: Controllers and REST endpoints for external interfaces
- **Configuration**: Critical application configuration and security setup
- **Utility Components**: Helper classes and utility functions

### 4. Unit Test Structure Evaluation
- **Test Organization**: Review current unit test structure and patterns
- **Mocking Strategy**: Assess use of Mockito/MockK for dependency isolation
- **Test Data Management**: Evaluate test data builders, fixtures, and object mothers
- **Assertion Patterns**: Review assertion libraries and patterns used
- **Test Performance**: Analyze unit test execution times and optimization needs

### 5. Integration Test Structure Evaluation
- **Test Containers Usage**: Assess current TestContainers setup for database testing
- **Spring Boot Test Configuration**: Review @SpringBootTest and slice test usage
- **External Dependencies**: Evaluate mocking of external services and APIs
- **Test Data Management**: Assess integration test data setup and cleanup
- **Environment Isolation**: Review test environment configuration and isolation

### 6. Task Separation Analysis
- **Build Task Configuration**: Analyze current Gradle/Maven task setup
- **Test Execution Strategy**: Review how unit vs integration tests are executed
- **CI/CD Integration**: Assess current pipeline test execution strategy
- **On-Demand Testing**: Evaluate current capability for selective test execution

## Expected Output Structure

Generate a Markdown document with the following sections:

### Executive Summary
- Overall testing maturity assessment
- Key gaps and immediate action items
- Current vs target coverage percentages

### Current Testing Configuration
- Framework versions and dependencies
- Build configuration summary
- Test execution setup

### Coverage Analysis
```markdown
## Current Coverage Summary

### Overall Coverage
- **Line Coverage**: X%
- **Branch Coverage**: X%
- **Method Coverage**: X%

### Coverage by Component Type
| Component Type | Current Coverage | Target Coverage | Gap |
|----------------|------------------|-----------------|-----|
| Service Layer  | X%              | 90%             | Y%  |
| Repository     | X%              | 85%             | Y%  |
| Controllers    | X%              | 85%             | Y%  |
| Entities       | X%              | 70%             | Y%  |
| Configuration  | X%              | 80%             | Y%  |
```

### Component Criticality Matrix
```markdown
## Component Priority for Testing (Most Critical → Least Critical)

### Critical Priority (Immediate Testing Required)
1. **[Component Name]**
   - **Type**: Service/Repository/Controller
   - **Risk Level**: High
   - **Current Coverage**: X%
   - **Required Tests**: 
     - Unit tests for [specific methods]
     - Integration tests for [specific scenarios]
   - **Business Impact**: [Description]

2. **[Component Name]**
   - [Same structure]

### High Priority
[Continue pattern]

### Medium Priority
[Continue pattern]

### Low Priority
[Continue pattern]
```

### Unit Test Recommendations
- Required unit tests by component
- Testing patterns to implement
- Mock strategy recommendations
- Test data management improvements

### Integration Test Recommendations
- Required integration test scenarios
- TestContainers setup improvements
- External service mocking strategy
- End-to-end test scenarios

### Task Separation Strategy
```markdown
## Test Execution Strategy

### Current Task Setup
- [Description of current Gradle/Maven task configuration]

### Recommended Task Structure
```gradle
// Unit Tests - Fast execution, part of build
tasks.register('unitTest', Test) {
    useJUnitPlatform {
        excludeTags 'integration'
    }
    group = 'verification'
    description = 'Runs unit tests only'
}

// Integration Tests - Slower execution, on-demand
tasks.register('integrationTest', Test) {
    useJUnitPlatform {
        includeTags 'integration'
    }
    group = 'verification'
    description = 'Runs integration tests only'
    shouldRunAfter tasks.unitTest
}

// Separate from main build
tasks.build {
    dependsOn tasks.unitTest
    // Integration tests NOT included in build
}
```

### Implementation Roadmap
- **Phase 1 (Immediate)**: Critical component testing
- **Phase 2 (Short-term)**: High priority components and task separation
- **Phase 3 (Medium-term)**: Complete coverage achievement
- **Phase 4 (Long-term)**: Advanced testing strategies

### Quality Gates
- Minimum coverage thresholds by component type
- Test execution time requirements
- Build pipeline integration requirements

## Analysis Instructions

1. **Examine Project Structure**: Review src/test directory organization and patterns
2. **Analyze Build Configuration**: Extract testing dependencies and JaCoCo setup
3. **Review Existing Tests**: Assess current test quality and coverage patterns
4. **Identify Critical Paths**: Map business-critical components and data flows
5. **Evaluate Test Separation**: Assess current unit vs integration test organization
6. **Calculate Coverage Gaps**: Determine specific testing needs per component
7. **Assess Task Configuration**: Review current build task setup for test execution

## Success Criteria

The generated document should provide:
- ✅ Clear understanding of current testing state
- ✅ Prioritized testing roadmap based on component criticality
- ✅ Specific coverage targets and gap analysis
- ✅ Proper separation of unit and integration tests
- ✅ Build configuration ensuring integration tests run on-demand only
- ✅ Actionable recommendations for immediate implementation
- ✅ Long-term testing strategy alignment with project goals

## Additional Considerations

- **Framework Compatibility**: Ensure recommendations align with Spring Boot 3.x and JUnit 5
- **Performance Impact**: Unit tests should complete quickly, integration tests should be optimized
- **Maintenance Burden**: Testing strategy should be sustainable and maintainable
- **Team Adoption**: Recommendations should be practical for current team skill level
- **CI/CD Integration**: Testing strategy should integrate well with build pipelines