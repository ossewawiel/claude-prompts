# Spring Boot Java GraphQL API - Claude Code Instructions

## CONTEXT
**Project Type**: backend-service
**Complexity**: complex
**Timeline**: production
**Architecture**: GraphQL API with Spring Boot and Java
**Last Updated**: 2025-06-18
**Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Primary Framework**: Spring Boot 3.3.x
- **Language**: Java 21 LTS
- **GraphQL Implementation**: Spring GraphQL 1.3.x
- **Runtime**: JDK 21 LTS
- **Build Tool**: Maven 3.9.x
- **Database**: PostgreSQL 16.x
- **ORM**: Spring Data JPA with Hibernate 6.x
- **Security**: Spring Security 6.x with JWT authentication
- **GraphQL Tools**: GraphQL Java 21.x, DataLoader 3.x
- **Testing**: JUnit 5 + Testcontainers + Mockito
- **Database Migration**: Flyway 10.x
- **Caching**: Redis 7.x with Spring Cache
- **Monitoring**: Micrometer + Prometheus
- **Documentation**: GraphiQL + GraphQL Voyager

### Project Structure
```
{{project_name}}/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── {{base_package}}/
│   │   │       ├── Application.java
│   │   │       ├── config/
│   │   │       │   ├── SecurityConfig.java
│   │   │       │   ├── GraphQLConfig.java
│   │   │       │   ├── DataLoaderConfig.java
│   │   │       │   ├── CacheConfig.java
│   │   │       │   ├── DatabaseConfig.java
│   │   │       │   └── AsyncConfig.java
│   │   │       ├── domain/
│   │   │       │   ├── entity/
│   │   │       │   │   ├── BaseEntity.java
│   │   │       │   │   ├── User.java
│   │   │       │   │   ├── Post.java
│   │   │       │   │   ├── Comment.java
│   │   │       │   │   ├── Category.java
│   │   │       │   │   ├── Tag.java
│   │   │       │   │   └── Author.java
│   │   │       │   ├── repository/
│   │   │       │   │   ├── UserRepository.java
│   │   │       │   │   ├── PostRepository.java
│   │   │       │   │   ├── CommentRepository.java
│   │   │       │   │   ├── CategoryRepository.java
│   │   │       │   │   ├── TagRepository.java
│   │   │       │   │   └── AuthorRepository.java
│   │   │       │   ├── service/
│   │   │       │   │   ├── UserService.java
│   │   │       │   │   ├── PostService.java
│   │   │       │   │   ├── CommentService.java
│   │   │       │   │   ├── CategoryService.java
│   │   │       │   │   ├── TagService.java
│   │   │       │   │   ├── AuthorService.java
│   │   │       │   │   ├── AuthenticationService.java
│   │   │       │   │   └── NotificationService.java
│   │   │       │   └── specification/
│   │   │       │       ├── PostSpecification.java
│   │   │       │       ├── UserSpecification.java
│   │   │       │       └── BaseSpecification.java
│   │   │       ├── graphql/
│   │   │       │   ├── resolver/
│   │   │       │   │   ├── query/
│   │   │       │   │   │   ├── UserQueryResolver.java
│   │   │       │   │   │   ├── PostQueryResolver.java
│   │   │       │   │   │   ├── CommentQueryResolver.java
│   │   │       │   │   │   ├── CategoryQueryResolver.java
│   │   │       │   │   │   └── SearchQueryResolver.java
│   │   │       │   │   ├── mutation/
│   │   │       │   │   │   ├── UserMutationResolver.java
│   │   │       │   │   │   ├── PostMutationResolver.java
│   │   │       │   │   │   ├── CommentMutationResolver.java
│   │   │       │   │   │   ├── AuthMutationResolver.java
│   │   │       │   │   │   └── CategoryMutationResolver.java
│   │   │       │   │   ├── subscription/
│   │   │       │   │   │   ├── PostSubscriptionResolver.java
│   │   │       │   │   │   ├── CommentSubscriptionResolver.java
│   │   │       │   │   │   └── NotificationSubscriptionResolver.java
│   │   │       │   │   └── type/
│   │   │       │   │       ├── PostResolver.java
│   │   │       │   │       ├── UserResolver.java
│   │   │       │   │       ├── CommentResolver.java
│   │   │       │   │       └── CategoryResolver.java
│   │   │       │   ├── dataloader/
│   │   │       │   │   ├── UserDataLoader.java
│   │   │       │   │   ├── PostDataLoader.java
│   │   │       │   │   ├── CommentDataLoader.java
│   │   │       │   │   ├── CategoryDataLoader.java
│   │   │       │   │   └── DataLoaderRegistry.java
│   │   │       │   ├── scalar/
│   │   │       │   │   ├── DateTimeScalar.java
│   │   │       │   │   ├── DateScalar.java
│   │   │       │   │   ├── EmailScalar.java
│   │   │       │   │   ├── UrlScalar.java
│   │   │       │   │   └── JsonScalar.java
│   │   │       │   ├── directive/
│   │   │       │   │   ├── AuthDirective.java
│   │   │       │   │   ├── RoleDirective.java
│   │   │       │   │   ├── RateLimitDirective.java
│   │   │       │   │   └── DeprecatedDirective.java
│   │   │       │   ├── input/
│   │   │       │   │   ├── CreateUserInput.java
│   │   │       │   │   ├── UpdateUserInput.java
│   │   │       │   │   ├── CreatePostInput.java
│   │   │       │   │   ├── UpdatePostInput.java
│   │   │       │   │   ├── CreateCommentInput.java
│   │   │       │   │   ├── FilterInput.java
│   │   │       │   │   ├── SortInput.java
│   │   │       │   │   └── PaginationInput.java
│   │   │       │   ├── type/
│   │   │       │   │   ├── UserType.java
│   │   │       │   │   ├── PostType.java
│   │   │       │   │   ├── CommentType.java
│   │   │       │   │   ├── CategoryType.java
│   │   │       │   │   ├── AuthPayload.java
│   │   │       │   │   ├── PageInfo.java
│   │   │       │   │   ├── Connection.java
│   │   │       │   │   └── Edge.java
│   │   │       │   ├── exception/
│   │   │       │   │   ├── GraphQLExceptionHandler.java
│   │   │       │   │   ├── AuthenticationException.java
│   │   │       │   │   ├── AuthorizationException.java
│   │   │       │   │   ├── ValidationException.java
│   │   │       │   │   ├── NotFoundException.java
│   │   │       │   │   └── BusinessException.java
│   │   │       │   ├── context/
│   │   │       │   │   ├── SecurityContext.java
│   │   │       │   │   ├── RequestContext.java
│   │   │       │   │   └── DataLoaderContext.java
│   │   │       │   └── instrumentation/
│   │   │       │       ├── TracingInstrumentation.java
│   │   │       │       ├── MetricsInstrumentation.java
│   │   │       │       ├── LoggingInstrumentation.java
│   │   │       │       └── SecurityInstrumentation.java
│   │   │       ├── security/
│   │   │       │   ├── JwtTokenProvider.java
│   │   │       │   ├── GraphQLAuthenticationInterceptor.java
│   │   │       │   ├── CustomUserDetailsService.java
│   │   │       │   ├── SecurityPrincipal.java
│   │   │       │   ├── GraphQLSecurityConfig.java
│   │   │       │   └── SecurityUtils.java
│   │   │       ├── validation/
│   │   │       │   ├── EmailValidator.java
│   │   │       │   ├── PasswordValidator.java
│   │   │       │   ├── GraphQLInputValidator.java
│   │   │       │   └── CustomConstraints.java
│   │   │       ├── util/
│   │   │       │   ├── GraphQLUtils.java
│   │   │       │   ├── CursorUtils.java
│   │   │       │   ├── SecurityUtils.java
│   │   │       │   ├── DateTimeUtils.java
│   │   │       │   └── ValidationUtils.java
│   │   │       └── monitoring/
│   │   │           ├── GraphQLMetrics.java
│   │   │           ├── QueryComplexityAnalyzer.java
│   │   │           ├── PerformanceInterceptor.java
│   │   │           └── SecurityEventLogger.java
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-test.yml
│   │       ├── application-prod.yml
│   │       ├── graphql/
│   │       │   ├── schema.graphqls
│   │       │   ├── types/
│   │       │   │   ├── user.graphqls
│   │       │   │   ├── post.graphqls
│   │       │   │   ├── comment.graphqls
│   │       │   │   ├── category.graphqls
│   │       │   │   ├── auth.graphqls
│   │       │   │   └── common.graphqls
│   │       │   ├── queries/
│   │       │   │   ├── user-queries.graphqls
│   │       │   │   ├── post-queries.graphqls
│   │       │   │   ├── search-queries.graphqls
│   │       │   │   └── admin-queries.graphqls
│   │       │   ├── mutations/
│   │       │   │   ├── auth-mutations.graphqls
│   │       │   │   ├── user-mutations.graphqls
│   │       │   │   ├── post-mutations.graphqls
│   │       │   │   └── comment-mutations.graphqls
│   │       │   ├── subscriptions/
│   │       │   │   ├── post-subscriptions.graphqls
│   │       │   │   ├── comment-subscriptions.graphqls
│   │       │   │   └── notification-subscriptions.graphqls
│   │       │   ├── directives/
│   │       │   │   ├── auth.graphqls
│   │       │   │   ├── role.graphqls
│   │       │   │   └── deprecated.graphqls
│   │       │   └── scalars/
│   │       │       ├── datetime.graphqls
│   │       │       ├── email.graphqls
│   │       │       ├── url.graphqls
│   │       │       └── json.graphqls
│   │       ├── db/migration/
│   │       │   ├── V1__Initial_schema.sql
│   │       │   ├── V2__Create_users_table.sql
│   │       │   ├── V3__Create_posts_table.sql
│   │       │   ├── V4__Create_comments_table.sql
│   │       │   ├── V5__Create_categories_table.sql
│   │       │   ├── V6__Create_tags_table.sql
│   │       │   ├── V7__Create_relationships.sql
│   │       │   ├── V8__Create_indexes.sql
│   │       │   └── V9__Insert_sample_data.sql
│   │       ├── static/
│   │       │   ├── graphiql/
│   │       │   │   ├── index.html
│   │       │   │   └── custom.css
│   │       │   └── voyager/
│   │       │       └── index.html
│   │       ├── templates/
│   │       │   ├── email/
│   │       │   │   ├── welcome.html
│   │       │   │   └── notification.html
│   │       │   └── reports/
│   │       │       └── user-activity.html
│   │       └── logback-spring.xml
│   └── test/
│       ├── java/
│       │   └── {{base_package}}/
│       │       ├── integration/
│       │       │   ├── AbstractIntegrationTest.java
│       │       │   ├── GraphQLIntegrationTest.java
│       │       │   ├── UserGraphQLIT.java
│       │       │   ├── PostGraphQLIT.java
│       │       │   ├── AuthGraphQLIT.java
│       │       │   └── SubscriptionIT.java
│       │       ├── graphql/
│       │       │   ├── resolver/
│       │       │   │   ├── UserQueryResolverTest.java
│       │       │   │   ├── PostQueryResolverTest.java
│       │       │   │   ├── UserMutationResolverTest.java
│       │       │   │   └── PostMutationResolverTest.java
│       │       │   ├── dataloader/
│       │       │   │   ├── UserDataLoaderTest.java
│       │       │   │   └── PostDataLoaderTest.java
│       │       │   ├── scalar/
│       │       │   │   ├── DateTimeScalarTest.java
│       │       │   │   └── EmailScalarTest.java
│       │       │   └── directive/
│       │       │       ├── AuthDirectiveTest.java
│       │       │       └── RoleDirectiveTest.java
│       │       ├── service/
│       │       │   ├── UserServiceTest.java
│       │       │   ├── PostServiceTest.java
│       │       │   └── AuthenticationServiceTest.java
│       │       ├── repository/
│       │       │   ├── UserRepositoryTest.java
│       │       │   ├── PostRepositoryTest.java
│       │       │   └── CommentRepositoryTest.java
│       │       ├── security/
│       │       │   ├── JwtTokenProviderTest.java
│       │       │   └── GraphQLSecurityTest.java
│       │       ├── util/
│       │       │   ├── TestDataBuilder.java
│       │       │   ├── GraphQLTestUtils.java
│       │       │   ├── TestContainerConfig.java
│       │       │   └── MockSecurityContext.java
│       │       └── performance/
│       │           ├── GraphQLPerformanceTest.java
│       │           ├── DataLoaderPerformanceTest.java
│       │           └── QueryComplexityTest.java
│       └── resources/
│           ├── application-test.yml
│           ├── graphql/
│           │   ├── test-queries/
│           │   │   ├── user-queries.graphql
│           │   │   ├── post-queries.graphql
│           │   │   └── auth-queries.graphql
│           │   └── test-mutations/
│           │       ├── user-mutations.graphql
│           │       └── post-mutations.graphql
│           ├── testdata/
│           │   ├── users.sql
│           │   ├── posts.sql
│           │   └── comments.sql
│           └── logback-test.xml
├── pom.xml
├── docker-compose.yml
├── docker-compose.override.yml
├── Dockerfile
├── .gitignore
├── .editorconfig
├── README.md
└── docs/
    ├── graphql/
    │   ├── schema-documentation.md
    │   ├── query-examples.md
    │   ├── mutation-examples.md
    │   └── subscription-examples.md
    ├── api/
    │   ├── authentication.md
    │   ├── authorization.md
    │   └── rate-limiting.md
    └── development/
        ├── setup.md
        ├── testing.md
        └── debugging.md
```

### Documentation Sources
- **Spring Boot Reference**: https://docs.spring.io/spring-boot/docs/current/reference/html/
- **Spring GraphQL Documentation**: https://docs.spring.io/spring-graphql/reference/
- **GraphQL Java Documentation**: https://www.graphql-java.com/documentation/
- **DataLoader Documentation**: https://github.com/graphql-java/java-dataloader
- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
- **Spring Security**: https://docs.spring.io/spring-security/reference/
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/16/
- **Flyway Documentation**: https://flywaydb.org/documentation/

## STRICT GUIDELINES

### Code Standards
- **Java Style**: Follow Google Java Style Guide
- **Spring Boot**: Use constructor injection only, no field injection
- **GraphQL Schema**: Schema-first approach with .graphqls files
- **API Design**: Follow GraphQL best practices and conventions
- **Database**: Use Flyway migrations for all schema changes
- **Security**: Implement field-level and operation-level security
- **Naming Conventions**:
  - Entities: PascalCase singular (User, Post, Comment)
  - Services: PascalCase with 'Service' suffix (UserService, PostService)
  - Repositories: PascalCase with 'Repository' suffix (UserRepository)
  - Resolvers: PascalCase with appropriate suffix (UserQueryResolver, PostMutationResolver)
  - GraphQL Types: PascalCase (User, Post, CreateUserInput)
  - GraphQL Fields: camelCase (firstName, createdAt, isPublished)
  - Constants: UPPER_SNAKE_CASE in static final fields
  - Package names: lowercase with dots (com.company.app.graphql.resolver)

### Architecture Rules
- **Schema-First Design**: Define GraphQL schema before implementation
- **Single Responsibility**: Each resolver handles one specific concern
- **DataLoader Pattern**: Use DataLoaders to solve N+1 query problems
- **Security by Design**: Implement authentication and authorization at schema level
- **Performance First**: Query complexity analysis and depth limiting
- **Error Handling**: Consistent GraphQL error responses with proper extensions
- **Caching Strategy**: Multi-level caching with Redis and in-memory caches

### GraphQL Best Practices
- **Schema Design**: Use unions and interfaces for polymorphic types
- **Pagination**: Implement Relay-style cursor pagination
- **Subscriptions**: Use for real-time features with proper filtering
- **Input Validation**: Validate all inputs at resolver level
- **Query Complexity**: Implement query complexity analysis
- **Depth Limiting**: Prevent deeply nested malicious queries
- **Field-Level Security**: Secure individual fields based on user context
- **Batching**: Use DataLoaders for efficient data fetching

### Java Best Practices
- Use Optional for nullable return types
- Implement proper exception handling with GraphQL error types
- Leverage CompletableFuture for asynchronous operations
- Use stream operations for data transformations
- Implement proper validation with Bean Validation
- Apply SOLID principles throughout the codebase
- Use dependency injection consistently

## TESTING REQUIREMENTS

### Unit Tests (90% coverage minimum)
- All service layer methods with business logic
- All GraphQL resolvers with mocked dependencies
- All repository custom queries and specifications
- All validation logic and custom validators
- All security components and JWT token handling
- All DataLoader implementations
- All custom scalar types and directives

### Integration Tests
- GraphQL query execution with real database
- Authentication and authorization flows
- Subscription functionality with WebSocket
- DataLoader batching and caching behavior
- Database operations with Testcontainers PostgreSQL
- Redis cache integration
- Error handling and exception scenarios

### GraphQL-Specific Tests
- Schema validation and introspection
- Query complexity analysis
- Depth limiting functionality
- Subscription filtering and lifecycle
- Custom scalar serialization/deserialization
- Directive functionality
- Query optimization with DataLoaders

### Performance Tests
- Query execution time under load
- DataLoader batching efficiency
- Concurrent subscription handling
- Memory usage with large result sets
- Database connection pooling under stress
- Cache hit ratios and performance impact

## SECURITY PRACTICES

### Authentication & Authorization
- JWT-based authentication with GraphQL context
- Field-level authorization with custom directives
- Role-based access control (RBAC)
- Operation-level security (query/mutation/subscription)
- Secure subscription filtering based on user context
- Token refresh mechanism for long-lived sessions

### GraphQL Security
- Query depth limiting to prevent deep nesting attacks
- Query complexity analysis to prevent expensive operations
- Rate limiting per user and operation type
- Input sanitization and validation
- Introspection disabled in production
- Query whitelisting for critical applications
- Timeout configuration for long-running operations

### Data Protection
- Field-level data masking based on user permissions
- Sensitive data encryption at rest
- Audit logging for all mutations
- CORS configuration for GraphQL endpoint
- HTTPS enforcement in production
- SQL injection prevention with parameterized queries

## IMPLEMENTATION STRATEGY

### Phase 1: Foundation Setup (Week 1-2)
- [ ] Initialize Spring Boot project with GraphQL dependencies
- [ ] Configure Maven build with all required plugins
- [ ] Set up PostgreSQL database with Docker Compose
- [ ] Configure application properties for all environments
- [ ] Create base entity classes with JPA annotations
- [ ] Set up Flyway database migrations with initial schema
- [ ] Configure Spring Security with JWT authentication
- [ ] Create basic GraphQL schema structure
- [ ] Set up testing infrastructure with Testcontainers
- [ ] Configure structured logging and metrics

### Phase 2: GraphQL Schema Design (Week 3-4)
- [ ] Design comprehensive GraphQL schema with types and operations
- [ ] Implement custom scalar types (DateTime, Email, URL, JSON)
- [ ] Create input types for mutations with validation
- [ ] Design connection types for pagination
- [ ] Implement custom directives for security and functionality
- [ ] Create union and interface types for polymorphism
- [ ] Define subscription types for real-time features
- [ ] Set up schema validation and documentation

### Phase 3: Core Domain Implementation (Week 5-6)
- [ ] Implement User, Post, Comment, Category, and Tag entities
- [ ] Create repository interfaces with custom query methods
- [ ] Develop service layer with comprehensive business logic
- [ ] Implement authentication and authorization services
- [ ] Create data transfer objects and mappers
- [ ] Add comprehensive input validation
- [ ] Implement audit logging for all operations
- [ ] Create email notification service

### Phase 4: GraphQL Resolvers (Week 7-9)
- [ ] Implement query resolvers for all entity types
- [ ] Create mutation resolvers with proper validation
- [ ] Develop subscription resolvers for real-time features
- [ ] Implement type resolvers for complex nested queries
- [ ] Add field-level security with custom directives
- [ ] Create search and filtering functionality
- [ ] Implement pagination with Relay cursor connections
- [ ] Add batch loading capabilities

### Phase 5: DataLoader Implementation (Week 10)
- [ ] Create DataLoaders for all entity relationships
- [ ] Implement batching strategies for N+1 problem prevention
- [ ] Add caching layers with Redis integration
- [ ] Optimize query execution paths
- [ ] Implement request-scoped DataLoader registry
- [ ] Add monitoring for DataLoader performance
- [ ] Create custom DataLoaders for complex scenarios

### Phase 6: Real-time Features (Week 11)
- [ ] Implement WebSocket configuration for subscriptions
- [ ] Create real-time post and comment notifications
- [ ] Add user activity tracking subscriptions
- [ ] Implement subscription filtering and security
- [ ] Add connection management and cleanup
- [ ] Create subscription testing framework
- [ ] Implement subscription performance monitoring

### Phase 7: Security & Performance (Week 12-13)
- [ ] Implement query complexity analysis
- [ ] Add query depth limiting
- [ ] Create rate limiting per user and operation
- [ ] Implement field-level authorization
- [ ] Add query whitelisting capability
- [ ] Create security monitoring and alerting
- [ ] Optimize database queries and indexing
- [ ] Implement comprehensive caching strategy

### Phase 8: Testing & Quality Assurance (Week 14-15)
- [ ] Complete comprehensive unit test suite
- [ ] Implement GraphQL integration tests
- [ ] Create subscription testing scenarios
- [ ] Add performance and load testing
- [ ] Implement security testing for all attack vectors
- [ ] Create test data generators and fixtures
- [ ] Add mutation testing for test quality
- [ ] Implement automated testing pipeline

### Phase 9: Documentation & Deployment (Week 16)
- [ ] Generate comprehensive GraphQL documentation
- [ ] Create API usage examples and tutorials
- [ ] Set up GraphiQL and Voyager for schema exploration
- [ ] Create Docker deployment configuration
- [ ] Implement monitoring and observability
- [ ] Add production health checks
- [ ] Create deployment automation
- [ ] Perform production readiness validation

## CLAUDE_CODE_COMMANDS

### Initial Setup
```bash
# Create project directory
mkdir {{project_name}}
cd {{project_name}}

# Initialize Maven project
mvn archetype:generate \
    -DgroupId={{base_package}} \
    -DartifactId={{project_name}} \
    -DarchetypeArtifactId=maven-archetype-quickstart \
    -DinteractiveMode=false

# Start development environment
docker-compose up -d
```

### Build Configuration (pom.xml)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.3.0</version>
        <relativePath/>
    </parent>
    
    <groupId>{{base_package}}</groupId>
    <artifactId>{{project_name}}</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>jar</packaging>
    
    <name>{{project_name}}</name>
    <description>Spring Boot GraphQL API</description>
    
    <properties>
        <java.version>21</java.version>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        
        <!-- Dependency Versions -->
        <spring-graphql.version>1.3.0</spring-graphql.version>
        <graphql-java.version>21.5</graphql-java.version>
        <graphql-java-dataloader.version>3.2.2</graphql-java-dataloader.version>
        <testcontainers.version>1.19.8</testcontainers.version>
        <jjwt.version>0.12.6</jjwt.version>
        <flyway.version>10.15.0</flyway.version>
    </properties>
    
    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-graphql</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-cache</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-websocket</artifactId>
        </dependency>
        
        <!-- GraphQL Dependencies -->
        <dependency>
            <groupId>com.graphql-java</groupId>
            <artifactId>graphql-java</artifactId>
            <version>${graphql-java.version}</version>
        </dependency>
        
        <dependency>
            <groupId>com.graphql-java</groupId>
            <artifactId>java-dataloader</artifactId>
            <version>${graphql-java-dataloader.version}</version>
        </dependency>
        
        <dependency>
            <groupId>com.graphql-java</groupId>
            <artifactId>graphql-java-extended-scalars</artifactId>
            <version>21.0</version>
        </dependency>
        
        <!-- Database -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-database-postgresql</artifactId>
        </dependency>
        
        <dependency>
            <groupId>com.zaxxer</groupId>
            <artifactId>HikariCP</artifactId>
        </dependency>
        
        <!-- Security & JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>${jjwt.version}</version>
        </dependency>
        
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>${jjwt.version}</version>
            <scope>runtime</scope>
        </dependency>
        
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>${jjwt.version}</version>
            <scope>runtime</scope>
        </dependency>
        
        <!-- Monitoring & Metrics -->
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
        
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-tracing-bridge-brave</artifactId>
        </dependency>
        
        <!-- Utilities -->
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-lang3</artifactId>
        </dependency>
        
        <dependency>
            <groupId>commons-io</groupId>
            <artifactId>commons-io</artifactId>
            <version>2.16.1</version>
        </dependency>
        
        <dependency>
            <groupId>com.fasterxml.jackson.datatype</groupId>
            <artifactId>jackson-datatype-jsr310</artifactId>
        </dependency>
        
        <!-- Caching -->
        <dependency>
            <groupId>com.github.ben-manes.caffeine</groupId>
            <artifactId>caffeine</artifactId>
        </dependency>
        
        <!-- Development Tools -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-configuration-processor</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.graphql</groupId>
            <artifactId>spring-graphql-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>junit-jupiter</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>postgresql</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.testcontainers</groupId>
            <artifactId>redis</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.awaitility</groupId>
            <artifactId>awaitility</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.testcontainers</groupId>
                <artifactId>testcontainers-bom</artifactId>
                <version>${testcontainers.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.springframework.boot</groupId>
                            <artifactId>spring-boot-configuration-processor</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.13.0</version>
                <configuration>
                    <source>21</source>
                    <target>21</target>
                    <compilerArgs>
                        <arg>--enable-preview</arg>
                    </compilerArgs>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.3.0</version>
                <configuration>
                    <argLine>--enable-preview</argLine>
                    <includes>
                        <include>**/*Test.java</include>
                        <include>**/*Tests.java</include>
                    </includes>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-failsafe-plugin</artifactId>
                <version>3.3.0</version>
                <configuration>
                    <argLine>--enable-preview</argLine>
                    <includes>
                        <include>**/*IT.java</include>
                        <include>**/*IntegrationTest.java</include>
                    </includes>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>integration-test</goal>
                            <goal>verify</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.12</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>check</id>
                        <goals>
                            <goal>check</goal>
                        </goals>
                        <configuration>
                            <rules>
                                <rule>
                                    <element>BUNDLE</element>
                                    <limits>
                                        <limit>
                                            <counter>INSTRUCTION</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>0.90</minimum>
                                        </limit>
                                        <limit>
                                            <counter>BRANCH</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>0.85</minimum>
                                        </limit>
                                    </limits>
                                </rule>
                            </rules>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
            
            <plugin>
                <groupId>org.flywaydb</groupId>
                <artifactId>flyway-maven-plugin</artifactId>
                <version>${flyway.version}</version>
                <configuration>
                    <url>jdbc:postgresql://localhost:5432/{{database_name}}</url>
                    <user>postgres</user>
                    <password>postgres</password>
                    <locations>
                        <location>classpath:db/migration</location>
                    </locations>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>com.spotify</groupId>
                <artifactId>dockerfile-maven-plugin</artifactId>
                <version>1.4.13</version>
                <executions>
                    <execution>
                        <id>default</id>
                        <goals>
                            <goal>build</goal>
                            <goal>push</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <repository>{{project_name}}</repository>
                    <tag>${project.version}</tag>
                    <buildArgs>
                        <JAR_FILE>${project.build.finalName}.jar</JAR_FILE>
                    </buildArgs>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>com.github.spotbugs</groupId>
                <artifactId>spotbugs-maven-plugin</artifactId>
                <version>4.8.6.1</version>
                <configuration>
                    <effort>Max</effort>
                    <threshold>Low</threshold>
                    <failOnError>true</failOnError>
                </configuration>
            </plugin>
            
            <plugin>
                <groupId>org.sonarsource.scanner.maven</groupId>
                <artifactId>sonar-maven-plugin</artifactId>
                <version>4.0.0.4121</version>
            </plugin>
        </plugins>
    </build>
    
    <profiles>
        <profile>
            <id>native</id>
            <build>
                <plugins>
                    <plugin>
                        <groupId>org.graalvm.buildtools</groupId>
                        <artifactId>native-maven-plugin</artifactId>
                        <version>0.10.2</version>
                        <executions>
                            <execution>
                                <id>build-native</id>
                                <goals>
                                    <goal>compile-no-fork</goal>
                                </goals>
                                <phase>package</phase>
                            </execution>
                        </executions>
                        <configuration>
                            <imageName>{{project_name}}</imageName>
                            <mainClass>{{base_package}}.Application</mainClass>
                            <buildArgs>
                                <buildArg>--enable-preview</buildArg>
                                <buildArg>--initialize-at-build-time=org.slf4j</buildArg>
                                <buildArg>-H:+ReportExceptionStackTraces</buildArg>
                                <buildArg>-H:+AddAllCharsets</buildArg>
                            </buildArgs>
                        </configuration>
                    </plugin>
                </plugins>
            </build>
        </profile>
    </profiles>
</project>
```

### Development Commands
```bash
# Start development server
mvn spring-boot:run

# Run with specific profile
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# Run tests with coverage
mvn clean test jacoco:report

# Run integration tests
mvn clean verify

# Run all quality checks
mvn clean verify jacoco:check spotbugs:check

# Build production JAR
mvn clean package -DskipTests

# Build native image
mvn clean package -Pnative

# Database migration
mvn flyway:migrate

# Clean migration (DEV ONLY)
mvn flyway:clean flyway:migrate

# Run performance tests
mvn test -Dtest="*PerformanceTest"

# Generate site documentation
mvn site

# Security scan
mvn org.owasp:dependency-check-maven:check
```

### Docker Commands
```bash
# Start development environment
docker-compose up -d

# Start only database services
docker-compose up -d postgres redis

# Build production image
docker build -t {{project_name}}:latest .

# Run production container
docker run -p 8080:8080 {{project_name}}:latest

# View application logs
docker-compose logs -f app

# Stop all services
docker-compose down

# GraphQL Playground access
open http://localhost:8080/graphiql
```

## VALIDATION_SCRIPTS

```java
// Project structure validation
public class ProjectStructureValidator {
    
    private static final List<String> REQUIRED_DIRECTORIES = Arrays.asList(
        "src/main/java/" + BASE_PACKAGE.replace('.', '/') + "/domain/entity",
        "src/main/java/" + BASE_PACKAGE.replace('.', '/') + "/domain/repository",
        "src/main/java/" + BASE_PACKAGE.replace('.', '/') + "/domain/service",
        "src/main/java/" + BASE_PACKAGE.replace('.', '/') + "/graphql/resolver",
        "src/main/java/" + BASE_PACKAGE.replace('.', '/') + "/graphql/dataloader",
        "src/main/java/" + BASE_PACKAGE.replace('.', '/') + "/security",
        "src/main/resources/graphql",
        "src/main/resources/db/migration",
        "src/test/java/" + BASE_PACKAGE.replace('.', '/') + "/integration"
    );
    
    private static final List<String> REQUIRED_DEPENDENCIES = Arrays.asList(
        "spring-boot-starter-graphql",
        "spring-boot-starter-data-jpa",
        "spring-boot-starter-security",
        "spring-boot-starter-validation",
        "postgresql",
        "flyway-core",
        "java-dataloader",
        "jjwt-api"
    );
    
    private static final List<String> REQUIRED_GRAPHQL_FILES = Arrays.asList(
        "src/main/resources/graphql/schema.graphqls",
        "src/main/resources/graphql/types/user.graphqls",
        "src/main/resources/graphql/types/post.graphqls",
        "src/main/resources/graphql/queries/user-queries.graphqls",
        "src/main/resources/graphql/mutations/auth-mutations.graphqls"
    );
    
    public static boolean validateProjectStructure() {
        return REQUIRED_DIRECTORIES.stream().allMatch(ProjectStructureValidator::directoryExists) &&
               REQUIRED_DEPENDENCIES.stream().allMatch(ProjectStructureValidator::dependencyExists) &&
               REQUIRED_GRAPHQL_FILES.stream().allMatch(ProjectStructureValidator::fileExists);
    }
    
    private static boolean directoryExists(String path) {
        return new File(path).exists() && new File(path).isDirectory();
    }
    
    private static boolean dependencyExists(String dependency) {
        // Implementation to check pom.xml for dependency
        return true; // Placeholder
    }
    
    private static boolean fileExists(String path) {
        return new File(path).exists() && new File(path).isFile();
    }
}

// GraphQL Schema validation
public class GraphQLSchemaValidator {
    
    private static final List<String> REQUIRED_TYPES = Arrays.asList(
        "User", "Post", "Comment", "Category", "Tag",
        "CreateUserInput", "UpdateUserInput", "CreatePostInput",
        "AuthPayload", "PageInfo", "Connection"
    );
    
    private static final List<String> REQUIRED_QUERIES = Arrays.asList(
        "user", "users", "post", "posts", "me", "search"
    );
    
    private static final List<String> REQUIRED_MUTATIONS = Arrays.asList(
        "login", "logout", "register", "createPost", "updatePost", "createComment"
    );
    
    private static final List<String> REQUIRED_SUBSCRIPTIONS = Arrays.asList(
        "postAdded", "commentAdded", "postUpdated"
    );
    
    public static boolean validateSchema(GraphQLSchema schema) {
        return validateTypes(schema) &&
               validateQueries(schema) &&
               validateMutations(schema) &&
               validateSubscriptions(schema);
    }
    
    private static boolean validateTypes(GraphQLSchema schema) {
        return REQUIRED_TYPES.stream()
            .allMatch(typeName -> schema.getType(typeName) != null);
    }
    
    private static boolean validateQueries(GraphQLSchema schema) {
        GraphQLObjectType queryType = schema.getQueryType();
        return REQUIRED_QUERIES.stream()
            .allMatch(queryName -> queryType.getFieldDefinition(queryName) != null);
    }
    
    private static boolean validateMutations(GraphQLSchema schema) {
        GraphQLObjectType mutationType = schema.getMutationType();
        return REQUIRED_MUTATIONS.stream()
            .allMatch(mutationName -> mutationType.getFieldDefinition(mutationName) != null);
    }
    
    private static boolean validateSubscriptions(GraphQLSchema schema) {
        GraphQLObjectType subscriptionType = schema.getSubscriptionType();
        return REQUIRED_SUBSCRIPTIONS.stream()
            .allMatch(subscriptionName -> subscriptionType.getFieldDefinition(subscriptionName) != null);
    }
}

// Application properties validation
public class ConfigurationValidator {
    
    private static final List<String> REQUIRED_PROPERTIES = Arrays.asList(
        "spring.datasource.url",
        "spring.datasource.username",
        "spring.datasource.password",
        "spring.jpa.hibernate.ddl-auto",
        "spring.flyway.enabled",
        "spring.graphql.websocket.path",
        "app.jwt.secret",
        "app.jwt.expiration",
        "app.graphql.query-complexity.max-complexity",
        "app.graphql.query-depth.max-depth"
    );
    
    public static boolean validateConfiguration(Environment environment) {
        return REQUIRED_PROPERTIES.stream()
            .allMatch(property -> environment.getProperty(property) != null);
    }
}
```

## PROJECT_VARIABLES
- **PROJECT_NAME**: {{project_name}}
- **BASE_PACKAGE**: {{base_package}}
- **DATABASE_NAME**: {{database_name}}
- **COMPANY_NAME**: {{company_name}}
- **APPLICATION_TITLE**: {{application_title}}
- **JWT_SECRET**: {{jwt_secret}}
- **ADMIN_EMAIL**: {{admin_email}}
- **ADMIN_PASSWORD**: {{admin_password}}
- **GRAPHQL_ENDPOINT**: {{graphql_endpoint}}
- **WEBSOCKET_ENDPOINT**: {{websocket_endpoint}}
- **MAX_QUERY_COMPLEXITY**: {{max_query_complexity}}
- **MAX_QUERY_DEPTH**: {{max_query_depth}}

## CONDITIONAL_REQUIREMENTS

### IF subscription_enabled == "true"
```java
// WebSocket configuration for GraphQL subscriptions
@Configuration
@EnableWebSocket
public class GraphQLWebSocketConfig implements WebSocketConfigurer {
    
    private final GraphQLWebSocketHandler webSocketHandler;
    
    public GraphQLWebSocketConfig(GraphQLWebSocketHandler webSocketHandler) {
        this.webSocketHandler = webSocketHandler;
    }
    
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(webSocketHandler, "/graphql-ws")
                .setAllowedOrigins("*")
                .withSockJS();
    }
}

// Subscription resolver example
@Component
public class PostSubscriptionResolver {
    
    private final PostService postService;
    private final SecurityService securityService;
    
    @SchemaMapping(typeName = "Subscription")
    public Publisher<Post> postAdded(@Argument String categoryId) {
        return postService.getPostAddedPublisher()
                .filter(post -> categoryId == null || 
                       categoryId.equals(post.getCategory().getId().toString()))
                .filter(post -> securityService.canViewPost(post));
    }
    
    @SchemaMapping(typeName = "Subscription")
    public Publisher<Comment> commentAdded(@Argument Long postId) {
        return postService.getCommentAddedPublisher()
                .filter(comment -> postId.equals(comment.getPost().getId()))
                .filter(comment -> securityService.canViewComment(comment));
    }
}
```

### IF federation_enabled == "true"
```java
// GraphQL Federation configuration
@Configuration
public class GraphQLFederationConfig {
    
    @Bean
    public RuntimeWiring.Builder runtimeWiringBuilder() {
        return RuntimeWiring.newRuntimeWiring()
                .scalar(ExtendedScalars.DateTime)
                .scalar(ExtendedScalars.Json)
                .directive("auth", new AuthDirective())
                .directive("role", new RoleDirective())
                .type("User", typeWiring -> typeWiring
                    .dataFetcher("posts", userPostsDataFetcher())
                    .dataFetcher("comments", userCommentsDataFetcher()))
                .type("Post", typeWiring -> typeWiring
                    .dataFetcher("author", postAuthorDataFetcher())
                    .dataFetcher("comments", postCommentsDataFetcher()));
    }
    
    @Bean
    public FederatedTracingInstrumentation federatedTracingInstrumentation() {
        return FederatedTracingInstrumentation.options()
                .debugEnabled(true)
                .build();
    }
}

// Federation entity resolver
@Component
public class FederationResolver {
    
    private final UserService userService;
    private final PostService postService;
    
    @EntityMapping
    public User user(@Argument String id) {
        return userService.findById(Long.valueOf(id));
    }
    
    @EntityMapping
    public Post post(@Argument String id) {
        return postService.findById(Long.valueOf(id));
    }
}
```

### IF caching_strategy == "redis"
```java
// Redis caching configuration for GraphQL
@Configuration
@EnableCaching
public class GraphQLCacheConfig {
    
    @Bean
    public CacheManager cacheManager(RedisConnectionFactory redisConnectionFactory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofMinutes(10))
                .serializeKeysWith(RedisSerializationContext.SerializationPair
                    .fromSerializer(new StringRedisSerializer()))
                .serializeValuesWith(RedisSerializationContext.SerializationPair
                    .fromSerializer(new Jackson2JsonRedisSerializer<>(Object.class)));
        
        return RedisCacheManager.builder(redisConnectionFactory)
                .cacheDefaults(config)
                .withCacheConfiguration("users", config.entryTtl(Duration.ofMinutes(30)))
                .withCacheConfiguration("posts", config.entryTtl(Duration.ofMinutes(15)))
                .withCacheConfiguration("comments", config.entryTtl(Duration.ofMinutes(5)))
                .transactionAware()
                .build();
    }
    
    @Bean
    public DataLoaderRegistry dataLoaderRegistry(UserDataLoader userDataLoader,
                                                PostDataLoader postDataLoader,
                                                CommentDataLoader commentDataLoader) {
        return DataLoaderRegistry.newRegistry()
                .register("userLoader", userDataLoader.createDataLoader())
                .register("postLoader", postDataLoader.createDataLoader())
                .register("commentLoader", commentDataLoader.createDataLoader())
                .build();
    }
}

// Cached DataLoader implementation
@Component
public class UserDataLoader {
    
    private final UserRepository userRepository;
    private final CacheManager cacheManager;
    
    public DataLoader<Long, User> createDataLoader() {
        return DataLoader.newMappedDataLoader((Set<Long> userIds, BatchLoaderEnvironment environment) -> {
            
            // Check cache first
            Map<Long, User> cached = getCachedUsers(userIds);
            Set<Long> uncachedIds = userIds.stream()
                    .filter(id -> !cached.containsKey(id))
                    .collect(Collectors.toSet());
            
            // Fetch uncached users
            Map<Long, User> fetched = new HashMap<>();
            if (!uncachedIds.isEmpty()) {
                List<User> users = userRepository.findAllById(uncachedIds);
                fetched = users.stream()
                        .collect(Collectors.toMap(User::getId, Function.identity()));
                
                // Cache the fetched users
                cacheUsers(fetched);
            }
            
            // Combine cached and fetched results
            Map<Long, User> result = new HashMap<>(cached);
            result.putAll(fetched);
            
            return CompletableFuture.completedFuture(result);
        });
    }
    
    private Map<Long, User> getCachedUsers(Set<Long> userIds) {
        Cache cache = cacheManager.getCache("users");
        return userIds.stream()
                .filter(id -> cache.get(id) != null)
                .collect(Collectors.toMap(
                    Function.identity(),
                    id -> (User) cache.get(id).get()
                ));
    }
    
    private void cacheUsers(Map<Long, User> users) {
        Cache cache = cacheManager.getCache("users");
        users.forEach((id, user) -> cache.put(id, user));
    }
}
```

### IF monitoring_enabled == "advanced"
```java
// Advanced GraphQL monitoring configuration
@Configuration
public class GraphQLMonitoringConfig {
    
    @Bean
    public GraphQLInstrumentation tracingInstrumentation() {
        return TracingInstrumentation.newInstrumentation()
                .includeRawQuery(true)
                .includeVariables(true)
                .includeValidationErrors(true)
                .build();
    }
    
    @Bean
    public GraphQLInstrumentation metricsInstrumentation(MeterRegistry meterRegistry) {
        return MetricsInstrumentation.newInstrumentation(meterRegistry)
                .fieldLevelMetrics(true)
                .dataLoaderMetrics(true)
                .build();
    }
    
    @Bean
    public QueryComplexityInstrumentation queryComplexityInstrumentation() {
        return QueryComplexityInstrumentation.newInstrumentation()
                .maximumComplexity(1000)
                .fieldComplexity(field -> {
                    if (field.getName().equals("posts")) return 10;
                    if (field.getName().equals("comments")) return 5;
                    return 1;
                })
                .build();
    }
    
    @Bean
    public MaxQueryDepthInstrumentation maxQueryDepthInstrumentation() {
        return MaxQueryDepthInstrumentation.newInstrumentation(15);
    }
}

// Custom metrics for GraphQL operations
@Component
public class GraphQLMetrics {
    
    private final MeterRegistry meterRegistry;
    private final Counter queryCounter;
    private final Counter mutationCounter;
    private final Counter subscriptionCounter;
    private final Timer queryTimer;
    private final Gauge activeSubscriptions;
    
    public GraphQLMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.queryCounter = Counter.builder("graphql.query.count")
                .description("Number of GraphQL queries executed")
                .register(meterRegistry);
        this.mutationCounter = Counter.builder("graphql.mutation.count")
                .description("Number of GraphQL mutations executed")
                .register(meterRegistry);
        this.subscriptionCounter = Counter.builder("graphql.subscription.count")
                .description("Number of GraphQL subscriptions created")
                .register(meterRegistry);
        this.queryTimer = Timer.builder("graphql.query.duration")
                .description("GraphQL query execution time")
                .register(meterRegistry);
        this.activeSubscriptions = Gauge.builder("graphql.subscription.active")
                .description("Number of active GraphQL subscriptions")
                .register(meterRegistry, this, GraphQLMetrics::getActiveSubscriptionCount);
    }
    
    public void recordQuery(String operationName, Duration duration) {
        queryCounter.increment(Tags.of("operation", operationName));
        queryTimer.record(duration);
    }
    
    public void recordMutation(String operationName) {
        mutationCounter.increment(Tags.of("operation", operationName));
    }
    
    public void recordSubscription(String operationName) {
        subscriptionCounter.increment(Tags.of("operation", operationName));
    }
    
    private double getActiveSubscriptionCount() {
        // Implementation to count active subscriptions
        return 0; // Placeholder
    }
}
```

## INCLUDE_MODULES
- @include: jwt-authentication.md
- @include: audit-logging.md
- @include: caching-strategies.md
- @include: monitoring-metrics.md
- @include: rate-limiting-throttling.md
- @include: input-validation-sanitization.md
- @include: security-headers.md
- @include: database-performance.md
- @include: real-time-subscriptions.md
- @include: query-optimization.md

## VALIDATION_CHECKLIST
- [ ] All Java compilation errors resolved without warnings
- [ ] Spring Boot application starts successfully on all profiles (dev, test, prod)
- [ ] GraphQL schema validates and introspection works
- [ ] All database migrations execute successfully without errors
- [ ] JWT authentication and authorization working correctly with GraphQL
- [ ] All GraphQL resolvers properly secured with field-level authorization
- [ ] DataLoaders implemented and N+1 queries eliminated
- [ ] Query complexity analysis and depth limiting functional
- [ ] GraphQL subscriptions working with WebSocket
- [ ] All GraphQL operations return consistent response format
- [ ] Input validation working on all mutation inputs
- [ ] Rate limiting configured and functional per user/operation
- [ ] Caching strategy implemented and cache hit ratios optimized
- [ ] Custom scalars (DateTime, Email, URL, JSON) working correctly
- [ ] Custom directives (@auth, @role, @deprecated) functional
- [ ] GraphiQL and Voyager accessible for schema exploration
- [ ] Monitoring endpoints collecting GraphQL-specific metrics
- [ ] Application logs structured with operation context
- [ ] Test coverage above 90% for resolvers and services
- [ ] Integration tests pass with Testcontainers PostgreSQL and Redis
- [ ] Performance requirements met under simulated load
- [ ] Security scan passes without critical vulnerabilities
- [ ] Docker image builds and runs successfully
- [ ] Production readiness checklist completed

## PERFORMANCE_REQUIREMENTS
- **GraphQL Query Response Time**: < 200ms for simple queries, < 1s for complex queries
- **DataLoader Batching Efficiency**: > 95% batch hit ratio for related data fetching
- **Subscription Message Delivery**: < 100ms latency for real-time updates
- **Query Complexity**: Support queries up to complexity score of 1000
- **Concurrent Subscriptions**: Handle 1000+ active WebSocket connections
- **Memory Usage**: < 2GB heap under normal load with 500 active users
- **Database Connection Pool**: Efficiently manage connections (max 20)
- **Cache Hit Ratio**: > 80% for frequently accessed GraphQL results
- **Schema Introspection**: Complete schema introspection in < 500ms
- **Startup Time**: Application ready in < 60 seconds

## MONITORING_AND_OBSERVABILITY

### GraphQL-Specific Metrics
- Query execution time by operation name and complexity
- DataLoader batch efficiency and cache hit ratios  
- Active subscription count and message throughput
- Schema introspection frequency and performance
- Query complexity distribution and depth analysis
- Error rates by operation type and field path
- Resolver execution time breakdown
- Custom directive execution metrics

### Security Monitoring
- Authentication failure rates
- Authorization denial patterns by field and operation
- Query complexity threshold violations
- Rate limiting trigger events
- Suspicious query patterns and potential attacks
- JWT token validation failure rates
- Field-level access denial tracking

### Business Metrics
- User engagement through GraphQL operations
- Most frequently accessed data types
- Subscription retention and dropout rates
- API usage patterns by client application
- Data export and import operation frequency

## SECURITY_HARDENING

### GraphQL-Specific Security
```java
// Query complexity analysis configuration
@Component
public class GraphQLSecurityConfig {
    
    @Value("${app.graphql.query-complexity.max-complexity:1000}")
    private int maxQueryComplexity;
    
    @Value("${app.graphql.query-depth.max-depth:15}")
    private int maxQueryDepth;
    
    @Bean
    public QueryComplexityInstrumentation queryComplexityInstrumentation() {
        return QueryComplexityInstrumentation.newInstrumentation()
                .maximumComplexity(maxQueryComplexity)
                .fieldComplexity(this::calculateFieldComplexity)
                .introspectionComplexity(10)
                .scalarComplexity(1)
                .build();
    }
    
    private int calculateFieldComplexity(FieldComplexityEnvironment environment) {
        String fieldName = environment.getField().getName();
        String parentType = environment.getParentType().getName();
        
        // High complexity for relationship fields
        if ("posts".equals(fieldName) || "comments".equals(fieldName)) {
            return 20;
        }
        
        // Medium complexity for search operations
        if ("search".equals(fieldName)) {
            return 15;
        }
        
        // Higher complexity for admin operations
        if ("Query".equals(parentType) && fieldName.startsWith("admin")) {
            return 25;
        }
        
        return 1; // Default complexity
    }
    
    @Bean
    public MaxQueryDepthInstrumentation maxQueryDepthInstrumentation() {
        return MaxQueryDepthInstrumentation.newInstrumentation(maxQueryDepth);
    }
}

// Field-level security directive
@Component
public class AuthDirective implements SchemaDirectiveWiring {
    
    private final SecurityService securityService;
    
    @Override
    public GraphQLFieldDefinition onField(SchemaDirectiveWiringEnvironment<GraphQLFieldDefinition> environment) {
        GraphQLFieldDefinition field = environment.getElement();
        GraphQLFieldsContainer parentType = environment.getFieldsContainer();
        
        DataFetcher<?> originalDataFetcher = environment.getCodeRegistry()
                .getDataFetcher(parentType, field);
        
        DataFetcher<?> securedDataFetcher = DataFetcherFactories
                .wrapDataFetcher(originalDataFetcher, (dataFetchingEnvironment, value) -> {
                    
                    SecurityContext securityContext = dataFetchingEnvironment
                            .getContext();
                    
                    if (!securityService.hasAccess(securityContext, field.getName())) {
                        throw new GraphQLException("Access denied to field: " + field.getName());
                    }
                    
                    return value;
                });
        
        environment.getCodeRegistry()
                .dataFetcher(parentType, field, securedDataFetcher);
        
        return field;
    }
}

// Rate limiting per GraphQL operation
@Component
public class GraphQLRateLimitingInterceptor implements WebRequestInterceptor {
    
    private final RedisTemplate<String, Object> redisTemplate;
    
    @Value("${app.rate-limit.graphql.queries-per-minute:100}")
    private int queriesPerMinute;
    
    @Value("${app.rate-limit.graphql.mutations-per-minute:20}")
    private int mutationsPerMinute;
    
    @Override
    public void preHandle(WebRequest request) throws Exception {
        String operation = extractOperation(request);
        String userId = extractUserId(request);
        String operationType = determineOperationType(operation);
        
        int limit = "mutation".equals(operationType) ? mutationsPerMinute : queriesPerMinute;
        
        String key = String.format("rate_limit:graphql:%s:%s:%s", 
                userId, operationType, getCurrentMinute());
        
        Long current = redisTemplate.opsForValue().increment(key);
        if (current == 1) {
            redisTemplate.expire(key, Duration.ofMinutes(1));
        }
        
        if (current > limit) {
            throw new GraphQLException("Rate limit exceeded for " + operationType);
        }
    }
    
    private String extractOperation(WebRequest request) {
        // Extract GraphQL operation from request
        return request.getParameter("query");
    }
    
    private String extractUserId(WebRequest request) {
        // Extract user ID from JWT token
        return SecurityUtils.getCurrentUserId();
    }
    
    private String determineOperationType(String operation) {
        if (operation.trim().startsWith("mutation")) {
            return "mutation";
        } else if (operation.trim().startsWith("subscription")) {
            return "subscription";
        }
        return "query";
    }
    
    private String getCurrentMinute() {
        return String.valueOf(System.currentTimeMillis() / 60000);
    }
}
```

### Input Sanitization and Validation
```java
// GraphQL input validation
@Component
public class GraphQLInputValidator {
    
    private final Validator validator;
    
    public GraphQLInputValidator(Validator validator) {
        this.validator = validator;
    }
    
    public <T> void validateInput(T input) {
        Set<ConstraintViolation<T>> violations = validator.validate(input);
        
        if (!violations.isEmpty()) {
            List<String> errors = violations.stream()
                    .map(violation -> violation.getPropertyPath() + ": " + violation.getMessage())
                    .collect(Collectors.toList());
            
            throw new GraphQLException("Validation failed: " + String.join(", ", errors));
        }
    }
    
    public void sanitizeStringInput(Object input) {
        if (input instanceof String) {
            String sanitized = sanitizeString((String) input);
            // Update input object with sanitized value
        } else {
            // Recursively sanitize nested objects
            sanitizeObjectFields(input);
        }
    }
    
    private String sanitizeString(String input) {
        if (input == null) return null;
        
        // Remove potentially dangerous characters
        String sanitized = input.replaceAll("[<>\"'&]", "");
        
        // Limit length
        if (sanitized.length() > 1000) {
            sanitized = sanitized.substring(0, 1000);
        }
        
        return sanitized.trim();
    }
    
    private void sanitizeObjectFields(Object obj) {
        Class<?> clazz = obj.getClass();
        Field[] fields = clazz.getDeclaredFields();
        
        for (Field field : fields) {
            field.setAccessible(true);
            try {
                Object value = field.get(obj);
                if (value instanceof String) {
                    field.set(obj, sanitizeString((String) value));
                } else if (value != null && !isPrimitiveOrWrapper(value.getClass())) {
                    sanitizeObjectFields(value);
                }
            } catch (IllegalAccessException e) {
                // Log error but continue processing
            }
        }
    }
    
    private boolean isPrimitiveOrWrapper(Class<?> clazz) {
        return clazz.isPrimitive() || 
               clazz == Boolean.class || clazz == Character.class ||
               clazz == Byte.class || clazz == Short.class ||
               clazz == Integer.class || clazz == Long.class ||
               clazz == Float.class || clazz == Double.class;
    }
}
```

## BUSINESS_LOGIC_EXAMPLES

### Core GraphQL Schema Definition
```graphql
# schema.graphqls - Main schema file
scalar DateTime
scalar Email
scalar URL
scalar JSON

directive @auth on FIELD_DEFINITION
directive @role(requires: Role!) on FIELD_DEFINITION
directive @rateLimit(max: Int!, window: Int!) on FIELD_DEFINITION
directive @deprecated(reason: String) on FIELD_DEFINITION

enum Role {
    USER
    MODERATOR
    ADMIN
}

type Query {
    # User queries
    me: User @auth
    user(id: ID!): User
    users(filter: UserFilter, sort: UserSort, pagination: PaginationInput): UserConnection!
    
    # Post queries  
    post(id: ID!): Post
    posts(filter: PostFilter, sort: PostSort, pagination: PaginationInput): PostConnection!
    
    # Search queries
    search(query: String!, type: SearchType, pagination: PaginationInput): SearchResult!
    
    # Admin queries
    adminStats: AdminStats @role(requires: ADMIN)
    adminUsers(filter: AdminUserFilter, pagination: PaginationInput): UserConnection! @role(requires: ADMIN)
}

type Mutation {
    # Authentication mutations
    login(input: LoginInput!): AuthPayload!
    logout: Boolean! @auth
    register(input: RegisterInput!): AuthPayload!
    refreshToken(input: RefreshTokenInput!): AuthPayload!
    
    # User mutations
    updateProfile(input: UpdateProfileInput!): User! @auth
    changePassword(input: ChangePasswordInput!): Boolean! @auth
    deleteAccount: Boolean! @auth
    
    # Post mutations
    createPost(input: CreatePostInput!): Post! @auth
    updatePost(id: ID!, input: UpdatePostInput!): Post! @auth
    deletePost(id: ID!): Boolean! @auth
    publishPost(id: ID!): Post! @auth
    
    # Comment mutations
    createComment(input: CreateCommentInput!): Comment! @auth
    updateComment(id: ID!, input: UpdateCommentInput!): Comment! @auth
    deleteComment(id: ID!): Boolean! @auth
    
    # Admin mutations
    banUser(userId: ID!, reason: String!): User! @role(requires: ADMIN)
    unbanUser(userId: ID!): User! @role(requires: ADMIN)
    deleteUserPost(postId: ID!, reason: String!): Boolean! @role(requires: MODERATOR)
}

type Subscription {
    # Post subscriptions
    postAdded(categoryId: ID): Post! @auth
    postUpdated(postId: ID!): Post! @auth
    postDeleted(categoryId: ID): ID! @auth
    
    # Comment subscriptions  
    commentAdded(postId: ID!): Comment! @auth
    commentUpdated(commentId: ID!): Comment! @auth
    commentDeleted(postId: ID!): ID! @auth
    
    # User subscriptions
    userStatusChanged(userId: ID!): User! @auth
    notificationReceived: Notification! @auth
}

# User type with all relationships
type User {
    id: ID!
    email: Email!
    username: String!
    firstName: String!
    lastName: String!
    fullName: String!
    avatar: URL
    bio: String
    website: URL
    location: String
    birthDate: DateTime
    isActive: Boolean!
    isVerified: Boolean!
    role: Role!
    joinedAt: DateTime!
    lastActiveAt: DateTime
    
    # Relationships
    posts(filter: PostFilter, pagination: PaginationInput): PostConnection!
    comments(filter: CommentFilter, pagination: PaginationInput): CommentConnection!
    followers(pagination: PaginationInput): UserConnection!
    following(pagination: PaginationInput): UserConnection!
    
    # Computed fields
    postCount: Int!
    followerCount: Int!
    followingCount: Int!
    isFollowing: Boolean! @auth
}

# Post type with content and metadata
type Post {
    id: ID!
    title: String!
    content: String!
    excerpt: String!
    slug: String!
    status: PostStatus!
    visibility: PostVisibility!
    featuredImage: URL
    publishedAt: DateTime
    createdAt: DateTime!
    updatedAt: DateTime!
    
    # Relationships
    author: User!
    category: Category!
    tags: [Tag!]!
    comments(filter: CommentFilter, pagination: PaginationInput): CommentConnection!
    
    # Metadata
    viewCount: Int!
    likeCount: Int!
    commentCount: Int!
    readingTime: Int!
    
    # User-specific fields
    isLiked: Boolean @auth
    isBookmarked: Boolean @auth
    canEdit: Boolean! @auth
    canDelete: Boolean! @auth
}

enum PostStatus {
    DRAFT
    PUBLISHED
    ARCHIVED
    DELETED
}

enum PostVisibility {
    PUBLIC
    PRIVATE
    UNLISTED
}

# Comment type with threading support
type Comment {
    id: ID!
    content: String!
    createdAt: DateTime!
    updatedAt: DateTime!
    editedAt: DateTime
    
    # Relationships
    author: User!
    post: Post!
    parent: Comment
    replies(pagination: PaginationInput): CommentConnection!
    
    # Metadata
    likeCount: Int!
    replyCount: Int!
    
    # User-specific fields
    isLiked: Boolean @auth
    canEdit: Boolean! @auth
    canDelete: Boolean! @auth
}

# Category for organizing posts
type Category {
    id: ID!
    name: String!
    slug: String!
    description: String
    color: String
    icon: String
    isActive: Boolean!
    createdAt: DateTime!
    
    # Relationships
    parent: Category
    children: [Category!]!
    posts(filter: PostFilter, pagination: PaginationInput): PostConnection!
    
    # Metadata
    postCount: Int!
}

# Tag for labeling posts
type Tag {
    id: ID!
    name: String!
    slug: String!
    description: String
    color: String
    isActive: Boolean!
    createdAt: DateTime!
    
    # Relationships
    posts(filter: PostFilter, pagination: PaginationInput): PostConnection!
    
    # Metadata
    postCount: Int!
    usage: Int!
}

# Authentication payload
type AuthPayload {
    accessToken: String!
    refreshToken: String!
    expiresIn: Int!
    user: User!
}

# Pagination types following Relay specification
type PageInfo {
    hasNextPage: Boolean!
    hasPreviousPage: Boolean!
    startCursor: String
    endCursor: String
    totalCount: Int!
}

type UserConnection {
    edges: [UserEdge!]!
    pageInfo: PageInfo!
}

type UserEdge {
    node: User!
    cursor: String!
}

type PostConnection {
    edges: [PostEdge!]!
    pageInfo: PageInfo!
}

type PostEdge {
    node: Post!
    cursor: String!
}

type CommentConnection {
    edges: [CommentEdge!]!
    pageInfo: PageInfo!
}

type CommentEdge {
    node: Comment!
    cursor: String!
}

# Search functionality
union SearchResult = User | Post | Comment | Tag

enum SearchType {
    ALL
    USERS
    POSTS
    COMMENTS
    TAGS
}

# Input types for mutations
input LoginInput {
    email: Email!
    password: String!
    rememberMe: Boolean = false
}

input RegisterInput {
    email: Email!
    username: String!
    firstName: String!
    lastName: String!
    password: String!
    acceptTerms: Boolean!
}

input CreatePostInput {
    title: String!
    content: String!
    excerpt: String
    categoryId: ID!
    tagIds: [ID!]
    featuredImage: URL
    status: PostStatus = DRAFT
    visibility: PostVisibility = PUBLIC
    publishedAt: DateTime
}

input UpdatePostInput {
    title: String
    content: String
    excerpt: String
    categoryId: ID
    tagIds: [ID!]
    featuredImage: URL
    status: PostStatus
    visibility: PostVisibility
    publishedAt: DateTime
}

input CreateCommentInput {
    postId: ID!
    parentId: ID
    content: String!
}

input UpdateCommentInput {
    content: String!
}

# Filter types for queries
input UserFilter {
    role: Role
    isActive: Boolean
    isVerified: Boolean
    joinedAfter: DateTime
    joinedBefore: DateTime
    search: String
}

input PostFilter {
    authorId: ID
    categoryId: ID
    tagIds: [ID!]
    status: PostStatus
    visibility: PostVisibility
    publishedAfter: DateTime
    publishedBefore: DateTime
    search: String
}

input CommentFilter {
    authorId: ID
    postId: ID
    createdAfter: DateTime
    createdBefore: DateTime
}

# Sort types
input UserSort {
    field: UserSortField!
    direction: SortDirection = ASC
}

enum UserSortField {
    ID
    USERNAME
    EMAIL
    JOINED_AT
    LAST_ACTIVE_AT
    POST_COUNT
    FOLLOWER_COUNT
}

input PostSort {
    field: PostSortField!
    direction: SortDirection = ASC
}

enum PostSortField {
    ID
    TITLE
    CREATED_AT
    UPDATED_AT
    PUBLISHED_AT
    VIEW_COUNT
    LIKE_COUNT
    COMMENT_COUNT
}

enum SortDirection {
    ASC
    DESC
}

# Pagination input
input PaginationInput {
    first: Int
    after: String
    last: Int
    before: String
}

# Admin types
type AdminStats {
    totalUsers: Int!
    totalPosts: Int!
    totalComments: Int!
    activeUsers: Int!
    newUsersToday: Int!
    newPostsToday: Int!
    popularPosts: [Post!]!
    recentActivity: [ActivityLog!]!
}

type ActivityLog {
    id: ID!
    userId: ID!
    action: String!
    resource: String!
    resourceId: ID
    timestamp: DateTime!
    metadata: JSON
}

# Notification type
type Notification {
    id: ID!
    userId: ID!
    type: NotificationType!
    title: String!
    message: String!
    data: JSON
    isRead: Boolean!
    createdAt: DateTime!
}

enum NotificationType {
    POST_LIKED
    POST_COMMENTED
    USER_FOLLOWED
    COMMENT_REPLIED
    POST_MENTIONED
    SYSTEM_ANNOUNCEMENT
}
```

### Core Resolver Implementations
```java
// User Query Resolver
@Component
public class UserQueryResolver {
    
    private final UserService userService;
    private final SecurityService securityService;
    private final GraphQLInputValidator inputValidator;
    
    @SchemaMapping(typeName = "Query")
    public User me(DataFetchingEnvironment environment) {
        SecurityContext securityContext = environment.getContext();
        Long userId = securityService.getCurrentUserId(securityContext);
        
        if (userId == null) {
            throw new GraphQLException("Authentication required");
        }
        
        return userService.findById(userId)
                .orElseThrow(() -> new GraphQLException("User not found"));
    }
    
    @SchemaMapping(typeName = "Query")
    public User user(@Argument String id, DataFetchingEnvironment environment) {
        Long userId = Long.valueOf(id);
        User user = userService.findById(userId)
                .orElseThrow(() -> new GraphQLException("User not found"));
        
        SecurityContext securityContext = environment.getContext();
        if (!securityService.canViewUser(securityContext, user)) {
            throw new GraphQLException("Access denied");
        }
        
        return user;
    }
    
    @SchemaMapping(typeName = "Query")
    public UserConnection users(@Argument UserFilter filter,
                               @Argument UserSort sort,
                               @Argument PaginationInput pagination,
                               DataFetchingEnvironment environment) {
        
        inputValidator.validateInput(filter);
        inputValidator.validateInput(pagination);
        
        SecurityContext securityContext = environment.getContext();
        if (!securityService.canListUsers(securityContext)) {
            throw new GraphQLException("Access denied");
        }
        
        return userService.findUsers(filter, sort, pagination);
    }
}

// Post Mutation Resolver
@Component
public class PostMutationResolver {
    
    private final PostService postService;
    private final SecurityService securityService;
    private final GraphQLInputValidator inputValidator;
    private final NotificationService notificationService;
    
    @SchemaMapping(typeName = "Mutation")
    public Post createPost(@Argument CreatePostInput input, 
                          DataFetchingEnvironment environment) {
        
        inputValidator.validateInput(input);
        inputValidator.sanitizeStringInput(input);
        
        SecurityContext securityContext = environment.getContext();
        Long userId = securityService.getCurrentUserId(securityContext);
        
        if (!securityService.canCreatePost(securityContext)) {
            throw new GraphQLException("Access denied");
        }
        
        Post post = postService.createPost(input, userId);
        
        // Send notifications for published posts
        if (post.getStatus() == PostStatus.PUBLISHED) {
            notificationService.notifyFollowers(post);
        }
        
        return post;
    }
    
    @SchemaMapping(typeName = "Mutation")
    public Post updatePost(@Argument String id,
                          @Argument UpdatePostInput input,
                          DataFetchingEnvironment environment) {
        
        inputValidator.validateInput(input);
        inputValidator.sanitizeStringInput(input);
        
        Long postId = Long.valueOf(id);
        Post existingPost = postService.findById(postId)
                .orElseThrow(() -> new GraphQLException("Post not found"));
        
        SecurityContext securityContext = environment.getContext();
        if (!securityService.canEditPost(securityContext, existingPost)) {
            throw new GraphQLException("Access denied");
        }
        
        return postService.updatePost(postId, input);
    }
    
    @SchemaMapping(typeName = "Mutation")
    public Boolean deletePost(@Argument String id, 
                             DataFetchingEnvironment environment) {
        
        Long postId = Long.valueOf(id);
        Post post = postService.findById(postId)
                .orElseThrow(() -> new GraphQLException("Post not found"));
        
        SecurityContext securityContext = environment.getContext();
        if (!securityService.canDeletePost(securityContext, post)) {
            throw new GraphQLException("Access denied");
        }
        
        postService.deletePost(postId);
        return true;
    }
}

// Post Subscription Resolver
@Component
public class PostSubscriptionResolver {
    
    private final PostService postService;
    private final SecurityService securityService;
    
    @SchemaMapping(typeName = "Subscription")
    public Publisher<Post> postAdded(@Argument String categoryId,
                                    DataFetchingEnvironment environment) {
        
        SecurityContext securityContext = environment.getContext();
        if (!securityService.isAuthenticated(securityContext)) {
            throw new GraphQLException("Authentication required");
        }
        
        return postService.getPostAddedPublisher()
                .filter(post -> categoryId == null || 
                       categoryId.equals(post.getCategory().getId().toString()))
                .filter(post -> securityService.canViewPost(securityContext, post))
                .map(post -> {
                    // Enhance post data for subscription
                    return postService.enrichPostForSubscription(post, securityContext);
                });
    }
    
    @SchemaMapping(typeName = "Subscription")
    public Publisher<Comment> commentAdded(@Argument String postId,
                                          DataFetchingEnvironment environment) {
        
        Long postIdLong = Long.valueOf(postId);
        SecurityContext securityContext = environment.getContext();
        
        if (!securityService.isAuthenticated(securityContext)) {
            throw new GraphQLException("Authentication required");
        }
        
        return postService.getCommentAddedPublisher()
                .filter(comment -> postIdLong.equals(comment.getPost().getId()))
                .filter(comment -> securityService.canViewComment(securityContext, comment));
    }
}

// DataLoader for efficient batch loading
@Component
public class UserDataLoader {
    
    private final UserRepository userRepository;
    private final CacheManager cacheManager;
    
    public DataLoader<Long, User> createDataLoader() {
        return DataLoader.newMappedDataLoader((Set<Long> userIds, BatchLoaderEnvironment environment) -> {
            
            // Get security context from environment
            SecurityContext securityContext = environment.getContext();
            
            // Filter user IDs based on security permissions
            Set<Long> allowedUserIds = userIds.stream()
                    .filter(userId -> securityService.canViewUserById(securityContext, userId))
                    .collect(Collectors.toSet());
            
            // Batch load users from database
            List<User> users = userRepository.findAllById(allowedUserIds);
            
            // Convert to map for DataLoader
            Map<Long, User> userMap = users.stream()
                    .collect(Collectors.toMap(User::getId, Function.identity()));
            
            return CompletableFuture.completedFuture(userMap);
        });
    }
}
```

This completes the comprehensive Spring Boot Java GraphQL API template with:

1. **Complete project structure** with proper GraphQL organization
2. **Comprehensive GraphQL schema** with types, queries, mutations, and subscriptions
3. **Production-ready Maven configuration** with all required dependencies
4. **Advanced security implementation** with field-level authorization and query complexity analysis
5. **DataLoader patterns** for efficient N+1 query prevention
6. **Real-time subscriptions** with WebSocket support and filtering
7. **Comprehensive testing strategy** including GraphQL-specific tests
8. **Performance optimization** with caching, batching, and monitoring
9. **Security hardening** with rate limiting, input validation, and query depth limiting
10. **Complete business logic examples** with resolvers, services, and schema definitions

The template provides a solid foundation for building production-grade GraphQL APIs with Spring Boot and Java, following GraphQL best practices and enterprise security requirements.
        