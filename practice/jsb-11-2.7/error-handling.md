        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(ex.getHttpStatus().value())
            .error(ex.getHttpStatus().getReasonPhrase())
            .errorCode(ex.getErrorCode())
            .message(getLocalizedMessage(ex.getMessage(), locale))
            .path(request.getRequestURI())
            .details(ex.getDetails())
            .build();
        
        return new ResponseEntity<>(errorResponse, ex.getHttpStatus());
    }
    
    /**
     * Handle validation errors
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(
            MethodArgumentNotValidException ex, HttpServletRequest request, Locale locale) {
        
        log.warn("Validation failed for request: {}", request.getRequestURI());
        
        Map<String, Object> validationErrors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error -> {
            String fieldName = error.getField();
            String errorMessage = getLocalizedMessage(error.getDefaultMessage(), locale);
            validationErrors.put(fieldName, errorMessage);
        });
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.BAD_REQUEST.value())
            .error(HttpStatus.BAD_REQUEST.getReasonPhrase())
            .errorCode("VALIDATION_FAILED")
            .message("Request validation failed")
            .path(request.getRequestURI())
            .details(Map.of("fieldErrors", validationErrors))
            .build();
        
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }
    
    /**
     * Handle constraint validation errors
     */
    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ErrorResponse> handleConstraintViolationException(
            ConstraintViolationException ex, HttpServletRequest request, Locale locale) {
        
        log.warn("Constraint validation failed: {}", ex.getMessage());
        
        Map<String, Object> constraintErrors = new HashMap<>();
        ex.getConstraintViolations().forEach(violation -> {
            String propertyPath = violation.getPropertyPath().toString();
            String message = getLocalizedMessage(violation.getMessage(), locale);
            constraintErrors.put(propertyPath, message);
        });
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.BAD_REQUEST.value())
            .error(HttpStatus.BAD_REQUEST.getReasonPhrase())
            .errorCode("CONSTRAINT_VIOLATION")
            .message("Constraint validation failed")
            .path(request.getRequestURI())
            .details(Map.of("constraintErrors", constraintErrors))
            .build();
        
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }
    
    /**
     * Handle HTTP message not readable (malformed JSON)
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ErrorResponse> handleHttpMessageNotReadableException(
            HttpMessageNotReadableException ex, HttpServletRequest request, Locale locale) {
        
        log.warn("Malformed request body: {}", ex.getMessage());
        
        String userMessage = "Malformed request body";
        if (ex.getCause() instanceof JsonParseException) {
            userMessage = "Invalid JSON format";
        } else if (ex.getCause() instanceof JsonMappingException) {
            userMessage = "JSON mapping error";
        }
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.BAD_REQUEST.value())
            .error(HttpStatus.BAD_REQUEST.getReasonPhrase())
            .errorCode("MALFORMED_REQUEST")
            .message(userMessage)
            .path(request.getRequestURI())
            .build();
        
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }
    
    /**
     * Handle data access exceptions
     */
    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ErrorResponse> handleDataAccessException(
            DataAccessException ex, HttpServletRequest request, Locale locale) {
        
        log.error("Data access error: {}", ex.getMessage(), ex);
        
        String userMessage = "Internal server error";
        String errorCode = "DATABASE_ERROR";
        
        if (ex instanceof DataIntegrityViolationException) {
            userMessage = "Data integrity violation";
            errorCode = "DATA_INTEGRITY_VIOLATION";
        } else if (ex instanceof OptimisticLockingFailureException) {
            userMessage = "Resource was modified by another user";
            errorCode = "OPTIMISTIC_LOCK_FAILURE";
        }
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
            .error(HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase())
            .errorCode(errorCode)
            .message(userMessage)
            .path(request.getRequestURI())
            .build();
        
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    
    /**
     * Handle async exceptions
     */
    @ExceptionHandler(AsyncException.class)
    public ResponseEntity<ErrorResponse> handleAsyncException(
            AsyncException ex, HttpServletRequest request, Locale locale) {
        
        log.error("Async operation failed: {}", ex.getMessage(), ex);
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
            .error(HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase())
            .errorCode("ASYNC_OPERATION_FAILED")
            .message("Asynchronous operation failed")
            .path(request.getRequestURI())
            .details(Map.of("asyncOperationType", ex.getOperationType()))
            .build();
        
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    
    /**
     * Handle generic runtime exceptions
     */
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ErrorResponse> handleRuntimeException(
            RuntimeException ex, HttpServletRequest request, Locale locale) {
        
        log.error("Unexpected runtime exception: {}", ex.getMessage(), ex);
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
            .error(HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase())
            .errorCode("INTERNAL_ERROR")
            .message("An unexpected error occurred")
            .path(request.getRequestURI())
            .build();
        
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    
    /**
     * Handle all other exceptions
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(
            Exception ex, HttpServletRequest request, Locale locale) {
        
        log.error("Unexpected exception: {}", ex.getMessage(), ex);
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
            .error(HttpStatus.INTERNAL_SERVER_ERROR.getReasonPhrase())
            .errorCode("UNEXPECTED_ERROR")
            .message("An unexpected error occurred")
            .path(request.getRequestURI())
            .build();
        
        return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    
    private String getLocalizedMessage(String message, Locale locale) {
        try {
            return messageSource.getMessage(message, null, message, locale);
        } catch (Exception e) {
            return message;
        }
    }
}

/**
 * Error response DTO
 */
@Value
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ErrorResponse {
    
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime timestamp;
    
    int status;
    String error;
    String errorCode;
    String message;
    String path;
    Map<String, Object> details;
    String traceId; // For distributed tracing
    
    public static ErrorResponseBuilder builder() {
        return new ErrorResponseBuilder()
            .timestamp(LocalDateTime.now());
    }
}
```

### 2. Service Layer Exception Handling

```java
@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final UserMapper userMapper;
    
    @Override
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        log.info("Creating user with email: {}", request.getEmail());
        
        try {
            // Validate business rules
            validateCreateUserRequest(request);
            
            // Create user entity
            User user = buildUserEntity(request);
            
            // Save user
            User savedUser = userRepository.save(user);
            
            // Send welcome email (handle failure gracefully)
            sendWelcomeEmailSafely(savedUser);
            
            log.info("User created successfully: {}", savedUser.getId());
            return userMapper.toResponse(savedUser);
            
        } catch (DataIntegrityViolationException e) {
            log.error("Data integrity violation while creating user: {}", e.getMessage());
            
            if (e.getMessage().contains("email")) {
                throw new UserAlreadyExistsException(request.getEmail());
            }
            
            throw new UserCreationException("Failed to create user due to data constraints", e);
            
        } catch (ApplicationException e) {
            // Re-throw application exceptions as-is
            throw e;
            
        } catch (Exception e) {
            log.error("Unexpected error creating user: {}", e.getMessage(), e);
            throw new UserCreationException("Failed to create user", e);
        }
    }
    
    @Override
    @Transactional
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        log.info("Updating user: {}", id);
        
        User user = findUserByIdOrThrow(id);
        
        try {
            // Update user fields
            userMapper.updateEntityFromDto(request, user);
            
            // Save changes
            User updatedUser = userRepository.save(user);
            
            log.info("User updated successfully: {}", id);
            return userMapper.toResponse(updatedUser);
            
        } catch (OptimisticLockingFailureException e) {
            log.warn("Optimistic locking failure for user {}: {}", id, e.getMessage());
            throw new UserConcurrentModificationException(id);
            
        } catch (DataIntegrityViolationException e) {
            log.error("Data integrity violation updating user {}: {}", id, e.getMessage());
            throw new UserUpdateException("Failed to update user due to data constraints", e);
            
        } catch (Exception e) {
            log.error("Unexpected error updating user {}: {}", id, e.getMessage(), e);
            throw new UserUpdateException("Failed to update user", e);
        }
    }
    
    @Override
    public Optional<UserResponse> findUserById(Long id) {
        try {
            return userRepository.findById(id)
                .map(userMapper::toResponse);
                
        } catch (DataAccessException e) {
            log.error("Database error finding user {}: {}", id, e.getMessage(), e);
            throw new UserDataAccessException("Failed to retrieve user", e);
        }
    }
    
    @Override
    @Transactional
    public void deleteUser(Long id) {
        log.info("Deleting user: {}", id);
        
        User user = findUserByIdOrThrow(id);
        
        try {
            // Check if user can be deleted
            validateUserDeletion(user);
            
            // Soft delete
            user.markAsDeleted();
            userRepository.save(user);
            
            log.info("User deleted successfully: {}", id);
            
        } catch (ApplicationException e) {
            throw e;
            
        } catch (Exception e) {
            log.error("Unexpected error deleting user {}: {}", id, e.getMessage(), e);
            throw new UserDeletionException("Failed to delete user", e);
        }
    }
    
    /**
     * Helper methods for error handling
     */
    private User findUserByIdOrThrow(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
    
    private void validateCreateUserRequest(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException(request.getEmail());
        }
        
        // Additional business validations
        if (isEmailBlacklisted(request.getEmail())) {
            throw new ValidationException("Email domain is not allowed");
        }
    }
    
    private void validateUserDeletion(User user) {
        if (user.hasActiveOrders()) {
            throw new UserDeletionNotAllowedException(user.getId(), "User has active orders");
        }
        
        if (user.isSystemUser()) {
            throw new UserDeletionNotAllowedException(user.getId(), "System users cannot be deleted");
        }
    }
    
    private void sendWelcomeEmailSafely(User user) {
        try {
            emailService.sendWelcomeEmailAsync(user.getEmail(), user.getFirstName());
        } catch (Exception e) {
            // Log error but don't fail user creation
            log.warn("Failed to send welcome email to {}: {}", user.getEmail(), e.getMessage());
        }
    }
    
    private User buildUserEntity(CreateUserRequest request) {
        return User.builder()
            .firstName(request.getFirstName())
            .lastName(request.getLastName())
            .email(request.getEmail())
            .password(passwordEncoder.encode(request.getPassword()))
            .status(UserStatus.PENDING_VERIFICATION)
            .createdAt(LocalDateTime.now())
            .build();
    }
    
    private boolean isEmailBlacklisted(String email) {
        // Implementation for email domain validation
        return false;
    }
}
```

## Exception Monitoring and Logging

### 1. Exception Metrics and Monitoring

```java
@Component
@RequiredArgsConstructor
@Slf4j
public class ExceptionMonitor {
    
    private final MeterRegistry meterRegistry;
    private final ApplicationEventPublisher eventPublisher;
    
    // Exception counters
    private final Counter businessExceptionCounter;
    private final Counter technicalExceptionCounter;
    private final Counter validationExceptionCounter;
    
    @PostConstruct
    public void initMetrics() {
        businessExceptionCounter = Counter.builder("exceptions.business")
            .description("Number of business exceptions")
            .tag("type", "business")
            .register(meterRegistry);
            
        technicalExceptionCounter = Counter.builder("exceptions.technical")
            .description("Number of technical exceptions")
            .tag("type", "technical")
            .register(meterRegistry);
            
        validationExceptionCounter = Counter.builder("exceptions.validation")
            .description("Number of validation exceptions")
            .tag("type", "validation")
            .register(meterRegistry);
    }
    
    @EventListener
    public void handleBusinessException(BusinessExceptionEvent event) {
        businessExceptionCounter.increment(
            Tags.of(
                "errorCode", event.getErrorCode(),
                "service", event.getServiceName()
            )
        );
        
        log.warn("Business exception in {}: {} - {}", 
            event.getServiceName(), event.getErrorCode(), event.getMessage());
    }
    
    @EventListener
    public void handleTechnicalException(TechnicalExceptionEvent event) {
        technicalExceptionCounter.increment(
            Tags.of(
                "exceptionType", event.getExceptionType(),
                "service", event.getServiceName()
            )
        );
        
        log.error("Technical exception in {}: {} - {}", 
            event.getServiceName(), event.getExceptionType(), event.getMessage());
            
        // Send alert for critical technical exceptions
        if (event.isCritical()) {
            sendCriticalErrorAlert(event);
        }
    }
    
    @EventListener
    public void handleValidationException(ValidationExceptionEvent event) {
        validationExceptionCounter.increment(
            Tags.of(
                "validationType", event.getValidationType(),
                "endpoint", event.getEndpoint()
            )
        );
    }
    
    private void sendCriticalErrorAlert(TechnicalExceptionEvent event) {
        // Integration with alerting system (PagerDuty, Slack, etc.)
        log.error("CRITICAL ERROR: {} in {}", event.getMessage(), event.getServiceName());
    }
}

/**
 * Exception events for monitoring
 */
@Value
public class BusinessExceptionEvent {
    String errorCode;
    String message;
    String serviceName;
    LocalDateTime timestamp;
    Map<String, Object> details;
}

@Value
public class TechnicalExceptionEvent {
    String exceptionType;
    String message;
    String serviceName;
    boolean critical;
    LocalDateTime timestamp;
    String stackTrace;
}

@Value
public class ValidationExceptionEvent {
    String validationType;
    String endpoint;
    Map<String, String> fieldErrors;
    LocalDateTime timestamp;
}
```

### 2. Centralized Error Logging

```java
@Aspect
@Component
@Slf4j
@RequiredArgsConstructor
public class ExceptionLoggingAspect {
    
    private final ApplicationEventPublisher eventPublisher;
    private final ObjectMapper objectMapper;
    
    @AfterThrowing(
        pointcut = "@within(org.springframework.stereotype.Service)",
        throwing = "exception"
    )
    public void logServiceException(JoinPoint joinPoint, Exception exception) {
        String serviceName = joinPoint.getTarget().getClass().getSimpleName();
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();
        
        if (exception instanceof BusinessException) {
            handleBusinessException((BusinessException) exception, serviceName, methodName, args);
        } else if (exception instanceof DataAccessException) {
            handleTechnicalException(exception, serviceName, methodName, args, true);
        } else {
            handleTechnicalException(exception, serviceName, methodName, args, false);
        }
    }
    
    private void handleBusinessException(
            BusinessException exception, 
            String serviceName, 
            String methodName, 
            Object[] args) {
        
        Map<String, Object> context = Map.of(
            "service", serviceName,
            "method", methodName,
            "arguments", sanitizeArguments(args),
            "errorDetails", exception.getDetails()
        );
        
        log.warn("Business exception in {}.{}: {} - {}", 
            serviceName, methodName, exception.getErrorCode(), exception.getMessage(), 
            context);
        
        BusinessExceptionEvent event = new BusinessExceptionEvent(
            exception.getErrorCode(),
            exception.getMessage(),
            serviceName,
            LocalDateTime.now(),
            context
        );
        
        eventPublisher.publishEvent(event);
    }
    
    private void handleTechnicalException(
            Exception exception, 
            String serviceName, 
            String methodName, 
            Object[] args, 
            boolean critical) {
        
        Map<String, Object> context = Map.of(
            "service", serviceName,
            "method", methodName,
            "arguments", sanitizeArguments(args)
        );
        
        log.error("Technical exception in {}.{}: {}", 
            serviceName, methodName, exception.getMessage(), exception);
        
        TechnicalExceptionEvent event = new TechnicalExceptionEvent(
            exception.getClass().getSimpleName(),
            exception.getMessage(),
            serviceName,
            critical,
            LocalDateTime.now(),
            getStackTrace(exception)
        );
        
        eventPublisher.publishEvent(event);
    }
    
    private Object[] sanitizeArguments(Object[] args) {
        return Arrays.stream(args)
            .map(this::sanitizeArgument)
            .toArray();
    }
    
    private Object sanitizeArgument(Object arg) {
        if (arg == null) {
            return null;
        }
        
        // Remove sensitive information
        if (arg.getClass().getSimpleName().contains("Password") ||
            arg.getClass().getSimpleName().contains("Credential")) {
            return "***SANITIZED***";
        }
        
        try {
            String json = objectMapper.writeValueAsString(arg);
            return objectMapper.readValue(json, Object.class);
        } catch (Exception e) {
            return arg.toString();
        }
    }
    
    private String getStackTrace(Exception exception) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        exception.printStackTrace(pw);
        return sw.toString();
    }
}
```

## Testing Exception Handling

### 1. Unit Testing Exceptions

```java
@ExtendWith(MockitoExtension.class)
class UserServiceExceptionTest {
    
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
    void shouldThrowUserAlreadyExistsExceptionWhenEmailExists() {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .email("existing@example.com")
            .firstName("John")
            .lastName("Doe")
            .password("password123")
            .build();
        
        when(userRepository.existsByEmail("existing@example.com")).thenReturn(true);
        
        // When & Then
        assertThatThrownBy(() -> userService.createUser(request))
            .isInstanceOf(UserAlreadyExistsException.class)
            .hasMessageContaining("User already exists with email: existing@example.com")
            .satisfies(ex -> {
                UserAlreadyExistsException exception = (UserAlreadyExistsException) ex;
                assertThat(exception.getErrorCode()).isEqualTo("USER_ALREADY_EXISTS");
                assertThat(exception.getDetails()).containsEntry("email", "existing@example.com");
                assertThat(exception.getHttpStatus()).isEqualTo(HttpStatus.BAD_REQUEST);
            });
    }
    
    @Test
    void shouldThrowUserNotFoundExceptionWhenUpdatingNonExistentUser() {
        // Given
        Long userId = 999L;
        UpdateUserRequest request = UpdateUserRequest.builder()
            .firstName("Updated")
            .lastName("Name")
            .build();
        
        when(userRepository.findById(userId)).thenReturn(Optional.empty());
        
        // When & Then
        assertThatThrownBy(() -> userService.updateUser(userId, request))
            .isInstanceOf(UserNotFoundException.class)
            .hasMessageContaining("User not found with ID: 999")
            .satisfies(ex -> {
                UserNotFoundException exception = (UserNotFoundException) ex;
                assertThat(exception.getErrorCode()).isEqualTo("USER_NOT_FOUND");
                assertThat(exception.getDetails()).containsEntry("userId", 999L);
                assertThat(exception.getHttpStatus()).isEqualTo(HttpStatus.NOT_FOUND);
            });
    }
    
    @Test
    void shouldHandleDataIntegrityViolationGracefully() {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .email("test@example.com")
            .firstName("John")
            .lastName("Doe")
            .password("password123")
            .build();
        
        User user = new User();
        
        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(userMapper.toEntity(request)).thenReturn(user);
        when(passwordEncoder.encode("password123")).thenReturn("encoded");
        when(userRepository.save(user)).thenThrow(
            new DataIntegrityViolationException("Duplicate key value violates unique constraint \"users_email_key\"")
        );
        
        // When & Then
        assertThatThrownBy(() -> userService.createUser(request))
            .isInstanceOf(UserAlreadyExistsException.class)
            .hasMessageContaining("User already exists with email: test@example.com");
    }
    
    @Test
    void shouldContinueWhenWelcomeEmailFails() {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .email("test@example.com")
            .firstName("John")
            .lastName("Doe")
            .password("password123")
            .build();
        
        User user = User.builder()
            .id(1L)
            .email("test@example.com")
            .firstName("John")
            .lastName("Doe")
            .build();
        
        UserResponse expectedResponse = UserResponse.builder()
            .id(1L)
            .email("test@example.com")
            .firstName("John")
            .lastName("Doe")
            .build();
        
        when(userRepository.existsByEmail("test@example.com")).thenReturn(false);
        when(userMapper.toEntity(request)).thenReturn(user);
        when(passwordEncoder.encode("password123")).thenReturn("encoded");
        when(userRepository.save(user)).thenReturn(user);
        when(userMapper.toResponse(user)).thenReturn(expectedResponse);
        
        // Email service fails but shouldn't affect user creation
        doThrow(new RuntimeException("SMTP server unavailable"))
            .when(emailService).sendWelcomeEmailAsync("test@example.com", "John");
        
        // When
        UserResponse result = userService.createUser(request);
        
        // Then
        assertThat(result).isEqualTo(expectedResponse);
        verify(userRepository).save(user);
        verify(emailService).sendWelcomeEmailAsync("test@example.com", "John");
    }
}
```

### 2. Integration Testing Exception Handling

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb",
    "spring.jpa.hibernate.ddl-auto=create-drop"
})
class GlobalExceptionHandlerIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    void shouldReturnValidationErrorForInvalidRequest() {
        // Given
        CreateUserRequest invalidRequest = CreateUserRequest.builder()
            .email("invalid-email") // Invalid email format
            .firstName("") // Blank first name
            .password("123") // Too short password
            .build();
        
        // When
        ResponseEntity<ErrorResponse> response = restTemplate.postForEntity(
            "/api/v1/users",
            invalidRequest,
            ErrorResponse.class
        );
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getErrorCode()).isEqualTo("VALIDATION_FAILED");
        assertThat(response.getBody().getMessage()).isEqualTo("Request validation failed");
        assertThat(response.getBody().getDetails()).containsKey("fieldErrors");
        
        @SuppressWarnings("unchecked")
        Map<String, String> fieldErrors = (Map<String, String>) response.getBody().getDetails().get("fieldErrors");
        assertThat(fieldErrors).containsKeys("email", "firstName", "password");
    }
    
    @Test
    void shouldReturnNotFoundErrorForNonExistentUser() {
        // When
        ResponseEntity<ErrorResponse> response = restTemplate.getForEntity(
            "/api/v1/users/999",
            ErrorResponse.class
        );
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getErrorCode()).isEqualTo("USER_NOT_FOUND");
        assertThat(response.getBody().getMessage()).contains("User not found with ID: 999");
        assertThat(response.getBody().getDetails()).containsEntry("userId", 999);
    }
    
    @Test
    void shouldReturnBusinessErrorForDuplicateUser() {
        // Given - Create a user first
        User existingUser = User.builder()
            .firstName("Existing")
            .lastName("User")
            .email("existing@example.com")
            .password("encoded-password")
            .status(UserStatus.ACTIVE)
            .createdAt(LocalDateTime.now())
            .build();
        userRepository.save(existingUser);
        
        CreateUserRequest duplicateRequest = CreateUserRequest.builder()
            .firstName("Duplicate")
            .lastName("User")
            .email("existing@example.com") // Same email
            .password("password123")
            .build();
        
        // When
        ResponseEntity<ErrorResponse> response = restTemplate.postForEntity(
            "/api/v1/users",
            duplicateRequest,
            ErrorResponse.class
        );
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getErrorCode()).isEqualTo("USER_ALREADY_EXISTS");
        assertThat(response.getBody().getMessage()).contains("User already exists with email: existing@example.com");
        assertThat(response.getBody().getDetails()).containsEntry("email", "existing@example.com");
    }
    
    @Test
    void shouldReturnMalformedRequestErrorForInvalidJson() {
        // Given
        String invalidJson = "{ invalid json }";
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<String> entity = new HttpEntity<>(invalidJson, headers);
        
        // When
        ResponseEntity<ErrorResponse> response = restTemplate.postForEntity(
            "/api/v1/users",
            entity,
            ErrorResponse.class
        );
        
        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getErrorCode()).isEqualTo("MALFORMED_REQUEST");
        assertThat(response.getBody().getMessage()).contains("Invalid JSON format");
    }
}
```

## Summary

Error handling and exception management best practices:

1. **Structured Exception Hierarchy** - Create meaningful exception types with proper inheritance
2. **Global Exception Handling** - Use `@ControllerAdvice` for centralized error handling
3. **Proper Error Responses** - Return consistent, informative error responses
4. **Service Layer Error Patterns** - Handle exceptions appropriately at service boundaries
5. **Exception Monitoring** - Track and monitor exceptions with metrics and alerting
6. **Graceful Degradation** - Handle non-critical failures without breaking core functionality
7. **Comprehensive Testing** - Test all exception scenarios in unit and integration tests
8. **Localization Support** - Provide localized error messages for international applications

Next: [Testing & Documentation](testing-docs)    
    @Override
    public HttpStatus getHttpStatus() {
        return HttpStatus.NOT_FOUND;
    }
}
```

### 2. Specific Business Exceptions

```java
/**
 * User-related exceptions
 */
public class UserNotFoundException extends ResourceNotFoundException {
    public UserNotFoundException(String message) {
        super("USER_NOT_FOUND", message);
    }
    
    public UserNotFoundException(Long userId) {
        super("USER_NOT_FOUND", "User not found with ID: " + userId);
        addDetail("userId", userId);
    }
}

public class UserAlreadyExistsException extends BusinessException {
    public UserAlreadyExistsException(String email) {
        super("USER_ALREADY_EXISTS", "User already exists with email: " + email);
        addDetail("email", email);
    }
}

public class UserNotActiveException extends BusinessException {
    public UserNotActiveException(Long userId) {
        super("USER_NOT_ACTIVE", "User account is not active: " + userId);
        addDetail("userId", userId);
        addDetail("requiredStatus", "ACTIVE");
    }
}

/**
 * Order-related exceptions
 */
public class OrderNotFoundException extends ResourceNotFoundException {
    public OrderNotFoundException(Long orderId) {
        super("ORDER_NOT_FOUND", "Order not found with ID: " + orderId);
        addDetail("orderId", orderId);
    }
}

public class InvalidOrderStateException extends BusinessException {
    public InvalidOrderStateException(Long orderId, String currentState, String requiredState) {
        super("INVALID_ORDER_STATE", 
              String.format("Order %d is in state %s, but %s is required", orderId, currentState, requiredState));
        addDetail("orderId", orderId);
        addDetail("currentState", currentState);
        addDetail("requiredState", requiredState);
    }
}

public class InsufficientInventoryException extends BusinessException {
    public InsufficientInventoryException(Long productId, int requested, int available) {
        super("INSUFFICIENT_INVENTORY", 
              String.format("Insufficient inventory for product %d: requested %d, available %d", 
                            productId, requested, available));
        addDetail("productId", productId);
        addDetail("requestedQuantity", requested);
        addDetail("availableQuantity", available);
    }
}

/**
 * Payment-related exceptions
 */
public class PaymentProcessingException extends BusinessException {
    public PaymentProcessingException(String message) {
        super("PAYMENT_PROCESSING_FAILED", message);
    }
    
    public PaymentProcessingException(String message, String transactionId) {
        super("PAYMENT_PROCESSING_FAILED", message);
        addDetail("transactionId", transactionId);
    }
}

/**
 * Validation exceptions
 */
public class ValidationException extends BusinessException {
    public ValidationException(String message) {
        super("VALIDATION_ERROR", message);
    }
    
    public ValidationException(String message, Map<String, Object> validationErrors) {
        super("VALIDATION_ERROR", message, validationErrors);
    }
}
```

## Global Exception Handling

### 1. Controller Advice Implementation

```java
@ControllerAdvice
@Slf4j
@Order(Ordered.HIGHEST_PRECEDENCE)
public class GlobalExceptionHandler {
    
    private final MessageSource messageSource;
    private final ObjectMapper objectMapper;
    
    public GlobalExceptionHandler(MessageSource messageSource, ObjectMapper objectMapper) {
        this.messageSource = messageSource;
        this.objectMapper = objectMapper;
    }
    
    /**
     * Handle business exceptions
     */
    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(
            BusinessException ex, HttpServletRequest request, Locale locale) {
        
        log.warn("Business exception occurred: {} - {}", ex.getErrorCode(), ex.getMessage());
        
        ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(ex.getHttpStatus().value())
            .error(ex.getHttpStatus().getReasonPhrase())
            .errorCode(ex.getErrorCode())
            .message(getLocalizedMessage(ex.getMessage(), locale))
            .path(request.getRequestURI())
            .details(ex.getDetails())
            .build();
        
        return new ResponseEntity<>(errorResponse, ex.getHttpStatus());
    }
    
    /**
     * Handle resource not found exceptions
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFoundException(
            ResourceNotFoundException ex, HttpServletRequest request, Locale locale) {
        
        log.warn("Resource not found: {} - {}", ex.getErrorCode(), ex.getMessage());
        
        ErrorResponse# Error Handling & Exception Management

## Overview

Robust error handling is crucial for maintainable Spring Boot applications. This document covers exception design patterns, global error handling, service layer error propagation, and best practices for Spring Boot 2.7.

## Exception Hierarchy Design

### 1. Base Exception Classes

```java
/**
 * Base application exception
 */
public abstract class ApplicationException extends RuntimeException {
    
    private final String errorCode;
    private final Map<String, Object> details;
    
    protected ApplicationException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
        this.details = new HashMap<>();
    }
    
    protected ApplicationException(String errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
        this.details = new HashMap<>();
    }
    
    protected ApplicationException(String errorCode, String message, Map<String, Object> details) {
        super(message);
        this.errorCode = errorCode;
        this.details = details != null ? new HashMap<>(details) : new HashMap<>();
    }
    
    public String getErrorCode() {
        return errorCode;
    }
    
    public Map<String, Object> getDetails() {
        return new HashMap<>(details);
    }
    
    public void addDetail(String key, Object value) {
        this.details.put(key, value);
    }
    
    public abstract HttpStatus getHttpStatus();
}

/**
 * Business logic exceptions
 */
public abstract class BusinessException extends ApplicationException {
    
    protected BusinessException(String errorCode, String message) {
        super(errorCode, message);
    }
    
    protected BusinessException(String errorCode, String message, Map<String, Object> details) {
        super(errorCode, message, details);
    }
    
    @Override
    public HttpStatus getHttpStatus() {
        return HttpStatus.BAD_REQUEST;
    }
}

/**
 * Resource not found exceptions
 */
public abstract class ResourceNotFoundException extends ApplicationException {
    
    protected ResourceNotFoundException(String errorCode, String message) {
        super(errorCode, message);
    }
    
    protected ResourceNotFoundException(String errorCode, String message, Map<String, Object> details) {
        super(errorCode, message, details);
    }
    