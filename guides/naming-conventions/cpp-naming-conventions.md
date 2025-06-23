# C++ Naming Conventions - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Classes and Structs
```cpp
// Classes: PascalCase
class UserService;
class DatabaseManager;
class PaymentProcessor;

// Structs: PascalCase
struct User {
    int64_t id;
    std::string name;
    std::string email;
};

struct ApiResponse {
    bool success;
    std::string message;
    int status_code;
};

// Abstract classes: PascalCase
class AbstractValidator {
public:
    virtual ~AbstractValidator() = default;
    virtual bool validate() const = 0;
};
```

### Functions and Variables
```cpp
// Functions: camelCase
User getUserById(int64_t id);
bool validateEmailAddress(const std::string& email);
double calculateTotalPrice(const std::vector<Item>& items);

// Variables: snake_case
std::string user_name;
bool is_active;
std::chrono::system_clock::time_point created_at;
std::optional<std::chrono::system_clock::time_point> last_login_time;

// Member variables: snake_case with trailing underscore
class UserService {
private:
    std::shared_ptr<Database> database_;
    std::string connection_string_;
    int retry_count_;
    bool is_initialized_;
};
```

## IMPLEMENTATION STRATEGY

### Constants and Enums
```cpp
// Constants: SCREAMING_SNAKE_CASE
const int MAX_RETRY_COUNT = 3;
const int DEFAULT_TIMEOUT_SECONDS = 30;
const std::string API_BASE_URL = "https://api.example.com";

// Class constants
class UserService {
private:
    static constexpr int DEFAULT_PAGE_SIZE = 20;
    static constexpr int MAX_USERNAME_LENGTH = 50;
};

// Enums: PascalCase for enum class, SCREAMING_SNAKE_CASE for values
enum class UserStatus {
    ACTIVE,
    INACTIVE,
    SUSPENDED,
    PENDING_VERIFICATION
};

enum class PaymentMethod {
    CREDIT_CARD,
    DEBIT_CARD,
    PAYPAL,
    BANK_TRANSFER
};
```

### Namespaces
```cpp
// Namespaces: lowercase with underscores
namespace company_name {
namespace user_service {
namespace domain {

class User {
    // Implementation
};

} // namespace domain
} // namespace user_service
} // namespace company_name

// Avoid abbreviations
namespace company_name::user_service::configuration // Good
namespace company_name::user_service::config        // Avoid

// Use descriptive names
namespace company_name::user_service::exceptions    // Good
namespace company_name::user_service::exc          // Avoid
```

### Templates and Generic Types
```cpp
// Template parameters: PascalCase
template<typename T>
class Repository {
public:
    std::optional<T> findById(int64_t id) const;
    bool save(const T& entity);
};

template<typename DataType, typename ErrorType>
class Result {
private:
    std::variant<DataType, ErrorType> value_;
};

// Template specializations
template<>
class Repository<User> {
    // Specialized implementation
};
```

### Files and Directories
```cpp
// Header files: PascalCase + .hpp
UserService.hpp          // contains class UserService
DatabaseManager.hpp     // contains class DatabaseManager
PaymentProcessor.hpp    // contains class PaymentProcessor

// Source files: PascalCase + .cpp
UserService.cpp         // implementation for UserService
DatabaseManager.cpp    // implementation for DatabaseManager
PaymentProcessor.cpp   // implementation for PaymentProcessor

// Utility headers: descriptive + Utils.hpp
StringUtils.hpp        // String utility functions
DateUtils.hpp         // Date utility functions
ValidationUtils.hpp   // Validation utility functions
```

### Function Parameters and Local Variables
```cpp
// Function parameters: snake_case
User createUser(
    const std::string& user_name,
    const std::string& email_address,
    bool is_active,
    int64_t created_by
);

// Local variables: snake_case
void processUser() {
    const auto current_user = getCurrentUser();
    const auto user_permissions = getPermissions(current_user.id);
    int attempt_count = 0;
    
    for (const auto& permission : user_permissions) {
        // Process permission
    }
}

// Lambda parameters: snake_case
auto users = getAllUsers();
std::sort(users.begin(), users.end(), 
    [](const User& left_user, const User& right_user) {
        return left_user.name < right_user.name;
    });
```

### Macros and Preprocessor
```cpp
// Macros: SCREAMING_SNAKE_CASE
#define MAX_BUFFER_SIZE 1024
#define VALIDATE_POINTER(ptr) \
    do { \
        if (!(ptr)) { \
            throw std::invalid_argument("Pointer cannot be null"); \
        } \
    } while (0)

// Header guards: SCREAMING_SNAKE_CASE with path
#ifndef COMPANY_USER_SERVICE_USER_HPP
#define COMPANY_USER_SERVICE_USER_HPP
// Header content
#endif // COMPANY_USER_SERVICE_USER_HPP
```

### Exception Classes
```cpp
// Custom exceptions: PascalCase + Exception suffix
class UserNotFoundException : public std::runtime_error {
public:
    explicit UserNotFoundException(const std::string& message)
        : std::runtime_error(message) {}
};

class InvalidEmailException : public std::invalid_argument {
public:
    explicit InvalidEmailException(const std::string& email)
        : std::invalid_argument("Invalid email: " + email) {}
};

class PaymentProcessingException : public std::runtime_error {
public:
    PaymentProcessingException(const std::string& message, int error_code)
        : std::runtime_error(message), error_code_(error_code) {}
    
    int getErrorCode() const { return error_code_; }

private:
    int error_code_;
};
```

### Test Classes
```cpp
// Test files: ClassName + Test.cpp
UserServiceTest.cpp
DatabaseManagerTest.cpp
PaymentProcessorTest.cpp

// Test fixtures: ClassName + TestFixture
class UserServiceTestFixture : public ::testing::Test {
protected:
    void SetUp() override {
        user_service_ = std::make_unique<UserService>(mock_database_);
    }
    
    void TearDown() override {
        user_service_.reset();
    }
    
    std::unique_ptr<UserService> user_service_;
    MockDatabase mock_database_;
};

// Test cases: descriptive snake_case
TEST_F(UserServiceTestFixture, should_return_user_when_valid_id_provided) {
    // Test implementation
}

TEST_F(UserServiceTestFixture, should_throw_exception_when_user_not_found) {
    // Test implementation
}
```

## CLAUDE_CODE_COMMANDS

```bash
# Check naming conventions with clang-tidy
clang-tidy **/*.cpp **/*.hpp -- -std=c++17

# Format code with clang-format
clang-format -i -style=file **/*.cpp **/*.hpp

# Static analysis with cppcheck
cppcheck --enable=all --std=c++17 src/
```

## VALIDATION_CHECKLIST
- [ ] All classes use PascalCase
- [ ] All functions use camelCase
- [ ] All variables use snake_case
- [ ] Member variables have trailing underscore
- [ ] Constants use SCREAMING_SNAKE_CASE
- [ ] Namespaces use snake_case
- [ ] File names match class names
- [ ] No abbreviations in names
- [ ] Template parameters use PascalCase