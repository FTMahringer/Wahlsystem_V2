#!/bin/bash

# Start development environment
# Auto-initializes backend and frontend if needed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ============================================================================
# Helper Functions (must be defined before use)
# ============================================================================

initialize_backend() {
    BACKEND_DIR="$PROJECT_ROOT/backend"
    TEMPLATE_DIR="$SCRIPT_DIR/templates/backend"

    echo "Creating backend directory structure..."

    # Create directory structure
    mkdir -p "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem"/{config,controller,dto,entity,enums,exception,mapper,repository,security,service,validation,util}
    mkdir -p "$BACKEND_DIR/src/main/resources/db/migration"
    mkdir -p "$BACKEND_DIR/src/test/java/at/ftmahringer/wahlsystem"
    mkdir -p "$BACKEND_DIR/src/test/resources"

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

    # Copy application.yml
    echo "Creating application configuration..."
    cp "$TEMPLATE_DIR/application.yml" "$BACKEND_DIR/src/main/resources/application.yml"

    # Create main application class
    echo "Creating main application class..."
    cat > "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/WahlsystemApplication.java" << 'EOF'
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
EOF

    # Copy entities from templates
    echo "Creating entities..."
    cp "$TEMPLATE_DIR/entity/User.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/entity/User.java"
    cp "$TEMPLATE_DIR/entity/Admin.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/entity/Admin.java"
    cp "$TEMPLATE_DIR/entity/Teacher.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/entity/Teacher.java"
    cp "$TEMPLATE_DIR/entity/Student.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/entity/Student.java"

    # Copy enums from templates
    echo "Creating enums..."
    cp "$TEMPLATE_DIR/enums/UserRole.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/enums/UserRole.java"
    cp "$TEMPLATE_DIR/enums/ElectionStatus.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/enums/ElectionStatus.java"
    cp "$TEMPLATE_DIR/enums/ElectionType.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/enums/ElectionType.java"

    # Copy security classes from templates
    echo "Creating security configuration..."
    cp "$TEMPLATE_DIR/security/JwtConfig.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/security/JwtConfig.java"
    cp "$TEMPLATE_DIR/security/JwtTokenProvider.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/security/JwtTokenProvider.java"
    cp "$TEMPLATE_DIR/security/JwtAuthenticationFilter.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/security/JwtAuthenticationFilter.java"
    cp "$TEMPLATE_DIR/security/UserPrincipal.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/security/UserPrincipal.java"
    cp "$TEMPLATE_DIR/security/UserDetailsServiceImpl.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/security/UserDetailsServiceImpl.java"
    cp "$TEMPLATE_DIR/security/SecurityConfig.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/security/SecurityConfig.java"

    # Copy DTOs from templates
    echo "Creating DTOs..."
    cp "$TEMPLATE_DIR/dto/LoginRequest.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/dto/LoginRequest.java"
    cp "$TEMPLATE_DIR/dto/RegisterRequest.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/dto/RegisterRequest.java"
    cp "$TEMPLATE_DIR/dto/AuthResponse.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/dto/AuthResponse.java"
    cp "$TEMPLATE_DIR/dto/UserDto.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/dto/UserDto.java"

    # Copy repositories from templates
    echo "Creating repositories..."
    cp "$TEMPLATE_DIR/repository/UserRepository.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/repository/UserRepository.java"
    cp "$TEMPLATE_DIR/repository/AdminRepository.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/repository/AdminRepository.java"
    cp "$TEMPLATE_DIR/repository/TeacherRepository.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/repository/TeacherRepository.java"
    cp "$TEMPLATE_DIR/repository/StudentRepository.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/repository/StudentRepository.java"

    # Copy services from templates
    echo "Creating services..."
    cp "$TEMPLATE_DIR/service/AuthService.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/service/AuthService.java"

    # Copy controllers from templates
    echo "Creating controllers..."
    cp "$TEMPLATE_DIR/controller/AuthController.java" "$BACKEND_DIR/src/main/java/at/ftmahringer/wahlsystem/controller/AuthController.java"

    # Create Flyway migration
    echo "Creating database migrations..."
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
    cat > "$BACKEND_DIR/src/test/java/at/ftmahringer/wahlsystem/WahlsystemApplicationTests.java" << 'EOF'
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
}

initialize_frontend() {
    FRONTEND_DIR="$PROJECT_ROOT/frontend"
    TEMPLATE_DIR="$SCRIPT_DIR/templates/frontend"

    echo "Creating frontend directory structure..."

    # Create directory structure
    mkdir -p "$FRONTEND_DIR/src/"{api,assets,components/{common,admin,voter,auth},composables,layouts,router,stores,types,utils,views/{admin,voter,auth}}

    # Copy template files
    echo "Creating configuration files..."
    cp "$TEMPLATE_DIR/package.json" "$FRONTEND_DIR/package.json"
    cp "$TEMPLATE_DIR/vite.config.ts" "$FRONTEND_DIR/vite.config.ts"
    cp "$TEMPLATE_DIR/tsconfig.json" "$FRONTEND_DIR/tsconfig.json"
    cp "$TEMPLATE_DIR/tsconfig.node.json" "$FRONTEND_DIR/tsconfig.node.json"
    cp "$TEMPLATE_DIR/index.html" "$FRONTEND_DIR/index.html"
    cp "$TEMPLATE_DIR/App.vue" "$FRONTEND_DIR/src/App.vue"
    cp "$TEMPLATE_DIR/main.ts" "$FRONTEND_DIR/src/main.ts"
    cp "$TEMPLATE_DIR/router.ts" "$FRONTEND_DIR/src/router/index.ts"
    cp "$TEMPLATE_DIR/env.d.ts" "$FRONTEND_DIR/src/env.d.ts"

    # Create .env files
    echo "Creating environment files..."
    cat > "$FRONTEND_DIR/.env.development" << 'EOF'
VITE_API_BASE_URL=http://localhost:8080/api/v1
VITE_APP_NAME=Wahlsystem
VITE_APP_ENV=development
EOF

    cat > "$FRONTEND_DIR/.env.production" << 'EOF'
VITE_API_BASE_URL=/api/v1
VITE_APP_NAME=Wahlsystem
VITE_APP_ENV=production
EOF

    # Copy types from templates
    echo "Creating TypeScript types..."
    cp "$TEMPLATE_DIR/src/types/auth.ts" "$FRONTEND_DIR/src/types/auth.ts"
    cp "$TEMPLATE_DIR/src/types/election.ts" "$FRONTEND_DIR/src/types/election.ts"
    cp "$TEMPLATE_DIR/src/types/candidate.ts" "$FRONTEND_DIR/src/types/candidate.ts"
    cp "$TEMPLATE_DIR/src/types/vote.ts" "$FRONTEND_DIR/src/types/vote.ts"
    cp "$TEMPLATE_DIR/src/types/index.ts" "$FRONTEND_DIR/src/types/index.ts"

    # Copy API layer from templates
    echo "Creating API layer..."
    cp "$TEMPLATE_DIR/src/api/axios.ts" "$FRONTEND_DIR/src/api/axios.ts"
    cp "$TEMPLATE_DIR/src/api/authApi.ts" "$FRONTEND_DIR/src/api/authApi.ts"
    cp "$TEMPLATE_DIR/src/api/electionApi.ts" "$FRONTEND_DIR/src/api/electionApi.ts"
    cp "$TEMPLATE_DIR/src/api/candidateApi.ts" "$FRONTEND_DIR/src/api/candidateApi.ts"
    cp "$TEMPLATE_DIR/src/api/voteApi.ts" "$FRONTEND_DIR/src/api/voteApi.ts"
    cp "$TEMPLATE_DIR/src/api/index.ts" "$FRONTEND_DIR/src/api/index.ts"

    # Copy stores from templates
    echo "Creating Pinia stores..."
    cp "$TEMPLATE_DIR/src/stores/authStore.ts" "$FRONTEND_DIR/src/stores/authStore.ts"

    # Copy views from templates
    echo "Creating views..."
    cp "$TEMPLATE_DIR/src/views/auth/LoginView.vue" "$FRONTEND_DIR/src/views/auth/LoginView.vue"
    cp "$TEMPLATE_DIR/src/views/auth/RegisterView.vue" "$FRONTEND_DIR/src/views/auth/RegisterView.vue"
    cp "$TEMPLATE_DIR/src/views/voter/VoterLoginView.vue" "$FRONTEND_DIR/src/views/voter/VoterLoginView.vue"
    cp "$TEMPLATE_DIR/src/views/voter/VoterElectionView.vue" "$FRONTEND_DIR/src/views/voter/VoterElectionView.vue"
    cp "$TEMPLATE_DIR/src/views/admin/AdminLoginView.vue" "$FRONTEND_DIR/src/views/admin/AdminLoginView.vue"
    cp "$TEMPLATE_DIR/src/views/admin/AdminDashboardView.vue" "$FRONTEND_DIR/src/views/admin/AdminDashboardView.vue"
    cp "$TEMPLATE_DIR/src/views/admin/AdminElectionsView.vue" "$FRONTEND_DIR/src/views/admin/AdminElectionsView.vue"

    # Install npm dependencies
    echo "Installing npm dependencies..."
    cd "$FRONTEND_DIR"
    npm install
    cd "$PROJECT_ROOT"

    echo ""
    echo "========================================"
    echo "Frontend initialization complete!"
    echo "========================================"
}

# ============================================================================
# Main Script
# ============================================================================

echo "========================================"
echo "Wahlsystem Development Environment"
echo "========================================"
echo ""

# Check if .env exists
if [ ! -f "$PROJECT_ROOT/docker/dev/.env" ]; then
    echo "Error: docker/dev/.env not found!"
    echo "Please copy .env.example to docker/dev/.env and configure it."
    exit 1
fi

# Initialize backend if needed
if [ ! -f "$PROJECT_ROOT/backend/pom.xml" ]; then
    echo "Backend not initialized. Initializing..."
    initialize_backend
    echo ""
fi

# Initialize frontend if needed
if [ ! -f "$PROJECT_ROOT/frontend/package.json" ]; then
    echo "Frontend not initialized. Initializing..."
    initialize_frontend
    echo ""
fi

echo "Starting Docker containers..."
echo ""

# Change to dev directory
cd "$PROJECT_ROOT/docker/dev"

# Build and start services
docker-compose up --build -d

echo ""
echo "========================================"
echo "Development environment started!"
echo "========================================"
echo ""
echo "Services available at:"
echo "  - Frontend (HMR):  http://localhost:5173"
echo "  - Backend API:     http://localhost:8080"
echo "  - Java Debug Port: localhost:5005"
echo "  - phpMyAdmin:      http://localhost:8081"
echo "  - Redis Commander: http://localhost:8082"
echo ""
echo "Stack:"
echo "  - Java 26"
echo "  - Spring Boot 4.0.5"
echo "  - Vue 3.5.31+"
echo "  - MariaDB 11.4"
echo "  - Redis 7"
echo ""
echo "Project initialized at:"
echo "  - Backend:  $PROJECT_ROOT/backend"
echo "  - Frontend: $PROJECT_ROOT/frontend"
echo ""
echo "To view logs: docker-compose -f docker/dev/docker-compose.yml logs -f"
echo "To stop:      ./scripts/stop-and-clear.sh"
echo ""
echo ""
