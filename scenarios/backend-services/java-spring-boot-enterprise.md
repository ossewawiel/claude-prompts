# Java Spring Boot Enterprise - Claude Code Instructions

## CONTEXT
- **Project Type**: scenario
- **Complexity**: advanced
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Framework**: Spring Boot 3.2+
- **Language**: Java 17+
- **Database**: PostgreSQL/MariaDB with JPA/Hibernate
- **Security**: Spring Security with JWT
- **Build Tool**: Gradle with Kotlin DSL
- **Testing**: JUnit 5, Mockito, TestContainers
- **Documentation**: OpenAPI/Swagger
- **Monitoring**: Actuator, Micrometer

### Enterprise Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Controller    │ ─→ │     Service     │ ─→ │   Repository    │
│   - REST API    │    │ - Business Logic│    │ - Data Access   │
│   - Validation  │    │ - Transactions  │    │ - JPA Entities  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      DTOs       │    │   Domain Model  │    │    Database     │
│ - Request/Resp  │    │ - Business Obj  │    │ - PostgreSQL    │
│ - Validation    │    │ - Value Objects │    │ - Migrations    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## IMPLEMENTATION STRATEGY

### 1. Project Structure
```
src/
├── main/
│   ├── java/com/company/app/
│   │   ├── Application.java          # Main application class
│   │   ├── config/                   # Configuration classes
│   │   │   ├── SecurityConfig.java
│   │   │   ├── DatabaseConfig.java
│   │   │   └── OpenApiConfig.java
│   │   ├── controller/               # REST controllers
│   │   ├── service/                  # Business logic
│   │   │   ├── impl/                # Service implementations
│   │   │   └── dto/                 # Data Transfer Objects
│   │   ├── repository/               # Data access layer
│   │   ├── entity/                   # JPA entities
│   │   ├── exception/                # Custom exceptions
│   │   └── util/                     # Utility classes
│   └── resources/
│       ├── application.yml           # Configuration
│       ├── application-dev.yml       # Development config
│       ├── application-prod.yml      # Production config
│       └── db/migration/             # Flyway migrations
└── test/                             # Test classes
```

### 2. Main Application Class
**Application**: `src/main/java/com/company/app/Application.java`
```java
@SpringBootApplication
@EnableJpaRepositories
@EnableScheduling
@EnableCaching
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

### 3. Entity Layer
**Base Entity**: `src/main/java/com/company/app/entity/BaseEntity.java`
```java
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @Version
    private Integer version;
    
    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public Integer getVersion() { return version; }
    public void setVersion(Integer version) { this.version = version; }
}
```

**User Entity**: `src/main/java/com/company/app/entity/User.java`
```java
@Entity
@Table(name = "users")
public class User extends BaseEntity {
    
    @Column(name = "username", unique = true, nullable = false)
    private String username;
    
    @Column(name = "email", unique = true, nullable = false)
    private String email;
    
    @Column(name = "password", nullable = false)
    private String password;
    
    @Column(name = "first_name")
    private String firstName;
    
    @Column(name = "last_name")
    private String lastName;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private UserStatus status = UserStatus.ACTIVE;
    
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "user_roles",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles = new HashSet<>();
    
    // Constructors
    public User() {}
    
    public User(String username, String email, String password) {
        this.username = username;
        this.email = email;
        this.password = password;
    }
    
    // Getters and setters
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public UserStatus getStatus() { return status; }
    public void setStatus(UserStatus status) { this.status = status; }
    
    public Set<Role> getRoles() { return roles; }
    public void setRoles(Set<Role> roles) { this.roles = roles; }
}

enum UserStatus {
    ACTIVE, INACTIVE, SUSPENDED
}
```

### 4. Repository Layer
**User Repository**: `src/main/java/com/company/app/repository/UserRepository.java`
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long>, JpaSpecificationExecutor<User> {
    
    Optional<User> findByUsername(String username);
    
    Optional<User> findByEmail(String email);
    
    boolean existsByUsername(String username);
    
    boolean existsByEmail(String email);
    
    @Query("SELECT u FROM User u WHERE u.status = :status")
    Page<User> findByStatus(@Param("status") UserStatus status, Pageable pageable);
    
    @Modifying
    @Query("UPDATE User u SET u.status = :status WHERE u.id = :id")
    int updateUserStatus(@Param("id") Long id, @Param("status") UserStatus status);
}
```

### 5. DTO Layer
**User DTO**: `src/main/java/com/company/app/service/dto/UserDto.java`
```java
public class UserDto {
    private Long id;
    
    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;
    
    @Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters")
    private String firstName;
    
    @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
    private String lastName;
    
    private UserStatus status;
    private Set<String> roles;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Constructors
    public UserDto() {}
    
    public UserDto(User user) {
        this.id = user.getId();
        this.username = user.getUsername();
        this.email = user.getEmail();
        this.firstName = user.getFirstName();
        this.lastName = user.getLastName();
        this.status = user.getStatus();
        this.roles = user.getRoles().stream()
            .map(Role::getName)
            .collect(Collectors.toSet());
        this.createdAt = user.getCreatedAt();
        this.updatedAt = user.getUpdatedAt();
    }
    
    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public UserStatus getStatus() { return status; }
    public void setStatus(UserStatus status) { this.status = status; }
    
    public Set<String> getRoles() { return roles; }
    public void setRoles(Set<String> roles) { this.roles = roles; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
```

### 6. Service Layer
**User Service Interface**: `src/main/java/com/company/app/service/UserService.java`
```java
public interface UserService {
    Page<UserDto> getAllUsers(Pageable pageable);
    UserDto getUserById(Long id);
    UserDto getUserByUsername(String username);
    UserDto createUser(CreateUserRequest request);
    UserDto updateUser(Long id, UpdateUserRequest request);
    void deleteUser(Long id);
    void updateUserStatus(Long id, UserStatus status);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
```

**User Service Implementation**: `src/main/java/com/company/app/service/impl/UserServiceImpl.java`
```java
@Service
@Transactional
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final Logger logger = LoggerFactory.getLogger(UserServiceImpl.class);
    
    public UserServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }
    
    @Override
    @Transactional(readOnly = true)
    public Page<UserDto> getAllUsers(Pageable pageable) {
        logger.debug("Getting all users with pagination: {}", pageable);
        return userRepository.findAll(pageable)
            .map(UserDto::new);
    }
    
    @Override
    @Transactional(readOnly = true)
    public UserDto getUserById(Long id) {
        logger.debug("Getting user by id: {}", id);
        User user = userRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("User not found with id: " + id));
        return new UserDto(user);
    }
    
    @Override
    @Transactional(readOnly = true)
    public UserDto getUserByUsername(String username) {
        logger.debug("Getting user by username: {}", username);
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new EntityNotFoundException("User not found with username: " + username));
        return new UserDto(user);
    }
    
    @Override
    public UserDto createUser(CreateUserRequest request) {
        logger.debug("Creating new user: {}", request.getUsername());
        
        if (existsByUsername(request.getUsername())) {
            throw new BusinessException("Username already exists: " + request.getUsername());
        }
        
        if (existsByEmail(request.getEmail())) {
            throw new BusinessException("Email already exists: " + request.getEmail());
        }
        
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        
        User savedUser = userRepository.save(user);
        logger.info("Created user with id: {}", savedUser.getId());
        
        return new UserDto(savedUser);
    }
    
    @Override
    public UserDto updateUser(Long id, UpdateUserRequest request) {
        logger.debug("Updating user: {}", id);
        
        User user = userRepository.findById(id)
            .orElseThrow(() -> new EntityNotFoundException("User not found with id: " + id));
        
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail());
        
        User updatedUser = userRepository.save(user);
        logger.info("Updated user with id: {}", updatedUser.getId());
        
        return new UserDto(updatedUser);
    }
    
    @Override
    public void deleteUser(Long id) {
        logger.debug("Deleting user: {}", id);
        
        if (!userRepository.existsById(id)) {
            throw new EntityNotFoundException("User not found with id: " + id);
        }
        
        userRepository.deleteById(id);
        logger.info("Deleted user with id: {}", id);
    }
    
    @Override
    public void updateUserStatus(Long id, UserStatus status) {
        logger.debug("Updating user status: {} to {}", id, status);
        
        int updated = userRepository.updateUserStatus(id, status);
        if (updated == 0) {
            throw new EntityNotFoundException("User not found with id: " + id);
        }
        
        logger.info("Updated user status: {} to {}", id, status);
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }
}
```

### 7. Controller Layer
**User Controller**: `src/main/java/com/company/app/controller/UserController.java`
```java
@RestController
@RequestMapping("/api/users")
@Validated
@Tag(name = "User Management", description = "Operations for managing users")
public class UserController {
    
    private final UserService userService;
    private final Logger logger = LoggerFactory.getLogger(UserController.class);
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    @GetMapping
    @Operation(summary = "Get all users", description = "Retrieve a paginated list of all users")
    public ResponseEntity<ApiResponse<Page<UserDto>>> getAllUsers(
        @RequestParam(defaultValue = "0") @Min(0) int page,
        @RequestParam(defaultValue = "10") @Min(1) @Max(100) int size,
        @RequestParam(defaultValue = "id") String sortBy,
        @RequestParam(defaultValue = "asc") String sortDir
    ) {
        logger.debug("Getting all users - page: {}, size: {}", page, size);
        
        Sort sort = sortDir.equalsIgnoreCase("desc") 
            ? Sort.by(sortBy).descending() 
            : Sort.by(sortBy).ascending();
        
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<UserDto> users = userService.getAllUsers(pageable);
        
        return ResponseEntity.ok(ApiResponse.success(users));
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID", description = "Retrieve a specific user by their ID")
    public ResponseEntity<ApiResponse<UserDto>> getUserById(
        @PathVariable @Min(1) Long id
    ) {
        logger.debug("Getting user by id: {}", id);
        UserDto user = userService.getUserById(id);
        return ResponseEntity.ok(ApiResponse.success(user));
    }
    
    @PostMapping
    @Operation(summary = "Create user", description = "Create a new user")
    public ResponseEntity<ApiResponse<UserDto>> createUser(
        @Valid @RequestBody CreateUserRequest request
    ) {
        logger.debug("Creating user: {}", request.getUsername());
        UserDto user = userService.createUser(request);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.success(user, "User created successfully"));
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update user", description = "Update an existing user")
    public ResponseEntity<ApiResponse<UserDto>> updateUser(
        @PathVariable @Min(1) Long id,
        @Valid @RequestBody UpdateUserRequest request
    ) {
        logger.debug("Updating user: {}", id);
        UserDto user = userService.updateUser(id, request);
        return ResponseEntity.ok(ApiResponse.success(user, "User updated successfully"));
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete user", description = "Delete a user by ID")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable @Min(1) Long id) {
        logger.debug("Deleting user: {}", id);
        userService.deleteUser(id);
        return ResponseEntity.ok(ApiResponse.success(null, "User deleted successfully"));
    }
    
    @PatchMapping("/{id}/status")
    @Operation(summary = "Update user status", description = "Update the status of a user")
    public ResponseEntity<ApiResponse<Void>> updateUserStatus(
        @PathVariable @Min(1) Long id,
        @Valid @RequestBody UpdateUserStatusRequest request
    ) {
        logger.debug("Updating user status: {} to {}", id, request.getStatus());
        userService.updateUserStatus(id, request.getStatus());
        return ResponseEntity.ok(ApiResponse.success(null, "User status updated successfully"));
    }
}
```

### 8. Configuration
**Database Configuration**: `src/main/java/com/company/app/config/DatabaseConfig.java`
```java
@Configuration
@EnableJpaAuditing
public class DatabaseConfig {
    
    @Bean
    public AuditorAware<String> auditorProvider() {
        return () -> {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication == null || !authentication.isAuthenticated()) {
                return Optional.of("system");
            }
            return Optional.of(authentication.getName());
        };
    }
}
```

## CLAUDE_CODE_COMMANDS

### Build Commands
```bash
# Build application
./gradlew build

# Run application
./gradlew bootRun

# Run tests
./gradlew test

# Generate test report
./gradlew test jacocoTestReport
```

### Database Commands
```bash
# Run migrations
./gradlew flywayMigrate

# Clean database
./gradlew flywayClean

# Generate migration
./gradlew flywayInfo
```

### Code Quality
```bash
# Run checkstyle
./gradlew checkstyleMain

# Run spotbugs
./gradlew spotbugsMain

# Run all quality checks
./gradlew check
```

## VALIDATION_CHECKLIST
- [ ] Entity relationships properly configured with JPA
- [ ] Service layer implements proper transaction management
- [ ] Repository layer uses Spring Data JPA specifications
- [ ] DTO validation with Bean Validation annotations
- [ ] Controller layer implements proper REST conventions
- [ ] Exception handling with global exception handler
- [ ] Audit fields automatically populated
- [ ] Database migrations properly versioned
- [ ] Unit tests cover service and repository layers
- [ ] Integration tests verify API endpoints