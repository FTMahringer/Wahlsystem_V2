# Start development environment
# Auto-initializes backend and frontend if needed

$ErrorActionPreference = "Stop"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_ROOT = Split-Path -Parent $SCRIPT_DIR

# ============================================================================
# Helper Functions (must be defined before use)
# ============================================================================

function Initialize-Backend {
    $BACKEND_DIR = "$PROJECT_ROOT\backend"
    $TEMPLATE_DIR = "$SCRIPT_DIR\templates\backend"

    Write-Host "Creating backend directory structure..." -ForegroundColor Green

    # Create directory structure
    $dirs = @(
        "src\main\java\at\ftmahringer\wahlsystem\config",
        "src\main\java\at\ftmahringer\wahlsystem\controller",
        "src\main\java\at\ftmahringer\wahlsystem\dto",
        "src\main\java\at\ftmahringer\wahlsystem\entity",
        "src\main\java\at\ftmahringer\wahlsystem\enums",
        "src\main\java\at\ftmahringer\wahlsystem\exception",
        "src\main\java\at\ftmahringer\wahlsystem\mapper",
        "src\main\java\at\ftmahringer\wahlsystem\repository",
        "src\main\java\at\ftmahringer\wahlsystem\security",
        "src\main\java\at\ftmahringer\wahlsystem\service",
        "src\main\java\at\ftmahringer\wahlsystem\validation",
        "src\main\java\at\ftmahringer\wahlsystem\util",
        "src\main\resources\db\migration",
        "src\test\java\at\ftmahringer\wahlsystem",
        "src\test\resources"
    )

    foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Force -Path "$BACKEND_DIR\$dir" | Out-Null
    }

    # Copy pom.xml
    Write-Host "Creating pom.xml..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\pom.xml" "$BACKEND_DIR\pom.xml" -Force

    # Create Maven wrapper
    Write-Host "Creating Maven wrapper..." -ForegroundColor Green

    # Create .mvn/wrapper directory
    New-Item -ItemType Directory -Force -Path "$BACKEND_DIR\.mvn\wrapper" | Out-Null

    # Create maven-wrapper.properties
    $wrapperProps = "distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip`nwrapperUrl=https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar`n"
    [System.IO.File]::WriteAllText("$BACKEND_DIR\.mvn\wrapper\maven-wrapper.properties", $wrapperProps)

    # Download the wrapper jar
    $wrapperJarUrl = "https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar"
    Invoke-WebRequest -Uri $wrapperJarUrl -OutFile "$BACKEND_DIR\.mvn\wrapper\maven-wrapper.jar" -UseBasicParsing

    # Create mvnw shell script (LF line endings for Docker/Linux)
    $mvnwSh = "#!/bin/sh`n" +
"# Apache Maven Wrapper startup script`n" +
"# -----------------------------------------------------------------------------`n" +
"`n" +
"APP_HOME=`$( cd `"`${APP_HOME:-.}`" && pwd -P ) || exit`n" +
"CLASSPATH=`$APP_HOME/.mvn/wrapper/maven-wrapper.jar`n" +
"`n" +
"# Determine the Java command to use to start the JVM.`n" +
"if [ -n `"`$JAVA_HOME`" ] ; then`n" +
"    if [ -x `"`$JAVA_HOME/jre/sh/java`" ] ; then`n" +
"        JAVACMD=`"`$JAVA_HOME/jre/sh/java`"`n" +
"    else`n" +
"        JAVACMD=`"`$JAVA_HOME/bin/java`"`n" +
"    fi`n" +
"    if [ ! -x `"`$JAVACMD`" ] ; then`n" +
"        echo `"ERROR: JAVA_HOME is set to an invalid directory: `$JAVA_HOME`"`n" +
"        exit 1`n" +
"    fi`n" +
"else`n" +
"    JAVACMD=`"java`"`n" +
"    if ! command -v java >/dev/null 2>&1 ; then`n" +
"        echo `"ERROR: JAVA_HOME is not set and no 'java' command could be found`"`n" +
"        exit 1`n" +
"    fi`n" +
"fi`n" +
"`n" +
"exec `"`$JAVACMD`" `$MAVEN_OPTS `$MAVEN_DEBUG_OPTS -classpath `"`$CLASSPATH`" -Dmaven.multiModuleProjectDirectory=`"`$MAVEN_PROJECTBASEDIR`" org.apache.maven.wrapper.MavenWrapperMain `"`$@`"`n"

    [System.IO.File]::WriteAllText("$BACKEND_DIR\mvnw", $mvnwSh)

    # Create mvnw.cmd for Windows (CRLF is fine for Windows)
    $mvnwCmd = "@echo off`r`n" +
"setlocal`r`n" +
"`r`n" +
"if not `%JAVA_HOME%` == `"`" goto OkJHome`r`n" +
"echo Error: JAVA_HOME not found in your environment.`r`n" +
"exit /b 1`r`n" +
"`r`n" +
":OkJHome`r`n" +
"if exist `%JAVA_HOME%\bin\java.exe` goto init`r`n" +
"echo Error: JAVA_HOME is set to an invalid directory.`r`n" +
"exit /b 1`r`n" +
"`r`n" +
":init`r`n" +
"set MAVEN_PROJECTBASEDIR=%CD%`r`n" +
"set WRAPPER_JAR=%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar`r`n" +
"`r`n" +
"`%JAVA_HOME%\bin\java.exe` %MAVEN_OPTS% %MAVEN_DEBUG_OPTS% -classpath `%WRAPPER_JAR%` -Dmaven.multiModuleProjectDirectory=`%MAVEN_PROJECTBASEDIR%` org.apache.maven.wrapper.MavenWrapperMain %*`r`n" +
"if ERRORLEVEL 1 exit /b 1`r`n" +
"exit /b 0`r`n"

    [System.IO.File]::WriteAllText("$BACKEND_DIR\mvnw.cmd", $mvnwCmd)

    # Copy application.yml
    Write-Host "Creating application configuration..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\application.yml" "$BACKEND_DIR\src\main\resources\application.yml" -Force

    # Create main application class
    Write-Host "Creating main application class..." -ForegroundColor Green

    $mainClass = @'
package at.ftmahringer.wahlsystem;

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

    $mainClass | Set-Content "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\WahlsystemApplication.java" -Encoding UTF8

    # Copy entities from templates
    Write-Host "Creating entities..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\entity\User.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\entity\User.java" -Force
    Copy-Item "$TEMPLATE_DIR\entity\Admin.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\entity\Admin.java" -Force
    Copy-Item "$TEMPLATE_DIR\entity\Teacher.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\entity\Teacher.java" -Force
    Copy-Item "$TEMPLATE_DIR\entity\Student.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\entity\Student.java" -Force

    # Copy enums from templates
    Write-Host "Creating enums..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\enums\UserRole.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\enums\UserRole.java" -Force
    Copy-Item "$TEMPLATE_DIR\enums\ElectionStatus.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\enums\ElectionStatus.java" -Force
    Copy-Item "$TEMPLATE_DIR\enums\ElectionType.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\enums\ElectionType.java" -Force

    # Copy security classes from templates
    Write-Host "Creating security configuration..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\security\JwtConfig.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\security\JwtConfig.java" -Force
    Copy-Item "$TEMPLATE_DIR\security\JwtTokenProvider.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\security\JwtTokenProvider.java" -Force
    Copy-Item "$TEMPLATE_DIR\security\JwtAuthenticationFilter.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\security\JwtAuthenticationFilter.java" -Force
    Copy-Item "$TEMPLATE_DIR\security\UserPrincipal.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\security\UserPrincipal.java" -Force
    Copy-Item "$TEMPLATE_DIR\security\UserDetailsServiceImpl.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\security\UserDetailsServiceImpl.java" -Force
    Copy-Item "$TEMPLATE_DIR\security\SecurityConfig.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\security\SecurityConfig.java" -Force

    # Copy DTOs from templates
    Write-Host "Creating DTOs..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\dto\LoginRequest.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\dto\LoginRequest.java" -Force
    Copy-Item "$TEMPLATE_DIR\dto\RegisterRequest.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\dto\RegisterRequest.java" -Force
    Copy-Item "$TEMPLATE_DIR\dto\AuthResponse.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\dto\AuthResponse.java" -Force
    Copy-Item "$TEMPLATE_DIR\dto\UserDto.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\dto\UserDto.java" -Force

    # Copy repositories from templates
    Write-Host "Creating repositories..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\repository\UserRepository.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\repository\UserRepository.java" -Force
    Copy-Item "$TEMPLATE_DIR\repository\AdminRepository.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\repository\AdminRepository.java" -Force
    Copy-Item "$TEMPLATE_DIR\repository\TeacherRepository.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\repository\TeacherRepository.java" -Force
    Copy-Item "$TEMPLATE_DIR\repository\StudentRepository.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\repository\StudentRepository.java" -Force

    # Copy services from templates
    Write-Host "Creating services..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\service\AuthService.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\service\AuthService.java" -Force

    # Copy controllers from templates
    Write-Host "Creating controllers..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\controller\AuthController.java" "$BACKEND_DIR\src\main\java\at\ftmahringer\wahlsystem\controller\AuthController.java" -Force

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
    $migration | Set-Content "$BACKEND_DIR\src\main\resources\db\migration\V1__Initial_schema.sql" -Encoding UTF8

    # Copy users migration from template
    Copy-Item "$TEMPLATE_DIR\V2__Create_users_table.sql" "$BACKEND_DIR\src\main\resources\db\migration\V2__Create_users_table.sql" -Force

    # Create test
    Write-Host "Creating sample test..." -ForegroundColor Green

    $testClass = @'
package at.ftmahringer.wahlsystem;

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
    $testClass | Set-Content "$BACKEND_DIR\src\test\java\at\ftmahringer\wahlsystem\WahlsystemApplicationTests.java" -Encoding UTF8

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
    $testYml | Set-Content "$BACKEND_DIR\src\test\resources\application-test.yml" -Encoding UTF8

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Backend initialization complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}

function Initialize-Frontend {
    $FRONTEND_DIR = "$PROJECT_ROOT\frontend"
    $TEMPLATE_DIR = "$SCRIPT_DIR\templates\frontend"

    Write-Host "Creating frontend directory structure..." -ForegroundColor Green

    # Create directory structure
    $dirs = @(
        "src\api",
        "src\assets",
        "src\components\common",
        "src\components\admin",
        "src\components\voter",
        "src\components\auth",
        "src\composables",
        "src\layouts",
        "src\stores",
        "src\types",
        "src\utils",
        "src\views\admin",
        "src\views\voter",
        "src\views\auth"
    )

    foreach ($dir in $dirs) {
        New-Item -ItemType Directory -Force -Path "$FRONTEND_DIR\$dir" | Out-Null
    }

    # Copy template files
    Write-Host "Creating configuration files..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\package.json" "$FRONTEND_DIR\package.json" -Force
    Copy-Item "$TEMPLATE_DIR\vite.config.ts" "$FRONTEND_DIR\vite.config.ts" -Force
    Copy-Item "$TEMPLATE_DIR\tsconfig.json" "$FRONTEND_DIR\tsconfig.json" -Force
    Copy-Item "$TEMPLATE_DIR\tsconfig.node.json" "$FRONTEND_DIR\tsconfig.node.json" -Force
    Copy-Item "$TEMPLATE_DIR\index.html" "$FRONTEND_DIR\index.html" -Force
    Copy-Item "$TEMPLATE_DIR\App.vue" "$FRONTEND_DIR\src\App.vue" -Force
    Copy-Item "$TEMPLATE_DIR\main.ts" "$FRONTEND_DIR\src\main.ts" -Force
    Copy-Item "$TEMPLATE_DIR\router.ts" "$FRONTEND_DIR\src\router.ts" -Force
    Copy-Item "$TEMPLATE_DIR\env.d.ts" "$FRONTEND_DIR\src\env.d.ts" -Force

    # Create .env files
    Write-Host "Creating environment files..." -ForegroundColor Green

    $envDev = @'
VITE_API_BASE_URL=http://localhost:8080/api/v1
VITE_APP_NAME=Wahlsystem
VITE_APP_ENV=development
'@
    $envDev | Set-Content "$FRONTEND_DIR\.env.development" -Encoding UTF8

    $envProd = @'
VITE_API_BASE_URL=/api/v1
VITE_APP_NAME=Wahlsystem
VITE_APP_ENV=production
'@
    $envProd | Set-Content "$FRONTEND_DIR\.env.production" -Encoding UTF8

    # Copy types from templates
    Write-Host "Creating TypeScript types..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\src\types\auth.ts" "$FRONTEND_DIR\src\types\auth.ts" -Force
    Copy-Item "$TEMPLATE_DIR\src\types\election.ts" "$FRONTEND_DIR\src\types\election.ts" -Force
    Copy-Item "$TEMPLATE_DIR\src\types\candidate.ts" "$FRONTEND_DIR\src\types\candidate.ts" -Force
    Copy-Item "$TEMPLATE_DIR\src\types\vote.ts" "$FRONTEND_DIR\src\types\vote.ts" -Force
    Copy-Item "$TEMPLATE_DIR\src\types\index.ts" "$FRONTEND_DIR\src\types\index.ts" -Force

    # Copy API layer from templates
    Write-Host "Creating API layer..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\src\api\axios.ts" "$FRONTEND_DIR\src\api\axios.ts" -Force
    Copy-Item "$TEMPLATE_DIR\src\api\authApi.ts" "$FRONTEND_DIR\src\api\authApi.ts" -Force
    Copy-Item "$TEMPLATE_DIR\src\api\electionApi.ts" "$FRONTEND_DIR\src\api\electionApi.ts" -Force
    Copy-Item "$TEMPLATE_DIR\src\api\candidateApi.ts" "$FRONTEND_DIR\src\api\candidateApi.ts" -Force
    Copy-Item "$TEMPLATE_DIR\src\api\voteApi.ts" "$FRONTEND_DIR\src\api\voteApi.ts" -Force
    Copy-Item "$TEMPLATE_DIR\src\api\index.ts" "$FRONTEND_DIR\src\api\index.ts" -Force

    # Copy stores from templates
    Write-Host "Creating Pinia stores..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\src\stores\authStore.ts" "$FRONTEND_DIR\src\stores\authStore.ts" -Force

    # Copy views from templates
    Write-Host "Creating views..." -ForegroundColor Green
    Copy-Item "$TEMPLATE_DIR\src\views\auth\LoginView.vue" "$FRONTEND_DIR\src\views\auth\LoginView.vue" -Force
    Copy-Item "$TEMPLATE_DIR\src\views\auth\RegisterView.vue" "$FRONTEND_DIR\src\views\auth\RegisterView.vue" -Force
    Copy-Item "$TEMPLATE_DIR\src\views\voter\VoterLoginView.vue" "$FRONTEND_DIR\src\views\voter\VoterLoginView.vue" -Force
    Copy-Item "$TEMPLATE_DIR\src\views\voter\VoterElectionView.vue" "$FRONTEND_DIR\src\views\voter\VoterElectionView.vue" -Force
    Copy-Item "$TEMPLATE_DIR\src\views\admin\AdminLoginView.vue" "$FRONTEND_DIR\src\views\admin\AdminLoginView.vue" -Force
    Copy-Item "$TEMPLATE_DIR\src\views\admin\AdminDashboardView.vue" "$FRONTEND_DIR\src\views\admin\AdminDashboardView.vue" -Force
    Copy-Item "$TEMPLATE_DIR\src\views\admin\AdminElectionsView.vue" "$FRONTEND_DIR\src\views\admin\AdminElectionsView.vue" -Force

    # Install npm dependencies
    Write-Host "Installing npm dependencies..." -ForegroundColor Green
    Set-Location $FRONTEND_DIR
    npm install
    Set-Location $PROJECT_ROOT

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Frontend initialization complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}

# ============================================================================
# Main Script
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Wahlsystem Development Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (-not (Test-Path "$PROJECT_ROOT/docker/dev/.env")) {
    Write-Host "Error: docker/dev/.env not found!" -ForegroundColor Red
    Write-Host "Please copy .env.example to docker/dev/.env and configure it." -ForegroundColor Yellow
    exit 1
}

# Initialize backend if needed
if (-not (Test-Path "$PROJECT_ROOT/backend/pom.xml")) {
    Write-Host "Backend not initialized. Initializing..." -ForegroundColor Yellow
    Initialize-Backend
    Write-Host ""
}

# Initialize frontend if needed
if (-not (Test-Path "$PROJECT_ROOT/frontend/package.json")) {
    Write-Host "Frontend not initialized. Initializing..." -ForegroundColor Yellow
    Initialize-Frontend
    Write-Host ""
}

Write-Host "Starting Docker containers..." -ForegroundColor Green
Write-Host ""

# Change to dev directory
Set-Location "$PROJECT_ROOT/docker/dev"

# Build and start services
docker-compose up --build -d

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Development environment started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Services available at:"
Write-Host "  - Application:     http://localhost"
Write-Host "  - Frontend (HMR):  http://localhost:5173"
Write-Host "  - Backend API:     http://localhost:8080"
Write-Host "  - Java Debug Port: localhost:5005"
Write-Host "  - phpMyAdmin:      http://localhost:8081"
Write-Host "  - Redis Commander: http://localhost:8082"
Write-Host ""
Write-Host "Stack:"
Write-Host "  - Java 26"
Write-Host "  - Spring Boot 4.0.5"
Write-Host "  - Vue 3.5.31+"
Write-Host "  - MariaDB 11.4"
Write-Host "  - Redis 7"
Write-Host ""
Write-Host "Project initialized at:"
Write-Host "  - Backend:  $PROJECT_ROOT\backend"
Write-Host "  - Frontend: $PROJECT_ROOT\frontend"
Write-Host ""
Write-Host "To view logs: docker-compose -f docker/dev/docker-compose.yml logs -f"
Write-Host "To stop:      .\scripts\stop-and-clear.ps1"
Write-Host ""

Set-Location "$PROJECT_ROOT"
