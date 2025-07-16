/**
 * Repository with performance-optimized queries
 */
@Repository
public interface OptimizedUserRepository extends JpaRepository<User, Long> {
    
    /**
     * Optimized query with fetch joins to avoid N+1 problems
     */
    @Query("SELECT u FROM User u " +
           "LEFT JOIN FETCH u.address " +
           "LEFT JOIN FETCH u.orders o " +
           "LEFT JOIN FETCH o.items " +
           "WHERE u.id = :id")
    Optional<User> findByIdWithDetails(@Param("id") Long id);
    
    /**
     * Projection query for lightweight user data
     */
    @Query("SELECT new com.example.dto.UserSummary(" +
           "u.id, u.firstName, u.lastName, u.email, u.status, u.createdAt) " +
           "FROM User u " +
           "WHERE u.status = :status " +
           "ORDER BY u.createdAt DESC")
    List<UserSummary> findUserSummariesByStatus(@Param("status") UserStatus status);
    
    /**
     * Batch query with IN clause optimization
     */
    @Query("SELECT u FROM User u WHERE u.id IN :ids")
    List<User> findByIdIn(@Param("ids") Collection<Long> ids);
    
    /**
     * Count query for pagination without loading data
     */
    @Query("SELECT COUNT(u) FROM User u WHERE " +
           "(:keyword IS NULL OR LOWER(u.firstName) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "AND (:status IS NULL OR u.status = :status)")
    long countBySearchCriteria(@Param("keyword") String keyword, 
                              @Param("status") UserStatus status);
    
    /**
     * Native query for complex aggregations
     */
    @Query(value = """
        SELECT DATE_TRUNC('day', created_at) as date,
               COUNT(*) as user_count,
               COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) as active_count
        FROM users 
        WHERE created_at >= :startDate 
        GROUP BY DATE_TRUNC('day', created_at)
        ORDER BY date DESC
        """, nativeQuery = true)
    List<Object[]> findUserRegistrationStats(@Param("startDate") LocalDateTime startDate);
    
    /**
     * Streaming query for large datasets
     */
    @Query("SELECT u FROM User u WHERE u.createdAt BETWEEN :startDate AND :endDate")
    Stream<User> streamUsersByDateRange(@Param("startDate") LocalDateTime startDate,
                                       @Param("endDate") LocalDateTime endDate);
    
    /**
     * Bulk update operation
     */
    @Modifying
    @Query("UPDATE User u SET u.status = :newStatus, u.updatedAt = CURRENT_TIMESTAMP " +
           "WHERE u.status = :oldStatus AND u.lastLoginAt < :cutoffDate")
    int bulkUpdateInactiveUsers(@Param("oldStatus") UserStatus oldStatus,
                               @Param("newStatus") UserStatus newStatus,
                               @Param("cutoffDate") LocalDateTime cutoffDate);
}

/**
 * Service with performance optimizations
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PerformanceOptimizedUserService {
    
    private final OptimizedUserRepository userRepository;
    private final UserMapper userMapper;
    private final RedisTemplate<String, Object> redisTemplate;
    
    /**
     * Batch processing with optimal chunk size
     */
    @Transactional
    public BatchResult processUsersBatch(List<Long> userIds) {
        int batchSize = 100; // Optimal batch size for memory usage
        List<BatchItemResult> results = new ArrayList<>();
        
        for (int i = 0; i < userIds.size(); i += batchSize) {
            int endIndex = Math.min(i + batchSize, userIds.size());
            List<Long> batch = userIds.subList(i, endIndex);
            
            log.debug("Processing batch {}-{} of {}", i, endIndex, userIds.size());
            
            List<User> users = userRepository.findByIdIn(batch);
            BatchItemResult batchResult = processBatch(users);
            results.add(batchResult);
            
            // Clear persistence context to prevent memory issues
            entityManager.clear();
        }
        
        return BatchResult.builder()
            .totalItems(userIds.size())
            .batchResults(results)
            .build();
    }
    
    /**
     * Streaming processing for large datasets
     */
    @Transactional(readOnly = true)
    public void exportUsers(LocalDateTime startDate, LocalDateTime endDate, 
                           OutputStream outputStream) throws IOException {
        
        try (Stream<User> userStream = userRepository.streamUsersByDateRange(startDate, endDate);
             CSVWriter csvWriter = new CSVWriter(new OutputStreamWriter(outputStream))) {
            
            // Write header
            csvWriter.writeNext(new String[]{"ID", "Name", "Email", "Status", "Created"});
            
            // Stream processing to avoid memory issues
            userStream
                .map(this::convertToCSVRow)
                .forEach(csvWriter::writeNext);
        }
    }
    
    /**
     * Optimized search with result caching
     */
    public PagedResponse<UserResponse> searchUsersOptimized(UserSearchCriteria criteria) {
        // Check cache first
        String cacheKey = buildSearchCacheKey(criteria);
        PagedResponse<UserResponse> cached = getCachedSearchResult(cacheKey);
        
        if (cached != null) {
            log.debug("Cache hit for search: {}", cacheKey);
            return cached;
        }
        
        // Get total count first (often cached by database)
        long totalCount = userRepository.countBySearchCriteria(
            criteria.getKeyword(), 
            UserStatus.valueOf(criteria.getStatus())
        );
        
        if (totalCount == 0) {
            return PagedResponse.<UserResponse>builder()
                .content(Collections.emptyList())
                .totalElements(0)
                .build();
        }
        
        // Fetch only required page
        Specification<User> spec = buildUserSpecification(criteria);
        Page<User> userPage = userRepository.findAll(spec, criteria.toPageable());
        
        PagedResponse<UserResponse> result = userMapper.toPagedResponse(userPage);
        
        // Cache result
        cacheSearchResult(cacheKey, result);
        
        return result;
    }
    
    /**
     * Connection pooling optimization
     */
    @EventListener
    public void handleApplicationReady(ApplicationReadyEvent event) {
        // Warm up connection pool
        log.info("Warming up database connection pool");
        userRepository.count();
    }
    
    private String[] convertToCSVRow(User user) {
        return new String[]{
            user.getId().toString(),
            user.getFullName(),
            user.getEmail(),
            user.getStatus().toString(),
            user.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE)
        };
    }
    
    private String buildSearchCacheKey(UserSearchCriteria criteria) {
        return String.format("search:%s:%s:%d:%d",
            criteria.getKeyword(),
            criteria.getStatus(),
            criteria.getPage(),
            criteria.getSize());
    }
}
```

### 3. JVM and GC Optimization

```java
/**
 * JVM monitoring and optimization configuration
 */
@Configuration
@ConditionalOnProperty(name = "app.monitoring.jvm.enabled", havingValue = "true")
public class JvmOptimizationConfiguration {
    
    @Bean
    public JvmGcMetrics jvmGcMetrics() {
        return new JvmGcMetrics();
    }
    
    @Bean
    public JvmMemoryMetrics jvmMemoryMetrics() {
        return new JvmMemoryMetrics();
    }
    
    @Bean
    public JvmThreadMetrics jvmThreadMetrics() {
        return new JvmThreadMetrics();
    }
    
    @EventListener
    public void handleContextRefresh(ContextRefreshedEvent event) {
        logJvmSettings();
    }
    
    private void logJvmSettings() {
        MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
        List<GarbageCollectorMXBean> gcBeans = ManagementFactory.getGarbageCollectorMXBeans();
        
        log.info("JVM Memory Settings:");
        log.info("Heap Memory: {}", memoryBean.getHeapMemoryUsage());
        log.info("Non-Heap Memory: {}", memoryBean.getNonHeapMemoryUsage());
        
        log.info("Garbage Collectors:");
        gcBeans.forEach(gc -> 
            log.info("GC: {} - Collections: {}, Time: {}ms", 
                gc.getName(), gc.getCollectionCount(), gc.getCollectionTime()));
    }
}

/**
 * Memory optimization service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class MemoryOptimizationService {
    
    private final MeterRegistry meterRegistry;
    
    @Scheduled(fixedRate = 300000) // Every 5 minutes
    public void monitorMemoryUsage() {
        MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
        MemoryUsage heapUsage = memoryBean.getHeapMemoryUsage();
        
        double heapUsedPercentage = (double) heapUsage.getUsed() / heapUsage.getMax() * 100;
        
        Gauge.builder("jvm.memory.heap.percentage")
            .description("Heap memory usage percentage")
            .register(meterRegistry, () -> heapUsedPercentage);
        
        if (heapUsedPercentage > 80) {
            log.warn("High heap memory usage: {:.2f}%", heapUsedPercentage);
            
            if (heapUsedPercentage > 90) {
                log.error("Critical heap memory usage: {:.2f}% - Suggesting GC", heapUsedPercentage);
                System.gc(); // Suggest garbage collection
            }
        }
    }
    
    @EventListener
    @Async
    public void handleLowMemoryWarning(LowMemoryEvent event) {
        log.warn("Low memory warning received: {}", event.getDetails());
        
        // Clear non-essential caches
        clearOptionalCaches();
        
        // Notify monitoring system
        meterRegistry.counter("memory.warnings", "type", "low_memory").increment();
    }
    
    private void clearOptionalCaches() {
        // Implementation to clear non-critical caches
        log.info("Clearing optional caches due to memory pressure");
    }
}
```

## Security Implementation

### 1. Input Validation and Sanitization

```java
/**
 * Security-focused validation service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SecurityValidationService {
    
    private static final Pattern SQL_INJECTION_PATTERN = Pattern.compile(
        "(?i).*(union|select|insert|update|delete|drop|create|alter|exec|execute).*"
    );
    
    private static final Pattern XSS_PATTERN = Pattern.compile(
        "(?i).*(<script|javascript:|onload|onerror|onclick).*"
    );
    
    private static final Pattern PATH_TRAVERSAL_PATTERN = Pattern.compile(
        ".*(\\.\\.[\\\\/]|\\.\\.[/\\\\]).*"
    );
    
    /**
     * Comprehensive input validation
     */
    public void validateUserInput(String input, String fieldName) {
        if (input == null) {
            return;
        }
        
        // Check for SQL injection attempts
        if (SQL_INJECTION_PATTERN.matcher(input).matches()) {
            log.warn("Potential SQL injection attempt in field {}: {}", fieldName, input);
            throw new SecurityViolationException("Invalid input detected in " + fieldName);
        }
        
        // Check for XSS attempts
        if (XSS_PATTERN.matcher(input).matches()) {
            log.warn("Potential XSS attempt in field {}: {}", fieldName, input);
            throw new SecurityViolationException("Invalid input detected in " + fieldName);
        }
        
        // Check for path traversal attempts
        if (PATH_TRAVERSAL_PATTERN.matcher(input).matches()) {
            log.warn("Potential path traversal attempt in field {}: {}", fieldName, input);
            throw new SecurityViolationException("Invalid input detected in " + fieldName);
        }
    }
    
    /**
     * Sanitize user input for safe processing
     */
    public String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        
        return input
            .replaceAll("[<>\"'&]", "") // Remove potentially dangerous characters
            .trim()
            .substring(0, Math.min(input.length(), 1000)); // Limit length
    }
    
    /**
     * Validate file upload security
     */
    public void validateFileUpload(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ValidationException("File is required");
        }
        
        // Check file size
        if (file.getSize() > 10 * 1024 * 1024) { // 10MB limit
            throw new ValidationException("File size exceeds maximum allowed");
        }
        
        // Check file type
        String contentType = file.getContentType();
        List<String> allowedTypes = List.of("image/jpeg", "image/png", "application/pdf");
        
        if (!allowedTypes.contains(contentType)) {
            throw new ValidationException("File type not allowed: " + contentType);
        }
        
        // Check file name for malicious patterns
        String filename = file.getOriginalFilename();
        if (filename != null) {
            validateUserInput(filename, "filename");
            
            if (filename.contains("..") || filename.contains("/") || filename.contains("\\")) {
                throw new SecurityViolationException("Invalid filename");
            }
        }
    }
}

/**
 * Secure user service implementation
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SecureUserService implements UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final SecurityValidationService securityValidator;
    private final AuditService auditService;
    private final RateLimitService rateLimitService;
    
    @Override
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        // Rate limiting
        rateLimitService.checkRateLimit("user_creation", request.getEmail());
        
        // Input validation and sanitization
        validateAndSanitizeCreateUserRequest(request);
        
        // Audit logging
        auditService.logUserCreationAttempt(request.getEmail());
        
        try {
            // Business logic
            User user = createUserEntity(request);
            User savedUser = userRepository.save(user);
            
            // Audit successful creation
            auditService.logUserCreated(savedUser.getId(), savedUser.getEmail());
            
            return userMapper.toResponse(savedUser);
            
        } catch (Exception e) {
            // Audit failed creation
            auditService.logUserCreationFailed(request.getEmail(), e.getMessage());
            throw e;
        }
    }
    
    /**
     * Secure password change with validation
     */
    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        // Rate limiting for password changes
        rateLimitService.checkRateLimit("password_change", userId.toString());
        
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException(userId));
        
        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            auditService.logPasswordChangeFailed(userId, "Invalid current password");
            throw new InvalidPasswordException("Current password is incorrect");
        }
        
        // Validate new password strength
        validatePasswordStrength(request.getNewPassword());
        
        // Check password history (prevent reuse)
        if (isPasswordReused(userId, request.getNewPassword())) {
            throw new PasswordReuseException("Cannot reuse recent passwords");
        }
        
        // Update password
        String encodedPassword = passwordEncoder.encode(request.getNewPassword());
        user.setPassword(encodedPassword);
        user.setPasswordChangedAt(LocalDateTime.now());
        
        userRepository.save(user);
        
        // Store password history
        storePasswordHistory(userId, encodedPassword);
        
        auditService.logPasswordChanged(userId);
    }
    
    private void validateAndSanitizeCreateUserRequest(CreateUserRequest request) {
        // Validate all string inputs
        securityValidator.validateUserInput(request.getFirstName(), "firstName");
        securityValidator.validateUserInput(request.getLastName(), "lastName");
        securityValidator.validateUserInput(request.getEmail(), "email");
        
        // Additional email validation
        if (!isValidEmailDomain(request.getEmail())) {
            throw new ValidationException("Email domain not allowed");
        }
        
        // Validate password strength
        validatePasswordStrength(request.getPassword());
    }
    
    private boolean isValidEmailDomain(String email) {
        String domain = email.substring(email.indexOf('@') + 1);
        List<String> blockedDomains = List.of("tempmail.com", "guerrillamail.com");
        return !blockedDomains.contains(domain.toLowerCase());
    }
    
    private void validatePasswordStrength(String password) {
        // Comprehensive password validation
        if (password.length() < 12) {
            throw new WeakPasswordException("Password must be at least 12 characters");
        }
        
        if (!password.matches(".*[A-Z].*")) {
            throw new WeakPasswordException("Password must contain uppercase letters");
        }
        
        if (!password.matches(".*[a-z].*")) {
            throw new WeakPasswordException("Password must contain lowercase letters");
        }
        
        if (!password.matches(".*\\d.*")) {
            throw new WeakPasswordException("Password must contain numbers");
        }
        
        if (!password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>?].*")) {
            throw new WeakPasswordException("Password must contain special characters");
        }
        
        // Check against common passwords
        if (isCommonPassword(password)) {
            throw new WeakPasswordException("Password is too common");
        }
    }
}
```

### 2. Rate Limiting and Security Monitoring

```java
/**
 * Rate limiting service implementation
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RateLimitService {
    
    private final RedisTemplate<String, String> redisTemplate;
    private final SecurityProperties securityProperties;
    
    /**
     * Check if operation is within rate limits
     */
    public void checkRateLimit(String operation, String identifier) {
        RateLimitConfig config = securityProperties.getRateLimit().get(operation);
        if (config == null) {
            return; // No rate limiting configured
        }
        
        String key = buildRateLimitKey(operation, identifier);
        String currentCount = redisTemplate.opsForValue().get(key);
        
        int count = currentCount != null ? Integer.parseInt(currentCount) : 0;
        
        if (count >= config.getLimit()) {
            log.warn("Rate limit exceeded for operation {} by {}: {}/{}", 
                operation, identifier, count, config.getLimit());
            
            // Record security event
            recordSecurityEvent(SecurityEventType.RATE_LIMIT_EXCEEDED, 
                operation, identifier, count);
            
            throw new RateLimitExceededException(
                String.format("Rate limit exceeded for %s. Try again in %s", 
                    operation, config.getWindow()));
        }
        
        // Increment counter
        redisTemplate.opsForValue().increment(key);
        redisTemplate.expire(key, config.getWindow());
    }
    
    /**
     * Sliding window rate limiting
     */
    public void checkSlidingWindowRateLimit(String operation, String identifier) {
        RateLimitConfig config = securityProperties.getRateLimit().get(operation);
        if (config == null) {
            return;
        }
        
        String key = buildRateLimitKey(operation, identifier);
        long currentTime = System.currentTimeMillis();
        long windowStart = currentTime - config.getWindow().toMillis();
        
        // Remove old entries
        redisTemplate.opsForZSet().removeRangeByScore(key, 0, windowStart);
        
        // Count current requests
        Long count = redisTemplate.opsForZSet().count(key, windowStart, currentTime);
        
        if (count >= config.getLimit()) {
            throw new RateLimitExceededException("Rate limit exceeded");
        }
        
        // Add current request
        redisTemplate.opsForZSet().add(key, UUID.randomUUID().toString(), currentTime);
        redisTemplate.expire(key, config.getWindow());
    }
    
    private String buildRateLimitKey(String operation, String identifier) {
        return String.format("rate_limit:%s:%s", operation, identifier);
    }
    
    private void recordSecurityEvent(SecurityEventType eventType, String operation, 
                                   String identifier, Object details) {
        SecurityEvent event = SecurityEvent.builder()
            .eventType(eventType)
            .operation(operation)
            .identifier(identifier)
            .details(details)
            .timestamp(LocalDateTime.now())
            .build();
        
        // Async security event processing
        applicationEventPublisher.publishEvent(event);
    }
}

/**
 * Security monitoring service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SecurityMonitoringService {
    
    private final MeterRegistry meterRegistry;
    private final AlertingService alertingService;
    
    // Security metrics
    private final Counter securityViolations;
    private final Counter authenticationFailures;
    private final Counter suspiciousActivities;
    
    @PostConstruct
    public void initMetrics() {
        securityViolations = Counter.builder("security.violations")
            .description("Number of security violations detected")
            .register(meterRegistry);
        
        authenticationFailures = Counter.builder("security.auth.failures")
            .description("Number of authentication failures")
            .register(meterRegistry);
        
        suspiciousActivities = Counter.builder("security.suspicious")
            .description("Number of suspicious activities detected")
            .register(meterRegistry);
    }
    
    @EventListener
    @Async
    public void handleSecurityEvent(SecurityEvent event) {
        log.info("Security event: {} - {} - {}", 
            event.getEventType(), event.getOperation(), event.getIdentifier());
        
        // Update metrics
        updateSecurityMetrics(event);
        
        // Analyze threat level
        ThreatLevel threatLevel = analyzeThreatLevel(event);
        
        // Send alerts for high-risk events
        if (threatLevel.ordinal() >= ThreatLevel.HIGH.ordinal()) {
            alertingService.sendSecurityAlert(event, threatLevel);
        }
        
        // Store for analysis
        storeSecurityEvent(event);
    }
    
    private void updateSecurityMetrics(SecurityEvent event) {
        switch (event.getEventType()) {
            case AUTHENTICATION_FAILURE:
                authenticationFailures.increment(
                    Tags.of("reason", event.getDetails().toString()));
                break;
            case RATE_LIMIT_EXCEEDED:
            case SQL_INJECTION_ATTEMPT:
            case XSS_ATTEMPT:
                securityViolations.increment(
                    Tags.of("type", event.getEventType().toString()));
                break;
            case SUSPICIOUS_LOGIN_PATTERN:
            case MULTIPLE_FAILED_ATTEMPTS:
                suspiciousActivities.increment(
                    Tags.of("pattern", event.getOperation()));
                break;
        }
    }
    
    private ThreatLevel analyzeThreatLevel(SecurityEvent event) {
        // Analyze based on event type and context
        switch (event.getEventType()) {
            case SQL_INJECTION_ATTEMPT:
            case XSS_ATTEMPT:
                return ThreatLevel.CRITICAL;
            case MULTIPLE_FAILED_ATTEMPTS:
                return ThreatLevel.HIGH;
            case RATE_LIMIT_EXCEEDED:
                return ThreatLevel.MEDIUM;
            case AUTHENTICATION_FAILURE:
                return ThreatLevel.LOW;
            default:
                return ThreatLevel.INFO;
        }
    }
    
    /**
     * Detect anomalous patterns
     */
    @Scheduled(fixedRate = 300000) // Every 5 minutes
    public void detectAnomalies() {
        // Detect unusual login patterns
        detectUnusualLoginPatterns();
        
        // Detect brute force attempts
        detectBruteForceAttempts();
        
        // Detect suspicious user behavior
        detectSuspiciousUserBehavior();
    }
    
    private void detectUnusualLoginPatterns() {
        // Implementation for detecting unusual login patterns
        // e.g., logins from new locations, unusual times, etc.
    }
    
    private void detectBruteForceAttempts() {
        // Implementation for detecting brute force attempts
        // e.g., multiple failed login attempts from same IP
    }
    
    private void detectSuspiciousUserBehavior() {
        // Implementation for detecting suspicious user behavior
        // e.g., rapid succession of operations, unusual access patterns
    }
}
```

### 3. Data Encryption and Privacy

```java
/**
 * Data encryption service for sensitive information
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EncryptionService {
    
    private final AESUtil aesUtil;
    private final RSAUtil rsaUtil;
    
    /**
     * Encrypt sensitive user data
     */
    public String encryptSensitiveData(String data) {
        if (data == null || data.isEmpty()) {
            return data;
        }
        
        try {
            return aesUtil.encrypt(data);
        } catch (Exception e) {
            log.error("Failed to encrypt sensitive data", e);
            throw new EncryptionException("Data encryption failed");
        }
    }
    
    /**
     * Decrypt sensitive user data
     */
    public String decryptSensitiveData(String encryptedData) {
        if (encryptedData == null || encryptedData.isEmpty()) {
            return encryptedData;
        }
        
        try {
            return aesUtil.decrypt(encryptedData);
        } catch (Exception e) {
            log.error("Failed to decrypt sensitive data", e);
            throw new DecryptionException("Data decryption failed");
        }
    }
    
    /**
     * Hash PII data for searching without exposing original values
     */
    public String hashPII(String piiData) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(piiData.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }
}

/**
 * Privacy-compliant user service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PrivacyCompliantUserService {
    
    private final UserRepository userRepository;
    private final EncryptionService encryptionService;
    private final AuditService auditService;
    private final DataRetentionService dataRetentionService;
    
    /**
     * Create user with data privacy compliance
     */
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        // Encrypt sensitive data
        String encryptedPhone = encryptionService.encryptSensitiveData(request.getPhoneNumber());
        String hashedSSN = encryptionService.hashPII(request.getSsn());
        
        User user = User.builder()
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .email(request.getEmail())
            .phoneNumber(encryptedPhone)
            .ssnHash(hashedSSN)
            .dataRetentionDate(calculateDataRetentionDate())
            .consentGiven(true)
            .consentDate(LocalDateTime.now())
            .build();
        
        User savedUser = userRepository.save(user);
        
        // Audit data creation
        auditService.logPersonalDataCreated(savedUser.getId(), 
            List.of("firstName", "lastName", "email", "phoneNumber"));
        
        return userMapper.toResponse(savedUser);
    }
    
    /**
     * Anonymize user data for GDPR compliance
     */
    @Transactional
    public void anonymizeUser(Long userId, String reason) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException(userId));
        
        // Create anonymized version
        User anonymizedUser = user.toBuilder()
            .firstName("ANONYMIZED")
            .lastName("ANONYMIZED")
            .email("anonymized@example.com")
            .phoneNumber(null)
            .ssnHash(null)
            .anonymized(true)
            .anonymizedAt(LocalDateTime.now())
            .anonymizationReason(reason)
            .build();
        
        userRepository.save(anonymizedUser);
        
        // Audit anonymization
        auditService.logPersonalDataAnonymized(userId, reason);
        
        log.info("User {} anonymized. Reason: {}", userId, reason);
    }
    
    /**
     * Export user data for GDPR data portability
     */
    public UserDataExport exportUserData(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException(userId));
        
        // Decrypt sensitive data for export
        String decryptedPhone = encryptionService.decryptSensitiveData(user.getPhoneNumber());
        
        UserDataExport export = UserDataExport.builder()
            .userId(userId)
            .firstName(user.getFirstName())
            .lastName(user.getLastName())
            .email(user.getEmail())
            .phoneNumber(decryptedPhone)
            .createdAt(user.getCreatedAt())
            .exportedAt(LocalDateTime.now())
            .build();
        
        // Audit data export
        auditService.logPersonalDataExported(userId);
        
        return export;
    }
    
    private LocalDateTime calculateDataRetentionDate() {
        // Calculate based on regulatory requirements
        return LocalDateTime.now().plusYears(7); // Example: 7 years retention
    }
}
```

## Monitoring and Observability

### 1. Performance Metrics

```java
/**
 * Performance monitoring service
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PerformanceMonitoringService {
    
    private final MeterRegistry meterRegistry;
    private final Timer.Sample sample;
    
    // Performance metrics
    private final Timer serviceMethodTimer;
    private final Counter serviceMethodCounter;
    private final Gauge databaseConnectionsGauge;
    private final Counter cacheHitCounter;
    private final Counter cacheMissCounter;
    
    @PostConstruct
    public void initMetrics() {
        serviceMethodTimer = Timer.builder("service.method.duration")
            .description("Service method execution time")
            .register(meterRegistry);
        
        serviceMethodCounter = Counter.builder("service.method.calls")
            .description("Service method call count")
            .register(meterRegistry);
        
        cacheHitCounter = Counter.builder("cache.hits")
            .description("Cache hit count")
            .register(meterRegistry);
        
        cacheMissCounter = Counter.builder("cache.misses")
            .description("Cache miss count")
            .register(meterRegistry);
    }
    
    /**
     * Monitor service method performance
     */
    @Around("@annotation(Monitored)")
    public Object monitorPerformance(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().getName();
        String className = joinPoint.getTarget().getClass().getSimpleName();
        
        Timer.Sample sample = Timer.start(meterRegistry);
        serviceMethodCounter.increment(Tags.of("class", className, "method", methodName));
        
        try {
            Object result = joinPoint.proceed();
            
            sample.stop(Timer.builder("service.method.duration")
                .tag("class", className)
                .tag("method", methodName)
                .tag("status", "success")
                .register(meterRegistry));
            
            return result;
            
        } catch (Exception e) {
            sample.stop(Timer.builder("service.method.duration")
                .tag("class", className)
                .tag("method", methodName)
                .tag("status", "error")
                .register(meterRegistry));
            
            Counter.builder("service.method.errors")
                .tag("class", className)
                .tag("method", methodName)
                .tag("exception", e.getClass().getSimpleName())
                .register(meterRegistry)
                .increment();
            
            throw e;
        }
    }
    
    /**
     * Monitor database performance
     */
    @EventListener
    public void handleDatabaseEvent(DatabaseEvent event) {
        Timer.builder("database.query.duration")
            .tag("operation", event.getOperation())
            .tag("table", event.getTable())
            .register(meterRegistry)
            .record(event.getDuration(), TimeUnit.MILLISECONDS);
        
        if (event.getDuration() > 1000) { // Slow query threshold
            log.warn("Slow database query detected: {} on {} took {}ms", 
                event.getOperation(), event.getTable(), event.getDuration());
            
            Counter.builder("database.slow.queries")
                .tag("table", event.getTable())
                .register(meterRegistry)
                .increment();
        }
    }
    
    /**
     * Monitor cache performance
     */
    public void recordCacheHit(String cacheName) {
        cacheHitCounter.increment(Tags.of("cache", cacheName));
    }
    
    public void recordCacheMiss(String cacheName) {
        cacheMissCounter.increment(Tags.of("cache", cacheName));
    }
    
    /**
     * Health check for performance metrics
     */
    @Scheduled(fixedRate = 60000) // Every minute
    public void performanceHealthCheck() {
        // Check average response times
        double avgResponseTime = serviceMethodTimer.mean(TimeUnit.MILLISECONDS);
        
        if (avgResponseTime > 500) { // 500ms threshold
            log.warn("High average response time detected: {}ms", avgResponseTime);
            
            // Send alert
            sendPerformanceAlert("High average response time", avgResponseTime);
        }
        
        // Check cache hit ratio
        double cacheHitRatio = calculateCacheHitRatio();
        
        if (cacheHitRatio < 0.8) { // 80% threshold
            log.warn("Low cache hit ratio detected: {}", cacheHitRatio);
            sendPerformanceAlert("Low cache hit ratio", cacheHitRatio);
        }
    }
    
    private double calculateCacheHitRatio() {
        double hits = cacheHitCounter.count();
        double misses = cacheMissCounter.count();
        return hits / (hits + misses);
    }
    
    private void sendPerformanceAlert(String message, double value) {
        // Implementation for sending performance alerts
        log.warn("Performance Alert: {} - Value: {}", message, value);
    }
}

/**
 * Custom monitoring annotation
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Monitored {
    String value() default "";
}

/**
 * Monitored user service implementation
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class MonitoredUserService implements UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final PerformanceMonitoringService monitoringService;
    
    @Override
    @Monitored
    @Timed(name = "user.creation.time", description = "Time taken to create user")
    public UserResponse createUser(CreateUserRequest request) {
        Timer.Sample sample = Timer.start();
        
        try {
            // Business logic here
            User user = createUserEntity(request);
            User savedUser = userRepository.save(user);
            
            sample.stop(Timer.builder("user.creation.duration")
                .tag("status", "success")
                .register(meterRegistry));
            
            return userMapper.toResponse(savedUser);
            
        } catch (Exception e) {
            sample.stop(Timer.builder("user.creation.duration")
                .tag("status", "error")
                .tag("exception", e.getClass().getSimpleName())
                .register(meterRegistry));
            
            throw e;
        }
    }
    
    @Override
    @Monitored
    @Cacheable("users")
    public Optional<UserResponse> findUserById(Long id) {
        String cacheName = "users";
        
        // Check if value is in cache
        if (cacheManager.getCache(cacheName).get(id) != null) {
            monitoringService.recordCacheHit(cacheName);
        } else {
            monitoringService.recordCacheMiss(cacheName);
        }
        
        return userRepository.findById(id)
            .map(userMapper::toResponse);
    }
}
```

### 2. Distributed Tracing

```java
/**
 * Distributed tracing configuration
 */
@Configuration
@ConditionalOnProperty(name = "spring.sleuth.enabled", havingValue = "true")
public class TracingConfiguration {
    
    @Bean
    public Sampler alwaysSampler() {
        return Sampler.create(1.0f); // Sample 100% of requests in development
    }
    
    @Bean
    public SpanCustomizer spanCustomizer() {
        return span -> {
            span.tag("application", "user-service");
            span.tag("version", getClass().getPackage().getImplementationVersion());
        };
    }
    
    @NewSpan("user-service-operation")
    @GetMapping("/api/users/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id, 
                                                   @SpanTag("userId") Long userId) {
        // Method implementation
        return ResponseEntity.ok(userService.findUserById(id).orElse(null));
    }
}

/**
 * Service with distributed tracing
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class TracedUserService implements UserService {
    
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final Tracer tracer;
    
    @Override
    @NewSpan("create-user")
    public UserResponse createUser(@SpanTag("email") CreateUserRequest request) {
        Span span = tracer.nextSpan()
            .name("user-creation")
            .tag("user.email", request.getEmail())
            .tag("operation", "create")
            .start();
        
        try (Tracer.SpanInScope ws = tracer.withSpanInScope(span)) {
            
            // Add business context to span
            span.tag("user.firstName", request.getFirstName());
            span.tag("user.lastName", request.getLastName());
            
            // Validate user
            Span validationSpan = tracer.nextSpan()
                .name("user-validation")
                .start();
            
            try (Tracer.SpanInScope validationScope = tracer.withSpanInScope(validationSpan)) {
                validateCreateUserRequest(request);
                validationSpan.tag("validation.result", "success");
            } catch (Exception e) {
                validationSpan.tag("validation.result", "failed");
                validationSpan.tag("error", e.getMessage());
                throw e;
            } finally {
                validationSpan.end();
            }
            
            // Create user
            Span persistenceSpan = tracer.nextSpan()
                .name("user-persistence")
                .start();
            
            try (Tracer.SpanInScope persistenceScope = tracer.withSpanInScope(persistenceSpan)) {
                User user = createUserEntity(request);
                User savedUser = userRepository.save(user);
                
                persistenceSpan.tag("user.id", savedUser.getId().toString());
                persistenceSpan.tag("persistence.result", "success");
                
                // Send email async (will create its own span)
                emailService.sendWelcomeEmailAsync(savedUser.getEmail(), savedUser.getFirstName());
                
                return userMapper.toResponse(savedUser);
                
            } catch (Exception e) {
                persistenceSpan.tag("persistence.result", "failed");
                persistenceSpan.tag("error", e.getMessage());
                throw e;
            } finally {
                persistenceSpan.end();
            }
            
        } catch (Exception e) {
            span.tag("result", "error");
            span.tag("error.message", e.getMessage());
            throw e;
        } finally {
            span.tag("result", "success");
            span.end();
        }
    }
    
    @NewSpan("user-search")
    public PagedResponse<UserResponse> searchUsers(@SpanTag("criteria") UserSearchCriteria criteria) {
        Span span = tracer.nextSpan().name("user-search");
        
        span.tag("search.keyword", criteria.getKeyword());
        span.tag("search.status", criteria.getStatus());
        span.tag("search.page", String.valueOf(criteria.getPage()));
        span.tag("search.size", String.valueOf(criteria.getSize()));
        
        try (Tracer.SpanInScope ws = tracer.withSpanInScope(span)) {
            
            PagedResponse<UserResponse> result = performUserSearch(criteria);
            
            span.tag("result.totalElements", String.valueOf(result.getTotalElements()));
            span.tag("result.totalPages", String.valueOf(result.getTotalPages()));
            
            return result;
            
        } finally {
            span.end();
        }
    }
}
```

### 3. Application Health Monitoring

```java
/**
 * Custom health indicators
 */
@Component
public class UserServiceHealthIndicator implements HealthIndicator {
    
    private final UserRepository userRepository;
    private final CacheManager cacheManager;
    private final EmailService emailService;
    
    public UserServiceHealthIndicator(UserRepository userRepository,
                                    CacheManager cacheManager,
                                    EmailService emailService) {
        this.userRepository = userRepository;
        this.cacheManager = cacheManager;
        this.emailService = emailService;
    }
    
    @Override
    public Health health() {
        Health.Builder builder = new Health.Builder();
        
        try {
            // Check database connectivity
            checkDatabaseHealth(builder);
            
            // Check cache health
            checkCacheHealth(builder);
            
            // Check email service health
            checkEmailServiceHealth(builder);
            
            return builder.up().build();
            
        } catch (Exception e) {
            return builder.down()
                .withException(e)
                .build();
        }
    }
    
    private void checkDatabaseHealth(Health.Builder builder) {
        try {
            long startTime = System.currentTimeMillis();
            long userCount = userRepository.count();
            long responseTime = System.currentTimeMillis() - startTime;
            
            builder.withDetail("database.status", "UP")
                   .withDetail("database.userCount", userCount)
                   .withDetail("database.responseTime", responseTime + "ms");
            
            if (responseTime > 1000) {
                builder.withDetail("database.warning", "Slow response time");
            }
            
        } catch (Exception e) {
            builder.withDetail("database.status", "DOWN")
                   .withDetail("database.error", e.getMessage());
            throw e;
        }
    }
    
    private void checkCacheHealth(Health.Builder builder) {
        try {
            Cache userCache = cacheManager.getCache("users");
            if (userCache != null) {
                builder.withDetail("cache.status", "UP")
                       .withDetail("cache.name", "users");
            } else {
                builder.withDetail("cache.status", "DOWN")
                       .withDetail("cache.error", "User cache not found");
            }
            
        } catch (Exception e) {
            builder.withDetail("cache.status", "DOWN")
                   .withDetail("cache.error", e.getMessage());
        }
    }
    
    private void checkEmailServiceHealth(Health.Builder builder) {
        try {
            boolean emailHealthy = emailService.isHealthy();
            
            builder.withDetail("email.status", emailHealthy ? "UP" : "DOWN");
            
            if (!emailHealthy) {
                builder.withDetail("email.warning", "Email service not responding");
            }
            
        } catch (Exception e) {
            builder.withDetail("email.status", "DOWN")
                   .withDetail("email.error", e.getMessage());
        }
    }
}

/**
 * Comprehensive application health monitoring
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class ApplicationHealthMonitor {
    
    private final HealthEndpoint healthEndpoint;
    private final MeterRegistry meterRegistry;
    private final AlertingService alertingService;
    
    @Scheduled(fixedRate = 30000) // Every 30 seconds
    public void monitorApplicationHealth() {
        try {
            HealthComponent health = healthEndpoint.health();
            Status status = health.getStatus();
            
            // Record health metrics
            Gauge.builder("application.health")
                .description("Application health status")
                .register(meterRegistry, () -> status == Status.UP ? 1.0 : 0.0);
            
            if (status != Status.UP) {
                log.error("Application health check failed: {}", health);
                alertingService.sendHealthAlert("Application unhealthy", health.getDetails());
            }
            
            // Check individual component health
            checkComponentHealth(health);
            
        } catch (Exception e) {
            log.error("Health monitoring failed", e);
            alertingService.sendHealthAlert("Health monitoring failure", e.getMessage());
        }
    }
    
    private void checkComponentHealth(HealthComponent health) {
        if (health instanceof CompositeHealthComponent) {
            CompositeHealthComponent composite = (CompositeHealthComponent) health;
            
            composite.getComponents().forEach((name, component) -> {
                Status componentStatus = component.getStatus();
                
                Gauge.builder("application.health.component")
                    .tag("component", name)
                    .description("Component health status")
                    .register(meterRegistry, () -> componentStatus == Status.UP ? 1.0 : 0.0);
                
                if (componentStatus != Status.UP) {
                    log.warn("Component {} is unhealthy: {}", name, component);
                }
            });
        }
    }
    
    @EventListener
    public void handleHealthChanged(HealthChangedEvent event) {
        log.info("Health status changed from {} to {}", 
            event.getPreviousStatus(), event.getCurrentStatus());
        
        if (event.getCurrentStatus() != Status.UP) {
            alertingService.sendHealthAlert("Health status degraded", 
                event.getCurrentStatus().toString());
        }
    }
}
```

## Configuration Properties

### application.yml

```yaml
# Performance Configuration
spring:
  jpa:
    hibernate:
      ddl-auto: validate
      jdbc:
        batch_size: 20
        fetch_size: 50
    properties:
      hibernate:
        jdbc:
          batch_size: 20
        order_inserts: true
        order_updates: true
        batch_versioned_data: true
        connection:
          provider_disables_autocommit: true
    show-sql: false
  
  # Connection Pool Configuration
  datasource:
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 300000
      connection-timeout: 20000
      max-lifetime: 1200000
      leak-detection-threshold: 60000
  
  # Cache Configuration
  cache:
    type: caffeine
    caffeine:
      spec: maximumSize=1000,expireAfterAccess=30m,expireAfterWrite=2h,recordStats
  
  # Redis Configuration
  redis:
    host: ${REDIS_HOST:localhost}
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PASSWORD:}
    timeout: 2000ms
    lettuce:
      pool:
        max-active: 8
        max-idle: 8
        min-idle: 0

# Security Configuration
app:
  security:
    password:
      encoder-strength: 12
      min-length: 12
      require-uppercase: true
      require-lowercase: true
      require-numbers: true
      require-special-chars: true
    
    rate-limit:
      user_creation:
        limit: 5
        window: PT1M
      password_change:
        limit: 3
        window: PT5M
      login_attempt:
        limit: 10
        window: PT15M
    
    encryption:
      aes-key: ${AES_ENCRYPTION_KEY}
      rsa-public-key: ${RSA_PUBLIC_KEY}
      rsa-private-key: ${RSA_PRIVATE_KEY}

# Monitoring Configuration
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus,info,threaddump,heapdump
  endpoint:
    health:
      show-details: always
      show-components: always
  metrics:
    export:
      prometheus:
        enabled: true
    distribution:
      percentiles-histogram:
        http.server.requests: true
        service.method.duration: true
      percentiles:
        http.server.requests: 0.5,0.9,0.95,0.99
        service.method.duration: 0.5,0.9,0.95,0.99

# Logging Configuration
logging:
  level:
    com.example.service: DEBUG
    org.springframework.security: DEBUG
    org.hibernate.SQL: INFO
    org.hibernate.type.descriptor.sql.BasicBinder: INFO
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level [%X{traceId:-},%X{spanId:-}] %logger{36} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level [%X{traceId:-},%X{spanId:-}] %logger{36} - %msg%n"

# Custom Application Properties
app:
  features:
    user-management:
      enabled: true
    advanced-search:
      enabled: true
    email-notifications:
      enabled: true
  
  performance:
    batch-size: 100
    cache-ttl: PT1H
    async-pool-size: 10
  
  data-retention:
    user-data-years: 7
    audit-log-years: 10
    temp-data-days: 30
```

## Summary

Performance and security best practices for Spring Boot service layers:

1. **Caching Strategy** - Multi-level caching with appropriate TTL and eviction policies
2. **Database Optimization** - Connection pooling, query optimization, and batch processing
3. **JVM Tuning** - Memory management and garbage collection optimization
4. **Security Implementation** - Input validation, encryption, rate limiting, and monitoring
5. **Performance Monitoring** - Comprehensive metrics, distributed tracing, and alerting
6. **Health Monitoring** - Application and component health checks with automated alerting
7. **Data Privacy** - GDPR compliance, data encryption, and privacy-by-design principles
8. **Observability** - Distributed tracing, metrics collection, and log correlation

This completes the comprehensive Java 11 Spring Boot 2.7 Service Layer Best Practices Guide. The guide covers all essential aspects of building robust, secure, and performant service layers with modern development practices, comprehensive testing, and production-ready monitoring.# Performance & Security

## Overview

Performance optimization and security are critical aspects of Spring Boot service layer development. This document covers caching strategies, performance monitoring, security best practices, and optimization techniques for Java 11 and Spring Boot 2.7.

## Performance Optimization

### 1. Caching Strategies

```java
/**
 * Caching configuration for service layer optimization
 */
@Configuration
@EnableCaching
@RequiredArgsConstructor
public class CacheConfiguration {
    
    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager();
        cacheManager.setCaffeine(caffeineCacheBuilder());
        return cacheManager;
    }
    
    private Caffeine<Object, Object> caffeineCacheBuilder() {
        return Caffeine.newBuilder()
            .initialCapacity(100)
            .maximumSize(1000)
            .expireAfterAccess(Duration.ofMinutes(30))
            .expireAfterWrite(Duration.ofHours(2))
            .recordStats()
            .removalListener((key, value, cause) -> 
                log.debug("Cache entry removed: key={}, cause={}", key, cause));
    }
    
    @Bean
    public CacheManager redisCacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofHours(1))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));
        
        return RedisCacheManager.builder(connectionFactory)
            .cacheDefaults(config)
            .build();
    }
}

/**
 * Service with comprehensive caching strategy
 */
@Service
@RequiredArgsConstructor
@Slf4j
@CacheConfig(cacheNames = "users")
public class CachedUserService implements UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final CacheManager cacheManager;
    
    /**
     * Cache user responses with TTL and conditional caching
     */
    @Override
    @Cacheable(
        key = "#id", 
        condition = "#id != null",
        unless = "#result.isEmpty()"
    )
    public Optional<UserResponse> findUserById(Long id) {
        log.debug("Cache miss for user ID: {}", id);
        
        return userRepository.findById(id)
            .map(userMapper::toResponse);
    }
    
    /**
     * Cache search results with complex key generation
     */
    @Cacheable(
        value = "userSearches",
        key = "#criteria.keyword + '_' + #criteria.status + '_' + #criteria.page + '_' + #criteria.size",
        condition = "#criteria.keyword != null and #criteria.keyword.length() > 2"
    )
    public PagedResponse<UserResponse> searchUsers(UserSearchCriteria criteria) {
        log.debug("Cache miss for user search: {}", criteria);
        
        Specification<User> spec = buildUserSpecification(criteria);
        Page<User> userPage = userRepository.findAll(spec, criteria.toPageable());
        
        return userMapper.toPagedResponse(userPage);
    }
    
    /**
     * Evict cache entries on user updates
     */
    @Override
    @CacheEvict(key = "#id")
    @CachePut(key = "#id", condition = "#result != null")
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        log.info("Updating user and refreshing cache: {}", id);
        
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
        
        userMapper.updateEntityFromDto(request, user);
        User savedUser = userRepository.save(user);
        
        // Evict related search caches
        evictSearchCaches();
        
        return userMapper.toResponse(savedUser);
    }
    
    /**
     * Evict all user-related caches
     */
    @CacheEvict(allEntries = true)
    public void evictAllUserCaches() {
        log.info("Evicting all user caches");
    }
    
    /**
     * Custom cache eviction for search results
     */
    private void evictSearchCaches() {
        Cache searchCache = cacheManager.getCache("userSearches");
        if (searchCache != null) {
            searchCache.clear();
            log.debug("Evicted user search cache");
        }
    }
    
    /**
     * Programmatic caching for complex scenarios
     */
    public UserStatistics getUserStatistics(Long userId) {
        String cacheKey = "userStats_" + userId;
        Cache cache = cacheManager.getCache("userStatistics");
        
        UserStatistics stats = cache.get(cacheKey, UserStatistics.class);
        
        if (stats == null) {
            log.debug("Computing user statistics for user: {}", userId);
            stats = computeUserStatistics(userId);
            cache.put(cacheKey, stats);
        }
        
        return stats;
    }
    
    private UserStatistics computeUserStatistics(Long userId) {
        // Expensive computation
        return UserStatistics.builder()
            .userId(userId)
            .loginCount(userRepository.countLoginsByUserId(userId))
            .lastLoginDate(userRepository.findLastLoginDate(userId))
            .orderCount(userRepository.countOrdersByUserId(userId))
            .computedAt(LocalDateTime.now())
            .build();
    }
}
```

### 2. Database Performance Optimization

```java
/**
 * Repository with performance-optimized queries
 */
@Repository
public interface OptimizedUserRepository extends