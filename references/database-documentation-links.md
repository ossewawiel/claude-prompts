# Database Documentation Links - Claude Code Instructions

## CONTEXT
- **Project Type**: reference
- **Complexity**: simple
- **Last Updated**: 2025-06-19
- **Template Version**: 1.0.0

## MANDATORY REQUIREMENTS

### PostgreSQL
- **Official Documentation**: https://www.postgresql.org/docs/
- **PostgreSQL 15 Manual**: https://www.postgresql.org/docs/15/
- **PostgreSQL Tutorial**: https://www.postgresql.org/docs/current/tutorial.html
- **SQL Commands Reference**: https://www.postgresql.org/docs/current/sql-commands.html
- **Functions and Operators**: https://www.postgresql.org/docs/current/functions.html
- **Administration Guide**: https://www.postgresql.org/docs/current/admin.html

### MariaDB
- **MariaDB Documentation**: https://mariadb.org/documentation/
- **MariaDB Knowledge Base**: https://mariadb.com/kb/en/
- **MariaDB Server Documentation**: https://mariadb.com/kb/en/mariadb-server/
- **SQL Statements**: https://mariadb.com/kb/en/sql-statements/
- **Built-in Functions**: https://mariadb.com/kb/en/built-in-functions/
- **System Variables**: https://mariadb.com/kb/en/server-system-variables/

## IMPLEMENTATION STRATEGY

### SQL Standards and References
- **SQL Standard**: https://www.iso.org/standard/63555.html
- **SQL Tutorial**: https://www.w3schools.com/sql/
- **SQL Reference**: https://www.sqlitetutorial.net/
- **Advanced SQL**: https://modern-sql.com/
- **SQL Performance**: https://use-the-index-luke.com/

### PostgreSQL Specific Features
- **JSONB Support**: https://www.postgresql.org/docs/current/datatype-json.html
- **Full Text Search**: https://www.postgresql.org/docs/current/textsearch.html
- **Extensions**: https://www.postgresql.org/docs/current/extend.html
- **Stored Procedures**: https://www.postgresql.org/docs/current/plpgsql.html
- **Triggers**: https://www.postgresql.org/docs/current/triggers.html
- **Views**: https://www.postgresql.org/docs/current/rules-views.html

### MariaDB Specific Features
- **JSON Functions**: https://mariadb.com/kb/en/json-functions/
- **Stored Procedures**: https://mariadb.com/kb/en/stored-procedures/
- **Triggers**: https://mariadb.com/kb/en/triggers/
- **Views**: https://mariadb.com/kb/en/views/
- **Sequences**: https://mariadb.com/kb/en/sequences/
- **Window Functions**: https://mariadb.com/kb/en/window-functions/

### Performance and Optimization
- **PostgreSQL Performance**: https://www.postgresql.org/docs/current/performance-tips.html
- **Query Optimization**: https://www.postgresql.org/docs/current/using-explain.html
- **Index Usage**: https://www.postgresql.org/docs/current/indexes.html
- **MariaDB Optimization**: https://mariadb.com/kb/en/optimization/
- **Query Cache**: https://mariadb.com/kb/en/query-cache/
- **Storage Engines**: https://mariadb.com/kb/en/storage-engines/

### Administration and Security
- **PostgreSQL Security**: https://www.postgresql.org/docs/current/user-manag.html
- **Authentication**: https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
- **Backup and Recovery**: https://www.postgresql.org/docs/current/backup.html
- **MariaDB Security**: https://mariadb.com/kb/en/securing-mariadb/
- **User Management**: https://mariadb.com/kb/en/account-management-sql-commands/
- **Backup Methods**: https://mariadb.com/kb/en/backup-and-restore-overview/

### Connection and Drivers
- **PostgreSQL JDBC**: https://jdbc.postgresql.org/documentation/
- **libpq (C API)**: https://www.postgresql.org/docs/current/libpq.html
- **psycopg2 (Python)**: https://www.psycopg.org/docs/
- **MariaDB Connector/J**: https://mariadb.com/kb/en/about-mariadb-connector-j/
- **MariaDB Connector/C**: https://mariadb.com/kb/en/mariadb-connector-c/
- **Node.js Drivers**: https://mariadb.com/kb/en/nodejs-connector/

### Tools and Utilities
- **psql**: https://www.postgresql.org/docs/current/app-psql.html
- **pgAdmin**: https://www.pgadmin.org/docs/
- **pg_dump**: https://www.postgresql.org/docs/current/app-pgdump.html
- **mysql/mariadb CLI**: https://mariadb.com/kb/en/mysql-command-line-client/
- **mysqldump**: https://mariadb.com/kb/en/mysqldump/
- **phpMyAdmin**: https://docs.phpmyadmin.net/

### Migration and Compatibility
- **PostgreSQL Migration**: https://www.postgresql.org/docs/current/migration.html
- **pg_upgrade**: https://www.postgresql.org/docs/current/pgupgrade.html
- **MariaDB Upgrade**: https://mariadb.com/kb/en/upgrading/
- **MySQL to MariaDB**: https://mariadb.com/kb/en/migrating-from-mysql-to-mariadb/
- **Data Import/Export**: https://mariadb.com/kb/en/importing-data-into-mariadb/

### Spring Data JPA Integration
- **Spring Data JPA**: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/
- **JPA with PostgreSQL**: https://www.baeldung.com/spring-boot-postgresql-docker
- **JPA with MariaDB**: https://www.baeldung.com/spring-boot-mariadb
- **Hibernate Documentation**: https://hibernate.org/orm/documentation/
- **JPA Specifications**: https://jakarta.ee/specifications/persistence/

### Database Design and Modeling
- **Database Design**: https://www.guru99.com/database-design.html
- **Normalization**: https://www.studytonight.com/dbms/database-normalization.php
- **ER Diagrams**: https://www.lucidchart.com/pages/er-diagrams
- **Schema Design**: https://www.postgresql.org/docs/current/ddl.html
- **Data Modeling**: https://www.vertabelo.com/blog/data-modeling/

### Testing and Development
- **TestContainers PostgreSQL**: https://testcontainers.com/modules/postgresql/
- **TestContainers MariaDB**: https://testcontainers.com/modules/mariadb/
- **H2 Database**: http://h2database.com/html/main.html
- **Database Testing**: https://www.baeldung.com/spring-boot-testing-testcontainers
- **Flyway Migration**: https://flywaydb.org/documentation/

### Monitoring and Logging
- **PostgreSQL Monitoring**: https://www.postgresql.org/docs/current/monitoring.html
- **pg_stat_statements**: https://www.postgresql.org/docs/current/pgstatstatements.html
- **Log Analysis**: https://www.postgresql.org/docs/current/logfile-maintenance.html
- **MariaDB Monitoring**: https://mariadb.com/kb/en/monitoring-mariadb/
- **Performance Schema**: https://mariadb.com/kb/en/performance-schema/
- **Slow Query Log**: https://mariadb.com/kb/en/slow-query-log/

### High Availability and Replication
- **PostgreSQL Replication**: https://www.postgresql.org/docs/current/high-availability.html
- **Streaming Replication**: https://www.postgresql.org/docs/current/warm-standby.html
- **MariaDB Replication**: https://mariadb.com/kb/en/standard-replication/
- **Galera Cluster**: https://mariadb.com/kb/en/galera-cluster/
- **MaxScale**: https://mariadb.com/kb/en/maxscale/

### Cloud and Managed Services
- **Amazon RDS PostgreSQL**: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html
- **Amazon RDS MariaDB**: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MariaDB.html
- **Azure Database for PostgreSQL**: https://docs.microsoft.com/en-us/azure/postgresql/
- **Azure Database for MariaDB**: https://docs.microsoft.com/en-us/azure/mariadb/
- **Google Cloud SQL**: https://cloud.google.com/sql/docs

### Learning Resources
- **PostgreSQL Tutorial**: https://postgresqltutorial.com/
- **MariaDB Tutorial**: https://www.mariadbtutorial.com/
- **SQL Bolt**: https://sqlbolt.com/
- **PostgreSQL Exercises**: https://pgexercises.com/
- **SQL Practice**: https://www.hackerrank.com/domains/sql

### Books and Publications
- **PostgreSQL: Up and Running**: O'Reilly Media
- **Learning PostgreSQL**: Packt Publishing
- **MariaDB Cookbook**: Packt Publishing
- **SQL Performance Explained**: Markus Winand
- **High Performance MySQL**: O'Reilly Media

### Community and Forums
- **PostgreSQL Mailing Lists**: https://www.postgresql.org/list/
- **PostgreSQL Slack**: https://postgres-slack.herokuapp.com/
- **MariaDB Community**: https://mariadb.org/get-involved/
- **Stack Overflow PostgreSQL**: https://stackoverflow.com/questions/tagged/postgresql
- **Stack Overflow MariaDB**: https://stackoverflow.com/questions/tagged/mariadb

### Version Information
- **PostgreSQL Releases**: https://www.postgresql.org/support/versioning/
- **PostgreSQL Release Notes**: https://www.postgresql.org/docs/release/
- **MariaDB Releases**: https://mariadb.org/download/
- **MariaDB Release Notes**: https://mariadb.com/kb/en/release-notes/
- **Version Compatibility**: https://mariadb.com/kb/en/mariadb-vs-mysql-compatibility/

### Security Resources
- **PostgreSQL Security**: https://www.postgresql.org/support/security/
- **CVE Database**: https://cve.mitre.org/
- **MariaDB Security**: https://mariadb.org/about/security/
- **Database Security Best Practices**: https://owasp.org/www-project-top-ten/
- **SQL Injection Prevention**: https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html

## VALIDATION_CHECKLIST
- [ ] Official documentation links verified
- [ ] Version-specific resources confirmed
- [ ] Driver documentation included
- [ ] Performance optimization covered
- [ ] Security best practices documented
- [ ] Migration guides available
- [ ] Tool documentation complete
- [ ] Community resources active
- [ ] Cloud service documentation included
- [ ] Learning resources comprehensive