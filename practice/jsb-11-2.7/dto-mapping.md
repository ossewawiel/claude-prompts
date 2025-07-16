# DTO Mapping & Data Transfer

## Overview

Data Transfer Objects (DTOs) are essential for creating clean boundaries between application layers and controlling data exposure. This document covers DTO patterns, mapping strategies, and best practices for Spring Boot 2.7 applications.

## DTO Design Patterns

### 1. Request/Response DTO Pattern

```java
/**
 * Request DTOs - Input validation and data binding
 */
@Value
@Builder
@JsonDeserialize(builder = CreateUserRequest.CreateUserRequestBuilder.class)
public class CreateUserRequest {
    
    @NotBlank(message = "First name is required")
    @Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters")
    String firstName;
    
    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
    String lastName;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    String email;
    
    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 100, message = "Password must be between 8 and 100 characters")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).*$", 
             message = "Password must contain at least one lowercase, one uppercase, and one digit")
    String password;
    
    @Valid
    @NotNull(message = "Address is required")
    AddressDto address;
    
    @JsonPOJOBuilder(withPrefix = "")
    public static class CreateUserRequestBuilder { }
}

/**
 * Response DTOs - Data presentation and serialization
 */
@Value
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class UserResponse {
    
    Long id;
    String firstName;
    String lastName;
    String email;
    String status;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime lastLoginAt;
    
    AddressDto address;
    
    // Computed fields
    @JsonProperty("fullName")
    public String getFullName() {
        return firstName + " " + lastName;
    }
    
    @JsonProperty("isActive")
    public boolean isActive() {
        return "ACTIVE".equals(status);
    }
    
    @JsonProperty("accountAge")
    public long getAccountAgeDays() {
        return createdAt != null ? ChronoUnit.DAYS.between(createdAt.toLocalDate(), LocalDate.now()) : 0;
    }
}

/**
 * Nested DTOs for complex objects
 */
@Value
@Builder
public class AddressDto {
    
    @NotBlank(message = "Street address is required")
    String street;
    
    @NotBlank(message = "City is required")
    String city;
    
    @NotBlank(message = "State is required")
    String state;
    
    @NotBlank(message = "ZIP code is required")
    @Pattern(regexp = "\\d{5}(-\\d{4})?", message = "ZIP code must be in format 12345 or 12345-6789")
    String zipCode;
    
    @NotBlank(message = "Country is required")
    String country;
}
```

### 2. Update and Patch DTOs

```java
/**
 * Update DTO - Full object replacement
 */
@Value
@Builder
@JsonDeserialize(builder = UpdateUserRequest.UpdateUserRequestBuilder.class)
public class UpdateUserRequest {
    
    @NotBlank(message = "First name is required")
    String firstName;
    
    @NotBlank(message = "Last name is required")
    String lastName;
    
    @Valid
    @NotNull(message = "Address is required")
    AddressDto address;
    
    @JsonPOJOBuilder(withPrefix = "")
    public static class UpdateUserRequestBuilder { }
}

/**
 * Patch DTO - Partial updates with Optional fields
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonDeserialize(builder = PatchUserRequest.PatchUserRequestBuilder.class)
public class PatchUserRequest {
    
    @Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters")
    Optional<String> firstName;
    
    @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
    Optional<String> lastName;
    
    @Valid
    Optional<AddressDto> address;
    
    // Helper methods for checking if fields are present
    public boolean hasFirstName() {
        return firstName != null && firstName.isPresent();
    }
    
    public boolean hasLastName() {
        return lastName != null && lastName.isPresent();
    }
    
    public boolean hasAddress() {
        return address != null && address.isPresent();
    }
    
    @JsonPOJOBuilder(withPrefix = "")
    public static class PatchUserRequestBuilder { }
}
```

### 3. Search and Filter DTOs

```java
/**
 * Search criteria with pagination
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserSearchCriteria {
    
    String keyword;  // Search in name, email
    String status;   // Filter by status
    String city;     // Filter by city
    LocalDate createdAfter;
    LocalDate createdBefore;
    
    @Builder.Default
    Integer page = 0;
    
    @Builder.Default
    @Range(min = 1, max = 100, message = "Size must be between 1 and 100")
    Integer size = 20;
    
    @Builder.Default
    String sortBy = "createdAt";
    
    @Builder.Default
    String sortDirection = "DESC";
    
    // Validation method
    public void validate() {
        if (createdAfter != null && createdBefore != null && createdAfter.isAfter(createdBefore)) {
            throw new IllegalArgumentException("createdAfter cannot be after createdBefore");
        }
    }
    
    // Convert to Pageable
    public Pageable toPageable() {
        Sort.Direction direction = Sort.Direction.fromString(sortDirection);
        Sort sort = Sort.by(direction, sortBy);
        return PageRequest.of(page, size, sort);
    }
}

/**
 * Paginated response wrapper
 */
@Value
@Builder
public class PagedResponse<T> {
    
    List<T> content;
    int page;
    int size;
    long totalElements;
    int totalPages;
    boolean first;
    boolean last;
    boolean empty;
    
    public static <T> PagedResponse<T> of(Page<T> page) {
        return PagedResponse.<T>builder()
            .content(page.getContent())
            .page(page.getNumber())
            .size(page.getSize())
            .totalElements(page.getTotalElements())
            .totalPages(page.getTotalPages())
            .first(page.isFirst())
            .last(page.isLast())
            .empty(page.isEmpty())
            .build();
    }
}
```

## Mapping Strategies

### 1. MapStruct Implementation (Recommended)

```xml
<!-- Maven dependency -->
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.5.3.Final</version>
</dependency>
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct-processor</artifactId>
    <version>1.5.3.Final</version>
    <scope>provided</scope>
</dependency>
```

```java
/**
 * MapStruct mapper interface
 */
@Mapper(componentModel = "spring", 
        injectionStrategy = InjectionStrategy.CONSTRUCTOR,
        uses = {AddressMapper.class})
public interface UserMapper {
    
    /**
     * Entity to Response DTO mapping
     */
    @Mapping(target = "status", source = "status", qualifiedByName = "statusToString")
    @Mapping(target = "address", source = "address")
    UserResponse toResponse(User user);
    
    /**
     * Request DTO to Entity mapping
     */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "lastLoginAt", ignore = true)
    @Mapping(target = "status", constant = "PENDING_VERIFICATION")
    @Mapping(target = "password", ignore = true) // Set separately after encoding
    User toEntity(CreateUserRequest request);
    
    /**
     * Update DTO to Entity mapping
     */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "email", ignore = true) // Email cannot be updated
    @Mapping(target = "password", ignore = true)
    /**
     * Update DTO to Entity mapping
     */
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "email", ignore = true) // Email cannot be updated
    @Mapping(target = "password", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", expression = "java(java.time.LocalDateTime.now())")
    void updateEntityFromDto(UpdateUserRequest request, @MappingTarget User user);
    
    /**
     * Patch DTO to Entity mapping
     */
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "email", ignore = true)
    @Mapping(target = "password", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", expression = "java(java.time.LocalDateTime.now())")
    void patchEntityFromDto(PatchUserRequest request, @MappingTarget User user);
    
    /**
     * List mapping
     */
    List<UserResponse> toResponseList(List<User> users);
    
    /**
     * Page mapping
     */
    default PagedResponse<UserResponse> toPagedResponse(Page<User> page) {
        return PagedResponse.<UserResponse>builder()
            .content(toResponseList(page.getContent()))
            .page(page.getNumber())
            .size(page.getSize())
            .totalElements(page.getTotalElements())
            .totalPages(page.getTotalPages())
            .first(page.isFirst())
            .last(page.isLast())
            .empty(page.isEmpty())
            .build();
    }
    
    /**
     * Custom mapping methods
     */
    @Named("statusToString")
    default String statusToString(UserStatus status) {
        return status != null ? status.name() : null;
    }
    
    /**
     * After mapping for complex logic
     */
    @AfterMapping
    default void enrichUserResponse(@MappingTarget UserResponse.UserResponseBuilder response, User user) {
        // Add computed fields or complex logic
        if (user.getLastLoginAt() != null) {
            long daysSinceLogin = ChronoUnit.DAYS.between(user.getLastLoginAt().toLocalDate(), LocalDate.now());
            // Could add this as a field if needed
        }
    }
}

/**
 * Address mapper
 */
@Mapper(componentModel = "spring")
public interface AddressMapper {
    
    AddressDto toDto(Address address);
    
    @Mapping(target = "id", ignore = true)
    Address toEntity(AddressDto dto);
    
    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromDto(AddressDto dto, @MappingTarget Address address);
}
```

### 2. ModelMapper Implementation (Alternative)

```java
/**
 * ModelMapper configuration
 */
@Configuration
public class ModelMapperConfig {
    
    @Bean
    public ModelMapper modelMapper() {
        ModelMapper mapper = new ModelMapper();
        
        // Global configuration
        mapper.getConfiguration()
            .setMatchingStrategy(MatchingStrategies.STRICT)
            .setFieldMatchingEnabled(true)
            .setFieldAccessLevel(org.modelmapper.config.Configuration.AccessLevel.PRIVATE);
        
        // Custom mappings
        configureUserMappings(mapper);
        
        return mapper;
    }
    
    private void configureUserMappings(ModelMapper mapper) {
        // Entity to Response DTO
        mapper.createTypeMap(User.class, UserResponse.class)
            .addMapping(src -> src.getStatus().name(), UserResponse::getStatus)
            .addMapping(User::getCreatedAt, UserResponse::getCreatedAt);
        
        // Request DTO to Entity
        mapper.createTypeMap(CreateUserRequest.class, User.class)
            .addMappings(mapping -> {
                mapping.skip(User::setId);
                mapping.skip(User::setCreatedAt);
                mapping.skip(User::setUpdatedAt);
                mapping.skip(User::setPassword); // Set separately
            });
    }
}

/**
 * ModelMapper service wrapper
 */
@Service
@RequiredArgsConstructor
public class UserMappingService {
    
    private final ModelMapper modelMapper;
    
    public UserResponse toResponse(User user) {
        return modelMapper.map(user, UserResponse.class);
    }
    
    public User toEntity(CreateUserRequest request) {
        User user = modelMapper.map(request, User.class);
        user.setStatus(UserStatus.PENDING_VERIFICATION);
        user.setCreatedAt(LocalDateTime.now());
        return user;
    }
    
    public void updateEntity(UpdateUserRequest request, User user) {
        modelMapper.map(request, user);
        user.setUpdatedAt(LocalDateTime.now());
    }
    
    public List<UserResponse> toResponseList(List<User> users) {
        return users.stream()
            .map(this::toResponse)
            .collect(Collectors.toList());
    }
}
```

### 3. Manual Mapping (For Complex Cases)

```java
/**
 * Manual mapper for complex business logic
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class OrderMapper {
    
    private final ProductService productService;
    private final CustomerService customerService;
    private final AddressMapper addressMapper;
    
    public OrderResponse toResponse(Order order) {
        return OrderResponse.builder()
            .id(order.getId())
            .orderNumber(order.getOrderNumber())
            .status(order.getStatus().name())
            .totalAmount(order.getTotalAmount())
            .currency(order.getCurrency())
            .createdAt(order.getCreatedAt())
            .customer(buildCustomerSummary(order.getCustomerId()))
            .items(buildOrderItems(order.getItems()))
            .shippingAddress(addressMapper.toDto(order.getShippingAddress()))
            .billingAddress(addressMapper.toDto(order.getBillingAddress()))
            .estimatedDelivery(calculateEstimatedDelivery(order))
            .build();
    }
    
    public Order toEntity(CreateOrderRequest request) {
        return Order.builder()
            .orderNumber(generateOrderNumber())
            .customerId(request.getCustomerId())
            .status(OrderStatus.PENDING)
            .currency(request.getCurrency())
            .createdAt(LocalDateTime.now())
            .items(buildOrderItemEntities(request.getItems()))
            .shippingAddress(addressMapper.toEntity(request.getShippingAddress()))
            .billingAddress(addressMapper.toEntity(request.getBillingAddress()))
            .build();
    }
    
    private CustomerSummary buildCustomerSummary(Long customerId) {
        return customerService.findById(customerId)
            .map(customer -> CustomerSummary.builder()
                .id(customer.getId())
                .name(customer.getFullName())
                .email(customer.getEmail())
                .membershipLevel(customer.getMembershipLevel())
                .build())
            .orElse(null);
    }
    
    private List<OrderItemResponse> buildOrderItems(List<OrderItem> items) {
        return items.stream()
            .map(item -> {
                Product product = productService.findById(item.getProductId())
                    .orElseThrow(() -> new ProductNotFoundException("Product not found: " + item.getProductId()));
                
                return OrderItemResponse.builder()
                    .productId(item.getProductId())
                    .productName(product.getName())
                    .productSku(product.getSku())
                    .quantity(item.getQuantity())
                    .unitPrice(item.getUnitPrice())
                    .totalPrice(item.getTotalPrice())
                    .build();
            })
            .collect(Collectors.toList());
    }
    
    private List<OrderItem> buildOrderItemEntities(List<OrderItemRequest> requests) {
        return requests.stream()
            .map(request -> {
                Product product = productService.findById(request.getProductId())
                    .orElseThrow(() -> new ProductNotFoundException("Product not found: " + request.getProductId()));
                
                return OrderItem.builder()
                    .productId(request.getProductId())
                    .quantity(request.getQuantity())
                    .unitPrice(product.getPrice())
                    .totalPrice(product.getPrice().multiply(BigDecimal.valueOf(request.getQuantity())))
                    .build();
            })
            .collect(Collectors.toList());
    }
    
    private LocalDateTime calculateEstimatedDelivery(Order order) {
        // Complex business logic for delivery estimation
        return order.getCreatedAt().plusDays(5); // Simplified
    }
    
    private String generateOrderNumber() {
        return "ORD-" + System.currentTimeMillis();
    }
}
```

## Service Layer Integration

### 1. Service Implementation with DTO Mapping

```java
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    
    @Override
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        log.info("Creating user with email: {}", request.getEmail());
        
        // Validate business rules
        validateCreateUserRequest(request);
        
        // Map to entity
        User user = userMapper.toEntity(request);
        
        // Set encoded password
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        
        // Save entity
        User savedUser = userRepository.save(user);
        
        // Send welcome email
        emailService.sendWelcomeEmailAsync(savedUser.getEmail(), savedUser.getFirstName());
        
        // Map to response
        return userMapper.toResponse(savedUser);
    }
    
    @Override
    @Transactional
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        log.info("Updating user: {}", id);
        
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
        
        // Update entity from DTO
        userMapper.updateEntityFromDto(request, user);
        
        // Save changes
        User updatedUser = userRepository.save(user);
        
        return userMapper.toResponse(updatedUser);
    }
    
    @Override
    @Transactional
    public UserResponse patchUser(Long id, PatchUserRequest request) {
        log.info("Patching user: {}", id);
        
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
        
        // Apply partial updates
        userMapper.patchEntityFromDto(request, user);
        
        User updatedUser = userRepository.save(user);
        
        return userMapper.toResponse(updatedUser);
    }
    
    @Override
    public Optional<UserResponse> findUserById(Long id) {
        return userRepository.findById(id)
            .map(userMapper::toResponse);
    }
    
    @Override
    public PagedResponse<UserResponse> searchUsers(UserSearchCriteria criteria) {
        log.debug("Searching users with criteria: {}", criteria);
        
        criteria.validate();
        
        Specification<User> spec = buildUserSpecification(criteria);
        Page<User> userPage = userRepository.findAll(spec, criteria.toPageable());
        
        return userMapper.toPagedResponse(userPage);
    }
    
    private void validateCreateUserRequest(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException("User with email already exists: " + request.getEmail());
        }
    }
    
    private Specification<User> buildUserSpecification(UserSearchCriteria criteria) {
        return Specification.where(null)
            .and(hasKeyword(criteria.getKeyword()))
            .and(hasStatus(criteria.getStatus()))
            .and(hasCity(criteria.getCity()))
            .and(createdAfter(criteria.getCreatedAfter()))
            .and(createdBefore(criteria.getCreatedBefore()));
    }
    
    private Specification<User> hasKeyword(String keyword) {
        return (root, query, builder) -> {
            if (keyword == null || keyword.isBlank()) {
                return null;
            }
            String pattern = "%" + keyword.toLowerCase() + "%";
            return builder.or(
                builder.like(builder.lower(root.get("firstName")), pattern),
                builder.like(builder.lower(root.get("lastName")), pattern),
                builder.like(builder.lower(root.get("email")), pattern)
            );
        };
    }
}
```

### 2. Controller Layer with DTOs

```java
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Slf4j
@Validated
public class UserController {
    
    private final UserService userService;
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse createUser(@Valid @RequestBody CreateUserRequest request) {
        log.info("Creating user via REST API");
        return userService.createUser(request);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id) {
        return userService.findUserById(id)
            .map(user -> ResponseEntity.ok(user))
            .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/{id}")
    public UserResponse updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRequest request) {
        return userService.updateUser(id, request);
    }
    
    @PatchMapping("/{id}")
    public UserResponse patchUser(
            @PathVariable Long id,
            @Valid @RequestBody PatchUserRequest request) {
        return userService.patchUser(id, request);
    }
    
    @GetMapping
    public PagedResponse<UserResponse> searchUsers(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate createdAfter,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate createdBefore,
            @RequestParam(defaultValue = "0") @Min(0) Integer page,
            @RequestParam(defaultValue = "20") @Range(min = 1, max = 100) Integer size,
            @RequestParam(defaultValue = "createdAt") String sortBy,
            @RequestParam(defaultValue = "DESC") String sortDirection) {
        
        UserSearchCriteria criteria = UserSearchCriteria.builder()
            .keyword(keyword)
            .status(status)
            .city(city)
            .createdAfter(createdAfter)
            .createdBefore(createdBefore)
            .page(page)
            .size(size)
            .sortBy(sortBy)
            .sortDirection(sortDirection)
            .build();
            
        return userService.searchUsers(criteria);
    }
}
```

## Advanced DTO Patterns

### 1. Projection DTOs for Performance

```java
/**
 * Lightweight projection for list views
 */
@Value
@Builder
public class UserSummary {
    Long id;
    String fullName;
    String email;
    String status;
    
    @JsonFormat(pattern = "yyyy-MM-dd")
    LocalDate createdDate;
}

/**
 * Repository with projection queries
 */
public interface UserRepository extends JpaRepository<User, Long> {
    
    @Query("SELECT new com.example.dto.UserSummary(" +
           "u.id, " +
           "CONCAT(u.firstName, ' ', u.lastName), " +
           "u.email, " +
           "u.status, " +
           "DATE(u.createdAt)) " +
           "FROM User u " +
           "WHERE (:status IS NULL OR u.status = :status)")
    Page<UserSummary> findUserSummaries(@Param("status") UserStatus status, Pageable pageable);
    
    @Query("SELECT u.id as id, " +
           "CONCAT(u.firstName, ' ', u.lastName) as fullName, " +
           "u.email as email, " +
           "u.status as status " +
           "FROM User u " +
           "WHERE u.lastLoginAt > :since")
    List<UserProjection> findActiveUsersSince(@Param("since") LocalDateTime since);
}

/**
 * Interface-based projection
 */
public interface UserProjection {
    Long getId();
    String getFullName();
    String getEmail();
    String getStatus();
}
```

### 2. Hierarchical DTOs

```java
/**
 * Category with nested subcategories
 */
@Value
@Builder
public class CategoryResponse {
    Long id;
    String name;
    String description;
    String slug;
    Integer level;
    Long parentId;
    
    @Builder.Default
    List<CategoryResponse> subcategories = new ArrayList<>();
    
    @Builder.Default
    List<ProductSummary> products = new ArrayList<>();
}

/**
 * Mapper for hierarchical structures
 */
@Mapper(componentModel = "spring")
public interface CategoryMapper {
    
    @Mapping(target = "subcategories", ignore = true) // Map separately
    @Mapping(target = "products", ignore = true)
    CategoryResponse toResponse(Category category);
    
    default CategoryResponse toResponseWithChildren(Category category) {
        CategoryResponse response = toResponse(category);
        
        // Map subcategories recursively
        List<CategoryResponse> subcategories = category.getSubcategories().stream()
            .map(this::toResponseWithChildren)
            .collect(Collectors.toList());
            
        // Map products
        List<ProductSummary> products = category.getProducts().stream()
            .map(this::toProductSummary)
            .collect(Collectors.toList());
            
        return response.toBuilder()
            .subcategories(subcategories)
            .products(products)
            .build();
    }
    
    @Mapping(target = "categoryName", source = "category.name")
    ProductSummary toProductSummary(Product product);
}
```

### 3. Aggregation DTOs

```java
/**
 * Complex aggregation DTO
 */
@Value
@Builder
public class DashboardResponse {
    UserStats userStats;
    OrderStats orderStats;
    RevenueStats revenueStats;
    List<PopularProduct> popularProducts;
    List<RecentActivity> recentActivities;
    
    @Value
    @Builder
    public static class UserStats {
        long totalUsers;
        long activeUsers;
        long newUsersToday;
        double growthRate;
    }
    
    @Value
    @Builder
    public static class OrderStats {
        long totalOrders;
        long pendingOrders;
        long completedOrders;
        BigDecimal averageOrderValue;
    }
    
    @Value
    @Builder
    public static class RevenueStats {
        BigDecimal totalRevenue;
        BigDecimal monthlyRevenue;
        BigDecimal dailyRevenue;
        double monthOverMonthGrowth;
    }
}

/**
 * Service for building aggregation DTOs
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardService {
    
    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ActivityRepository activityRepository;
    
    public DashboardResponse getDashboardData() {
        log.info("Building dashboard data");
        
        return DashboardResponse.builder()
            .userStats(buildUserStats())
            .orderStats(buildOrderStats())
            .revenueStats(buildRevenueStats())
            .popularProducts(findPopularProducts())
            .recentActivities(findRecentActivities())
            .build();
    }
    
    private DashboardResponse.UserStats buildUserStats() {
        long totalUsers = userRepository.count();
        long activeUsers = userRepository.countByStatus(UserStatus.ACTIVE);
        long newUsersToday = userRepository.countByCreatedAtAfter(LocalDateTime.now().toLocalDate().atStartOfDay());
        
        // Calculate growth rate
        LocalDateTime lastMonth = LocalDateTime.now().minusMonths(1);
        long usersLastMonth = userRepository.countByCreatedAtBefore(lastMonth);
        double growthRate = usersLastMonth > 0 ? ((double) (totalUsers - usersLastMonth) / usersLastMonth) * 100 : 0;
        
        return DashboardResponse.UserStats.builder()
            .totalUsers(totalUsers)
            .activeUsers(activeUsers)
            .newUsersToday(newUsersToday)
            .growthRate(growthRate)
            .build();
    }
}
```

## Performance Considerations

### 1. DTO Mapping Performance

```java
/**
 * Cached mapping for frequently accessed data
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CachedMappingService {
    
    private final UserMapper userMapper;
    private final CacheManager cacheManager;
    
    @Cacheable(value = "userResponses", key = "#user.id")
    public UserResponse toUserResponse(User user) {
        log.debug("Mapping user to response DTO: {}", user.getId());
        return userMapper.toResponse(user);
    }
    
    @CacheEvict(value = "userResponses", key = "#user.id")
    public void evictUserResponseCache(User user) {
        log.debug("Evicting user response cache: {}", user.getId());
    }
    
    public List<UserResponse> toUserResponseList(List<User> users) {
        return users.parallelStream()  // Use parallel stream for large lists
            .map(this::toUserResponse)
            .collect(Collectors.toList());
    }
}

/**
 * Lazy loading prevention in DTOs
 */
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class OptimizedUserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    
    @EntityGraph(attributePaths = {"address", "orders.items"})
    public UserResponse findUserWithDetails(Long id) {
        return userRepository.findById(id)
            .map(userMapper::toResponse)
            .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
    }
    
    @Query("SELECT u FROM User u LEFT JOIN FETCH u.address WHERE u.id IN :ids")
    public List<UserResponse> findUsersWithAddresses(List<Long> ids) {
        List<User> users = userRepository.findUsersWithAddresses(ids);
        return userMapper.toResponseList(users);
    }
}
```

### 2. Memory Optimization

```java
/**
 * Streaming DTOs for large datasets
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class BulkExportService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    
    public void exportUsersToCSV(OutputStream outputStream) throws IOException {
        try (CSVWriter writer = new CSVWriter(new OutputStreamWriter(outputStream))) {
            
            // Write CSV header
            writer.writeNext(new String[]{"ID", "Name", "Email", "Status", "Created"});
            
            // Stream process users to avoid loading all into memory
            userRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(this::mapToCSVRow)
                .forEach(writer::writeNext);
        }
    }
    
    private String[] mapToCSVRow(User user) {
        return new String[]{
            user.getId().toString(),
            user.getFirstName() + " " + user.getLastName(),
            user.getEmail(),
            user.getStatus().toString(),
            user.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE)
        };
    }
    
    @Transactional(readOnly = true)
    public Stream<UserSummary> streamUserSummaries() {
        return userRepository.streamAllByOrderByCreatedAtDesc()
            .map(user -> UserSummary.builder()
                .id(user.getId())
                .fullName(user.getFirstName() + " " + user.getLastName())
                .email(user.getEmail())
                .status(user.getStatus().toString())
                .createdDate(user.getCreatedAt().toLocalDate())
                .build());
    }
}
```

## Validation and Error Handling

### 1. Custom DTO Validators

```java
/**
 * Custom validation annotation
 */
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = ValidOrderRequestValidator.class)
@Documented
public @interface ValidOrderRequest {
    String message() default "Invalid order request";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

/**
 * Custom validator implementation
 */
public class ValidOrderRequestValidator implements ConstraintValidator<ValidOrderRequest, CreateOrderRequest> {
    
    @Override
    public boolean isValid(CreateOrderRequest request, ConstraintValidatorContext context) {
        if (request == null) {
            return true; // Let @NotNull handle null validation
        }
        
        boolean valid = true;
        
        // Validate item quantities
        if (request.getItems().stream().anyMatch(item -> item.getQuantity() <= 0)) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("All items must have positive quantities")
                .addPropertyNode("items")
                .addConstraintViolation();
            valid = false;
        }
        
        // Validate total amount
        BigDecimal calculatedTotal = request.getItems().stream()
            .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
            
        if (calculatedTotal.compareTo(request.getTotalAmount()) != 0) {
            context.disableDefaultConstraintViolation();
            context.buildConstraintViolationWithTemplate("Total amount does not match item calculations")
                .addPropertyNode("totalAmount")
                .addConstraintViolation();
            valid = false;
        }
        
        return valid;
    }
}

/**
 * Apply custom validation to DTO
 */
@Value
@Builder
@ValidOrderRequest
@JsonDeserialize(builder = CreateOrderRequest.CreateOrderRequestBuilder.class)
public class CreateOrderRequest {
    
    @NotNull(message = "Customer ID is required")
    Long customerId;
    
    @NotEmpty(message = "Order must contain at least one item")
    @Valid
    List<OrderItemRequest> items;
    
    @NotNull(message = "Total amount is required")
    @DecimalMin(value = "0.01", message = "Total amount must be positive")
    BigDecimal totalAmount;
    
    @NotBlank(message = "Currency is required")
    String currency;
    
    @Valid
    @NotNull(message = "Shipping address is required")
    AddressDto shippingAddress;
    
    @JsonPOJOBuilder(withPrefix = "")
    public static class CreateOrderRequestBuilder { }
}
```

## Summary

DTO mapping and data transfer best practices:

1. **Immutable DTOs** - Use `@Value` and `@Builder` for request/response objects
2. **MapStruct for Performance** - Compile-time mapping generation with type safety
3. **Validation** - Comprehensive input validation with custom validators
4. **Projection** - Use lightweight DTOs for list views and performance
5. **Caching** - Cache frequently accessed mapping operations
6. **Streaming** - Use streaming for large dataset processing
7. **Error Handling** - Proper validation error messages and handling
8. **Testing** - Unit test all mapping operations and validations

Next: [Error Handling & Exception Management](error-handling)