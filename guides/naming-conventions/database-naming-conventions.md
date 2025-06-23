# Database Naming Conventions - Claude Code Instructions

## CONTEXT
- **Project Type**: guide
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### Tables
```sql
-- Tables: snake_case, plural nouns
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE user_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    bio TEXT,
    avatar_url VARCHAR(500)
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id),
    product_id BIGINT REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

-- Junction tables: table1_table2 format
CREATE TABLE user_roles (
    user_id BIGINT REFERENCES users(id),
    role_id BIGINT REFERENCES roles(id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);
```

### Columns
```sql
-- Columns: snake_case, descriptive names
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_address VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

-- Boolean columns: is_ or has_ prefix
is_active BOOLEAN DEFAULT true,
is_verified BOOLEAN DEFAULT false,
has_premium_subscription BOOLEAN DEFAULT false,
can_send_notifications BOOLEAN DEFAULT true,

-- Timestamp columns: descriptive with _at suffix
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
deleted_at TIMESTAMP NULL,
last_login_at TIMESTAMP NULL,
password_reset_at TIMESTAMP NULL,
```

## IMPLEMENTATION STRATEGY

### Primary Keys and Foreign Keys
```sql
-- Primary keys: id (BIGSERIAL for PostgreSQL, BIGINT AUTO_INCREMENT for MariaDB)
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,  -- PostgreSQL
    -- id BIGINT AUTO_INCREMENT PRIMARY KEY,  -- MariaDB
    name VARCHAR(255) NOT NULL
);

-- Foreign keys: referenced_table_id format
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    shipping_address_id BIGINT REFERENCES addresses(id),
    billing_address_id BIGINT REFERENCES addresses(id),
    status VARCHAR(50) NOT NULL
);

-- Composite foreign keys: descriptive names
CREATE TABLE user_project_permissions (
    user_id BIGINT REFERENCES users(id),
    project_id BIGINT REFERENCES projects(id),
    permission_level VARCHAR(50) NOT NULL,
    granted_by BIGINT REFERENCES users(id),
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, project_id)
);
```

### Indexes
```sql
-- Indexes: idx_table_column(s) format
CREATE INDEX idx_users_email ON users(email_address);
CREATE INDEX idx_users_last_name ON users(last_name);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status_created_at ON orders(status, created_at);

-- Unique indexes: uk_table_column(s) format
CREATE UNIQUE INDEX uk_users_email ON users(email_address);
CREATE UNIQUE INDEX uk_user_profiles_user_id ON user_profiles(user_id);

-- Partial indexes: descriptive names
CREATE INDEX idx_active_users_email ON users(email_address) WHERE is_active = true;
CREATE INDEX idx_pending_orders ON orders(created_at) WHERE status = 'PENDING';
```

### Constraints
```sql
-- Primary key constraints: pk_table format
CONSTRAINT pk_users PRIMARY KEY (id),
CONSTRAINT pk_orders PRIMARY KEY (id),

-- Foreign key constraints: fk_table_referenced_table format
CONSTRAINT fk_orders_users FOREIGN KEY (user_id) REFERENCES users(id),
CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id) REFERENCES orders(id),
CONSTRAINT fk_order_items_products FOREIGN KEY (product_id) REFERENCES products(id),

-- Check constraints: ck_table_column_condition format
CONSTRAINT ck_users_email_format CHECK (email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
CONSTRAINT ck_orders_quantity_positive CHECK (quantity > 0),
CONSTRAINT ck_users_age_valid CHECK (date_of_birth IS NULL OR date_of_birth < CURRENT_DATE),

-- Unique constraints: uk_table_column(s) format
CONSTRAINT uk_users_email UNIQUE (email_address),
CONSTRAINT uk_products_sku UNIQUE (sku_code),
```

### Views
```sql
-- Views: v_ prefix, descriptive names
CREATE VIEW v_active_users AS
SELECT id, first_name, last_name, email_address, created_at
FROM users
WHERE is_active = true AND deleted_at IS NULL;

CREATE VIEW v_order_summary AS
SELECT 
    o.id,
    o.order_number,
    u.first_name || ' ' || u.last_name AS customer_name,
    o.total_amount,
    o.status,
    o.created_at
FROM orders o
JOIN users u ON o.user_id = u.id;

CREATE VIEW v_monthly_sales AS
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_sales
FROM orders
WHERE status = 'COMPLETED'
GROUP BY DATE_TRUNC('month', created_at);
```

### Stored Procedures and Functions
```sql
-- Functions: snake_case with descriptive names
CREATE OR REPLACE FUNCTION calculate_order_total(order_id_param BIGINT)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    total_amount DECIMAL(10,2);
BEGIN
    SELECT SUM(quantity * unit_price)
    INTO total_amount
    FROM order_items
    WHERE order_id = order_id_param;
    
    RETURN COALESCE(total_amount, 0);
END;
$$ LANGUAGE plpgsql;

-- Stored procedures: sp_ prefix (for systems that distinguish)
CREATE OR REPLACE PROCEDURE sp_update_user_last_login(user_id_param BIGINT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE users
    SET last_login_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = user_id_param;
END;
$$;
```

### Sequences and Triggers
```sql
-- Sequences: seq_table_column format
CREATE SEQUENCE seq_order_number_generator
    START WITH 100000
    INCREMENT BY 1
    NO MAXVALUE
    CACHE 1;

-- Triggers: trg_table_action format
CREATE OR REPLACE FUNCTION trg_users_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_before_update
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION trg_users_update_timestamp();
```

### Schema Organization
```sql
-- Schemas: descriptive, lowercase
CREATE SCHEMA user_management;
CREATE SCHEMA order_processing;
CREATE SCHEMA reporting;
CREATE SCHEMA audit_logs;

-- Table creation in schemas
CREATE TABLE user_management.users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE order_processing.orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES user_management.users(id)
);
```

## CLAUDE_CODE_COMMANDS

```bash
# PostgreSQL: Check naming conventions
psql -d database_name -c "\dt" # List tables
psql -d database_name -c "\di" # List indexes
psql -d database_name -c "\df" # List functions

# MariaDB: Check naming conventions  
mysql -u username -p -e "SHOW TABLES FROM database_name;"
mysql -u username -p -e "SHOW INDEX FROM table_name;"

# Generate schema documentation
pg_dump --schema-only database_name > schema.sql
```

## VALIDATION_CHECKLIST
- [ ] All tables use snake_case and plural nouns
- [ ] All columns use snake_case
- [ ] Primary keys named 'id'
- [ ] Foreign keys follow referenced_table_id format
- [ ] Boolean columns use is_/has_/can_ prefix
- [ ] Timestamp columns use _at suffix
- [ ] Indexes follow idx_table_column format
- [ ] Constraints follow naming patterns
- [ ] Views use v_ prefix
- [ ] No reserved words used as names