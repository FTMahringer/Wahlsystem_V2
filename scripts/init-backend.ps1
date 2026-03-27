# Initialize Spring Boot Backend for Wahlsystem
# This script creates a complete Spring Boot 4.0.5 project structure with JWT Auth

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR
$BACKEND_DIR = Join-Path $PROJECT_ROOT "backend"
$TEMPLATE_DIR = Join-Path $SCRIPT_DIR "templates/backend"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Initializing Wahlsystem Backend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if backend is already initialized
if ((Test-Path "$BACKEND_DIR/pom.xml") -and (Test-Path "$BACKEND_DIR/src")) {
    Write-Host "Backend already initialized (pom.xml and src/ found)." -ForegroundColor Yellow
    Write-Host "Skipping initialization."
    exit 0
}

Write-Host "Creating backend directory structure..." -ForegroundColor Green

# Create directory structure
$dirs = @(
    "src/main/java/com/example/wahlsystem/config",
    "src/main/java/com/example/wahlsystem/controller",
    "src/main/java/com/example/wahlsystem/dto",
    "src/main/java/com/example/wahlsystem/entity",
    "src/main/java/com/example/wahlsystem/enums",
    "src/main/java/com/example/wahlsystem/exception",
    "src/main/java/com/example/wahlsystem/mapper",
    "src/main/java/com/example/wahlsystem/repository",
    "src/main/java/com/example/wahlsystem/security",
    "src/main/java/com/example/wahlsystem/service",
    "src/main/java/com/example/wahlsystem/validation",
    "src/main/java/com/example/wahlsystem/util",
    "src/main/resources/db/migration",
    "src/test/java/com/example/wahlsystem",
    "src/test/resources"
)

foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $BACKEND_DIR $dir) | Out-Null
}

# Copy pom.xml
Write-Host "Creating pom.xml..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/pom.xml" "$BACKEND_DIR/pom.xml" -Force

# Create Maven wrapper
Write-Host "Creating Maven wrapper..." -ForegroundColor Green
Set-Location $BACKEND_DIR

if (-not (Test-Path "$BACKEND_DIR/mvnw")) {
    Write-Host "Downloading Maven wrapper..." -ForegroundColor Green
    
    # Download using Invoke-WebRequest
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/takari/maven-wrapper/master/mvnw" -OutFile "mvnw" -UseBasicParsing
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/takari/maven-wrapper/master/mvnw.cmd" -OutFile "mvnw.cmd" -UseBasicParsing
    
    # Create .mvn/wrapper directory and properties
    New-Item -ItemType Directory -Force -Path "$BACKEND_DIR/.mvn/wrapper" | Out-Null
    
    @"
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip
wrapperUrl=https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar
"@ | Set-Content "$BACKEND_DIR/.mvn/wrapper/maven-wrapper.properties" -Encoding UTF8
}

# Copy application.yml
Write-Host "Creating application configuration..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/application.yml" "$BACKEND_DIR/src/main/resources/application.yml" -Force

# Create main application class
Write-Host "Creating main application class..." -ForegroundColor Green

$mainClass = @'
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
'@

$mainClass | Set-Content "$BACKEND_DIR/src/main/java/com/example/wahlsystem/WahlsystemApplication.java" -Encoding UTF8

# Copy entities from templates
Write-Host "Creating entities..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/entity/User.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/entity/User.java" -Force
Copy-Item "$TEMPLATE_DIR/entity/Admin.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/entity/Admin.java" -Force
Copy-Item "$TEMPLATE_DIR/entity/Teacher.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/entity/Teacher.java" -Force
Copy-Item "$TEMPLATE_DIR/entity/Student.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/entity/Student.java" -Force

# Copy enums from templates
Write-Host "Creating enums..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/enums/UserRole.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/enums/UserRole.java" -Force
Copy-Item "$TEMPLATE_DIR/enums/ElectionStatus.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/enums/ElectionStatus.java" -Force
Copy-Item "$TEMPLATE_DIR/enums/ElectionType.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/enums/ElectionType.java" -Force

# Copy security classes from templates
Write-Host "Creating security configuration..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/security/JwtConfig.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/JwtConfig.java" -Force
Copy-Item "$TEMPLATE_DIR/security/JwtTokenProvider.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/JwtTokenProvider.java" -Force
Copy-Item "$TEMPLATE_DIR/security/JwtAuthenticationFilter.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/JwtAuthenticationFilter.java" -Force
Copy-Item "$TEMPLATE_DIR/security/UserPrincipal.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/UserPrincipal.java" -Force
Copy-Item "$TEMPLATE_DIR/security/UserDetailsServiceImpl.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/UserDetailsServiceImpl.java" -Force
Copy-Item "$TEMPLATE_DIR/security/SecurityConfig.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/security/SecurityConfig.java" -Force

# Copy DTOs from templates
Write-Host "Creating DTOs..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/dto/LoginRequest.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/dto/LoginRequest.java" -Force
Copy-Item "$TEMPLATE_DIR/dto/RegisterRequest.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/dto/RegisterRequest.java" -Force
Copy-Item "$TEMPLATE_DIR/dto/AuthResponse.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/dto/AuthResponse.java" -Force
Copy-Item "$TEMPLATE_DIR/dto/UserDto.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/dto/UserDto.java" -Force

# Copy repositories from templates
Write-Host "Creating repositories..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/repository/UserRepository.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/repository/UserRepository.java" -Force
Copy-Item "$TEMPLATE_DIR/repository/AdminRepository.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/repository/AdminRepository.java" -Force
Copy-Item "$TEMPLATE_DIR/repository/TeacherRepository.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/repository/TeacherRepository.java" -Force
Copy-Item "$TEMPLATE_DIR/repository/StudentRepository.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/repository/StudentRepository.java" -Force

# Copy services from templates
Write-Host "Creating services..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/service/AuthService.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/service/AuthService.java" -Force

# Copy controllers from templates
Write-Host "Creating controllers..." -ForegroundColor Green
Copy-Item "$TEMPLATE_DIR/controller/AuthController.java" "$BACKEND_DIR/src/main/java/com/example/wahlsystem/controller/AuthController.java" -Force

# Create Flyway migration
Write-Host "Creating database migrations..." -ForegroundColor Green

$migration = @'
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
'@
$migration | Set-Content "$BACKEND_DIR/src/main/resources/db/migration/V1__Initial_schema.sql" -Encoding UTF8

# Copy users migration from template
Copy-Item "$TEMPLATE_DIR/V2__Create_users_table.sql" "$BACKEND_DIR/src/main/resources/db/migration/V2__Create_users_table.sql" -Force

# Create test
Write-Host "Creating sample test..." -ForegroundColor Green

$testClass = @'
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
'@
$testClass | Set-Content "$BACKEND_DIR/src/test/java/com/example/wahlsystem/WahlsystemApplicationTests.java" -Encoding UTF8

# Create application-test.yml
$testYml = @'
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
'@
$testYml | Set-Content "$BACKEND_DIR/src/test/resources/application-test.yml" -Encoding UTF8

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Backend initialization complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Project structure created at: $BACKEND_DIR"
Write-Host ""
Write-Host "Default admin credentials:"
Write-Host "  Username: admin"
Write-Host "  Password: admin123"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. cd backend"
Write-Host "  2. .\mvnw.cmd clean install (Windows) or ./mvnw clean install (Linux/Mac)"
Write-Host "  3. Start development with: .\mvnw.cmd spring-boot:run"
Write-Host ""
