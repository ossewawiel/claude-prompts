# Java 11 Features & Best Practices

## Overview

Java 11 is a Long Term Support (LTS) release that provides significant performance improvements and new language features compared to Java 8. This document covers Java 11 specific features and best practices for Spring Boot 2.7 service layer development.

## Key Java 11 Features for Service Development

### 1. String Methods Enhancement

```java
@Service
public class TextProcessingService {
    
    public boolean isValidInput(String input) {
        // Java 11: isBlank() - checks for empty or whitespace-only strings
        return input != null && !input.isBlank();
    }
    
    public List<String> processLines(String multiLineText) {
        // Java 11: lines() - splits string into stream of lines
        return multiLineText.lines()
            .filter(line -> !line.isBlank())
            .map(String::trim)
            .collect(Collectors.toList());
    }
    
    public String repeatMessage(String message, int count) {
        // Java 11: repeat() - repeats string n times
        return message.repeat(count);
    }
}
```

### 2. Local Variable Type Inference (var)

```java
@Service
public class OrderService {
    
    public OrderSummary processOrder(OrderRequest request) {
        // Use var for complex generic types to improve readability
        var orderItems = request.getItems().stream()
            .filter(item -> item.getQuantity() > 0)
            .collect(Collectors.toList());
            
        var totalAmount = orderItems.stream()
            .mapToDouble(item -> item.getPrice() * item.getQuantity())
            .sum();
            
        // Don't use var when type is not obvious
        OrderSummary summary = new OrderSummary(); // Better than var here
        summary.setTotal(totalAmount);
        return summary;
    }
}
```

### 3. HTTP Client (Replacement for RestTemplate)

```java
@Service
@Slf4j
public class ExternalApiService {
    
    private final HttpClient httpClient;
    
    public ExternalApiService() {
        this.httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();
    }
    
    public CompletableFuture<String> fetchDataAsync(String url) {
        var request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .timeout(Duration.ofSeconds(30))
            .header("Accept", "application/json")
            .GET()
            .build();
            
        return httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofString())
            .thenApply(HttpResponse::body);
    }
}
```

## Performance Best Practices

### 1. Use Modern Garbage Collectors

```bash
# G1GC (recommended for most applications)
-XX:+UseG1GC -XX:MaxGCPauseMillis=200

# ZGC for low-latency applications (Java 11+)
-XX:+UnlockExperimentalVMOptions -XX:+UseZGC
```

### 2. JVM Memory Configuration

```bash
# For Spring Boot applications
-Xms512m -Xmx2g
-XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=512m
```

### 3. Modern Collection Usage

```java
@Service
public class CollectionService {
    
    // Use List.of() for immutable collections (Java 9+)
    private static final List<String> VALID_STATUSES = List.of(
        "PENDING", "APPROVED", "REJECTED"
    );
    
    // Use Set.of() for better performance
    private static final Set<String> ADMIN_ROLES = Set.of(
        "SUPER_ADMIN", "ADMIN", "MODERATOR"
    );
    
    public boolean isValidStatus(String status) {
        return VALID_STATUSES.contains(status);
    }
    
    // Use Stream API efficiently
    public List<UserDto> getActiveUsers(List<User> users) {
        return users.parallelStream() // Use parallel streams for large datasets
            .filter(User::isActive)
            .filter(user -> user.getLastLoginDate().isAfter(LocalDate.now().minusDays(30)))
            .map(this::convertToDto)
            .collect(Collectors.toList());
    }
}
```

## Modern Java Patterns

### 1. Optional Usage

```java
@Service
public class UserService {
    
    // Good: Return Optional for potentially null results
    public Optional<User> findUserById(Long id) {
        return userRepository.findById(id);
    }
    
    // Good: Use Optional methods for cleaner code
    public String getUserDisplayName(Long userId) {
        return findUserById(userId)
            .map(User::getDisplayName)
            .orElse("Unknown User");
    }
    
    // Avoid: Don't use Optional as method parameters
    // Bad: public void updateUser(Optional<User> user)
    // Good:
    public void updateUser(User user) {
        if (user != null) {
            userRepository.save(user);
        }
    }
}
```

### 2. Exception Handling with Modern Patterns

```java
@Service
@Slf4j
public class PaymentService {
    
    public PaymentResult processPayment(PaymentRequest request) {
        try {
            validatePaymentRequest(request);
            var result = executePayment(request);
            return result;
        } catch (ValidationException e) {
            log.warn("Payment validation failed: {}", e.getMessage());
            throw new PaymentValidationException(e.getMessage(), e);
        } catch (Exception e) {
            log.error("Unexpected error during payment processing", e);
            throw new PaymentProcessingException("Payment processing failed", e);
        }
    }
    
    // Use multi-catch for similar exception handling
    private void handleExternalApiCall() {
        try {
            callExternalApi();
        } catch (ConnectException | SocketTimeoutException e) {
            log.error("Network error: {}", e.getMessage());
            throw new ExternalServiceException("Service temporarily unavailable", e);
        }
    }
}
```

## Resource Management

### 1. Try-with-Resources Enhancement

```java
@Service
public class FileProcessingService {
    
    // Java 9+: Try-with-resources with existing variables
    public String processFile(Path filePath) throws IOException {
        var reader = Files.newBufferedReader(filePath);
        var writer = Files.newBufferedWriter(filePath.resolveSibling("output.txt"));
        
        // Automatically closes both resources
        try (reader; writer) {
            return reader.lines()
                .map(String::toUpperCase)
                .peek(writer::println)
                .collect(Collectors.joining("\n"));
        }
    }
}
```

## Code Quality Best Practices

### 1. Immutable Objects

```java
@Value // Lombok annotation for immutable class
@Builder
public class ProductInfo {
    String name;
    BigDecimal price;
    String category;
    LocalDateTime createdAt;
    
    // Lombok generates constructor, getters, equals, hashCode, toString
}

@Service
public class ProductService {
    
    public ProductInfo createProduct(String name, BigDecimal price, String category) {
        return ProductInfo.builder()
            .name(name)
            .price(price)
            .category(category)
            .createdAt(LocalDateTime.now())
            .build();
    }
}
```

### 2. Fluent Interfaces

```java
@Service
public class QueryService {
    
    public List<Product> searchProducts(String category, BigDecimal minPrice, BigDecimal maxPrice) {
        var specification = ProductSpecification.builder()
            .withCategory(category)
            .withPriceRange(minPrice, maxPrice)
            .withActiveStatus(true)
            .build();
            
        return productRepository.findAll(specification);
    }
}
```

## Performance Monitoring

### 1. Method Execution Time Logging

```java
@Service
@Slf4j
public class MetricsService {
    
    @Timed(name = "user.processing.time", description = "Time taken to process user data")
    public UserResult processUserData(UserRequest request) {
        var startTime = System.nanoTime();
        try {
            // Business logic here
            var result = doProcessing(request);
            return result;
        } finally {
            var duration = System.nanoTime() - startTime;
            log.debug("User processing completed in {} ms", duration / 1_000_000);
        }
    }
}
```

## Migration from Java 8

### Key Changes to Adopt

1. **Replace Anonymous Classes with Lambda Expressions:**
   ```java
   // Old way
   users.sort(new Comparator<User>() {
       public int compare(User u1, User u2) {
           return u1.getName().compareTo(u2.getName());
       }
   });
   
   // Modern way
   users.sort(Comparator.comparing(User::getName));
   ```

2. **Use Stream API More Effectively:**
   ```java
   // Collect to specific collection types
   var activeUserNames = users.stream()
       .filter(User::isActive)
       .map(User::getName)
       .collect(Collectors.toUnmodifiableList());
   ```

3. **Leverage Time API:**
   ```java
   // Use modern time APIs
   var expirationDate = LocalDateTime.now().plusDays(30);
   var isExpired = expirationDate.isBefore(LocalDateTime.now());
   ```

## Summary

Java 11 provides significant performance improvements and language features that enhance Spring Boot development. Key benefits include:

- Enhanced string processing capabilities
- Improved HTTP client support
- Better garbage collection options
- More expressive and concise code patterns
- Enhanced resource management

Next: [Project Structure & Naming Conventions](project-structure)
