# Entity Test Generator Prompt

name: "generate-entity-tests"
description: "Generate comprehensive unit or integration tests for Spring Boot 2.7 Java 11 entity classes with 80% coverage target"
parameters:
  - name: "entity_file_path"
    description: "Path to the JPA entity class file (e.g., src/main/java/com/example/User.java)"
    required: true
  - name: "test_type"
    description: "Type of tests to generate: 'unit' or 'integration'"
    required: true

---

You are an expert Java developer specializing in Spring Boot 2.7 and Java 11 entity testing. Your task is to analyze the provided entity class and generate comprehensive tests targeting 80% code coverage.

## Step 1: Read Reference Documentation

**IMPORTANT**: Based on the test_type parameter, read the appropriate documentation:

- If test_type is "unit": Read `entity-testing/entity-unit-testing-best-practices.md`
- If test_type is "integration": Read `entity-testing/entity-integration-testing-best-practices.md`
- Always read `entity-testing/entity-test-refactoring-and-data-management.md` for test data builders and setup

## Step 2: Entity Analysis

Analyze the entity class at `{{entity_file_path}}` and provide:

```
📋 ENTITY ANALYSIS SUMMARY
========================
Entity Name: [EntityName]
Package: [package.path]
Primary Key: [field name and type]
Validation Annotations: [list JSR-303 annotations found]
Relationships: [OneToMany, ManyToOne, etc.]
Custom Methods: [business methods, equals, hashCode]
Lifecycle Callbacks: [@PrePersist, @PostUpdate, etc.]
Test Type: {{test_type}}
Estimated Complexity: [Simple/Medium/Complex]
```

## Step 3: Test Strategy by Priority

Present test categories grouped by criticality with coverage estimates:

```
🎯 {{test_type|upper}} TEST STRATEGY (Target: 80% Coverage)
========================================================

CRITICAL TESTS (Must Have - 50% coverage):
□ [Test Category 1]
  Purpose: [Brief explanation of why this is critical]
  Tests: [List 3-5 specific test methods]

□ [Test Category 2]  
  Purpose: [Brief explanation]
  Tests: [List 3-5 specific test methods]

HIGH PRIORITY TESTS (Should Have - 20% coverage):
□ [Test Category 3]
  Purpose: [Brief explanation]
  Tests: [List 2-4 specific test methods]

□ [Test Category 4]
  Purpose: [Brief explanation]  
  Tests: [List 2-4 specific test methods]

MEDIUM PRIORITY TESTS (Nice to Have - 10% coverage):
□ [Test Category 5]
  Purpose: [Brief explanation]
  Tests: [List 1-3 specific test methods]

EDGE CASES (Optional - Additional coverage):
□ [Edge Case 1]: [Brief description]
□ [Edge Case 2]: [Brief description]
□ [Edge Case 3]: [Brief description]
□ [Edge Case 4]: [Brief description]
□ [Edge Case 5]: [Brief description]

Total Estimated Tests: [X] tests for [Y]% coverage
```

## Step 4: Interactive Test Selection

For each test category, ask for confirmation:

```
Generate CRITICAL tests? (y/n): 
Generate HIGH PRIORITY tests? (y/n):
Generate MEDIUM PRIORITY tests? (y/n):
Generate EDGE CASES? (y/n):
```

Then ask:
```
Do you want to specify any additional custom test cases? (y/n):
[If yes, wait for user input]
```

## Step 5: Test Class Generation

After user selections, generate the complete test class following the patterns from the reference documentation:

### For Unit Tests:
- Use `@ExtendWith(MockitoExtension.class)`
- Include validation setup with `Validator`
- Organize with `@Nested` classes
- Include test data builders
- Focus on business logic and validation

### For Integration Tests:
- Use `@DataJpaTest` 
- Include `TestEntityManager` and repository
- Test database persistence and constraints
- Include transaction testing
- Test entity relationships with database

## Code Generation Guidelines

### Test Method Naming
```java
@Test
@DisplayName("Should [expected behavior] when [condition]")
void should[Behavior]When[Condition]() {
    // Given-When-Then structure
}
```

### Test Organization
```java
@DisplayName("[Entity] {{test_type|title}} Tests")
class [Entity]{{test_type|title}}Test {
    
    @Nested
    @DisplayName("[Category] Tests")
    class [Category]Tests {
        // Related tests grouped together
    }
}
```

### Java 11 Features
- Use `var` for local variables
- Use modern string methods (`isBlank()`, `strip()`)
- Use `List.of()` for immutable collections
- Use enhanced Optional methods

## File Organization

Create tests in standard structure:
- **Unit tests**: `src/test/java/[package]/[Entity]Test.java`
- **Integration tests**: `src/test/java/[package]/[Entity]IntegrationTest.java`
- **Test builders**: `src/test/java/[package]/[Entity]TestDataBuilder.java`

## Success Criteria

Generated tests must:
- ✅ Achieve 80%+ code coverage
- ✅ Follow reference documentation patterns
- ✅ Use proper annotations and structure
- ✅ Include comprehensive assertions
- ✅ Be maintainable and readable
- ✅ Execute efficiently
- ✅ Be independent and repeatable

## Output Format

1. **Entity Analysis Summary**
2. **Test Strategy with Priority Groups**
3. **Interactive Selection Prompts**
4. **Complete Generated Test Class(es)**
5. **Coverage Estimation**
6. **Next Steps Recommendations**

Begin analysis now for entity at: `{{entity_file_path}}` with test type: `{{test_type}}`