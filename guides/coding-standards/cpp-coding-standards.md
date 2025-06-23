# C++ Coding Standards - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Code Formatting
- **Formatter**: clang-format
- **Standard**: C++17 or C++20
- **Line Length**: 120 characters
- **Indentation**: 4 spaces (no tabs)

### File Organization
```cpp
// header.hpp
#pragma once

#include <memory>
#include <string>
#include <vector>

namespace company::module {

class UserService {
public:
    // Constructor
    explicit UserService(std::shared_ptr<Database> db);
    
    // Destructor
    ~UserService() = default;
    
    // Public methods
    std::optional<User> findById(int64_t id) const;
    bool createUser(const User& user);
    
private:
    // Private members
    std::shared_ptr<Database> database_;
    static constexpr int MAX_RETRY_COUNT = 3;
};

} // namespace company::module
```

```cpp
// implementation.cpp
#include "header.hpp"
#include <iostream>
#include <stdexcept>

namespace company::module {

UserService::UserService(std::shared_ptr<Database> db) 
    : database_(std::move(db)) {
    if (!database_) {
        throw std::invalid_argument("Database cannot be null");
    }
}

std::optional<User> UserService::findById(int64_t id) const {
    if (id <= 0) {
        return std::nullopt;
    }
    
    return database_->findUser(id);
}

} // namespace company::module
```

## IMPLEMENTATION STRATEGY

### Naming Conventions
- **Classes**: PascalCase (`UserService`, `DatabaseManager`)
- **Functions**: camelCase (`getUserById`, `validateInput`)
- **Variables**: snake_case (`user_name`, `is_valid`)
- **Constants**: SCREAMING_SNAKE_CASE (`MAX_RETRY_COUNT`)
- **Private Members**: snake_case with trailing underscore (`database_`, `user_count_`)
- **Namespaces**: lowercase with :: (`company::module`)

### Modern C++ Features
```cpp
// Use auto for type deduction
auto users = database_->getAllUsers();

// Use range-based for loops
for (const auto& user : users) {
    processUser(user);
}

// Use smart pointers
std::unique_ptr<User> createUser(const std::string& name) {
    return std::make_unique<User>(name);
}

// Use RAII for resource management
class FileHandler {
public:
    explicit FileHandler(const std::string& filename) 
        : file_(filename, std::ios::binary) {
        if (!file_.is_open()) {
            throw std::runtime_error("Failed to open file");
        }
    }
    
private:
    std::fstream file_;
};
```

### Error Handling
```cpp
// Use exceptions for error conditions
void validateUser(const User& user) {
    if (user.getName().empty()) {
        throw std::invalid_argument("User name cannot be empty");
    }
}

// Use std::optional for potentially missing values
std::optional<int> parseInteger(const std::string& str) {
    try {
        return std::stoi(str);
    } catch (const std::exception&) {
        return std::nullopt;
    }
}
```

### Memory Management
```cpp
// Prefer stack allocation
User user{"John", "john@example.com"};

// Use smart pointers for dynamic allocation
auto user_ptr = std::make_unique<User>("John", "john@example.com");

// Use shared_ptr for shared ownership
std::shared_ptr<Database> database = std::make_shared<Database>();
```

## CLAUDE_CODE_COMMANDS

```bash
# Format code with clang-format
clang-format -i -style=file **/*.cpp **/*.hpp

# Static analysis with clang-tidy
clang-tidy **/*.cpp -- -std=c++17

# Build with CMake
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
```

## VALIDATION_CHECKLIST
- [ ] All classes follow PascalCase naming
- [ ] All functions follow camelCase naming
- [ ] All variables follow snake_case naming
- [ ] Private members have trailing underscore
- [ ] Smart pointers used for dynamic allocation
- [ ] RAII principles applied
- [ ] clang-format passes without changes
- [ ] No raw pointers for ownership