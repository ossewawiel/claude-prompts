# Async Operations & Multithreading

## Overview

Modern Spring Boot applications require efficient handling of concurrent operations, async processing, and multithreading. This document covers async patterns, thread pool configuration, reactive programming, and best practices for Java 11 and Spring Boot 2.7.

## Async Configuration

### 1. Basic Async Setup

```java
@Configuration
@EnableAsync
@Slf4j
public class AsyncConfiguration implements AsyncConfigurer {
    
    @Override
    @Bean("taskExecutor")
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(20);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("async-");
        executor.setKeepAliveSeconds(60);
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.setAwaitTerminationSeconds(30);
        
        // Rejection policy when queue is full
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        
        // Thread factory for better thread management
        executor.setThreadFactory(r -> {
            Thread thread = new Thread(r);
            thread.setDaemon(false);
            thread.setUncaughtExceptionHandler((t, e) -> 
                log.error("Uncaught exception in async thread {}: {}", t.getName(), e.getMessage(), e));
            return thread;
        });
        
        executor.initialize();
        return executor;
    }
    
    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return new CustomAsyncExceptionHandler();
    }
    
    @Bean("emailTaskExecutor")
    public TaskExecutor emailTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(3);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(50);
        executor.setThreadNamePrefix("email-");
        executor.initialize();
        return executor;
    }
    
    @Bean("reportTaskExecutor")
    public TaskExecutor reportTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(5);
        executor.setQueueCapacity(25);
        executor.setThreadNamePrefix("report-");
        executor.initialize();
        return executor;
    }
}

/**
 * Custom exception handler for async operations
 */
@Slf4j
public class CustomAsyncExceptionHandler implements AsyncUncaughtExceptionHandler {
    
    @Override
    public void handleUncaughtException(Throwable throwable, Method method, Object... objects) {
        log.error("Async method {} failed with parameters: {}", 
            method.getName(), Arrays.toString(objects), throwable);
            
        // Send notification to monitoring system
        // Could integrate with metrics, alerting, etc.
    }
}
```

### 2. Advanced Thread Pool Configuration

```java
@Configuration
@ConfigurationProperties(prefix = "app.async")
@Data
public class AsyncProperties {
    
    private ThreadPool defaultPool = new ThreadPool();
    private ThreadPool emailPool = new ThreadPool();
    private ThreadPool reportPool = new ThreadPool();
    private ThreadPool heavyPool = new ThreadPool();
    
    @Data
    public static class ThreadPool {
        private int coreSize = 5;
        private int maxSize = 20;
        private int queueCapacity = 100;
        private int keepAliveSeconds = 60;
        private String threadNamePrefix = "async-";
        private boolean waitForTasksToCompleteOnShutdown = true;
        private int awaitTerminationSeconds = 30;
    }
}

@Configuration
@EnableAsync
@EnableConfigurationProperties(AsyncProperties.class)
@RequiredArgsConstructor
public class AdvancedAsyncConfiguration {
    
    private final AsyncProperties asyncProperties;
    
    @Bean("defaultTaskExecutor")
    @Primary
    public TaskExecutor defaultTaskExecutor() {
        return createTaskExecutor(asyncProperties.getDefaultPool());
    }
    
    @Bean("emailTaskExecutor")
    public TaskExecutor emailTaskExecutor() {
        return createTaskExecutor(asyncProperties.getEmailPool());
    }
    
    @Bean("reportTaskExecutor") 
    public TaskExecutor reportTaskExecutor() {
        return createTaskExecutor(asyncProperties.getReportPool());
    }
    
    @Bean("heavyTaskExecutor")
    public TaskExecutor heavyTaskExecutor() {
        AsyncProperties.ThreadPool config = asyncProperties.getHeavyPool();
        config.setCoreSize(2); // Override for heavy tasks
        config.setMaxSize(4);
        return createTaskExecutor(config);
    }
    
    private TaskExecutor createTaskExecutor(AsyncProperties.ThreadPool config) {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(config.getCoreSize());
        executor.setMaxPoolSize(config.getMaxSize());
        executor.setQueueCapacity(config.getQueueCapacity());
        executor.setKeepAliveSeconds(config.getKeepAliveSeconds());
        executor.setThreadNamePrefix(config.getThreadNamePrefix());
        executor.setWaitForTasksToCompleteOnShutdown(config.isWaitForTasksToCompleteOnShutdown());
        executor.setAwaitTerminationSeconds(config.getAwaitTerminationSeconds());
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
}
```

## Async Service Patterns

### 1. Basic Async Operations

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {
    
    private final EmailSender emailSender;
    private final SmsSender smsSender;
    private final NotificationRepository notificationRepository;
    
    /**
     * Fire-and-forget async operation
     */
    @Async("emailTaskExecutor")
    public void sendWelcomeEmailAsync(String email, String firstName) {
        log.info("Sending welcome email asynchronously to: {}", email);
        
        try {
            EmailTemplate template = EmailTemplate.builder()
                .to(email)
                .subject("Welcome!")
                .template("welcome")
                .variable("firstName", firstName)
                .build();
                
            emailSender.send(template);
            
            // Log successful notification
            saveNotificationLog(email, "WELCOME_EMAIL", "SUCCESS");
            
        } catch (Exception e) {
            log.error("Failed to send welcome email to: {}", email, e);
            saveNotificationLog(email, "WELCOME_EMAIL", "FAILED");
            throw new AsyncNotificationException("Welcome email failed", e);
        }
    }
    
    /**
     * Async operation with return value
     */
    @Async("emailTaskExecutor")
    public CompletableFuture<NotificationResult> sendOrderConfirmationAsync(OrderConfirmationRequest request) {
        log.info("Sending order confirmation async for order: {}", request.getOrderId());
        
        try {
            // Send email
            EmailResult emailResult = emailSender.send(buildOrderEmail(request));
            
            // Send SMS if phone number provided
            SmsResult smsResult = null;
            if (request.getPhoneNumber() != null) {
                smsResult = smsSender.send(buildOrderSms(request));
            }
            
            NotificationResult result = NotificationResult.builder()
                .emailSent(emailResult.isSuccess())
                .smsSent(smsResult != null && smsResult.isSuccess())
                .orderId(request.getOrderId())
                .timestamp(LocalDateTime.now())
                .build();
                
            saveNotificationLog(request.getEmail(), "ORDER_CONFIRMATION", "SUCCESS");
            
            return CompletableFuture.completedFuture(result);
            
        } catch (Exception e) {
            log.error("Failed to send order confirmation for order: {}", request.getOrderId(), e);
            saveNotificationLog(request.getEmail(), "ORDER_CONFIRMATION", "FAILED");
            return CompletableFuture.failedFuture(e);
        }
    }
    
    /**
     * Conditional async execution
     */
    @Async("emailTaskExecutor")
    @ConditionalOnProperty(name = "app.notifications.email.enabled", havingValue = "true")
    public CompletableFuture<Void> sendMarketingEmailAsync(String email, String campaign) {
        log.info("Sending marketing email for campaign: {}", campaign);
        
        // Check user preferences first
        if (!isUserOptedInForMarketing(email)) {
            log.info("User {} not opted in for marketing emails", email);
            return CompletableFuture.completedFuture(null);
        }
        
        try {
            emailSender.send(buildMarketingEmail(email, campaign));
            return CompletableFuture.completedFuture(null);
        } catch (Exception e) {
            log.error("Marketing email failed for {}: {}", email, e.getMessage());
            return CompletableFuture.failedFuture(e);
        }
    }
    
    private void saveNotificationLog(String recipient, String type, String status) {
        // Save asynchronously to avoid blocking
        CompletableFuture.runAsync(() -> {
            NotificationLog log = NotificationLog.builder()
                .recipient(recipient)
                .type(type)
                .status(status)
                .timestamp(LocalDateTime.now())
                .build();
            notificationRepository.save(log);
        });
    }
}
```

### 2. Async Data Processing

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class DataProcessingService {
    
    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final ReportGenerator reportGenerator;
    private final FileStorageService fileStorageService;
    
    /**
     * Parallel data processing with CompletableFuture
     */
    @Async("reportTaskExecutor")
    public CompletableFuture<MonthlyReport> generateMonthlyReportAsync(YearMonth yearMonth) {
        log.info("Generating monthly report for: {}", yearMonth);
        
        LocalDateTime startDate = yearMonth.atDay(1).atStartOfDay();
        LocalDateTime endDate = yearMonth.atEndOfMonth().atTime(23, 59, 59);
        
        // Execute multiple queries in parallel
        CompletableFuture<List<User>> usersFuture = CompletableFuture.supplyAsync(() -> 
            userRepository.findByCreatedAtBetween(startDate, endDate));
            
        CompletableFuture<List<Order>> ordersFuture = CompletableFuture.supplyAsync(() -> 
            orderRepository.findByCreatedAtBetween(startDate, endDate));
            
        CompletableFuture<BigDecimal> revenueFuture = CompletableFuture.supplyAsync(() -> 
            orderRepository.sumTotalAmountByCreatedAtBetween(startDate, endDate));
        
        // Combine results
        return CompletableFuture.allOf(usersFuture, ordersFuture, revenueFuture)
            .thenApply(ignored -> {
                List<User> users = usersFuture.join();
                List<Order> orders = ordersFuture.join();
                BigDecimal revenue = revenueFuture.join();
                
                return MonthlyReport.builder()
                    .yearMonth(yearMonth)
                    .newUsersCount(users.size())
                    .ordersCount(orders.size())
                    .totalRevenue(revenue)
                    .generatedAt(LocalDateTime.now())
                    .build();
            })
            .exceptionally(throwable -> {
                log.error("Failed to generate monthly report for {}: {}", yearMonth, throwable.getMessage());
                throw new ReportGenerationException("Monthly report generation failed", throwable);
            });
    }
    
    /**
     * Batch processing with parallel streams
     */
    @Async("heavyTaskExecutor")
    public CompletableFuture<BatchProcessingResult> processBatchDataAsync(List<DataRecord> records) {
        log.info("Processing batch of {} records", records.size());
        
        int batchSize = 100;
        List<List<DataRecord>> batches = partitionList(records, batchSize);
        
        List<CompletableFuture<BatchResult>> futures = batches.stream()
            .map(batch -> CompletableFuture.supplyAsync(() -> processBatch(batch)))
            .collect(Collectors.toList());
        
        return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
            .thenApply(ignored -> {
                List<BatchResult> results = futures.stream()
                    .map(CompletableFuture::join)
                    .collect(Collectors.toList());
                
                return BatchProcessingResult.builder()
                    .totalRecords(records.size())
                    .successfulBatches(results.size())
                    .results(results)
                    .build();
            });
    }
    
    /**
     * Pipeline processing with async stages
     */
    @Async("heavyTaskExecutor")
    public CompletableFuture<ProcessingResult> processDataPipelineAsync(String inputFilePath) {
        log.info("Starting data pipeline for file: {}", inputFilePath);
        
        return CompletableFuture
            // Stage 1: Read and validate file
            .supplyAsync(() -> readAndValidateFile(inputFilePath))
            // Stage 2: Transform data
            .thenCompose(this::transformDataAsync)
            // Stage 3: Enrich data
            .thenCompose(this::enrichDataAsync)
            // Stage 4: Save results
            .thenCompose(this::saveProcessedDataAsync)
            // Handle errors
            .exceptionally(throwable -> {
                log.error("Data pipeline failed for file {}: {}", inputFilePath, throwable.getMessage());
                return ProcessingResult.failed(throwable.getMessage());
            });
    }
    
    private CompletableFuture<TransformedData> transformDataAsync(RawData rawData) {
        return CompletableFuture.supplyAsync(() -> {
            log.debug("Transforming {} records", rawData.getRecords().size());
            // Heavy transformation logic here
            return new TransformedData(rawData);
        });
    }
    
    private CompletableFuture<EnrichedData> enrichDataAsync(TransformedData transformedData) {
        return CompletableFuture.supplyAsync(() -> {
            log.debug("Enriching {} records", transformedData.getRecords().size());
            // Data enrichment logic here
            return new EnrichedData(transformedData);
        });
    }
    
    private CompletableFuture<ProcessingResult> saveProcessedDataAsync(EnrichedData enrichedData) {
        return CompletableFuture.supplyAsync(() -> {
            log.debug("Saving {} processed records", enrichedData.getRecords().size());
            // Save to database or file system
            return ProcessingResult.success(enrichedData.getRecords().size());
        });
    }
}
```

### 3. Async Event Processing

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class EventProcessingService {
    
    private final ApplicationEventPublisher eventPublisher;
    private final UserService userService;
    private final NotificationService notificationService;
    private final AnalyticsService analyticsService;
    
    /**
     * Async event listener
     */
    @EventListener
    @Async("defaultTaskExecutor")
    public void handleUserRegisteredEvent(UserRegisteredEvent event) {
        log.info("Processing user registered event async: {}", event.getUserId());
        
        try {
            // Send welcome email
            notificationService.sendWelcomeEmailAsync(event.getEmail(), event.getFirstName());
            
            // Update analytics
            analyticsService.trackUserRegistration(event.getUserId());
            
            // Create user profile
            createUserProfileAsync(event.getUserId());
            
        } catch (Exception e) {
            log.error("Failed to process user registered event for user {}: {}", 
                event.getUserId(), e.getMessage(), e);
        }
    }
    
    /**
     * Parallel event processing
     */
    @EventListener
    @Async("defaultTaskExecutor")
    public void handleOrderCreatedEvent(OrderCreatedEvent event) {
        log.info("Processing order created event async: {}", event.getOrderId());
        
        // Process multiple operations in parallel
        CompletableFuture<Void> inventoryUpdate = CompletableFuture.runAsync(() -> 
            updateInventoryAsync(event.getOrderId()));
            
        CompletableFuture<Void> customerUpdate = CompletableFuture.runAsync(() -> 
            updateCustomerStatsAsync(event.getCustomerId()));
            
        CompletableFuture<Void> analyticsUpdate = CompletableFuture.runAsync(() -> 
            updateAnalyticsAsync(event.getOrderId()));
        
        // Wait for all operations to complete
        CompletableFuture.allOf(inventoryUpdate, customerUpdate, analyticsUpdate)
            .thenRun(() -> log.info("Order event processing completed for order: {}", event.getOrderId()))
            .exceptionally(throwable -> {
                log.error("Order event processing failed for order {}: {}", 
                    event.getOrderId(), throwable.getMessage());
                return null;
            });
    }
    
    @Async("defaultTaskExecutor")
    private void createUserProfileAsync(Long userId) {
        try {
            Thread.sleep(500); // Simulate processing time
            log.debug("User profile created for user: {}", userId);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("User profile creation interrupted", e);
        }
    }
}
```

## Thread Safety and Synchronization

### 1. Thread-Safe Service Components

```java
@Service
@Slf4j
public class CounterService {
    
    // Thread-safe atomic operations
    private final AtomicLong requestCounter = new AtomicLong(0);
    private final AtomicReference<LocalDateTime> lastResetTime = new AtomicReference<>(LocalDateTime.now());
    
    // Thread-safe collections
    private final ConcurrentHashMap<String, AtomicLong> userCounters = new ConcurrentHashMap<>();
    private final ConcurrentLinkedQueue<RequestEvent> recentEvents = new ConcurrentLinkedQueue<>();
    
    // ReadWriteLock for scenarios with many readers, few writers
    private final ReadWriteLock statsLock = new ReentrantReadWriteLock();
    private final Map<String, Object> stats = new HashMap<>();
    
    public long incrementAndGetRequestCount() {
        return requestCounter.incrementAndGet();
    }
    
    public long getUserRequestCount(String userId) {
        return userCounters.computeIfAbsent(userId, k -> new AtomicLong(0))
            .incrementAndGet();
    }
    
    public void addRecentEvent(RequestEvent event) {
        recentEvents.offer(event);
        
        // Keep only last 1000 events
        while (recentEvents.size() > 1000) {
            recentEvents.poll();
        }
    }
    
    public Map<String, Object> getStats() {
        statsLock.readLock().lock();
        try {
            return new HashMap<>(stats);
        } finally {
            statsLock.readLock().unlock();
        }
    }
    
    public void updateStats(String key, Object value) {
        statsLock.writeLock().lock();
        try {
            stats.put(key, value);
        } finally {
            statsLock.writeLock().unlock();
        }
    }
    
    @Scheduled(fixedRate = 60000) // Every minute
    public void resetDailyCountersIfNeeded() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime lastReset = lastResetTime.get();
        
        if (!now.toLocalDate().equals(lastReset.toLocalDate())) {
            if (lastResetTime.compareAndSet(lastReset, now)) {
                log.info("Resetting daily counters");
                requestCounter.set(0);
                userCounters.clear();
            }
        }
    }
}
```

### 2. Synchronized Operations

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class InventoryService {
    
    private final InventoryRepository inventoryRepository;
    
    // Object-level locking for fine-grained synchronization
    private final ConcurrentHashMap<Long, Object> productLocks = new ConcurrentHashMap<>();
    
    /**
     * Thread-safe inventory update with product-level locking
     */
    public void updateInventory(Long productId, int quantityChange) {
        Object lock = productLocks.computeIfAbsent(productId, k -> new Object());
        
        synchronized (lock) {
            log.debug("Updating inventory for product {} by {}", productId, quantityChange);
            
            Inventory inventory = inventoryRepository.findByProductIdForUpdate(productId)
                .orElseThrow(() -> new InventoryNotFoundException("Inventory not found for product: " + productId));
            
            int newQuantity = inventory.getQuantity() + quantityChange;
            
            if (newQuantity < 0) {
                throw new InsufficientInventoryException("Insufficient inventory for product: " + productId);
            }
            
            inventory.setQuantity(newQuantity);
            inventory.setLastUpdated(LocalDateTime.now());
            
            inventoryRepository.save(inventory);
            
            log.info("Inventory updated for product {}: {} -> {}", 
                productId, inventory.getQuantity() - quantityChange, newQuantity);
        }
        
        // Clean up locks for unused products periodically
        if (productLocks.size() > 10000) {
            cleanupUnusedLocks();
        }
    }
    
    /**
     * Bulk inventory update with proper ordering to prevent deadlocks
     */
    public void updateInventoryBulk(Map<Long, Integer> updates) {
        // Sort product IDs to prevent deadlocks
        List<Long> sortedProductIds = updates.keySet().stream()
            .sorted()
            .collect(Collectors.toList());
        
        for (Long productId : sortedProductIds) {
            updateInventory(productId, updates.get(productId));
        }
    }
    
    @Scheduled(fixedRate = 300000) // Every 5 minutes
    private void cleanupUnusedLocks() {
        if (productLocks.size() > 1000) {
            log.info("Cleaning up unused product locks, current size: {}", productLocks.size());
            // In a real implementation, you'd track which locks are actually in use
            // For this example, we'll just clear old locks periodically
        }
    }
}
```

## Reactive Programming with WebFlux

### 1. Reactive Service Implementation

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class ReactiveUserService {
    
    private final ReactiveUserRepository userRepository;
    private final ReactiveEmailService emailService;
    private final UserMapper userMapper;
    
    /**
     * Reactive user creation
     */
    public Mono<UserResponse> createUser(CreateUserRequest request) {
        log.info("Creating user reactively: {}", request.getEmail());
        
        return userRepository.existsByEmail(request.getEmail())
            .flatMap(exists -> {
                if (exists) {
                    return Mono.error(new UserAlreadyExistsException("User already exists: " + request.getEmail()));
                }
                
                User user = userMapper.toEntity(request);
                user.setCreatedAt(LocalDateTime.now());
                
                return userRepository.save(user);
            })
            .flatMap(savedUser -> {
                // Send welcome email asynchronously
                return emailService.sendWelcomeEmail(savedUser.getEmail(), savedUser.getFirstName())
                    .then(Mono.just(savedUser));
            })
            .map(userMapper::toResponse)
            .doOnSuccess(response -> log.info("User created successfully: {}", response.getId()))
            .doOnError(error -> log.error("Failed to create user: {}", error.getMessage()));
    }
    
    /**
     * Reactive search with pagination
     */
    public Flux<UserResponse> searchUsers(UserSearchCriteria criteria) {
        log.debug("Searching users reactively with criteria: {}", criteria);
        
        return userRepository.findBySearchCriteria(criteria)
            .map(userMapper::toResponse)
            .onErrorResume(error -> {
                log.error("Error during user search: {}", error.getMessage());
                return Flux.empty();
            });
    }
    
    /**
     * Reactive parallel processing
     */
    public Flux<UserProcessingResult> processUsersInParallel(List<Long> userIds) {
        return Flux.fromIterable(userIds)
            .flatMap(this::processUserReactively, 10) // Process max 10 in parallel
            .onErrorContinue((error, userId) -> 
                log.error("Failed to process user {}: {}", userId, error.getMessage()));
    }
    
    private Mono<UserProcessingResult> processUserReactively(Long userId) {
        return userRepository.findById(userId)
            .flatMap(user -> {
                // Simulate processing
                return Mono.fromCallable(() -> {
                    // Some processing logic
                    return UserProcessingResult.success(userId);
                }).subscribeOn(Schedulers.boundedElastic());
            })
            .switchIfEmpty(Mono.just(UserProcessingResult.notFound(userId)));
    }
}
```

### 2. Reactive Event Streaming

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class ReactiveEventService {
    
    private final Sinks.Many<DomainEvent> eventSink = Sinks.many().multicast().onBackpressureBuffer();
    
    /**
     * Publish events reactively
     */
    public void publishEvent(DomainEvent event) {
        log.debug("Publishing event: {}", event.getClass().getSimpleName());
        
        Sinks.EmitResult result = eventSink.tryEmitNext(event);
        
        if (result.isFailure()) {
            log.warn("Failed to publish event: {}", result);
            // Could retry or handle failure
        }
    }
    
    /**
     * Get event stream
     */
    public Flux<DomainEvent> getEventStream() {
        return eventSink.asFlux()
            .doOnSubscribe(subscription -> log.info("New event stream subscriber"))
            .doOnCancel(() -> log.info("Event stream subscription cancelled"));
    }
    
    /**
     * Filtered event streams
     */
    public Flux<UserEvent> getUserEventStream() {
        return getEventStream()
            .filter(event -> event instanceof UserEvent)
            .cast(UserEvent.class)
            .doOnNext(event -> log.debug("User event: {}", event));
    }
    
    /**
     * Reactive event processing with backpressure handling
     */
    @PostConstruct
    public void startEventProcessing() {
        getEventStream()
            .onBackpressureBuffer(1000) // Buffer up to 1000 events
            .groupBy(event -> event.getClass())
            .flatMap(groupedFlux -> 
                groupedFlux.bufferTimeout(100, Duration.ofSeconds(5)) // Batch events
                    .flatMap(this::processBatchedEvents)
            )
            .subscribe(
                result -> log.debug("Event processing result: {}", result),
                error -> log.error("Event processing error: {}", error.getMessage())
            );
    }
    
    private Mono<String> processBatchedEvents(List<DomainEvent> events) {
        return Mono.fromCallable(() -> {
            log.info("Processing batch of {} events", events.size());
            // Process batch
            return "Processed " + events.size() + " events";
        }).subscribeOn(Schedulers.boundedElastic());
    }
}
```

## Performance Monitoring and Metrics

### 1. Async Performance Monitoring

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class AsyncMonitoringService {
    
    private final MeterRegistry meterRegistry;
    private final Timer.Sample sample;
    
    // Metrics for async operations
    private final Counter asyncOperationsStarted;
    private final Counter asyncOperationsCompleted;
    private final Counter asyncOperationsFailed;
    private final Timer asyncOperationDuration;
    
    @PostConstruct
    public void initMetrics() {
        asyncOperationsStarted = Counter.builder("async.operations.started")
            .description("Number of async operations started")
            .register(meterRegistry);
            
        asyncOperationsCompleted = Counter.builder("async.operations.completed")
            .description("Number of async operations completed successfully")
            .register(meterRegistry);
            
        asyncOperationsFailed = Counter.builder("async.operations.failed")
            .description("Number of async operations that failed")
            .register(meterRegistry);
            
        asyncOperationDuration = Timer.builder("async.operations.duration")
            .description("Duration of async operations")
            .register(meterRegistry);
    }
    
    /**
     * Monitored async operation
     */
    @Async("monitoredTaskExecutor")
    public CompletableFuture<String> performMonitoredAsyncOperation(String input) {
        Timer.Sample sample = Timer.start(meterRegistry);
        asyncOperationsStarted.increment();
        
        try {
            // Simulate async work
            Thread.sleep(1000);
            
            asyncOperationsCompleted.increment();
            sample.stop(asyncOperationDuration);
            
            return CompletableFuture.completedFuture("Processed: " + input);
            
        } catch (Exception e) {
            asyncOperationsFailed.increment();
            sample.stop(asyncOperationDuration);
            
            return CompletableFuture.failedFuture(e);
        }
    }
    
    /**
     * Thread pool monitoring
     */
    @Bean
    public TaskExecutor monitoredTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(5);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(25);
        executor.setThreadNamePrefix("monitored-");
        
        // Add monitoring
        executor.setTaskDecorator(new MonitoringTaskDecorator());
        
        executor.initialize();
        
        // Register metrics
        registerThreadPoolMetrics(executor, "monitored");
        
        return executor;
    }
    
    private void registerThreadPoolMetrics(ThreadPoolTaskExecutor executor, String name) {
        Gauge.builder("thread.pool.active")
            .tag("pool", name)
            .description("Active threads in pool")
            .register(meterRegistry, executor, e -> e.getActiveCount());
            
        Gauge.builder("thread.pool.size")
            .tag("pool", name)
            .description("Current pool size")
            .register(meterRegistry, executor, e -> e.getPoolSize());
            
        Gauge.builder("thread.pool.queue.size")
            .tag("pool", name)
            .description("Queue size")
            .register(meterRegistry, executor, e -> e.getThreadPoolExecutor().getQueue().size());
            
        Gauge.builder("thread.pool.completed.tasks")
            .tag("pool", name)
            .description("Completed tasks")
            .register(meterRegistry, executor, e -> e.getThreadPoolExecutor().getCompletedTaskCount());
    }
    
    /**
     * Task decorator for monitoring individual tasks
     */
    private static class MonitoringTaskDecorator implements TaskDecorator {
        @Override
        public Runnable decorate(Runnable runnable) {
            return () -> {
                String threadName = Thread.currentThread().getName();
                long startTime = System.currentTimeMillis();
                
                try {
                    runnable.run();
                } finally {
                    long duration = System.currentTimeMillis() - startTime;
                    log.debug("Task completed in thread {} after {}ms", threadName, duration);
                }
            };
        }
    }
}
```

## Error Handling in Async Operations

### 1. Async Exception Handling

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class ResilientAsyncService {
    
    private final RetryTemplate retryTemplate;
    private final CircuitBreaker circuitBreaker;
    
    /**
     * Async operation with retry logic
     */
    @Async("resilientTaskExecutor")
    public CompletableFuture<String> resilientAsyncOperation(String input) {
        return CompletableFuture.supplyAsync(() -> {
            return retryTemplate.execute(context -> {
                log.debug("Attempt {} for input: {}", context.getRetryCount() + 1, input);
                
                // Simulate operation that might fail
                if (Math.random() < 0.3) { // 30% failure rate
                    throw new RuntimeException("Random failure");
                }
                
                return "Processed: " + input;
            });
        }).exceptionally(throwable -> {
            log.error("Resilient async operation failed for input {}: {}", input, throwable.getMessage());
            return "Failed: " + input;
        });
    }
    
    /**
     * Async operation with circuit breaker
     */
    @Async("resilientTaskExecutor")
    public CompletableFuture<String> circuitBreakerAsyncOperation(String input) {
        return CompletableFuture.supplyAsync(() -> {
            return circuitBreaker.executeSupplier(() -> {
                // Call external service
                return callExternalService(input);
            });
        }).exceptionally(throwable -> {
            if (throwable.getCause() instanceof CallNotPermittedException) {
                log.warn("Circuit breaker is open, operation not permitted for input: {}", input);
                return "Circuit breaker open";
            } else {
                log.error("Circuit breaker operation failed for input {}: {}", input, throwable.getMessage());
                return "Failed: " + input;
            }
        });
    }
    
    /**
     * Timeout handling for async operations
     */
    @Async("timeoutTaskExecutor")
    public CompletableFuture<String> timeoutAsyncOperation(String input) {
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            try {
                // Simulate long-running operation
                Thread.sleep(5000);
                return "Completed: " + input;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new RuntimeException("Operation interrupted", e);
            }
        });
        
        // Add timeout
        return future.orTimeout(3, TimeUnit.SECONDS)
            .exceptionally(throwable -> {
                if (throwable instanceof TimeoutException) {
                    log.warn("Async operation timed out for input: {}", input);
                    return "Timeout: " + input;
                } else {
                    log.error("Async operation failed for input {}: {}", input, throwable.getMessage());
                    return "Failed: " + input;
                }
            });
    }
    
    private String callExternalService(String input) {
        // Simulate external service call
        if (Math.random() < 0.2) { // 20% failure rate
            throw new RuntimeException("External service failure");
        }
        return "External result: " + input;
    }
}

/**
 * Retry configuration
 */
@Configuration
public class ResilienceConfiguration {
    
    @Bean
    public RetryTemplate retryTemplate() {
        return RetryTemplate.builder()
            .maxAttempts(3)
            .exponentialBackoff(1000, 2, 10000)
            .retryOn(RuntimeException.class)
            .build();
    }
    
    @Bean
    public CircuitBreaker circuitBreaker() {
        return CircuitBreaker.ofDefaults("asyncService");
    }
    
    @Bean("resilientTaskExecutor")
    public TaskExecutor resilientTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(3);
        executor.setMaxPoolSize(10);
        executor.setQueueCapacity(50);
        executor.setThreadNamePrefix("resilient-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
    
    @Bean("timeoutTaskExecutor")
    public TaskExecutor timeoutTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(5);
        executor.setQueueCapacity(25);
        executor.setThreadNamePrefix("timeout-");
        executor.initialize();
        return executor;
    }
}
```

### 2. Async Transaction Management

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class AsyncTransactionService {
    
    private final TransactionTemplate transactionTemplate;
    private final PlatformTransactionManager transactionManager;
    private final OrderRepository orderRepository;
    private final PaymentService paymentService;
    
    /**
     * Async operation with transaction boundaries
     */
    @Async("transactionalTaskExecutor")
    public CompletableFuture<OrderResult> processOrderAsync(OrderRequest request) {
        return CompletableFuture.supplyAsync(() -> {
            return transactionTemplate.execute(status -> {
                try {
                    log.info("Processing order async in transaction: {}", request.getId());
                    
                    // Create order
                    Order order = createOrder(request);
                    
                    // Process payment
                    PaymentResult payment = paymentService.processPayment(order.getTotalAmount());
                    
                    if (!payment.isSuccessful()) {
                        // Mark transaction for rollback
                        status.setRollbackOnly();
                        throw new PaymentFailedException("Payment failed: " + payment.getFailureReason());
                    }
                    
                    // Update order status
                    order.markAsPaid(payment.getTransactionId());
                    orderRepository.save(order);
                    
                    return OrderResult.success(order.getId());
                    
                } catch (Exception e) {
                    log.error("Order processing failed: {}", e.getMessage());
                    status.setRollbackOnly();
                    throw e;
                }
            });
        }).exceptionally(throwable -> {
            log.error("Async order processing failed: {}", throwable.getMessage());
            return OrderResult.failure(throwable.getMessage());
        });
    }
    
    /**
     * Async batch processing with individual transactions
     */
    @Async("batchTaskExecutor")
    public CompletableFuture<BatchResult> processBatchAsync(List<BatchItem> items) {
        List<CompletableFuture<ItemResult>> futures = items.stream()
            .map(this::processItemInTransaction)
            .collect(Collectors.toList());
        
        return CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
            .thenApply(ignored -> {
                List<ItemResult> results = futures.stream()
                    .map(CompletableFuture::join)
                    .collect(Collectors.toList());
                
                return BatchResult.builder()
                    .totalItems(items.size())
                    .results(results)
                    .build();
            });
    }
    
    private CompletableFuture<ItemResult> processItemInTransaction(BatchItem item) {
        return CompletableFuture.supplyAsync(() -> {
            return transactionTemplate.execute(status -> {
                try {
                    // Process individual item
                    processItem(item);
                    return ItemResult.success(item.getId());
                } catch (Exception e) {
                    log.error("Item processing failed for {}: {}", item.getId(), e.getMessage());
                    return ItemResult.failure(item.getId(), e.getMessage());
                }
            });
        });
    }
    
    private Order createOrder(OrderRequest request) {
        // Order creation logic
        return new Order();
    }
    
    private void processItem(BatchItem item) {
        // Item processing logic
    }
}
```

## Async Testing Strategies

### 1. Testing Async Services

```java
@ExtendWith(MockitoExtension.class)
class AsyncServiceTest {
    
    @Mock
    private EmailSender emailSender;
    
    @Mock
    private NotificationRepository notificationRepository;
    
    @InjectMocks
    private NotificationService notificationService;
    
    private TestTaskExecutor testTaskExecutor;
    
    @BeforeEach
    void setUp() {
        // Use synchronous executor for testing
        testTaskExecutor = new TestTaskExecutor();
        ReflectionTestUtils.setField(notificationService, "taskExecutor", testTaskExecutor);
    }
    
    @Test
    void shouldSendWelcomeEmailAsynchronously() throws Exception {
        // Given
        String email = "test@example.com";
        String firstName = "John";
        
        when(emailSender.send(any(EmailTemplate.class))).thenReturn(EmailResult.success());
        
        // When
        notificationService.sendWelcomeEmailAsync(email, firstName);
        
        // Wait for async execution
        testTaskExecutor.waitForCompletion(5, TimeUnit.SECONDS);
        
        // Then
        verify(emailSender).send(argThat(template -> 
            template.getTo().equals(email) && 
            template.getSubject().equals("Welcome!")));
        verify(notificationRepository).save(any(NotificationLog.class));
    }
    
    @Test
    void shouldHandleAsyncEmailFailure() throws Exception {
        // Given
        String email = "test@example.com";
        String firstName = "John";
        
        when(emailSender.send(any(EmailTemplate.class)))
            .thenThrow(new EmailSendException("SMTP server unavailable"));
        
        // When
        CompletableFuture<Void> future = notificationService.sendWelcomeEmailAsync(email, firstName);
        
        // Then
        assertThatThrownBy(() -> future.get(5, TimeUnit.SECONDS))
            .isInstanceOf(ExecutionException.class)
            .hasCauseInstanceOf(AsyncNotificationException.class);
    }
    
    /**
     * Test executor that allows waiting for task completion
     */
    private static class TestTaskExecutor implements TaskExecutor {
        private final ExecutorService executor = Executors.newSingleThreadExecutor();
        private final CountDownLatch latch = new CountDownLatch(1);
        
        @Override
        public void execute(Runnable task) {
            executor.submit(() -> {
                try {
                    task.run();
                } finally {
                    latch.countDown();
                }
            });
        }
        
        public void waitForCompletion(long timeout, TimeUnit unit) throws InterruptedException {
            latch.await(timeout, unit);
        }
    }
}

/**
 * Integration test for async operations
 */
@SpringBootTest
@TestPropertySource(properties = {
    "spring.task.execution.pool.core-size=2",
    "spring.task.execution.pool.max-size=4"
})
class AsyncIntegrationTest {
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Test
    @Transactional
    void shouldProcessAsyncNotificationEndToEnd() throws Exception {
        // Given
        String email = "integration@example.com";
        String firstName = "Integration";
        
        // When
        CompletableFuture<NotificationResult> future = 
            notificationService.sendOrderConfirmationAsync(
                OrderConfirmationRequest.builder()
                    .orderId(123L)
                    .email(email)
                    .firstName(firstName)
                    .build()
            );
        
        // Wait for completion
        NotificationResult result = future.get(10, TimeUnit.SECONDS);
        
        // Then
        assertThat(result.isEmailSent()).isTrue();
        assertThat(result.getOrderId()).isEqualTo(123L);
        
        // Verify database changes
        entityManager.flush();
        entityManager.clear();
        
        List<NotificationLog> logs = entityManager.getEntityManager()
            .createQuery("SELECT n FROM NotificationLog n WHERE n.recipient = :email", NotificationLog.class)
            .setParameter("email", email)
            .getResultList();
            
        assertThat(logs).hasSize(1);
        assertThat(logs.get(0).getType()).isEqualTo("ORDER_CONFIRMATION");
        assertThat(logs.get(0).getStatus()).isEqualTo("SUCCESS");
    }
}
```

### 2. Performance Testing for Async Operations

```java
@SpringBootTest
@TestPropertySource(properties = {
    "app.async.default-pool.core-size=10",
    "app.async.default-pool.max-size=20"
})
class AsyncPerformanceTest {
    
    @Autowired
    private DataProcessingService dataProcessingService;
    
    @Test
    void shouldProcessLargeDatasetWithinTimeLimit() throws Exception {
        // Given
        List<DataRecord> records = generateTestData(1000);
        
        // When
        long startTime = System.currentTimeMillis();
        
        CompletableFuture<BatchProcessingResult> future = 
            dataProcessingService.processBatchDataAsync(records);
        
        BatchProcessingResult result = future.get(30, TimeUnit.SECONDS);
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;
        
        // Then
        assertThat(result.getTotalRecords()).isEqualTo(1000);
        assertThat(result.getSuccessfulBatches()).isGreaterThan(0);
        assertThat(duration).isLessThan(30000); // Should complete within 30 seconds
        
        log.info("Processed {} records in {}ms", records.size(), duration);
    }
    
    @Test
    void shouldHandleConcurrentAsyncOperations() throws Exception {
        // Given
        int concurrentOperations = 50;
        List<CompletableFuture<String>> futures = new ArrayList<>();
        
        // When
        long startTime = System.currentTimeMillis();
        
        for (int i = 0; i < concurrentOperations; i++) {
            CompletableFuture<String> future = dataProcessingService.processDataAsync("data-" + i);
            futures.add(future);
        }
        
        // Wait for all to complete
        CompletableFuture<Void> allFutures = CompletableFuture.allOf(
            futures.toArray(new CompletableFuture[0])
        );
        
        allFutures.get(60, TimeUnit.SECONDS);
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;
        
        // Then
        List<String> results = futures.stream()
            .map(CompletableFuture::join)
            .collect(Collectors.toList());
            
        assertThat(results).hasSize(concurrentOperations);
        assertThat(results).allMatch(result -> result.startsWith("Processed"));
        
        log.info("Completed {} concurrent operations in {}ms", concurrentOperations, duration);
    }
    
    private List<DataRecord> generateTestData(int count) {
        return IntStream.range(0, count)
            .mapToObj(i -> DataRecord.builder()
                .id((long) i)
                .data("test-data-" + i)
                .build())
            .collect(Collectors.toList());
    }
}
```

## Best Practices and Anti-Patterns

### 1. Async Best Practices

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class AsyncBestPracticesService {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    /**
     * ✅ GOOD: Proper async method signature with CompletableFuture
     */
    @Async("emailTaskExecutor")
    public CompletableFuture<EmailResult> sendEmailAsync(String email, String subject, String content) {
        try {
            EmailResult result = emailService.sendEmail(email, subject, content);
            return CompletableFuture.completedFuture(result);
        } catch (Exception e) {
            log.error("Failed to send email to {}: {}", email, e.getMessage());
            return CompletableFuture.failedFuture(e);
        }
    }
    
    /**
     * ✅ GOOD: Use specific thread pools for different types of work
     */
    @Async("heavyComputationExecutor")
    public CompletableFuture<ComputationResult> performHeavyComputation(ComputationInput input) {
        // CPU-intensive work in dedicated thread pool
        return CompletableFuture.supplyAsync(() -> {
            return performComputation(input);
        });
    }
    
    @Async("ioTaskExecutor")
    public CompletableFuture<String> performIOOperation(String filename) {
        // I/O operations in dedicated thread pool
        return CompletableFuture.supplyAsync(() -> {
            return readFromFile(filename);
        });
    }
    
    /**
     * ✅ GOOD: Proper exception handling and logging
     */
    @Async("defaultTaskExecutor")
    public CompletableFuture<Void> processUserDataAsync(Long userId) {
        return CompletableFuture.runAsync(() -> {
            try {
                User user = userRepository.findById(userId)
                    .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
                
                processUser(user);
                
                log.info("Successfully processed user: {}", userId);
                
            } catch (Exception e) {
                log.error("Failed to process user {}: {}", userId, e.getMessage(), e);
                // Don't rethrow - let the caller handle via CompletableFuture
            }
        });
    }
    
    /**
     * ❌ BAD: Don't call async methods from within the same class
     */
    public void badAsyncCall() {
        // This will NOT be async because of Spring's proxy mechanism
        sendEmailAsync("test@example.com", "Subject", "Content");
    }
    
    /**
     * ❌ BAD: Don't use @Async on private methods
     */
    @Async // This won't work - private methods can't be proxied
    private void privateAsyncMethod() {
        // This will run synchronously
    }
    
    /**
     * ❌ BAD: Don't ignore CompletableFuture return values
     */
    public void badAsyncUsage() {
        // Calling async method but ignoring the CompletableFuture
        sendEmailAsync("test@example.com", "Subject", "Content");
        // No way to know if it succeeded or handle errors
    }
    
    /**
     * ✅ GOOD: Proper async method composition
     */
    public CompletableFuture<ProcessingResult> processWithDependencies(Long userId) {
        return CompletableFuture
            .supplyAsync(() -> userRepository.findById(userId))
            .thenCompose(userOpt -> {
                if (userOpt.isEmpty()) {
                    return CompletableFuture.failedFuture(
                        new UserNotFoundException("User not found: " + userId));
                }
                return processUserDataAsync(userId)
                    .thenApply(ignored -> ProcessingResult.success(userId));
            })
            .exceptionally(throwable -> {
                log.error("Processing failed for user {}: {}", userId, throwable.getMessage());
                return ProcessingResult.failure(userId, throwable.getMessage());
            });
    }
}
```

### 2. Thread Safety Anti-Patterns

```java
@Service
@Slf4j
public class ThreadSafetyExamples {
    
    // ❌ BAD: Non-thread-safe shared state
    private int counter = 0; // Race condition!
    private List<String> sharedList = new ArrayList<>(); // Not thread-safe!
    
    // ✅ GOOD: Thread-safe alternatives
    private final AtomicInteger safeCounter = new AtomicInteger(0);
    private final List<String> safeList = Collections.synchronizedList(new ArrayList<>());
    private final ConcurrentLinkedQueue<String> concurrentQueue = new ConcurrentLinkedQueue<>();
    
    /**
     * ❌ BAD: Race condition
     */
    @Async
    public void badCounterIncrement() {
        counter++; // Not atomic - race condition!
    }
    
    /**
     * ✅ GOOD: Atomic operation
     */
    @Async
    public void goodCounterIncrement() {
        safeCounter.incrementAndGet(); // Thread-safe
    }
    
    /**
     * ❌ BAD: Improper synchronization
     */
    @Async
    public void badListOperation(String item) {
        if (!sharedList.contains(item)) { // Check
            sharedList.add(item); // Then act - race condition!
        }
    }
    
    /**
     * ✅ GOOD: Proper synchronization
     */
    @Async
    public void goodListOperation(String item) {
        synchronized (safeList) {
            if (!safeList.contains(item)) {
                safeList.add(item); // Atomic check-then-act
            }
        }
    }
    
    /**
     * ✅ BETTER: Use concurrent collections
     */
    private final ConcurrentHashMap<String, Boolean> itemSet = new ConcurrentHashMap<>();
    
    @Async
    public void bestListOperation(String item) {
        itemSet.putIfAbsent(item, true); // Thread-safe and more efficient
    }
}
```

## Configuration Properties

### application.yml

```yaml
# Async configuration
spring:
  task:
    execution:
      pool:
        core-size: 5
        max-size: 20
        queue-capacity: 100
        keep-alive: 60s
      thread-name-prefix: "async-"
      shutdown:
        await-termination: true
        await-termination-period: 30s

# Custom async properties
app:
  async:
    default-pool:
      core-size: 5
      max-size: 20
      queue-capacity: 100
      keep-alive-seconds: 60
      thread-name-prefix: "default-"
      wait-for-tasks-to-complete-on-shutdown: true
      await-termination-seconds: 30
    
    email-pool:
      core-size: 3
      max-size: 10
      queue-capacity: 50
      thread-name-prefix: "email-"
    
    report-pool:
      core-size: 2
      max-size: 5
      queue-capacity: 25
      thread-name-prefix: "report-"
    
    heavy-pool:
      core-size: 2
      max-size: 4
      queue-capacity: 10
      thread-name-prefix: "heavy-"

# Resilience configuration
resilience4j:
  retry:
    instances:
      async-service:
        max-attempts: 3
        wait-duration: 1s
        exponential-backoff-multiplier: 2
  
  circuitbreaker:
    instances:
      async-service:
        failure-rate-threshold: 50
        wait-duration-in-open-state: 30s
        sliding-window-size: 10

# Monitoring
management:
  metrics:
    export:
      prometheus:
        enabled: true
  endpoints:
    web:
      exposure:
        include: health,metrics,threaddump
```

## Summary

Key principles for async operations and multithreading:

1. **Proper Thread Pool Configuration** - Use dedicated pools for different workload types
2. **Exception Handling** - Always handle exceptions in async operations
3. **Thread Safety** - Use thread-safe collections and atomic operations
4. **Monitoring** - Track performance metrics and thread pool health
5. **Testing** - Comprehensive testing of async behavior and edge cases
6. **Resource Management** - Proper shutdown and cleanup of thread pools
7. **Avoid Common Pitfalls** - Don't call async methods within same class, use proper return types
8. **Resilience Patterns** - Implement retry, circuit breaker, and timeout patterns

Next: Complete the remaining documents in the guide...

Now I'll continue with the error handling document and complete the comprehensive guide.