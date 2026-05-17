# ============================================================
# check-prerequisites.ps1
# Checks and installs prerequisites for the Secure Leave
# Management System microservices project.
# Run as Administrator for automatic installs.
# ============================================================

param(
    [switch]$AutoInstall   # Pass -AutoInstall to attempt auto-install of missing tools
)

$ErrorActionPreference = "Continue"

# ---- Helpers ------------------------------------------------
function Write-Header($msg) {
    Write-Host "`n======================================" -ForegroundColor Cyan
    Write-Host "  $msg" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
}

function Write-OK($msg)   { Write-Host "  [OK]  $msg" -ForegroundColor Green  }
function Write-FAIL($msg) { Write-Host "  [MISSING] $msg" -ForegroundColor Red }
function Write-WARN($msg) { Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Write-INFO($msg) { Write-Host "  [INFO] $msg" -ForegroundColor Gray   }

function Test-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Get-WingetApp($id, $name) {
    if (-not (Test-Command "winget")) {
        Write-WARN "winget not available — install $name manually."
        return
    }
    Write-INFO "Installing $name via winget..."
    winget install --id $id --silent --accept-package-agreements --accept-source-agreements
}

$issues = @()

# ============================================================
Write-Header "1. Git"
# ============================================================
if (Test-Command "git") {
    $v = git --version
    Write-OK "git installed: $v"
} else {
    Write-FAIL "git not found"
    $issues += "git"
    if ($AutoInstall) { Get-WingetApp "Git.Git" "Git" }
}

# ============================================================
Write-Header "2. Java 17 (JDK)"
# ============================================================
$javaOk = $false
if (Test-Command "java") {
    $jv = java -version 2>&1 | Select-String "version"
    Write-OK "java found: $jv"
    if ($jv -match '"17') { $javaOk = $true; Write-OK "Java 17 confirmed" }
    elseif ($jv -match '"21') { $javaOk = $true; Write-WARN "Java 21 found (17 preferred but 21 works)" }
    else { Write-WARN "Java version is not 17 — project targets Java 17" }
} else {
    Write-FAIL "java not found"
    $issues += "Java 17 JDK"
    if ($AutoInstall) { Get-WingetApp "EclipseAdoptium.Temurin.17.JDK" "Eclipse Temurin JDK 17" }
}

# Check JAVA_HOME
if ($env:JAVA_HOME) {
    Write-OK "JAVA_HOME set: $env:JAVA_HOME"
} else {
    Write-WARN "JAVA_HOME environment variable is not set"
    Write-INFO "Set JAVA_HOME to your JDK folder, e.g.:"
    Write-INFO '  $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17"'
    Write-INFO '  $env:PATH += ";$env:JAVA_HOME\bin"'
}

# ============================================================
Write-Header "3. Maven"
# ============================================================
if (Test-Command "mvn") {
    $mv = mvn --version | Select-Object -First 1
    Write-OK "Maven installed: $mv"
} else {
    Write-FAIL "mvn not found"
    $issues += "Apache Maven"
    if ($AutoInstall) { Get-WingetApp "Apache.Maven" "Apache Maven" }
    else {
        Write-INFO "Install Maven: https://maven.apache.org/download.cgi"
        Write-INFO "Or use the included mvnw wrapper instead: .\mvnw package"
    }
}

# ============================================================
Write-Header "4. Docker Desktop"
# ============================================================
if (Test-Command "docker") {
    $dv = docker --version
    Write-OK "Docker installed: $dv"

    # Check Docker daemon running
    $dockerRunning = docker info 2>&1 | Select-String "Server Version"
    if ($dockerRunning) {
        Write-OK "Docker daemon is running"
    } else {
        Write-WARN "Docker is installed but the daemon is NOT running — start Docker Desktop"
        $issues += "Docker daemon (not running)"
    }
} else {
    Write-FAIL "docker not found"
    $issues += "Docker Desktop"
    if ($AutoInstall) { Get-WingetApp "Docker.DockerDesktop" "Docker Desktop" }
    else { Write-INFO "Install Docker Desktop: https://www.docker.com/products/docker-desktop/" }
}

# Check Docker Compose
if (Test-Command "docker") {
    $dcv = docker compose version 2>&1
    if ($dcv -match "Docker Compose version") {
        Write-OK "Docker Compose (v2 plugin): $dcv"
    } else {
        Write-WARN "docker compose v2 not detected — ensure Docker Desktop is up to date"
    }
}

# ============================================================
Write-Header "5. Port Availability"
# ============================================================
$ports = @{
    8080 = "API Gateway"
    8761 = "Eureka Discovery Server"
    9092 = "Kafka"
    2181 = "Zookeeper"
    3306 = "MySQL (leave-request-db)"
    3307 = "MySQL (leave-tracking-db)"
    3308 = "MySQL (personnel-info-db)"
}

foreach ($port in $ports.Keys) {
    $inUse = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($inUse) {
        Write-WARN "Port $port ($($ports[$port])) is already in use!"
        $issues += "Port $port in use"
    } else {
        Write-OK "Port $port ($($ports[$port])) is free"
    }
}

# ============================================================
Write-Header "6. RAM Check"
# ============================================================
$ram = (Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB
$ramRounded = [math]::Round($ram, 1)
if ($ram -ge 8) {
    Write-OK "${ramRounded}GB RAM available — sufficient (8 GB minimum recommended)"
} else {
    Write-WARN "${ramRounded}GB RAM — less than 8 GB. Docker services may be slow or crash."
    $issues += "RAM < 8 GB"
}

# ============================================================
Write-Header "7. Disk Space"
# ============================================================
$disk = Get-PSDrive C | Select-Object -ExpandProperty Free
$diskGB = [math]::Round($disk / 1GB, 1)
if ($diskGB -ge 10) {
    Write-OK "${diskGB}GB free on C: — sufficient"
} else {
    Write-WARN "${diskGB}GB free on C: — low disk space may cause Docker image pull failures"
    $issues += "Low disk space"
}

# ============================================================
Write-Header "Summary"
# ============================================================
if ($issues.Count -eq 0) {
    Write-Host "`n  All prerequisites satisfied! You can start the project." -ForegroundColor Green
    Write-Host "`n  To start the application, run from the project directory:" -ForegroundColor Cyan
    Write-Host '    docker compose up -d' -ForegroundColor White
    Write-Host "`n  Then open: http://localhost:8080/ui/auth" -ForegroundColor Cyan
} else {
    Write-Host "`n  Issues found ($($issues.Count)):" -ForegroundColor Red
    $issues | ForEach-Object { Write-Host "    - $_" -ForegroundColor Yellow }
    Write-Host "`n  Fix the above issues, then re-run this script." -ForegroundColor Yellow
    if (-not $AutoInstall) {
        Write-Host "`n  TIP: Run with -AutoInstall to attempt automatic installation:" -ForegroundColor Cyan
        Write-Host "    .\check-prerequisites.ps1 -AutoInstall" -ForegroundColor White
    }
}
Write-Host ""
