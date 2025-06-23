# CORBA Kotlin Spring Boot Integration Pattern - Claude Code Instructions

## CONTEXT
**Project Type**: pattern
**Complexity**: complex
**Timeline**: production
**Architecture**: CORBA backend integration with Vaadin session management
**Last Updated**: 2025-06-18
**Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Technology Stack
- **Spring Boot**: 3.5.0+
- **Kotlin**: 2.1.0+
- **CORBA Library**: optimus-rt 1.8-SNAPSHOT
- **IDL Generation**: optimus-idl 19.800+
- **Session Management**: Vaadin Session (@VaadinSessionScope)
- **Error Handling**: Result<T> pattern with sealed exceptions

### Project Structure
```
src/main/kotlin/{{base_package}}/
├── corba/
│   ├── BaseCorbaRepository.kt          # Common CORBA patterns
│   ├── CorbaUserSession.kt            # Session-scoped CORBA management
│   ├── OptimusUserEnvironment.kt      # Environment wrapper extensions
│   └── exception/
│       └── CorbaException.kt          # CORBA-specific exceptions
├── repository/
│   ├── EnvironmentRepository.kt       # System-level CORBA operations
│   └── domain/
│       ├── TaxPayerRepository.kt      # Domain-specific repositories
│       └── CustomerRepository.kt      # Business entity repositories
├── service/
│   ├── EnvironmentService.kt          # Environment management
│   └── impl/
│       ├── EnvironmentServiceImpl.kt  # Real CORBA implementation
│       └── MockEnvironmentService.kt  # Development mock
└── config/
    └── CorbaConfiguration.kt          # Profile-based CORBA config
```

### Documentation Sources
- **Optimus-RT Documentation**: Internal Optimus CORBA wrapper library
- **Spring Boot Session Scoping**: https://docs.spring.io/spring-framework/docs/current/reference/html/web.html#websocket-stomp-websocket-scope
- **Vaadin Session Management**: https://vaadin.com/docs/latest/advanced/preserving-state-on-refresh

## STRICT GUIDELINES

### CORBA Integration Patterns

#### 1. Base Repository Pattern
```kotlin
abstract class BaseCorbaRepository {
    
    @Autowired
    protected lateinit var corbaSession: CorbaUserSession
    
    protected fun <T> withCorbaEnvironment(operation: (OptimusUserEnvironment) -> T): T {
        val env = corbaSession.getEnvironment()
            ?: throw IllegalStateException("No active CORBA session")
        
        return try {
            wrapServerExceptions { operation(env) }
        } catch (e: org.omg.CORBA.SystemException) {
            throw CorbaException.ConnectionException("CORBA operation failed", e)
        }
    }
    
    protected fun <T> safeCorbaOperation(operation: (OptimusUserEnvironment) -> T): Result<T> {
        return try {
            val result = withCorbaEnvironment(operation)
            Result.success(result)
        } catch (e: Exception) {
            logger.error("CORBA operation failed", e)
            Result.failure(e)
        }
    }
    
    companion object {
        private val logger = LoggerFactory.getLogger(BaseCorbaRepository::class.java)
    }
}
```

#### 2. Session Management Pattern
```kotlin
@Service
@VaadinSessionScope
class CorbaUserSession {
    
    private var environment: OptimusUserEnvironment? = null
    private var username: String? = null
    private var database: String? = null
    
    fun createSession(username: String, password: String, database: String): Result<Unit> {
        return try {
            val env = wrapServerExceptions {
                OptimusUserEnvironment.create(hostname, username, password, database)
            }
            this.environment = env
            this.username = username
            this.database = database
            Result.success(Unit)
        } catch (e: Exception) {
            logger.error("Failed to create CORBA session", e)
            Result.failure(e)
        }
    }
    
    fun getEnvironment(): OptimusUserEnvironment? = environment
    
    @PreDestroy
    fun closeSession() {
        environment?.let { env ->
            try {
                env._release()
            } catch (e: Exception) {
                logger.warn("Error releasing CORBA environment", e)
            }
        }
        environment = null
    }
}
```

#### 3. Environment Extensions Pattern - Production Implementation
```kotlin
// Production patterns from reference codebase
// Dual function approach: getter + resource-safe wrapper

// Connect services
fun OptimusUserEnvironment.getConnectSession(): connectSession {
    return wrapServerExceptions { resolve<connectServer>("opt3cs/connect").createSession(userSession) }
}

fun <R> OptimusUserEnvironment.withConnectSession(block: (connectSession) -> R): R {
    return getConnectSession().useThenFree(block)
}

// Stock services
fun OptimusUserEnvironment.getStockSession(): stockSession {
    return wrapServerExceptions { resolve<stockServer>("opt3cs/stock").createSession(userSession) }
}

fun <R> OptimusUserEnvironment.withStockSession(block: (stockSession) -> R): R {
    return getStockSession().useThenFree(block)
}

// Purchase order services
fun OptimusUserEnvironment.getPurchaseOrderSession(): purchaseOrderSession {
    return wrapServerExceptions { resolve<purchaseOrderServer>("opt3cs/purchase").createSession(userSession) }
}

fun <R> OptimusUserEnvironment.withPurchaseOrderSession(block: (purchaseOrderSession) -> R): R {
    return getPurchaseOrderSession().useThenFree(block)
}

// Search services (different pattern - no session, direct search objects)
fun OptimusUserEnvironment.getRequisitionSearch(): requisitionSearch {
    return wrapServerExceptions { resolve<requisitionSearchSvr>("opt3cs/reqSearch").newRequisitionSearch(userSession) }
}

// Resource management extension (provided by optimus-rt.corba)
// Already available: fun <T, R> T.useThenFree(operation: (T) -> R): R where T : org.omg.CORBA.Object
```

#### 4. Exception Handling Pattern
```kotlin
sealed class CorbaException(message: String, cause: Throwable? = null) : Exception(message, cause) {
    class ConnectionException(message: String, cause: Throwable) : CorbaException(message, cause)
    class ServiceException(message: String, cause: Throwable) : CorbaException(message, cause)
    class AuthenticationException(message: String) : CorbaException(message)
    class DataException(message: String, cause: Throwable) : CorbaException(message, cause)
}
```

### Code Standards - Enhanced from Production Analysis
- **Session Scoping**: Always use @VaadinSessionScope for CORBA connections
- **Error Wrapping**: All CORBA operations must use wrapServerExceptions
- **Resource Management**: Use dual function pattern (get* + with*) with useThenFree
- **Result Pattern**: Use Result<T> for all repository operations
- **Service Resolution**: Use typed resolve<ServerType>("service/path") pattern
- **Dual Function Pattern**: Every service has both getter and resource-safe wrapper
- **Service Path Convention**: Follow "opt3cs/serviceName" or "opt4/serviceName" patterns
- **Session Creation**: Use .createSession(userSession) for session-based services
- **Search Services**: Use .newSearch(userSession) for search-based services

### Testing Requirements
- **Unit Tests**: Mock CorbaUserSession and test business logic
- **Integration Tests**: Test with mock CORBA services using profiles
- **Resource Tests**: Verify proper cleanup of CORBA connections
- **Session Tests**: Test session lifecycle and timeout handling

## IMPLEMENTATION STRATEGY

### Phase 1: Foundation Setup
- [ ] Create BaseCorbaRepository with common patterns
- [ ] Implement CorbaUserSession with @VaadinSessionScope
- [ ] Add OptimusUserEnvironment extension functions
- [ ] Create CorbaException hierarchy
- [ ] Configure profile-based CORBA vs mock services

### Phase 2: Repository Layer
- [ ] Create system-level EnvironmentRepository
- [ ] Implement domain-specific repositories extending base
- [ ] Add proper error handling and logging
- [ ] Create comprehensive unit tests with mocked sessions

### Phase 3: Service Integration
- [ ] Implement service layer using repositories
- [ ] Add business logic and validation
- [ ] Create mock service implementations for development
- [ ] Set up integration testing with TestContainers alternative

## CLAUDE_CODE_COMMANDS

### Initial Setup
```bash
# Add CORBA dependencies to build.gradle.kts
implementation("com.optimusmis:optimus-rt:1.8-SNAPSHOT")
implementation("com.optimusmis:optimus-idl:19.800")

# Create CORBA package structure
mkdir -p src/main/kotlin/{{base_package}}/corba/exception
mkdir -p src/main/kotlin/{{base_package}}/repository/domain
```

### Development Commands
```bash
# Run with mock CORBA services
./gradlew bootRun --args='--spring.profiles.active=dev,mock-corba'

# Run integration tests (requires CORBA service)
./gradlew integrationTest -Doptimus.integration.enabled=true

# Run unit tests only (no CORBA dependencies)
./gradlew unitTest
```

## VALIDATION_SCRIPTS

```kotlin
// CORBA session validation
fun validateCorbaSession(): Boolean {
    val session = CorbaUserSession()
    return try {
        session.createSession("test", "test", "test").isSuccess
    } catch (e: Exception) {
        false
    }
}

// Resource cleanup validation
fun validateResourceCleanup(): Boolean {
    val testService = mockk<TaxPayerService>()
    var released = false
    every { testService._release() } answers { released = true }
    
    testService.useThenFree { /* operation */ }
    return released
}
```

## PROJECT_VARIABLES
- **BASE_PACKAGE**: {{base_package}}
- **CORBA_HOSTNAME**: {{corba_hostname}}
- **OPTIMUS_RT_VERSION**: {{optimus_rt_version}}
- **OPTIMUS_IDL_VERSION**: {{optimus_idl_version}}

## CONDITIONAL_REQUIREMENTS

### IF deployment_environment == "development"
```yaml
# application-dev.yml
corba:
  enabled: false
  mock:
    enabled: true
    
optimus:
  server:
    hostname: localhost
    port: 2809
    mock-services: true
```

### IF deployment_environment == "production"
```yaml
# application-prod.yml
corba:
  enabled: true
  mock:
    enabled: false
    
optimus:
  server:
    hostname: ${OPTIMUS_SERVER_HOST}
    port: ${OPTIMUS_SERVER_PORT:2809}
    timeout: 30000
```

## VALIDATION_CHECKLIST
- [ ] CORBA dependencies properly configured with custom repositories
- [ ] BaseCorbaRepository implements Result<T> pattern for all operations
- [ ] CorbaUserSession properly scoped to Vaadin session
- [ ] Environment extension functions provide clean service access
- [ ] Exception hierarchy covers all CORBA failure scenarios
- [ ] Resource management ensures proper cleanup of CORBA objects
- [ ] Profile-based configuration supports both real and mock CORBA
- [ ] Integration tests validate CORBA service connectivity
- [ ] Unit tests mock CORBA dependencies effectively
- [ ] Session lifecycle properly handles creation, usage, and cleanup
- [ ] Error handling provides meaningful messages to users
- [ ] Performance acceptable for session-scoped CORBA connections

## PERFORMANCE_REQUIREMENTS
- **Session Creation**: < 2 seconds for CORBA environment setup
- **Service Resolution**: < 100ms for cached service lookup
- **Operation Timeout**: 30 seconds maximum for CORBA calls
- **Resource Cleanup**: Automatic cleanup on session end
- **Connection Pooling**: Not applicable - session-scoped connections
- **Error Recovery**: Graceful fallback to mock services in development

## SECURITY_CONSIDERATIONS
- **Authentication**: CORBA credentials managed through secure session
- **Session Security**: Proper cleanup prevents credential leakage
- **Error Information**: Avoid exposing internal CORBA details to users
- **Resource Limits**: Session timeout prevents resource exhaustion
- **Connection Security**: Use secure CORBA configuration in production

This pattern provides the foundation for integrating CORBA services with Spring Boot and Vaadin while maintaining clean architecture and proper resource management.