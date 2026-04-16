#!/usr/bin/env pwsh
# reset-admin.ps1 — Insert/reset the default admin user directly in the database.
# Reads the pepper from docker/dev/.env so the hash is correct for the current config.
# Usage: .\scripts\reset-admin.ps1

param(
    [string]$Container  = "Wahlsystem-mariadb-dev",
    [string]$DbName     = "myapp_db",
    [string]$DbUser     = "root",
    [string]$DbPassword = "dev_root_password_123",
    [string]$Password   = "admin123"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host "  Wahlsystem — Reset Default Admin"
Write-Host "========================================"
Write-Host ""

# ── Read pepper and bcrypt strength from dev .env ─────────────────────────────
$envFile = Join-Path $PSScriptRoot "..\docker\dev\.env"
$pepper  = ""
$strength = "12"

if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*PASSWORD_PEPPER\s*=\s*(.+)$')       { $pepper   = $matches[1].Trim() }
        if ($_ -match '^\s*PASSWORD_BCRYPT_STRENGTH\s*=\s*(\d+)$') { $strength = $matches[1].Trim() }
    }
}

if ($pepper) {
    Write-Host "  Pepper   : configured (from docker/dev/.env)" -ForegroundColor Cyan
} else {
    Write-Host "  Pepper   : not set (hash will be plain bcrypt)" -ForegroundColor Yellow
}
Write-Host "  Strength : $strength"
Write-Host ""

# ── Generate hash using hash-util ─────────────────────────────────────────────
$hashUtil = Join-Path $PSScriptRoot "hash-util\hash.mjs"
if (-not (Test-Path $hashUtil)) {
    Write-Host "ERROR: hash-util not found at $hashUtil" -ForegroundColor Red
    exit 1
}

Write-Host "Generating password hash..." -ForegroundColor Cyan
$bcryptHash = node $hashUtil $Password $pepper "bcrypt" $strength

if (-not $bcryptHash) {
    Write-Host "ERROR: Failed to generate hash." -ForegroundColor Red
    exit 1
}

# ── Insert into database ───────────────────────────────────────────────────────
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
    admin_level          = 1,
    can_manage_users     = TRUE,
    can_manage_elections = TRUE,
    can_view_all_results = TRUE;

SELECT 'Admin user ready.' AS result;
"@

Write-Host "Connecting to container '$Container'..." -ForegroundColor Cyan

$output = docker exec -i $Container mariadb -u $DbUser -p"$DbPassword" $DbName -e $sql 2>&1

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
Write-Host "  Password : $Password"
Write-Host "  Role     : ADMIN"
Write-Host ""
Write-Host "Login at: http://localhost:5173/admin/login" -ForegroundColor Cyan
Write-Host ""
Write-Host "Change this password after logging in!" -ForegroundColor Yellow
Write-Host ""
