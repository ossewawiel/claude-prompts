# GraphQL Best Practices for Spring Boot (Java/Kotlin) - Claude Code Integration

## Document Information
- **Purpose**: Comprehensive GraphQL best practices for Spring Boot with Java and Kotlin
- **Last Updated**: June 26, 2025
- **Document Version**: 2.0.0
- **Target Frameworks**: Spring Boot 3.x, Spring GraphQL, Java 17+, Kotlin 2.1+
- **Integration**: Designed for Claude Code analysis and project validation

## Table of Contents
1. [Library Dependencies](#library-dependencies)
2. [Project Structure](#project-structure)
3. [Naming Conventions](#naming-conventions)
4. [Schema Design](#schema-design)
5. [Null Handling](#null-handling)
6. [Resolver Implementation](#resolver-implementation)
7. [Error Handling](#error-handling)
8. [Security](#security)
9. [Performance Optimization](#performance-optimization)
10. [Testing](#testing)
11. [Validation Checklist](#validation-checklist)

---

## Library Dependencies

### Required Dependencies

#### Maven (Java)
```xml
<dependencies>
    <!-- Core Spring Boot GraphQL -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-graphql</artifactId>
    </dependency>
    
    <!-- Web Support -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    
    <!-- WebSocket Support for Subscriptions -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-websocket</artifactId>
    </dependency>
    
    <!-- Data JPA -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    
    <!-- Security -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    
    <!-- Validation -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    
    <!-- DataLoader for N+1 prevention -->
    <dependency>
        <groupId>com.graphql-java</groupId>
        <artifactId>java-dataloader</artifactId>
        <version>3.2.1</version>
    </dependency>
    
    <!-- Database -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>
    
    <!-- Redis for caching -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-redis</artifactId>
    </dependency>
</dependencies>
```

#### Gradle (Kotlin)
```kotlin
dependencies {
    // Core Spring Boot GraphQL
    implementation("org.springframework.boot:spring-boot-starter-graphql")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-websocket")
    
    // Data and Security
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    
    // DataLoader
    implementation("com.graphql-java:java-dataloader:3.2.1")
    
    // Kotlin specific
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    
    // Database
    runtimeOnly("org.postgresql:postgresql")
    implementation("org.springframework.boot:spring-boot-starter-data-redis")
    
    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.graphql:spring-graphql-test")
    testImplementation("io.mockk:mockk:1.13.5")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:postgresql")
}
```

---

## Project Structure

### Recommended Directory Structure
```
src/
├── main/
│   ├── java/kotlin/
│   │   └── com/company/app/
│   │       ├── GraphQLApplication.java/kt
│   │       ├── config/
│   │       │   ├── GraphQLConfig.java/kt
│   │       │   ├── SecurityConfig.java/kt
│   │       │   ├── DataLoaderConfig.java/kt
│   │       │   └── WebSocketConfig.java/kt
│   │       ├── domain/
│   │       │   ├── entity/
│   │       │   │   ├── User.java/kt
│   │       │   │   ├── Post.java/kt
│   │       │   │   └── Comment.java/kt
│   │       │   ├── repository/
│   │       │   │   ├── UserRepository.java/kt
│   │       │   │   ├── PostRepository.java/kt
│   │       │   │   └── CommentRepository.java/kt
│   │       │   └── service/
│   │       │       ├── UserService.java/kt
│   │       │       ├── PostService.java/kt
│   │       │       └── CommentService.java/kt
│   │       ├── graphql/
│   │       │   ├── resolver/
│   │       │   │   ├── query/
│   │       │   │   │   ├── UserQueryResolver.java/kt
│   │       │   │   │   ├── PostQueryResolver.java/kt
│   │       │   │   │   └── SearchQueryResolver.java/kt
│   │       │   │   ├── mutation/
│   │       │   │   │   ├── UserMutationResolver.java/kt
│   │       │   │   │   ├── PostMutationResolver.java/kt
│   │       │   │   │   └── AuthMutationResolver.java/kt
│   │       │   │   ├── subscription/
│   │       │   │   │   ├── PostSubscriptionResolver.java/kt
│   │       │   │   │   └── NotificationSubscriptionResolver.java/kt
│   │       │   │   └── field/
│   │       │   │       ├── UserFieldResolver.java/kt
│   │       │   │       └── PostFieldResolver.java/kt
│   │       │   ├── dataloader/
│   │       │   │   ├── UserDataLoader.java/kt
│   │       │   │   ├── PostDataLoader.java/kt
│   │       │   │   └── DataLoaderRegistrar.java/kt
│   │       │   ├── dto/
│   │       │   │   ├── input/
│   │       │   │   │   ├── CreateUserInput.java/kt
│   │       │   │   │   ├── UpdateUserInput.java/kt
│   │       │   │   │   └── CreatePostInput.java/kt
│   │       │   │   ├── payload/
│   │       │   │   │   ├── AuthPayload.java/kt
│   │       │   │   │   ├── UserPayload.java/kt
│   │       │   │   │   └── PostPayload.java/kt
│   │       │   │   └── filter/
│   │       │   │       ├── UserFilter.java/kt
│   │       │   │       ├── PostFilter.java/kt
│   │       │   │       └── PaginationInput.java/kt
│   │       │   ├── scalar/
│   │       │   │   ├── DateTimeScalar.java/kt
│   │       │   │   ├── EmailScalar.java/kt
│   │       │   │   └── JsonScalar.java/kt
│   │       │   ├── directive/
│   │       │   │   ├── AuthDirective.java/kt
│   │       │   │   ├── RoleDirective.java/kt
│   │       │   │   └── RateLimitDirective.java/kt
│   │       │   ├── exception/
│   │       │   │   ├── GraphQLExceptionHandler.java/kt
│   │       │   │   ├── AuthenticationException.java/kt
│   │       │   │   ├── AuthorizationException.java/kt
│   │       │   │   ├── ValidationException.java/kt
│   │       │   │   └── NotFoundException.java/kt
│   │       │   ├── context/
│   │       │   │   ├── SecurityContext.java/kt
│   │       │   │   ├── RequestContext.java/kt
│   │       │   │   └── DataLoaderContext.java/kt
│   │       │   └── instrumentation/
│   │       │       ├── TracingInstrumentation.java/kt
│   │       │       ├── MetricsInstrumentation.java/kt
│   │       │       ├── SecurityInstrumentation.java/kt
│   │       │       └── QueryComplexityInstrumentation.java/kt
│   │       └── security/
│   │           ├── JwtTokenProvider.java/kt
│   │           ├── UserDetailsService.java/kt
│   │           ├── SecurityUtils.java/kt
│   │           └── GraphQLSecurityInterceptor.java/kt
│   └── resources/
│       ├── application.yml
│       ├── application-dev.yml
│       ├── application-test.yml
│       ├── application-prod.yml
│       └── graphql/
│           ├── schema.graphqls
│           ├── types/
│           │   ├── user.graphqls
│           │   ├── post.graphqls
│           │   ├── comment.graphqls
│           │   ├── auth.graphqls
│           │   └── common.graphqls
│           ├── queries/
│           │   ├── user-queries.graphqls
│           │   ├── post-queries.graphqls
│           │   └── search-queries.graphqls
│           ├── mutations/
│           │   ├── auth-mutations.graphqls
│           │   ├── user-mutations.graphqls
│           │   └── post-mutations.graphqls
│           └── subscriptions/
│               ├── post-subscriptions.graphqls
│               └── notification-subscriptions.graphqls
└── test/
    ├── java/kotlin/
    │   └── com/company/app/
    │       ├── integration/
    │       │   ├── GraphQLIntegrationTest.java/kt
    │       │   ├── UserResolverIntegrationTest.java/kt
    │       │   └── SecurityIntegrationTest.java/kt
    │       ├── resolver/
    │       │   ├── UserQueryResolverTest.java/kt
    │       │   ├── PostMutationResolverTest.java/kt
    │       │   └── SubscriptionResolverTest.java/kt
    │       └── dataloader/
    │           ├── UserDataLoaderTest.java/kt
    │           └── PostDataLoaderTest.java/kt
    └── resources/
        ├── graphql-test/
        │   ├── user-queries.graphql
        │   ├── post-mutations.graphql
        │   └── subscription-tests.graphql
        └── application-test.yml
```

---

## Naming Conventions

### GraphQL Schema Naming

#### Types and Interfaces
```graphql
# ✅ CORRECT: PascalCase for types
type User {
    id: ID!
    firstName: String!
    lastName: String!
    email: String!
}

type Post {
    id: ID!
    title: String!
    content: String!
    author: User!
}

# ✅ CORRECT: Input types with Input suffix
input CreateUserInput {
    firstName: String!
    lastName: String!
    email: String!
    password: String!
}

input UpdatePostInput {
    id: ID!
    title: String
    content: String
}

# ✅ CORRECT: Payload types for mutations
type CreateUserPayload {
    user: User
    errors: [FieldError!]!
}

# ✅ CORRECT: Connection types for pagination
type UserConnection {
    edges: [UserEdge!]!
    pageInfo: PageInfo!
    totalCount: Int!
}

# ✅ CORRECT: Enums in SCREAMING_SNAKE_CASE
enum UserStatus {
    ACTIVE
    INACTIVE
    SUSPENDED
    PENDING_VERIFICATION
}
```

#### Fields and Arguments
```graphql
# ✅ CORRECT: camelCase for fields and arguments
type Query {
    # Single entity queries
    user(id: ID!): User
    post(id: ID!): Post
    
    # Collection queries with pagination
    users(
        filter: UserFilter
        sort: UserSort
        first: Int
        after: String
    ): UserConnection!
    
    # Search queries
    searchUsers(query: String!, limit: Int = 10): [User!]!
    searchPosts(
        query: String!
        authorId: ID
        categoryId: ID
        publishedAfter: DateTime
    ): PostConnection!
}

type Mutation {
    # CRUD operations with clear naming
    createUser(input: CreateUserInput!): CreateUserPayload!
    updateUser(input: UpdateUserInput!): UpdateUserPayload!
    deleteUser(id: ID!): DeleteUserPayload!
    
    # Authentication mutations
    login(email: String!, password: String!): AuthPayload!
    logout: Boolean!
    refreshToken(token: String!): AuthPayload!
}

type Subscription {
    # Past tense for events
    userCreated(organizationId: ID): User!
    postPublished(authorId: ID): Post!
    commentAdded(postId: ID!): Comment!
}
```

### Java/Kotlin Class Naming

#### Java Examples
```java
// ✅ CORRECT: Resolver naming with clear suffixes
@Component
public class UserQueryResolver {
    // Query methods
}

@Component
public class UserMutationResolver {
    // Mutation methods
}

@Component
public class UserFieldResolver {
    // Field resolution methods
}

// ✅ CORRECT: Service and Repository naming
@Service
public class UserService {
    // Business logic
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Data access methods
}

// ✅ CORRECT: Input/Output DTOs
public class CreateUserInput {
    @NotBlank private String firstName;
    @NotBlank private String lastName;
    @Email private String email;
}

public class UserPayload {
    private User user;
    private List<FieldError> errors;
}

// ✅ CORRECT: DataLoader naming
@Component
public class UserDataLoader {
    public DataLoader<Long, User> createDataLoader() {
        // Implementation
    }
}
```

#### Kotlin Examples
```kotlin
// ✅ CORRECT: Resolver naming with clear suffixes
@Component
class UserQueryResolver(
    private val userService: UserService,
    private val securityService: SecurityService
) {
    // Query methods
}

@Component
class UserMutationResolver(
    private val userService: UserService
) {
    // Mutation methods
}

// ✅ CORRECT: Service and Repository naming
@Service
class UserService(
    private val userRepository: UserRepository
) {
    // Business logic
}

interface UserRepository : JpaRepository<User, Long> {
    // Data access methods
}

// ✅ CORRECT: Data classes for DTOs
data class CreateUserInput(
    @field:NotBlank val firstName: String,
    @field:NotBlank val lastName: String,
    @field:Email val email: String,
    @field:NotBlank val password: String
)

data class UserPayload(
    val user: User?,
    val errors: List<FieldError> = emptyList()
)

// ✅ CORRECT: DataLoader component
@Component
class UserDataLoader(
    private val userRepository: UserRepository
) {
    fun createDataLoader(): DataLoader<Long, User> {
        // Implementation
    }
}
```

### Package Structure Naming
```
# ✅ CORRECT: Descriptive package names
com.company.app.graphql.resolver.query
com.company.app.graphql.resolver.mutation
com.company.app.graphql.resolver.subscription
com.company.app.graphql.resolver.field
com.company.app.graphql.dataloader
com.company.app.graphql.directive
com.company.app.graphql.scalar
com.company.app.graphql.exception
com.company.app.domain.entity
com.company.app.domain.repository
com.company.app.domain.service

# ❌ INCORRECT: Abbreviated names
com.company.app.gql.res
com.company.app.repo
com.company.app.svc
```

---

## Schema Design

### Schema-First Approach
Always define GraphQL schema files (`.graphqls`) before implementing resolvers:

```graphql
# schema.graphqls - Main schema file
schema {
    query: Query
    mutation: Mutation
    subscription: Subscription
}

# Include type definitions
type Query {
    # User queries
    me: User
    user(id: ID!): User
    users(filter: UserFilter, pagination: PaginationInput): UserConnection!
    
    # Post queries  
    post(id: ID!): Post
    posts(filter: PostFilter, pagination: PaginationInput): PostConnection!
    
    # Search
    search(query: String!, type: SearchType): SearchResult!
}

type Mutation {
    # Authentication
    login(input: LoginInput!): AuthPayload!
    register(input: RegisterInput!): AuthPayload!
    logout: Boolean!
    
    # User management
    updateProfile(input: UpdateProfileInput!): UserPayload!
    changePassword(input: ChangePasswordInput!): UserPayload!
    
    # Content management
    createPost(input: CreatePostInput!): PostPayload!
    updatePost(input: UpdatePostInput!): PostPayload!
    deletePost(id: ID!): DeletePayload!
}

type Subscription {
    postCreated(authorId: ID): Post!
    postUpdated(postId: ID!): Post!
    commentAdded(postId: ID!): Comment!
    userStatusChanged(userId: ID!): UserStatus!
}
```

### Type System Best Practices

#### Use Unions for Polymorphic Types
```graphql
# ✅ CORRECT: Union types for search results
union SearchResult = User | Post | Comment | Tag

type Query {
    search(query: String!): [SearchResult!]!
}

# ✅ CORRECT: Union types for notifications
union NotificationContent = 
    | PostLikedNotification 
    | CommentAddedNotification 
    | FollowNotification

type Notification {
    id: ID!
    recipient: User!
    content: NotificationContent!
    createdAt: DateTime!
    readAt: DateTime
}
```

#### Use Interfaces for Shared Fields
```graphql
# ✅ CORRECT: Interface for common entity fields
interface Node {
    id: ID!
}

interface Timestamped {
    createdAt: DateTime!
    updatedAt: DateTime!
}

interface Authored {
    author: User!
    createdAt: DateTime!
}

type Post implements Node & Timestamped & Authored {
    id: ID!
    title: String!
    content: String!
    author: User!
    createdAt: DateTime!
    updatedAt: DateTime!
    status: PostStatus!
}

type Comment implements Node & Timestamped & Authored {
    id: ID!
    content: String!
    author: User!
    post: Post!
    createdAt: DateTime!
    updatedAt: DateTime!
}
```

#### Pagination with Relay Connections
```graphql
# ✅ CORRECT: Relay-style pagination
type PageInfo {
    hasNextPage: Boolean!
    hasPreviousPage: Boolean!
    startCursor: String
    endCursor: String
}

type UserEdge {
    node: User!
    cursor: String!
}

type UserConnection {
    edges: [UserEdge!]!
    pageInfo: PageInfo!
    totalCount: Int!
}

input PaginationInput {
    first: Int
    after: String
    last: Int
    before: String
}

type Query {
    users(pagination: PaginationInput): UserConnection!
}
```

---

## Null Handling

### GraphQL Schema Nullability
```graphql
# ✅ CORRECT: Clear nullability rules
type User {
    # Required fields - never null
    id: ID!
    email: String!
    firstName: String!
    lastName: String!
    createdAt: DateTime!
    
    # Optional fields - can be null
    avatar: String
    bio: String
    lastLoginAt: DateTime
    phoneNumber: String
    
    # Related entities - use appropriate nullability
    organization: Organization  # Can be null if user has no organization
    posts: [Post!]!            # List is never null, but can be empty
    favoritePost: Post         # Can be null if user has no favorite
}

# ✅ CORRECT: Input nullability
input UpdateUserInput {
    id: ID!              # Required - must provide user ID
    firstName: String    # Optional - only update if provided
    lastName: String     # Optional - only update if provided
    bio: String         # Optional - can be set to null to clear
}
```

### Java Optional Handling
```java
// ✅ CORRECT: Always use Optional for nullable service returns
@Service
public class UserService {
    
    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }
    
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }
    
    // ✅ CORRECT: Never return null, use Optional.empty()
    public Optional<Organization> getUserOrganization(Long userId) {
        return findById(userId)
                .map(User::getOrganization);
    }
    
    // ✅ CORRECT: Collections should never be null
    public List<Post> getUserPosts(Long userId) {
        return findById(userId)
                .map(User::getPosts)
                .orElse(Collections.emptyList());
    }
}

// ✅ CORRECT: Resolver null handling
@Component
public class UserQueryResolver {
    
    @SchemaMapping(typeName = "Query")
    public User user(@Argument String id) {
        return userService.findById(Long.valueOf(id))
                .orElseThrow(() -> new GraphQLException("User not found"));
    }
    
    @SchemaMapping(typeName = "User")
    public String avatar(User user) {
        // Return null for optional fields when not present
        return user.getAvatarUrl().orElse(null);
    }
    
    @SchemaMapping(typeName = "User")
    public List<Post> posts(User user) {
        // Never return null for lists
        return userService.getUserPosts(user.getId());
    }
}
```

### Kotlin Null Safety
```kotlin
// ✅ CORRECT: Leverage Kotlin null safety
@Service
class UserService(
    private val userRepository: UserRepository
) {
    
    fun findById(id: Long): User? {
        return userRepository.findById(id).orElse(null)
    }
    
    fun findByEmail(email: String): User? {
        return userRepository.findByEmail(email).orElse(null)
    }
    
    // ✅ CORRECT: Use nullable types appropriately
    fun getUserOrganization(userId: Long): Organization? {
        return findById(userId)?.organization
    }
    
    // ✅ CORRECT: Collections should never be null
    fun getUserPosts(userId: Long): List<Post> {
        return findById(userId)?.posts ?: emptyList()
    }
}

// ✅ CORRECT: Resolver null handling in Kotlin
@Component
class UserQueryResolver(
    private val userService: UserService
) {
    
    @SchemaMapping(typeName = "Query")
    fun user(@Argument id: String): User {
        return userService.findById(id.toLong())
            ?: throw GraphQLException("User not found")
    }
    
    @SchemaMapping(typeName = "User")
    fun avatar(user: User): String? {
        // Return null for optional fields when not present
        return user.avatarUrl
    }
    
    @SchemaMapping(typeName = "User") 
    fun posts(user: User): List<Post> {
        // Never return null for lists
        return userService.getUserPosts(user.id)
    }
}
```

---

## Resolver Implementation

### Query Resolvers

#### Java Implementation
```java
@Component
public class UserQueryResolver {
    
    private final UserService userService;
    private final SecurityService securityService;
    
    public UserQueryResolver(UserService userService, SecurityService securityService) {
        this.userService = userService;
        this.securityService = securityService;
    }
    
    @SchemaMapping(typeName = "Query")
    public User me(DataFetchingEnvironment environment) {
        SecurityContext context = environment.getContext();
        Long userId = securityService.getCurrentUserId(context);
        
        if (userId == null) {
            throw new AuthenticationException("Authentication required");
        }
        
        return userService.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));
    }
    
    @SchemaMapping(typeName = "Query")
    public User user(@Argument String id, DataFetchingEnvironment environment) {
        SecurityContext context = environment.getContext();
        
        User user = userService.findById(Long.valueOf(id))
                .orElseThrow(() -> new NotFoundException("User not found"));
        
        if (!securityService.canViewUser(context, user)) {
            throw new AuthorizationException("Access denied");
        }
        
        return user;
    }
    
    @SchemaMapping(typeName = "Query")
    public UserConnection users(
            @Argument UserFilter filter,
            @Argument PaginationInput pagination,
            DataFetchingEnvironment environment) {
        
        SecurityContext context = environment.getContext();
        securityService.requireRole(context, "ADMIN");
        
        return userService.findUsers(filter, pagination);
    }
}
```

#### Kotlin Implementation
```kotlin
@Component
class UserQueryResolver(
    private val userService: UserService,
    private val securityService: SecurityService
) {
    
    @SchemaMapping(typeName = "Query")
    fun me(environment: DataFetchingEnvironment): User {
        val context = environment.getContext<SecurityContext>()
        val userId = securityService.getCurrentUserId(context)
            ?: throw AuthenticationException("Authentication required")
        
        return userService.findById(userId)
            ?: throw NotFoundException("User not found")
    }
    
    @SchemaMapping(typeName = "Query")
    fun user(
        @Argument id: String,
        environment: DataFetchingEnvironment
    ): User {
        val context = environment.getContext<SecurityContext>()
        
        val user = userService.findById(id.toLong())
            ?: throw NotFoundException("User not found")
        
        if (!securityService.canViewUser(context, user)) {
            throw AuthorizationException("Access denied")
        }
        
        return user
    }
    
    @SchemaMapping(typeName = "Query")
    suspend fun users(
        @Argument filter: UserFilter?,
        @Argument pagination: PaginationInput?,
        environment: DataFetchingEnvironment
    ): UserConnection {
        val context = environment.getContext<SecurityContext>()
        securityService.requireRole(context, "ADMIN")
        
        return userService.findUsers(filter, pagination)
    }
}
```

### Mutation Resolvers

#### Java Implementation
```java
@Component
public class UserMutationResolver {
    
    private final UserService userService;
    private final ValidationService validationService;
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional
    suspend fun createUser(@Argument input: CreateUserInput): CreateUserPayload {
        return try {
            validationService.validate(input)
            val user = userService.createUser(input)
            CreateUserPayload.success(user)
        } catch (e: ValidationException) {
            CreateUserPayload.withErrors(e.fieldErrors)
        }
    }
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional
    suspend fun updateUser(
        @Argument input: UpdateUserInput,
        environment: DataFetchingEnvironment
    ): UpdateUserPayload {
        val context = environment.getContext<SecurityContext>()
        
        return try {
            validationService.validate(input)
            val user = userService.updateUser(input, context)
            UpdateUserPayload.success(user)
        } catch (e: ValidationException) {
            UpdateUserPayload.withErrors(e.fieldErrors)
        } catch (e: AuthorizationException) {
            throw e // Re-throw security exceptions
        }
    }
}
```

### Subscription Resolvers

#### Java Implementation
```java
@Component
public class PostSubscriptionResolver {
    
    private final PostService postService;
    private final SecurityService securityService;
    
    @SchemaMapping(typeName = "Subscription")
    public Publisher<Post> postCreated(
            @Argument String authorId,
            DataFetchingEnvironment environment) {
        
        SecurityContext context = environment.getContext();
        
        if (!securityService.isAuthenticated(context)) {
            throw new AuthenticationException("Authentication required for subscriptions");
        }
        
        return postService.getPostCreatedPublisher()
                .filter(post -> authorId == null || authorId.equals(post.getAuthor().getId().toString()))
                .filter(post -> securityService.canViewPost(context, post));
    }
    
    @SchemaMapping(typeName = "Subscription")
    public Publisher<Comment> commentAdded(
            @Argument String postId,
            DataFetchingEnvironment environment) {
        
        SecurityContext context = environment.getContext();
        Long postIdLong = Long.valueOf(postId);
        
        return postService.getCommentAddedPublisher()
                .filter(comment -> postIdLong.equals(comment.getPost().getId()))
                .filter(comment -> securityService.canViewComment(context, comment));
    }
}
```

#### Kotlin Implementation
```kotlin
@Component
class PostSubscriptionResolver(
    private val postService: PostService,
    private val securityService: SecurityService
) {
    
    @SchemaMapping(typeName = "Subscription")
    fun postCreated(
        @Argument authorId: String?,
        environment: DataFetchingEnvironment
    ): Publisher<Post> {
        val context = environment.getContext<SecurityContext>()
        
        if (!securityService.isAuthenticated(context)) {
            throw AuthenticationException("Authentication required for subscriptions")
        }
        
        return postService.getPostCreatedPublisher()
            .filter { post -> 
                authorId == null || authorId == post.author.id.toString()
            }
            .filter { post -> 
                securityService.canViewPost(context, post)
            }
    }
    
    @SchemaMapping(typeName = "Subscription")
    fun commentAdded(
        @Argument postId: String,
        environment: DataFetchingEnvironment
    ): Publisher<Comment> {
        val context = environment.getContext<SecurityContext>()
        val postIdLong = postId.toLong()
        
        return postService.getCommentAddedPublisher()
            .filter { comment -> postIdLong == comment.post.id }
            .filter { comment -> securityService.canViewComment(context, comment) }
    }
}
```

### Field Resolvers

#### Java Implementation
```java
@Component
public class UserFieldResolver {
    
    private final PostService postService;
    private final OrganizationService organizationService;
    
    @SchemaMapping(typeName = "User")
    public CompletableFuture<List<Post>> posts(
            User user,
            @Argument PostFilter filter,
            @Argument PaginationInput pagination,
            DataFetchingEnvironment environment) {
        
        DataLoader<Long, List<Post>> postDataLoader = 
            environment.getDataLoader("userPostsDataLoader");
        
        return postDataLoader.load(user.getId());
    }
    
    @SchemaMapping(typeName = "User")
    public CompletableFuture<Organization> organization(
            User user,
            DataFetchingEnvironment environment) {
        
        if (user.getOrganizationId() == null) {
            return CompletableFuture.completedFuture(null);
        }
        
        DataLoader<Long, Organization> orgDataLoader = 
            environment.getDataLoader("organizationDataLoader");
        
        return orgDataLoader.load(user.getOrganizationId());
    }
    
    @SchemaMapping(typeName = "User")
    public String fullName(User user) {
        return user.getFirstName() + " " + user.getLastName();
    }
    
    @SchemaMapping(typeName = "User")
    public Boolean isOnline(User user) {
        return user.getLastActiveAt() != null && 
               user.getLastActiveAt().isAfter(LocalDateTime.now().minusMinutes(5));
    }
}
```

#### Kotlin Implementation  
```kotlin
@Component
class UserFieldResolver(
    private val postService: PostService,
    private val organizationService: OrganizationService
) {
    
    @SchemaMapping(typeName = "User")
    suspend fun posts(
        user: User,
        @Argument filter: PostFilter?,
        @Argument pagination: PaginationInput?,
        environment: DataFetchingEnvironment
    ): List<Post> {
        val postDataLoader = environment.getDataLoader<Long, List<Post>>("userPostsDataLoader")
        return postDataLoader.load(user.id).await()
    }
    
    @SchemaMapping(typeName = "User") 
    suspend fun organization(
        user: User,
        environment: DataFetchingEnvironment
    ): Organization? {
        val organizationId = user.organizationId ?: return null
        
        val orgDataLoader = environment.getDataLoader<Long, Organization>("organizationDataLoader")
        return orgDataLoader.load(organizationId).await()
    }
    
    @SchemaMapping(typeName = "User")
    fun fullName(user: User): String {
        return "${user.firstName} ${user.lastName}"
    }
    
    @SchemaMapping(typeName = "User")
    fun isOnline(user: User): Boolean {
        return user.lastActiveAt?.isAfter(LocalDateTime.now().minusMinutes(5)) ?: false
    }
}
```

---

## Error Handling

### Custom GraphQL Exceptions

#### Java Implementation
```java
// Base GraphQL Exception
public abstract class GraphQLException extends RuntimeException {
    private final String errorCode;
    private final Map<String, Object> extensions;
    
    public GraphQLException(String message, String errorCode) {
        super(message);
        this.errorCode = errorCode;
        this.extensions = new HashMap<>();
    }
    
    public String getErrorCode() { return errorCode; }
    public Map<String, Object> getExtensions() { return extensions; }
    
    public void addExtension(String key, Object value) {
        extensions.put(key, value);
    }
}

// Specific Exception Types
public class AuthenticationException extends GraphQLException {
    public AuthenticationException(String message) {
        super(message, "AUTHENTICATION_ERROR");
    }
}

public class AuthorizationException extends GraphQLException {
    public AuthorizationException(String message) {
        super(message, "AUTHORIZATION_ERROR");
    }
}

public class ValidationException extends GraphQLException {
    private final List<FieldError> fieldErrors;
    
    public ValidationException(List<FieldError> fieldErrors) {
        super("Validation failed", "VALIDATION_ERROR");
        this.fieldErrors = fieldErrors;
        addExtension("fieldErrors", fieldErrors);
    }
    
    public List<FieldError> getFieldErrors() { return fieldErrors; }
}

public class NotFoundException extends GraphQLException {
    public NotFoundException(String message) {
        super(message, "NOT_FOUND");
    }
}

public class BusinessException extends GraphQLException {
    public BusinessException(String message, String errorCode) {
        super(message, errorCode);
    }
}
```

#### Kotlin Implementation
```kotlin
// Base GraphQL Exception
abstract class GraphQLException(
    message: String,
    val errorCode: String,
    cause: Throwable? = null
) : RuntimeException(message, cause) {
    
    private val extensions = mutableMapOf<String, Any>()
    
    fun getExtensions(): Map<String, Any> = extensions.toMap()
    
    fun addExtension(key: String, value: Any) {
        extensions[key] = value
    }
}

// Specific Exception Types
class AuthenticationException(message: String) : 
    GraphQLException(message, "AUTHENTICATION_ERROR")

class AuthorizationException(message: String) : 
    GraphQLException(message, "AUTHORIZATION_ERROR")

class ValidationException(val fieldErrors: List<FieldError>) : 
    GraphQLException("Validation failed", "VALIDATION_ERROR") {
    
    init {
        addExtension("fieldErrors", fieldErrors)
    }
}

class NotFoundException(message: String) : 
    GraphQLException(message, "NOT_FOUND")

class BusinessException(message: String, errorCode: String) : 
    GraphQLException(message, errorCode)
```

### Global Error Handler

#### Java Implementation
```java
@Component
public class GraphQLExceptionHandler implements DataFetcherExceptionHandler {
    
    private static final Logger logger = LoggerFactory.getLogger(GraphQLExceptionHandler.class);
    
    @Override
    public DataFetcherExceptionHandlerResult onException(
            DataFetcherExceptionHandlerParameters handlerParameters) {
        
        Throwable exception = handlerParameters.getException();
        SourceLocation sourceLocation = handlerParameters.getSourceLocation();
        ResultPath path = handlerParameters.getPath();
        
        GraphQLError error = createGraphQLError(exception, sourceLocation, path);
        
        return DataFetcherExceptionHandlerResult.newResult()
                .error(error)
                .build();
    }
    
    private GraphQLError createGraphQLError(
            Throwable exception, 
            SourceLocation sourceLocation, 
            ResultPath path) {
        
        if (exception instanceof GraphQLException) {
            GraphQLException gqlException = (GraphQLException) exception;
            return GraphQLError.newError()
                    .message(gqlException.getMessage())
                    .location(sourceLocation)
                    .path(path)
                    .extensions(createExtensions(gqlException))
                    .build();
        }
        
        // Log unexpected exceptions
        logger.error("Unexpected GraphQL error", exception);
        
        return GraphQLError.newError()
                .message("Internal server error")
                .location(sourceLocation)
                .path(path)
                .extensions(Map.of("errorCode", "INTERNAL_ERROR"))
                .build();
    }
    
    private Map<String, Object> createExtensions(GraphQLException exception) {
        Map<String, Object> extensions = new HashMap<>(exception.getExtensions());
        extensions.put("errorCode", exception.getErrorCode());
        extensions.put("timestamp", Instant.now().toString());
        return extensions;
    }
}
```

#### Kotlin Implementation
```kotlin
@Component
class GraphQLExceptionHandler : DataFetcherExceptionHandler {
    
    private val logger = LoggerFactory.getLogger(GraphQLExceptionHandler::class.java)
    
    override fun onException(
        handlerParameters: DataFetcherExceptionHandlerParameters
    ): DataFetcherExceptionHandlerResult {
        
        val exception = handlerParameters.exception
        val sourceLocation = handlerParameters.sourceLocation
        val path = handlerParameters.path
        
        val error = createGraphQLError(exception, sourceLocation, path)
        
        return DataFetcherExceptionHandlerResult.newResult()
            .error(error)
            .build()
    }
    
    private fun createGraphQLError(
        exception: Throwable,
        sourceLocation: SourceLocation,
        path: ResultPath
    ): GraphQLError {
        
        return when (exception) {
            is GraphQLException -> {
                GraphQLError.newError()
                    .message(exception.message)
                    .location(sourceLocation)
                    .path(path)
                    .extensions(createExtensions(exception))
                    .build()
            }
            else -> {
                // Log unexpected exceptions
                logger.error("Unexpected GraphQL error", exception)
                
                GraphQLError.newError()
                    .message("Internal server error")
                    .location(sourceLocation)
                    .path(path)
                    .extensions(mapOf("errorCode" to "INTERNAL_ERROR"))
                    .build()
            }
        }
    }
    
    private fun createExtensions(exception: GraphQLException): Map<String, Any> {
        return exception.getExtensions() + mapOf(
            "errorCode" to exception.errorCode,
            "timestamp" to Instant.now().toString()
        )
    }
}
```

### Payload Types with Error Handling

#### GraphQL Schema
```graphql
# ✅ CORRECT: Payload types for mutations with error handling
type CreateUserPayload {
    user: User
    errors: [FieldError!]!
    success: Boolean!
}

type UpdateUserPayload {
    user: User
    errors: [FieldError!]!
    success: Boolean!
}

type DeleteUserPayload {
    deletedId: ID
    success: Boolean!
    errors: [FieldError!]!
}

type FieldError {
    field: String!
    message: String!
    code: String!
}

# ✅ CORRECT: Union type for operation results
union UserOperationResult = UserSuccess | UserError

type UserSuccess {
    user: User!
}

type UserError {
    message: String!
    code: String!
    field: String
}
```

#### Java Payload Implementation
```java
public class CreateUserPayload {
    private final User user;
    private final List<FieldError> errors;
    private final boolean success;
    
    private CreateUserPayload(User user, List<FieldError> errors, boolean success) {
        this.user = user;
        this.errors = errors != null ? errors : Collections.emptyList();
        this.success = success;
    }
    
    public static CreateUserPayload success(User user) {
        return new CreateUserPayload(user, null, true);
    }
    
    public static CreateUserPayload withErrors(List<FieldError> errors) {
        return new CreateUserPayload(null, errors, false);
    }
    
    // Getters
    public User getUser() { return user; }
    public List<FieldError> getErrors() { return errors; }
    public boolean isSuccess() { return success; }
}

public class FieldError {
    private final String field;
    private final String message;
    private final String code;
    
    public FieldError(String field, String message, String code) {
        this.field = field;
        this.message = message;
        this.code = code;
    }
    
    // Getters
    public String getField() { return field; }
    public String getMessage() { return message; }
    public String getCode() { return code; }
}
```

#### Kotlin Payload Implementation
```kotlin
data class CreateUserPayload(
    val user: User? = null,
    val errors: List<FieldError> = emptyList(),
    val success: Boolean = user != null
) {
    companion object {
        fun success(user: User) = CreateUserPayload(user = user)
        fun withErrors(errors: List<FieldError>) = CreateUserPayload(errors = errors)
    }
}

data class FieldError(
    val field: String,
    val message: String,
    val code: String
)
```

---

## Security

### Authentication and Authorization

#### Security Configuration
```java
// Java Security Configuration
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class GraphQLSecurityConfig {
    
    private final JwtTokenProvider tokenProvider;
    private final UserDetailsService userDetailsService;
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session -> 
                    session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                    .requestMatchers("/graphql").permitAll()
                    .requestMatchers("/graphiql/**").hasRole("ADMIN")
                    .anyRequest().authenticated())
                .addFilterBefore(new JwtAuthenticationFilter(tokenProvider), 
                    UsernamePasswordAuthenticationFilter.class)
                .build();
    }
    
    @Bean
    public WebGraphQlConfigurer webGraphQlConfigurer(SecurityService securityService) {
        return configurer -> {
            configurer.configureWebMvc(webMvcConfigurer -> {
                webMvcConfigurer.configureArgumentResolvers(resolvers -> {
                    resolvers.add(new SecurityContextArgumentResolver());
                });
            });
        };
    }
}
```

```kotlin
// Kotlin Security Configuration
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
class GraphQLSecurityConfig(
    private val tokenProvider: JwtTokenProvider,
    private val userDetailsService: UserDetailsService
) {
    
    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        return http
            .csrf { it.disable() }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
            .authorizeHttpRequests { auth ->
                auth
                    .requestMatchers("/graphql").permitAll()
                    .requestMatchers("/graphiql/**").hasRole("ADMIN")
                    .anyRequest().authenticated()
            }
            .addFilterBefore(
                JwtAuthenticationFilter(tokenProvider),
                UsernamePasswordAuthenticationFilter::class.java
            )
            .build()
    }
    
    @Bean
    fun webGraphQlConfigurer(securityService: SecurityService): WebGraphQlConfigurer {
        return WebGraphQlConfigurer { configurer ->
            configurer.configureWebMvc { webMvcConfigurer ->
                webMvcConfigurer.configureArgumentResolvers { resolvers ->
                    resolvers.add(SecurityContextArgumentResolver())
                }
            }
        }
    }
}
```

#### Custom Directives for Authorization
```graphql
# ✅ CORRECT: Security directives
directive @auth on FIELD_DEFINITION | OBJECT
directive @hasRole(role: String!) on FIELD_DEFINITION | OBJECT  
directive @hasPermission(permission: String!) on FIELD_DEFINITION | OBJECT
directive @rateLimit(max: Int!, window: Int!) on FIELD_DEFINITION

type Query {
    # Public query - no auth required
    posts: [Post!]!
    
    # Requires authentication
    me: User @auth
    
    # Requires specific role
    adminDashboard: AdminDashboard @hasRole(role: "ADMIN")
    
    # Requires specific permission
    userAnalytics: UserAnalytics @hasPermission(permission: "READ_ANALYTICS")
    
    # Rate limited query
    searchUsers(query: String!): [User!]! @rateLimit(max: 100, window: 3600)
}

type User @auth {
    id: ID!
    email: String!
    
    # Only admin or self can see sensitive data
    phoneNumber: String @hasPermission(permission: "READ_SENSITIVE_DATA")
    lastLoginAt: DateTime @hasRole(role: "ADMIN")
}
```

#### Directive Implementation
```java
// Java Authorization Directive
@Component
public class AuthDirective implements SchemaDirectiveWiring {
    
    private final SecurityService securityService;
    
    @Override
    public GraphQLFieldDefinition onField(SchemaDirectiveWiringEnvironment<GraphQLFieldDefinition> environment) {
        GraphQLFieldDefinition field = environment.getElement();
        DataFetcher<?> originalDataFetcher = environment.getCodeRegistry().getDataFetcher(
            environment.getFieldsContainer(), field);
        
        DataFetcher<?> authDataFetcher = (DataFetchingEnvironment dfe) -> {
            SecurityContext context = dfe.getContext();
            
            if (!securityService.isAuthenticated(context)) {
                throw new AuthenticationException("Authentication required");
            }
            
            return originalDataFetcher.get(dfe);
        };
        
        environment.getCodeRegistry().dataFetcher(
            environment.getFieldsContainer(), field, authDataFetcher);
        
        return field;
    }
}
```

```kotlin
// Kotlin Authorization Directive
@Component
class AuthDirective(
    private val securityService: SecurityService
) : SchemaDirectiveWiring {
    
    override fun onField(environment: SchemaDirectiveWiringEnvironment<GraphQLFieldDefinition>): GraphQLFieldDefinition {
        val field = environment.element
        val originalDataFetcher = environment.codeRegistry.getDataFetcher(
            environment.fieldsContainer, field
        )
        
        val authDataFetcher = DataFetcher { dfe ->
            val context = dfe.getContext<SecurityContext>()
            
            if (!securityService.isAuthenticated(context)) {
                throw AuthenticationException("Authentication required")
            }
            
            originalDataFetcher.get(dfe)
        }
        
        environment.codeRegistry.dataFetcher(
            environment.fieldsContainer, field, authDataFetcher
        )
        
        return field
    }
}
```

---

## Performance Optimization

### DataLoader Pattern

#### Java DataLoader Implementation
```java
@Component
public class UserDataLoader {
    
    private final UserRepository userRepository;
    private final CacheManager cacheManager;
    
    public DataLoader<Long, User> createUserDataLoader() {
        return DataLoader.newMappedDataLoader((Set<Long> userIds, BatchLoaderEnvironment environment) -> {
            
            // Check cache first
            Cache cache = cacheManager.getCache("users");
            Map<Long, User> cachedUsers = new HashMap<>();
            Set<Long> uncachedIds = new HashSet<>();
            
            for (Long id : userIds) {
                User cachedUser = cache.get(id, User.class);
                if (cachedUser != null) {
                    cachedUsers.put(id, cachedUser);
                } else {
                    uncachedIds.add(id);
                }
            }
            
            // Batch load uncached users
            List<User> users = userRepository.findAllById(uncachedIds);
            Map<Long, User> userMap = users.stream()
                    .collect(Collectors.toMap(User::getId, Function.identity()));
            
            // Cache loaded users
            users.forEach(user -> cache.put(user.getId(), user));
            
            // Combine cached and loaded users
            cachedUsers.putAll(userMap);
            
            return CompletableFuture.completedFuture(cachedUsers);
        });
    }
    
    public DataLoader<Long, List<Post>> createUserPostsDataLoader() {
        return DataLoader.newMappedDataLoader((Set<Long> userIds, BatchLoaderEnvironment environment) -> {
            
            List<Post> posts = userRepository.findPostsByUserIds(userIds);
            
            Map<Long, List<Post>> groupedPosts = posts.stream()
                    .collect(Collectors.groupingBy(post -> post.getAuthor().getId()));
            
            // Ensure all requested user IDs have a list (even if empty)
            Map<Long, List<Post>> result = userIds.stream()
                    .collect(Collectors.toMap(
                            Function.identity(),
                            id -> groupedPosts.getOrDefault(id, Collections.emptyList())
                    ));
            
            return CompletableFuture.completedFuture(result);
        });
    }
}
```

#### Kotlin DataLoader Implementation
```kotlin
@Component
class UserDataLoader(
    private val userRepository: UserRepository,
    private val cacheManager: CacheManager
) {
    
    fun createUserDataLoader(): DataLoader<Long, User> {
        return DataLoader.newMappedDataLoader { userIds, environment ->
            
            // Check cache first
            val cache = cacheManager.getCache("users")
            val cachedUsers = mutableMapOf<Long, User>()
            val uncachedIds = mutableSetOf<Long>()
            
            userIds.forEach { id ->
                val cachedUser = cache?.get(id, User::class.java)
                if (cachedUser != null) {
                    cachedUsers[id] = cachedUser
                } else {
                    uncachedIds.add(id)
                }
            }
            
            // Batch load uncached users
            val users = userRepository.findAllById(uncachedIds)
            val userMap = users.associateBy { it.id }
            
            // Cache loaded users
            users.forEach { user -> cache?.put(user.id, user) }
            
            // Combine cached and loaded users
            val result = cachedUsers + userMap
            
            CompletableFuture.completedFuture(result)
        }
    }
    
    fun createUserPostsDataLoader(): DataLoader<Long, List<Post>> {
        return DataLoader.newMappedDataLoader { userIds, environment ->
            
            val posts = userRepository.findPostsByUserIds(userIds)
            val groupedPosts = posts.groupBy { it.author.id }
            
            // Ensure all requested user IDs have a list (even if empty)
            val result = userIds.associateWith { id ->
                groupedPosts[id] ?: emptyList()
            }
            
            CompletableFuture.completedFuture(result)
        }
    }
}
```

### Query Complexity Analysis

#### Java Implementation
```java
@Component
public class QueryComplexityInstrumentation implements Instrumentation {
    
    private static final int MAX_COMPLEXITY = 1000;
    private static final int MAX_DEPTH = 15;
    
    @Override
    public InstrumentationContext<ExecutionResult> beginExecution(
            InstrumentationExecutionParameters parameters,
            InstrumentationState state) {
        
        ExecutionInput executionInput = parameters.getExecutionInput();
        Document document = executionInput.getQuery();
        
        // Analyze query complexity
        QueryComplexityInfo complexityInfo = QueryComplexityAnalysis.analyzeComplexity(
                document, parameters.getSchema());
        
        if (complexityInfo.getComplexity() > MAX_COMPLEXITY) {
            throw new GraphQLException(
                    "Query complexity " + complexityInfo.getComplexity() + 
                    " exceeds maximum allowed " + MAX_COMPLEXITY);
        }
        
        if (complexityInfo.getDepth() > MAX_DEPTH) {
            throw new GraphQLException(
                    "Query depth " + complexityInfo.getDepth() + 
                    " exceeds maximum allowed " + MAX_DEPTH);
        }
        
        return InstrumentationContext.noOp();
    }
}
```

#### Kotlin Implementation
```kotlin
@Component
class QueryComplexityInstrumentation : Instrumentation {
    
    companion object {
        private const val MAX_COMPLEXITY = 1000
        private const val MAX_DEPTH = 15
    }
    
    override fun beginExecution(
        parameters: InstrumentationExecutionParameters,
        state: InstrumentationState?
    ): InstrumentationContext<ExecutionResult> {
        
        val executionInput = parameters.executionInput
        val document = executionInput.query
        
        // Analyze query complexity
        val complexityInfo = QueryComplexityAnalysis.analyzeComplexity(
            document, parameters.schema
        )
        
        if (complexityInfo.complexity > MAX_COMPLEXITY) {
            throw GraphQLException(
                "Query complexity ${complexityInfo.complexity} exceeds maximum allowed $MAX_COMPLEXITY"
            )
        }
        
        if (complexityInfo.depth > MAX_DEPTH) {
            throw GraphQLException(
                "Query depth ${complexityInfo.depth} exceeds maximum allowed $MAX_DEPTH"
            )
        }
        
        return InstrumentationContext.noOp()
    }
}
```

---

## Testing

### Unit Testing Resolvers

#### Java Tests
```java
@ExtendWith(MockitoExtension.class)
class UserQueryResolverTest {
    
    @Mock
    private UserService userService;
    
    @Mock
    private SecurityService securityService;
    
    @InjectMocks
    private UserQueryResolver userQueryResolver;
    
    @Mock
    private DataFetchingEnvironment environment;
    
    @Mock
    private SecurityContext securityContext;
    
    @Test
    void me_shouldReturnCurrentUser_whenAuthenticated() {
        // Given
        Long userId = 1L;
        User user = createTestUser(userId);
        
        when(environment.getContext()).thenReturn(securityContext);
        when(securityService.getCurrentUserId(securityContext)).thenReturn(userId);
        when(userService.findById(userId)).thenReturn(Optional.of(user));
        
        // When
        User result = userQueryResolver.me(environment);
        
        // Then
        assertThat(result).isEqualTo(user);
        verify(securityService).getCurrentUserId(securityContext);
        verify(userService).findById(userId);
    }
    
    @Test
    void me_shouldThrowAuthenticationException_whenNotAuthenticated() {
        // Given
        when(environment.getContext()).thenReturn(securityContext);
        when(securityService.getCurrentUserId(securityContext)).thenReturn(null);
        
        // When & Then
        assertThatThrownBy(() -> userQueryResolver.me(environment))
                .isInstanceOf(AuthenticationException.class)
                .hasMessage("Authentication required");
    }
    
    @Test
    void user_shouldReturnUser_whenUserExistsAndAuthorized() {
        // Given
        String userId = "1";
        User user = createTestUser(1L);
        
        when(environment.getContext()).thenReturn(securityContext);
        when(userService.findById(1L)).thenReturn(Optional.of(user));
        when(securityService.canViewUser(securityContext, user)).thenReturn(true);
        
        // When
        User result = userQueryResolver.user(userId, environment);
        
        // Then
        assertThat(result).isEqualTo(user);
    }
    
    private User createTestUser(Long id) {
        User user = new User();
        user.setId(id);
        user.setEmail("test@example.com");
        user.setFirstName("John");
        user.setLastName("Doe");
        return user;
    }
}
```

#### Kotlin Tests
```kotlin
@ExtendWith(MockKExtension::class)
class UserQueryResolverTest {
    
    @MockK
    private lateinit var userService: UserService
    
    @MockK
    private lateinit var securityService: SecurityService
    
    @InjectMockKs
    private lateinit var userQueryResolver: UserQueryResolver
    
    @MockK
    private lateinit var environment: DataFetchingEnvironment
    
    @MockK
    private lateinit var securityContext: SecurityContext
    
    @Test
    fun `me should return current user when authenticated`() {
        // Given
        val userId = 1L
        val user = createTestUser(userId)
        
        every { environment.getContext<SecurityContext>() } returns securityContext
        every { securityService.getCurrentUserId(securityContext) } returns userId
        every { userService.findById(userId) } returns user
        
        // When
        val result = userQueryResolver.me(environment)
        
        // Then
        assertThat(result).isEqualTo(user)
        verify { securityService.getCurrentUserId(securityContext) }
        verify { userService.findById(userId) }
    }
    
    @Test
    fun `me should throw AuthenticationException when not authenticated`() {
        // Given
        every { environment.getContext<SecurityContext>() } returns securityContext
        every { securityService.getCurrentUserId(securityContext) } returns null
        
        // When & Then
        assertThrows<AuthenticationException> {
            userQueryResolver.me(environment)
        }.also { exception ->
            assertThat(exception.message).isEqualTo("Authentication required")
        }
    }
    
    @Test
    fun `user should return user when user exists and authorized`() {
        // Given
        val userId = "1"
        val user = createTestUser(1L)
        
        every { environment.getContext<SecurityContext>() } returns securityContext
        every { userService.findById(1L) } returns user
        every { securityService.canViewUser(securityContext, user) } returns true
        
        // When
        val result = userQueryResolver.user(userId, environment)
        
        // Then
        assertThat(result).isEqualTo(user)
    }
    
    private fun createTestUser(id: Long): User {
        return User(
            id = id,
            email = "test@example.com",
            firstName = "John",
            lastName = "Doe"
        )
    }
}
```

### Integration Testing

#### Java Integration Tests
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
@Testcontainers
class GraphQLIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");
    
    @Autowired
    private WebTestClient webTestClient;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private JwtTokenProvider tokenProvider;
    
    @Test
    void shouldExecuteUserQuery() {
        // Given
        User user = createAndSaveTestUser();
        String token = tokenProvider.generateToken(user.getEmail());
        
        String query = """
                query GetUser($id: ID!) {
                    user(id: $id) {
                        id
                        firstName
                        lastName
                        email
                        posts {
                            id
                            title
                        }
                    }
                }
                """;
        
        // When & Then
        webTestClient
                .post()
                .uri("/graphql")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(Map.of(
                        "query", query,
                        "variables", Map.of("id", user.getId().toString())
                ))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.data.user.id").isEqualTo(user.getId().toString())
                .jsonPath("$.data.user.firstName").isEqualTo(user.getFirstName())
                .jsonPath("$.data.user.email").isEqualTo(user.getEmail())
                .jsonPath("$.errors").doesNotExist();
    }
    
    @Test
    void shouldExecuteCreateUserMutation() {
        // Given
        String mutation = """
                mutation CreateUser($input: CreateUserInput!) {
                    createUser(input: $input) {
                        user {
                            id
                            firstName
                            lastName
                            email
                        }
                        errors {
                            field
                            message
                            code
                        }
                        success
                    }
                }
                """;
        
        Map<String, Object> input = Map.of(
                "firstName", "Jane",
                "lastName", "Smith", 
                "email", "jane.smith@example.com",
                "password", "securePassword123"
        );
        
        // When & Then
        webTestClient
                .post()
                .uri("/graphql")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(Map.of(
                        "query", mutation,
                        "variables", Map.of("input", input)
                ))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.data.createUser.success").isEqualTo(true)
                .jsonPath("$.data.createUser.user.firstName").isEqualTo("Jane")
                .jsonPath("$.data.createUser.user.email").isEqualTo("jane.smith@example.com")
                .jsonPath("$.data.createUser.errors").isEmpty()
                .jsonPath("$.errors").doesNotExist();
    }
    
    @Test
    void shouldReturnAuthenticationError_whenNoToken() {
        // Given
        String query = """
                query {
                    me {
                        id
                        email
                    }
                }
                """;
        
        // When & Then
        webTestClient
                .post()
                .uri("/graphql")
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(Map.of("query", query))
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.errors[0].extensions.errorCode").isEqualTo("AUTHENTICATION_ERROR")
                .jsonPath("$.data.me").doesNotExist();
    }
    
    private User createAndSaveTestUser() {
        User user = new User();
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setEmail("john.doe@example.com");
        user.setPasswordHash("hashedPassword");
        return userRepository.save(user);
    }
}
```

#### Kotlin Integration Tests
```kotlin
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(properties = [
    "spring.datasource.url=jdbc:h2:mem:testdb",
    "spring.jpa.hibernate.ddl-auto=create-drop"
])
@Testcontainers
class GraphQLIntegrationTest {
    
    companion object {
        @Container
        @JvmStatic
        val postgres: PostgreSQLContainer<*> = PostgreSQLContainer("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test")
    }
    
    @Autowired
    private lateinit var webTestClient: WebTestClient
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Autowired
    private lateinit var tokenProvider: JwtTokenProvider
    
    @Test
    fun `should execute user query`() {
        // Given
        val user = createAndSaveTestUser()
        val token = tokenProvider.generateToken(user.email)
        
        val query = """
            query GetUser(${'
    public CreateUserPayload createUser(@Argument CreateUserInput input) {
        try {
            validationService.validate(input);
            User user = userService.createUser(input);
            return CreateUserPayload.success(user);
        } catch (ValidationException e) {
            return CreateUserPayload.withErrors(e.getFieldErrors());
        }
    }
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional
    public UpdateUserPayload updateUser(
            @Argument UpdateUserInput input,
            DataFetchingEnvironment environment) {
        
        SecurityContext context = environment.getContext();
        
        try {
            validationService.validate(input);
            User user = userService.updateUser(input, context);
            return UpdateUserPayload.success(user);
        } catch (ValidationException e) {
            return UpdateUserPayload.withErrors(e.getFieldErrors());
        } catch (AuthorizationException e) {
            throw e; // Re-throw security exceptions
        }
    }
}
```

#### Kotlin Implementation
```kotlin
@Component
class UserMutationResolver(
    private val userService: UserService,
    private val validationService: ValidationService
) {
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional}id: ID!) {
                user(id: ${'
    public CreateUserPayload createUser(@Argument CreateUserInput input) {
        try {
            validationService.validate(input);
            User user = userService.createUser(input);
            return CreateUserPayload.success(user);
        } catch (ValidationException e) {
            return CreateUserPayload.withErrors(e.getFieldErrors());
        }
    }
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional
    public UpdateUserPayload updateUser(
            @Argument UpdateUserInput input,
            DataFetchingEnvironment environment) {
        
        SecurityContext context = environment.getContext();
        
        try {
            validationService.validate(input);
            User user = userService.updateUser(input, context);
            return UpdateUserPayload.success(user);
        } catch (ValidationException e) {
            return UpdateUserPayload.withErrors(e.getFieldErrors());
        } catch (AuthorizationException e) {
            throw e; // Re-throw security exceptions
        }
    }
}
```

#### Kotlin Implementation
```kotlin
@Component
class UserMutationResolver(
    private val userService: UserService,
    private val validationService: ValidationService
) {
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional}id) {
                    id
                    firstName
                    lastName
                    email
                    posts {
                        id
                        title
                    }
                }
            }
        """.trimIndent()
        
        // When & Then
        webTestClient
            .post()
            .uri("/graphql")
            .header("Authorization", "Bearer $token")
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(mapOf(
                "query" to query,
                "variables" to mapOf("id" to user.id.toString())
            ))
            .exchange()
            .expectStatus().isOk
            .expectBody()
            .jsonPath("$.data.user.id").isEqualTo(user.id.toString())
            .jsonPath("$.data.user.firstName").isEqualTo(user.firstName)
            .jsonPath("$.data.user.email").isEqualTo(user.email)
            .jsonPath("$.errors").doesNotExist()
    }
    
    @Test
    fun `should execute create user mutation`() {
        // Given
        val mutation = """
            mutation CreateUser(${'
    public CreateUserPayload createUser(@Argument CreateUserInput input) {
        try {
            validationService.validate(input);
            User user = userService.createUser(input);
            return CreateUserPayload.success(user);
        } catch (ValidationException e) {
            return CreateUserPayload.withErrors(e.getFieldErrors());
        }
    }
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional
    public UpdateUserPayload updateUser(
            @Argument UpdateUserInput input,
            DataFetchingEnvironment environment) {
        
        SecurityContext context = environment.getContext();
        
        try {
            validationService.validate(input);
            User user = userService.updateUser(input, context);
            return UpdateUserPayload.success(user);
        } catch (ValidationException e) {
            return UpdateUserPayload.withErrors(e.getFieldErrors());
        } catch (AuthorizationException e) {
            throw e; // Re-throw security exceptions
        }
    }
}
```

#### Kotlin Implementation
```kotlin
@Component
class UserMutationResolver(
    private val userService: UserService,
    private val validationService: ValidationService
) {
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional}input: CreateUserInput!) {
                createUser(input: ${'
    public CreateUserPayload createUser(@Argument CreateUserInput input) {
        try {
            validationService.validate(input);
            User user = userService.createUser(input);
            return CreateUserPayload.success(user);
        } catch (ValidationException e) {
            return CreateUserPayload.withErrors(e.getFieldErrors());
        }
    }
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional
    public UpdateUserPayload updateUser(
            @Argument UpdateUserInput input,
            DataFetchingEnvironment environment) {
        
        SecurityContext context = environment.getContext();
        
        try {
            validationService.validate(input);
            User user = userService.updateUser(input, context);
            return UpdateUserPayload.success(user);
        } catch (ValidationException e) {
            return UpdateUserPayload.withErrors(e.getFieldErrors());
        } catch (AuthorizationException e) {
            throw e; // Re-throw security exceptions
        }
    }
}
```

#### Kotlin Implementation
```kotlin
@Component
class UserMutationResolver(
    private val userService: UserService,
    private val validationService: ValidationService
) {
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional}input) {
                    user {
                        id
                        firstName
                        lastName
                        email
                    }
                    errors {
                        field
                        message
                        code
                    }
                    success
                }
            }
        """.trimIndent()
        
        val input = mapOf(
            "firstName" to "Jane",
            "lastName" to "Smith",
            "email" to "jane.smith@example.com",
            "password" to "securePassword123"
        )
        
        // When & Then
        webTestClient
            .post()
            .uri("/graphql")
            .contentType(MediaType.APPLICATION_JSON)
            .bodyValue(mapOf(
                "query" to mutation,
                "variables" to mapOf("input" to input)
            ))
            .exchange()
            .expectStatus().isOk
            .expectBody()
            .jsonPath("$.data.createUser.success").isEqualTo(true)
            .jsonPath("$.data.createUser.user.firstName").isEqualTo("Jane")
            .jsonPath("$.data.createUser.user.email").isEqualTo("jane.smith@example.com")
            .jsonPath("$.data.createUser.errors").isEmpty
            .jsonPath("$.errors").doesNotExist()
    }
    
    private fun createAndSaveTestUser(): User {
        val user = User(
            firstName = "John",
            lastName = "Doe",
            email = "john.doe@example.com",
            passwordHash = "hashedPassword"
        )
        return userRepository.save(user)
    }
}
```

### GraphQL-Specific Testing

#### Schema Testing
```java
@SpringBootTest
class GraphQLSchemaTest {
    
    @Autowired
    private GraphQLSchema schema;
    
    @Test
    void shouldHaveValidSchema() {
        assertThat(schema).isNotNull();
        assertThat(schema.getQueryType()).isNotNull();
        assertThat(schema.getMutationType()).isNotNull();
        assertThat(schema.getSubscriptionType()).isNotNull();
    }
    
    @Test
    void shouldHaveRequiredQueries() {
        GraphQLObjectType queryType = schema.getQueryType();
        
        assertThat(queryType.getFieldDefinition("me")).isNotNull();
        assertThat(queryType.getFieldDefinition("user")).isNotNull();
        assertThat(queryType.getFieldDefinition("users")).isNotNull();
        assertThat(queryType.getFieldDefinition("posts")).isNotNull();
    }
    
    @Test
    void shouldHaveRequiredMutations() {
        GraphQLObjectType mutationType = schema.getMutationType();
        
        assertThat(mutationType.getFieldDefinition("login")).isNotNull();
        assertThat(mutationType.getFieldDefinition("register")).isNotNull();
        assertThat(mutationType.getFieldDefinition("createUser")).isNotNull();
        assertThat(mutationType.getFieldDefinition("updateUser")).isNotNull();
    }
    
    @Test
    void shouldHaveRequiredSubscriptions() {
        GraphQLObjectType subscriptionType = schema.getSubscriptionType();
        
        assertThat(subscriptionType.getFieldDefinition("postCreated")).isNotNull();
        assertThat(subscriptionType.getFieldDefinition("commentAdded")).isNotNull();
    }
}
```

#### DataLoader Testing
```java
@ExtendWith(MockitoExtension.class)
class UserDataLoaderTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private CacheManager cacheManager;
    
    @Mock
    private Cache cache;
    
    @InjectMocks
    private UserDataLoader userDataLoader;
    
    @Test
    void shouldBatchLoadUsers() throws Exception {
        // Given
        Set<Long> userIds = Set.of(1L, 2L, 3L);
        List<User> users = createTestUsers(userIds);
        
        when(cacheManager.getCache("users")).thenReturn(cache);
        when(cache.get(any(Long.class), eq(User.class))).thenReturn(null);
        when(userRepository.findAllById(userIds)).thenReturn(users);
        
        DataLoader<Long, User> dataLoader = userDataLoader.createUserDataLoader();
        
        // When
        CompletableFuture<User> user1Future = dataLoader.load(1L);
        CompletableFuture<User> user2Future = dataLoader.load(2L);
        CompletableFuture<User> user3Future = dataLoader.load(3L);
        
        dataLoader.dispatch();
        
        // Then
        assertThat(user1Future.get().getId()).isEqualTo(1L);
        assertThat(user2Future.get().getId()).isEqualTo(2L);
        assertThat(user3Future.get().getId()).isEqualTo(3L);
        
        verify(userRepository, times(1)).findAllById(userIds);
    }
    
    private List<User> createTestUsers(Set<Long> ids) {
        return ids.stream()
                .map(id -> {
                    User user = new User();
                    user.setId(id);
                    user.setEmail("user" + id + "@example.com");
                    return user;
                })
                .collect(Collectors.toList());
    }
}
```

---

## Validation Checklist

### ✅ Project Structure Compliance
- [ ] Proper directory structure with `graphql/` folder organization
- [ ] Schema files in `resources/graphql/` with appropriate organization
- [ ] Resolvers organized by operation type (query/mutation/subscription/field)
- [ ] DataLoaders in dedicated package
- [ ] Security components properly structured
- [ ] Exception handling centralized

### ✅ Naming Convention Compliance
- [ ] GraphQL types in PascalCase (User, Post, CreateUserInput)
- [ ] GraphQL fields in camelCase (firstName, createdAt, isActive)
- [ ] Java/Kotlin classes follow naming conventions
- [ ] Resolvers have clear suffixes (UserQueryResolver, PostMutationResolver)
- [ ] Services and repositories properly named
- [ ] Package names are descriptive and lowercase

### ✅ Schema Design Compliance
- [ ] Schema-first approach with .graphqls files
- [ ] Proper use of nullable vs non-nullable types
- [ ] Unions and interfaces used appropriately
- [ ] Relay-style pagination implemented
- [ ] Input types have Input suffix
- [ ] Payload types for mutations with error handling

### ✅ Library Usage Compliance
- [ ] Spring Boot GraphQL starter used
- [ ] DataLoader library included for N+1 prevention
- [ ] Proper security dependencies configured
- [ ] Testing dependencies included (spring-graphql-test)
- [ ] Kotlin-specific dependencies for Kotlin projects

### ✅ Error Handling Compliance
- [ ] Custom GraphQL exceptions defined
- [ ] Global exception handler implemented
- [ ] Payload types include error handling
- [ ] Proper error codes and extensions
- [ ] Security exceptions handled appropriately

### ✅ Security Compliance
- [ ] Authentication and authorization implemented
- [ ] Custom directives for security (@auth, @hasRole, @hasPermission)
- [ ] JWT token handling configured
- [ ] Query complexity analysis implemented
- [ ] Rate limiting configured
- [ ] Input validation implemented

### ✅ Performance Compliance
- [ ] DataLoaders implemented for all N+1 scenarios
- [ ] Caching strategy implemented
- [ ] Query complexity limits configured
- [ ] Depth limiting implemented
- [ ] Connection pooling configured
- [ ] Lazy loading where appropriate

### ✅ Testing Compliance
- [ ] Unit tests for all resolvers
- [ ] Integration tests with real GraphQL execution
- [ ] DataLoader testing implemented
- [ ] Schema validation tests
- [ ] Security testing included
- [ ] Performance testing for complex queries

### ✅ Null Handling Compliance
- [ ] Optional used for nullable returns in Java
- [ ] Kotlin null safety leveraged appropriately
- [ ] GraphQL schema nullability clearly defined
- [ ] Collections never return null
- [ ] Proper handling of missing data

---

## Reference URLs for Claude Code

### Official Documentation
- **Spring GraphQL**: https://docs.spring.io/spring-graphql/docs/current/reference/html/
- **GraphQL Java**: https://www.graphql-java.com/documentation/
- **Spring Boot**: https://docs.spring.io/spring-boot/docs/current/reference/html/
- **Spring Security**: https://docs.spring.io/spring-security/reference/

### GraphQL Specifications
- **GraphQL Specification**: https://spec.graphql.org/
- **Relay Specification**: https://relay.dev/graphql/
- **GraphQL Best Practices**: https://graphql.org/learn/best-practices/

### Java/Kotlin Resources
- **Kotlin Language**: https://kotlinlang.org/docs/home.html
- **Kotlin Coroutines**: https://kotlinlang.org/docs/coroutines-overview.html
- **Jackson Kotlin Module**: https://github.com/FasterXML/jackson-module-kotlin

### Testing Resources
- **Spring GraphQL Test**: https://docs.spring.io/spring-graphql/docs/current/reference/html/#testing
- **Testcontainers**: https://www.testcontainers.org/
- **MockK**: https://mockk.io/
- **AssertJ**: https://assertj.github.io/doc/

### Security Resources
- **JWT**: https://jwt.io/
- **Spring Security GraphQL**: https://docs.spring.io/spring-security/reference/graphql.html
- **OWASP GraphQL Security**: https://cheatsheetseries.owasp.org/cheatsheets/GraphQL_Cheat_Sheet.html

### Performance Resources
- **DataLoader**: https://github.com/graphql-java/java-dataloader
- **GraphQL Query Complexity**: https://github.com/4finance/graphql-query-complexity-analysis
- **Spring Cache**: https://docs.spring.io/spring-framework/docs/current/reference/html/integration.html#cache

---

**Note**: This comprehensive document serves as the authoritative guide for GraphQL development with Spring Boot using both Java and Kotlin. It should be referenced for all GraphQL projects to ensure consistent implementation and adherence to best practices. The validation checklist can be used by Claude Code for automated project analysis and compliance verification.
    public CreateUserPayload createUser(@Argument CreateUserInput input) {
        try {
            validationService.validate(input);
            User user = userService.createUser(input);
            return CreateUserPayload.success(user);
        } catch (ValidationException e) {
            return CreateUserPayload.withErrors(e.getFieldErrors());
        }
    }
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional
    public UpdateUserPayload updateUser(
            @Argument UpdateUserInput input,
            DataFetchingEnvironment environment) {
        
        SecurityContext context = environment.getContext();
        
        try {
            validationService.validate(input);
            User user = userService.updateUser(input, context);
            return UpdateUserPayload.success(user);
        } catch (ValidationException e) {
            return UpdateUserPayload.withErrors(e.getFieldErrors());
        } catch (AuthorizationException e) {
            throw e; // Re-throw security exceptions
        }
    }
}
```

#### Kotlin Implementation
```kotlin
@Component
class UserMutationResolver(
    private val userService: UserService,
    private val validationService: ValidationService
) {
    
    @SchemaMapping(typeName = "Mutation")
    @Transactional