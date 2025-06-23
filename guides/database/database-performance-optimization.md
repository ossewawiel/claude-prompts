# Database Performance Optimization - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Index Optimization
```sql
-- PostgreSQL Index Strategies
-- B-tree indexes (default) - for equality and range queries
CREATE INDEX idx_users_email ON users(email_address);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Partial indexes - for filtered queries
CREATE INDEX idx_active_users ON users(email_address) WHERE is_active = true;
CREATE INDEX idx_pending_orders ON orders(created_at) WHERE status = 'PENDING';

-- Composite indexes - for multi-column queries
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_users_name_active ON users(last_name, first_name) WHERE is_active = true;

-- GIN indexes - for JSON and array queries (PostgreSQL)
CREATE INDEX idx_users_preferences ON users USING GIN(preferences);
CREATE INDEX idx_products_tags ON products USING GIN(tags);

-- MariaDB Index Strategies
-- Standard indexes
CREATE INDEX idx_users_email ON users(email_address);
CREATE INDEX idx_orders_compound ON orders(user_id, status, created_at);

-- JSON indexes (MariaDB 10.3+)
ALTER TABLE users ADD INDEX idx_preferences_theme 
    ((CAST(JSON_EXTRACT(preferences, '$.theme') AS CHAR(50))));

-- Full-text indexes
ALTER TABLE articles ADD FULLTEXT(title, content);
```

### Query Optimization
```kotlin
// Repository with optimized queries
@Repository
interface UserRepository : JpaRepository<User, Long> {
    
    // Use indexes effectively
    @Query("SELECT u FROM User u WHERE u.emailAddress = :email AND u.isActive = true")
    fun findActiveUserByEmail(@Param("email") email: String): Optional<User>
    
    // Avoid N+1 queries with JOIN FETCH
    @Query("SELECT u FROM User u JOIN FETCH u.orders WHERE u.id = :id")
    fun findUserWithOrders(@Param("id") id: Long): Optional<User>
    
    // Use pagination for large result sets
    @Query("SELECT u FROM User u WHERE u.status = :status ORDER BY u.createdAt DESC")
    fun findByStatusPaginated(
        @Param("status") status: UserStatus, 
        pageable: Pageable
    ): Page<User>
    
    // Projection for performance
    @Query("SELECT u.id, u.firstName, u.lastName FROM User u WHERE u.isActive = true")
    fun findActiveUserSummaries(): List<UserSummary>
    
    // Native queries for complex operations
    @Query(
        value = """
            SELECT u.*, COUNT(o.id) as order_count,
                   COALESCE(SUM(o.total_amount), 0) as total_spent
            FROM users u 
            LEFT JOIN orders o ON u.id = o.user_id 
            WHERE u.created_at >= :since
            GROUP BY u.id 
            HAVING COUNT(o.id) > :minOrders
            ORDER BY total_spent DESC
            LIMIT :limit
        """,
        nativeQuery = true
    )
    fun findTopCustomers(
        @Param("since") since: LocalDateTime,
        @Param("minOrders") minOrders: Int,
        @Param("limit") limit: Int
    ): List<TopCustomerProjection>
}

// Projection interface for performance
interface UserSummary {
    val id: Long
    val firstName: String
    val lastName: String
}

interface TopCustomerProjection {
    val id: Long
    val firstName: String
    val lastName: String
    val orderCount: Int
    val totalSpent: BigDecimal
}
```

## IMPLEMENTATION STRATEGY

### Connection Pool Tuning
```kotlin
@Configuration
class DatabasePerformanceConfig {
    
    @Bean
    @ConfigurationProperties("spring.datasource.hikari")
    fun hikariConfig(): HikariConfig {
        return HikariConfig().apply {
            // Pool sizing based on CPU cores and expected load
            val cpuCores = Runtime.getRuntime().availableProcessors()
            maximumPoolSize = cpuCores * 2 + 1  // Formula: cores * 2 + 1
            minimumIdle = cpuCores
            
            // Connection timeouts
            connectionTimeout = 20000     // 20 seconds
            idleTimeout = 600000         // 10 minutes
            maxLifetime = 1800000        // 30 minutes
            leakDetectionThreshold = 60000 // 1 minute
            
            // Performance optimizations
            addDataSourceProperty("cachePrepStmts", "true")
            addDataSourceProperty("prepStmtCacheSize", "250")
            addDataSourceProperty("prepStmtCacheSqlLimit", "2048")
            addDataSourceProperty("useServerPrepStmts", "true")
            addDataSourceProperty("rewriteBatchedStatements", "true")
            addDataSourceProperty("cacheResultSetMetadata", "true")
            addDataSourceProperty("cacheServerConfiguration", "true")
            addDataSourceProperty("maintainTimeStats", "false")
        }
    }
}
```

### JPA Performance Configuration
```kotlin
@Configuration
@EnableJpaRepositories
class JpaPerformanceConfig {
    
    @Bean
    fun entityManagerFactory(dataSource: DataSource): LocalContainerEntityManagerFactoryBean {
        return LocalContainerEntityManagerFactoryBean().apply {
            setDataSource(dataSource)
            setPackagesToScan("com.company.domain")
            
            val properties = Properties().apply {
                // Hibernate performance settings
                setProperty("hibernate.dialect", "org.hibernate.dialect.PostgreSQLDialect")
                setProperty("hibernate.jdbc.batch_size", "25")
                setProperty("hibernate.jdbc.fetch_size", "50")
                setProperty("hibernate.order_inserts", "true")
                setProperty("hibernate.order_updates", "true")
                setProperty("hibernate.batch_versioned_data", "true")
                
                // Second-level cache (if using)
                setProperty("hibernate.cache.use_second_level_cache", "true")
                setProperty("hibernate.cache.use_query_cache", "true")
                setProperty("hibernate.cache.region.factory_class", 
                    "org.hibernate.cache.jcache.JCacheRegionFactory")
                
                // SQL logging (disable in production)
                setProperty("hibernate.show_sql", "false")
                setProperty("hibernate.format_sql", "false")
                setProperty("hibernate.use_sql_comments", "false")
                
                // JDBC settings
                setProperty("hibernate.jdbc.time_zone", "UTC")
                setProperty("hibernate.temp.use_jdbc_metadata_defaults", "false")
            }
            
            setJpaProperties(properties)
            jpaVendorAdapter = HibernateJpaVendorAdapter()
        }
    }
}
```

### Batch Operations
```kotlin
@Service
@Transactional
class UserBatchService(
    private val entityManager: EntityManager,
    private val userRepository: UserRepository
) {
    
    fun createUsersInBatch(users: List<UserCreateDto>): List<User> {
        val batchSize = 25
        val savedUsers = mutableListOf<User>()
        
        users.chunked(batchSize).forEach { batch ->
            val entities = batch.map { dto ->
                User().apply {
                    firstName = dto.firstName
                    lastName = dto.lastName
                    emailAddress = dto.emailAddress
                }
            }
            
            savedUsers.addAll(userRepository.saveAll(entities))
            entityManager.flush()
            entityManager.clear() // Clear persistence context
        }
        
        return savedUsers
    }
    
    fun updateUsersInBatch(updates: List<UserUpdateDto>) {
        val batchSize = 25
        
        updates.chunked(batchSize).forEach { batch ->
            batch.forEach { update ->
                val user = userRepository.findById(update.id)
                    .orElseThrow { UserNotFoundException("User ${update.id} not found") }
                
                user.firstName = update.firstName
                user.lastName = update.lastName
                // entityManager.merge() is called automatically by JPA
            }
            
            entityManager.flush()
            entityManager.clear()
        }
    }
    
    @Modifying
    @Query("UPDATE User u SET u.isActive = false WHERE u.lastLoginAt < :cutoffDate")
    fun deactivateInactiveUsers(@Param("cutoffDate") cutoffDate: LocalDateTime): Int
}
```

### Caching Strategies
```kotlin
@Configuration
@EnableCaching
class CacheConfig {
    
    @Bean
    fun cacheManager(): CacheManager {
        return ConcurrentMapCacheManager().apply {
            setCacheNames(listOf("users", "userProfiles", "lookupData"))
        }
    }
}

@Service
@Transactional(readOnly = true)
class UserCacheService(private val userRepository: UserRepository) {
    
    @Cacheable(value = ["users"], key = "#id")
    fun findById(id: Long): User? {
        return userRepository.findById(id).orElse(null)
    }
    
    @Cacheable(value = ["users"], key = "#email")
    fun findByEmail(email: String): User? {
        return userRepository.findByEmailAddress(email).orElse(null)
    }
    
    @CacheEvict(value = ["users"], key = "#user.id")
    fun evictUser(user: User) {
        // Cache eviction only
    }
    
    @CacheEvict(value = ["users"], allEntries = true)
    fun evictAllUsers() {
        // Clear entire cache
    }
    
    // Cache lookup data that rarely changes
    @Cacheable(value = ["lookupData"], key = "'userStatuses'")
    fun getAllUserStatuses(): List<UserStatus> {
        return UserStatus.values().toList()
    }
}
```

### Database Monitoring
```kotlin
@Component
class DatabaseMonitor {
    
    @Autowired
    private lateinit var jdbcTemplate: JdbcTemplate
    
    @EventListener
    @Async
    fun handleSlowQuery(event: SlowQueryEvent) {
        log.warn("Slow query detected: ${event.sql} took ${event.executionTime}ms")
        
        if (event.executionTime > 5000) { // 5 seconds
            // Alert or take action for very slow queries
            notifySlowQuery(event)
        }
    }
    
    @Scheduled(fixedRate = 60000) // Every minute
    fun monitorConnectionPool() {
        val activeConnections = getActiveConnectionCount()
        val maxConnections = getMaxConnectionCount()
        
        val utilizationPercent = (activeConnections.toDouble() / maxConnections) * 100
        
        if (utilizationPercent > 80) {
            log.warn("High connection pool utilization: ${utilizationPercent}%")
        }
    }
    
    private fun getActiveConnectionCount(): Int {
        return jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.processlist WHERE command != 'Sleep'",
            Int::class.java
        ) ?: 0
    }
    
    private fun getMaxConnectionCount(): Int {
        return jdbcTemplate.queryForObject(
            "SELECT @@max_connections",
            Int::class.java
        ) ?: 0
    }
    
    fun getSlowQueries(): List<SlowQueryInfo> {
        // PostgreSQL
        return jdbcTemplate.query(
            """
            SELECT query, mean_time, calls, total_time
            FROM pg_stat_statements 
            WHERE mean_time > 1000 
            ORDER BY mean_time DESC 
            LIMIT 10
            """.trimIndent()
        ) { rs, _ ->
            SlowQueryInfo(
                query = rs.getString("query"),
                meanTime = rs.getDouble("mean_time"),
                calls = rs.getLong("calls"),
                totalTime = rs.getDouble("total_time")
            )
        }
    }
}

data class SlowQueryInfo(
    val query: String,
    val meanTime: Double,
    val calls: Long,
    val totalTime: Double
)
```

### Performance Testing
```kotlin
@SpringBootTest
class DatabasePerformanceTest {
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Test
    fun `should handle large batch operations efficiently`() {
        val startTime = System.currentTimeMillis()
        
        // Create 1000 test users
        val users = (1..1000).map { i ->
            User().apply {
                firstName = "User$i"
                lastName = "Test$i"
                emailAddress = "user$i@test.com"
            }
        }
        
        userRepository.saveAll(users)
        
        val endTime = System.currentTimeMillis()
        val executionTime = endTime - startTime
        
        // Should complete within reasonable time
        assertThat(executionTime).isLessThan(5000) // 5 seconds
    }
    
    @Test
    fun `should execute queries within performance thresholds`() {
        // Test specific query performance
        val startTime = System.nanoTime()
        
        val users = userRepository.findByStatusPaginated(
            UserStatus.ACTIVE, 
            PageRequest.of(0, 100)
        )
        
        val executionTimeMs = (System.nanoTime() - startTime) / 1_000_000
        
        assertThat(executionTimeMs).isLessThan(500) // 500ms
        assertThat(users.content).isNotEmpty()
    }
}
```

## CLAUDE_CODE_COMMANDS

```bash
# PostgreSQL performance analysis
psql -d database_name -c "SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;"

# MariaDB performance analysis
mysql -u username -p -e "SELECT * FROM performance_schema.events_statements_summary_by_digest ORDER BY avg_timer_wait DESC LIMIT 10;"

# Explain query plans
EXPLAIN ANALYZE SELECT * FROM users WHERE email_address = 'test@example.com';

# Check index usage
SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0; -- PostgreSQL
SHOW INDEX FROM table_name; -- MariaDB

# Monitor connection pools
jstack <java_pid> | grep HikariPool
```

## VALIDATION_CHECKLIST
- [ ] Appropriate indexes created for query patterns
- [ ] Connection pool sized correctly for load
- [ ] Batch operations used for bulk data changes
- [ ] Query projections used to limit data transfer
- [ ] Caching implemented for frequently accessed data
- [ ] Slow query monitoring in place
- [ ] Database performance baselines established
- [ ] N+1 query patterns eliminated
- [ ] Pagination used for large result sets
- [ ] Performance tests written and passing