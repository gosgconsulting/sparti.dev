# Bolt.DIY Production Deployment Script
# This script sets up and runs the Bolt.DIY application in production mode

param(
    [switch]$Setup,
    [switch]$Start,
    [switch]$Stop,
    [switch]$Restart,
    [switch]$Logs,
    [switch]$Status,
    [switch]$Help
)

function Show-Help {
    Write-Host "Bolt.DIY Production Deployment Script" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\deploy-production.ps1 -Setup    # Initial setup and environment check"
    Write-Host "  .\deploy-production.ps1 -Start    # Start the production environment"
    Write-Host "  .\deploy-production.ps1 -Stop     # Stop the production environment"
    Write-Host "  .\deploy-production.ps1 -Restart  # Restart the production environment"
    Write-Host "  .\deploy-production.ps1 -Logs     # Show application logs"
    Write-Host "  .\deploy-production.ps1 -Status   # Check service status"
    Write-Host "  .\deploy-production.ps1 -Help     # Show this help message"
    Write-Host ""
}

function Test-Prerequisites {
    Write-Host "[INFO] Checking prerequisites..." -ForegroundColor Blue
    
    # Check Docker
    try {
        $dockerVersion = docker --version
        Write-Host "[OK] Docker is installed: $dockerVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Docker is not installed or not accessible" -ForegroundColor Red
        exit 1
    }
    
    # Check Docker Compose
    try {
        $composeVersion = docker compose version
        Write-Host "[OK] Docker Compose is installed: $composeVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Docker Compose is not installed or not accessible" -ForegroundColor Red
        exit 1
    }
    
    # Check required files
    $requiredFiles = @("docker-compose.prod.yml", "production.env", "nginx.conf")
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Host "[OK] Found required file: $file" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Missing required file: $file" -ForegroundColor Red
            exit 1
        }
    }
}

function Setup-Environment {
    Write-Host "[INFO] Setting up production environment..." -ForegroundColor Blue
    
    Test-Prerequisites
    
    # Create SSL directory for certificates
    if (-not (Test-Path "ssl")) {
        New-Item -ItemType Directory -Path "ssl"
        Write-Host "[INFO] Created SSL directory. Please add your SSL certificates (cert.pem and key.pem)" -ForegroundColor Yellow
    }
    
    # Pull the latest image
    Write-Host "[INFO] Pulling the latest Docker image..." -ForegroundColor Blue
    docker pull ghcr.io/stackblitz-labs/bolt.diy:sha-bab9a64@sha256:17f2106b8dd6d9293d75492fbc01aea67b9c6b7e14c25717f6a05258e311bea7
    
    Write-Host "[INFO] Environment setup completed!" -ForegroundColor Green
    Write-Host "[INFO] Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Update production.env with your actual API keys"
    Write-Host "  2. Add SSL certificates to the ssl/ directory"
    Write-Host "  3. Run: .\deploy-production.ps1 -Start"
}

function Start-Production {
    Write-Host "[INFO] Starting production environment..." -ForegroundColor Blue
    Test-Prerequisites
    docker compose -f docker-compose.prod.yml up -d
    Write-Host "[INFO] Production environment started!" -ForegroundColor Green
    Write-Host "[INFO] Application should be available at:" -ForegroundColor Yellow
    Write-Host "  - HTTP:  http://localhost"
    Write-Host "  - HTTPS: https://localhost"
    Write-Host "  - Direct: http://localhost:5173"
}

function Stop-Production {
    Write-Host "[INFO] Stopping production environment..." -ForegroundColor Blue
    docker compose -f docker-compose.prod.yml down
    Write-Host "[INFO] Production environment stopped!" -ForegroundColor Green
}

function Restart-Production {
    Write-Host "[INFO] Restarting production environment..." -ForegroundColor Blue
    Stop-Production
    Start-Sleep -Seconds 3
    Start-Production
}

function Show-Logs {
    Write-Host "[INFO] Showing application logs..." -ForegroundColor Blue
    docker compose -f docker-compose.prod.yml logs -f
}

function Show-Status {
    Write-Host "[INFO] Checking service status..." -ForegroundColor Blue
    docker compose -f docker-compose.prod.yml ps
    Write-Host ""
    Write-Host "Container logs (last 10 lines):" -ForegroundColor Yellow
    docker compose -f docker-compose.prod.yml logs --tail=10
}

# Main script logic
if ($Help -or $args.Count -eq 0) {
    Show-Help
    exit 0
}

if ($Setup) {
    Setup-Environment
}
elseif ($Start) {
    Start-Production
}
elseif ($Stop) {
    Stop-Production
}
elseif ($Restart) {
    Restart-Production
}
elseif ($Logs) {
    Show-Logs
}
elseif ($Status) {
    Show-Status
}
else {
    Write-Host "[ERROR] Invalid option. Use -Help to see available options." -ForegroundColor Red
    exit 1
}
