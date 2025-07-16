# Entity Usage Pattern Refactoring

## Purpose
Identify how entities are used in services, repositories, and controllers to suggest better separation of concerns and usage patterns.

## Usage Pattern Analysis

### CRITICAL Issues

#### 1. Entity Exposed in Controller Return Types
**Pattern**: Controllers returning entity objects directly
```java
// SMELL: Entity exposure in controller
@RestController
public class UserController {
    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id); // Returns entity
    }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Replace entity with DTO in controller
// Fix: Create UserDTO and use mapping service
// Reason: Prevents entity exposure and uncontrolled serialization
```

#### 2. Entity Used as Request Body
**Pattern**: Controllers accepting entity objects as input
```java
// SMELL: Entity as request body
@RestController
public class UserController {
    @PostMapping("/users")
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Replace entity with DTO in request body
// Fix: Create CreateUserRequest DTO and map to entity
// Reason: Prevents client control over entity fields and validation bypass
```

#### 3. Entity Construction in Controller
**Pattern**: Controllers creating entity instances
```java
// SMELL: Entity construction in controller
@RestController
public class UserController {
    @PostMapping("/users")
    public ResponseEntity<User> createUser(@RequestBody CreateUserRequest request) {
        User user = new User(request.getName(), request.getEmail());
        return ResponseEntity.ok(userService.save(user));
    }
}
```
**TODO Template**:
```java
// TODO: [CRITICAL] Move entity construction to service layer
// Fix: Pass DTO to service, construct entity in service
// Reason: Controllers should only handle HTTP concerns
```

### HIGH Priority Issues

#### 4. Entity Passed Between Services
**Pattern**: Services passing entities to other services
```java
// SMELL: Entity passed between services
@Service
public class UserService {
    public void processUser(User user) {
        emailService.sendWelcomeEmail(user); // Passing entity
        auditService.logUserCreation(user);
    }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Use DTOs for service-to-service communication
// Fix: Create UserEvent DTO for service communication
// Reason: Reduces coupling and prevents unintended entity modifications
```

#### 5. Repository Methods Returning Entity Collections
**Pattern**: Large entity collections returned without pagination
```java
// SMELL: Unbounded entity collections
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByStatus(String status); // Could return millions
}
```
**TODO Template**:
```java
// TODO: [HIGH] Add pagination to large collection queries
// Fix: Use Page<User> findByStatus(String status, Pageable pageable)
// Reason: Prevents memory issues and improves performance
```

#### 6. Entity Modification in Multiple Services
**Pattern**: Multiple services modifying the same entity
```java
// SMELL: Multiple services modifying entity
@Service
public class UserService {
    public void updateProfile(User user) { /* modify user */ }
}

@Service
public class EmailService {
    public void updateEmailSettings(User user) { /* modify user */ }
}
```
**TODO Template**:
```java
// TODO: [HIGH] Centralize entity modifications in single service
// Fix: Create UserManagementService as single modification point
// Reason: Prevents conflicting modifications and ensures consistency
```

### MEDIUM Priority Issues

#### 7. Entity Validation in Multiple Layers
**Pattern**: Same validation logic in controller and service
```java
// SMELL: Duplicate validation
@RestController
public class UserController {
    @PostMapping("/users")
    public User createUser(@Valid @RequestBody User user) {
        if (user.getName() == null) throw new ValidationException();
        return userService.save(user);
    }
}

@Service
public class UserService {
    public User save(User user) {
        if (user.getName() == null) throw new ValidationException();
        return userRepository.save(user);
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Consolidate validation in single layer
// Fix: Use JSR-303 annotations on entity, validate in service layer only
// Reason: Eliminates duplicate validation code and ensures consistency
```

#### 8. Entity Querying in Service Methods
**Pattern**: Services containing query logic
```java
// SMELL: Query logic in service
@Service
public class UserService {
    public List<User> findActiveUsers() {
        return userRepository.findAll().stream()
            .filter(user -> user.isActive())
            .collect(Collectors.toList());
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Move query logic to repository layer
// Fix: Create custom repository method findByActiveTrue()
// Reason: Separates query concerns and improves performance
```

#### 9. Entity Conversion Logic in Controller
**Pattern**: DTO mapping logic in controller methods
```java
// SMELL: Mapping logic in controller
@RestController
public class UserController {
    @GetMapping("/users/{id}")
    public UserDTO getUser(@PathVariable Long id) {
        User user = userService.findById(id);
        UserDTO dto = new UserDTO();
        dto.setName(user.getName());
        dto.setEmail(user.getEmail());
        return dto;
    }
}
```
**TODO Template**:
```java
// TODO: [MEDIUM] Extract mapping logic to dedicated mapper
// Fix: Create UserMapper service or use MapStruct
// Reason: Reduces controller complexity and improves reusability
```

### LOW Priority Issues

#### 10. Entity Caching Without Strategy
**Pattern**: Entity caching without clear invalidation strategy
```java
// SMELL: Unclear caching strategy
@Service
public class UserService {
    @Cacheable("users")
    public User findById(Long id) {
        return userRepository.findById(id).orElse(null);
    }
    
    public User save(User user) {
        return userRepository.save(user); // No cache invalidation
    }
}
```
**TODO Template**:
```java
// TODO: [LOW] Add cache invalidation strategy
// Fix: Use @CacheEvict on save/update methods
// Reason: Prevents stale data in cache
```

## Usage Pattern Best Practices

### Controller Layer Patterns
```java
// GOOD: DTO-based controller
@RestController
public class UserController {
    @PostMapping("/users")
    public ResponseEntity<UserResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        UserResponse response = userService.createUser(request);
        return ResponseEntity.ok(response);
    }
}
```

### Service Layer Patterns
```java
// GOOD: Service with DTO handling
@Service
@Transactional(readOnly = true)
public class UserService {
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        User user = userMapper.toEntity(request);
        user = userRepository.save(user);
        return userMapper.toResponse(user);
    }
}
```

### Repository Layer Patterns
```java
// GOOD: Repository with specific queries
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Page<User> findByActiveTrue(Pageable pageable);
    Optional<User> findByEmail(String email);
    
    @Query("SELECT u FROM User u WHERE u.createdAt > :date")
    List<User> findRecentUsers(@Param("date") LocalDateTime date);
}
```

### Mapping Strategy
```java
// GOOD: Dedicated mapper
@Component
public class UserMapper {
    public User toEntity(CreateUserRequest request) {
        return User.builder()
            .name(request.getName())
            .email(request.getEmail())
            .build();
    }
    
    public UserResponse toResponse(User user) {
        return UserResponse.builder()
            .id(user.getId())
            .name(user.getName())
            .email(user.getEmail())
            .build();
    }
}
```

## Detection Patterns for Claude Code

### Controller Layer Checks
- Entity types in `@RequestBody` parameters
- Entity types in method return types
- Entity construction in controller methods
- Entity modification in controller methods

### Service Layer Checks
- Services passing entities to other services
- Multiple services modifying same entity
- Query logic in service methods
- Entity conversion logic in service methods

### Repository Layer Checks
- Methods returning large collections without pagination
- Complex query logic in service instead of repository
- Missing specific query methods

### Cross-Layer Checks
- Same validation logic in multiple layers
- Entity exposure across layer boundaries
- Inconsistent error handling patterns
- Missing transaction boundaries

## Refactoring Strategies

### Layer Responsibility Matrix
| Layer | Responsibility | Entity Usage |
|-------|---------------|--------------|
| Controller | HTTP handling | DTOs only |
| Service | Business logic | Entity manipulation |
| Repository | Data access | Entity queries |
| Mapper | Data transformation | Entity ↔ DTO |

### Communication Patterns
- **Controller → Service**: DTOs
- **Service → Repository**: Entity IDs or simple parameters
- **Service → Service**: Event objects or DTOs
- **Repository → Service**: Entities or projections