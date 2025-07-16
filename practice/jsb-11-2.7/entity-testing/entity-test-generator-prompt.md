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

## Documentation Path:
Load `/mnt/D/SourceCode/claude-prompts/practice/jsb-11-2.7/`

## Step 1: Read Reference Documentation

**IMPORTANT**: Based on the test_type parameter, read the appropriate documentation:

- If test_type is "unit": Read `entity-testing/entity-unit-testing-best-practices.md`
- If test_type is "integration": Read `entity-testing/entity-integration-testing-best-practices.md`
- Always read `entity-testing/entity-test-refactoring-and-data-management.md` for test data builders and setup

## Step 2: Existing Test Analysis

**IMPORTANT**: Before generating new tests, analyze existing tests to avoid duplication and ensure consistency.

Search for existing test files related to the entity:
- Check `src/test/java/[package]/[Entity]Test.java` (unit tests)
- Check `src/test/java/[package]/[Entity]IntegrationTest.java` (integration tests)
- Look for related test files with variations in naming

If existing tests are found, analyze them and provide:

```
🔍 EXISTING TEST ANALYSIS
=========================
Found Tests: [List of existing test files]
Coverage Areas: [What's already tested]
Test Quality: [Assessment of existing test quality]
Gaps Identified: [What's missing or needs improvement]
Naming Convention: [Current naming pattern used]
Test Location: [Current directory structure]
```

**Interactive Confirmation for Test Location/Naming:**
```
Current test naming follows: [existing pattern]
Recommended best practice: [Entity][TestType]Test.java in src/test/java/[package]/

Should the test name and location be updated to follow best practices? (y/n):
[If yes, suggest specific changes and get confirmation]
```

## Step 3: Entity Analysis

Analyze the entity class at `{{entity_file_path}}` and provide:

```
📋 ENTITY ANALYSIS SUMMARY
========================
Entity Information:
├── Name: [EntityName]
├── Package: [package.path]
├── Table: [table name if specified]
├── Primary Key: [field name and type]
└── Test Type: {{test_type}}

Annotations Found:
├── Class Level: [@Entity, @Table, @EntityListeners, etc.]
├── Field Level: [@Id, @Column, @JoinColumn, etc.]
├── Validation: [@NotNull, @Size, @Email, etc.]
└── Relationship: [@OneToMany, @ManyToOne, @JoinTable, etc.]

Code Structure:
├── Fields: [count] fields ([count] with validation)
├── Constructors: [count] constructors
├── Business Methods: [list custom methods]
├── Lifecycle Callbacks: [@PrePersist, @PostUpdate, etc.]
├── Equals/HashCode: [implemented/not implemented]
└── ToString: [implemented/not implemented]

Entity Relationships:
├── One-To-Many: [list relationships]
├── Many-To-One: [list relationships]
├── One-To-One: [list relationships]
└── Many-To-Many: [list relationships]

Testing Complexity Assessment:
├── Overall Complexity: [Simple/Medium/Complex]
├── Validation Complexity: [Low/Medium/High]
├── Relationship Complexity: [Low/Medium/High]
└── Business Logic Complexity: [Low/Medium/High]
```

## Step 4: Interactive Test Generation by Priority

**NOTE**: If existing tests were found, focus strategy on filling gaps and improving coverage rather than duplicating existing tests.

Go through each test category individually. For each category:

1. **Present the category** and ask for confirmation
2. **If confirmed (y)**: Generate tests and provide explanations
3. **If declined (n)**: Skip to next category
4. **Move to next category** only after completing current one

### Available Test Categories:

#### CRITICAL TESTS (Must Have - 50% coverage)
These tests are essential for basic functionality and must be implemented.

#### HIGH PRIORITY TESTS (Should Have - 20% coverage) 
These tests cover important scenarios and edge cases that commonly occur.

#### MEDIUM PRIORITY TESTS (Nice to Have - 10% coverage)
These tests provide additional coverage for less common scenarios.

#### EDGE CASES (Optional - Additional coverage)
These tests handle unusual or boundary conditions.

## Per-Category Test Generation Flow

For each confirmed category, follow this exact sequence:

### Step 1: Present Category
```
=== GENERATING: [Category Name] TESTS ===
Should I generate [Category Name] tests? (y/n):
```

### Step 2: If Yes - Generate Tests
1. **Present the test subcategories** for this priority level
2. **For each subcategory**, ask for confirmation and generate if approved:

```
📝 [SUBCATEGORY NAME] TESTS
Purpose: [Brief explanation of why this subcategory is important]
Planned Tests: [List 2-5 specific test methods]

Generate [Subcategory Name] tests? (y/n):
```

3. **If confirmed**, generate the test code with explanations:

```
🧪 GENERATED TEST: [Test Method Name]
Explanation: [One paragraph explaining what this test does, why it's important, and what scenarios it covers]

[Generated test code]
```

### Step 3: Move to Next Category
```
✅ [Category Name] tests complete. Moving to next category...
```

## Final Steps

After all categories are processed:

### Step 5: Complete Test Class Assembly
Assemble all generated tests into the complete test class structure following the patterns from the reference documentation.

### Step 6: Test Execution Prompt
```
🏃 TEST EXECUTION
================
The test class has been generated. Should I help you run the tests to verify they work correctly? (y/n):

[If yes, provide commands to run tests and help debug any issues]
```

## Code Generation Guidelines

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

## Final Instructions

1. **Go through categories one by one** in sequential order
2. **For each category**: Present subcategories individually with y/n confirmation
3. **Generate tests immediately** after each subcategory confirmation
4. **Provide explanations** for each generated test method
5. **Complete full test class** assembly at the end
6. **Prompt for test execution** to help with debugging

## Starting Instructions

Begin by asking: "I'll generate the entity tests by category. Ready to start with the first category?"

Then proceed with entity analysis and interactive test generation.

Begin analysis now for entity at: `{{entity_file_path}}` with test type: `{{test_type}}`