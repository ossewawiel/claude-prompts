# JPA Repository Code Review Guide
## Java 11 Spring Boot 2.7 - Comprehensive Reference for Claude Code

---

## 📋 QUICK REFERENCE CHECKLIST

### Critical Issues (Fix Immediately)
- [ ] Missing `@Repository` annotation or proper interface extension
- [ ] Business logic in repository layer
- [ ] SQL injection vulnerabilities in native queries
- [ ] Missing `@Transactional` on modifying operations
- [ ] Exposed mutable collections without defensive copying
- [ ] N+1 query problems in relationships

### High Priority Issues
- [ ] Missing pagination for large result sets
- [ ] Inefficient fetch strategies (unnecessary EAGER loading)
- [ ] Missing error handling for data access exceptions
- [ ] Custom queries without proper parameter validation
- [ ] Missing indexes on frequently queried columns

### Medium Priority Issues
- [ ] Inconsistent naming conventions
- [ ] Missing documentation for custom queries
- [ ] Lack of batch operation optimization
- [ ] Missing audit logging for sensitive operations

---

## 🏗️ REPOSITORY STRUCTURE & DESIGN

### Base Repository Interface
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long>, 
                                       JpaSpecificationExecutor<User> {
    // Derived query methods
    Optional<User> findByEmail(String email);
    
    // Custom JPQL queries
    @Query("SELECT u FROM User u WHERE u.status = :status")
    Page<User> findActiveUsers(@Param("status") UserStatus status, Pageable pageable);
    
    // Native queries (use sparingly)
    @Query(value = "SELECT * FROM users WHERE created_at > :date", nativeQuery = true)
    List<User> findRecentUsersNative(@Param("date") LocalDateTime date);
}
```

### Repository Design Principles
- **Single Responsibility**: Keep repositories focused on data access only
- **Interface Segregation**: Extend appropriate base interfaces (`CrudRepository`, `JpaRepository`, `PagingAndSortingRepository`)
- **Explicit Over Implicit**: Always specify fetch types, cascade types, and transaction boundaries
- **Performance First**: Consider query impact and use appropriate pagination

---

## 🔍 QUERY METHODS & NAMING

### Derived Query Method Conventions
```java
// ✅ Good - Clear, follows Spring Data conventions
Optional<User> findByEmailAndStatus(String email, UserStatus status);
List<User> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
Page<User> findByDepartmentNameContainingIgnoreCase(String name, Pageable pageable);

// ❌ Avoid - Overly complex derived queries
List<User> findByDepartmentNameAndStatusAndCreatedAtBetweenAndEmailContaining(
    String deptName, UserStatus status, LocalDateTime start, LocalDateTime end, String email);
```

### Custom JPQL Queries
```java
// ✅ Preferred - Clear JPQL with named parameters
@Query("SELECT u FROM User u JOIN FETCH u.roles WHERE u.department.id = :deptId")
List<User> findUsersWithRolesByDepartment(@Param("deptId") Long departmentId);

// ✅ DTO Projections for performance
@Query("SELECT new com.example.dto.UserSummaryDTO(u.id, u.name, u.email) " +
       "FROM User u WHERE u.status = :status")
List<UserSummaryDTO> findUserSummaries(@Param("status") UserStatus status);
```

### Native SQL Guidelines
```java
// ⚠️ Use only when JPQL is insufficient
@Query(value = """
    SELECT u.* FROM users u 
    WHERE u.created_at > :since 
    AND EXISTS (
        SELECT 1 FROM user_activity ua 
        WHERE ua.user_id = u.id 
        AND ua.activity_date = CURRENT_DATE
    )
    """, nativeQuery = true)
List<User> findActiveUsersToday(@Param("since") LocalDateTime since);
```

---

## 🔄 TRANSACTION MANAGEMENT

### Transaction Boundaries
```java
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    // ✅ Read-only for query optimization
    @Transactional(readOnly = true)
    @Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.customerId = :customerId")
    List<Order> findOrdersWithItems(@Param("customerId") Long customerId);
    
    // ✅ Required for modifying operations
    @Modifying
    @Transactional
    @Query("UPDATE Order o SET o.status = :status WHERE o.id = :id")
    int updateOrderStatus(@Param("id") Long id, @Param("status") OrderStatus status);
    
    // ✅ Bulk operations with explicit flushing
    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Transactional
    @Query("DELETE FROM OrderItem oi WHERE oi.order.id = :orderId")
    void deleteOrderItems(@Param("orderId") Long orderId);
}
```

### Transaction Best Practices
- **Use `@Transactional(readOnly = true)`** for query methods to optimize performance
- **Always annotate modifying operations** with `@Modifying` and `@Transactional`
- **Consider transaction propagation** for complex operations
- **Handle transaction rollback** scenarios appropriately

---

## 📊 PAGINATION & SORTING

### Pagination Implementation
```java
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    // ✅ Page for total count needed (admin interfaces)
    Page<Product> findByCategory(String category, Pageable pageable);
    
    // ✅ Slice for infinite scroll (no count query)
    Slice<Product> findByCategoryOrderByCreatedAtDesc(String category, Pageable pageable);
    
    // ✅ Custom pagination with complex queries
    @Query("SELECT p FROM Product p WHERE p.price BETWEEN :minPrice AND :maxPrice")
    Page<Product> findByPriceRange(@Param("minPrice") BigDecimal min, 
                                   @Param("maxPrice") BigDecimal max, 
                                   Pageable pageable);
}
```

### Constructing Pageable Objects
```java
// ✅ Basic pagination
Pageable pageable = PageRequest.of(0, 20);

// ✅ With sorting
Pageable pageableWithSort = PageRequest.of(0, 20, 
    Sort.by("createdAt").descending().and(Sort.by("name")));

// ✅ Type-safe sorting with meta-model
Pageable typeSafePageable = PageRequest.of(0, 20, 
    Sort.by(User_.CREATED_AT).descending());
```

### Pagination Best Practices
- **Default to reasonable page sizes** (10-50 items)
- **Cap maximum page size** to prevent abuse (max 100-500)
- **Always provide stable sorting** for consistent results
- **Use indexed columns for sorting** to maintain performance
- **Return appropriate metadata** for UI pagination controls

---

## 🎯 DYNAMIC QUERIES WITH SPECIFICATIONS

### Specification Pattern Implementation
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long>, 
                                       JpaSpecificationExecutor<User> {
    
    // Specifications allow dynamic query building
    default Page<User> findUsersWithCriteria(UserSearchCriteria criteria, Pageable pageable) {
        Specification<User> spec = Specification.where(null);
        
        if (criteria.getName() != null) {
            spec = spec.and(UserSpecifications.hasNameContaining(criteria.getName()));
        }
        if (criteria.getStatus() != null) {
            spec = spec.and(UserSpecifications.hasStatus(criteria.getStatus()));
        }
        if (criteria.getDepartmentId() != null) {
            spec = spec.and(UserSpecifications.belongsToDepartment(criteria.getDepartmentId()));
        }
        
        return findAll(spec, pageable);
    }
}

// Separate specification class for reusability
public class UserSpecifications {
    
    public static Specification<User> hasNameContaining(String name) {
        return (root, query, criteriaBuilder) -> 
            criteriaBuilder.like(
                criteriaBuilder.lower(root.get("name")), 
                "%" + name.toLowerCase() + "%"
            );
    }
    
    public static Specification<User> hasStatus(UserStatus status) {
        return (root, query, criteriaBuilder) -> 
            criteriaBuilder.equal(root.get("status"), status);
    }
    
    public static Specification<User> belongsToDepartment(Long departmentId) {
        return (root, query, criteriaBuilder) -> 
            criteriaBuilder.equal(root.get("department").get("id"), departmentId);
    }
}
```

---

## ⚡ PERFORMANCE OPTIMIZATION

### Fetch Strategy Optimization
```java
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    // ✅ Entity Graph for selective eager loading
    @EntityGraph(attributePaths = {"items", "customer"})
    @Query("SELECT o FROM Order o WHERE o.status = :status")
    List<Order> findOrdersWithItemsAndCustomer(@Param("status") OrderStatus status);
    
    // ✅ Multiple entity graphs for different use cases
    @EntityGraph(attributePaths = {"items.product"})
    Optional<Order> findWithItemsAndProducts(Long id);
    
    // ✅ DTO projection for read-only data
    @Query("SELECT new com.example.dto.OrderSummaryDTO(o.id, o.totalAmount, c.name) " +
           "FROM Order o JOIN o.customer c WHERE o.createdAt > :since")
    List<OrderSummaryDTO> findOrderSummariesSince(@Param("since") LocalDateTime since);
}
```

### Batch Operations
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // ✅ Batch updates for better performance
    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.lastLoginAt = :loginTime WHERE u.id IN :userIds")
    int updateLastLoginBatch(@Param("userIds") List<Long> userIds, 
                           @Param("loginTime") LocalDateTime loginTime);
    
    // ✅ Batch inserts with saveAll()
    default List<User> createUsersBatch(List<User> users) {
        return saveAll(users); // Optimized for batch operations
    }
}
```

### Query Optimization Guidelines
- **Avoid N+1 queries** - Use `@EntityGraph`, `JOIN FETCH`, or DTO projections
- **Index frequently queried columns** - Work with DBAs for proper indexing
- **Use batch operations** for bulk inserts/updates
- **Profile queries** with SQL logging and performance monitoring
- **Consider read replicas** for heavy read workloads

---

## 🔒 SECURITY & ERROR HANDLING

### SQL Injection Prevention
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // ✅ Safe - Uses parameterized queries
    @Query("SELECT u FROM User u WHERE u.email = :email")
    Optional<User> findByEmailSafe(@Param("email") String email);
    
    // ❌ Dangerous - String concatenation
    @Query("SELECT u FROM User u WHERE u.email = '" + "#{#email}" + "'")
    Optional<User> findByEmailUnsafe(@Param("email") String email);
    
    // ✅ Safe native query with parameters
    @Query(value = "SELECT * FROM users WHERE department_id = :deptId", nativeQuery = true)
    List<User> findByDepartmentNative(@Param("deptId") Long departmentId);
}
```

### Error Handling Patterns
```java
@Service
@Transactional
public class UserService {
    
    private final UserRepository userRepository;
    
    public User findUserSecurely(Long userId) {
        try {
            return userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
        } catch (DataAccessException e) {
            log.error("Database error while fetching user: {}", userId, e);
            throw new ServiceException("Unable to retrieve user data", e);
        }
    }
    
    public void updateUserWithOptimisticLocking(User user) {
        try {
            userRepository.save(user);
        } catch (OptimisticLockingFailureException e) {
            throw new ConcurrentModificationException("User was modified by another process");
        } catch (DataIntegrityViolationException e) {
            throw new BusinessException("User data violates business constraints");
        }
    }
}
```

### Input Validation
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // ✅ Validate parameters in service layer
    default Optional<User> findByEmailValidated(String email) {
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email format");
        }
        return findByEmail(email);
    }
    
    // ✅ Use @Valid in service methods
    @Transactional
    default User createUser(@Valid User user) {
        if (existsByEmail(user.getEmail())) {
            throw new DuplicateEmailException("Email already exists");
        }
        return save(user);
    }
}
```

---

## 🏗️ CUSTOM REPOSITORY IMPLEMENTATIONS

### Extending Repository Interfaces
```java
// Custom interface for complex operations
public interface UserRepositoryCustom {
    List<User> findUsersWithComplexCriteria(UserSearchRequest request);
    UserStatistics calculateUserStatistics(LocalDateTime from, LocalDateTime to);
}

// Implementation class
@Repository
public class UserRepositoryImpl implements UserRepositoryCustom {
    
    @PersistenceContext
    private EntityManager entityManager;
    
    @Override
    public List<User> findUsersWithComplexCriteria(UserSearchRequest request) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<User> query = cb.createQuery(User.class);
        Root<User> root = query.from(User.class);
        
        List<Predicate> predicates = new ArrayList<>();
        
        // Build dynamic predicates based on request
        if (request.getNamePattern() != null) {
            predicates.add(cb.like(root.get("name"), "%" + request.getNamePattern() + "%"));
        }
        
        query.where(predicates.toArray(new Predicate[0]));
        
        return entityManager.createQuery(query)
            .setMaxResults(request.getLimit())
            .getResultList();
    }
}

// Main repository interface extends both
public interface UserRepository extends JpaRepository<User, Long>, 
                                       UserRepositoryCustom {
    // Standard repository methods
}
```

---

## 📊 CACHING STRATEGIES

### Repository-Level Caching
```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // ✅ Cache frequently accessed, rarely changed data
    @Cacheable(value = "users", key = "#id", unless = "#result == null")
    Optional<User> findById(Long id);
    
    // ✅ Cache expensive queries
    @Cacheable(value = "userStats", key = "#department")
    @Query("SELECT COUNT(u) FROM User u WHERE u.department.name = :department")
    Long countByDepartment(@Param("department") String department);
    
    // ✅ Cache eviction on updates
    @CacheEvict(value = "users", key = "#user.id")
    @Modifying
    @Transactional
    default User updateUser(User user) {
        return save(user);
    }
    
    // ✅ Clear cache for bulk operations
    @CacheEvict(value = {"users", "userStats"}, allEntries = true)
    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.status = :status WHERE u.lastLoginAt < :cutoff")
    int deactivateInactiveUsers(@Param("status") UserStatus status, 
                               @Param("cutoff") LocalDateTime cutoff);
}
```

### Cache Configuration Best Practices
- **Choose appropriate TTL** based on data volatility
- **Use cache keys wisely** to avoid collisions
- **Implement cache warming** for critical data
- **Monitor cache hit rates** and adjust strategies
- **Handle cache failures gracefully** with fallback mechanisms



---

## 🎯 COMMON ANTI-PATTERNS TO AVOID

### Repository Anti-Patterns
```java
// ❌ Business logic in repository
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    default User promoteUser(Long userId) { // Wrong layer!
        User user = findById(userId).orElseThrow();
        user.setRole(Role.MANAGER);
        // Complex business rules here
        return save(user);
    }
}

// ❌ Exposing mutable collections
@Entity
public class Order {
    @OneToMany(mappedBy = "order")
    private List<OrderItem> items = new ArrayList<>();
    
    public List<OrderItem> getItems() {
        return items; // Exposes mutable reference!
    }
}

// ❌ Inefficient N+1 queries
@Query("SELECT u FROM User u") // Missing JOIN FETCH
List<User> findAllUsers(); // Will trigger N+1 for lazy associations
```

### Performance Anti-Patterns
```java
// ❌ No pagination for large datasets
List<User> findByDepartment(String department); // Could return millions

// ❌ Eager loading everything
@OneToMany(fetch = FetchType.EAGER) // Loads unnecessary data
private Set<Order> orders;

// ❌ Missing transaction boundaries
@Query("UPDATE User u SET u.lastLogin = :now") // No @Transactional
int updateLastLogin(@Param("now") LocalDateTime now);
```

---

## 📖 DOCUMENTATION STANDARDS

### Repository Documentation
```java
/**
 * Repository for managing User entities with specialized query methods.
 * 
 * <p>This repository provides optimized queries for user management operations
 * including user lookup, batch operations, and reporting functionality.</p>
 * 
 * @author Development Team
 * @since 1.0
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * Finds users by email address with case-insensitive matching.
     * 
     * @param email the email address to search for (case-insensitive)
     * @return Optional containing the user if found, empty otherwise
     * @throws IllegalArgumentException if email is null or invalid format
     */
    @Query("SELECT u FROM User u WHERE LOWER(u.email) = LOWER(:email)")
    Optional<User> findByEmailIgnoreCase(@Param("email") String email);
    
    /**
     * Retrieves users with their roles loaded to avoid N+1 queries.
     * 
     * <p>This method uses JOIN FETCH to eagerly load user roles in a single query.
     * Recommended for operations that need immediate access to role information.</p>
     * 
     * @param departmentId the department ID to filter by
     * @return list of users with roles pre-loaded
     * @see #findUsersWithRolesByDepartment(Long, Pageable) for paginated version
     */
    @EntityGraph(attributePaths = {"roles"})
    @Query("SELECT DISTINCT u FROM User u WHERE u.department.id = :deptId")
    List<User> findUsersWithRolesByDepartment(@Param("deptId") Long departmentId);
}
```

---

## 🔧 TOOLS & UTILITIES

### Development Tools
- **Spring Boot DevTools** - Auto-restart and live reload
- **H2 Console** - Database inspection during development
- **JPA Buddy Plugin** - IntelliJ IDEA plugin for JPA development
- **Flyway/Liquibase** - Database migration management

---

## 📋 FINAL CHECKLIST FOR CODE REVIEWS

### Repository Design Review
- [ ] Repository follows single responsibility principle
- [ ] Appropriate base interface extension (`JpaRepository`, `CrudRepository`)
- [ ] No business logic in repository layer
- [ ] Proper transaction boundaries defined
- [ ] Security considerations addressed (SQL injection prevention)

### Query Review
- [ ] Efficient query design (avoid N+1 problems)
- [ ] Appropriate use of pagination for large datasets
- [ ] Proper parameter binding and validation
- [ ] Index considerations for query performance
- [ ] DTO projections used where appropriate

### Performance Review
- [ ] Fetch strategies optimized (`LAZY` vs `EAGER`)
- [ ] Batch operations used for bulk data manipulation
- [ ] Caching strategy implemented where beneficial
- [ ] Query execution plans analyzed for complex queries
- [ ] Connection pool settings appropriate for load

### Testing Review
- [ ] *See separate JPA Repository Testing Guide*

### Documentation Review
- [ ] Repository interface and methods documented
- [ ] Complex queries explained with comments
- [ ] Performance characteristics documented
- [ ] Usage examples provided where helpful
- [ ] Migration and deployment notes included

---

*This guide serves as a comprehensive reference for reviewing JPA repositories in Spring Boot 2.7 applications. Regular updates should be made to reflect evolving best practices and team-specific conventions.*