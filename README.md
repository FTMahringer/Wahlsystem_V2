# Docker Compose Environment

A complete Docker Compose setup with Vue.js (or React/Angular/Svelte) frontend, Spring Boot 4.0.5 with Java 26 backend, MariaDB (or PostgreSQL) database, and Redis cache.

## What's Included

- **Frontend** - Supports Vue 3.5.31+, React, Angular, Svelte, or any Node.js framework
- **Backend** - Spring Boot 4.0.5 with Java 26 (latest)
- **Database** - MariaDB 11.4 (default) or PostgreSQL 16 (alternative)
- **Database Admin** - phpMyAdmin (MariaDB) or pgAdmin (PostgreSQL)
- **Cache** - Redis 7 with Redis Commander (dev only)

## Project Structure

```
.
├── docker/
│   ├── dev/
│   │   ├── docker-compose.yml      # Development services
│   │   ├── frontend.Dockerfile     # Dev Dockerfile (supports Vue/React/Angular)
│   │   ├── backend.Dockerfile      # Dev Dockerfile (Java 26 + Spring Boot 4.0.5)
│   │   └── .env                    # Dev environment variables
│   └── prod/
│       ├── docker-compose.yml      # Production services
│       ├── frontend.Dockerfile     # Production Dockerfile
│       ├── backend.Dockerfile      # Production Dockerfile (Java 26 JRE)
│       └── .env                    # Production environment variables
├── nginx/
│   ├── dev/
│   │   └── nginx.conf              # Nginx config for development
│   └── prod/
│       ├── nginx.conf              # Nginx config for production
│       ├── default.conf            # Location blocks
│       └── ssl/                    # SSL certificates (production)
├── frontend/                       # Your Vue/React/Angular app
├── backend/                        # Your Spring Boot application
├── scripts/
│   ├── start-dev.sh / .ps1         # Start development environment
│   ├── start-prod.sh / .ps1        # Start production environment
│   ├── backup-db.sh                # Database backup script
│   └── restore-db.sh               # Database restore script
└── .env.example                    # Example environment variables
```

## Quick Start

### Development Environment

1. **Copy and configure environment variables:**
   ```bash
   cp .env.example docker/dev/.env
   # Edit docker/dev/.env with your settings
   ```

2. **Start the development environment:**
   
   On Linux/Mac:
   ```bash
   ./scripts/start-dev.sh
   ```
   
   On Windows (PowerShell):
   ```powershell
   .\scripts\start-dev.ps1
   ```

3. **Access the services:**
   - Frontend (with HMR): http://localhost:5173
   - Backend API: http://localhost:8080
   - phpMyAdmin: http://localhost:8081
   - Redis Commander: http://localhost:8082

### Production Environment

1. **Copy and configure environment variables:**
   ```bash
   cp .env.example docker/prod/.env
   # Edit docker/prod/.env and change ALL default passwords!
   ```

2. **Start the production environment:**
   
   On Linux/Mac:
   ```bash
   ./scripts/start-prod.sh
   ```
   
   On Windows (PowerShell):
   ```powershell
   .\scripts\start-prod.ps1
   ```

3. **Access the application:**
   - Application: http://localhost

## Services Overview

| Service | Development | Production | Description |
|---------|-------------|------------|-------------|
| Frontend | Port 5173 (HMR) | Static files | Vue/React/Angular/etc. |
| Spring Boot | Port 8080 | Internal | Backend API (Java 26) |
| MariaDB | Port 3306 | Internal | Database (default) |
| phpMyAdmin | Port 8081 | Optional | DB management |
| Redis | Port 6379 | Internal | Cache |
| Redis Commander | Port 8082 | - | Redis GUI |

## Technology Stack Details

### Backend (Spring Boot)
- **Java**: 26 (latest stable, released March 2026)
- **Spring Boot**: 4.0.5
- **Spring Framework**: 7.x
- **Build Tool**: Maven
- **Features**: DevTools (hot reload), Actuator (health checks), OpenAPI/Swagger

### Frontend
Flexible - supports any Node.js-based framework:
- **Vue.js**: 3.5.31+ (recommended)
- **React**: 18/19 with Vite or Next.js
- **Angular**: 17/18
- **Svelte/SvelteKit**
- **Node.js**: 22 LTS

### Database Options

#### MariaDB (Default)
- Version: 11.4
- Management: phpMyAdmin
- Driver: `org.mariadb.jdbc:mariadb-java-client`

#### PostgreSQL (Alternative)
To switch to PostgreSQL:
1. In `docker-compose.yml`, comment out `mariadb` and `phpmyadmin` services
2. Uncomment `db` (PostgreSQL) and `pgadmin` services
3. Update the backend connection string from `jdbc:mariadb://` to `jdbc:postgresql://`

## Environment Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `PROJECT_NAME` | Project name prefix | `myapp` |
| `NGINX_PORT` | Nginx HTTP port | `80` |
| `DB_NAME` | Database name | `myapp_db` |
| `DB_USER` | Database user | `myapp_user` |
| `DB_PASSWORD` | Database password | `secure_password` |
| `DB_ROOT_PASSWORD` | MariaDB root password | `root_password` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `REDIS_PASSWORD` | Redis password | - |
| `PHPMYADMIN_PORT` | phpMyAdmin port | `8081` |
| `DEBUG_PORT` | Java debug port | `5005` |

---

## Backend Dependencies (Spring Boot 4.0.5)

### Core Dependencies

```xml
<!-- Spring Boot Parent -->
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>4.0.5</version>
    <relativePath/>
</parent>

<!-- Java Version -->
<properties>
    <java.version>26</java.version>
</properties>
```

### Web & REST API

```xml
<!-- Spring Boot Web Starter - Core web functionality including REST -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Spring Boot WebFlux Starter - Reactive web support (optional) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>

<!-- Validation - Bean Validation with Hibernate Validator -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

### OpenAPI / Swagger Documentation

```xml
<!-- SpringDoc OpenAPI for Spring Boot 4.x - API documentation -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>3.0.2</version>
</dependency>

<!-- Alternative: SpringDoc WebFlux (if using reactive) -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webflux-ui</artifactId>
    <version>3.0.2</version>
</dependency>
```

### Database & JPA

```xml
<!-- Spring Data JPA - JPA support with Hibernate -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- MariaDB JDBC Driver (Default) -->
<dependency>
    <groupId>org.mariadb.jdbc</groupId>
    <artifactId>mariadb-java-client</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Alternative: PostgreSQL JDBC Driver -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- H2 Database - For testing/development -->
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Flyway - Database migrations -->
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>

<!-- Flyway MySQL/MariaDB support -->
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-mysql</artifactId>
</dependency>
```

### Redis Cache

```xml
<!-- Spring Data Redis - Redis support -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<!-- Lettuce Core - Redis client (included in starter, but can be explicit) -->
<dependency>
    <groupId>io.lettuce</groupId>
    <artifactId>lettuce-core</artifactId>
</dependency>

<!-- Spring Boot Cache Starter - Caching abstraction -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

### Security

```xml
<!-- Spring Security - Authentication and authorization -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- OAuth2 Resource Server - JWT token validation -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
</dependency>

<!-- OAuth2 Client - OAuth2 client support -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-client</artifactId>
</dependency>

<!-- JWT Implementation - Nimbus JOSE+JWT -->
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-oauth2-jose</artifactId>
</dependency>
```

### Monitoring & Observability

```xml
<!-- Spring Boot Actuator - Production-ready features, health checks, metrics -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<!-- Micrometer Prometheus Registry - Metrics export to Prometheus -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>

<!-- OpenTelemetry Starter - Distributed tracing (NEW in Spring Boot 4.0) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-opentelemetry</artifactId>
</dependency>

<!-- Zipkin Brave - Alternative tracing (optional) -->
<dependency>
    <groupId>io.zipkin.brave</groupId>
    <artifactId>brave-instrumentation-spring-web</artifactId>
</dependency>
```

### Messaging

```xml
<!-- Spring for RabbitMQ - AMQP messaging -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>

<!-- Spring for Apache Kafka - Kafka messaging -->
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>

<!-- Spring Boot Starter Mail - Email support -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>
```

### Utilities

```xml
<!-- Lombok - Reduce boilerplate code -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>

<!-- MapStruct - Object mapping -->
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.6.0</version>
</dependency>

<!-- MapStruct Processor -->
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct-processor</artifactId>
    <version>1.6.0</version>
    <scope>provided</scope>
</dependency>

<!-- Apache Commons Lang3 - Utility functions -->
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-lang3</artifactId>
</dependency>

<!-- Jackson Datatype JSR310 - Java 8 date/time support -->
<dependency>
    <groupId>com.fasterxml.jackson.datatype</groupId>
    <artifactId>jackson-datatype-jsr310</artifactId>
</dependency>

<!-- Configuration Processor - For application.yml/properties metadata -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

### Testing

```xml
<!-- Spring Boot Test Starter - Testing support -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>

<!-- Spring Security Test - Security testing utilities -->
<dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-test</artifactId>
    <scope>test</scope>
</dependency>

<!-- Testcontainers - Integration testing with Docker -->
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>

<!-- Testcontainers MariaDB -->
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>mariadb</artifactId>
    <scope>test</scope>
</dependency>

<!-- Testcontainers Redis -->
<dependency>
    <groupId>com.redis.testcontainers</groupId>
    <artifactId>testcontainers-redis-junit</artifactId>
    <version>1.6.4</version>
    <scope>test</scope>
</dependency>

<!-- REST Assured - API testing -->
<dependency>
    <groupId>io.rest-assured</groupId>
    <artifactId>rest-assured</artifactId>
    <scope>test</scope>
</dependency>
```

### Development Tools

```xml
<!-- Spring Boot DevTools - Hot reload, automatic restart -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <scope>runtime</scope>
    <optional>true</optional>
</dependency>
```

---

## Frontend Dependencies

### Vue.js 3.5.31+ (Recommended)

```json
{
  "dependencies": {
    "vue": "^3.5.31",
    "vue-router": "^4.5.0",
    "pinia": "^2.3.0",
    "axios": "^1.7.9"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.2.0",
    "vite": "^6.0.0",
    "vue-tsc": "^2.2.0",
    "typescript": "~5.7.0",
    "@types/node": "^22.10.0"
  }
}
```

### React 18/19 with Vite

```json
{
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router-dom": "^7.0.0",
    "@tanstack/react-query": "^5.62.0",
    "axios": "^1.7.9",
    "zustand": "^5.0.0"
  },
  "devDependencies": {
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "@vitejs/plugin-react": "^4.3.0",
    "vite": "^6.0.0",
    "typescript": "~5.7.0"
  }
}
```

### Angular 18

```json
{
  "dependencies": {
    "@angular/animations": "^18.2.0",
    "@angular/common": "^18.2.0",
    "@angular/compiler": "^18.2.0",
    "@angular/core": "^18.2.0",
    "@angular/forms": "^18.2.0",
    "@angular/platform-browser": "^18.2.0",
    "@angular/platform-browser-dynamic": "^18.2.0",
    "@angular/router": "^18.2.0",
    "rxjs": "~7.8.0",
    "tslib": "^2.8.0",
    "zone.js": "~0.14.0"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "^18.2.0",
    "@angular/cli": "^18.2.0",
    "@angular/compiler-cli": "^18.2.0",
    "typescript": "~5.5.0"
  }
}
```

### Common Frontend Libraries

```json
{
  "dependencies": {
    "axios": "^1.7.9",
    "date-fns": "^4.1.0",
    "lodash-es": "^4.17.21",
    "zod": "^3.24.0"
  },
  "devDependencies": {
    "@types/lodash-es": "^4.17.12",
    "eslint": "^9.17.0",
    "prettier": "^3.4.0",
    "vitest": "^2.1.0",
    "@testing-library/vue": "^8.1.0",
    "@testing-library/react": "^16.1.0",
    "@testing-library/jest-dom": "^6.6.0"
  }
}
```

---

## Complete Backend pom.xml Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>4.0.5</version>
        <relativePath/>
    </parent>
    
    <groupId>com.example</groupId>
    <artifactId>myapp</artifactId>
    <version>1.0.0</version>
    <name>myapp</name>
    <description>My Application with Spring Boot 4.0.5</description>
    
    <properties>
        <java.version>26</java.version>
        <mapstruct.version>1.6.0</mapstruct.version>
        <springdoc.version>2.8.0</springdoc.version>
    </properties>
    
    <dependencies>
        <!-- Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <!-- OpenAPI/Swagger -->
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>${springdoc.version}</version>
        </dependency>
        
        <!-- Database -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.mariadb.jdbc</groupId>
            <artifactId>mariadb-java-client</artifactId>
            <scope>runtime</scope>
        </dependency>
        
        <!-- Redis -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-cache</artifactId>
        </dependency>
        
        <!-- Security -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
        </dependency>
        
        <!-- Monitoring -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-opentelemetry</artifactId>
        </dependency>
        
        <!-- Utilities -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct</artifactId>
            <version>${mapstruct.version}</version>
        </dependency>
        
        <dependency>
            <groupId>org.mapstruct</groupId>
            <artifactId>mapstruct-processor</artifactId>
            <version>${mapstruct.version}</version>
            <scope>provided</scope>
        </dependency>
        
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-lang3</artifactId>
        </dependency>
        
        <dependency>
            <groupId>com.fasterxml.jackson.datatype</groupId>
            <artifactId>jackson-datatype-jsr310</artifactId>
        </dependency>
        
        <!-- Development -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        
        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

---

## Application Configuration (Spring Boot 4.0.5)

### application-dev.yml

```yaml
server:
  port: 8080

spring:
  application:
    name: myapp
  
  datasource:
    url: jdbc:mariadb://mariadb:3306/${DB_NAME}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
    driver-class-name: org.mariadb.jdbc.Driver
  
  redis:
    host: redis
    port: 6379
  
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MariaDBDialect
        format_sql: true
  
  cache:
    type: redis
    redis:
      time-to-live: 600000
  
  devtools:
    restart:
      enabled: true
    livereload:
      enabled: true

# OpenAPI Configuration
springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html
    operationsSorter: method

# Logging
logging:
  level:
    org.springframework.web: DEBUG
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE

# Management / Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true
```

### application-prod.yml

```yaml
server:
  port: 8080

spring:
  application:
    name: myapp
  
  datasource:
    url: jdbc:mariadb://mariadb:3306/${DB_NAME}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
    driver-class-name: org.mariadb.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
  
  redis:
    host: redis
    port: 6379
    password: ${REDIS_PASSWORD}
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MariaDBDialect
  
  cache:
    type: redis
    redis:
      time-to-live: 3600000

# OpenAPI Configuration
springdoc:
  api-docs:
    enabled: false
  swagger-ui:
    enabled: false

# Logging
logging:
  level:
    root: WARN
    com.example: INFO

# Management / Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
      base-path: /actuator
  endpoint:
    health:
      show-details: when_authorized
      probes:
        enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
  tracing:
    export:
      enabled: true
```

---

## SSL/HTTPS (Production)

To enable HTTPS in production:

1. Place your SSL certificates in `nginx/prod/ssl/`:
   - `cert.pem` - Certificate
   - `key.pem` - Private key

2. Uncomment the HTTPS server block in `nginx/prod/nginx.conf`

3. Alternatively, use a reverse proxy like Traefik or Caddy for automatic HTTPS

---

## Backup and Restore

### Backup Database

```bash
./scripts/backup-db.sh
```

Backups are saved to `./backups/` with timestamp.

### Restore Database

```bash
./scripts/restore-db.sh ./backups/myapp_backup_20240101_120000.sql.gz
```

---

## Useful Commands

```bash
# View logs
docker-compose -f docker/dev/docker-compose.yml logs -f

# Stop services
docker-compose -f docker/dev/docker-compose.yml down

# Stop and remove volumes (WARNING: deletes data!)
docker-compose -f docker/dev/docker-compose.yml down -v

# Rebuild specific service
docker-compose -f docker/dev/docker-compose.yml up -d --build backend

# Execute command in container
docker-compose -f docker/dev/docker-compose.yml exec mariadb mysql -u root -p

# Access Redis CLI
docker-compose -f docker/dev/docker-compose.yml exec redis redis-cli
```

---

## Troubleshooting

### Port Already in Use

If you get "port already in use" errors, change the ports in your `.env` file.

### Permission Denied (Linux/Mac)

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Database Connection Issues

Check that the database is healthy:
```bash
docker-compose -f docker/dev/docker-compose.yml ps
```

### Frontend Hot Reload Not Working

Ensure your dev server config has `host: '0.0.0.0'`:
- **Vite**: `server: { host: '0.0.0.0' }`
- **Angular**: `--host 0.0.0.0 --disable-host-check`
- **Next.js**: `--hostname 0.0.0.0`

### Java Version Issues

The backend uses Java 26. Make sure your `pom.xml` specifies:
```xml
<java.version>26</java.version>
```

---

## Security Notes

1. **Change all default passwords** before deploying to production
2. Use strong, unique passwords for database and admin interfaces
3. Enable HTTPS in production
4. Restrict access to phpMyAdmin/pgAdmin in production
5. Regularly update Docker images
6. Use non-root users in production containers (already configured)
7. Java 26 includes security improvements and should be kept up to date

---

## Technology Highlights

### Spring Boot 4.0.5 Features

- **Spring Framework 7.x** base
- **HTTP Service Clients** - Annotate interfaces for automatic HTTP client implementation
- **API Versioning** - Built-in support for API versioning strategies
- **OpenTelemetry Starter** - First-class observability support
- **JSpecify Null Safety** - Improved null-safety annotations
- **Kotlin Serialization** - First-class Kotlinx.serialization support
- **Virtual Threads** - Enhanced support for Project Loom virtual threads

### Java 26 Features

- **HTTP/3 Support** - JEP 517 for HTTP Client API
- **G1 GC Improvements** - Better throughput (JEP 522)
- **AOT Object Caching** - With any GC (JEP 516)
- **Structured Concurrency** - Preview (JEP 525)
- **Vector API** - Eleventh incubator (JEP 529)

---

## License

MIT
