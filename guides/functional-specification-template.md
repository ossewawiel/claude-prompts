# Functional Specification Template - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: advanced
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Purpose
This template breaks down user functional requirements into actionable development steps with testing protocols and UI guidance for Claude Code implementation.

### Template Structure
Use this template when users provide functional specifications to create structured development plans.

## IMPLEMENTATION STRATEGY

### FUNCTIONAL SPECIFICATION BREAKDOWN

#### **1. REQUIREMENTS ANALYSIS**
```markdown
## Requirements Summary
- **Feature Name**: [Clear, concise name]
- **Business Purpose**: [Why this feature is needed]
- **User Types**: [Who will use this feature]
- **Priority**: [High/Medium/Low]
- **Complexity**: [Simple/Medium/Complex]
- **Estimated Development Time**: [Hours/Days]

## Functional Requirements
### Primary Functions
- [ ] [What the system must do - action verb + object]
- [ ] [Each requirement should be testable]
- [ ] [Use clear, unambiguous language]

### Secondary Functions  
- [ ] [Nice-to-have features]
- [ ] [Enhancement opportunities]

### Non-Functional Requirements
- [ ] **Performance**: [Response time, throughput requirements]
- [ ] **Security**: [Authentication, authorization, data protection]
- [ ] **Usability**: [User experience expectations]
- [ ] **Compatibility**: [Browser, device, platform requirements]
```

#### **2. USER STORIES & USE CASES**
```markdown
## User Stories
### Story 1: [User Role] wants to [Goal] so that [Benefit]
**Acceptance Criteria:**
- [ ] Given [precondition] when [action] then [expected result]
- [ ] Given [precondition] when [action] then [expected result]

**Test Scenarios:**
- [ ] Happy path: [Normal user flow]
- [ ] Edge case: [Boundary conditions]
- [ ] Error case: [What happens when things go wrong]

### Story 2: [Continue for each major user interaction]
```

#### **3. UI/UX SPECIFICATIONS**
```markdown
## User Interface Requirements

### Screen/Component Layout
**Screenshot/Wireframe Location**: [Specify where visual materials are located]
- [ ] **Desktop Layout**: [Describe layout for desktop screens]
- [ ] **Mobile Layout**: [Responsive design requirements]
- [ ] **Tablet Layout**: [Medium screen considerations]

### Visual Elements
- [ ] **Color Scheme**: [Primary, secondary colors]
- [ ] **Typography**: [Font families, sizes, weights]
- [ ] **Icons**: [Icon library, custom icons needed]
- [ ] **Branding**: [Logo placement, brand guidelines]

### Interaction Patterns
- [ ] **Navigation**: [How users move between sections]
- [ ] **Form Interactions**: [Input validation, submission flows]
- [ ] **Feedback**: [Loading states, success/error messages]
- [ ] **Accessibility**: [ARIA labels, keyboard navigation, screen reader support]

### Wireframe Requirements
If wireframes/mockups are provided:
- [ ] **Reference Images**: [List image files and their purpose]
- [ ] **Component Breakdown**: [Identify reusable components from wireframes]
- [ ] **Responsive Behavior**: [How layout adapts to different screen sizes]
```

#### **4. TECHNICAL ARCHITECTURE**
```markdown
## Technology Stack Selection
- [ ] **Frontend**: [React Next.js + MUI / Vaadin + Kotlin]
- [ ] **Backend**: [Spring Boot + Kotlin/Java]
- [ ] **Database**: [PostgreSQL/MariaDB]
- [ ] **Authentication**: [JWT/OAuth2/Spring Security]

## Data Model
### Entities Required
- [ ] **[Entity Name]**: [Fields, relationships, constraints]
- [ ] **[Entity Name]**: [Fields, relationships, constraints]

### Database Schema
- [ ] **Tables**: [Table structure, indexes, foreign keys]
- [ ] **Migrations**: [Database change scripts needed]
- [ ] **Seed Data**: [Initial data requirements]

## API Design
### Endpoints Required
- [ ] **GET /api/[resource]**: [Purpose, request/response format]
- [ ] **POST /api/[resource]**: [Purpose, request/response format]
- [ ] **PUT/PATCH /api/[resource]**: [Purpose, request/response format]
- [ ] **DELETE /api/[resource]**: [Purpose, request/response format]
```

#### **5. DEVELOPMENT BREAKDOWN**
```markdown
## Implementation Steps

### Phase 1: Foundation
- [ ] **Database Setup**
  - [ ] Create entity classes
  - [ ] Set up repositories
  - [ ] Create migration scripts
  - [ ] **Test**: Verify database connectivity and CRUD operations

- [ ] **API Layer**
  - [ ] Create controller classes
  - [ ] Implement service layer
  - [ ] Add request/response DTOs
  - [ ] **Test**: Unit tests for service methods, integration tests for endpoints

### Phase 2: Core Logic
- [ ] **Business Logic Implementation**
  - [ ] [Specific business rule 1]
  - [ ] [Specific business rule 2]
  - [ ] **Test**: Unit tests for business logic, mock external dependencies

- [ ] **Data Validation**
  - [ ] Input validation rules
  - [ ] Business rule validation
  - [ ] **Test**: Validation with valid/invalid data sets

### Phase 3: User Interface
- [ ] **Component Creation**
  - [ ] [Component 1: Purpose and functionality]
  - [ ] [Component 2: Purpose and functionality]
  - [ ] **Test**: Component unit tests, visual regression tests

- [ ] **Page/View Implementation**
  - [ ] [Page 1: Layout and interactions]
  - [ ] [Page 2: Layout and interactions]
  - [ ] **Test**: Integration tests, user journey tests

### Phase 4: Integration & Polish
- [ ] **Frontend-Backend Integration**
  - [ ] API client setup
  - [ ] Error handling
  - [ ] Loading states
  - [ ] **Test**: End-to-end user scenarios

- [ ] **Security Implementation**
  - [ ] Authentication flow
  - [ ] Authorization rules
  - [ ] **Test**: Security penetration testing, unauthorized access attempts

- [ ] **Performance Optimization**
  - [ ] Database query optimization
  - [ ] Frontend performance tuning
  - [ ] **Test**: Load testing, performance benchmarks
```

#### **6. TESTING STRATEGY**
```markdown
## Testing Approach

### Unit Testing
- [ ] **Backend Services**: [Service layer methods, business logic]
- [ ] **Frontend Components**: [Component behavior, props handling]
- [ ] **Database Repositories**: [CRUD operations, query methods]
- [ ] **Coverage Target**: [Minimum 80% code coverage]

### Integration Testing
- [ ] **API Testing**: [Endpoint behavior, request/response validation]
- [ ] **Database Integration**: [Entity relationships, transaction handling]
- [ ] **Frontend-Backend**: [Data flow, API communication]

### User Acceptance Testing
- [ ] **Happy Path Scenarios**: [Primary user workflows]
- [ ] **Edge Cases**: [Boundary conditions, unusual inputs]
- [ ] **Error Handling**: [System behavior during failures]
- [ ] **Cross-Browser Testing**: [Compatibility across browsers]
- [ ] **Mobile Testing**: [Responsive behavior, touch interactions]

### Performance Testing
- [ ] **Load Testing**: [Expected user load scenarios]
- [ ] **Stress Testing**: [System behavior under peak load]
- [ ] **Database Performance**: [Query execution times, index usage]

## Test Data Requirements
- [ ] **Sample Data**: [Realistic test data sets]
- [ ] **Edge Case Data**: [Boundary values, empty sets, large datasets]
- [ ] **Mock Services**: [External API responses, error conditions]
```

#### **7. VALIDATION CHECKLIST**
```markdown
## Implementation Validation

### Functional Validation
- [ ] All user stories implemented and tested
- [ ] All acceptance criteria met
- [ ] UI matches provided wireframes/specifications
- [ ] All API endpoints working as specified
- [ ] Database schema supports all requirements

### Quality Validation
- [ ] Code follows established coding standards
- [ ] All tests passing (unit, integration, e2e)
- [ ] Performance benchmarks met
- [ ] Security requirements satisfied
- [ ] Accessibility standards complied with

### Deployment Validation
- [ ] Application builds successfully
- [ ] Database migrations run without errors
- [ ] Environment configuration correct
- [ ] Monitoring and logging in place
- [ ] Backup and recovery procedures tested

## Documentation Updates
- [ ] API documentation updated
- [ ] User guide created/updated
- [ ] Technical documentation updated
- [ ] Deployment guide updated
```

## CLAUDE_CODE_COMMANDS

### Initial Analysis
```bash
# When starting a new functional specification
mkdir -p docs/specifications
touch docs/specifications/[feature-name]-spec.md
```

### Development Commands
```bash
# Testing commands to run at each phase
./gradlew test                    # Unit tests
./gradlew integrationTest         # Integration tests  
npm run test                      # Frontend tests
npm run test:e2e                  # End-to-end tests
```

### Validation Commands
```bash
# Code quality checks
./gradlew ktlintCheck            # Kotlin code style
npm run lint                     # JavaScript code style
./gradlew detekt                 # Kotlin static analysis
```

## VALIDATION_CHECKLIST
- [ ] Template structure covers all development phases
- [ ] Testing protocols defined for each implementation step
- [ ] UI/UX guidance includes wireframe and screenshot integration
- [ ] Technical architecture section matches available technology stack
- [ ] Development breakdown creates manageable, testable chunks
- [ ] Validation checklist ensures quality and completeness
- [ ] Template adaptable to different complexity levels
- [ ] Clear connection between requirements and implementation steps