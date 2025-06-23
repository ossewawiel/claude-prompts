## VALIDATION_CHECKLIST
- [ ] All Kotlin compilation errors resolved without warnings
- [ ] Spring Boot application starts successfully on all profiles (dev, test, prod)
- [ ] Database migrations execute successfully without errors
- [ ] All security configurations properly implemented and tested
- [ ] JWT authentication and authorization working correctly
- [ ] All REST API endpoints properly secured and documented
- [ ] OpenAPI documentation generated and accessible at /swagger-ui.html
- [ ] Test coverage above 90% for service and repository layers
- [ ] Integration tests pass with Testcontainers PostgreSQL
- [ ] Performance requirements met under simulated load
- [ ] Security scan passes without critical vulnerabilities
- [ ] All API endpoints return consistent error response format
- [ ] Input validation working on all request DTOs
- [ ] Rate limiting configured and functional
- [ ] Caching strategy implemented and working
- [ ] Monitoring endpoints accessible at /actuator/*
- [ ] Application logs structured and correlation IDs present
- [ ] Docker image builds and runs successfully
- [ ] Kubernetes manifests deploy without errors
- [ ] Database connection pooling configured optimally
- [ ] Email service integration functional with templates
- [ ] File upload/download functionality working securely
- [ ] Backup and restore procedures tested
- [ ] Documentation complete and accurate
- [ ] Production readiness checklist completed

## PERFORMANCE_REQUIREMENTS
- **API Response Time**: < 200ms for simple CRUD operations
- **Database Query Time**: < 100ms for indexed queries, < 500ms for complex joins
- **Concurrent Users**: Support 1000+ concurrent authenticated sessions
- **Memory Usage**: < 2GB heap under normal load with 500 active users
- **Startup Time**: < 60 seconds in production environment
- **Throughput**: Handle 10,000+ requests per minute
- **Database Connections**: Efficiently manage connection pool (max 20 connections)
- **Cache Hit Ratio**: > 80% for frequently accessed data
- **JWT Token Processing**: < 50ms for token validation and user context loading
- **File Upload**: Support files up to 100MB with progress tracking

## MONITORING_AND_OBSERVABILITY

### Application Metrics
```kotlin
// Custom metrics configuration
@Component
class CustomMetrics(private val meterRegistry: MeterRegistry) {
    
    private val userLoginCounter = Counter.builder("user.login.attempts")
        .description("Number of user login attempts")
        .tag("status", "success")
        .register(meterRegistry)
    
    private val userLoginFailureCounter = Counter.builder("user.login.attempts")
        .description("Number of failed user login attempts")
        .tag("status", "failure")
        .register(meterRegistry)
    
    private val apiRequestTimer = Timer.builder("api.request.duration")
        .description("API request processing time")
        .register(meterRegistry)
    
    private val databaseQueryTimer = Timer.builder("database.query.duration")
        .description("Database query execution time")
        .register(meterRegistry)
    
    private val cacheHitCounter = Counter.builder("cache.hit")
        .description("Cache hit counter")
        .register(meterRegistry)
    
    private val cacheMissCounter = Counter.builder("cache.miss")
        .description("Cache miss counter")
        .register(meterRegistry)
    
    fun recordSuccessfulLogin() = userLoginCounter.increment()
    fun recordFailedLogin() = userLoginFailureCounter.increment()
    fun recordApiRequest(duration: Duration) = apiRequestTimer.record(duration)
    fun recordDatabaseQuery(duration: Duration) = databaseQueryTimer.record(duration)
    fun recordCacheHit() = cacheHitCounter.increment()
    fun recordCacheMiss() = cacheMissCounter.increment()
}
```

### Health Checks
```kotlin
// Custom health indicators
@Component
class DatabaseHealthIndicator(
    private val dataSource: DataSource
) : HealthIndicator {
    
    override fun health(): Health {
        return try {
            dataSource.connection.use { connection ->
                val statement = connection.createStatement()
                statement.executeQuery("SELECT 1").use { resultSet ->
                    if (resultSet.next()) {
                        Health.up()
                            .withDetail("database", "PostgreSQL")
                            .withDetail("status", "Connected")
                            .build()
                    } else {
                        Health.down()
                            .withDetail("database", "PostgreSQL")
                            .withDetail("status", "Query failed")
                            .build()
                    }
                }
            }
        } catch (e: Exception) {
            Health.down()
                .withDetail("database", "PostgreSQL")
                .withDetail("error", e.message)
                .build()
        }
    }
}

@Component
@ConditionalOnProperty(prefix = "spring.cache", name = ["type"], havingValue = "redis")
class RedisHealthIndicator(
    private val redisTemplate: RedisTemplate<String, Any>
) : HealthIndicator {
    
    override fun health(): Health {
        return try {
            redisTemplate.execute { connection ->
                connection.ping()
            }
            Health.up()
                .withDetail("cache", "Redis")
                .withDetail("status", "Connected")
                .build()
        } catch (e: Exception) {
            Health.down()
                .withDetail("cache", "Redis")
                .withDetail("error", e.message)
                .build()
        }
    }
}
```

### Structured Logging
```xml
<!-- logback-spring.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <include resource="org/springframework/boot/logging/logback/defaults.xml"/>
    
    <springProfile name="!prod">
        <include resource="org/springframework/boot/logging/logback/console-appender.xml"/>
        <root level="INFO">
            <appender-ref ref="CONSOLE"/>
        </root>
    </springProfile>
    
    <springProfile name="prod">
        <appender name="JSON_CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
            <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
                <providers>
                    <timestamp/>
                    <logLevel/>
                    <loggerName/>
                    <message/>
                    <mdc/>
                    <arguments/>
                    <stackTrace/>
                </providers>
            </encoder>
        </appender>
        
        <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
            <file>logs/{{project_name}}.log</file>
            <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
                <fileNamePattern>logs/{{project_name}}.%d{yyyy-MM-dd}.%i.log</fileNamePattern>
                <maxFileSize>100MB</maxFileSize>
                <maxHistory>30</maxHistory>
                <totalSizeCap>3GB</totalSizeCap>
            </rollingPolicy>
            <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
                <providers>
                    <timestamp/>
                    <logLevel/>
                    <loggerName/>
                    <message/>
                    <mdc/>
                    <arguments/>
                    <stackTrace/>
                </providers>
            </encoder>
        </appender>
        
        <root level="INFO">
            <appender-ref ref="JSON_CONSOLE"/>
            <appender-ref ref="FILE"/>
        </root>
    </springProfile>
    
    <!-- Security event logging -->
    <logger name="SECURITY" level="INFO" additivity="false">
        <appender name="SECURITY_FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
            <file>logs/security.log</file>
            <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
                <fileNamePattern>logs/security.%d{yyyy-MM-dd}.log</fileNamePattern>
                <maxHistory>90</maxHistory>
            </rollingPolicy>
            <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
                <providers>
                    <timestamp/>
                    <message/>
                    <mdc/>
                </providers>
            </encoder>
        </appender>
        <appender-ref ref="SECURITY_FILE"/>
    </logger>
    
    <!-- Application specific loggers -->
    <logger name="{{base_package}}" level="DEBUG"/>
    <logger name="org.springframework.security" level="WARN"/>
    <logger name="org.springframework.web" level="WARN"/>
    <logger name="org.hibernate.SQL" level="DEBUG"/>
    <logger name="org.hibernate.type.descriptor.sql.BasicBinder" level="TRACE"/>
    <logger name="com.zaxxer.hikari" level="INFO"/>
</configuration>
```

## SECURITY_HARDENING

### Security Headers Configuration
```kotlin
// Security headers filter
@Component
class SecurityHeadersFilter : Filter {
    
    override fun doFilter(request: ServletRequest, response: ServletResponse, chain: FilterChain) {
        val httpResponse = response as HttpServletResponse
        
        // Security headers
        httpResponse.setHeader("X-Content-Type-Options", "nosniff")
        httpResponse.setHeader("X-Frame-Options", "DENY")
        httpResponse.setHeader("X-XSS-Protection", "1; mode=block")
        httpResponse.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload")
        httpResponse.setHeader("Content-Security-Policy", 
            "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' https:; connect-src 'self' https:")
        httpResponse.setHeader("Referrer-Policy", "strict-origin-when-cross-origin")
        httpResponse.setHeader("Permissions-Policy", "geolocation=(), microphone=(), camera=(), payment=(), usb=()")
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate")
        httpResponse.setHeader("Pragma", "no-cache")
        httpResponse.setHeader("Expires", "0")
        
        chain.doFilter(request, response)
    }
}
```

### Rate Limiting Implementation
```kotlin
// Rate limiting configuration
@Configuration
class RateLimitConfig {
    
    @Bean
    fun rateLimitFilter(): FilterRegistrationBean<RateLimitFilter> {
        val registration = FilterRegistrationBean<RateLimitFilter>()
        registration.filter = RateLimitFilter()
        registration.addUrlPatterns("/api/*")
        registration.order = 1
        return registration
    }
}

@Component
class RateLimitFilter(
    private val redisTemplate: RedisTemplate<String, Any>
) : Filter {
    
    companion object {
        private const val RATE_LIMIT_PREFIX = "rate_limit:"
        private const val DEFAULT_REQUESTS_PER_MINUTE = 100
        private const val LOGIN_REQUESTS_PER_MINUTE = 5
    }
    
    override fun doFilter(request: ServletRequest, response: ServletResponse, chain: FilterChain) {
        val httpRequest = request as HttpServletRequest
        val httpResponse = response as HttpServletResponse
        
        val clientIp = getClientIp(httpRequest)
        val requestPath = httpRequest.requestURI
        
        val limit = when {
            requestPath.contains("/auth/login") -> LOGIN_REQUESTS_PER_MINUTE
            else -> DEFAULT_REQUESTS_PER_MINUTE
        }
        
        if (!isAllowed(clientIp, requestPath, limit)) {
            httpResponse.status = HttpStatus.TOO_MANY_REQUESTS.value()
            httpResponse.writer.write("""{"error": "Rate limit exceeded"}""")
            return
        }
        
        chain.doFilter(request, response)
    }
    
    private fun isAllowed(clientIp: String, path: String, limit: Int): Boolean {
        val key = "$RATE_LIMIT_PREFIX$clientIp:$path"
        val current = redisTemplate.opsForValue().get(key) as? Int ?: 0
        
        if (current >= limit) {
            return false
        }
        
        redisTemplate.opsForValue().increment(key)
        redisTemplate.expire(key, Duration.ofMinutes(1))
        
        return true
    }
    
    private fun getClientIp(request: HttpServletRequest): String {
        val xForwardedFor = request.getHeader("X-Forwarded-For")
        val xRealIp = request.getHeader("X-Real-IP")
        
        return when {
            !xForwardedFor.isNullOrBlank() -> xForwardedFor.split(",")[0].trim()
            !xRealIp.isNullOrBlank() -> xRealIp
            else -> request.remoteAddr
        }
    }
}
```

### Input Validation and Sanitization
```kotlin
// Custom validation annotations
@Target(AnnotationTarget.FIELD, AnnotationTarget.VALUE_PARAMETER)
@Retention(AnnotationRetention.RUNTIME)
@Constraint(validatedBy = [StrongPasswordValidator::class])
annotation class StrongPassword(
    val message: String = "Password must be at least 8 characters with uppercase, lowercase, number and special character",
    val groups: Array<KClass<*>> = [],
    val payload: Array<KClass<out Payload>> = []
)

class StrongPasswordValidator : ConstraintValidator<StrongPassword, String> {
    
    private val passwordPattern = Regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}$")
    
    override fun isValid(value: String?, context: ConstraintValidatorContext): Boolean {
        return value?.matches(passwordPattern) == true
    }
}

@Target(AnnotationTarget.FIELD, AnnotationTarget.VALUE_PARAMETER)
@Retention(AnnotationRetention.RUNTIME)
@Constraint(validatedBy = [SafeStringValidator::class])
annotation class SafeString(
    val message: String = "Input contains potentially harmful content",
    val groups: Array<KClass<*>> = [],
    val payload: Array<KClass<out Payload>> = []
)

class SafeStringValidator : ConstraintValidator<SafeString, String> {
    
    private val dangerousPatterns = listOf(
        Regex("<script[^>]*>.*?</script>", RegexOption.IGNORE_CASE),
        Regex("javascript:", RegexOption.IGNORE_CASE),
        Regex("on\\w+\\s*=", RegexOption.IGNORE_CASE),
        Regex("union.*select", RegexOption.IGNORE_CASE),
        Regex("insert.*into", RegexOption.IGNORE_CASE),
        Regex("delete.*from", RegexOption.IGNORE_CASE),
        Regex("drop.*table", RegexOption.IGNORE_CASE)
    )
    
    override fun isValid(value: String?, context: ConstraintValidatorContext): Boolean {
        if (value == null) return true
        
        return dangerousPatterns.none { pattern ->
            value.contains(pattern)
        }
    }
}
```

## DEPLOYMENT_CONFIGURATION

### Production Application Configuration
```yaml
# application-prod.yml
spring:
  datasource:
    url: ${DATABASE_URL:jdbc:postgresql://localhost:5432/{{database_name}}}
    username: ${DATABASE_USERNAME:{{database_name}}_user}
    password: ${DATABASE_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
      leak-detection-threshold: 60000
      
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        jdbc:
          batch_size: 25
          batch_versioned_data: true
        order_inserts: true
        order_updates: true
        format_sql: false
        use_sql_comments: false
        generate_statistics: false
        
  flyway:
    enabled: true
    validate-on-migrate: true
    out-of-order: false
    
  cache:
    type: redis
    redis:
      time-to-live: 600000 # 10 minutes
      
  data:
    redis:
      url: ${REDIS_URL:redis://localhost:6379}
      timeout: 2000ms
      lettuce:
        pool:
          max-active: 8
          max-idle: 8
          min-idle: 2
          
  rabbitmq:
    host: ${RABBITMQ_HOST:localhost}
    port: ${RABBITMQ_PORT:5672}
    username: ${RABBITMQ_USERNAME:guest}
    password: ${RABBITMQ_PASSWORD:guest}
    virtual-host: ${RABBITMQ_VHOST:/}
    
  mail:
    host: ${MAIL_HOST:smtp.gmail.com}
    port: ${MAIL_PORT:587}
    username: ${MAIL_USERNAME}
    password: ${MAIL_PASSWORD}
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
            
server:
  port: 8080
  shutdown: graceful
  compression:
    enabled: true
    mime-types: text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/json
  http2:
    enabled: true
  ssl:
    enabled: ${SSL_ENABLED:false}
    key-store: ${SSL_KEYSTORE_PATH:}
    key-store-password: ${SSL_KEYSTORE_PASSWORD:}
    key-store-type: PKCS12
    
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
      cors:
        allowed-origins: ${CORS_ALLOWED_ORIGINS:http://localhost:3000}
        allowed-methods: GET,POST
  endpoint:
    health:
      show-details: when-authorized
      cache:
        time-to-live: 10s
  metrics:
    export:
      prometheus:
        enabled: true
    distribution:
      percentiles-histogram:
        http.server.requests: true
      percentiles:
        http.server.requests: 0.5, 0.95, 0.99
        
logging:
  level:
    com.{{company}}.{{project}}: INFO
    org.springframework.security: WARN
    org.springframework.web: WARN
    org.hibernate.SQL: WARN
    com.zaxxer.hikari: INFO
    root: WARN
  pattern:
    console: "%d{HH:mm:ss.SSS} [%thread] %-5level [%X{correlationId}] %logger{36} - %msg%n"
  
app:
  jwt:
    secret: ${JWT_SECRET}
    expiration: 86400000 # 24 hours
    refresh-expiration: 2592000000 # 30 days
    issuer: {{project_name}}
  
  security:
    password:
      min-length: 8
      max-length: 128
      require-uppercase: true
      require-lowercase: true
      require-numbers: true
      require-special-chars: true
    account-lockout:
      max-attempts: 5
      lockout-duration: 900000 # 15 minutes
  
  file-upload:
    max-size: 104857600 # 100MB
    allowed-types: image/jpeg,image/png,image/gif,application/pdf,text/plain,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    storage-path: ${FILE_STORAGE_PATH:/app/uploads}
  
  storage:
    type: ${STORAGE_TYPE:local} # local or s3
    s3:
      bucket-name: ${S3_BUCKET_NAME:}
      region: ${S3_REGION:us-east-1}
      access-key: ${S3_ACCESS_KEY:}
      secret-key: ${S3_SECRET_KEY:}
      url-expiration: PT1H # 1 hour
  
  messaging:
    enabled: ${MESSAGING_ENABLED:true}
  
  monitoring:
    enabled: ${MONITORING_ENABLED:true}
    
  cors:
    allowed-origins: ${CORS_ALLOWED_ORIGINS:http://localhost:3000,https://app.{{domain_name}}}
    allowed-methods: GET,POST,PUT,DELETE,OPTIONS
    allowed-headers: "*"
    allow-credentials: true
    max-age: 3600
```

### Docker Production Configuration
```dockerfile
# Multi-stage build Dockerfile
FROM eclipse-temurin:21-jdk-alpine AS builder

# Set working directory
WORKDIR /app

# Copy gradle wrapper and build files
COPY gradle/ gradle/
COPY gradlew build.gradle.kts settings.gradle.kts gradle.properties ./

# Download dependencies
RUN ./gradlew dependencies --no-daemon

# Copy source code
COPY src/ src/

# Build application
RUN ./gradlew bootJar --no-daemon -x test

FROM eclipse-temurin:21-jre-alpine

# Install necessary packages
RUN apk add --no-cache \
    curl \
    dumb-init \
    && addgroup -g 1001 appgroup \
    && adduser -u 1001 -G appgroup -s /bin/sh -D appuser

# Set working directory
WORKDIR /app

# Copy built jar
COPY --from=builder /app/build/libs/*.jar app.jar

# Create directories and set permissions
RUN mkdir -p /app/logs /app/uploads /app/config \
    && chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Set JVM options
ENV JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### Docker Compose Production
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  app:
    build: 
      context: .
      dockerfile: docker/app/Dockerfile
    image: {{project_name}}:latest
    container_name: {{project_name}}-app
    restart: unless-stopped
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DATABASE_URL=jdbc:postgresql://postgres:5432/{{database_name}}
      - DATABASE_USERNAME={{database_name}}_user
      - DATABASE_PASSWORD=${DATABASE_PASSWORD}
      - REDIS_URL=redis://redis:6379
      - RABBITMQ_HOST=rabbitmq
      - JWT_SECRET=${JWT_SECRET}
      - MAIL_USERNAME=${MAIL_USERNAME}
      - MAIL_PASSWORD=${MAIL_PASSWORD}
    ports:
      - "8080:8080"
    volumes:
      - app_logs:/app/logs
      - app_uploads:/app/uploads
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    networks:
      - app_network
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
          
  postgres:
    image: postgres:16-alpine
    container_name: {{project_name}}-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB={{database_name}}
      - POSTGRES_USER={{database_name}}_user
      - POSTGRES_PASSWORD=${DATABASE_PASSWORD}
      - POSTGRES_INITDB_ARGS="--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - app_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U {{database_name}}_user -d {{database_name}}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
      
  redis:
    image: redis:7-alpine
    container_name: {{project_name}}-redis
    restart: unless-stopped
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - app_network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
      
  rabbitmq:
    image: rabbitmq:3.13-management-alpine
    container_name: {{project_name}}-rabbitmq
    restart: unless-stopped
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=${RABBITMQ_PASSWORD}
      - RABBITMQ_DEFAULT_VHOST=/
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - app_network
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      
  nginx:
    image: nginx:alpine
    container_name: {{project_name}}-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./docker/nginx/ssl:/etc/nginx/ssl:ro
      - nginx_logs:/var/log/nginx
    depends_on:
      - app
    networks:
      - app_network
      
  prometheus:
    image: prom/prometheus:latest
    container_name: {{project_name}}-prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./docker/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - app_network
      
  grafana:
    image: grafana/grafana:latest
    container_name: {{project_name}}-grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./docker/grafana/provisioning:/etc/grafana/provisioning:ro
    depends_on:
      - prometheus
    networks:
      - app_network

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  rabbitmq_data:
    driver: local
  app_logs:
    driver: local
  app_uploads:
    driver: local
  nginx_logs:
    driver: local
  prometheus_data:
    driver: local
  grafana_data:
    driver: local

networks:
  app_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

## BUSINESS_LOGIC_EXAMPLES

### Core Domain Entities
```kotlin
// Base entity with auditing
@MappedSuperclass
@EntityListeners(AuditingEntityListener::class)
abstract class BaseEntity {
    
    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    lateinit var createdAt: LocalDateTime
    
    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    lateinit var updatedAt: LocalDateTime
    
    @CreatedBy
    @Column(name = "created_by", updatable = false)
    var createdBy: String? = null
    
    @LastModifiedBy
    @Column(name = "updated_by")
    var updatedBy: String? = null
    
    @Version
    @Column(name = "version", nullable = false)
    var version: Long = 0
}

// User entity
@Entity
@Table(
    name = "users",
    indexes = [
        Index(name = "idx_user_email", columnList = "email"),
        Index(name = "idx_user_organization", columnList = "organization_id"),
        Index(name = "idx_user_status", columnList = "status")
    ]
)
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(unique = true, nullable = false, length = 255)
    val email: String,
    
    @Column(nullable = false, length = 255)
    val password: String,
    
    @Column(name = "first_name", nullable = false, length = 100)
    val firstName: String,
    
    @Column(name = "last_name", nullable = false, length = 100)
    val lastName: String,
    
    @Column(name = "phone_number", length = 20)
    val phoneNumber: String? = null,
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    val status: UserStatus = UserStatus.ACTIVE,
    
    @Column(name = "email_verified", nullable = false)
    val emailVerified: Boolean = false,
    
    @Column(name = "last_login")
    val lastLogin: LocalDateTime? = null,
    
    @Column(name = "failed_login_attempts", nullable = false)
    val failedLoginAttempts: Int = 0,
    
    @Column(name = "locked_until")
    val lockedUntil: LocalDateTime? = null,
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organization_id")
    val organization: Organization? = null,
    
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "user_roles",
        joinColumns = [JoinColumn(name = "user_id")],
        inverseJoinColumns = [JoinColumn(name = "role_id")]
    )
    val roles: Set<Role> = emptySet(),
    
    @Column(name = "profile_picture_url")
    val profilePictureUrl: String? = null,
    
    @Column(name = "timezone", length = 50)
    val timezone: String = "UTC",
    
    @Column(name = "language", length = 10)
    val language: String = "en"
) : BaseEntity() {
    
    val fullName: String
        get() = "$firstName $lastName"
    
    val isLocked: Boolean
        get() = lockedUntil?.isAfter(LocalDateTime.now()) ?: false
    
    val isActive: Boolean
        get() = status == UserStatus.ACTIVE && !isLocked
    
    fun hasRole(roleName: String): Boolean {
        return roles.any { it.name.equals(roleName, ignoreCase = true) }
    }
    
    fun hasPermission(permissionName: String): Boolean {
        return roles.flatMap { it.permissions }.any { it.name.equals(permissionName, ignoreCase = true) }
    }
    
    fun incrementFailedLoginAttempts(): User {
        return this.copy(failedLoginAttempts = failedLoginAttempts + 1)
    }
    
    fun resetFailedLoginAttempts(): User {
        return this.copy(failedLoginAttempts = 0, lockedUntil = null)
    }
    
    fun lockAccount(duration: Duration): User {
        return this.copy(lockedUntil = LocalDateTime.now().plus(duration))
    }
}

enum class UserStatus {
    ACTIVE, INACTIVE, SUSPENDED, PENDING_VERIFICATION
}

// Organization entity
@Entity
@Table(
    name = "organizations",
    indexes = [
        Index(name = "idx_org_name", columnList = "name"),
        Index(name = "idx_org_parent", columnList = "parent_id"),
        Index(name = "idx_org_status", columnList = "status")
    ]
)
data class Organization(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(nullable = false, length = 255)
    val name: String,
    
    @Column(length = 1000)
    val description: String? = null,
    
    @Column(name = "registration_number", length = 100)
    val registrationNumber: String? = null,
    
    @Column(name = "tax_id", length = 100)
    val taxId: String? = null,
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    val status: OrganizationStatus = OrganizationStatus.ACTIVE,
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    val parent: Organization? = null,
    
    @OneToMany(mappedBy = "parent", cascade = [CascadeType.ALL], fetch = FetchType.LAZY)
    val children: Set<Organization> = emptySet(),
    
    @OneToMany(mappedBy = "organization", cascade = [CascadeType.ALL], fetch = FetchType.LAZY)
    val users: Set<User> = emptySet(),
    
    @Embedded
    val address: Address? = null,
    
    @Column(name = "logo_url")
    val logoUrl: String? = null,
    
    @Column(name = "website_url")
    val websiteUrl: String? = null,
    
    @Column(name = "contact_email")
    val contactEmail: String? = null,
    
    @Column(name = "contact_phone", length = 20)
    val contactPhone: String? = null
) : BaseEntity() {
    
    val isActive: Boolean
        get() = status == OrganizationStatus.ACTIVE
    
    fun getAllDescendants(): Set<Organization> {
        val descendants = mutableSetOf<Organization>()
        children.forEach { child ->
            descendants.add(child)
            descendants.addAll(child.getAllDescendants())
        }
        return descendants
    }
}

enum class OrganizationStatus {
    ACTIVE, INACTIVE, SUSPENDED, PENDING_APPROVAL
}

@Embeddable
data class Address(
    @Column(name = "street_address")
    val streetAddress: String? = null,
    
    @Column(name = "city")
    val city: String? = null,
    
    @Column(name = "state_province")
    val stateProvince: String? = null,
    
    @Column(name = "postal_code", length = 20)
    val postalCode: String? = null,
    
    @Column(name = "country", length = 100)
    val country: String? = null
) {
    val fullAddress: String
        get() = listOfNotNull(streetAddress, city, stateProvince, postalCode, country)
            .filter { it.isNotBlank() }
            .joinToString(", ")
}

// Role and Permission entities
@Entity
@Table(
    name = "roles",
    indexes = [Index(name = "idx_role_name", columnList = "name")]
)
data class Role(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(unique = true, nullable = false, length = 100)
    val name: String,
    
    @Column(length = 500)
    val description: String? = null,
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    val type: RoleType = RoleType.CUSTOM,
    
    @Column(nullable = false)
    val isSystemRole: Boolean = false,
    
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "role_permissions",
        joinColumns = [JoinColumn(name = "role_id")],
        inverseJoinColumns = [JoinColumn(name = "permission_id")]
    )
    val permissions: Set<Permission> = emptySet()
) : BaseEntity()

enum class RoleType {
    SYSTEM, ORGANIZATION, CUSTOM
}

@Entity
@Table(
    name = "permissions",
    indexes = [
        Index(name = "idx_permission_name", columnList = "name"),
        Index(name = "idx_permission_resource", columnList = "resource")
    ]
)
data class Permission(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(unique = true, nullable = false, length = 100)
    val name: String,
    
    @Column(length = 500)
    val description: String? = null,
    
    @Column(nullable = false, length = 100)
    val resource: String,
    
    @Column(nullable = false, length = 50)
    val action: String,
    
    @Column(nullable = false)
    val isSystemPermission: Boolean = false
) : BaseEntity() {
    
    val resourceAction: String
        get() = "$resource:$action"
}

// Audit Log entity
@Entity
@Table(
    name = "audit_logs",
    indexes = [
        Index(name = "idx_audit_user", columnList = "user_id"),
        Index(name = "idx_audit_entity", columnList = "entity_type, entity_id"),
        Index(name = "idx_audit_timestamp", columnList = "timestamp"),
        Index(name = "idx_audit_action", columnList = "action")
    ]
)
data class AuditLog(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(name = "user_id")
    val userId: Long? = null,
    
    @Column(name = "session_id", length = 100)
    val sessionId: String? = null,
    
    @Column(name = "entity_type", nullable = false, length = 100)
    val entityType: String,
    
    @Column(name = "entity_id", nullable = false)
    val entityId: String,
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    val action: AuditAction,
    
    @Column(name = "old_values", columnDefinition = "TEXT")
    val oldValues: String? = null,
    
    @Column(name = "new_values", columnDefinition = "TEXT")
    val newValues: String? = null,
    
    @Column(name = "ip_address", length = 45)
    val ipAddress: String? = null,
    
    @Column(name = "user_agent", length = 500)
    val userAgent: String? = null,
    
    @Column(nullable = false)
    val timestamp: LocalDateTime = LocalDateTime.now(),
    
    @Column(length = 1000)
    val details: String? = null
)

enum class AuditAction {
    CREATE, UPDATE, DELETE, LOGIN, LOGOUT, PASSWORD_CHANGE, PERMISSION_CHANGE, STATUS_CHANGE
}

// Refresh Token entity
@Entity
@Table(
    name = "refresh_tokens",
    indexes = [
        Index(name = "idx_refresh_token", columnList = "token"),
        Index(name = "idx_refresh_user", columnList = "user_id"),
        Index(name = "idx_refresh_expiry", columnList = "expiry_date")
    ]
)
data class RefreshToken(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,
    
    @Column(unique = true, nullable = false, length = 500)
    val token: String,
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: User,
    
    @Column(name = "expiry_date", nullable = false)
    val expiryDate: LocalDateTime,
    
    @Column(name = "is_revoked", nullable = false)
    val isRevoked: Boolean = false,
    
    @Column(name = "device_info", length = 500)
    val deviceInfo: String? = null,
    
    @Column(name = "ip_address", length = 45)
    val ipAddress: String? = null
) : BaseEntity() {
    
    val isExpired: Boolean
        get() = LocalDateTime.now().isAfter(expiryDate)
    
    val isValid: Boolean
        get() = !isRevoked && !isExpired
}
```

### Service Layer Implementation
```kotlin
// User Service with comprehensive business logic
@Service
@Transactional
class UserService(
    private val userRepository: UserRepository,
    private val roleRepository: RoleRepository,
    private val organizationRepository: OrganizationRepository,
    private val passwordEncoder: PasswordEncoder,
    private val emailService: EmailService,
    private val auditService: AuditService,
    private val cacheService: CacheService,
    private val customMetrics: CustomMetrics
) {
    
    private val logger = LoggerFactory.getLogger(UserService::class.java)
    
    @Cacheable(value = ["users"], key = "#id")
    @Transactional(readOnly = true)
    fun findById(id: Long): UserResponse? {
        val startTime = System.currentTimeMillis()
        
        return try {
            val user = userRepository.findById(id).orElse(null)
            user?.let { UserMapper.toResponse(it) }
        } finally {
            customMetrics.recordDatabaseQuery(Duration.ofMillis(System.currentTimeMillis() - startTime))
        }
    }
    
    @Transactional(readOnly = true)
    fun findByEmail(email: String): User? {
        return userRepository.findByEmailIgnoreCase(email)
    }
    
    @Transactional(readOnly = true)
    fun searchUsers(searchRequest: SearchRequest, pageable: Pageable): Page<UserResponse> {
        val specification = UserSpecification.buildSpecification(searchRequest)
        val users = userRepository.findAll(specification, pageable)
        
        return users.map { UserMapper.toResponse(it) }
    }
    
    @PreAuthorize("hasPermission(#request, 'USER_CREATE')")
    fun createUser(request: CreateUserRequest): UserResponse {
        logger.info("Creating new user with email: ${request.email}")
        
        validateUserCreation(request)
        
        val organization = request.organizationId?.let { organizationId ->
            organizationRepository.findById(organizationId)
                .orElseThrow { NotFoundException("Organization not found: $organizationId") }
        }
        
        val defaultRoles = roleRepository.findByNameIn(listOf("USER"))
        
        val user = User(
            email = request.email.lowercase(),
            password = passwordEncoder.encode(request.password),
            firstName = request.firstName.trim(),
            lastName = request.lastName.trim(),
            phoneNumber = request.phoneNumber?.trim(),
            organization = organization,
            roles = defaultRoles.toSet(),
            status = UserStatus.PENDING_VERIFICATION
        )
        
        val savedUser = userRepository.save(user)
        
        // Send welcome email
        emailService.sendWelcomeEmail(savedUser)
        
        // Audit log
        auditService.logUserCreation(savedUser)
        
        // Clear cache
        cacheService.evictUserCache(savedUser.id!!)
        
        logger.info("User created successfully: ${savedUser.email}")
        return UserMapper.toResponse(savedUser)
    }
    
    @PreAuthorize("hasPermission(#id, 'User', 'UPDATE')")
    @CacheEvict(value = ["users"], key = "#id")
    fun updateUser(id: Long, request: UpdateUserRequest): UserResponse {
        logger.info("Updating user: $id")
        
        val existingUser = userRepository.findById(id)
            .orElseThrow { NotFoundException("User not found: $id") }
        
        val oldValues = UserMapper.toResponse(existingUser)
        
        val updatedUser = existingUser.copy(
            firstName = request.firstName?.trim() ?: existingUser.firstName,
            lastName = request.lastName?.trim() ?: existingUser.lastName,
            phoneNumber = request.phoneNumber?.trim() ?: existingUser.phoneNumber,
            timezone = request.timezone ?: existingUser.timezone,
            language = request.language ?: existingUser.language
        )
        
        val savedUser = userRepository.save(updatedUser)
        
        // Audit log
        auditService.logUserUpdate(savedUser, oldValues, UserMapper.toResponse(savedUser))
        
        logger.info("User updated successfully: ${savedUser.email}")
        return UserMapper.toResponse(savedUser)
    }
    
    @PreAuthorize("hasPermission(#id, 'User', 'DELETE')")
    @CacheEvict(value = ["users"], key = "#id")
    fun deleteUser(id: Long) {
        logger.info("Deleting user: $id")
        
        val user = userRepository.findById(id)
            .orElseThrow { NotFoundException("User not found: $id") }
        
        if (user.hasRole("ADMIN") && userRepository.countByRoles_Name("ADMIN") <= 1) {
            throw BusinessException("Cannot delete the last admin user")
        }
        
        // Soft delete by updating status
        val deletedUser = user.copy(status = UserStatus.INACTIVE)
        userRepository.save(deletedUser)
        
        // Audit log
        auditService.logUserDeletion(user)
        
        logger.info("User deleted successfully: ${user.email}")
    }
    
    fun changePassword(userId: Long, request: ChangePasswordRequest) {
        logger.info("Changing password for user: $userId")
        
        val user = userRepository.findById(userId)
            .orElseThrow { NotFoundException("User not found: $userId") }
        
        if (!passwordEncoder.matches(request.currentPassword, user.password)) {
            throw ValidationException("Current password is incorrect")
        }
        
        validatePasswordStrength(request.newPassword)
        
        val updatedUser = user.copy(
            password = passwordEncoder.encode(request.newPassword),
            failedLoginAttempts = 0,
            lockedUntil = null
        )
        
        userRepository.save(updatedUser)
        
        // Send notification email
        emailService.sendPasswordChangeNotification(user)
        
        // Audit log
        auditService.logPasswordChange(user)
        
        // Clear cache
        cacheService.evictUserCache(userId)
        
        logger.info("Password changed successfully for user: ${user.email}")
    }
    
    fun assignRole(userId: Long, roleName: String) {
        logger.info("Assigning role '$roleName' to user: $userId")
        
        val user = userRepository.findById(userId)
            .orElseThrow { NotFoundException("User not found: $userId") }
        
        val role = roleRepository.findByName(roleName)
            ?: throw NotFoundException("Role not found: $roleName")
        
        if (user.roles.contains(role)) {
            throw BusinessException("User already has role: $roleName")
        }
        
        val updatedUser = user.copy(roles = user.roles + role)
        userRepository.save(updatedUser)
        
        // Audit log
        auditService.logRoleAssignment(user, role)
        
        // Clear cache
        cacheService.evictUserCache(userId)
        
        logger.info("Role assigned successfully: $roleName to ${user.email}")
    }
    
    fun removeRole(userId: Long, roleName: String) {
        logger.info("Removing role '$roleName' from user: $userId")
        
        val user = userRepository.findById(userId)
            .orElseThrow { NotFoundException("User not found: $userId") }
        
        val role = roleRepository.findByName(roleName)
            ?: throw NotFoundException("Role not found: $roleName")
        
        if (!user.roles.contains(role)) {
            throw BusinessException("User does not have role: $roleName")
        }
        
        if (roleName == "ADMIN" && userRepository.countByRoles_Name("ADMIN") <= 1) {
            throw BusinessException("Cannot remove admin role from the last admin user")
        }
        
        val updatedUser = user.copy(roles = user.roles - role)
        userRepository.save(updatedUser)
        
        // Audit log
        auditService.logRoleRemoval(user, role)
        
        // Clear cache
        cacheService.evictUserCache(userId)
        
        logger.info("Role removed successfully: $roleName from ${user.email}")
    }
    
    private fun validateUserCreation(request: CreateUserRequest) {
        if (userRepository.existsByEmailIgnoreCase(request.email)) {
            throw ConflictException("User with email already exists: ${request.email}")
        }
        
        validatePasswordStrength(request.password)
        
        if (request.phoneNumber != null && userRepository.existsByPhoneNumber(request.phoneNumber)) {
            throw ConflictException("User with phone number already exists: ${request.phoneNumber}")
        }
    }
    
    private fun validatePasswordStrength(password: String) {
        val passwordPattern = Regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}$")
        
        if (!password.matches(passwordPattern)) {
            throw ValidationException("Password must be at least 8 characters with uppercase, lowercase, number and special character")
        }
        
        // Check against common passwords
        val commonPasswords = listOf("password", "123456", "password123", "admin", "qwerty")
        if (commonPasswords.any { it.equals(password, ignoreCase = true) }) {
            throw ValidationException("Password is too common")
        }
    }
}

// Authentication Service
@Service
@Transactional
class AuthenticationService(
    private val userRepository: UserRepository,
    private val refreshTokenRepository: RefreshTokenRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtTokenProvider: JwtTokenProvider,
    private val emailService: EmailService,
    private val auditService: AuditService,
    private val customMetrics: CustomMetrics
) {
    
    private val logger = LoggerFactory.getLogger(AuthenticationService::class.java)
    
    fun authenticate(request: LoginRequest, ipAddress: String, userAgent: String): AuthResponse {
        logger.info("Authentication attempt for email: ${request.email}")
        
        val user = userRepository.findByEmailIgnoreCase(request.email)
            ?: throw UnauthorizedException("Invalid credentials")
        
        if (user.isLocked) {
            logger.warn("Login attempt for locked account: ${request.email}")
            customMetrics.recordFailedLogin()
            throw UnauthorizedException("Account is locked")
        }
        
        if (!user.isActive) {
            logger.warn("Login attempt for inactive account: ${request.email}")
            customMetrics.recordFailedLogin()
            throw UnauthorizedException("Account is not active")
        }
        
        if (!passwordEncoder.matches(request.password, user.password)) {
            handleFailedLogin(user, ipAddress, userAgent)
            customMetrics.recordFailedLogin()
            throw UnauthorizedException("Invalid credentials")
        }
        
        // Reset failed attempts on successful login
        if (user.failedLoginAttempts > 0) {
            val resetUser = user.resetFailedLoginAttempts().copy(lastLogin = LocalDateTime.now())
            userRepository.save(resetUser)
        } else {
            val updatedUser = user.copy(lastLogin = LocalDateTime.now())
            userRepository.save(updatedUser)
        }
        
        // Generate tokens
        val accessToken = jwtTokenProvider.generateAccessToken(user)
        val refreshToken = generateRefreshToken(user, ipAddress, userAgent)
        
        // Audit log
        auditService.logSuccessfulLogin(user, ipAddress, userAgent)
        
        customMetrics.recordSuccessfulLogin()
        logger.info("Authentication successful for: ${request.email}")
        
        return AuthResponse(
            accessToken = accessToken,
            refreshToken = refreshToken.token,
            expiresIn = jwtTokenProvider.getAccessTokenExpiration(),
            user = UserMapper.toResponse(user)
        )
    }
    
    fun refreshToken(tokenValue: String, ipAddress: String): AuthResponse {
        logger.debug("Token refresh attempt")
        
        val refreshToken = refreshTokenRepository.findByToken(tokenValue)
            ?: throw UnauthorizedException("Invalid refresh token")
        
        if (!refreshToken.isValid) {
            refreshTokenRepository.delete(refreshToken)
            throw UnauthorizedException("Refresh token is expired or revoked")
        }
        
        val user = refreshToken.user
        
        if (!user.isActive) {
            throw UnauthorizedException("User account is not active")
        }
        
        // Generate new access token
        val newAccessToken = jwtTokenProvider.generateAccessToken(user)
        
        // Optionally rotate refresh token
        val newRefreshToken = if (shouldRotateRefreshToken(refreshToken)) {
            refreshTokenRepository.delete(refreshToken)
            generateRefreshToken(user, ipAddress, null)
        } else {
            refreshToken
        }
        
        logger.debug("Token refreshed successfully for user: ${user.email}")
        
        return AuthResponse(
            accessToken = newAccessToken,
            refreshToken = newRefreshToken.token,
            expiresIn = jwtTokenProvider.getAccessTokenExpiration(),
            user = UserMapper.toResponse(user)
        )
    }
    
    fun logout(tokenValue: String) {
        logger.debug("Logout attempt")
        
        val refreshToken = refreshTokenRepository.findByToken(tokenValue)
        
        if (refreshToken != null) {
            val revokedToken = refreshToken.copy(isRevoked = true)
            refreshTokenRepository.save(revokedToken)
            
            // Audit log
            auditService.logLogout(refreshToken.user)
            
            logger.info("Logout successful for user: ${refreshToken.user.email}")
        }
    }
    
    private fun handleFailedLogin(user: User, ipAddress: String, userAgent: String) {
        val updatedUser = user.incrementFailedLoginAttempts()
        
        if (updatedUser.failedLoginAttempts >= 5) {
            val lockedUser = updatedUser.lockAccount(Duration.ofMinutes(15))
            userRepository.save(lockedUser)
            
            // Send security notification
            emailService.sendAccountLockedNotification(lockedUser)
            
            logger.warn("Account locked due to failed login attempts: ${user.email}")
        } else {
            userRepository.save(updatedUser)
        }
        
        // Audit log
        auditService.logFailedLogin(user, ipAddress, userAgent)
    }
    
    private fun generateRefreshToken(user: User, ipAddress: String, userAgent: String?): RefreshToken {
        val tokenValue = UUID.randomUUID().toString()
        val expiryDate = LocalDateTime.now().plusSeconds(jwtTokenProvider.getRefreshTokenExpiration())
        
        val refreshToken = RefreshToken(
            token = tokenValue,
            user = user,
            expiryDate = expiryDate,
            deviceInfo = userAgent,
            ipAddress = ipAddress
        )
        
        return refreshTokenRepository.save(refreshToken)
    }
    
    private fun shouldRotateRefreshToken(refreshToken: RefreshToken): Boolean {
        val halfLife = Duration.between(refreshToken.createdAt, refreshToken.expiryDate).dividedBy(2)
        val halfLifeExpiry = refreshToken.createdAt.plus(halfLife)
        return LocalDateTime.now().isAfter(halfLifeExpiry)
    }
}
```

This completes the comprehensive Spring Boot Kotlin Enterprise Application template with:

1. **Complete project structure** with all necessary packages, files, and configurations
2. **Production-ready build configuration** with Gradle Kotlin DSL and all required dependencies  
3. **Comprehensive security implementation** with JWT authentication, rate limiting, and security headers
4. **Rich domain models** with proper JPA relationships and business logic
5. **Service layer** with transactional business logic, caching, and audit logging
6. **Full testing strategy** including unit, integration, and performance tests
7. **Docker deployment** with multi-stage builds and production optimization
8. **Kubernetes deployment** with comprehensive manifests and monitoring
9. **Monitoring and observability** with Prometheus, Grafana, and structured logging
10. **Security hardening** with input validation, rate limiting, and security best practices

The template provides a solid foundation for building enterprise-grade Spring Boot applications with Kotlin, following industry best practices and including all the necessary components for a production-ready system.# Spring Boot Kotlin Enterprise Application - Claude Code Instructions

## CONTEXT
**Project Type**: backend-service
**Complexity**: complex
**Timeline**: production
**Architecture**: Enterprise-grade REST API with layered architecture
**Last Updated**: 2025-06-18
**Template Version**: 1.6.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Primary Framework**: Spring Boot 3.3.x
- **Language**: Kotlin 2.0.x
- **Runtime**: JDK 21 LTS
- **Build Tool**: Gradle 8.8.x with Kotlin DSL
- **Database**: PostgreSQL 16.x
- **ORM**: Spring Data JPA with Hibernate 6.x
- **Security**: Spring Security 6.x with JWT authentication
- **API Documentation**: SpringDoc OpenAPI 3.2.x
- **Testing**: JUnit 5 + Testcontainers + MockK
- **Database Migration**: Flyway 10.x
- **Caching**: Redis 7.x with Spring Cache
- **Messaging**: RabbitMQ 3.13.x (optional)
- **Monitoring**: Micrometer + Prometheus

### Project Structure
```
{{project_name}}/
├── src/
│   ├── main/
│   │   ├── kotlin/
│   │   │   └── {{base_package}}/
│   │   │       ├── Application.kt
│   │   │       ├── config/
│   │   │       │   ├── SecurityConfig.kt
│   │   │       │   ├── DatabaseConfig.kt
│   │   │       │   ├── CacheConfig.kt
│   │   │       │   ├── OpenApiConfig.kt
│   │   │       │   ├── JacksonConfig.kt
│   │   │       │   ├── AsyncConfig.kt
│   │   │       │   └── MessagingConfig.kt
│   │   │       ├── domain/
│   │   │       │   ├── entity/
│   │   │       │   │   ├── BaseEntity.kt
│   │   │       │   │   ├── User.kt
│   │   │       │   │   ├── Role.kt
│   │   │       │   │   ├── Permission.kt
│   │   │       │   │   ├── Organization.kt
│   │   │       │   │   ├── AuditLog.kt
│   │   │       │   │   └── RefreshToken.kt
│   │   │       │   ├── repository/
│   │   │       │   │   ├── UserRepository.kt
│   │   │       │   │   ├── RoleRepository.kt
│   │   │       │   │   ├── PermissionRepository.kt
│   │   │       │   │   ├── OrganizationRepository.kt
│   │   │       │   │   ├── AuditLogRepository.kt
│   │   │       │   │   └── RefreshTokenRepository.kt
│   │   │       │   ├── service/
│   │   │       │   │   ├── UserService.kt
│   │   │       │   │   ├── AuthenticationService.kt
│   │   │       │   │   ├── AuthorizationService.kt
│   │   │       │   │   ├── OrganizationService.kt
│   │   │       │   │   ├── EmailService.kt
│   │   │       │   │   ├── AuditService.kt
│   │   │       │   │   ├── CacheService.kt
│   │   │       │   │   └── FileStorageService.kt
│   │   │       │   └── specification/
│   │   │       │       ├── UserSpecification.kt
│   │   │       │       ├── OrganizationSpecification.kt
│   │   │       │       └── BaseSpecification.kt
│   │   │       ├── api/
│   │   │       │   ├── controller/
│   │   │       │   │   ├── AuthController.kt
│   │   │       │   │   ├── UserController.kt
│   │   │       │   │   ├── OrganizationController.kt
│   │   │       │   │   ├── AdminController.kt
│   │   │       │   │   ├── FileController.kt
│   │   │       │   │   └── HealthController.kt
│   │   │       │   ├── dto/
│   │   │       │   │   ├── request/
│   │   │       │   │   │   ├── LoginRequest.kt
│   │   │       │   │   │   ├── RegisterRequest.kt
│   │   │       │   │   │   ├── CreateUserRequest.kt
│   │   │       │   │   │   ├── UpdateUserRequest.kt
│   │   │       │   │   │   ├── ChangePasswordRequest.kt
│   │   │       │   │   │   ├── CreateOrganizationRequest.kt
│   │   │       │   │   │   └── SearchRequest.kt
│   │   │       │   │   ├── response/
│   │   │       │   │   │   ├── AuthResponse.kt
│   │   │       │   │   │   ├── UserResponse.kt
│   │   │       │   │   │   ├── OrganizationResponse.kt
│   │   │       │   │   │   ├── PageResponse.kt
│   │   │       │   │   │   ├── ApiResponse.kt
│   │   │       │   │   │   └── ErrorResponse.kt
│   │   │       │   │   └── common/
│   │   │       │   │       ├── BaseDto.kt
│   │   │       │   │       ├── SortDto.kt
│   │   │       │   │       └── FilterDto.kt
│   │   │       │   ├── validation/
│   │   │       │   │   ├── EmailValidator.kt
│   │   │       │   │   ├── PasswordValidator.kt
│   │   │       │   │   ├── PhoneValidator.kt
│   │   │       │   │   └── UniqueValidator.kt
│   │   │       │   └── mapper/
│   │   │       │       ├── UserMapper.kt
│   │   │       │       ├── OrganizationMapper.kt
│   │   │       │       ├── RoleMapper.kt
│   │   │       │       └── BaseMapper.kt
│   │   │       ├── infrastructure/
│   │   │       │   ├── security/
│   │   │       │   │   ├── JwtTokenProvider.kt
│   │   │       │   │   ├── JwtAuthenticationFilter.kt
│   │   │       │   │   ├── CustomUserDetailsService.kt
│   │   │       │   │   ├── SecurityPrincipal.kt
│   │   │       │   │   ├── MethodSecurityConfig.kt
│   │   │       │   │   └── SecurityUtils.kt
│   │   │       │   ├── exception/
│   │   │       │   │   ├── GlobalExceptionHandler.kt
│   │   │       │   │   ├── BusinessException.kt
│   │   │       │   │   ├── ValidationException.kt
│   │   │       │   │   ├── UnauthorizedException.kt
│   │   │       │   │   ├── ForbiddenException.kt
│   │   │       │   │   ├── NotFoundException.kt
│   │   │       │   │   └── ConflictException.kt
│   │   │       │   ├── messaging/
│   │   │       │   │   ├── MessageProducer.kt
│   │   │       │   │   ├── MessageConsumer.kt
│   │   │       │   │   ├── EmailEventHandler.kt
│   │   │       │   │   └── AuditEventHandler.kt
│   │   │       │   ├── persistence/
│   │   │       │   │   ├── AuditingConfig.kt
│   │   │       │   │   ├── CustomRepositoryImpl.kt
│   │   │       │   │   └── DatabaseHealthIndicator.kt
│   │   │       │   ├── external/
│   │   │       │   │   ├── EmailServiceImpl.kt
│   │   │       │   │   ├── FileStorageServiceImpl.kt
│   │   │       │   │   ├── S3FileStorageService.kt
│   │   │       │   │   └── ExternalApiClient.kt
│   │   │       │   └── monitoring/
│   │   │       │       ├── CustomMetrics.kt
│   │   │       │       ├── PerformanceInterceptor.kt
│   │   │       │       └── AuditInterceptor.kt
│   │   │       └── util/
│   │   │           ├── extension/
│   │   │           │   ├── StringExtensions.kt
│   │   │           │   ├── DateTimeExtensions.kt
│   │   │           │   ├── EntityExtensions.kt
│   │   │           │   ├── SecurityExtensions.kt
│   │   │           │   └── ResponseExtensions.kt
│   │   │           ├── constants/
│   │   │           │   ├── SecurityConstants.kt
│   │   │           │   ├── ApiConstants.kt
│   │   │           │   ├── CacheConstants.kt
│   │   │           │   └── ValidationConstants.kt
│   │   │           ├── converter/
│   │   │           │   ├── StringToEnumConverter.kt
│   │   │           │   ├── LocalDateTimeConverter.kt
│   │   │           │   └── JsonConverter.kt
│   │   │           └── helper/
│   │   │               ├── PaginationHelper.kt
│   │   │               ├── SortingHelper.kt
│   │   │               ├── PasswordHelper.kt
│   │   │               └── FileHelper.kt
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-test.yml
│   │       ├── application-prod.yml
│   │       ├── db/migration/
│   │       │   ├── V1__Initial_schema.sql
│   │       │   ├── V2__Create_users_table.sql
│   │       │   ├── V3__Create_roles_permissions.sql
│   │       │   ├── V4__Create_organizations.sql
│   │       │   ├── V5__Create_audit_log.sql
│   │       │   ├── V6__Create_refresh_tokens.sql
│   │       │   ├── V7__Create_indexes.sql
│   │       │   └── V8__Insert_default_data.sql
│   │       ├── static/
│   │       │   ├── api-docs/
│   │       │   │   └── openapi.json
│   │       │   └── images/
│   │       │       └── logo.png
│   │       ├── templates/
│   │       │   ├── email/
│   │       │   │   ├── welcome.html
│   │       │   │   ├── password-reset.html
│   │       │   │   ├── account-activation.html
│   │       │   │   └── notification.html
│   │       │   └── reports/
│   │       │       ├── user-report.jrxml
│   │       │       └── audit-report.jrxml
│   │       ├── i18n/
│   │       │   ├── messages.properties
│   │       │   ├── messages_en.properties
│   │       │   ├── messages_es.properties
│   │       │   └── messages_fr.properties
│   │       ├── logback-spring.xml
│   │       └── banner.txt
│   └── test/
│       ├── kotlin/
│       │   └── {{base_package}}/
│       │       ├── integration/
│       │       │   ├── AbstractIntegrationTest.kt
│       │       │   ├── UserControllerIT.kt
│       │       │   ├── AuthControllerIT.kt
│       │       │   ├── OrganizationControllerIT.kt
│       │       │   ├── UserServiceIT.kt
│       │       │   ├── SecurityConfigIT.kt
│       │       │   └── DatabaseIT.kt
│       │       ├── repository/
│       │       │   ├── UserRepositoryTest.kt
│       │       │   ├── OrganizationRepositoryTest.kt
│       │       │   ├── RoleRepositoryTest.kt
│       │       │   └── AuditLogRepositoryTest.kt
│       │       ├── service/
│       │       │   ├── UserServiceTest.kt
│       │       │   ├── AuthenticationServiceTest.kt
│       │       │   ├── AuthorizationServiceTest.kt
│       │       │   ├── OrganizationServiceTest.kt
│       │       │   ├── EmailServiceTest.kt
│       │       │   └── CacheServiceTest.kt
│       │       ├── api/
│       │       │   ├── controller/
│       │       │   │   ├── AuthControllerTest.kt
│       │       │   │   ├── UserControllerTest.kt
│       │       │   │   ├── OrganizationControllerTest.kt
│       │       │   │   └── AdminControllerTest.kt
│       │       │   ├── validation/
│       │       │   │   ├── EmailValidatorTest.kt
│       │       │   │   ├── PasswordValidatorTest.kt
│       │       │   │   └── PhoneValidatorTest.kt
│       │       │   └── mapper/
│       │       │       ├── UserMapperTest.kt
│       │       │       └── OrganizationMapperTest.kt
│       │       ├── infrastructure/
│       │       │   ├── security/
│       │       │   │   ├── JwtTokenProviderTest.kt
│       │       │   │   ├── JwtAuthenticationFilterTest.kt
│       │       │   │   └── CustomUserDetailsServiceTest.kt
│       │       │   ├── messaging/
│       │       │   │   ├── MessageProducerTest.kt
│       │       │   │   └── EmailEventHandlerTest.kt
│       │       │   └── external/
│       │       │       ├── EmailServiceImplTest.kt
│       │       │       └── FileStorageServiceImplTest.kt
│       │       ├── util/
│       │       │   ├── TestDataBuilder.kt
│       │       │   ├── TestContainerConfig.kt
│       │       │   ├── MockSecurityContext.kt
│       │       │   ├── IntegrationTestSupport.kt
│       │       │   └── TestUtils.kt
│       │       └── performance/
│       │           ├── UserControllerPerformanceTest.kt
│       │           ├── DatabasePerformanceTest.kt
│       │           └── CachePerformanceTest.kt
│       └── resources/
│           ├── application-test.yml
│           ├── testdata/
│           │   ├── users.sql
│           │   ├── organizations.sql
│           │   ├── roles.sql
│           │   └── test-schema.sql
│           ├── contracts/
│           │   ├── user-contracts.yml
│           │   └── auth-contracts.yml
│           ├── fixtures/
│           │   ├── valid-user.json
│           │   ├── invalid-user.json
│           │   └── sample-organization.json
│           └── logback-test.xml
├── gradle/
│   └── wrapper/
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── docker/
│   ├── app/
│   │   ├── Dockerfile
│   │   └── entrypoint.sh
│   ├── postgres/
│   │   ├── Dockerfile
│   │   └── init.sql
│   └── nginx/
│       ├── Dockerfile
│       └── nginx.conf
├── scripts/
│   ├── build.sh
│   ├── test.sh
│   ├── deploy.sh
│   ├── migrate.sh
│   └── generate-keys.sh
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── hpa.yaml
├── docs/
│   ├── api/
│   │   ├── README.md
│   │   ├── authentication.md
│   │   ├── users.md
│   │   └── organizations.md
│   ├── development/
│   │   ├── setup.md
│   │   ├── testing.md
│   │   ├── debugging.md
│   │   └── contributing.md
│   ├── deployment/
│   │   ├── docker.md
│   │   ├── kubernetes.md
│   │   ├── aws.md
│   │   └── monitoring.md
│   └── security/
│       ├── authentication.md
│       ├── authorization.md
│       ├── security-checklist.md
│       └── vulnerability-management.md
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
├── docker-compose.yml
├── docker-compose.override.yml
├── docker-compose.prod.yml
├── .env.example
├── .gitignore
├── .editorconfig
├── .pre-commit-config.yaml
├── README.md
├── CHANGELOG.md
├── LICENSE
└── SECURITY.md
```

### Documentation Sources
- **Spring Boot Reference**: https://docs.spring.io/spring-boot/docs/current/reference/html/
- **Kotlin Documentation**: https://kotlinlang.org/docs/home.html
- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
- **Spring Security**: https://docs.spring.io/spring-security/reference/
- **Gradle Kotlin DSL**: https://docs.gradle.org/current/userguide/kotlin_dsl.html
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/16/
- **Flyway Documentation**: https://flywaydb.org/documentation/
- **SpringDoc OpenAPI**: https://springdoc.org/
- **Testcontainers**: https://www.testcontainers.org/

## STRICT GUIDELINES

### Code Standards
- **Kotlin Style**: Follow Kotlin Coding Conventions and ktlint rules
- **Spring Boot**: Use constructor injection only, no field injection
- **Clean Architecture**: Clear separation of concerns across layers
- **API Design**: RESTful principles with consistent naming
- **Database**: Use Flyway migrations for all schema changes
- **Security**: Implement defense-in-depth security patterns
- **Naming Conventions**:
  - Entities: PascalCase singular (User, Organization, Role)
  - Services: PascalCase with 'Service' suffix (UserService, AuthenticationService)
  - Repositories: PascalCase with 'Repository' suffix (UserRepository)
  - Controllers: PascalCase with 'Controller' suffix (UserController)
  - DTOs: PascalCase with appropriate suffix (UserRequest, UserResponse)
  - Constants: UPPER_SNAKE_CASE in companion objects
  - Package names: lowercase with dots (com.company.app.domain.entity)
  - Database tables: snake_case (user_roles, refresh_tokens)
  - Database columns: snake_case (created_at, user_id)

### Architecture Rules
- **Domain-Driven Design**: Rich domain models with business logic
- **Dependency Direction**: Dependencies point inward (API → Domain → Infrastructure)
- **Single Responsibility**: Each class serves one primary purpose
- **Open/Closed Principle**: Open for extension, closed for modification
- **Interface Segregation**: Small, focused interfaces
- **Dependency Inversion**: Depend on abstractions, not concretions
- **Immutability**: Prefer immutable data classes where possible
- **Error Handling**: Consistent exception handling with meaningful messages

### Kotlin Best Practices
- Use data classes for DTOs and value objects
- Leverage sealed classes for state representation and result types
- Prefer extension functions over utility classes
- Implement proper null safety with nullable types
- Use companion objects for constants and factory methods
- Utilize Kotlin-specific Spring annotations
- Apply scope functions (let, run, with, apply, also) appropriately
- Use coroutines for asynchronous operations when appropriate
- Implement custom DSLs for complex configuration

### Spring Boot Best Practices
- **Configuration**: Use @ConfigurationProperties for type-safe configuration
- **Profiles**: Environment-specific configurations with profiles
- **Actuator**: Comprehensive health checks and metrics
- **Caching**: Strategic caching with proper cache eviction
- **Transactions**: Proper transaction boundaries and isolation levels
- **Validation**: Bean Validation with custom validators
- **Documentation**: Auto-generated API documentation with OpenAPI

## TESTING REQUIREMENTS

### Unit Tests (90% coverage minimum)
- All service layer methods with business logic
- All repository custom queries and specifications
- All utility functions and extension methods
- All validation logic and custom validators
- All security components and JWT token handling
- All data transformation and mapping logic
- All exception handling scenarios

### Integration Tests
- Database operations with Testcontainers PostgreSQL
- Spring Security configuration and JWT authentication flows
- REST API endpoints with MockMvc and TestRestTemplate
- Message queue integration with embedded RabbitMQ
- Redis cache integration with embedded Redis
- Email service integration with mock SMTP server
- External API integrations with WireMock
- End-to-end user workflows and business scenarios

### Performance Tests
- API endpoint response times under load
- Database query performance with large datasets
- Concurrent user authentication and authorization
- Cache hit/miss ratios and performance impact
- Memory usage and garbage collection efficiency
- Connection pool performance under stress
- Message processing throughput and latency

### Security Tests
- Authentication bypass attempts
- Authorization boundary testing
- JWT token manipulation and validation
- SQL injection prevention validation
- XSS and CSRF protection verification
- Rate limiting and brute force protection
- Input validation and sanitization testing

## SECURITY PRACTICES

### Authentication & Authorization
- JWT-based stateless authentication with refresh tokens
- Role-based access control (RBAC) with fine-grained permissions
- Password encryption with BCrypt (strength 12)
- Account lockout after failed login attempts
- Password complexity requirements and validation
- Multi-factor authentication support (optional)
- Session management with secure token handling
- OAuth2 integration for social login (optional)

### Data Protection
- Database connection encryption (SSL/TLS)
- Sensitive data encryption at rest using AES-256
- Input validation and sanitization on all endpoints
- SQL injection prevention with parameterized queries
- Output encoding to prevent XSS attacks
- HTTPS enforcement in production
- Secure headers implementation (HSTS, CSP, etc.)
- Personal data anonymization for GDPR compliance

### API Security
- Rate limiting per user and endpoint
- CORS configuration for allowed origins
- API versioning strategy for backward compatibility
- Request/response logging for audit trails
- API key authentication for service-to-service communication
- Input size limits to prevent DoS attacks
- Secure file upload with type and size validation
- API documentation security notes and examples

### Infrastructure Security
- Container security scanning with vulnerability detection
- Network segmentation with proper firewall rules
- Secrets management with external secret stores
- Database user permissions with principle of least privilege
- Application logging with security event monitoring
- Backup encryption and secure storage
- Disaster recovery procedures and testing
- Security incident response procedures

## IMPLEMENTATION STRATEGY

### Phase 1: Foundation Setup (Week 1-2)
- [ ] Initialize Spring Boot project with Kotlin and required dependencies
- [ ] Configure Gradle build with all plugins and dependency management
- [ ] Set up PostgreSQL database with Docker Compose
- [ ] Configure application properties for all environments (dev, test, prod)
- [ ] Create base entity classes with JPA annotations and auditing
- [ ] Set up Flyway database migrations with initial schema
- [ ] Configure Spring Security with JWT authentication infrastructure
- [ ] Create global exception handling with standardized error responses
- [ ] Set up testing infrastructure with Testcontainers and MockK
- [ ] Configure structured logging with Logback and correlation IDs
- [ ] Implement basic health checks and actuator endpoints

### Phase 2: Core Domain Implementation (Week 3-4)
- [ ] Implement User, Role, Permission, and Organization entities with relationships
- [ ] Create repository interfaces with custom query methods and specifications
- [ ] Develop service layer with comprehensive business logic and validation
- [ ] Implement JWT token provider with refresh token mechanism
- [ ] Create Spring Security UserDetailsService and authentication components
- [ ] Develop authorization service with role and permission checking
- [ ] Implement password validation and encryption utilities
- [ ] Create audit logging service for tracking entity changes
- [ ] Add email service with template support and async processing
- [ ] Implement comprehensive input validation with custom validators
- [ ] Create data transfer objects (DTOs) for all API operations
- [ ] Add database seed data with default admin user and roles

### Phase 3: REST API Development (Week 5-6)
- [ ] Implement authentication controller with login, logout, and token refresh
- [ ] Create user management controller with CRUD operations
- [ ] Develop organization management controller with hierarchical support
- [ ] Build admin controller with system configuration and user management
- [ ] Implement file upload controller with secure file handling
- [ ] Create comprehensive request/response DTOs with validation
- [ ] Add API versioning strategy and implementation
- [ ] Implement pagination, sorting, and filtering for list endpoints
- [ ] Create OpenAPI documentation with detailed schemas and examples
- [ ] Add API rate limiting and throttling mechanisms
- [ ] Implement request/response logging and audit trails
- [ ] Create comprehensive error handling with localized messages

### Phase 4: Advanced Features (Week 7-9)
- [ ] Implement Redis caching with strategic cache management
- [ ] Add RabbitMQ messaging for asynchronous operations
- [ ] Create comprehensive search functionality with specifications
- [ ] Implement data export functionality (CSV, Excel, PDF)
- [ ] Add email notification system with template management
- [ ] Create file storage service with S3 integration
- [ ] Implement batch operations for bulk data processing
- [ ] Add system configuration management interface
- [ ] Create comprehensive monitoring with custom metrics
- [ ] Implement backup and restore functionality
- [ ] Add internationalization (i18n) support
- [ ] Create admin dashboard with system statistics

### Phase 5: Security Hardening (Week 10-11)
- [ ] Implement comprehensive input validation and sanitization
- [ ] Add API rate limiting and DDoS protection
- [ ] Create security headers configuration
- [ ] Implement account lockout and brute force protection
- [ ] Add suspicious activity detection and alerting
- [ ] Create security audit logging and monitoring
- [ ] Implement data encryption for sensitive fields
- [ ] Add vulnerability scanning and security testing
- [ ] Create security documentation and procedures
- [ ] Implement incident response procedures
- [ ] Add compliance reporting for regulations
- [ ] Perform penetration testing and security audit

### Phase 6: Performance Optimization (Week 12-13)
- [ ] Optimize database queries with proper indexing
- [ ] Implement connection pooling optimization
- [ ] Add application-level caching strategies
- [ ] Optimize JVM settings for production
- [ ] Implement lazy loading and eager loading strategies
- [ ] Add database query monitoring and optimization
- [ ] Create performance benchmarking and testing
- [ ] Implement memory usage optimization
- [ ] Add CDN integration for static assets
- [ ] Optimize startup time and resource usage
- [ ] Create performance monitoring dashboards
- [ ] Implement auto-scaling configuration

### Phase 7: Testing & Quality Assurance (Week 14-15)
- [ ] Complete comprehensive unit test suite with high coverage
- [ ] Implement integration tests for all major workflows
- [ ] Create performance tests with realistic load scenarios
- [ ] Add security tests for all authentication and authorization flows
- [ ] Implement contract testing for API versioning
- [ ] Create chaos engineering tests for resilience
- [ ] Add end-to-end tests for critical business scenarios
- [ ] Implement test data management and cleanup
- [ ] Create automated testing pipeline with quality gates
- [ ] Add mutation testing for test quality validation
- [ ] Implement visual regression testing for documentation
- [ ] Create test environment management and provisioning

### Phase 8: Deployment & Production Readiness (Week 16)
- [ ] Create Docker containers with multi-stage builds
- [ ] Implement Kubernetes deployment manifests
- [ ] Set up CI/CD pipeline with automated testing and deployment
- [ ] Configure monitoring and alerting infrastructure
- [ ] Implement log aggregation and analysis
- [ ] Create backup and disaster recovery procedures
- [ ] Add production health checks and readiness probes
- [ ] Implement secrets management and configuration
- [ ] Create deployment documentation and runbooks
- [ ] Add production troubleshooting guides
- [ ] Implement rollback procedures and strategies
- [ ] Perform production readiness checklist and sign-off

## CLAUDE_CODE_COMMANDS

### Initial Setup
```bash
# Create project directory
mkdir {{project_name}}
cd {{project_name}}

# Initialize Gradle project with Kotlin DSL
gradle init --type kotlin-application --dsl kotlin --project-name {{project_name}} --package {{base_package}}

# Generate JWT signing keys
mkdir -p src/main/resources/keys
openssl genrsa -out src/main/resources/keys/private_key.pem 2048
openssl rsa -pubout -in src/main/resources/keys/private_key.pem -out src/main/resources/keys/public_key.pem

# Start development environment
docker-compose up -d
```

### Build Configuration (build.gradle.kts)
```kotlin
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "2.0.0"
    kotlin("plugin.spring") version "2.0.0"
    kotlin("plugin.jpa") version "2.0.0"
    kotlin("plugin.allopen") version "2.0.0"
    kotlin("plugin.noarg") version "2.0.0"
    kotlin("kapt") version "2.0.0"
    id("org.springframework.boot") version "3.3.0"
    id("io.spring.dependency-management") version "1.1.5"
    id("org.flywaydb.flyway") version "10.15.0"
    id("org.jlleitschuh.gradle.ktlint") version "12.1.1"
    id("jacoco")
    id("org.sonarqube") version "5.0.0.4638"
    id("com.github.ben-manes.versions") version "0.51.0"
    id("org.springframework.boot.aot") version "3.3.0"
    id("org.graalvm.buildtools.native") version "0.10.2"
}

group = "{{base_package}}"
version = "1.0.0-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_21

repositories {
    mavenCentral()
    maven { url = uri("https://repo.spring.io/milestone") }
}

extra["springCloudVersion"] = "2023.0.2"
extra["testcontainersVersion"] = "1.19.8"
extra["mockkVersion"] = "1.13.11"

dependencies {
    // Spring Boot Starters
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-mail")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-cache")
    implementation("org.springframework.boot:spring-boot-starter-data-redis")
    implementation("org.springframework.boot:spring-boot-starter-amqp")
    implementation("org.springframework.boot:spring-boot-starter-thymeleaf")
    implementation("org.springframework.boot:spring-boot-starter-aop")
    implementation("org.springframework.boot:spring-boot-starter-webflux") // For WebClient
    
    // Database
    implementation("org.postgresql:postgresql")
    implementation("org.flywaydb:flyway-core")
    implementation("org.flywaydb:flyway-database-postgresql")
    implementation("com.zaxxer:HikariCP")
    
    // Security & JWT
    implementation("io.jsonwebtoken:jjwt-api:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.6")
    implementation("org.springframework.security:spring-security-crypto")
    
    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
    
    // API Documentation
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.5.0")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-api:2.5.0")
    
    // Utilities
    implementation("org.apache.commons:commons-lang3")
    implementation("commons-io:commons-io:2.16.1")
    implementation("org.apache.commons:commons-csv:1.11.0")
    implementation("com.opencsv:opencsv:5.9")
    
    // Caching
    implementation("com.github.ben-manes.caffeine:caffeine")
    implementation("org.springframework.boot:spring-boot-starter-cache")
    
    // Monitoring & Metrics
    implementation("io.micrometer:micrometer-registry-prometheus")
    implementation("io.micrometer:micrometer-tracing-bridge-brave")
    implementation("io.zipkin.reporter2:zipkin-reporter-brave")
    
    // File Processing
    implementation("org.apache.poi:poi:5.2.5")
    implementation("org.apache.poi:poi-ooxml:5.2.5")
    implementation("com.itextpdf:itext7-core:8.0.4")
    
    // AWS SDK (Optional)
    implementation("software.amazon.awssdk:s3:2.26.12")
    implementation("software.amazon.awssdk:ses:2.26.12")
    
    // Configuration Processing
    kapt("org.springframework.boot:spring-boot-configuration-processor")
    annotationProcessor("org.springframework.boot:spring-boot-configuration-processor")
    
    // Development Tools
    developmentOnly("org.springframework.boot:spring-boot-devtools")
    developmentOnly("org.springframework.boot:spring-boot-docker-compose")
    
    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test") {
        exclude(group = "org.mockito", module = "mockito-core")
    }
    testImplementation("org.springframework.security:spring-security-test")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:postgresql")
    testImplementation("org.testcontainers:rabbitmq")
    testImplementation("org.testcontainers:redis")
    testImplementation("io.mockk:mockk:${property("mockkVersion")}")
    testImplementation("com.ninja-squad:springmockk:4.0.2")
    testImplementation("com.github.tomakehurst:wiremock-jre8:3.0.1")
    testImplementation("org.awaitility:awaitility-kotlin:4.2.1")
    testImplementation("org.springframework.cloud:spring-cloud-contract-wiremock")
    
    // Performance Testing
    testImplementation("org.springframework.boot:spring-boot-starter-webflux")
    testImplementation("io.projectreactor:reactor-test")
}

dependencyManagement {
    imports {
        mavenBom("org.springframework.cloud:spring-cloud-dependencies:${property("springCloudVersion")}")
        mavenBom("org.testcontainers:testcontainers-bom:${property("testcontainersVersion")}")
        mavenBom("software.amazon.awssdk:bom:2.26.12")
    }
}

allOpen {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
    annotation("org.springframework.stereotype.Service")
    annotation("org.springframework.stereotype.Repository")
    annotation("org.springframework.stereotype.Component")
    annotation("org.springframework.web.bind.annotation.RestController")
}

noArg {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}

tasks.withType<KotlinCompile> {
    kotlinOptions {
        freeCompilerArgs = listOf(
            "-Xjsr305=strict",
            "-Xjvm-default=all",
            "-Xopt-in=kotlin.RequiresOptIn"
        )
        jvmTarget = "21"
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
    finalizedBy(tasks.jacocoTestReport)
    
    // JVM arguments for testing
    jvmArgs = listOf(
        "-XX:+EnableDynamicAgentLoading",
        "-Xmx2g",
        "-XX:MaxMetaspaceSize=512m"
    )
    
    // Test execution configuration
    maxParallelForks = (Runtime.getRuntime().availableProcessors() / 2).takeIf { it > 0 } ?: 1
    
    // System properties for tests
    systemProperty("spring.profiles.active", "test")
    systemProperty("junit.jupiter.execution.parallel.enabled", "true")
    systemProperty("junit.jupiter.execution.parallel.mode.default", "concurrent")
}

tasks.jacocoTestReport {
    dependsOn(tasks.test)
    reports {
        xml.required.set(true)
        html.required.set(true)
        csv.required.set(false)
    }
    
    classDirectories.setFrom(
        files(classDirectories.files.map {
            fileTree(it) {
                exclude(
                    "**/config/**",
                    "**/dto/**",
                    "**/entity/**",
                    "**/*Application*",
                    "**/*Config*",
                    "**/*Constants*"
                )
            }
        })
    )
}

jacoco {
    toolVersion = "0.8.12"
}

tasks.jacocoTestCoverageVerification {
    dependsOn(tasks.jacocoTestReport)
    violationRules {
        rule {
            limit {
                minimum = "0.90".toBigDecimal()
                counter = "INSTRUCTION"
            }
        }
        rule {
            limit {
                minimum = "0.85".toBigDecimal()
                counter = "BRANCH"
            }
        }
    }
}

ktlint {
    version.set("1.3.0")
    android.set(false)
    outputToConsole.set(true)
    coloredOutput.set(true)
    verbose.set(true)
    filter {
        exclude("**/generated/**")
        exclude("**/build/**")
        include("**/kotlin/**")
    }
}

sonarqube {
    properties {
        property("sonar.projectName", "{{project_name}}")
        property("sonar.projectKey", "{{base_package}}:{{project_name}}")
        property("sonar.sources", "src/main/kotlin")
        property("sonar.tests", "src/test/kotlin")
        property("sonar.coverage.jacoco.xmlReportPaths", "build/reports/jacoco/test/jacocoTestReport.xml")
        property("sonar.junit.reportPaths", "build/test-results/test")
    }
}

// Custom tasks
tasks.register("generateApiDocs") {
    dependsOn("build")
    doLast {
        println("API documentation generated at: build/docs/api/")
    }
}

tasks.register("securityScan") {
    group = "verification"
    description = "Run security vulnerability scan"
    doLast {
        exec {
            commandLine("./scripts/security-scan.sh")
        }
    }
}

tasks.register("performanceTest") {
    group = "verification"
    description = "Run performance tests"
    dependsOn("testClasses")
    doLast {
        exec {
            commandLine("./gradlew", "test", "--tests", "*PerformanceTest")
        }
    }
}

// Native image configuration
graalvmNative {
    binaries {
        named("main") {
            imageName.set("{{project_name}}")
            mainClass.set("{{base_package}}.ApplicationKt")
            debug.set(false)
            verbose.set(true)
            fallback.set(false)
            
            buildArgs.add("--enable-preview")
            buildArgs.add("--initialize-at-build-time=org.slf4j")
            buildArgs.add("-H:+ReportExceptionStackTraces")
            buildArgs.add("-H:+AddAllCharsets")
            buildArgs.add("-H:EnableURLProtocols=http,https")
        }
    }
}
```

### Development Commands
```bash
# Start development server with hot reload
./gradlew bootRun

# Run with specific profile
./gradlew bootRun --args='--spring.profiles.active=dev'

# Run tests with coverage
./gradlew test jacocoTestReport

# Run integration tests only
./gradlew integrationTest

# Run performance tests
./gradlew performanceTest

# Code quality checks
./gradlew ktlintCheck sonarqube

# Fix code formatting
./gradlew ktlintFormat

# Security vulnerability scan
./gradlew securityScan

# Build production JAR
./gradlew bootJar -x test

# Build native image
./gradlew nativeCompile

# Database migration
./gradlew flywayMigrate

# Clean migration (DEV ONLY)
./gradlew flywayClean flywayMigrate

# Generate API documentation
./gradlew generateApiDocs

# Run all quality checks
./gradlew check jacocoTestCoverageVerification
```

### Docker Commands
```bash
# Start full development environment
docker-compose up -d

# Start only database services
docker-compose up -d postgres redis rabbitmq

# Build production image
docker build -f docker/app/Dockerfile -t {{project_name}}:latest .

# Run production container
docker run -p 8080:8080 {{project_name}}:latest

# View application logs
docker-compose logs -f app

# Stop all services
docker-compose down

# Clean volumes (WARNING: Data loss)
docker-compose down -v
```

### Database Commands
```bash
# Connect to PostgreSQL
docker-compose exec postgres psql -U postgres -d {{database_name}}

# Backup database
docker-compose exec postgres pg_dump -U postgres {{database_name}} > backup.sql

# Restore database
docker-compose exec -T postgres psql -U postgres {{database_name}} < backup.sql

# Run migration info
./gradlew flywayInfo

# Validate migrations
./gradlew flywayValidate

# Repair migration checksums
./gradlew flywayRepair
```

## VALIDATION_SCRIPTS

```kotlin
// Project structure validation
val requiredDirectories = listOf(
    "src/main/kotlin/${basePackage.replace('.', '/')}/domain/entity",
    "src/main/kotlin/${basePackage.replace('.', '/')}/domain/repository",
    "src/main/kotlin/${basePackage.replace('.', '/')}/domain/service",
    "src/main/kotlin/${basePackage.replace('.', '/')}/api/controller",
    "src/main/kotlin/${basePackage.replace('.', '/')}/api/dto",
    "src/main/kotlin/${basePackage.replace('.', '/')}/infrastructure/security",
    "src/main/kotlin/${basePackage.replace('.', '/')}/infrastructure/exception",
    "src/main/kotlin/${basePackage.replace('.', '/')}/config",
    "src/main/resources/db/migration",
    "src/test/kotlin/${basePackage.replace('.', '/')}/integration"
)

// Required dependencies validation
val requiredDependencies = listOf(
    "spring-boot-starter-web",
    "spring-boot-starter-data-jpa",
    "spring-boot-starter-security",
    "spring-boot-starter-validation",
    "postgresql",
    "flyway-core",
    "kotlin-reflect",
    "jackson-module-kotlin",
    "jjwt-api",
    "springdoc-openapi-starter-webmvc-ui"
)

// Security configuration validation
val requiredSecurityFeatures = listOf(
    "@EnableWebSecurity",
    "@EnableMethodSecurity",
    "SecurityFilterChain",
    "UserDetailsService",
    "PasswordEncoder",
    "JwtAuthenticationFilter",
    "JwtTokenProvider"
)

// Database migration validation
fun validateMigrations(): Boolean {
    val migrationDir = File("src/main/resources/db/migration")
    val migrations = migrationDir.listFiles { file -> 
        file.name.matches(Regex("V\\d+__.*\\.sql"))
    }
    return migrations?.isNotEmpty() == true && 
           migrations.sortedBy { it.name }.first().name.startsWith("V1__")
}

// Application properties validation
val requiredProperties = listOf(
    "spring.datasource.url",
    "spring.datasource.username", 
    "spring.datasource.password",
    "spring.jpa.hibernate.ddl-auto",
    "spring.flyway.enabled",
    "app.jwt.secret",
    "app.jwt.expiration",
    "spring.profiles.active",
    "logging.level.com.{{company}}.{{project}}"
)

// REST API validation
val requiredEndpoints = listOf(
    "/api/v1/auth/login",
    "/api/v1/auth/refresh",
    "/api/v1/auth/logout",
    "/api/v1/users",
    "/api/v1/users/{id}",
    "/api/v1/organizations",
    "/actuator/health",
    "/actuator/metrics",
    "/v3/api-docs"
)

// Test coverage validation
fun validateTestCoverage(): Boolean {
    val jacocoReport = File("build/reports/jacoco/test/jacocoTestReport.xml")
    if (!jacocoReport.exists()) return false
    
    // Parse XML and check coverage percentage
    // Implementation would parse XML and verify > 90% coverage
    return true
}

// Docker configuration validation
val requiredDockerFiles = listOf(
    "Dockerfile",
    "docker-compose.yml",
    ".dockerignore"
)

// Kubernetes configuration validation
val requiredK8sFiles = listOf(
    "k8s/deployment.yaml",
    "k8s/service.yaml",
    "k8s/configmap.yaml",
    "k8s/secret.yaml"
)
```

## PROJECT_VARIABLES
- **PROJECT_NAME**: {{project_name}}
- **BASE_PACKAGE**: {{base_package}}
- **DATABASE_NAME**: {{database_name}}
- **COMPANY_NAME**: {{company_name}}
- **APPLICATION_TITLE**: {{application_title}}
- **JWT_SECRET**: {{jwt_secret}}
- **ADMIN_EMAIL**: {{admin_email}}
- **ADMIN_PASSWORD**: {{admin_password}}
- **DEPLOYMENT_ENV**: {{deployment_environment}}
- **DOMAIN_NAME**: {{domain_name}}
- **SSL_ENABLED**: {{ssl_enabled}}

## CONDITIONAL_REQUIREMENTS

### IF deployment_environment == "kubernetes"
```yaml
# Kubernetes deployment configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{project_name}}
  namespace: {{project_name}}-ns
  labels:
    app: {{project_name}}
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: {{project_name}}
  template:
    metadata:
      labels:
        app: {{project_name}}
        version: v1
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/actuator/prometheus"
    spec:
      serviceAccountName: {{project_name}}-sa
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
      containers:
      - name: {{project_name}}
        image: {{project_name}}:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          name: http
          protocol: TCP
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        - name: SPRING_DATASOURCE_URL
          valueFrom:
            secretKeyRef:
              name: {{project_name}}-secret
              key: database-url
        - name: SPRING_DATASOURCE_USERNAME
          valueFrom:
            secretKeyRef:
              name: {{project_name}}-secret
              key: database-username
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{project_name}}-secret
              key: database-password
        - name: APP_JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: {{project_name}}-secret
              key: jwt-secret
        - name: SPRING_REDIS_URL
          valueFrom:
            secretKeyRef:
              name: {{project_name}}-secret
              key: redis-url
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        startupProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 30
        volumeMounts:
        - name: logs
          mountPath: /app/logs
        - name: config
          mountPath: /app/config
          readOnly: true
      volumes:
      - name: logs
        emptyDir: {}
      - name: config
        configMap:
          name: {{project_name}}-config
---
apiVersion: v1
kind: Service
metadata:
  name: {{project_name}}-service
  namespace: {{project_name}}-ns
  labels:
    app: {{project_name}}
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  selector:
    app: {{project_name}}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{project_name}}-ingress
  namespace: {{project_name}}-ns
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-window: "1m"
spec:
  tls:
  - hosts:
    - api.{{domain_name}}
    secretName: {{project_name}}-tls
  rules:
  - host: api.{{domain_name}}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {{project_name}}-service
            port:
              number: 80
```

### IF messaging_enabled == "true"
```kotlin
// RabbitMQ configuration
@Configuration
@EnableRabbit
@ConditionalOnProperty(prefix = "app.messaging", name = ["enabled"], havingValue = "true")
class MessagingConfig {
    
    companion object {
        const val USER_EVENTS_EXCHANGE = "user.events"
        const val EMAIL_QUEUE = "email.notifications"
        const val AUDIT_QUEUE = "audit.logs"
    }
    
    @Bean
    fun topicExchange(): TopicExchange {
        return TopicExchange(USER_EVENTS_EXCHANGE, true, false)
    }
    
    @Bean
    fun emailQueue(): Queue {
        return QueueBuilder.durable(EMAIL_QUEUE)
            .withArgument("x-dead-letter-exchange", "$USER_EVENTS_EXCHANGE.dlx")
            .build()
    }
    
    @Bean
    fun auditQueue(): Queue {
        return QueueBuilder.durable(AUDIT_QUEUE)
            .withArgument("x-message-ttl", 604800000) // 7 days
            .build()
    }
    
    @Bean
    fun emailBinding(): Binding {
        return BindingBuilder.bind(emailQueue())
            .to(topicExchange())
            .with("user.email.*")
    }
    
    @Bean
    fun auditBinding(): Binding {
        return BindingBuilder.bind(auditQueue())
            .to(topicExchange())
            .with("user.audit.*")
    }
    
    @Bean
    fun rabbitTemplate(connectionFactory: ConnectionFactory): RabbitTemplate {
        val template = RabbitTemplate(connectionFactory)
        template.messageConverter = Jackson2JsonMessageConverter()
        template.setConfirmCallback { correlationData, ack, cause ->
            if (!ack) {
                logger.error("Message failed to deliver: $cause")
            }
        }
        return template
    }
    
    private val logger = LoggerFactory.getLogger(MessagingConfig::class.java)
}

// Message events
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "type")
@JsonSubTypes(
    JsonSubTypes.Type(value = UserCreatedEvent::class, name = "user.created"),
    JsonSubTypes.Type(value = UserUpdatedEvent::class, name = "user.updated"),
    JsonSubTypes.Type(value = UserDeletedEvent::class, name = "user.deleted")
)
sealed class UserEvent(
    val eventId: String = UUID.randomUUID().toString(),
    val timestamp: Instant = Instant.now(),
    val userId: Long
)

data class UserCreatedEvent(
    val id: Long,
    val email: String,
    val firstName: String,
    val lastName: String
) : UserEvent(userId = id)

data class UserUpdatedEvent(
    val id: Long,
    val changes: Map<String, Any>
) : UserEvent(userId = id)

data class UserDeletedEvent(
    val id: Long,
    val email: String
) : UserEvent(userId = id)
```

### IF caching_enabled == "redis"
```kotlin
// Redis caching configuration
@Configuration
@EnableCaching
@ConditionalOnProperty(prefix = "spring.cache", name = ["type"], havingValue = "redis")
class RedisCacheConfig {
    
    @Bean
    fun cacheManager(redisConnectionFactory: RedisConnectionFactory): CacheManager {
        val builder = RedisCacheManager.builder(redisConnectionFactory)
            .cacheDefaults(cacheConfiguration(Duration.ofMinutes(10)))
            .withCacheConfiguration("users", cacheConfiguration(Duration.ofMinutes(30)))
            .withCacheConfiguration("organizations", cacheConfiguration(Duration.ofMinutes(60)))
            .withCacheConfiguration("permissions", cacheConfiguration(Duration.ofHours(1)))
            .transactionAware()
        
        return builder.build()
    }
    
    private fun cacheConfiguration(ttl: Duration): RedisCacheConfiguration {
        return RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(ttl)
            .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(Jackson2JsonRedisSerializer(Any::class.java)))
            .disableCachingNullValues()
    }
    
    @Bean
    fun redisTemplate(redisConnectionFactory: RedisConnectionFactory): RedisTemplate<String, Any> {
        val template = RedisTemplate<String, Any>()
        template.connectionFactory = redisConnectionFactory
        template.keySerializer = StringRedisSerializer()
        template.valueSerializer = Jackson2JsonRedisSerializer(Any::class.java)
        template.hashKeySerializer = StringRedisSerializer()
        template.hashValueSerializer = Jackson2JsonRedisSerializer(Any::class.java)
        template.afterPropertiesSet()
        return template
    }
}

// Cache service
@Service
class CacheService(
    private val redisTemplate: RedisTemplate<String, Any>,
    private val cacheManager: CacheManager
) {
    
    fun evictUserCache(userId: Long) {
        cacheManager.getCache("users")?.evict("user:$userId")
        redisTemplate.delete("user:sessions:$userId")
    }
    
    fun evictAllUserCaches() {
        cacheManager.getCache("users")?.clear()
    }
    
    fun storeUserSession(userId: Long, sessionId: String, ttl: Duration) {
        redisTemplate.opsForValue().set(
            "user:session:$sessionId", 
            userId, 
            ttl
        )
    }
    
    fun getUserFromSession(sessionId: String): Long? {
        return redisTemplate.opsForValue().get("user:session:$sessionId") as? Long
    }
    
    fun invalidateSession(sessionId: String) {
        redisTemplate.delete("user:session:$sessionId")
    }
}
```

### IF file_storage == "s3"
```kotlin
// AWS S3 file storage configuration
@Configuration
@ConditionalOnProperty(prefix = "app.storage", name = ["type"], havingValue = "s3")
class S3Config {
    
    @Bean
    @ConfigurationProperties(prefix = "app.storage.s3")
    fun s3Properties(): S3Properties = S3Properties()
    
    @Bean
    fun s3Client(s3Properties: S3Properties): S3Client {
        return S3Client.builder()
            .region(Region.of(s3Properties.region))
            .credentialsProvider(
                if (s3Properties.accessKey.isNotBlank()) {
                    StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(s3Properties.accessKey, s3Properties.secretKey)
                    )
                } else {
                    DefaultCredentialsProvider.create()
                }
            )
            .build()
    }
}

data class S3Properties(
    var bucketName: String = "",
    var region: String = "us-east-1",
    var accessKey: String = "",
    var secretKey: String = "",
    var urlExpiration: Duration = Duration.ofHours(1)
)

@Service
@ConditionalOnProperty(prefix = "app.storage", name = ["type"], havingValue = "s3")
class S3FileStorageService(
    private val s3Client: S3Client,
    private val s3Properties: S3Properties
) : FileStorageService {
    
    override fun store(file: MultipartFile, directory: String): String {
        val key = "$directory/${UUID.randomUUID()}-${file.originalFilename}"
        
        val request = PutObjectRequest.builder()
            .bucket(s3Properties.bucketName)
            .key(key)
            .contentType(file.contentType)
            .contentLength(file.size)
            .build()
        
        s3Client.putObject(request, RequestBody.fromInputStream(file.inputStream, file.size))
        return key
    }
    
    override fun generateDownloadUrl(key: String): String {
        val request = GetObjectRequest.builder()
            .bucket(s3Properties.bucketName)
            .key(key)
            .build()
        
        val presigner = S3Presigner.create()
        val presignRequest = GetObjectPresignRequest.builder()
            .signatureDuration(s3Properties.urlExpiration)
            .getObjectRequest(request)
            .build()
        
        return presigner.presignGetObject(presignRequest).url().toString()
    }
    
    override fun delete(key: String) {
        val request = DeleteObjectRequest.builder()
            .bucket(s3Properties.bucketName)
            .key(key)
            .build()
        
        s3Client.deleteObject(request)
    }
}
```

## INCLUDE_MODULES
- @include: jwt-authentication.md
- @include: audit-logging.md
- @include: email-templates.md
- @include: caching-strategies.md
- @include: monitoring-metrics.md
- @include: rate-limiting-throttling.md
- @include: file-upload-handling.md
- @include: data-export-functionality.md
- @include: security-headers.md
- @include: database-performance.md