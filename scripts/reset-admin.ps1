#!/usr/bin/env pwsh
# reset-admin.ps1 — Insert/reset the default admin user directly in the database.
# Reads password hashing settings from the running backend container first so the
# generated hash matches the active backend configuration.
# Usage: .\scripts\reset-admin.ps1

param(
    [string]$BackendContainer = "Wahlsystem-backend-dev",
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

# ── Read password hashing config ───────────────────────────────────────────────
$envFile = Join-Path $PSScriptRoot "..\docker\dev\.env"
$algorithm = "bcrypt"
$pepper  = ""
$strength = "12"
$configSource = "defaults"

if ($BackendContainer) {
    $containerEnv = docker exec $BackendContainer /bin/sh -c "env" 2>$null
    if ($LASTEXITCODE -eq 0 -and $containerEnv) {
        $configSource = "backend container"
        $containerEnv | ForEach-Object {
            if ($_ -match '^PASSWORD_ALGORITHM=(.+)$') {
                $algorithm = $matches[1].Trim()
            }
            if ($_ -match '^PASSWORD_PEPPER=(.*)$') {
                $pepper = $matches[1].Trim()
            }
            if ($_ -match '^PASSWORD_BCRYPT_STRENGTH=(\d+)$') {
                $strength = $matches[1].Trim()
            }
        }
    }
}

if ($configSource -eq "defaults" -and (Test-Path $envFile)) {
    $configSource = "docker/dev/.env"
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*PASSWORD_ALGORITHM\s*=\s*(.+)$') {
            $algorithm = $matches[1].Trim()
        }
        if ($_ -match '^\s*PASSWORD_PEPPER\s*=\s*(.*)$') {
            $pepper = $matches[1].Trim()
        }
        if ($_ -match '^\s*PASSWORD_BCRYPT_STRENGTH\s*=\s*(\d+)$') {
            $strength = $matches[1].Trim()
        }
    }
}

if ($algorithm -ne "bcrypt") {
    Write-Host "ERROR: reset-admin.ps1 currently supports only PASSWORD_ALGORITHM=bcrypt." -ForegroundColor Red
    Write-Host "Active algorithm: $algorithm (from $configSource)" -ForegroundColor Red
    Write-Host "Either switch the dev profile to bcrypt for this script or extend hash-util to the selected algorithm." -ForegroundColor Yellow
    exit 1
}

Write-Host "  Config   : $configSource" -ForegroundColor Cyan
Write-Host "  Algorithm: $algorithm"
if ($pepper) {
    Write-Host "  Pepper   : configured" -ForegroundColor Cyan
} else {
    Write-Host "  Pepper   : not set (hash will be plain bcrypt)" -ForegroundColor Yellow
}
Write-Host "  Strength : $strength"
Write-Host "  Salt     : managed inside the bcrypt hash (no separate DB column)"
Write-Host ""

# ── Generate hash using hash-util ─────────────────────────────────────────────
$hashUtil = Join-Path $PSScriptRoot "hash-util\hash.mjs"
if (-not (Test-Path $hashUtil)) {
    Write-Host "ERROR: hash-util not found at $hashUtil" -ForegroundColor Red
    exit 1
}

Write-Host "Generating password hash..." -ForegroundColor Cyan
$bcryptHash = node $hashUtil $Password $pepper $algorithm $strength

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
