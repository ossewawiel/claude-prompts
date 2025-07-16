# Testing & Documentation

## Overview

Comprehensive testing and documentation are essential for maintainable Spring Boot applications. This document covers testing strategies for service layers, documentation standards, and best practices for Java 11 and Spring Boot 2.7.

## Testing Service Layers

### 1. Unit Testing with JUnit 5 and Mockito

```java
@ExtendWith(MockitoExtension.class)
@DisplayName("User Service Tests")
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
    
    @Nested
    @DisplayName("User Creation Tests")
    class UserCreationTests {
        
        @Test
        @DisplayName("Should create user successfully with valid data")
        void shouldCreateUserSuccessfully() {
            // Given
            CreateUserRequest request = CreateUserRequest.builder()
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@example.com")
                .password("SecurePass123!")
                .build();
            
            User savedUser = User.builder()
                .id(1L)
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@example.com")
                .password("encoded-password")
                .status(UserStatus.PENDING_VERIFICATION)
                .createdAt(LocalDateTime.now())
                .build();
            
            UserResponse expectedResponse = UserResponse.builder()
                .id(1L)
                .firstName("John")
                .lastName("Doe")
                .email("john.doe@example.com")
                .status("PENDING_VERIFICATION")
                .createdAt(savedUser.getCreatedAt())
                .build();
            
            when(userRepository.existsByEmail("john.doe@example.com")).thenReturn(false);
            when(userMapper.toEntity(request)).thenReturn(savedUser);
            when(passwordEncoder.encode("SecurePass123!")).thenReturn("encoded-password");
            when(userRepository.save(any(User.class))).thenReturn(savedUser);
            when(userMapper.toResponse(savedUser)).thenReturn(expectedResponse);
            
            // When
            UserResponse result = userService.createUser(request);
            
            // Then
            assertThat(result)
                .isNotNull()
                .satisfies(response -> {
                    assertThat(response.getId()).isEqualTo(1L);
                    assertThat(response.getEmail()).isEqualTo("john.doe@example.com");
                    assertThat(response.getStatus()).isEqualTo("PENDING_VERIFICATION");
                });
            
            // Verify interactions
            verify(userRepository).existsByEmail("john.doe@example.com");
            verify(passwordEncoder).encode("SecurePass123!");
            verify(userRepository).save(any(User.class));
            verify(emailService).sendWelcomeEmailAsync("john.doe@example.com", "John");
            verify(userMapper).toResponse(savedUser);
            
            verifyNoMoreInteractions(userRepository, passwordEncoder, emailService, userMapper);
        }
        
        @Test
        @DisplayName("Should throw UserAlreadyExistsException when email exists")
        void shouldThrowExceptionWhenEmailExists() {
            // Given
            CreateUserRequest request = CreateUserRequest.builder()
                .email("existing@example.com")
                .build();
            
            when(userRepository.existsByEmail("existing@example.com")).thenReturn(true);
            
            // When & Then
            assertThatThrownBy(() -> userService.createUser(request))
                .isInstanceOf(UserAlreadyExistsException.class)
                .hasMessage("User already exists with email: existing@example.com")
                .satisfies(ex -> {
                    UserAlreadyExistsException exception = (UserAlreadyExistsException) ex;
                    assertThat(exception.getErrorCode()).isEqualTo("USER_ALREADY_EXISTS");
                    assertThat(exception.getDetails())
                        .containsEntry("email", "existing@example.com");
                });
            
            verify(userRepository).existsByEmail("existing@example.com");
            verifyNoMoreInteractions(userRepository);
            verifyNoInteractions(passwordEncoder, emailService, userMapper);
        }
        
        @ParameterizedTest
        @DisplayName("Should handle various invalid email formats")
        @ValueSource(strings = {
            "invalid-email",
            "@example.com",
            "user@",
            "user..name@example.com",
            "user@.com"
        })
        void shouldHandleInvalidEmailFormats(String invalidEmail) {
            // Given
            CreateUserRequest request = CreateUserRequest.builder()
                .email(invalidEmail)
                .firstName("John")
                .lastName("Doe")
                .password("password123")
                .build();
            
            // When & Then
            assertThatThrownBy(() -> userService.createUser(request))
                .isInstanceOf(ValidationException.class);
        }
        
        @Test
        @DisplayName("Should continue user creation when welcome email fails")
        void shouldContinueWhenWelcomeEmailFails() {
            // Given
            CreateUserRequest request = CreateUserRequest.builder()
                .firstName("John")
                .lastName("Doe")
                .email("john@example.com")
                .password("password123")
                .build();
            
            User savedUser = createTestUser();
            UserResponse expectedResponse = createTestUserResponse();
            
            setupSuccessfulUserCreation(request, savedUser, expectedResponse);
            
            // Email service throws exception
            doThrow(new RuntimeException("SMTP server unavailable"))
                .when(emailService).sendWelcomeEmailAsync(anyString(), anyString());
            
            // When
            UserResponse result = userService.createUser(request);
            
            // Then
            assertThat(result).isEqualTo(expectedResponse);
            verify(emailService).sendWelcomeEmailAsync("john@example.com", "John");
        }
    }
    
    @Nested
    @DisplayName("User Search Tests")
    class UserSearchTests {
        
        @Test
        @DisplayName("Should return paginated users for search criteria")
        void shouldReturnPaginatedUsers() {
            // Given
            UserSearchCriteria criteria = UserSearchCriteria.builder()
                .keyword("john")
                .status("ACTIVE")
                .page(0)
                .size(10)
                .build();
            
            List<User> users = List.of(createTestUser(), createTestUser());
            Page<User> userPage = new PageImpl<>(users, PageRequest.of(0, 10), 2);
            List<UserResponse> userResponses = List.of(createTestUserResponse(), createTestUserResponse());
            
            when(userRepository.findAll(any(Specification.class), any(Pageable.class)))
                .thenReturn(userPage);
            when(userMapper.toPagedResponse(userPage))
                .thenReturn(PagedResponse.<UserResponse>builder()
                    .content(userResponses)
                    .page(0)
                    .size(10)
                    .totalElements(2)
                    .totalPages(1)
                    .build());
            
            // When
            PagedResponse<UserResponse> result = userService.searchUsers(criteria);
            
            // Then
            assertThat(result)
                .satisfies(response -> {
                    assertThat(response.getContent()).hasSize(2);
                    assertThat(response.getTotalElements()).isEqualTo(2);
                    assertThat(response.getPage()).isEqualTo(0);
                    assertThat(response.getSize()).isEqualTo(10);
                });
        }
        
        @Test
        @DisplayName("Should validate search criteria")
        void shouldValidateSearchCriteria() {
            // Given
            UserSearchCriteria invalidCriteria = UserSearchCriteria.builder()
                .createdAfter(LocalDate.now())
                .createdBefore(LocalDate.now().minusDays(1)) // Before is earlier than after
                .build();
            
            // When & Then
            assertThatThrownBy(() -> userService.searchUsers(invalidCriteria))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("createdAfter cannot be after createdBefore");
        }
    }
    
    // Helper methods
    private User createTestUser() {
        return User.builder()
            .id(1L)
            .firstName("John")
            .lastName("Doe")
            .email("john@example.com")
            .status(UserStatus.ACTIVE)
            .createdAt(LocalDateTime.now())
            .build();
    }
    
    private UserResponse createTestUserResponse() {
        return UserResponse.builder()
            .id(1L)
            .firstName("John")
            .lastName("Doe")
            .email("john@example.com")
            .status("ACTIVE")
            .createdAt(LocalDateTime.now())
            .build();
    }
    
    private void setupSuccessfulUserCreation(
            CreateUserRequest request, 
            User savedUser, 
            UserResponse expectedResponse) {
        when(userRepository.existsByEmail(request.getEmail())).thenReturn(false);
        when(userMapper.toEntity(request)).thenReturn(savedUser);
        when(passwordEncoder.encode(request.getPassword())).thenReturn("encoded-password");
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(userMapper.toResponse(savedUser)).thenReturn(expectedResponse);
    }
}
```

### 2. Integration Testing

```java
@SpringBootTest
@Transactional
@TestPropertySource(properties = {
    "spring.datasource.url=jdbc:h2:mem:testdb",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "spring.sql.init.data-locations=classpath:test-data.sql"
})
@DisplayName("User Service Integration Tests")
class UserServiceIntegrationTest {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private TestEntityManager entityManager;
    
    @MockBean
    private EmailService emailService;
    
    @Test
    @DisplayName("Should create user and persist to database")
    void shouldCreateUserAndPersistToDatabase() {
        // Given
        CreateUserRequest request = CreateUserRequest.builder()
            .firstName("Integration")
            .lastName("Test")
            .email("integration@example.com")
            .password("SecurePass123!")
            .address(AddressDto.builder()
                .street("123 Test St")
                .city("Test City")
                .state("TS")
                .zipCode("12345")
                .country("Test Country")
                .build())
            .build();
        
        // When
        UserResponse result = userService.createUser(request);
        
        // Flush to database
        entityManager.flush();
        entityManager.clear();
        
        // Then
        assertThat(result.getId()).isNotNull();
        assertThat(result.getEmail()).isEqualTo("integration@example.com");
        
        // Verify persistence
        Optional<User> savedUser = userRepository.findById(result.getId());
        assertThat(savedUser)
            .isPresent()
            .get()
            .satisfies(user -> {
                assertThat(user.getEmail()).isEqualTo("integration@example.com");
                assertThat(user.getPassword()).isNotEqualTo("SecurePass123!"); // Should be encoded
                assertThat(user.getStatus()).isEqualTo(UserStatus.PENDING_VERIFICATION);
                assertThat(user.getCreatedAt()).isNotNull();
                assertThat(user.getAddress()).isNotNull();
            });
        
        verify(emailService).sendWelcomeEmailAsync("integration@example.com", "Integration");
    }
    
    @Test
    @DisplayName("Should handle concurrent user creation attempts")
    void shouldHandleConcurrentUserCreation() throws Exception {
        // Given
        String email = "concurrent@example.com";
        CreateUserRequest request1 = CreateUserRequest.builder()
            .firstName("User1")
            .lastName("Test")
            .email(email)
            .password("password123")
            .build();
        
        CreateUserRequest request2 = CreateUserRequest.builder()
            .firstName("User2")
            .lastName("Test")
            .email(email)
            .password("password456")
            .build();
        
        // When - Execute requests concurrently
        ExecutorService executor = Executors.newFixedThreadPool(2);
        Future<UserResponse> future1 = executor.submit(() -> userService.createUser(request1));
        Future<UserResponse> future2 = executor.submit(() -> userService.createUser(request2));
        
        // Then - One should succeed, one should fail
        List<Future<UserResponse>> futures = List.of(future1, future2);
        List<Exception> exceptions = new ArrayList<>();
        List<UserResponse> responses = new ArrayList<>();
        
        for (Future<UserResponse> future : futures) {
            try {
                responses.add(future.get(5, TimeUnit.SECONDS));
            } catch (ExecutionException e) {
                exceptions.add((Exception) e.getCause());
            }
        }
        
        assertThat(responses).hasSize(1);
        assertThat(exceptions).hasSize(1);
        assertThat(exceptions.get(0)).isInstanceOf(UserAlreadyExistsException.class);
        
        executor.shutdown();
    }
    
    @Test
    @DisplayName("Should search users with complex criteria")
    void shouldSearchUsersWithComplexCriteria() {
        // Given - Create test data
        createTestUsers();
        entityManager.flush();
        entityManager.clear();
        
        UserSearchCriteria criteria = UserSearchCriteria.builder()
            .keyword("john")
            .status("ACTIVE")
            .createdAfter(LocalDate.now().minusDays(1))
            .page(0)
            .size(10)
            .sortBy("firstName")
            .sortDirection("ASC")
            .build();
        
        // When
        PagedResponse<UserResponse> result = userService.searchUsers(criteria);
        
        // Then
        assertThat(result.getContent())
            .isNotEmpty()
            .allSatisfy(user -> {
                assertThat(user.getFirstName().toLowerCase()).contains("john");
                assertThat(user.getStatus()).isEqualTo("ACTIVE");
            });
    }
    
    private void createTestUsers() {
        List<User> users = List.of(
            User.builder()
                .firstName("John")
                .lastName("Active")
                .email("john.active@example.com")
                .password("encoded")
                .status(UserStatus.ACTIVE)
                .createdAt(LocalDateTime.now())
                .build(),
            User.builder()
                .firstName("John")
                .lastName("Inactive")
                .email("john.inactive@example.com")
                .password("encoded")
                .status(UserStatus.INACTIVE)
                .createdAt(LocalDateTime.now())
                .build(),
            User.builder()
                .firstName("Jane")
                .lastName("Active")
                .email("jane.active@example.com")
                .password("encoded")
                .status(UserStatus.ACTIVE)
                .createdAt(LocalDateTime.now())
                .build()
        );
        
        users.forEach(entityManager::persist);
    }
}
```

### 3. Test Slices and Focused Testing

```java
/**
 * Repository layer testing
 */
@DataJpaTest
@DisplayName("User Repository Tests")
class UserRepositoryTest {
    
    @Autowired
    private TestEntityManager entityManager;
    
    @Autowired
    private UserRepository userRepository;
    
    @Test
    @DisplayName("Should find user by email")
    void shouldFindUserByEmail() {
        // Given
        User user = User.builder()
            .firstName("Test")
            .lastName("User")
            .email("test@example.com")
            .password("encoded")
            .status(UserStatus.ACTIVE)
            .createdAt(LocalDateTime.now())
            .build();
        
        entityManager.persistAndFlush(user);
        entityManager.clear();
        
        // When
        Optional<User> result = userRepository.findByEmail("test@example.com");
        
        // Then
        assertThat(result)
            .isPresent()
            .get()
            .satisfies(foundUser -> {
                assertThat(foundUser.getEmail()).isEqualTo("test@example.com");
                assertThat(foundUser.getFirstName()).isEqualTo("Test");
            });
    }
    
    @Test
    @DisplayName("Should check if user exists by email")
    void shouldCheckIfUserExistsByEmail() {
        // Given
        User user = User.builder()
            .firstName("Existing")
            .lastName("User")
            .email("existing@example.com")
            .password("encoded")
            .status(UserStatus.ACTIVE)
            .createdAt(LocalDateTime.now())
            .build();
        
        entityManager.persistAndFlush(user);
        
        // When & Then
        assertThat(userRepository.existsByEmail("existing@example.com")).isTrue();
        assertThat(userRepository.existsByEmail("nonexistent@example.com")).isFalse();
    }
    
    @Test
    @DisplayName("Should find users by status and creation date")
    void shouldFindUsersByStatusAndCreationDate() {
        // Given
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(1);
        
        User activeUser = createUser("active@example.com", UserStatus.ACTIVE, LocalDateTime.now());
        User inactiveUser = createUser("inactive@example.com", UserStatus.INACTIVE, LocalDateTime.now());
        User oldUser = createUser("old@example.com", UserStatus.ACTIVE, cutoffDate.minusHours(1));
        
        entityManager.persist(activeUser);
        entityManager.persist(inactiveUser);
        entityManager.persist(oldUser);
        entityManager.flush();
        
        // When
        List<User> result = userRepository.findByStatusAndCreatedAtAfter(UserStatus.ACTIVE, cutoffDate);
        
        // Then
        assertThat(result)
            .hasSize(1)
            .first()
            .satisfies(user -> {
                assertThat(user.getEmail()).isEqualTo("active@example.com");
                assertThat(user.getStatus()).isEqualTo(UserStatus.ACTIVE);
            });
    }
    
    private User createUser(String email, UserStatus status, LocalDateTime createdAt) {
        return User.builder()
            .firstName("Test")
            .lastName("User")
            .email(email)
            .password("encoded")
            .status(status)
            .createdAt(createdAt)
            .build();
    }
}

/**
 * JSON serialization testing
 */
@JsonTest
@DisplayName("User Response JSON Tests")
class UserResponseJsonTest {
    
    @Autowired
    private JacksonTester<UserResponse> json;
    
    @Test
    @DisplayName("Should serialize UserResponse to JSON correctly")
    void shouldSerializeUserResponseCorrectly() throws Exception {
        // Given
        UserResponse userResponse = UserResponse.builder()
            .id(1L)
            .firstName("John")
            .lastName("Doe")
            .email("john.doe@example.com")
            .status("ACTIVE")
            .createdAt(LocalDateTime.of(2024, 1, 15, 10, 30, 0))
            .lastLoginAt(LocalDateTime.of(2024, 1, 16, 14, 20, 0))
            .build();
        
        // When & Then
        assertThat(json.write(userResponse))
            .hasJsonPath("$.id")
            .hasJsonPath("$.firstName")
            .hasJsonPath("$.lastName")
            .hasJsonPath("$.email")
            .hasJsonPath("$.status")
            .hasJsonPath("$.fullName")
            .hasJsonPath("$.isActive")
            .extractingJsonPathStringValue("$.createdAt")
            .isEqualTo("2024-01-15T10:30:00");
    }
    
    @Test
    @DisplayName("Should deserialize JSON to UserResponse correctly")
    void shouldDeserializeUserResponseCorrectly() throws Exception {
        // Given
        String jsonContent = """
            {
                "id": 1,
                "firstName": "John",
                "lastName": "Doe",
                "email": "john.doe@example.com",
                "status": "ACTIVE",
                "createdAt": "2024-01-15T10:30:00"
            }
            """;
        
        // When & Then
        assertThat(json.parse(jsonContent))
            .satisfies(userResponse -> {
                assertThat(userResponse.getId()).isEqualTo(1L);
                assertThat(userResponse.getFirstName()).isEqualTo("John");
                assertThat(userResponse.getEmail()).isEqualTo("john.doe@example.com");
                assertThat(userResponse.getStatus()).isEqualTo("ACTIVE");
                assertThat(userResponse.getCreatedAt())
                    .isEqualTo(LocalDateTime.of(2024, 1, 15, 10, 30, 0));
            });
    }
}
```

### 4. Test Utilities and Fixtures

```java
/**
 * Test data builder for consistent test data creation
 */
public class TestDataBuilder {
    
    private TestDataBuilder() {}
    
    public static UserBuilder user() {
        return new UserBuilder();
    }
    
    public static CreateUserRequestBuilder createUserRequest() {
        return new CreateUserRequestBuilder();
    }
    
    public static class UserBuilder {
        private Long id = 1L;
        private String firstName = "Test";
        private String lastName = "User";
        private String email = "test@example.com";
        private String password = "encoded-password";
        private UserStatus status = UserStatus.ACTIVE;
        private LocalDateTime createdAt = LocalDateTime.now();
        
        public UserBuilder id(Long id) {
            this.id = id;
            return this;
        }
        
        public UserBuilder firstName(String firstName) {
            this.firstName = firstName;
            return this;
        }
        
        public UserBuilder lastName(String lastName) {
            this.lastName = lastName;
            return this;
        }
        
        public UserBuilder email(String email) {
            this.email = email;
            return this;
        }
        
        public UserBuilder password(String password) {
            this.password = password;
            return this;
        }
        
        public UserBuilder status(UserStatus status) {
            this.status = status;
            return this;
        }
        
        public UserBuilder createdAt(LocalDateTime createdAt) {
            this.createdAt = createdAt;
            return this;
        }
        
        public User build() {
            return User.builder()
                .id(id)
                .firstName(firstName)
                .lastName(lastName)
                .email(email)
                .password(password)
                .status(status)
                .createdAt(createdAt)
                .build();
        }
    }
    
    public static class CreateUserRequestBuilder {
        private String firstName = "Test";
        private String lastName = "User";
        private String email = "test@example.com";
        private String password = "TestPassword123!";
        
        public CreateUserRequestBuilder firstName(String firstName) {
            this.firstName = firstName;
            return this;
        }
        
        public CreateUserRequestBuilder lastName(String lastName) {
            this.lastName = lastName;
            return this;
        }
        
        public CreateUserRequestBuilder email(String email) {
            this.email = email;
            return this;
        }
        
        public CreateUserRequestBuilder password(String password) {
            this.password = password;
            return this;
        }
        
        public CreateUserRequest build() {
            return CreateUserRequest.builder()
                .firstName(firstName)
                .lastName(lastName)
                .email(email)
                .password(password)
                .build();
        }
    }
}

/**
 * Custom assertions for domain objects
 */
public class UserAssertions {
    
    public static UserAssert assertThat(User actual) {
        return new UserAssert(actual);
    }
    
    public static class UserAssert extends AbstractAssert<UserAssert, User> {
        
        public UserAssert(User actual) {
            super(actual, UserAssert.class);
        }
        
        public UserAssert hasEmail(String email) {
            isNotNull();
            if (!Objects.equals(actual.getEmail(), email)) {
                failWithMessage("Expected user email to be <%s> but was <%s>", 
                    email, actual.getEmail());
            }
            return this;
        }
        
        public UserAssert hasStatus(UserStatus status) {
            isNotNull();
            if (!Objects.equals(actual.getStatus(), status)) {
                failWithMessage("Expected user status to be <%s> but was <%s>", 
                    status, actual.getStatus());
            }
            return this;
        }
        
        public UserAssert hasFullName(String expectedFullName) {
            isNotNull();
            String actualFullName = actual.getFirstName() + " " + actual.getLastName();
            if (!Objects.equals(actualFullName, expectedFullName)) {
                failWithMessage("Expected user full name to be <%s> but was <%s>", 
                    expectedFullName, actualFullName);
            }
            return this;
        }
        
        public UserAssert wasCreatedAfter(LocalDateTime dateTime) {
            isNotNull();
            if (actual.getCreatedAt() == null || actual.getCreatedAt().isBefore(dateTime)) {
                failWithMessage("Expected user to be created after <%s> but was created at <%s>", 
                    dateTime, actual.getCreatedAt());
            }
            return this;
        }
    }
}
```

## JavaDoc Best Practices

### 1. Service Interface Documentation

```java
/**
 * Service for managing user accounts and related operations.
 * 
 * <p>This service provides comprehensive user management functionality including
 * user creation, updates, searches, and account lifecycle management. All operations
 * are transactional and include proper error handling and validation.</p>
 * 
 * <p>Usage example:</p>
 * <pre>{@code
 * UserService userService = // ... inject or create
 * 
 * // Create a new user
 * CreateUserRequest request = CreateUserRequest.builder()
 *     .firstName("John")
 *     .lastName("Doe")
 *     .email("john.doe@example.com")
 *     .password("SecurePassword123!")
 *     .build();
 *     
 * UserResponse user = userService.createUser(request);
 * 
 * // Search for users
 * UserSearchCriteria criteria = UserSearchCriteria.builder()
 *     .keyword("john")
 *     .status("ACTIVE")
 *     .build();
 *     
 * PagedResponse<UserResponse> results = userService.searchUsers(criteria);
 * }</pre>
 * 
 * @author Development Team
 * @version 1.0
 * @since 1.0
 * @see UserRepository
 * @see UserMapper
 */
public interface UserService {
    
    /**
     * Creates a new user account with the provided information.
     * 
     * <p>This method performs the following operations:</p>
     * <ul>
     *   <li>Validates that the email is unique</li>
     *   <li>Encodes the user's password securely</li>
     *   <li>Creates the user entity in the database</li>
     *   <li>Sends a welcome email asynchronously</li>
     *   <li>Returns the created user information</li>
     * </ul>
     * 
     * <p>The user will be created with {@link UserStatus#PENDING_VERIFICATION} status
     * and will need to verify their email before the account becomes fully active.</p>
     * 
     * @param request the user creation request containing user details
     * @return the created user response with generated ID and timestamps
     * @throws UserAlreadyExistsException if a user with the same email already exists
     * @throws ValidationException if the request data is invalid
     * @throws UserCreationException if user creation fails for any other reason
     * @see CreateUserRequest
     * @see UserResponse
     * @see UserStatus
     */
    UserResponse createUser(CreateUserRequest request);
    
    /**
     * Finds a user by their unique identifier.
     * 
     * <p>This is a read-only operation that retrieves user information
     * including their current status, profile details, and timestamps.</p>
     * 
     * @param id the unique user identifier, must not be null
     * @return an {@link Optional} containing the user if found, empty otherwise
     * @throws IllegalArgumentException if id is null
     * @throws UserDataAccessException if database access fails
     * @see UserResponse
     */
    Optional<UserResponse> findUserById(Long id);
    
    /**
     * Updates an existing user's information.
     * 
     * <p>This method allows updating user profile information such as name
     * and address. The email address and password cannot be updated through
     * this method for security reasons.</p>
     * 
     * <p><strong>Note:</strong> This method uses optimistic locking to prevent
     * concurrent modification conflicts. If another process modifies the user
     * between read and update, a {@link UserConcurrentModificationException}
     * will be thrown.</p>
     * 
     * @param id the unique identifier of the user to update
     * @param request the update request containing new user information
     * @return the updated user response
     * @throws UserNotFoundException if no user exists with the given ID
     * @throws UserConcurrentModificationException if the user was modified by another process
     * @throws ValidationException if the update data is invalid
     * @throws UserUpdateException if the update fails for any other reason
     * @see UpdateUserRequest
     * @see UserResponse
     */
    UserResponse updateUser(Long id, UpdateUserRequest request);
    
    /**
     * Searches for users based on the provided criteria with pagination support.
     * 
     * <p>This method supports flexible searching with the following capabilities:</p>
     * <ul>
     *   <li>Keyword search across first name, last name, and email</li>
     *   <li>Filtering by user status</li>
     *   <li>Date range filtering by creation date</li>
     *   <li>Pagination and sorting support</li>
     * </ul>
     * 
     * <p>The search is case-insensitive and uses partial matching for keywords.
     * Results are returned in a paginated format with metadata about total
     * results and page information.</p>
     * 
     * @param criteria the search criteria containing filters and search terms
     * @return a paginated response containing matching users and pagination metadata
     * @throws IllegalArgumentException if criteria validation fails
     * @throws UserSearchException if the search operation fails
     * @see UserSearchCriteria
     * @see PagedResponse
     */
    PagedResponse<UserResponse> searchUsers(UserSearchCriteria criteria);
    
    /**
     * Activates a user account, allowing them to use the system.
     * 
     * <p>This method transitions a user from {@link UserStatus#PENDING_VERIFICATION}
     * to {@link UserStatus#ACTIVE} status. Once activated, the user can log in
     * and access all system features.</p>
     * 
     * @param userId the unique identifier of the user to activate
     * @throws UserNotFoundException if no user exists with the given ID
     * @throws UserAlreadyActiveException if the user is already active
     * @throws UserActivationException if activation fails for any other reason
     * @see UserStatus
     */
    void activateUser(Long userId);
    
    /**
     * Deactivates a user account, preventing system access while preserving data.
     * 
     * <p>This is a soft deletion that marks the user as inactive but preserves
     * all user data and history. The user will not be able to log in but their
     * data remains in the system for audit and compliance purposes.</p>
     * 
     * @param userId the unique identifier of the user to deactivate
     * @throws UserNotFoundException if no user exists with the given ID
     * @throws UserDeactivationException if deactivation fails
     * @see UserStatus
     */
    void deactivateUser(Long userId);
}
```

### 2. Implementation Class Documentation

```java
/**
 * Default implementation of {@link UserService} providing comprehensive user management.
 * 
 * <p>This implementation uses Spring's transaction management for data consistency
 * and includes comprehensive error handling and logging. All public methods are
 * transactional with appropriate isolation levels.</p>
 * 
 * <p>Key features:</p>
 * <ul>
 *   <li>Automatic password encoding using bcrypt</li>
 *   <li>Asynchronous email notifications</li>
 *   <li>Optimistic locking for concurrent access</li>
 *   <li>Comprehensive audit logging</li>
 *   <li>Input validation and sanitization</li>
 * </ul>
 * 
 * @author Development Team
 * @version 1.0
 * @since 1.0
 */
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {
    
    /**
     * Repository for user data persistence operations.
     * <p>Provides CRUD operations and custom queries for user entities.</p>
     */
    private final UserRepository userRepository;
    
    /**
     * Password encoder for secure password hashing.
     * <p>Uses bcrypt algorithm with configurable strength for password security.</p>
     */
    private final PasswordEncoder passwordEncoder;
    
    /**
     * Service for sending email notifications.
     * <p>Handles asynchronous email delivery with retry mechanisms.</p>
     */
    private final EmailService emailService;
    
    /**
     * Mapper for converting between entities and DTOs.
     * <p>Provides efficient mapping using MapStruct code generation.</p>
     */
    private final UserMapper userMapper;
    
    /**
     * {@inheritDoc}
     * 
     * <p>Implementation notes:</p>
     * <ul>
     *   <li>Password is encoded using bcrypt with strength 12</li>
     *   <li>Welcome email is sent asynchronously and failures don't affect user creation</li>
     *   <li>User creation is logged for audit purposes</li>
     *   <li>Database constraints are handled gracefully with meaningful exceptions</li>
     * </ul>
     * 
     * @implNote This method is transactional with default isolation level.
     *           Email sending failures are logged but don't cause transaction rollback.
     */
    @Override
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        log.info("Creating user with email: {}", request.getEmail());
        
        try {
            // Validate business rules
            validateCreateUserRequest(request);
            
            // Create and save user entity
            User user = buildUserEntity(request);
            User savedUser = userRepository.save(user);
            
            // Send welcome email (non-blocking)
            sendWelcomeEmailSafely(savedUser);
            
            log.info("User created successfully: {}", savedUser.getId());
            return userMapper.toResponse(savedUser);
            
        } catch (DataIntegrityViolationException e) {
            handleDataIntegrityViolation(e, request.getEmail());
            throw new UserCreationException("User creation failed", e);
        } catch (ApplicationException e) {
            throw e; // Re-throw application exceptions
        } catch (Exception e) {
            log.error("Unexpected error creating user: {}", e.getMessage(), e);
            throw new UserCreationException("Failed to create user", e);
        }
    }
    
    /**
     * Validates the create user request against business rules.
     * 
     * <p>Validation includes:</p>
     * <ul>
     *   <li>Email uniqueness check</li>
     *   <li>Email domain validation against blacklist</li>
     *   <li>Password strength requirements</li>
     * </ul>
     * 
     * @param request the user creation request to validate
     * @throws UserAlreadyExistsException if email is already registered
     * @throws ValidationException if any validation rule fails
     */
    private void validateCreateUserRequest(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new UserAlreadyExistsException(request.getEmail());
        }
        
        if (isEmailBlacklisted(request.getEmail())) {
            throw new ValidationException("Email domain is not allowed");
        }
        
        validatePasswordStrength(request.getPassword());
    }
    
    /**
     * Builds a user entity from the creation request.
     * 
     * <p>Sets default values for system-managed fields such as creation timestamp
     * and initial status. The password is encoded before setting.</p>
     * 
     * @param request the user creation request
     * @return a new user entity ready for persistence
     */
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
    
    /**
     * Sends welcome email with error handling that doesn't affect user creation.
     * 
     * <p>Email failures are logged as warnings but don't cause the user creation
     * transaction to rollback. This ensures that temporary email service issues
     * don't prevent user registration.</p>
     * 
     * @param user the newly created user to send welcome email to
     */
    private void sendWelcomeEmailSafely(User user) {
        try {
            emailService.sendWelcomeEmailAsync(user.getEmail(), user.getFirstName());
        } catch (Exception e) {
            log.warn("Failed to send welcome email to {}: {}", 
                user.getEmail(), e.getMessage());
            // Don't rethrow - email failure shouldn't prevent user creation
        }
    }
    
    /**
     * Handles data integrity violations with specific error mapping.
     * 
     * <p>Maps database constraint violations to meaningful business exceptions
     * that can be properly handled by the client.</p>
     * 
     * @param e the data integrity violation exception
     * @param email the email that caused the violation
     * @throws UserAlreadyExistsException if the violation is due to email uniqueness
     */
    private void handleDataIntegrityViolation(DataIntegrityViolationException e, String email) {
        if (e.getMessage().contains("email")) {
            throw new UserAlreadyExistsException(email);
        }
        log.error("Unhandled data integrity violation: {}", e.getMessage());
    }
    
    /**
     * Validates password strength according to security policy.
     * 
     * <p>Current requirements:</p>
     * <ul>
     *   <li>Minimum 8 characters</li>
     *   <li>At least one uppercase letter</li>
     *   <li>At least one lowercase letter</li>
     *   <li>At least one digit</li>
     *   <li>At least one special character</li>
     * </ul>
     * 
     * @param password the password to validate
     * @throws ValidationException if password doesn't meet requirements
     */
    private void validatePasswordStrength(String password) {
        if (password.length() < 8) {
            throw new ValidationException("Password must be at least 8 characters long");
        }
        
        if (!password.matches(".*[A-Z].*")) {
            throw new ValidationException("Password must contain at least one uppercase letter");
        }
        
        if (!password.matches(".*[a-z].*")) {
            throw new ValidationException("Password must contain at least one lowercase letter");
        }
        
        if (!password.matches(".*\\d.*")) {
            throw new ValidationException("Password must contain at least one digit");
        }
        
        if (!password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>?].*")) {
            throw new ValidationException("Password must contain at least one special character");
        }
    }
    
    /**
     * Checks if an email domain is blacklisted.
     * 
     * <p>This method can be extended to check against a configurable blacklist
     * of email domains that are not allowed for registration.</p>
     * 
     * @param email the email address to check
     * @return true if the email domain is blacklisted, false otherwise
     */
    private boolean isEmailBlacklisted(String email) {
        // Implementation would check against configured blacklist
        String domain = email.substring(email.indexOf('@') + 1);
        List<String> blacklistedDomains = List.of("tempmail.com", "10minutemail.com");
        return blacklistedDomains.contains(domain.toLowerCase());
    }
}
```

### 3. DTO and Entity Documentation

```java
/**
 * Request DTO for creating a new user account.
 * 
 * <p>This immutable data transfer object encapsulates all the information
 * required to create a new user account. It includes comprehensive validation
 * annotations to ensure data integrity at the API boundary.</p>
 * 
 * <p>Example usage:</p>
 * <pre>{@code
 * CreateUserRequest request = CreateUserRequest.builder()
 *     .firstName("John")
 *     .lastName("Doe")
 *     .email("john.doe@example.com")
 *     .password("SecurePass123!")
 *     .address(AddressDto.builder()
 *         .street("123 Main St")
 *         .city("Anytown")
 *         .state("ST")
 *         .zipCode("12345")
 *         .country("USA")
 *         .build())
 *     .build();
 * }</pre>
 * 
 * @author Development Team
 * @version 1.0
 * @since 1.0
 * @see UserResponse
 * @see AddressDto
 */
@Value
@Builder
@JsonDeserialize(builder = CreateUserRequest.CreateUserRequestBuilder.class)
public class CreateUserRequest {
    
    /**
     * The user's first name.
     * <p>Must be between 2 and 50 characters and cannot be blank.</p>
     */
    @NotBlank(message = "First name is required")
    @Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters")
    String firstName;
    
    /**
     * The user's last name.
     * <p>Must be between 2 and 50 characters and cannot be blank.</p>
     */
    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
    String lastName;
    
    /**
     * The user's email address.
     * <p>Must be a valid email format and will be used as the login identifier.
     * Email addresses are case-insensitive and must be unique across the system.</p>
     */
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    String email;
    
    /**
     * The user's password.
     * <p>Must meet security requirements:</p>
     * <ul>
     *   <li>Minimum 8 characters</li>
     *   <li>At least one uppercase letter</li>
     *   <li>At least one lowercase letter</li>
     *   <li>At least one digit</li>
     *   <li>At least one special character</li>
     * </ul>
     */
    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 100, message = "Password must be between 8 and 100 characters")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&].*$", 
             message = "Password must contain at least one lowercase, one uppercase, one digit, and one special character")
    String password;
    
    /**
     * The user's address information.
     * <p>Required for user registration and used for billing and shipping purposes.</p>
     */
    @Valid
    @NotNull(message = "Address is required")
    AddressDto address;
    
    /**
     * Builder configuration for JSON deserialization.
     * <p>Required for proper Jackson JSON deserialization support.</p>
     */
    @JsonPOJOBuilder(withPrefix = "")
    public static class CreateUserRequestBuilder { }
}

/**
 * User entity representing a system user account.
 * 
 * <p>This JPA entity encapsulates all user information including authentication
 * credentials, profile data, and system metadata. The entity uses optimistic
 * locking to handle concurrent updates safely.</p>
 * 
 * <p>Key features:</p>
 * <ul>
 *   <li>Automatic timestamp management for creation and updates</li>
 *   <li>Optimistic locking with version field</li>
 *   <li>Soft deletion support through status field</li>
 *   <li>Cascade operations for related entities</li>
 * </ul>
 * 
 * <p><strong>Security Note:</strong> The password field is excluded from
 * toString() output to prevent accidental logging of sensitive information.</p>
 * 
 * @author Development Team
 * @version 1.0
 * @since 1.0
 * @see UserStatus
 * @see Address
 */
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_status", columnList = "status"),
    @Index(name = "idx_user_created_at", columnList = "created_at")
})
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(exclude = {"password", "orders"}) // Exclude sensitive and lazy fields
public class User {
    
    /**
     * The unique identifier for this user.
     * <p>Auto-generated using database identity strategy.</p>
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;
    
    /**
     * The user's first name.
     * <p>Cannot be null and has a maximum length of 50 characters.</p>
     */
    @Column(name = "first_name", nullable = false, length = 50)
    private String firstName;
    
    /**
     * The user's last name.
     * <p>Cannot be null and has a maximum length of 50 characters.</p>
     */
    @Column(name = "last_name", nullable = false, length = 50)
    private String lastName;
    
    /**
     * The user's unique email address.
     * <p>Used as the login identifier. Must be unique across all users.</p>
     */
    @Column(name = "email", nullable = false, unique = true, length = 255)
    @EqualsAndHashCode.Include
    private String email;
    
    /**
     * The user's encrypted password.
     * <p>Stored as a bcrypt hash. The plain text password is never persisted.</p>
     */
    @Column(name = "password", nullable = false)
    private String password;
    
    /**
     * The current status of the user account.
     * <p>Determines whether the user can access the system and what
     * functionality is available to them.</p>
     * 
     * @see UserStatus
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private UserStatus status;
    
    /**
     * Timestamp when the user account was created.
     * <p>Automatically set when the entity is first persisted.</p>
     */
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    /**
     * Timestamp when the user account was last updated.
     * <p>Automatically updated whenever the entity is modified.</p>
     */
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    /**
     * Timestamp when the user last logged into the system.
     * <p>Updated each time the user successfully authenticates.</p>
     */
    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;
    
    /**
     * Version field for optimistic locking.
     * <p>Automatically managed by JPA to prevent concurrent modification conflicts.</p>
     */
    @Version
    private Long version;
    
    /**
     * The user's address information.
     * <p>Embedded value object containing address details.</p>
     */
    @Embedded
    private Address address;
    
    /**
     * Orders placed by this user.
     * <p>Lazy-loaded collection of orders. Excluded from toString to prevent
     * N+1 query issues during logging.</p>
     */
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<Order> orders = new ArrayList<>();
    
    /**
     * Lifecycle callback to set creation timestamp.
     * <p>Called automatically before the entity is first persisted.</p>
     */
    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * Lifecycle callback to update modification timestamp.
     * <p>Called automatically before the entity is updated.</p>
     */
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * Marks the user as deleted by setting status to INACTIVE.
     * <p>This is a soft delete operation that preserves the user data
     * while preventing system access.</p>
     */
    public void markAsDeleted() {
        this.status = UserStatus.INACTIVE;
        this.updatedAt = LocalDateTime.now();
    }
    
    /**
     * Checks if the user account is currently active.
     * 
     * @return true if the user status is ACTIVE, false otherwise
     */
    public boolean isActive() {
        return UserStatus.ACTIVE.equals(this.status);
    }
    
    /**
     * Gets the user's full name.
     * 
     * @return the concatenated first and last name
     */
    public String getFullName() {
        return firstName + " " + lastName;
    }
    
    /**
     * Checks if the user has any active orders.
     * 
     * @return true if the user has orders with non-terminal status
     */
    public boolean hasActiveOrders() {
        return orders != null && orders.stream()
            .anyMatch(order -> !order.getStatus().isTerminal());
    }
}
```

## Code Documentation Standards

### 1. Package Documentation

```java
/**
 * User management service layer components.
 * 
 * <p>This package contains all service classes and interfaces responsible for
 * user account management, including creation, updates, authentication, and
 * lifecycle management.</p>
 * 
 * <p>Key components:</p>
 * <ul>
 *   <li>{@link UserService} - Main service interface for user operations</li>
 *   <li>{@link UserServiceImpl} - Default implementation with full functionality</li>
 *   <li>{@link UserValidationService} - Specialized validation logic</li>
 *   <li>{@link UserNotificationService} - User notification handling</li>
 * </ul>
 * 
 * <p>All services in this package are transactional and include comprehensive
 * error handling. They follow the established patterns for dependency injection,
 * logging, and exception management.</p>
 * 
 * @author Development Team
 * @version 1.0
 * @since 1.0
 */
package com.example.service.user;
```

### 2. Configuration Documentation

```java
/**
 * Configuration class for user management services.
 * 
 * <p>This configuration class sets up all beans and infrastructure required
 * for user management functionality, including password encoding, validation,
 * and notification services.</p>
 * 
 * <p>Key configurations:</p>
 * <ul>
 *   <li>Password encoder with bcrypt strength 12</li>
 *   <li>User validation rules and constraints</li>
 *   <li>Email template configuration</li>
 *   <li>Audit logging setup</li>
 * </ul>
 * 
 * @author Development Team
 * @version 1.0
 * @since 1.0
 */
@Configuration
@EnableConfigurationProperties({UserProperties.class, SecurityProperties.class})
@ConditionalOnProperty(name = "app.features.user-management.enabled", havingValue = "true", matchIfMissing = true)
public class UserServiceConfiguration {
    
    /**
     * Creates a password encoder bean with secure bcrypt configuration.
     * 
     * <p>Uses bcrypt with strength 12 which provides a good balance between
     * security and performance. The strength can be adjusted via configuration
     * properties if needed.</p>
     * 
     * @param securityProperties security configuration properties
     * @return configured password encoder instance
     * @see SecurityProperties#getPasswordEncoderStrength()
     */
    @Bean
    @ConditionalOnMissingBean
    public PasswordEncoder passwordEncoder(SecurityProperties securityProperties) {
        return new BCryptPasswordEncoder(securityProperties.getPasswordEncoderStrength());
    }
    
    /**
     * Creates a user validator bean with custom validation rules.
     * 
     * <p>This validator includes business-specific validation logic that goes
     * beyond standard JSR-303 bean validation, such as email domain checking
     * and password complexity requirements.</p>
     * 
     * @param userProperties user management configuration properties
     * @return configured user validator instance
     */
    @Bean
    public UserValidator userValidator(UserProperties userProperties) {
        return new UserValidator(userProperties.getValidation());
    }
}
```

## Summary

Testing and documentation best practices for Spring Boot service layers:

1. **Comprehensive Testing Strategy** - Unit tests, integration tests, and test slices
2. **Test Organization** - Use `@Nested` classes and descriptive test names
3. **Test Data Management** - Builder pattern and test fixtures for consistency
4. **Mock Management** - Proper mock setup and verification
5. **JavaDoc Standards** - Complete documentation with examples and usage notes
6. **Package Documentation** - Overview documentation for packages and modules
7. **Configuration Documentation** - Clear documentation of configuration classes and beans
8. **Code Examples** - Include practical examples in documentation

Next: [Performance & Security](performance-security)