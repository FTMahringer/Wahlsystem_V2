#!/usr/bin/env pwsh
# reset-admin.ps1 — Insert/reset the default admin user directly in the database
# Usage: .\scripts\reset-admin.ps1

param(
    [string]$Container   = "Wahlsystem-mariadb-dev",
    [string]$DbName      = "myapp_db",
    [string]$DbUser      = "root",
    [string]$DbPassword  = "dev_root_password_123"
)

Write-Host ""
Write-Host "========================================"
Write-Host "  Wahlsystem — Reset Default Admin"
Write-Host "========================================"
Write-Host ""

# bcrypt hash of "admin123" (cost 10, generated via bcryptjs)
$bcryptHash = '$2b$10$15LVKujaNqKA/SU5MoSCkuAyedWr0zBwHbmpXJFpsLbV1q4XFOACG'

$sql = @"
INSERT INTO users (username, email, password, first_name, last_name, role, user_type, active, email_verified)
VALUES ('admin', 'admin@wahlsystem.local', '$bcryptHash', 'System', 'Administrator', 'ADMIN', 'ADMIN', TRUE, TRUE)
ON DUPLICATE KEY UPDATE
    password       = VALUES(password),
    active         = TRUE,
    email_verified = TRUE;

SET @uid = (SELECT id FROM users WHERE username = 'admin');

INSERT INTO admins (user_id, admin_level, can_manage_users, can_manage_elections, can_view_all_results)
VALUES (@uid, 1, TRUE, TRUE, TRUE)
ON DUPLICATE KEY UPDATE
    admin_level           = 1,
    can_manage_users      = TRUE,
    can_manage_elections  = TRUE,
    can_view_all_results  = TRUE;

SELECT CONCAT('Admin user ready — username: admin  password: admin123') AS result;
"@

Write-Host "Connecting to container '$Container'..." -ForegroundColor Cyan

try {
    $output = docker exec -i $Container `
        mariadb -u $DbUser -p"$DbPassword" $DbName -e $sql 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: SQL execution failed." -ForegroundColor Red
        Write-Host $output -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "========================================"
    Write-Host "  Done!" -ForegroundColor Green
    Write-Host "========================================"
    Write-Host ""
    Write-Host "  Username : admin"
    Write-Host "  Password : admin123"
    Write-Host "  Role     : ADMIN"
    Write-Host ""
    Write-Host "Login at: http://localhost:5173/admin/login" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Change this password after logging in!" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "ERROR: Could not connect to Docker container." -ForegroundColor Red
    Write-Host "Make sure the dev environment is running: .\scripts\start-dev.ps1" -ForegroundColor Red
    exit 1
}
