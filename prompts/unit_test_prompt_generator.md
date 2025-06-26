# Unit Test Prompt Generator

## Overview
This document generates specific unit test prompts based on the testing analysis results. Supply a scope (critical/high/medium/low priority), specific test name, or class name to receive a targeted prompt for generating comprehensive unit tests.

## Usage Instructions

### Input Types
1. **Priority Scope**: "critical", "high", "medium", "low" - generates prompts for all components in that priority level
2. **Specific Component**: Component name from the analysis document (e.g., "UserService", "OrderRepository")
3. **Class Name**: Exact class name for targeted unit test generation

### Prompt Template Structure

---

## Unit Test Generation Prompt Template

### Context Information
**Project Framework**: Spring Boot 3.x with Kotlin/Java
**Testing Framework**: JUnit 5 (Jupiter) - MANDATORY
**Mocking Framework**: MockK (Kotlin) / Mockito (Java)
**Coverage Target**: [Extracted from analysis document]
**Component Priority**: [Critical/High/Medium/Low]
**Business Impact**: [Extracted from analysis document]

### Component Analysis Reference
**Source Document**: [Reference to testing analysis document]
**Component Details**: [Extracted from component criticality matrix]
**Current Coverage**: [X%]
**Target Coverage**: [Y%]
**Gap Analysis**: [Specific areas needing coverage]

### Class-Specific Requirements

#### Class: `[ClassName]`
**Package**: `[com.company.domain.service]`
**Type**: [Service/Repository/Controller/Component]
**Dependencies**: [List of injected dependencies]
**Key Responsibilities**: [Primary business logic handled]

#### Methods to Test (Priority Order):
1. **[methodName1]**
   - **Complexity**: High/Medium/Low
   - **Business Logic**: [Description]
   - **Edge Cases**: [List specific scenarios]
   - **Mocking Required**: [Dependencies to mock]

2. **[methodName2]**
   - [Same structure]

### Unit Test Requirements

#### Framework Specifications
```kotlin
// MANDATORY: Use JUnit 5 Jupiter
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.extension.ExtendWith

// MANDATORY: Use MockK for Kotlin / Mockito for Java
import io.mockk.*
import org.assertj.core.api.Assertions.*

// NEVER use kotlin.test imports
// NEVER use JUnit 4 imports
```

#### Test Structure Requirements
1. **Test Class Naming**: `[ClassName]Test`
2. **Test Method Naming**: `should_[expected_behavior]_when_[condition]()`
3. **Test Organization**: Use `@Nested` classes for logical grouping
4. **Assertion Library**: AssertJ for fluent assertions
5. **Mock Management**: Create mocks in `@BeforeEach`, reset in `@AfterEach`

#### Coverage Requirements
- **Line Coverage**: Minimum [X]% for this component
- **Branch Coverage**: All conditional logic paths
- **Edge Cases**: Null inputs, empty collections, boundary values
- **Error Scenarios**: Exception handling and validation failures
- **Business Rules**: All domain-specific logic validation

### Test Scenarios to Generate

#### 1. Happy Path Tests
- Valid input scenarios with expected outputs
- Successful business operation flows
- Proper dependency interaction verification

#### 2. Edge Case Tests
- Boundary value testing
- Empty/null input handling
- Maximum/minimum value scenarios
- Collection edge cases (empty, single item, large collections)

#### 3. Error Handling Tests
- Invalid input validation
- Exception propagation
- Business rule violations
- External dependency failures

#### 4. Integration Boundary Tests
- Dependency interaction verification
- Data transformation accuracy
- State change validation
- Side effect verification

### Mock Strategy

#### Dependencies to Mock:
[List specific dependencies extracted from class analysis]

#### Mock Behavior Patterns:
```kotlin
// Example mock setup pattern
@MockK
private lateinit var [dependencyName]: [DependencyType]

@BeforeEach
fun setup() {
    [className] = [ClassName]([dependencies])
}
```

#### Verification Requirements:
- Verify correct method calls on dependencies
- Verify argument matching for complex objects
- Verify call sequences for multi-step operations
- Verify no unintended side effects

### Test Data Requirements

#### Test Data Builders
Generate test data builders following the pattern:
```kotlin
object [ClassName]TestDataBuilder {
    fun a[ClassName]() = [ClassName]Builder()
    
    class [ClassName]Builder {
        private var field1: Type = defaultValue
        
        fun withField1(value: Type) = apply { this.field1 = value }
        fun build() = [ClassName](field1, ...)
    }
}
```

#### Test Fixtures
- Valid business objects for positive tests
- Invalid objects for validation tests
- Edge case data for boundary testing
- Minimal and maximal data sets

### Performance Requirements
- **Unit Test Speed**: Each test should complete under 100ms
- **Test Isolation**: Tests must be independent and order-agnostic
- **Resource Usage**: Minimal memory footprint per test
- **Parallel Execution**: Tests should support parallel execution

### Code Quality Standards

#### Code Organization
```kotlin
@ExtendWith(MockKExtension::class)
class [ClassName]Test {
    
    @MockK
    private lateinit var dependency1: Dependency1Type
    
    @MockK
    private lateinit var dependency2: Dependency2Type
    
    private lateinit var [instanceName]: [ClassName]
    
    @BeforeEach
    fun setup() {
        [instanceName] = [ClassName](dependency1, dependency2)
    }
    
    @Nested
    @DisplayName("[MethodName] method tests")
    inner class [MethodName]Tests {
        
        @Test
        fun `should [expected behavior] when [condition]`() {
            // Given
            val input = a[InputType]().build()
            every { dependency.method() } returns expectedValue
            
            // When
            val result = [instanceName].[methodName](input)
            
            // Then
            assertThat(result).isEqualTo(expectedResult)
            verify { dependency.method() }
        }
    }
}
```

#### Required Test Patterns
1. **Given-When-Then** structure
2. **Descriptive test names** explaining behavior
3. **Proper mock setup** and verification
4. **Clear assertions** with meaningful error messages
5. **Test data isolation** between tests

### Reference Documentation

#### Spring Boot Testing Guidelines
- **Source**: `testing/strategies/unit-testing-strategy.md`
- **Key Requirements**: [Extract relevant sections]
- **Framework Patterns**: [Reference specific patterns]

#### Project-Specific Standards
- **Source**: `testing/strategies/[framework]-testing-strategy.md`
- **Naming Conventions**: [Project-specific patterns]
- **Architecture Patterns**: [Layer-specific requirements]

#### Code Quality Requirements
- **Source**: Project knowledge quality guidelines
- **Coverage Thresholds**: [Component-specific targets]
- **Performance Benchmarks**: [Test execution requirements]

### Generation Instructions

#### Output Requirements
1. **Complete Test Class**: Fully functional test class with all imports
2. **Comprehensive Coverage**: Tests for all public methods and scenarios
3. **Production Ready**: Code following all project standards and patterns
4. **Documentation**: Clear comments explaining complex test scenarios
5. **Maintainable**: Easy to understand and modify tests

#### Quality Checklist
- [ ] Uses JUnit 5 (Jupiter) exclusively
- [ ] Follows project naming conventions
- [ ] Achieves target coverage percentage
- [ ] Includes all edge cases and error scenarios
- [ ] Proper mock setup and verification
- [ ] Fast execution (under 100ms per test)
- [ ] Independent and isolated tests
- [ ] Clear and descriptive test names
- [ ] Follows Given-When-Then pattern
- [ ] Uses appropriate assertion library

#### Validation Steps
1. Verify all imports are correct (JUnit 5, not kotlin.test)
2. Confirm test naming follows conventions
3. Validate mock setup and verification patterns
4. Check coverage of all business logic paths
5. Ensure test data builders are included
6. Verify error scenario coverage
7. Confirm performance requirements met

### Output Format
Generate the complete unit test class as a single file with:
- All necessary imports
- Proper class structure with nested test groups
- Complete test methods covering all scenarios
- Test data builders and fixtures
- Clear documentation and comments

---

## Scope-Specific Prompt Variants

### For Critical Priority Components
**Additional Requirements**:
- 95% minimum coverage target
- Exhaustive edge case testing
- Performance benchmarking tests
- Security validation tests
- Business rule validation tests

### For High Priority Components  
**Additional Requirements**:
- 90% minimum coverage target
- Core business logic focus
- Integration boundary testing
- Error handling validation

### For Medium Priority Components
**Additional Requirements**:
- 85% minimum coverage target
- Primary functionality focus
- Basic edge case coverage
- Standard error handling

### For Low Priority Components
**Additional Requirements**:
- 80% minimum coverage target
- Core functionality only
- Basic validation coverage
- Essential error scenarios

## Usage Examples

### Example 1: Priority Scope Request
**Input**: "Generate unit test prompts for critical priority components"
**Output**: Individual prompts for each critical component with 95% coverage requirements

### Example 2: Specific Component Request  
**Input**: "Generate unit test prompt for UserService"
**Output**: Targeted prompt for UserService with specific method analysis and requirements

### Example 3: Class Name Request
**Input**: "Generate unit test prompt for com.company.service.OrderProcessingService"
**Output**: Detailed prompt with class-specific dependencies, methods, and test scenarios

## Integration with Testing Analysis

This prompt generator should be used in conjunction with the testing analysis document to:
1. Extract component priority levels
2. Reference specific coverage gaps
3. Apply appropriate testing requirements
4. Ensure alignment with project testing strategy
5. Maintain consistency across all generated tests