# Service Layer Architecture

## Overview

The service layer is the heart of business logic in Spring Boot applications. This document covers architectural patterns, design principles, transaction management, and dependency injection strategies for building robust service layers.

## Service Layer Responsibilities

### 1. Core Responsibilities

```java
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@Slf4j
public class OrderService {
    
    private final OrderRepository orderRepository;
    private final ProductService productService;
    private final PaymentService paymentService;
    private final InventoryService inventoryService;
    private final NotificationService notificationService;
    private final OrderMapper orderMapper;
    
    /**
     * Business Logic: Orchestrate order creation process
     * - Validate business rules
     * - Coordinate with other services
     * - Manage transactions
     * - Handle business exceptions
     */
    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        log.info("Creating order for user: {}", request.getUserId());
        
        // 1. Business validation
        validateOrderRequest(request);
        
        // 2. Check inventory and reserve products
        List<ProductReservation> reservations = reserveProducts(request.getItems());
        
        try {
            // 3. Create order entity
            Order order = buildOrder(request, reservations);
            
            // 4. Process payment
            PaymentResult payment = paymentService.processPayment(
                order.getTotalAmount(), request.getPaymentDetails());
            
            if (!payment.isSuccessful()) {
                throw new PaymentFailedException("Payment processing failed: " + payment.getFailureReason());
            }
            
            // 5. Finalize order
            order.markAsPaid(payment.getTransactionId());
            Order savedOrder = orderRepository.save(order);
            
            // 6. Send notifications (async)
            notificationService.sendOrderConfirmationAsync(savedOrder);
            
            log.info("Order created successfully: {}", savedOrder.getId());
            return orderMapper.toResponse(savedOrder);
            
        } catch (Exception e) {
            // 7. Rollback reservations on failure
            releaseReservations(reservations);
            throw e;
        }
    }
    
    /**
     * Business Rule Validation
     */
    private void validateOrderRequest(CreateOrderRequest request) {
        if (request.getItems().isEmpty()) {
            throw new InvalidOrderException("Order must contain at least one item");
        }
        
        if (request.getItems().size() > 50) {
            throw new InvalidOrderException("Order cannot contain more than 50 items");
        }
        
        BigDecimal totalValue = request.getItems().stream()
            .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
            
        if (totalValue.compareTo(BigDecimal.valueOf(10000)) > 0) {
            throw new InvalidOrderException("Order value cannot exceed $10,000");
        }
    }
}
```

### 2. Service Layer Patterns

#### A. Interface-Based Services

```java
/**
 * Service interface defining business operations
 */
public interface UserService {
    
    /**
     * Creates a new user account
     * @param request user creation data
     * @return created user response
     * @throws UserAlreadyExistsException if email already exists
     * @throws ValidationException if input data is invalid
     */
    UserResponse createUser(CreateUserRequest request);
    
    /**
     * Finds user by ID
     * @param id user identifier
     * @return user data if found
     */
    Optional<UserResponse> findUserById(Long id);
    
    /**
     * Updates user information
     * @param id user identifier
     * @param request update data
     * @return updated user response
     * @throws UserNotFoundException if user doesn't exist
     */
    UserResponse updateUser(Long id, UpdateUserRequest request);
    
    /**
     * Activates user account
     * @param userId user identifier
     * @throws UserNotFoundException if user doesn't exist
     * @throws UserAlreadyActiveException if user is already active
     */
    void activateUser(Long userId);
    
    /**
     * Searches users by criteria
     * @param criteria search parameters
     * @return paginated search results
     */
    Page<UserResponse> searchUsers(UserSearchCriteria criteria, Pageable pageable);
}

/**
 * Primary implementation of UserService
 */
@Service
@Primary
@Transactional(readOnly = true)
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final UserMapper userMapper;
    private final AuditService auditService;
    
    @Override
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        log.info("Creating user with email: {}", request.getEmail());
        
        // Business validation
        validateUniqueEmail(request.getEmail());
        
        // Create entity
        User user = User.builder()
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .email(request.getEmail())
            .password(passwordEncoder.encode(request.getPassword()))
            .status(UserStatus.PENDING_VERIFICATION)
            .createdAt(LocalDateTime.now())
            .build();
            
        User savedUser = userRepository.save(user);
        
        // Business operations
        emailService.sendVerificationEmail(savedUser.getEmail(), generateVerificationToken(savedUser));
        auditService.logUserCreation(savedUser.getId());
        
        log.info("User created successfully: {}", savedUser.getId());
        return userMapper.toResponse(savedUser);
    }
    
    private void validateUniqueEmail(String email) {
        if (userRepository.existsByEmail(email)) {
            throw new UserAlreadyExistsException("User with email already exists: " + email);
        }
    }
}
```

#### B. Domain Service Pattern

```java
/**
 * Domain service for complex business operations
 * that don't naturally fit in a single entity
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class OrderDomainService {
    
    private final ProductService productService;
    private final InventoryService inventoryService;
    private final PricingService pricingService;
    private final DiscountService discountService;
    
    /**
     * Complex business logic for order calculation
     */
    public OrderCalculation calculateOrder(List<OrderItem> items, String couponCode, Long customerId) {
        log.debug("Calculating order for {} items", items.size());
        
        // 1. Validate all products exist and are available
        List<Product> products = validateAndRetrieveProducts(items);
        
        // 2. Check inventory availability
        validateInventoryAvailability(items);
        
        // 3. Calculate base pricing
        BigDecimal baseTotal = calculateBaseTotal(items, products);
        
        // 4. Apply customer-specific pricing
        BigDecimal customerTotal = pricingService.applyCustomerPricing(baseTotal, customerId);
        
        // 5. Apply discounts and coupons
        DiscountCalculation discount = discountService.calculateDiscount(customerTotal, couponCode, customerId);
        
        // 6. Calculate taxes
        BigDecimal taxAmount = calculateTax(customerTotal.subtract(discount.getAmount()));
        
        // 7. Build final calculation
        return OrderCalculation.builder()
            .baseTotal(baseTotal)
            .customerTotal(customerTotal)
            .discountAmount(discount.getAmount())
            .taxAmount(taxAmount)
            .finalTotal(customerTotal.subtract(discount.getAmount()).add(taxAmount))
            .appliedDiscounts(discount.getAppliedDiscounts())
            .build();
    }
    
    private List<Product> validateAndRetrieveProducts(List<OrderItem> items) {
        List<Long> productIds = items.stream()
            .map(OrderItem::getProductId)
            .collect(Collectors.toList());
            
        List<Product> products = productService.findProductsByIds(productIds);
        
        if (products.size() != productIds.size()) {
            throw new ProductNotFoundException("One or more products not found");
        }
        
        // Validate all products are active
        products.stream()
            .filter(product -> !product.isActive())
            .findFirst()
            .ifPresent(product -> {
                throw new ProductNotAvailableException("Product not available: " + product.getName());
            });
            
        return products;
    }
}
```

## Transaction Management

### 1. Transaction Configuration

```java
@Service
@Transactional(readOnly = true)  // Default to read-only
@RequiredArgsConstructor
@Slf4j
public class AccountService {
    
    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    private final NotificationService notificationService;
    
    /**
     * Read-only operation - uses class-level configuration
     */
    public Optional<AccountResponse> findAccountById(Long id) {
        return accountRepository.findById(id)
            .map(this::toResponse);
    }
    
    /**
     * Write operation - override with read-write transaction
     */
    @Transactional
    public AccountResponse createAccount(CreateAccountRequest request) {
        Account account = Account.builder()
            .accountNumber(generateAccountNumber())
            .balance(BigDecimal.ZERO)
            .status(AccountStatus.ACTIVE)
            .build();
            
        Account savedAccount = accountRepository.save(account);
        
        // This runs in the same transaction
        createInitialTransaction(savedAccount);
        
        return toResponse(savedAccount);
    }
    
    /**
     * Complex transaction with rollback scenarios
     */
    @Transactional(rollbackFor = {BusinessException.class})
    public TransferResult transferFunds(TransferRequest request) {
        log.info("Transferring {} from account {} to account {}", 
            request.getAmount(), request.getFromAccountId(), request.getToAccountId());
            
        // 1. Load and lock accounts
        Account fromAccount = accountRepository.findByIdForUpdate(request.getFromAccountId())
            .orElseThrow(() -> new AccountNotFoundException("Source account not found"));
            
        Account toAccount = accountRepository.findByIdForUpdate(request.getToAccountId())
            .orElseThrow(() -> new AccountNotFoundException("Destination account not found"));
        
        // 2. Business validation
        validateTransfer(fromAccount, toAccount, request.getAmount());
        
        // 3. Perform transfer
        fromAccount.debit(request.getAmount());
        toAccount.credit(request.getAmount());
        
        // 4. Save changes
        accountRepository.saveAll(List.of(fromAccount, toAccount));
        
        // 5. Record transaction history
        Transaction transaction = Transaction.builder()
            .fromAccountId(fromAccount.getId())
            .toAccountId(toAccount.getId())
            .amount(request.getAmount())
            .type(TransactionType.TRANSFER)
            .status(TransactionStatus.COMPLETED)
            .timestamp(LocalDateTime.now())
            .build();
            
        transactionRepository.save(transaction);
        
        // 6. Send notifications (runs in same transaction)
        notificationService.notifyTransferCompleted(fromAccount, toAccount, request.getAmount());
        
        return TransferResult.success(transaction.getId());
    }
    
    /**
     * New transaction for independent operations
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void logAuditEvent(AuditEvent event) {
        // This runs in a separate transaction
        // Won't be rolled back even if calling method fails
        auditRepository.save(event);
    }
}
```

### 2. Transaction Best Practices

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class BankingService {
    
    private final AccountService accountService;
    private final AuditService auditService;
    
    /**
     * Declarative transaction boundaries
     */
    @Transactional
    public void processLoan(LoanApplication application) {
        try {
            // All operations in single transaction
            validateLoanApplication(application);
            Account account = accountService.createLoanAccount(application);
            disburseLoanAmount(account, application.getAmount());
            scheduleRepayments(account, application);
            
        } catch (BusinessException e) {
            // Log audit event in separate transaction
            auditService.logLoanProcessingFailure(application.getId(), e.getMessage());
            throw e;
        }
    }
    
    /**
     * Programmatic transaction management for complex scenarios
     */
    @Autowired
    private TransactionTemplate transactionTemplate;
    
    public BatchProcessResult processBatchPayments(List<PaymentRequest> payments) {
        List<PaymentResult> results = new ArrayList<>();
        List<PaymentRequest> failures = new ArrayList<>();
        
        for (PaymentRequest payment : payments) {
            try {
                PaymentResult result = transactionTemplate.execute(status -> {
                    return processIndividualPayment(payment);
                });
                results.add(result);
                
            } catch (Exception e) {
                log.warn("Payment failed: {}", payment.getId(), e);
                failures.add(payment);
                // Continue processing other payments
            }
        }
        
        return BatchProcessResult.builder()
            .successfulPayments(results)
            .failedPayments(failures)
            .build();
    }
}
```

## Dependency Injection Patterns

### 1. Constructor Injection (Recommended)

```java
@Service
@RequiredArgsConstructor  // Lombok generates constructor
@Slf4j
public class ProductService {
    
    // All dependencies are final and injected via constructor
    private final ProductRepository productRepository;
    private final CategoryService categoryService;
    private final InventoryService inventoryService;
    private final PriceCalculator priceCalculator;
    private final ProductMapper productMapper;
    
    // Benefits:
    // 1. Immutable dependencies
    // 2. Fail-fast if dependencies are missing
    // 3. Easy unit testing
    // 4. Clear dependency requirements
    
    public ProductResponse createProduct(CreateProductRequest request) {
        log.info("Creating product: {}", request.getName());
        
        // All dependencies are guaranteed to be available
        Category category = categoryService.findById(request.getCategoryId())
            .orElseThrow(() -> new CategoryNotFoundException("Category not found"));
            
        Product product = Product.builder()
            .name(request.getName())
            .description(request.getDescription())
            .category(category)
            .basePrice(request.getPrice())
            .build();
            
        // Calculate pricing with injected calculator
        BigDecimal finalPrice = priceCalculator.calculateFinalPrice(product);
        product.setFinalPrice(finalPrice);
        
        Product savedProduct = productRepository.save(product);
        
        // Initialize inventory
        inventoryService.initializeInventory(savedProduct.getId(), request.getInitialStock());
        
        return productMapper.toResponse(savedProduct);
    }
}
```

### 2. Conditional and Qualified Injection

```java
/**
 * Multiple implementations of the same interface
 */
@Service
@Qualifier("database")
public class DatabaseUserService implements UserService {
    // Implementation that uses database
}

@Service
@Qualifier("cache")
public class CachedUserService implements UserService {
    // Implementation that uses cache
}

@Service
@Primary  // Default implementation
public class DefaultUserService implements UserService {
    // Default implementation
}

/**
 * Service that uses multiple implementations
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UserManagementService {
    
    @Qualifier("database")
    private final UserService databaseUserService;
    
    @Qualifier("cache")
    private final UserService cachedUserService;
    
    private final UserService defaultUserService;  // Uses @Primary
    
    public UserResponse getUserWithStrategy(Long id, DataStrategy strategy) {
        return switch (strategy) {
            case DATABASE_ONLY -> databaseUserService.findUserById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
            case CACHE_FIRST -> cachedUserService.findUserById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
            case DEFAULT -> defaultUserService.findUserById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + id));
        };
    }
}

/**
 * Conditional injection based on properties
 */
@Service
@RequiredArgsConstructor
@Slf4j
@ConditionalOnProperty(name = "app.features.advanced-search", havingValue = "true")
public class AdvancedSearchService {
    
    private final ElasticsearchService elasticsearchService;
    private final AnalyticsService analyticsService;
    
    public SearchResponse performAdvancedSearch(SearchCriteria criteria) {
        log.info("Performing advanced search with Elasticsearch");
        return elasticsearchService.search(criteria);
    }
}

@Service
@RequiredArgsConstructor
@Slf4j
@ConditionalOnProperty(name = "app.features.advanced-search", havingValue = "false", matchIfMissing = true)
public class BasicSearchService {
    
    private final ProductRepository productRepository;
    
    public SearchResponse performBasicSearch(SearchCriteria criteria) {
        log.info("Performing basic search with database");
        return productRepository.searchByCriteria(criteria);
    }
}
```

### 3. Configuration-Based Injection

```java
@Configuration
@EnableConfigurationProperties(AppProperties.class)
public class ServiceConfiguration {
    
    @Bean
    @ConditionalOnProperty(name = "app.payment.provider", havingValue = "stripe")
    public PaymentService stripePaymentService(StripeProperties stripeProperties) {
        return new StripePaymentService(stripeProperties);
    }
    
    @Bean
    @ConditionalOnProperty(name = "app.payment.provider", havingValue = "paypal")
    public PaymentService paypalPaymentService(PayPalProperties paypalProperties) {
        return new PayPalPaymentService(paypalProperties);
    }
    
    @Bean
    @ConditionalOnMissingBean(PaymentService.class)
    public PaymentService mockPaymentService() {
        return new MockPaymentService();
    }
    
    @Bean
    public NotificationService notificationService(
            AppProperties appProperties,
            @Autowired(required = false) EmailService emailService,
            @Autowired(required = false) SmsService smsService) {
        
        return NotificationService.builder()
            .emailService(emailService)
            .smsService(smsService)
            .emailEnabled(appProperties.getNotification().isEmailEnabled())
            .smsEnabled(appProperties.getNotification().isSmsEnabled())
            .build();
    }
}
```

## Service Composition and Orchestration

### 1. Service Orchestration Pattern

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class OrderOrchestrationService {
    
    private final OrderService orderService;
    private final PaymentService paymentService;
    private final InventoryService inventoryService;
    private final ShippingService shippingService;
    private final NotificationService notificationService;
    private final EventPublisher eventPublisher;
    
    /**
     * Orchestrates the complete order fulfillment process
     */
    @Transactional
    public OrderFulfillmentResult fulfillOrder(Long orderId) {
        log.info("Starting order fulfillment for order: {}", orderId);
        
        try {
            // 1. Retrieve order
            Order order = orderService.findById(orderId)
                .orElseThrow(() -> new OrderNotFoundException("Order not found: " + orderId));
            
            // 2. Validate order state
            validateOrderForFulfillment(order);
            
            // 3. Reserve inventory
            InventoryReservation reservation = inventoryService.reserveItems(order.getItems());
            
            // 4. Process payment
            PaymentResult payment = paymentService.capturePayment(order.getPaymentId());
            
            if (!payment.isSuccessful()) {
                inventoryService.releaseReservation(reservation.getId());
                throw new PaymentCaptureFailedException("Payment capture failed");
            }
            
            // 5. Create shipment
            Shipment shipment = shippingService.createShipment(order, reservation);
            
            // 6. Update order status
            order.markAsFulfilled(shipment.getTrackingNumber());
            orderService.save(order);
            
            // 7. Send notifications
            notificationService.sendFulfillmentNotification(order, shipment);
            
            // 8. Publish domain event
            eventPublisher.publishEvent(new OrderFulfilledEvent(order.getId(), shipment.getId()));
            
            log.info("Order fulfillment completed for order: {}", orderId);
            
            return OrderFulfillmentResult.success(order, shipment);
            
        } catch (Exception e) {
            log.error("Order fulfillment failed for order: {}", orderId, e);
            
            // Publish failure event
            eventPublisher.publishEvent(new OrderFulfillmentFailedEvent(orderId, e.getMessage()));
            
            throw new OrderFulfillmentException("Order fulfillment failed", e);
        }
    }
}
```

### 2. Saga Pattern for Distributed Transactions

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class BookingService {
    
    private final HotelService hotelService;
    private final FlightService flightService;
    private final CarRentalService carRentalService;
    private final PaymentService paymentService;
    private final SagaManager sagaManager;
    
    /**
     * Implements Saga pattern for distributed booking transaction
     */
    public BookingResult createBooking(BookingRequest request) {
        String sagaId = UUID.randomUUID().toString();
        
        try {
            Saga saga = Saga.builder()
                .sagaId(sagaId)
                .type("TRAVEL_BOOKING")
                .build();
                
            sagaManager.startSaga(saga);
            
            // Step 1: Reserve hotel
            HotelReservation hotelReservation = executeWithCompensation(
                () -> hotelService.reserveRoom(request.getHotelRequest()),
                (reservation) -> hotelService.cancelReservation(reservation.getId()),
                saga
            );
            
            // Step 2: Book flight
            FlightBooking flightBooking = executeWithCompensation(
                () -> flightService.bookFlight(request.getFlightRequest()),
                (booking) -> flightService.cancelBooking(booking.getId()),
                saga
            );
            
            // Step 3: Rent car
            CarRental carRental = executeWithCompensation(
                () -> carRentalService.rentCar(request.getCarRequest()),
                (rental) -> carRentalService.cancelRental(rental.getId()),
                saga
            );
            
            // Step 4: Process payment
            PaymentResult payment = executeWithCompensation(
                () -> paymentService.processPayment(calculateTotalAmount(hotelReservation, flightBooking, carRental)),
                (paymentResult) -> paymentService.refundPayment(paymentResult.getTransactionId()),
                saga
            );
            
            sagaManager.completeSaga(sagaId);
            
            return BookingResult.success(hotelReservation, flightBooking, carRental, payment);
            
        } catch (Exception e) {
            log.error("Booking failed, executing compensation", e);
            sagaManager.compensateSaga(sagaId);
            throw new BookingFailedException("Booking process failed", e);
        }
    }
    
    private <T> T executeWithCompensation(
            Supplier<T> action,
            Consumer<T> compensation,
            Saga saga) {
        
        try {
            T result = action.get();
            saga.addCompensationAction(() -> compensation.accept(result));
            return result;
        } catch (Exception e) {
            saga.executeCompensations();
            throw e;
        }
    }
}
```

## Async and Event-Driven Patterns

### 1. Asynchronous Service Operations

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {
    
    private final EmailTemplate emailTemplate;
    private final EmailSender emailSender;
    private final UserRepository userRepository;
    
    /**
     * Synchronous email sending for critical operations
     */
    public void sendWelcomeEmail(String email, String firstName) {
        log.info("Sending welcome email to: {}", email);
        
        String content = emailTemplate.generateWelcomeEmail(firstName);
        EmailMessage message = EmailMessage.builder()
            .to(email)
            .subject("Welcome!")
            .content(content)
            .build();
            
        emailSender.send(message);
    }
    
    /**
     * Asynchronous email sending for non-critical operations
     */
    @Async("emailTaskExecutor")
    public CompletableFuture<Void> sendWelcomeEmailAsync(String email, String firstName) {
        log.info("Sending welcome email asynchronously to: {}", email);
        
        try {
            sendWelcomeEmail(email, firstName);
            return CompletableFuture.completedFuture(null);
        } catch (Exception e) {
            log.error("Failed to send welcome email to: {}", email, e);
            return CompletableFuture.failedFuture(e);
        }
    }
    
    /**
     * Batch email processing
     */
    @Async("batchTaskExecutor")
    public CompletableFuture<BatchEmailResult> sendBatchEmails(List<EmailMessage> messages) {
        log.info("Processing batch of {} emails", messages.size());
        
        List<EmailResult> results = new ArrayList<>();
        
        for (EmailMessage message : messages) {
            try {
                emailSender.send(message);
                results.add(EmailResult.success(message.getTo()));
            } catch (Exception e) {
                log.warn("Failed to send email to: {}", message.getTo(), e);
                results.add(EmailResult.failure(message.getTo(), e.getMessage()));
            }
        }
        
        return CompletableFuture.completedFuture(
            BatchEmailResult.builder()
                .results(results)
                .totalSent(results.size())
                .build()
        );
    }
}

@Configuration
@EnableAsync
public class AsyncConfiguration {
    
    @Bean("emailTaskExecutor")
    public TaskExecutor emailTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("email-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
    
    @Bean("batchTaskExecutor")
    public TaskExecutor batchTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(3);
        executor.setMaxPoolSize(5);
        executor.setQueueCapacity(50);
        executor.setThreadNamePrefix("batch-");
        executor.initialize();
        return executor;
    }
}
```

### 2. Event-Driven Architecture

```java
/**
 * Domain events
 */
public abstract class DomainEvent {
    private final String eventId = UUID.randomUUID().toString();
    private final LocalDateTime occurredAt = LocalDateTime.now();
    
    // Getters
}

@Value
@EqualsAndHashCode(callSuper = true)
public class UserRegisteredEvent extends DomainEvent {
    Long userId;
    String email;
    String firstName;
    LocalDateTime registrationTime;
}

@Value
@EqualsAndHashCode(callSuper = true)
public class OrderCreatedEvent extends DomainEvent {
    Long orderId;
    Long customerId;
    BigDecimal totalAmount;
    List<Long> productIds;
}

/**
 * Event publishing service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    
    private final UserRepository userRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final PasswordEncoder passwordEncoder;
    
    @Transactional
    public UserResponse registerUser(UserRegistrationRequest request) {
        // Create user
        User user = User.builder()
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .email(request.getEmail())
            .password(passwordEncoder.encode(request.getPassword()))
            .status(UserStatus.PENDING_VERIFICATION)
            .registrationTime(LocalDateTime.now())
            .build();
            
        User savedUser = userRepository.save(user);
        
        // Publish domain event
        UserRegisteredEvent event = new UserRegisteredEvent(
            savedUser.getId(),
            savedUser.getEmail(),
            savedUser.getFirstName(),
            savedUser.getRegistrationTime()
        );
        
        eventPublisher.publishEvent(event);
        
        log.info("User registered and event published: {}", savedUser.getId());
        return userMapper.toResponse(savedUser);
    }
}

/**
 * Event listeners
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class UserEventHandler {
    
    private final EmailService emailService;
    private final AuditService auditService;
    private final AnalyticsService analyticsService;
    
    @EventListener
    @Async
    public void handleUserRegistered(UserRegisteredEvent event) {
        log.info("Handling user registered event: {}", event.getUserId());
        
        // Send welcome email
        emailService.sendWelcomeEmailAsync(event.getEmail(), event.getFirstName());
        
        // Log audit event
        auditService.logUserRegistration(event.getUserId(), event.getRegistrationTime());
        
        // Track analytics
        analyticsService.trackUserRegistration(event.getUserId());
    }
    
    @EventListener
    @Async
    public void handleOrderCreated(OrderCreatedEvent event) {
        log.info("Handling order created event: {}", event.getOrderId());
        
        // Update customer statistics
        analyticsService.updateCustomerStats(event.getCustomerId(), event.getTotalAmount());
        
        // Update product popularity
        analyticsService.updateProductPopularity(event.getProductIds());
        
        // Trigger recommendation engine
        analyticsService.triggerRecommendationUpdate(event.getCustomerId());
    }
}
```

## Testing Service Layer

### 1. Unit Testing

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository userRepository;
    
    @Mock
    private PasswordEncoder passwordEncoder;
    
    @Mock
    private EmailService emailService;
    
    @Mock
    private UserMapper userMapper;
    
    @InjectMocks
    private UserServiceImpl userService;
    
    @Test
    void shouldCreateUserWhenValidDataProvided() {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .firstName("John")
            .lastName("Doe")
            .email("john@example.com")
            .password("password123")
            .build();
            
        User savedUser = User.builder()
            .id(1L)
            .firstName("John")
            .lastName("Doe")
            .email("john@example.com")
            .password("encoded-password")
            .status(UserStatus.PENDING_VERIFICATION)
            .build();
            
        UserResponse expectedResponse = UserResponse.builder()
            .id(1L)
            .firstName("John")
            .lastName("Doe")
            .email("john@example.com")
            .status("PENDING_VERIFICATION")
            .build();
        
        when(userRepository.existsByEmail("john@example.com")).thenReturn(false);
        when(passwordEncoder.encode("password123")).thenReturn("encoded-password");
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(savedUser)).thenReturn(expectedResponse);
        
        // When
        UserResponse result = userService.createUser(request);
        
        // Then
        assertThat(result).isEqualTo(expectedResponse);
        verify(userRepository).existsByEmail("john@example.com");
        verify(passwordEncoder).encode("password123");
        verify(userRepository).save(any(User.class));
        verify(emailService).sendVerificationEmail(eq("john@example.com"), any());
    }
    
    @Test
    void shouldThrowExceptionWhenEmailAlreadyExists() {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .email("existing@example.com")
            .build();
            
        when(userRepository.existsByEmail("existing@example.com")).thenReturn(true);
        
        // When & Then
        assertThatThrownBy(() -> userService.createUser(request))
            .isInstanceOf(UserAlreadyExistsException.class)
            .hasMessageContaining("User with email already exists");
            
        verify(userRepository).existsByEmail("existing@example.com");
        verify(userRepository, never()).save(any());
    }
}
```

### 2. Integration Testing

```java
@SpringBootTest
@Transactional
@ActiveProfiles("test")
class UserServiceIntegrationTest {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Test
    void shouldCreateUserWithAllDependencies() {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .firstName("Jane")
            .lastName("Smith")
            .email("jane@example.com")
            .password("password123")
            .build();
        
        // When
        UserResponse result = userService.createUser(request);
        
        // Then
        assertThat(result.getId()).isNotNull();
        assertThat(result.getFirstName()).isEqualTo("Jane");
        assertThat(result.getEmail()).isEqualTo("jane@example.com");
        
        // Verify persistence
        Optional<User> savedUser = userRepository.findById(result.getId());
        assertThat(savedUser).isPresent();
        assertThat(savedUser.get().getPassword()).isNotEqualTo("password123"); // Should be encoded
    }
}
```

## Summary

Service layer architecture best practices:

1. **Clear Responsibilities** - Business logic, transaction management, service coordination
2. **Interface-Based Design** - Use interfaces for loose coupling and testability
3. **Transaction Management** - Use declarative transactions with proper boundaries
4. **Constructor Injection** - Immutable dependencies with Lombok `@RequiredArgsConstructor`
5. **Domain Services** - Separate complex business logic from CRUD operations
6. **Event-Driven Patterns** - Decouple services using domain events
7. **Async Operations** - Use async processing for non-critical operations
8. **Comprehensive Testing** - Unit and integration tests for all service methods

Next: [DTO Mapping & Data Transfer](dto-mapping)