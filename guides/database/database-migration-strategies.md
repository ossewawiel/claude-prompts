# Database Migration Strategies - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: medium
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Flyway Configuration
```yaml
# application.yml
spring:
  flyway:
    enabled: true
    baseline-on-migrate: true
    baseline-version: 1.0.0
    locations: classpath:db/migration
    table: flyway_schema_history
    validate-on-migrate: true
    out-of-order: false
    clean-disabled: true
    sql-migration-prefix: V
    sql-migration-separator: __
    sql-migration-suffixes: .sql
```

### Migration File Naming
```bash
# Standard format: V{version}__{description}.sql
db/migration/
├── V1.0.0__Create_initial_schema.sql
├── V1.0.1__Add_user_table.sql
├── V1.0.2__Add_user_indexes.sql
├── V1.1.0__Add_order_system.sql
├── V1.1.1__Update_user_constraints.sql
├── V1.2.0__Add_audit_tables.sql
└── V2.0.0__Major_schema_refactor.sql
```

## IMPLEMENTATION STRATEGY

### Safe Migration Patterns
```sql
-- V1.0.1__Add_user_table.sql
-- Safe: Creating new tables
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_address VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V1.0.2__Add_user_indexes.sql
-- Safe: Adding indexes (non-blocking)
CREATE INDEX idx_users_email ON users(email_address);
CREATE INDEX idx_users_created_at ON users(created_at);

-- V1.0.3__Add_optional_columns.sql
-- Safe: Adding nullable columns
ALTER TABLE users ADD COLUMN phone_number VARCHAR(20);
ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

-- V1.0.4__Add_new_table_with_fk.sql
-- Safe: Adding new tables with foreign keys
CREATE TABLE user_profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(500),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Risky Migration Patterns (Avoid in Production)
```sql
-- DANGEROUS: Don't do these in production without downtime
-- ALTER TABLE users DROP COLUMN old_column;           -- Data loss
-- ALTER TABLE users MODIFY COLUMN email VARCHAR(100); -- Truncation risk
-- DROP TABLE obsolete_table;                          -- Data loss
-- ALTER TABLE users ADD COLUMN required_field NOT NULL; -- Constraint violation
```

### Multi-Step Safe Migrations
```sql
-- V1.1.0__Prepare_email_split_step1.sql
-- Step 1: Add new columns
ALTER TABLE users 
ADD COLUMN email_local VARCHAR(100),
ADD COLUMN email_domain VARCHAR(100);

-- V1.1.1__Prepare_email_split_step2.sql
-- Step 2: Populate new columns
UPDATE users 
SET 
    email_local = SUBSTRING_INDEX(email_address, '@', 1),
    email_domain = SUBSTRING_INDEX(email_address, '@', -1)
WHERE email_address IS NOT NULL;

-- V1.1.2__Prepare_email_split_step3.sql
-- Step 3: Add constraints after data is populated
ALTER TABLE users 
MODIFY COLUMN email_local VARCHAR(100) NOT NULL,
MODIFY COLUMN email_domain VARCHAR(100) NOT NULL;

CREATE UNIQUE INDEX idx_users_email_parts ON users(email_local, email_domain);

-- V1.1.3__Complete_email_split_step4.sql
-- Step 4: (Future release) Drop old column after verification
-- ALTER TABLE users DROP COLUMN email_address;
```

### Data Migrations
```sql
-- V1.2.0__Migrate_user_status_data.sql
-- Safe data migration with validation
UPDATE users 
SET status = CASE 
    WHEN is_active = TRUE THEN 'ACTIVE'
    WHEN is_active = FALSE THEN 'INACTIVE'
    ELSE 'UNKNOWN'
END
WHERE status IS NULL;

-- Validate migration
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN status IS NOT NULL THEN 1 END) as users_with_status
FROM users;

-- V1.2.1__Add_user_status_constraints.sql
-- Add constraints after data migration
ALTER TABLE users 
MODIFY COLUMN status VARCHAR(50) NOT NULL,
ADD CONSTRAINT ck_users_status_valid 
    CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED'));
```

### Environment-Specific Migrations
```sql
-- V1.3.0__Create_performance_indexes.sql
-- Conditional migrations based on environment
SET @environment = IFNULL(@environment, 'production');

-- Only create expensive indexes in production
SET @sql = IF(@environment = 'production',
    'CREATE INDEX idx_users_complex_query ON users(status, created_at, last_name)',
    'SELECT "Skipping complex index in non-production environment" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
```

### Rollback Strategies
```sql
-- V1.4.0__Add_user_preferences_table.sql
-- Include rollback instructions in comments
/*
ROLLBACK STRATEGY:
1. Remove foreign key constraints
2. Drop the user_preferences table
3. Update application to handle missing preferences gracefully

ROLLBACK SQL:
DROP TABLE IF EXISTS user_preferences;
*/

CREATE TABLE user_preferences (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    preference_key VARCHAR(100) NOT NULL,
    preference_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_preferences (user_id, preference_key)
);
```

### Testing Migrations
```kotlin
// Migration Test
@SpringBootTest
@TestPropertySource(properties = ["spring.flyway.clean-disabled=false"])
class DatabaseMigrationTest {
    
    @Autowired
    private lateinit var flyway: Flyway
    
    @Autowired
    private lateinit var jdbcTemplate: JdbcTemplate
    
    @Test
    fun `should apply all migrations successfully`() {
        // Clean and migrate
        flyway.clean()
        val migrateResult = flyway.migrate()
        
        assertThat(migrateResult.migrationsExecuted).isGreaterThan(0)
        assertThat(migrateResult.success).isTrue()
    }
    
    @Test
    fun `should validate current schema state`() {
        // Validate that expected tables exist
        val tableCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE()",
            Int::class.java
        )
        
        assertThat(tableCount).isGreaterThan(0)
        
        // Validate specific table structure
        val userTableExists = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'users'",
            Int::class.java
        )
        
        assertThat(userTableExists).isEqualTo(1)
    }
    
    @Test
    fun `should handle migration from baseline`() {
        // Test migration from specific version
        flyway.clean()
        flyway.baseline()
        
        val info = flyway.info()
        val pendingMigrations = info.pending()
        
        assertThat(pendingMigrations).isNotEmpty()
        
        flyway.migrate()
        assertThat(flyway.info().pending()).isEmpty()
    }
}
```

### Production Migration Checklist
```kotlin
// Pre-Migration Validation
@Component
class MigrationValidator {
    
    @Autowired
    private lateinit var jdbcTemplate: JdbcTemplate
    
    fun validateBeforeMigration(): MigrationValidationResult {
        val results = mutableListOf<String>()
        
        // Check disk space
        val freeSpace = checkDiskSpace()
        if (freeSpace < 1000) { // Less than 1GB
            results.add("WARNING: Low disk space: ${freeSpace}MB")
        }
        
        // Check active connections
        val activeConnections = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM information_schema.processlist WHERE command != 'Sleep'",
            Int::class.java
        ) ?: 0
        
        if (activeConnections > 50) {
            results.add("WARNING: High number of active connections: $activeConnections")
        }
        
        // Check table sizes
        val largeTables = jdbcTemplate.queryForList(
            """
            SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb
            FROM information_schema.tables 
            WHERE table_schema = DATABASE() 
            AND ((data_length + index_length) / 1024 / 1024) > 1000
            ORDER BY size_mb DESC
            """.trimIndent()
        )
        
        if (largeTables.isNotEmpty()) {
            results.add("INFO: Large tables found: ${largeTables.size}")
        }
        
        return MigrationValidationResult(
            isValid = results.none { it.startsWith("ERROR") },
            warnings = results
        )
    }
    
    private fun checkDiskSpace(): Long {
        // Implementation to check available disk space
        return File("/").usableSpace / 1024 / 1024 // MB
    }
}

data class MigrationValidationResult(
    val isValid: Boolean,
    val warnings: List<String>
)
```

## CLAUDE_CODE_COMMANDS

```bash
# Validate migrations without applying
mvn flyway:validate

# Get migration info
mvn flyway:info

# Apply migrations
mvn flyway:migrate

# Repair corrupted migration history
mvn flyway:repair

# Baseline existing database
mvn flyway:baseline -Dflyway.baselineVersion=1.0.0

# Clean database (DANGEROUS - only for development)
mvn flyway:clean

# Test migrations in Docker
docker run --rm -v $(pwd)/src/main/resources/db/migration:/flyway/sql flyway/flyway:latest migrate
```

## VALIDATION_CHECKLIST
- [ ] Migration files follow naming convention
- [ ] Each migration is backwards compatible
- [ ] Large data migrations are split into steps
- [ ] Rollback strategy documented
- [ ] Migrations tested in staging environment
- [ ] Database backup taken before production migration
- [ ] Migration performance impact assessed
- [ ] Constraints added after data population
- [ ] Environment-specific logic handled
- [ ] Migration validation tests written