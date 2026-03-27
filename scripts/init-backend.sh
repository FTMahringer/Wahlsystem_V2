#!/bin/bash

# Initialize Spring Boot Backend for Wahlsystem
# This script creates a complete Spring Boot 4.0.5 project structure with JWT Auth

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_ROOT/backend"
TEMPLATE_DIR="$SCRIPT_DIR/templates/backend"

echo "========================================"
echo "Initializing Wahlsystem Backend"
echo "========================================"

# Check if backend is already initialized
if [ -f "$BACKEND_DIR/pom.xml" ] && [ -d "$BACKEND_DIR/src" ]; then
    echo "Backend already initialized (pom.xml and src/ found)."
    echo "Skipping initialization."
    exit 0
fi

echo "Creating backend directory structure..."

# Create directory structure
mkdir -p "$BACKEND_DIR/src/main/java/com/example/wahlsystem"
mkdir -p "$BACKEND_DIR/src/main/resources"
mkdir -p "$BACKEND_DIR/src/test/java/com/example/wahlsystem"
mkdir -p "$BACKEND_DIR/src/test/resources"

# Create package structure
mkdir -p "$BACKEND_DIR/src/main/java/com/example/wahlsystem/"{config,controller,dto,entity,enums,exception,mapper,repository,security,service,validation,util}

# Copy pom.xml
echo "Creating pom.xml..."
cp "$TEMPLATE_DIR/pom.xml" "$BACKEND_DIR/pom.xml"

# Create Maven wrapper
echo "Creating Maven wrapper..."
cd "$BACKEND_DIR"

# Download Maven wrapper
if [ ! -f "$BACKEND_DIR/mvnw" ]; then
    echo "Downloading Maven wrapper..."
    curl -sSL https://raw.githubusercontent.com/takari/maven-wrapper/master/mvnw -o mvnw
    curl -sSL https://raw.githubusercontent.com/takari/maven-wrapper/master/mvnw.cmd -o mvnw.cmd
    chmod +x mvnw
    
    # Create .mvn/wrapper directory and properties
    mkdir -p "$BACKEND_DIR/.mvn/wrapper"
    cat > "$BACKEND_DIR/.mvn/wrapper/maven-wrapper.properties" << 'EOF'
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip
wrapperUrl=https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar
EOF
fi

# Create application.yml
echo "Creating application configuration..."
cp "$TEMPLATE_DIR/application.yml" "$BACKEND_DIR/src/main/resources/application.yml"

# Create main application class
echo "Creating main application class..."

mkdir -p "$BACKEND_DIR/src/main/java/com/example/wahlsystem"
cat > "$BACKEND_DIR/src/main/java/com/example/wahlsystem/WahlsystemApplication.java" << 'EOF'
package com.example.wahlsystem;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class WahlsystemApplication {

    public static void main(String[] args) {
        SpringApplication.run(WahlsystemApplication.class, args);
    }

}
EOF

# Copy entities from templates
echo "Creating entities..."
cp "$TEMPLATE_DIR/entity/User.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/entity/User.java"
cp "$TEMPLATE_DIR/entity/Admin.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/entity/Admin.java"
cp "$TEMPLATE_DIR/entity/Teacher.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/entity/Teacher.java"
cp "$TEMPLATE_DIR/entity/Student.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/entity/Student.java"

# Copy enums from templates
echo "Creating enums..."
cp "$TEMPLATE_DIR/enums/UserRole.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/enums/UserRole.java"
cp "$TEMPLATE_DIR/enums/ElectionStatus.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/enums/ElectionStatus.java"
cp "$TEMPLATE_DIR/enums/ElectionType.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/enums/ElectionType.java"

# Copy security classes from templates
echo "Creating security configuration..."
cp "$TEMPLATE_DIR/security/JwtConfig.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/JwtConfig.java"
cp "$TEMPLATE_DIR/security/JwtTokenProvider.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/JwtTokenProvider.java"
cp "$TEMPLATE_DIR/security/JwtAuthenticationFilter.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/JwtAuthenticationFilter.java"
cp "$TEMPLATE_DIR/security/UserPrincipal.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/UserPrincipal.java"
cp "$TEMPLATE_DIR/security/UserDetailsServiceImpl.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/UserDetailsServiceImpl.java"
cp "$TEMPLATE_DIR/security/SecurityConfig.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/SecurityConfig.java"

# Copy DTOs from templates
echo "Creating DTOs..."
cp "$TEMPLATE_DIR/dto/LoginRequest.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/dto/LoginRequest.java"
cp "$TEMPLATE_DIR/dto/RegisterRequest.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/dto/RegisterRequest.java"
cp "$TEMPLATE_DIR/dto/AuthResponse.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/dto/AuthResponse.java"
cp "$TEMPLATE_DIR/dto/UserDto.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/dto/UserDto.java"

# Copy repositories from templates
echo "Creating repositories..."
cp "$TEMPLATE_DIR/repository/UserRepository.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/repository/UserRepository.java"
cp "$TEMPLATE_DIR/repository/AdminRepository.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/repository/AdminRepository.java"
cp "$TEMPLATE_DIR/repository/TeacherRepository.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/repository/TeacherRepository.java"
cp "$TEMPLATE_DIR/repository/StudentRepository.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/repository/StudentRepository.java"

# Copy services from templates
echo "Creating services..."
cp "$TEMPLATE_DIR/service/AuthService.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/service/AuthService.java"

# Copy controllers from templates
echo "Creating controllers..."
cp "$TEMPLATE_DIR/controller/AuthController.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/controller/AuthController.java"

# Create Flyway migration
echo "Creating database migrations..."
mkdir -p "$BACKEND_DIR/src/main/resources/db/migration"

# Create initial schema migration
cat > "$BACKEND_DIR/src/main/resources/db/migration/V1__Initial_schema.sql" << 'EOF'
-- Initial schema for Wahlsystem

CREATE TABLE IF NOT EXISTS elections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'DRAFT',
    start_at TIMESTAMP,
    end_at TIMESTAMP,
    created_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS candidates (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    class_name VARCHAR(100),
    description TEXT,
    sort_order INT DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    election_id BIGINT NOT NULL,
    FOREIGN KEY (election_id) REFERENCES elections(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX idx_elections_status ON elections(status);
CREATE INDEX idx_candidates_election ON candidates(election_id);
EOF

# Copy users migration from template
cp "$TEMPLATE_DIR/V2__Create_users_table.sql" "$BACKEND_DIR/src/main/resources/db/migration/V2__Create_users_table.sql"

# Create test
echo "Creating sample test..."
mkdir -p "$BACKEND_DIR/src/test/java/com/example/wahlsystem"

cat > "$BACKEND_DIR/src/test/java/com/example/wahlsystem/WahlsystemApplicationTests.java" << 'EOF'
package com.example.wahlsystem;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class WahlsystemApplicationTests {

    @Test
    void contextLoads() {
    }

}
EOF

# Create application-test.yml
cat > "$BACKEND_DIR/src/test/resources/application-test.yml" << 'EOF'
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password:
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  flyway:
    enabled: false

app:
  jwt:
    secret: testSecretKey123456789012345678901234567890
    expiration-ms: 86400000
    refresh-expiration-ms: 604800000
EOF

echo ""
echo "========================================"
echo "Backend initialization complete!"
echo "========================================"
echo ""
echo "Project structure created at: $BACKEND_DIR"
echo ""
echo "Default admin credentials:"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "Next steps:"
echo "  1. cd backend"
echo "  2. ./mvnw clean install (or mvnw.cmd on Windows)"
echo "  3. Start development with: ./mvnw spring-boot:run"
echo ""
