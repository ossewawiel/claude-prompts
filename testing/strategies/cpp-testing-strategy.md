# C++ Testing Strategy - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Dependencies (CMake)
```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(MyProject VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find packages
find_package(GTest REQUIRED)
find_package(GMock REQUIRED)

# Enable testing
enable_testing()

# Test executable
add_executable(tests
    tests/test_main.cpp
    tests/user_service_test.cpp
    tests/database_manager_test.cpp
    tests/integration_test.cpp
)

target_link_libraries(tests
    PRIVATE
    GTest::gtest
    GTest::gtest_main
    GTest::gmock
    ${PROJECT_NAME}_lib
)

# Register tests with CTest
gtest_discover_tests(tests)

# Coverage target
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(tests PRIVATE --coverage)
    target_link_options(tests PRIVATE --coverage)
endif()
```

### Test Framework Setup
```cpp
// tests/test_main.cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    ::testing::InitGoogleMock(&argc, argv);
    return RUN_ALL_TESTS();
}
```

## IMPLEMENTATION STRATEGY

### Unit Testing with Google Test
```cpp
// tests/user_service_test.cpp
#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "user_service.hpp"
#include "mock_database.hpp"

using ::testing::_;
using ::testing::Return;
using ::testing::StrictMock;
using ::testing::NiceMock;

class UserServiceTest : public ::testing::Test {
protected:
    void SetUp() override {
        mock_database_ = std::make_shared<StrictMock<MockDatabase>>();
        user_service_ = std::make_unique<UserService>(mock_database_);
    }
    
    void TearDown() override {
        user_service_.reset();
        mock_database_.reset();
    }
    
    std::shared_ptr<MockDatabase> mock_database_;
    std::unique_ptr<UserService> user_service_;
};

TEST_F(UserServiceTest, ShouldCreateUserWithValidData) {
    // Arrange
    const UserData user_data{
        .first_name = "John",
        .last_name = "Doe",
        .email = "john.doe@example.com"
    };
    
    const User expected_user{
        .id = 1,
        .first_name = "John",
        .last_name = "Doe",
        .email = "john.doe@example.com",
        .is_active = true
    };
    
    EXPECT_CALL(*mock_database_, insert(user_data))
        .WillOnce(Return(expected_user));
    
    // Act
    const auto result = user_service_->create_user(user_data);
    
    // Assert
    ASSERT_TRUE(result.has_value());
    EXPECT_EQ(result->id, 1);
    EXPECT_EQ(result->first_name, "John");
    EXPECT_EQ(result->last_name, "Doe");
    EXPECT_EQ(result->email, "john.doe@example.com");
    EXPECT_TRUE(result->is_active);
}

TEST_F(UserServiceTest, ShouldReturnErrorForInvalidEmail) {
    // Arrange
    const UserData invalid_user_data{
        .first_name = "John",
        .last_name = "Doe",
        .email = "invalid-email"
    };
    
    // Act
    const auto result = user_service_->create_user(invalid_user_data);
    
    // Assert
    ASSERT_FALSE(result.has_value());
    EXPECT_EQ(result.error(), UserServiceError::INVALID_EMAIL);
}

TEST_F(UserServiceTest, ShouldHandleDatabaseErrors) {
    // Arrange
    const UserData user_data{
        .first_name = "John",
        .last_name = "Doe",
        .email = "john.doe@example.com"
    };
    
    EXPECT_CALL(*mock_database_, insert(user_data))
        .WillOnce(Return(DatabaseError::CONNECTION_FAILED));
    
    // Act
    const auto result = user_service_->create_user(user_data);
    
    // Assert
    ASSERT_FALSE(result.has_value());
    EXPECT_EQ(result.error(), UserServiceError::DATABASE_ERROR);
}

// Parameterized tests for edge cases
class EmailValidationTest : public ::testing::TestWithParam<std::pair<std::string, bool>> {};

TEST_P(EmailValidationTest, ShouldValidateEmailCorrectly) {
    const auto& [email, expected_valid] = GetParam();
    
    const bool is_valid = UserService::is_valid_email(email);
    
    EXPECT_EQ(is_valid, expected_valid) << "Email: " << email;
}

INSTANTIATE_TEST_SUITE_P(
    EmailValidationCases,
    EmailValidationTest,
    ::testing::Values(
        std::make_pair("user@example.com", true),
        std::make_pair("user.name@example.com", true),
        std::make_pair("user+tag@example.com", true),
        std::make_pair("invalid-email", false),
        std::make_pair("@example.com", false),
        std::make_pair("user@", false),
        std::make_pair("", false)
    )
);
```

### Mock Objects
```cpp
// tests/mock_database.hpp
#pragma once
#include <gmock/gmock.h>
#include "database_interface.hpp"

class MockDatabase : public DatabaseInterface {
public:
    MOCK_METHOD(std::expected<User, DatabaseError>, insert, 
                (const UserData& user_data), (override));
    
    MOCK_METHOD(std::expected<User, DatabaseError>, find_by_id, 
                (int64_t id), (const, override));
    
    MOCK_METHOD(std::expected<std::vector<User>, DatabaseError>, find_by_email, 
                (const std::string& email), (const, override));
    
    MOCK_METHOD(std::expected<void, DatabaseError>, update, 
                (const User& user), (override));
    
    MOCK_METHOD(std::expected<void, DatabaseError>, remove, 
                (int64_t id), (override));
    
    MOCK_METHOD(bool, is_connected, (), (const, override));
    
    MOCK_METHOD(std::expected<void, DatabaseError>, begin_transaction, (), (override));
    MOCK_METHOD(std::expected<void, DatabaseError>, commit_transaction, (), (override));
    MOCK_METHOD(std::expected<void, DatabaseError>, rollback_transaction, (), (override));
};

// Mock factory for easier test setup
class MockDatabaseFactory {
public:
    static std::shared_ptr<MockDatabase> create_strict() {
        return std::make_shared<::testing::StrictMock<MockDatabase>>();
    }
    
    static std::shared_ptr<MockDatabase> create_nice() {
        return std::make_shared<::testing::NiceMock<MockDatabase>>();
    }
};
```

### Integration Testing
```cpp
// tests/integration_test.cpp
#include <gtest/gtest.h>
#include "user_service.hpp"
#include "postgresql_database.hpp"
#include "test_database_fixture.hpp"

class UserServiceIntegrationTest : public TestDatabaseFixture {
protected:
    void SetUp() override {
        TestDatabaseFixture::SetUp();
        database_ = std::make_shared<PostgreSQLDatabase>(connection_string_);
        user_service_ = std::make_unique<UserService>(database_);
    }
    
    void TearDown() override {
        user_service_.reset();
        database_.reset();
        TestDatabaseFixture::TearDown();
    }
    
    std::shared_ptr<PostgreSQLDatabase> database_;
    std::unique_ptr<UserService> user_service_;
};

TEST_F(UserServiceIntegrationTest, ShouldCreateAndRetrieveUser) {
    // Arrange
    const UserData user_data{
        .first_name = "John",
        .last_name = "Doe",
        .email = "john.doe@example.com"
    };
    
    // Act - Create user
    const auto created_user = user_service_->create_user(user_data);
    ASSERT_TRUE(created_user.has_value());
    
    // Act - Retrieve user
    const auto retrieved_user = user_service_->find_by_id(created_user->id);
    
    // Assert
    ASSERT_TRUE(retrieved_user.has_value());
    EXPECT_EQ(retrieved_user->id, created_user->id);
    EXPECT_EQ(retrieved_user->first_name, "John");
    EXPECT_EQ(retrieved_user->last_name, "Doe");
    EXPECT_EQ(retrieved_user->email, "john.doe@example.com");
}

TEST_F(UserServiceIntegrationTest, ShouldHandleUniqueConstraintViolation) {
    // Arrange
    const UserData user_data{
        .first_name = "John",
        .last_name = "Doe",
        .email = "john.doe@example.com"
    };
    
    // Act - Create first user
    const auto first_user = user_service_->create_user(user_data);
    ASSERT_TRUE(first_user.has_value());
    
    // Act - Try to create second user with same email
    const auto duplicate_user = user_service_->create_user(user_data);
    
    // Assert
    ASSERT_FALSE(duplicate_user.has_value());
    EXPECT_EQ(duplicate_user.error(), UserServiceError::EMAIL_ALREADY_EXISTS);
}
```

### Performance Testing
```cpp
// tests/performance_test.cpp
#include <gtest/gtest.h>
#include <chrono>
#include <vector>
#include <random>
#include "user_service.hpp"
#include "test_database_fixture.hpp"

class UserServicePerformanceTest : public TestDatabaseFixture {
protected:
    void SetUp() override {
        TestDatabaseFixture::SetUp();
        database_ = std::make_shared<PostgreSQLDatabase>(connection_string_);
        user_service_ = std::make_unique<UserService>(database_);
    }
    
    std::vector<UserData> generate_test_users(size_t count) {
        std::vector<UserData> users;
        users.reserve(count);
        
        std::random_device rd;
        std::mt19937 gen(rd());
        
        for (size_t i = 0; i < count; ++i) {
            users.emplace_back(UserData{
                .first_name = "User" + std::to_string(i),
                .last_name = "Test" + std::to_string(i),
                .email = "user" + std::to_string(i) + "@test.com"
            });
        }
        
        return users;
    }
    
    std::shared_ptr<PostgreSQLDatabase> database_;
    std::unique_ptr<UserService> user_service_;
};

TEST_F(UserServicePerformanceTest, ShouldCreateUsersWithinTimeLimit) {
    // Arrange
    const size_t user_count = 1000;
    const auto test_users = generate_test_users(user_count);
    
    // Act
    const auto start_time = std::chrono::high_resolution_clock::now();
    
    for (const auto& user_data : test_users) {
        const auto result = user_service_->create_user(user_data);
        ASSERT_TRUE(result.has_value()) << "Failed to create user: " << user_data.email;
    }
    
    const auto end_time = std::chrono::high_resolution_clock::now();
    const auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
        end_time - start_time
    );
    
    // Assert - Should complete within 5 seconds
    EXPECT_LT(duration.count(), 5000) 
        << "Creating " << user_count << " users took " << duration.count() << "ms";
}

TEST_F(UserServicePerformanceTest, ShouldSearchUsersEfficiently) {
    // Arrange - Create test data
    const size_t user_count = 10000;
    const auto test_users = generate_test_users(user_count);
    
    for (const auto& user_data : test_users) {
        user_service_->create_user(user_data);
    }
    
    // Act - Search for users
    const auto start_time = std::chrono::high_resolution_clock::now();
    
    const auto results = user_service_->search_by_name("User");
    
    const auto end_time = std::chrono::high_resolution_clock::now();
    const auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
        end_time - start_time
    );
    
    // Assert
    ASSERT_TRUE(results.has_value());
    EXPECT_GT(results->size(), 0);
    
    // Should complete search within 1 second
    EXPECT_LT(duration.count(), 1000)
        << "Searching " << user_count << " users took " << duration.count() << "ms";
}
```

### Memory and Resource Testing
```cpp
// tests/memory_test.cpp
#include <gtest/gtest.h>
#include <memory>
#include <vector>
#include "user_service.hpp"
#include "memory_monitor.hpp"

class MemoryTest : public ::testing::Test {
protected:
    void SetUp() override {
        memory_monitor_ = std::make_unique<MemoryMonitor>();
        memory_monitor_->start_monitoring();
    }
    
    void TearDown() override {
        memory_monitor_->stop_monitoring();
    }
    
    std::unique_ptr<MemoryMonitor> memory_monitor_;
};

TEST_F(MemoryTest, ShouldNotLeakMemoryDuringNormalOperations) {
    auto mock_database = MockDatabaseFactory::create_nice();
    auto user_service = std::make_unique<UserService>(mock_database);
    
    const size_t initial_memory = memory_monitor_->get_current_usage();
    
    // Perform operations that should not leak memory
    for (int i = 0; i < 1000; ++i) {
        const UserData user_data{
            .first_name = "User" + std::to_string(i),
            .last_name = "Test",
            .email = "user" + std::to_string(i) + "@test.com"
        };
        
        // Mock successful creation
        ON_CALL(*mock_database, insert(user_data))
            .WillByDefault(Return(User{
                .id = static_cast<int64_t>(i),
                .first_name = user_data.first_name,
                .last_name = user_data.last_name,
                .email = user_data.email,
                .is_active = true
            }));
        
        user_service->create_user(user_data);
    }
    
    // Force garbage collection and check memory
    user_service.reset();
    mock_database.reset();
    
    const size_t final_memory = memory_monitor_->get_current_usage();
    const size_t memory_diff = final_memory - initial_memory;
    
    // Allow for some memory overhead but detect significant leaks
    EXPECT_LT(memory_diff, 1024 * 1024) // Less than 1MB increase
        << "Memory usage increased by " << memory_diff << " bytes";
}

TEST_F(MemoryTest, ShouldHandleLargeDataSetsWithoutExcessiveMemoryUsage) {
    auto mock_database = MockDatabaseFactory::create_nice();
    auto user_service = std::make_unique<UserService>(mock_database);
    
    const size_t initial_memory = memory_monitor_->get_current_usage();
    
    // Simulate processing large result sets
    std::vector<User> large_user_set;
    large_user_set.reserve(100000);
    
    for (int i = 0; i < 100000; ++i) {
        large_user_set.emplace_back(User{
            .id = static_cast<int64_t>(i),
            .first_name = "User" + std::to_string(i),
            .last_name = "Test",
            .email = "user" + std::to_string(i) + "@test.com",
            .is_active = true
        });
    }
    
    const size_t peak_memory = memory_monitor_->get_peak_usage();
    const size_t memory_increase = peak_memory - initial_memory;
    
    // Should not use more than 100MB for 100k users
    EXPECT_LT(memory_increase, 100 * 1024 * 1024)
        << "Peak memory usage increased by " << memory_increase << " bytes";
}
```

### Thread Safety Testing
```cpp
// tests/thread_safety_test.cpp
#include <gtest/gtest.h>
#include <thread>
#include <vector>
#include <atomic>
#include <future>
#include "user_service.hpp"
#include "test_database_fixture.hpp"

class ThreadSafetyTest : public TestDatabaseFixture {
protected:
    void SetUp() override {
        TestDatabaseFixture::SetUp();
        database_ = std::make_shared<PostgreSQLDatabase>(connection_string_);
        user_service_ = std::make_unique<UserService>(database_);
    }
    
    std::shared_ptr<PostgreSQLDatabase> database_;
    std::unique_ptr<UserService> user_service_;
};

TEST_F(ThreadSafetyTest, ShouldHandleConcurrentUserCreation) {
    const size_t thread_count = 10;
    const size_t users_per_thread = 100;
    
    std::vector<std::future<size_t>> futures;
    std::atomic<size_t> total_created{0};
    
    // Launch concurrent threads
    for (size_t thread_id = 0; thread_id < thread_count; ++thread_id) {
        auto future = std::async(std::launch::async, [this, thread_id, users_per_thread, &total_created]() {
            size_t created_count = 0;
            
            for (size_t i = 0; i < users_per_thread; ++i) {
                const UserData user_data{
                    .first_name = "User" + std::to_string(thread_id) + "_" + std::to_string(i),
                    .last_name = "Test",
                    .email = "user" + std::to_string(thread_id) + "_" + std::to_string(i) + "@test.com"
                };
                
                const auto result = user_service_->create_user(user_data);
                if (result.has_value()) {
                    ++created_count;
                }
            }
            
            total_created += created_count;
            return created_count;
        });
        
        futures.push_back(std::move(future));
    }
    
    // Wait for all threads to complete
    size_t expected_total = 0;
    for (auto& future : futures) {
        expected_total += future.get();
    }
    
    // Verify results
    EXPECT_EQ(total_created.load(), expected_total);
    EXPECT_EQ(expected_total, thread_count * users_per_thread);
}
```

### Test Utilities
```cpp
// tests/test_database_fixture.hpp
#pragma once
#include <gtest/gtest.h>
#include <string>

class TestDatabaseFixture : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup test database
        connection_string_ = "postgresql://test:test@localhost:5432/test_db";
        setup_test_database();
    }
    
    void TearDown() override {
        cleanup_test_database();
    }
    
    void setup_test_database() {
        // Create tables, load test data, etc.
    }
    
    void cleanup_test_database() {
        // Clean up test data
    }
    
    std::string connection_string_;
};

// tests/test_helpers.hpp
#pragma once
#include <random>
#include <string>

class TestHelpers {
public:
    static std::string generate_random_email() {
        static std::random_device rd;
        static std::mt19937 gen(rd());
        static std::uniform_int_distribution<> dis(10000, 99999);
        
        return "test" + std::to_string(dis(gen)) + "@example.com";
    }
    
    static UserData create_valid_user_data() {
        return UserData{
            .first_name = "Test",
            .last_name = "User",
            .email = generate_random_email()
        };
    }
};
```

## CLAUDE_CODE_COMMANDS

```bash
# Build and run tests
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j$(nproc)
ctest --output-on-failure

# Run specific test suite
ctest -R UserServiceTest

# Run tests with verbose output
ctest --verbose

# Generate coverage report
make coverage
lcov --capture --directory . --output-file coverage.info
genhtml coverage.info --output-directory coverage_report

# Run memory checks with Valgrind
valgrind --tool=memcheck --leak-check=full ./tests

# Run with AddressSanitizer
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-fsanitize=address" ..
make && ./tests
```

## VALIDATION_CHECKLIST
- [ ] Unit tests cover all public methods
- [ ] Mock objects used for external dependencies
- [ ] Integration tests verify database interactions
- [ ] Performance tests establish baseline metrics
- [ ] Memory leak detection implemented
- [ ] Thread safety verified for concurrent operations
- [ ] Error handling and edge cases tested
- [ ] Parameterized tests for multiple input scenarios
- [ ] Test fixtures provide clean test environments
- [ ] Code coverage above 80% threshold