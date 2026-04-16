#!/usr/bin/env pwsh
# create-admin.ps1 — Create a new admin user via the API
# Usage: .\scripts\create-admin.ps1

param(
    [string]$ApiBase = "http://localhost:8080/api/v1"
)

Write-Host ""
Write-Host "========================================"
Write-Host "  Wahlsystem — Create Admin User"
Write-Host "========================================"
Write-Host ""

# ── Step 1: New admin credentials ─────────────────────────────────────────────
Write-Host "Enter details for the new admin user:"
Write-Host ""

$newUsername  = Read-Host "  Username"
$newEmail     = Read-Host "  Email"
$newFirstName = Read-Host "  First name"
$newLastName  = Read-Host "  Last name"
$newPassword  = Read-Host "  Password" -AsSecureString
$newPassword2 = Read-Host "  Confirm password" -AsSecureString

# Compare passwords
$p1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword))
$p2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newPassword2))

if ($p1 -ne $p2) {
    Write-Host ""
    Write-Host "ERROR: Passwords do not match." -ForegroundColor Red
    exit 1
}
if ($p1.Length -lt 8) {
    Write-Host ""
    Write-Host "ERROR: Password must be at least 8 characters." -ForegroundColor Red
    exit 1
}

Write-Host ""

# ── Step 2: Login with existing admin to get JWT ───────────────────────────────
Write-Host "Authenticate with an existing admin account to authorize this action:"
Write-Host "(Default admin: admin / admin123)"
Write-Host ""

$authUsername = Read-Host "  Existing admin username"
$authPassword = Read-Host "  Existing admin password" -AsSecureString
$authPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($authPassword))

Write-Host ""
Write-Host "Logging in..." -ForegroundColor Cyan

try {
    $loginBody = @{
        username = $authUsername
        password = $authPasswordPlain
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod `
        -Uri "$ApiBase/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop

    $token = $loginResponse.token
    Write-Host "  Login successful." -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    Write-Host ""
    Write-Host "ERROR: Login failed (HTTP $statusCode). Check your credentials and make sure the backend is running." -ForegroundColor Red
    exit 1
}

# ── Step 3: Create the new admin user ─────────────────────────────────────────
Write-Host "Creating admin user '$newUsername'..." -ForegroundColor Cyan

try {
    $createBody = @{
        username  = $newUsername
        email     = $newEmail
        password  = $p1
        firstName = $newFirstName
        lastName  = $newLastName
        role      = "ADMIN"
    } | ConvertTo-Json

    $createResponse = Invoke-RestMethod `
        -Uri "$ApiBase/auth/register/admin" `
        -Method POST `
        -ContentType "application/json" `
        -Headers @{ Authorization = "Bearer $token" } `
        -Body $createBody `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "========================================"
    Write-Host "  Admin user created successfully!" -ForegroundColor Green
    Write-Host "========================================"
    Write-Host ""
    Write-Host "  Username : $newUsername"
    Write-Host "  Email    : $newEmail"
    Write-Host "  Name     : $newFirstName $newLastName"
    Write-Host "  Role     : ADMIN"
    Write-Host ""
    Write-Host "You can now log in at http://localhost:5173/admin/login" -ForegroundColor Cyan
    Write-Host ""
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $errorBody  = $_.ErrorDetails.Message

    Write-Host ""
    Write-Host "ERROR: Failed to create user (HTTP $statusCode)." -ForegroundColor Red
    if ($errorBody) {
        Write-Host "  Details: $errorBody" -ForegroundColor Red
    }
    exit 1
}
