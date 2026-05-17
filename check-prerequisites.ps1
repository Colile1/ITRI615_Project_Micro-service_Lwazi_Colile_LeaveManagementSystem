# check-prerequisites.ps1
# Checks and installs prerequisites for the Secure Leave Management System project.
# Run as Administrator for automatic installs.

param(
    [switch]$AutoInstall
)

$ErrorActionPreference = "Continue"

function Write-Header($msg) {
    Write-Host "`n======================================" -ForegroundColor Cyan
    Write-Host "  $msg" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
}
function Write-OK($msg)   { Write-Host "  [OK]      $msg" -ForegroundColor Green  }
function Write-FAIL($msg) { Write-Host "  [MISSING] $msg" -ForegroundColor Red    }
function Write-WARN($msg) { Write-Host "  [WARN]    $msg" -ForegroundColor Yellow }
function Write-INFO($msg) { Write-Host "  [INFO]    $msg" -ForegroundColor Gray   }

function Test-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Install-WithWinget($id, $name) {
    if (-not (Test-Command "winget")) {
        Write-WARN "winget not available -- install $name manually."
        return
    }
    Write-INFO "Installing $name via winget..."
    winget install --id $id --silent --accept-package-agreements --accept-source-agreements
}

$issues = @()

Write-Header "1. Git"
if (Test-Command "git") {
    $v = git --version
    Write-OK "git installed: $v"
} else {
    Write-FAIL "git not found"
    $issues += "git"
    if ($AutoInstall) { Install-WithWinget "Git.Git" "Git" }
}

Write-Header "2. Java 17 (JDK)"
if (Test-Command "java") {
    $jv = java -version 2>&1 | Select-String "version" | Select-Object -First 1
    Write-OK "java found: $jv"
    if ($jv -match '"17') {
        Write-OK "Java 17 confirmed"
    } elseif ($jv -match '"21') {
        Write-WARN "Java 21 found (17 preferred but 21 works)"
    } else {
        Write-WARN "Java version may not be 17 -- project targets Java 17"
    }
} else {
    Write-FAIL "java not found"
    $issues += "Java 17 JDK"
    if ($AutoInstall) { Install-WithWinget "EclipseAdoptium.Temurin.17.JDK" "Eclipse Temurin JDK 17" }
    else { Write-INFO "Download: https://adoptium.net/temurin/releases/?version=17" }
}

if ($env:JAVA_HOME) {
    Write-OK "JAVA_HOME set: $env:JAVA_HOME"
} else {
    Write-WARN "JAVA_HOME is not set"
    Write-INFO 'Set it with: $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17..."'
}

Write-Header "3. Maven"
if (Test-Command "mvn") {
    $mv = mvn --version | Select-Object -First 1
    Write-OK "Maven installed: $mv"
} else {
    Write-FAIL "mvn not found"
    $issues += "Apache Maven"
    if ($AutoInstall) { Install-WithWinget "Apache.Maven" "Apache Maven" }
    else { Write-INFO "Download: https://maven.apache.org/download.cgi" }
}

Write-Header "4. Docker Desktop"
if (Test-Command "docker") {
    $dv = docker --version
    Write-OK "Docker installed: $dv"
    $dockerRunning = docker info 2>&1 | Select-String "Server Version"
    if ($dockerRunning) {
        Write-OK "Docker daemon is running"
    } else {
        Write-WARN "Docker installed but daemon NOT running -- start Docker Desktop"
        $issues += "Docker daemon (not running)"
    }
    $dcv = docker compose version 2>&1
    if ($dcv -match "Docker Compose version") {
        Write-OK "Docker Compose v2: $dcv"
    } else {
        Write-WARN "docker compose v2 not detected -- update Docker Desktop"
    }
} else {
    Write-FAIL "docker not found"
    $issues += "Docker Desktop"
    if ($AutoInstall) { Install-WithWinget "Docker.DockerDesktop" "Docker Desktop" }
    else { Write-INFO "Download: https://www.docker.com/products/docker-desktop/" }
}

Write-Header "5. Port Availability"
$ports = [ordered]@{
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
        Write-WARN "Port $port ($($ports[$port])) is already IN USE"
        $issues += "Port $port in use"
    } else {
        Write-OK "Port $port ($($ports[$port])) is free"
    }
}

Write-Header "6. RAM"
$ramGB = [math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1GB, 1)
if ($ramGB -ge 8) {
    Write-OK "${ramGB} GB RAM -- sufficient (8 GB minimum recommended)"
} else {
    Write-WARN "${ramGB} GB RAM -- less than 8 GB. Services may be slow."
    $issues += "RAM < 8 GB"
}

Write-Header "7. Disk Space (C:)"
$diskGB = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
if ($diskGB -ge 10) {
    Write-OK "${diskGB} GB free -- sufficient"
} else {
    Write-WARN "${diskGB} GB free -- low disk space may affect Docker image pulls"
    $issues += "Low disk space on C:"
}

Write-Header "Summary"
if ($issues.Count -eq 0) {
    Write-Host "`n  All prerequisites satisfied! Ready to start the project." -ForegroundColor Green
    Write-Host "`n  From the project directory, run:" -ForegroundColor Cyan
    Write-Host "    docker compose up -d" -ForegroundColor White
    Write-Host "`n  Then open your browser at: http://localhost:8080/ui/auth" -ForegroundColor Cyan
} else {
    Write-Host "`n  Issues found ($($issues.Count)):" -ForegroundColor Red
    $issues | ForEach-Object { Write-Host "    - $_" -ForegroundColor Yellow }
    Write-Host "`n  Fix the above, then re-run this script." -ForegroundColor Yellow
    if (-not $AutoInstall) {
        Write-Host "`n  TIP: Run with -AutoInstall to attempt auto-install:" -ForegroundColor Cyan
        Write-Host "    .\check-prerequisites.ps1 -AutoInstall" -ForegroundColor White
    }
}
Write-Host ""
