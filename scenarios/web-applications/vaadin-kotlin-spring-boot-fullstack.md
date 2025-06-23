# Vaadin Kotlin Spring Boot Enterprise Web Application - Claude Code Instructions

## CONTEXT
**Project Type**: web-app
**Complexity**: complex
**Timeline**: production
**Architecture**: Full-stack enterprise web application with server-side rendering
**Last Updated**: 2025-06-18
**Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Primary Framework**: Vaadin 24.4.x (LTS)
- **Backend Framework**: Spring Boot 3.3.x
- **Language**: Kotlin 2.0.x
- **Runtime**: JDK 21 LTS
- **Build Tool**: Gradle 8.8.x with Kotlin DSL
- **Database**: PostgreSQL 16.x
- **ORM**: Spring Data JPA with Hibernate 6.x
- **Security**: Spring Security 6.x with form-based authentication
- **Testing**: JUnit 5 + Testcontainers + Vaadin TestBench
- **Documentation**: SpringDoc OpenAPI 3
- **Database Migration**: Flyway 10.x

### Project Structure
```
{{project_name}}/
├── src/
│   ├── main/
│   │   ├── kotlin/
│   │   │   └── {{base_package}}/
│   │   │       ├── Application.kt
│   │   │       ├── config/
│   │   │       │   ├── SecurityConfig.kt
│   │   │       │   ├── DatabaseConfig.kt
│   │   │       │   └── VaadinConfig.kt
│   │   │       ├── domain/
│   │   │       │   ├── entity/
│   │   │       │   │   ├── User.kt
│   │   │       │   │   ├── Role.kt
│   │   │       │   │   ├── Permission.kt
│   │   │       │   │   └── BaseEntity.kt
│   │   │       │   ├── repository/
│   │   │       │   │   ├── UserRepository.kt
│   │   │       │   │   ├── RoleRepository.kt
│   │   │       │   │   └── PermissionRepository.kt
│   │   │       │   └── service/
│   │   │       │       ├── UserService.kt
│   │   │       │       ├── SecurityService.kt
│   │   │       │       └── EmailService.kt
│   │   │       ├── presentation/
│   │   │       │   ├── view/
│   │   │       │   │   ├── MainLayout.kt
│   │   │       │   │   ├── login/
│   │   │       │   │   │   └── LoginView.kt
│   │   │       │   │   ├── dashboard/
│   │   │       │   │   │   └── DashboardView.kt
│   │   │       │   │   ├── user/
│   │   │       │   │   │   ├── UserListView.kt
│   │   │       │   │   │   ├── UserFormView.kt
│   │   │       │   │   │   └── UserProfileView.kt
│   │   │       │   │   ├── admin/
│   │   │       │   │   │   ├── AdminView.kt
│   │   │       │   │   │   ├── SystemConfigView.kt
│   │   │       │   │   │   └── UserManagementView.kt
│   │   │       │   │   └── error/
│   │   │       │   │       ├── ErrorView.kt
│   │   │       │   │       └── AccessDeniedView.kt
│   │   │       │   ├── component/
│   │   │       │   │   ├── layout/
│   │   │       │   │   │   ├── AppShell.kt
│   │   │       │   │   │   ├── HeaderComponent.kt
│   │   │       │   │   │   ├── SidebarComponent.kt
│   │   │       │   │   │   └── FooterComponent.kt
│   │   │       │   │   ├── form/
│   │   │       │   │   │   ├── UserForm.kt
│   │   │       │   │   │   ├── BaseForm.kt
│   │   │       │   │   │   └── ValidationUtils.kt
│   │   │       │   │   ├── grid/
│   │   │       │   │   │   ├── UserGrid.kt
│   │   │       │   │   │   ├── BaseGrid.kt
│   │   │       │   │   │   └── GridUtils.kt
│   │   │       │   │   └── dialog/
│   │   │       │   │       ├── ConfirmDialog.kt
│   │   │       │   │       ├── NotificationUtil.kt
│   │   │       │   │       └── BaseDialog.kt
│   │   │       │   └── dto/
│   │   │       │       ├── UserDto.kt
│   │   │       │       ├── DashboardStatsDto.kt
│   │   │       │       └── BaseDto.kt
│   │   │       ├── api/
│   │   │       │   ├── rest/
│   │   │       │   │   ├── UserController.kt
│   │   │       │   │   ├── DashboardController.kt
│   │   │       │   │   └── BaseController.kt
│   │   │       │   └── exception/
│   │   │       │       ├── GlobalExceptionHandler.kt
│   │   │       │       ├── ValidationException.kt
│   │   │       │       └── BusinessException.kt
│   │   │       ├── integration/
│   │   │       │   ├── email/
│   │   │       │   │   ├── EmailTemplateService.kt
│   │   │       │   │   └── EmailConfig.kt
│   │   │       │   └── external/
│   │   │       │       └── ExternalApiClient.kt
│   │   │       └── util/
│   │   │           ├── extension/
│   │   │           │   ├── StringExtensions.kt
│   │   │           │   ├── EntityExtensions.kt
│   │   │           │   └── VaadinExtensions.kt
│   │   │           ├── converter/
│   │   │           │   ├── EntityDtoConverter.kt
│   │   │           │   └── DateTimeConverter.kt
│   │   │           ├── validator/
│   │   │           │   ├── EmailValidator.kt
│   │   │           │   ├── PasswordValidator.kt
│   │   │           │   └── CustomValidators.kt
│   │   │           └── constants/
│   │   │               ├── SecurityConstants.kt
│   │   │               ├── ViewConstants.kt
│   │   │               └── AppConstants.kt
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-test.yml
│   │       ├── application-prod.yml
│   │       ├── db/migration/
│   │       │   ├── V1__Initial_schema.sql
│   │       │   ├── V2__Create_users_table.sql
│   │       │   ├── V3__Create_roles_permissions.sql
│   │       │   └── V4__Insert_default_data.sql
│   │       ├── META-INF/
│   │       │   └── resources/
│   │       │       ├── frontend/
│   │       │       │   ├── themes/
│   │       │       │   │   └── {{app_theme}}/
│   │       │       │   │       ├── theme.json
│   │       │       │   │       ├── styles.css
│   │       │       │   │       └── components/
│   │       │       │   │           ├── vaadin-app-layout.css
│   │       │       │   │           ├── vaadin-button.css
│   │       │       │   │           └── vaadin-grid.css
│   │       │       │   ├── styles/
│   │       │       │   │   ├── shared-styles.css
│   │       │       │   │   ├── views/
│   │       │       │   │   │   ├── main-layout.css
│   │       │       │   │   │   ├── dashboard.css
│   │       │       │   │   │   └── login.css
│   │       │       │   │   └── components/
│   │       │       │   │       ├── forms.css
│   │       │       │   │       ├── grids.css
│   │       │       │   │       └── dialogs.css
│   │       │       │   ├── images/
│   │       │       │   │   ├── logo.png
│   │       │       │   │   ├── avatar-placeholder.png
│   │       │       │   │   └── icons/
│   │       │       │   │       ├── dashboard.svg
│   │       │       │   │       ├── users.svg
│   │       │       │   │       └── settings.svg
│   │       │       │   └── index.html
│   │       │       └── icons/
│   │       │           ├── icon-16.png
│   │       │           ├── icon-32.png
│   │       │           ├── icon-144.png
│   │       │           └── icon-192.png
│   │       └── templates/
│   │           ├── email/
│   │           │   ├── welcome-email.html
│   │           │   ├── password-reset.html
│   │           │   └── notification-email.html
│   │           └── reports/
│   │               ├── user-report.jrxml
│   │               └── dashboard-export.jrxml
│   └── test/
│       ├── kotlin/
│       │   └── {{base_package}}/
│       │       ├── integration/
│       │       │   ├── AbstractIntegrationTest.kt
│       │       │   ├── UserRepositoryIT.kt
│       │       │   ├── UserServiceIT.kt
│       │       │   └── SecurityConfigIT.kt
│       │       ├── repository/
│       │       │   ├── UserRepositoryTest.kt
│       │       │   ├── RoleRepositoryTest.kt
│       │       │   └── RepositoryTestConfig.kt
│       │       ├── service/
│       │       │   ├── UserServiceTest.kt
│       │       │   ├── SecurityServiceTest.kt
│       │       │   └── EmailServiceTest.kt
│       │       ├── view/
│       │       │   ├── AbstractViewTest.kt
│       │       │   ├── LoginViewTest.kt
│       │       │   ├── DashboardViewTest.kt
│       │       │   └── UserListViewTest.kt
│       │       ├── api/
│       │       │   ├── UserControllerTest.kt
│       │       │   ├── DashboardControllerTest.kt
│       │       │   └── AbstractControllerTest.kt
│       │       └── util/
│       │           ├── TestDataBuilder.kt
│       │           ├── TestContainerConfig.kt
│       │           └── MockSecurityContext.kt
│       └── resources/
│           ├── application-test.yml
│           ├── testdata/
│           │   ├── users.sql
│           │   ├── roles.sql
│           │   └── test-schema.sql
│           └── logback-test.xml
├── gradle/
│   └── wrapper/
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
├── docker-compose.yml
├── docker-compose.override.yml
├── Dockerfile
├── Dockerfile.dev
├── .gitignore
├── .editorconfig
├── README.md
├── CHANGELOG.md
└── docs/
    ├── api/
    │   └── README.md
    ├── deployment/
    │   ├── docker.md
    │   ├── kubernetes.md
    │   └── production-checklist.md
    └── development/
        ├── setup.md
        ├── coding-standards.md
        └── testing-guide.md
```

### Documentation Sources
- **Vaadin Documentation**: https://vaadin.com/docs/latest
- **Spring Boot Reference**: https://docs.spring.io/spring-boot/docs/current/reference/html/
- **Kotlin Documentation**: https://kotlinlang.org/docs/home.html
- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
- **Spring Security**: https://docs.spring.io/spring-security/reference/
- **Gradle Kotlin DSL**: https://docs.gradle.org/current/userguide/kotlin_dsl.html
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/16/
- **Flyway Documentation**: https://flywaydb.org/documentation/

## STRICT GUIDELINES

### Code Standards
- **Kotlin Style**: Follow Kotlin Coding Conventions and ktlint rules
- **Spring Boot**: Use constructor injection only, no field injection
- **Vaadin**: Implement proper Component-Service separation pattern
- **Database**: Use Flyway migrations for all schema changes
- **Security**: Implement method-level security annotations
- **Naming Conventions**:
  - Entities: PascalCase singular (User, Role, Permission)
  - Services: PascalCase with 'Service' suffix (UserService, SecurityService)
  - Repositories: PascalCase with 'Repository' suffix (UserRepository)
  - Views: PascalCase with 'View' suffix (DashboardView, UserListView)
  - Components: PascalCase with 'Component' suffix (HeaderComponent)
  - DTOs: PascalCase with 'Dto' suffix (UserDto, DashboardStatsDto)
  - Constants: UPPER_SNAKE_CASE in companion objects
  - Package names: lowercase with dots (com.company.app.domain.entity)

### Architecture Rules
- **Clean Architecture**: Separate domain, application, and presentation layers
- **Dependency Direction**: Dependencies point inward (UI → Service → Repository)
- **Single Responsibility**: Each class serves one primary purpose
- **Vaadin Component Hierarchy**: Proper component composition and reuse
- **Security by Design**: Security considerations in every component
- **Immutability**: Prefer immutable data classes where possible
- **Error Handling**: Consistent exception handling with user-friendly messages

### Kotlin Best Practices
- Use data classes for DTOs and value objects
- Leverage sealed classes for state representation
- Prefer extension functions over utility classes
- Implement proper null safety with nullable types
- Use companion objects for constants and factory methods
- Utilize Kotlin-specific Spring annotations (@Autowired not needed)
- Apply scope functions (let, run, with, apply, also) appropriately

### Vaadin Best Practices
- **Component Lifecycle**: Proper component initialization and cleanup
- **State Management**: Server-side state with session scoping
- **UI Thread Safety**: All UI updates on UI thread
- **Resource Management**: Proper disposal of resources and listeners
- **Performance**: Lazy loading and pagination for large datasets
- **Responsive Design**: Mobile-friendly layouts and components
- **Accessibility**: ARIA attributes and keyboard navigation support

## TESTING REQUIREMENTS

### Unit Tests (90% coverage minimum)
- All service layer methods with business logic
- All repository custom queries and methods
- All utility functions and extension methods
- All validation logic and custom validators
- All security configuration components
- All data transformation and mapping logic

### Integration Tests
- Database operations with Testcontainers PostgreSQL
- Spring Security configuration and authentication flows
- Vaadin view rendering and component interaction
- Email service integration and template processing
- External API integrations with mock servers
- End-to-end user workflows

### UI Tests (Critical flows only)
- User authentication and session management
- Main navigation and view transitions
- Form validation and submission workflows
- Grid operations (filtering, sorting, pagination)
- Administrative functions and user management
- Error handling and user feedback

### Performance Tests
- Database query performance under load
- Vaadin UI rendering performance with large datasets
- Concurrent user session management
- Memory usage and garbage collection efficiency
- Application startup time and resource initialization

## SECURITY PRACTICES

### Authentication & Authorization
- Form-based authentication with Spring Security
- Role-based access control (RBAC) with method-level security
- Password encryption with BCrypt
- Session management with secure cookies
- Remember-me functionality with secure tokens
- Account lockout after failed login attempts
- Password complexity requirements and validation

### Data Protection
- Database connection encryption (SSL/TLS)
- Sensitive data encryption at rest
- Input validation and sanitization on all forms
- SQL injection prevention with parameterized queries
- XSS protection with Vaadin's built-in escaping
- CSRF protection enabled by default
- Audit logging for all data modifications

### Vaadin Security
- View-level security with @RolesAllowed annotations
- Component-level security for sensitive operations
- Server-side validation for all user inputs
- Secure session handling with automatic timeout
- Protection against UI redressing attacks
- Secure file upload handling with type validation

### API Security
- RESTful API endpoints secured with Spring Security
- JWT token support for API authentication (optional)
- Rate limiting for API endpoints
- CORS configuration for allowed origins
- API versioning strategy for backward compatibility
- Comprehensive request/response logging for audit

## IMPLEMENTATION STRATEGY

### Phase 1: Foundation Setup (Week 1-2)
- [ ] Initialize Spring Boot project with Vaadin and Kotlin
- [ ] Configure Gradle build with all required dependencies
- [ ] Set up PostgreSQL database with Docker Compose
- [ ] Configure application properties for all environments
- [ ] Create base entity classes with JPA annotations
- [ ] Set up Flyway database migrations with initial schema
- [ ] Configure Spring Security with basic form authentication
- [ ] Create main application layout and routing structure
- [ ] Set up testing infrastructure with Testcontainers
- [ ] Configure logging with structured output

### Phase 2: Core Domain Implementation (Week 3-4)
- [ ] Implement User, Role, and Permission entities with relationships
- [ ] Create repository interfaces with custom query methods
- [ ] Develop service layer with business logic and validation
- [ ] Implement Spring Security UserDetailsService
- [ ] Create data transfer objects (DTOs) for API responses
- [ ] Set up email service with template support
- [ ] Implement audit logging for entity changes
- [ ] Create comprehensive validation framework
- [ ] Add database seed data with default admin user
- [ ] Implement password reset functionality

### Phase 3: Vaadin UI Development (Week 5-8)
- [ ] Design and implement MainLayout with responsive navigation
- [ ] Create LoginView with proper error handling
- [ ] Build DashboardView with key metrics and charts
- [ ] Implement UserListView with grid, filtering, and sorting
- [ ] Create UserFormView for user creation and editing
- [ ] Build UserProfileView for self-service user management
- [ ] Implement AdminView with system configuration options
- [ ] Create reusable form components and validation
- [ ] Add confirmation dialogs and user feedback notifications
- [ ] Implement responsive design for tablet and mobile devices
- [ ] Create custom CSS theme following brand guidelines
- [ ] Add accessibility features and keyboard navigation

### Phase 4: Advanced Features (Week 9-12)
- [ ] Implement comprehensive role-based access control
- [ ] Add real-time notifications with server push
- [ ] Create data export functionality (Excel, PDF, CSV)
- [ ] Implement advanced search and filtering capabilities
- [ ] Add batch operations for user management
- [ ] Create system configuration management interface
- [ ] Implement email templates and notification system
- [ ] Add file upload and management capabilities
- [ ] Create audit trail and activity logging views
- [ ] Implement data backup and restore functionality
- [ ] Add system health monitoring dashboard
- [ ] Create comprehensive help system and user documentation

### Phase 5: Testing, Optimization & Deployment (Week 13-16)
- [ ] Complete comprehensive test suite with high coverage
- [ ] Perform security audit and penetration testing
- [ ] Optimize database queries and implement caching
- [ ] Load testing with realistic user scenarios
- [ ] Performance optimization and memory profiling
- [ ] Production deployment pipeline with Docker
- [ ] Set up monitoring and alerting infrastructure
- [ ] Create deployment documentation and runbooks
- [ ] Implement backup and disaster recovery procedures
- [ ] User acceptance testing and feedback incorporation
- [ ] Security hardening and compliance validation
- [ ] Production readiness checklist completion

## CLAUDE_CODE_COMMANDS

### Initial Setup
```bash
# Create project directory
mkdir {{project_name}}
cd {{project_name}}

# Initialize Gradle project with Kotlin DSL
gradle init --type kotlin-application --dsl kotlin --project-name {{project_name}} --package {{base_package}}

# Start PostgreSQL with Docker Compose
docker-compose up -d
```

### Build Configuration (build.gradle.kts)
```kotlin
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "2.0.0"
    kotlin("plugin.spring") version "2.0.0"
    kotlin("plugin.jpa") version "2.0.0"
    kotlin("plugin.allopen") version "2.0.0"
    kotlin("plugin.noarg") version "2.0.0"
    id("org.springframework.boot") version "3.3.0"
    id("io.spring.dependency-management") version "1.1.5"
    id("com.vaadin") version "24.4.4"
    id("org.flywaydb.flyway") version "10.15.0"
    id("org.jlleitschuh.gradle.ktlint") version "12.1.1"
    id("jacoco")
    id("org.sonarqube") version "5.0.0.4638"
}

group = "{{base_package}}"
version = "1.0.0-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_21

repositories {
    mavenCentral()
    maven { url = uri("https://maven.vaadin.com/vaadin-addons") }
}

extra["vaadinVersion"] = "24.4.4"
extra["testcontainersVersion"] = "1.19.8"

dependencies {
    // Spring Boot Starters
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-mail")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-cache")
    
    // Vaadin
    implementation("com.vaadin:vaadin-spring-boot-starter") {
        exclude(group = "com.vaadin", module = "vaadin-dev-server")
    }
    implementation("com.vaadin:vaadin-core")
    implementation("com.vaadin:vaadin-lumo-theme")
    
    // Database
    implementation("org.postgresql:postgresql")
    implementation("org.flywaydb:flyway-core")
    implementation("org.flywaydb:flyway-database-postgresql")
    
    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    
    // Utilities
    implementation("org.apache.commons:commons-lang3")
    implementation("commons-io:commons-io:2.16.1")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.5.0")
    
    // Caching
    implementation("org.springframework.boot:spring-boot-starter-cache")
    implementation("com.github.ben-manes.caffeine:caffeine")
    
    // Email Templates
    implementation("org.springframework.boot:spring-boot-starter-thymeleaf")
    
    // Development Tools
    developmentOnly("org.springframework.boot:spring-boot-devtools")
    developmentOnly("org.springframework.boot:spring-boot-docker-compose")
    
    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.security:spring-security-test")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:postgresql")
    testImplementation("com.vaadin:vaadin-testbench-junit5")
    testImplementation("io.mockk:mockk:1.13.11")
    testImplementation("com.ninja-squad:springmockk:4.0.2")
    
    // Annotation Processors
    annotationProcessor("org.springframework.boot:spring-boot-configuration-processor")
}

dependencyManagement {
    imports {
        mavenBom("com.vaadin:vaadin-bom:${property("vaadinVersion")}")
        mavenBom("org.testcontainers:testcontainers-bom:${property("testcontainersVersion")}")
    }
}

allOpen {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}

noArg {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}

tasks.withType<KotlinCompile> {
    kotlinOptions {
        freeCompilerArgs = listOf("-Xjsr305=strict", "-Xjvm-default=all")
        jvmTarget = "21"
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
    finalizedBy(tasks.jacocoTestReport)
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
        xml.required.set(true)
        html.required.set(true)
    }
}

ktlint {
    version.set("1.3.0")
    android.set(false)
    outputToConsole.set(true)
    coloredOutput.set(true)
    verbose.set(true)
    filter {
        exclude("**/generated/**")
        include("**/kotlin/**")
    }
}

vaadin {
    if (project.hasProperty("productionMode")) {
        productionMode = true
    }
}
```

### Development Commands
```bash
# Start development server with hot reload
./gradlew bootRun

# Run tests with coverage
./gradlew test jacocoTestReport

# Run integration tests
./gradlew integrationTest

# Code quality checks
./gradlew ktlintCheck

# Fix code formatting
./gradlew ktlintFormat

# Build production JAR
./gradlew bootJar -Pproduction

# Run with production mode
./gradlew bootRun -Pproduction

# Database migration
./gradlew flywayMigrate

# Start with development profile
./gradlew bootRun --args='--spring.profiles.active=dev'
```

### Docker Commands
```bash
# Start development environment
docker-compose up -d

# Build production image
docker build -t {{project_name}}:latest .

# Run production container
docker run -p 8080:8080 {{project_name}}:latest

# View logs
docker-compose logs -f app

# Stop all services
docker-compose down
```

## VALIDATION_SCRIPTS

```kotlin
// Project structure validation
val requiredDirectories = listOf(
    "src/main/kotlin/${basePackage.replace('.', '/')}/domain/entity",
    "src/main/kotlin/${basePackage.replace('.', '/')}/domain/repository",
    "src/main/kotlin/${basePackage.replace('.', '/')}/domain/service",
    "src/main/kotlin/${basePackage.replace('.', '/')}/presentation/view",
    "src/main/kotlin/${basePackage.replace('.', '/')}/presentation/component",
    "src/main/kotlin/${basePackage.replace('.', '/')}/config",
    "src/main/resources/db/migration",
    "src/main/resources/META-INF/resources/frontend/themes",
    "src/test/kotlin/${basePackage.replace('.', '/')}/integration"
)

// Required dependencies validation
val requiredDependencies = listOf(
    "spring-boot-starter-web",
    "spring-boot-starter-data-jpa",
    "spring-boot-starter-security",
    "vaadin-spring-boot-starter",
    "postgresql",
    "flyway-core",
    "kotlin-reflect"
)

// Security configuration validation
val requiredSecurityFeatures = listOf(
    "@EnableWebSecurity",
    "@EnableMethodSecurity",
    "SecurityFilterChain",
    "UserDetailsService",
    "PasswordEncoder",
    "AuthenticationManager"
)

// Vaadin configuration validation
val requiredVaadinFeatures = listOf(
    "@PWA",
    "@Theme",
    "@Route",
    "@RolesAllowed",
    "MainLayout",
    "AppShell"
)

// Database migration validation
fun validateMigrations(): Boolean {
    val migrationDir = File("src/main/resources/db/migration")
    val migrations = migrationDir.listFiles { file -> 
        file.name.matches(Regex("V\\d+__.*\\.sql"))
    }
    return migrations?.isNotEmpty() == true
}

// Application properties validation
val requiredProperties = listOf(
    "spring.datasource.url",
    "spring.datasource.username",
    "spring.datasource.password",
    "spring.jpa.hibernate.ddl-auto",
    "spring.flyway.enabled",
    "vaadin.productionMode",
    "logging.level.com.{{company}}.{{project}}"
)
```

## PROJECT_VARIABLES
- **PROJECT_NAME**: {{project_name}}
- **BASE_PACKAGE**: {{base_package}}
- **DATABASE_NAME**: {{database_name}}
- **APP_THEME**: {{app_theme}}
- **COMPANY_NAME**: {{company_name}}
- **APPLICATION_TITLE**: {{application_title}}
- **DEPLOYMENT_ENV**: {{deployment_environment}}
- **EMAIL_FROM**: {{email_from_address}}
- **ADMIN_EMAIL**: {{admin_email_address}}

## CONDITIONAL_REQUIREMENTS

### IF deployment_environment == "kubernetes"
```yaml
# Additional Kubernetes configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{project_name}}
  labels:
    app: {{project_name}}
spec:
  replicas: 3
  selector:
    matchLabels:
      app: {{project_name}}
  template:
    metadata:
      labels:
        app: {{project_name}}
    spec:
      containers:
      - name: {{project_name}}
        image: {{project_name}}:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        - name: SPRING_DATASOURCE_URL
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: url
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: {{project_name}}-service
spec:
  selector:
    app: {{project_name}}
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: ClusterIP
```

### IF app_theme == "custom"
```css
/* Custom theme configuration */
/* src/main/resources/META-INF/resources/frontend/themes/{{app_theme}}/theme.json */
{
  "lumoImports": ["color", "typography", "sizing", "spacing", "style", "icons"],
  "documentCss": ["styles.css"],
  "importCss": ["components/vaadin-app-layout.css", "components/vaadin-button.css"]
}

/* src/main/resources/META-INF/resources/frontend/themes/{{app_theme}}/styles.css */
:root {
  --lumo-primary-color: #{{primary_color}};
  --lumo-primary-color-50pct: #{{primary_color}}80;
  --lumo-primary-color-10pct: #{{primary_color}}1a;
  --lumo-error-color: #{{error_color}};
  --lumo-success-color: #{{success_color}};
  --lumo-warning-color: #{{warning_color}};
}
```

### IF email_service == "enabled"
```kotlin
// Additional email configuration
@Configuration
@EnableConfigurationProperties(EmailProperties::class)
class EmailConfig {
    
    @Bean
    @ConditionalOnProperty(prefix = "app.email", name = ["enabled"], havingValue = "true")
    fun javaMailSender(emailProperties: EmailProperties): JavaMailSender {
        val mailSender = JavaMailSenderImpl()
        mailSender.host = emailProperties.host
        mailSender.port = emailProperties.port
        mailSender.username = emailProperties.username
        mailSender.password = emailProperties.password
        
        val props = mailSender.javaMailProperties
        props["mail.transport.protocol"] = "smtp"
        props["mail.smtp.auth"] = "true"
        props["mail.smtp.starttls.enable"] = "true"
        props["mail.debug"] = emailProperties.debug
        
        return mailSender
    }
}

@ConfigurationProperties(prefix = "app.email")
data class EmailProperties(
    val enabled: Boolean = false,
    val host: String = "localhost",
    val port: Int = 587,
    val username: String = "",
    val password: String = "",
    val debug: Boolean = false,
    val from: String = "noreply@{{company_name}}.com"
)
```

### IF monitoring == "enabled"
```kotlin
// Additional monitoring configuration
dependencies {
    implementation("io.micrometer:micrometer-registry-prometheus")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
}

// application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when-authorized
  metrics:
    export:
      prometheus:
        enabled: true
```

## INCLUDE_MODULES
- @include: audit-logging.md
- @include: email-templates.md
- @include: caching-strategies.md
- @include: monitoring-metrics.md
- @include: security-headers.md
- @include: file-upload-handling.md
- @include: data-export-functionality.md

## VALIDATION_CHECKLIST
- [ ] All Kotlin compilation errors resolved
- [ ] Spring Boot application starts without errors on all profiles
- [ ] Database migrations execute successfully
- [ ] All security configurations properly implemented and tested
- [ ] Vaadin UI renders correctly on desktop, tablet, and mobile
- [ ] All views accessible with proper role-based authorization
- [ ] Form validation working on client and server side
- [ ] Email service integration functional with templates
- [ ] All REST API endpoints properly secured and documented
- [ ] Test coverage above 90% for service and repository layers
- [ ] Integration tests pass with Testcontainers
- [ ] UI tests cover critical user workflows
- [ ] Performance requirements met under simulated load
- [ ] Security scan passes without critical vulnerabilities
- [ ] Docker image builds and runs successfully
- [ ] Application deploys successfully to target environment
- [ ] All external integrations working in production-like environment
- [ ] Monitoring and health checks configured and functional
- [ ] Backup and restore procedures tested
- [ ] Documentation complete and accurate

## PERFORMANCE_REQUIREMENTS
- **Page Load Time**: < 2 seconds for dashboard on desktop
- **Mobile Responsiveness**: Usable on devices with 4-inch screens
- **Database Query Time**: < 500ms for complex queries with proper indexing
- **Concurrent Users**: Support 500+ concurrent sessions
- **Memory Usage**: < 1GB heap under normal load with 100 active users
- **Response Time**: < 1 second for CRUD operations
- **Session Management**: Handle 1000+ concurrent sessions efficiently
- **File Upload**: Support files up to 50MB with progress indication
- **Data Export**: Generate reports with 10,000+ records in < 30 seconds

## MONITORING_AND_OBSERVABILITY
- **Application Metrics**: Custom business metrics with Micrometer
- **Health Checks**: Comprehensive health indicators for all dependencies
- **Logging**: Structured JSON logging with correlation IDs
- **User Activity Tracking**: Audit trail for all user actions
- **Performance Monitoring**: Response time and throughput metrics
- **Error Tracking**: Centralized error collection and alerting
- **Database Monitoring**: Query performance and connection pool metrics
- **Security Monitoring**: Failed login attempts and suspicious activity detection

## ACCESSIBILITY_REQUIREMENTS
- **WCAG 2.1 AA Compliance**: All UI components meet accessibility standards
- **Keyboard Navigation**: Full application usable without mouse
- **Screen Reader Support**: Proper ARIA attributes and semantic HTML
- **Color Contrast**: Minimum 4.5:1 contrast ratio for all text
- **Focus Management**: Clear focus indicators and logical tab order
- **Error Identification**: Clear error messages with programmatic identification
- **Resize Support**: Text can be resized up to 200% without horizontal scrolling
- **Alternative Text**: All images and icons have appropriate alt text

## DEPLOYMENT_CONFIGURATION

### Docker Configuration
```dockerfile
# Dockerfile
FROM eclipse-temurin:21-jre-alpine

# Create app directory
WORKDIR /app

# Copy the JAR file
COPY build/libs/{{project_name}}-*.jar app.jar

# Create non-root user
RUN addgroup -g 1001 appgroup && adduser -u 1001 -G appgroup -s /bin/sh -D appuser
RUN chown -R appuser:appgroup /app
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/{{database_name}}
      - SPRING_DATASOURCE_USERNAME=postgres
      - SPRING_DATASOURCE_PASSWORD=postgres
    depends_on:
      - db
      - redis
    restart: unless-stopped
    
  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_DB={{database_name}}
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    restart: unless-stopped
    
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    restart: unless-stopped
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
    restart: unless-stopped

volumes:
  postgres_data:
```

### Production Configuration
```yaml
# application-prod.yml
spring:
  datasource:
    url: ${DATABASE_URL:jdbc:postgresql://localhost:5432/{{database_name}}}
    username: ${DATABASE_USERNAME:{{database_name}}_user}
    password: ${DATABASE_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      leak-detection-threshold: 60000
      
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        jdbc:
          batch_size: 25
        order_inserts: true
        order_updates: true
        format_sql: false
        
  flyway:
    enabled: true
    validate-on-migrate: true
    out-of-order: false
    
  cache:
    type: caffeine
    caffeine:
      spec: maximumSize=1000,expireAfterWrite=10m
      
vaadin:
  productionMode: true
  
server:
  port: 8080
  compression:
    enabled: true
    mime-types: text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/json
  http2:
    enabled: true
    
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when-authorized
      
logging:
  level:
    com.{{company}}.{{project}}: INFO
    org.springframework.security: WARN
    com.vaadin: WARN
  pattern:
    console: "%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"
    file: "%d{ISO8601} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/{{project_name}}.log
    
app:
  security:
    jwt:
      secret: ${JWT_SECRET}
      expiration: 86400000 # 24 hours
    password:
      min-length: 8
      require-uppercase: true
      require-lowercase: true
      require-numbers: true
      require-special-chars: true
  email:
    enabled: ${EMAIL_ENABLED:true}
    host: ${EMAIL_HOST:smtp.gmail.com}
    port: ${EMAIL_PORT:587}
    username: ${EMAIL_USERNAME}
    password: ${EMAIL_PASSWORD}
    from: ${EMAIL_FROM:noreply@{{company_name}}.com}
  file-upload:
    max-size: 52428800 # 50MB
    allowed-types: image/jpeg,image/png,image/gif,application/pdf,text/plain
    storage-path: ${FILE_STORAGE_PATH:/app/uploads}
```

## SECURITY_HARDENING

### Additional Security Measures
```kotlin
// Security headers configuration
@Configuration
class SecurityHeadersConfig {
    
    @Bean
    fun securityHeadersFilter(): FilterRegistrationBean<SecurityHeadersFilter> {
        val registration = FilterRegistrationBean<SecurityHeadersFilter>()
        registration.filter = SecurityHeadersFilter()
        registration.addUrlPatterns("/*")
        registration.order = 1
        return registration
    }
}

class SecurityHeadersFilter : Filter {
    override fun doFilter(request: ServletRequest, response: ServletResponse, chain: FilterChain) {
        val httpResponse = response as HttpServletResponse
        
        // Security headers
        httpResponse.setHeader("X-Content-Type-Options", "nosniff")
        httpResponse.setHeader("X-Frame-Options", "DENY")
        httpResponse.setHeader("X-XSS-Protection", "1; mode=block")
        httpResponse.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
        httpResponse.setHeader("Content-Security-Policy", 
            "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'")
        httpResponse.setHeader("Referrer-Policy", "strict-origin-when-cross-origin")
        httpResponse.setHeader("Permissions-Policy", "geolocation=(), microphone=(), camera=()")
        
        chain.doFilter(request, response)
    }
}
```

### Rate Limiting Configuration
```kotlin
@Configuration
@EnableConfigurationProperties(RateLimitProperties::class)
class RateLimitConfig {
    
    @Bean
    fun rateLimitFilter(properties: RateLimitProperties): FilterRegistrationBean<RateLimitFilter> {
        val registration = FilterRegistrationBean<RateLimitFilter>()
        registration.filter = RateLimitFilter(properties)
        registration.addUrlPatterns("/api/*", "/login")
        registration.order = 2
        return registration
    }
}

@ConfigurationProperties(prefix = "app.rate-limit")
data class RateLimitProperties(
    val enabled: Boolean = true,
    val maxRequests: Int = 100,
    val windowSeconds: Int = 3600,
    val maxLoginAttempts: Int = 5,
    val loginWindowMinutes: Int = 15
)
```

## BUSINESS_LOGIC_EXAMPLES

### Core Business Entities
```kotlin
@Entity
@Table(name = "users")
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(unique = true, nullable = false)
    val email: String,
    
    @Column(nullable = false)
    val password: String,
    
    @Column(name = "first_name", nullable = false)
    val firstName: String,
    
    @Column(name = "last_name", nullable = false)
    val lastName: String,
    
    @Column(name = "phone_number")
    val phoneNumber: String? = null,
    
    @Column(name = "is_active", nullable = false)
    val isActive: Boolean = true,
    
    @Column(name = "email_verified", nullable = false)
    val emailVerified: Boolean = false,
    
    @Column(name = "last_login")
    val lastLogin: LocalDateTime? = null,
    
    @Column(name = "failed_login_attempts", nullable = false)
    val failedLoginAttempts: Int = 0,
    
    @Column(name = "locked_until")
    val lockedUntil: LocalDateTime? = null,
    
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "user_roles",
        joinColumns = [JoinColumn(name = "user_id")],
        inverseJoinColumns = [JoinColumn(name = "role_id")]
    )
    val roles: Set<Role> = emptySet()
) : BaseEntity() {
    
    val fullName: String
        get() = "$firstName $lastName"
    
    val isLocked: Boolean
        get() = lockedUntil?.isAfter(LocalDateTime.now()) ?: false
    
    fun hasRole(roleName: String): Boolean {
        return roles.any { it.name == roleName }
    }
    
    fun hasPermission(permissionName: String): Boolean {
        return roles.flatMap { it.permissions }.any { it.name == permissionName }
    }
}

@Entity
@Table(name = "roles")
data class Role(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(unique = true, nullable = false)
    val name: String,
    
    @Column(length = 500)
    val description: String? = null,
    
    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "role_permissions",
        joinColumns = [JoinColumn(name = "role_id")],
        inverseJoinColumns = [JoinColumn(name = "permission_id")]
    )
    val permissions: Set<Permission> = emptySet()
) : BaseEntity()

@Entity
@Table(name = "permissions")
data class Permission(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(unique = true, nullable = false)
    val name: String,
    
    @Column(length = 500)
    val description: String? = null,
    
    @Column(nullable = false)
    val resource: String,
    
    @Column(nullable = false)
    val action: String
) : BaseEntity()
```

This completes the comprehensive Vaadin Kotlin Spring Boot enterprise web application template. The template provides:

1. **Complete project structure** with all necessary packages and files
2. **Production-ready configuration** for all environments
3. **Comprehensive security implementation** with role-based access control
4. **Modern Vaadin UI architecture** with responsive design
5. **Full testing strategy** including unit, integration, and UI tests
6. **Docker deployment configuration** with monitoring and observability
7. **Performance optimization** and scalability considerations
8. **Security hardening** with rate limiting and security headers
9. **Complete build configuration** with Gradle Kotlin DSL

The template follows enterprise best practices and provides a solid foundation for building production-grade Vaadin applications with Kotlin and Spring Boot.