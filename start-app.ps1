#Requires -Version 5.1
<#
.SYNOPSIS
    Start the Secure Leave Management System -- fully automated with guided prompts.
.DESCRIPTION
    Checks prerequisites, collects required secrets, cleans stale Docker state,
    pulls images, starts all containers, waits for health checks, and opens the
    UI in the browser. Run from the ITRI615_Project_Micro-service directory.
.EXAMPLE
    .\start-app.ps1                  # full run (pulls images)
    .\start-app.ps1 -SkipPull        # use cached images (faster on re-runs)
    .\start-app.ps1 -MonitoringStack # also start Prometheus + Grafana
    .\start-app.ps1 -StopAll         # stop and remove all containers
#>
param(
    [switch]$SkipPull,
    [switch]$MonitoringStack,
    [switch]$StopAll
)

# PS 5.1: never use 2>&1 on native exes -- stderr becomes ErrorRecords even on success.
# Use Continue + check $LASTEXITCODE instead.
$ErrorActionPreference = 'Continue'

# ---------------------------------------------------------------------------
# Add Docker bin to PATH if missing (Docker Desktop doesn't always propagate it)
# ---------------------------------------------------------------------------
$dockerBin = 'C:\Program Files\Docker\Docker\resources\bin'
if ((Test-Path $dockerBin) -and ($env:PATH -notlike "*Docker*resources*bin*")) {
    $env:PATH = "$dockerBin;$env:PATH"
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-Header { param($msg) Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Write-Step   { param($msg) Write-Host "  > $msg"      -ForegroundColor White }
function Write-OK     { param($msg) Write-Host "  [OK]   $msg" -ForegroundColor Green }
function Write-Warn   { param($msg) Write-Host "  [WARN] $msg" -ForegroundColor Yellow }
function Write-Fail   { param($msg) Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Write-Info   { param($msg) Write-Host "  $msg"        -ForegroundColor DarkGray }

# Invoke docker and capture stdout; stderr goes to console as-is (progress messages).
function Invoke-Docker {
    param([string[]]$DockerArgs)
    & docker @DockerArgs
}

# ---------------------------------------------------------------------------
# Locate project files
# ---------------------------------------------------------------------------
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ComposeDir  = Join-Path $ScriptDir 'Secure Leave Management System_2'
$ComposeFile = Join-Path $ComposeDir 'docker-compose.yml'
$EnvFile     = Join-Path $ComposeDir '.env'

if (-not (Test-Path $ComposeFile)) {
    Write-Fail "docker-compose.yml not found at: $ComposeFile"
    Write-Fail "Run this script from the ITRI615_Project_Micro-service directory."
    exit 1
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '  +----------------------------------------------------------+' -ForegroundColor Cyan
Write-Host '  |   Secure Leave Management System -- Startup Script      |' -ForegroundColor Cyan
Write-Host '  |   ITRI615 Computer Security 1                           |' -ForegroundColor Cyan
Write-Host '  +----------------------------------------------------------+' -ForegroundColor Cyan
Write-Host ''

# ---------------------------------------------------------------------------
# -StopAll mode -- no prompts needed
# ---------------------------------------------------------------------------
if ($StopAll) {
    Write-Header 'Stopping All Containers'
    Push-Location $ComposeDir
    & docker compose down --remove-orphans
    Pop-Location
    Write-OK 'All containers stopped and removed.'
    exit 0
}

# ===========================================================================
# STEP 1 -- Prerequisites
# ===========================================================================
Write-Header 'Step 1: Checking Prerequisites'

# Docker CLI available?
$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerCmd) {
    Write-Fail 'docker is not in PATH.'
    Write-Info "Expected location: $dockerBin\docker.exe"
    Write-Info 'Install Docker Desktop: https://www.docker.com/products/docker-desktop/'
    exit 1
}
$dockerVer = & docker --version
Write-OK "Docker CLI: $dockerVer"

# Docker daemon running?
Write-Step 'Checking Docker daemon...'
& docker info | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Warn 'Docker daemon is not running. Trying to start Docker Desktop...'
    $desktopExe = 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
    if (Test-Path $desktopExe) {
        Start-Process $desktopExe
        $waited = 0
        $daemonUp = $false
        while ($waited -lt 90) {
            Start-Sleep -Seconds 6
            $waited += 6
            & docker info | Out-Null
            if ($LASTEXITCODE -eq 0) { $daemonUp = $true; break }
            Write-Info "    ...waiting for daemon ($waited s)"
        }
        if (-not $daemonUp) {
            Write-Fail 'Docker daemon did not start. Open Docker Desktop manually and re-run.'
            exit 1
        }
    } else {
        Write-Fail 'Docker Desktop not found. Please install it and re-run.'
        exit 1
    }
}
Write-OK 'Docker daemon is running.'

# Disk space
$freeGB = [math]::Round((Get-PSDrive C).Free / 1GB, 1)
if ($freeGB -lt 5) {
    Write-Warn "Only $freeGB GB free on C:. Docker images need ~5 GB."
    Write-Info 'Tip: Docker Desktop -> Troubleshoot -> Clean / Purge data frees space.'
    $ans = Read-Host '  Continue anyway? (y/N)'
    if ($ans -ne 'y' -and $ans -ne 'Y') { exit 1 }
} else {
    Write-OK "$freeGB GB free on C: -- sufficient."
}

# ===========================================================================
# STEP 2 -- Environment / Secrets
# ===========================================================================
Write-Header 'Step 2: Environment Configuration'

# Load existing .env
$envVars = @{}
if (Test-Path $EnvFile) {
    Write-Step 'Loading existing .env...'
    Get-Content $EnvFile | Where-Object { $_ -match '^\s*\w+=' } | ForEach-Object {
        $parts = $_ -split '=', 2
        if ($parts.Count -eq 2) { $envVars[$parts[0].Trim()] = $parts[1].Trim() }
    }
    Write-OK ".env loaded ($($envVars.Count) variables)"
} else {
    Write-Warn '.env not found -- you will be prompted for required values.'
    Write-Info "Values will be saved to $EnvFile for future runs."
}

function Read-EnvVar {
    param(
        [string]$Key,
        [string]$Prompt,
        [string]$Default = '',
        [switch]$Secret
    )
    if ($envVars.ContainsKey($Key) -and $envVars[$Key] -ne '') {
        Write-OK "$Key is set."
        return $envVars[$Key]
    }
    if ($Default -ne '') {
        Write-Warn "$Key not set. Press Enter to use default, or type a value."
    } else {
        Write-Warn "$Key is required."
    }
    if ($Secret) {
        $ss   = Read-Host "  $Prompt" -AsSecureString
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss)
        $val  = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    } else {
        $val = Read-Host "  $Prompt"
    }
    if ($val -eq '' -and $Default -ne '') { $val = $Default }
    if ($val -eq '') { Write-Fail "$Key cannot be empty."; exit 1 }
    return $val
}

$autoSecret = [System.Guid]::NewGuid().ToString('N') + [System.Guid]::NewGuid().ToString('N')

$mailUser   = Read-EnvVar 'MAIL_USERNAME' 'Gmail address for notifications (e.g. you@gmail.com)'
$mailPass   = Read-EnvVar 'MAIL_PASSWORD' 'Gmail App Password (16-char, from Google account security)' -Secret
$jwtSecret  = Read-EnvVar 'JWT_SECRET'   "JWT signing secret -- Enter to auto-generate" $autoSecret
$dbUser     = Read-EnvVar 'DB_USER'      'MySQL username -- Enter for default: ramo' 'ramo'
$dbPassword = Read-EnvVar 'DB_PASSWORD'  'MySQL password -- Enter for default: 12345' '12345' -Secret

# Persist to .env
Write-Step 'Saving .env...'
@(
    '# Auto-generated by start-app.ps1 -- DO NOT COMMIT',
    "MAIL_USERNAME=$mailUser",
    "MAIL_PASSWORD=$mailPass",
    "JWT_SECRET=$jwtSecret",
    "DB_USER=$dbUser",
    "DB_PASSWORD=$dbPassword"
) | Set-Content -Path $EnvFile -Encoding UTF8
Write-OK '.env saved.'

# Export for docker compose
$env:MAIL_USERNAME = $mailUser
$env:MAIL_PASSWORD = $mailPass
$env:JWT_SECRET    = $jwtSecret
$env:DB_USER       = $dbUser
$env:DB_PASSWORD   = $dbPassword

# ===========================================================================
# STEP 3 -- Clean stale state
# ===========================================================================
Write-Header 'Step 3: Cleaning Stale Docker State'

Push-Location $ComposeDir
Write-Step 'Stopping any running containers from this project...'
& docker compose down --remove-orphans | Out-Null
Write-OK 'Stale containers removed.'

# ===========================================================================
# STEP 4 -- Pull images
# ===========================================================================
if ($SkipPull) {
    Write-Header 'Step 4: Skipping Image Pull (using cached images)'
    Write-OK 'Cached images will be used. Add --pull=missing behaviour is disabled.'
} else {
    Write-Header 'Step 4: Pulling Images (may take several minutes on first run)'
    Write-Info 'Images: MySQL x3, Zookeeper, Kafka, Kafka-tools, 6 app services'
    Write-Info 'Use -SkipPull on future runs to skip this step.'
    & docker compose pull
    if ($LASTEXITCODE -ne 0) {
        Write-Warn 'Some images failed to pull -- will try to start with what is cached.'
    } else {
        Write-OK 'All images pulled.'
    }
}

$pullFlag = if ($SkipPull) { '--pull=never' } else { '--pull=missing' }

# ===========================================================================
# STEP 5 -- Start infrastructure
# ===========================================================================
Write-Header 'Step 5: Starting Infrastructure (MySQL x3, Zookeeper, Kafka)'

$infraSvcs = @('zookeeper', 'kafka', 'mysql-leave-request', 'mysql-leave-tracking', 'mysql-personnel-info')
& docker compose up -d $pullFlag @infraSvcs
if ($LASTEXITCODE -ne 0) {
    Write-Fail 'Infrastructure failed to start. Check Docker Desktop logs.'
    Pop-Location
    exit 1
}
Write-OK 'Infrastructure containers started.'
Write-Step 'Waiting 25 s for MySQL and Kafka to initialise...'
Start-Sleep -Seconds 25
Write-OK 'Infrastructure ready.'

# ===========================================================================
# STEP 6 -- Start application services
# ===========================================================================
Write-Header 'Step 6: Starting Application Services'

$appSvcs = @(
    'discovery-server',
    'api-gateway',
    'personnel-info-service',
    'leave-request-service',
    'leave-tracking-service',
    'mail-service',
    'ui-service'
)

if ($MonitoringStack) {
    $promYml = Join-Path $ComposeDir 'monitoring\prometheus.yml'
    if (Test-Path $promYml) {
        $appSvcs += 'prometheus'
        $appSvcs += 'grafana'
        Write-Step 'Monitoring stack (Prometheus + Grafana) included.'
    } else {
        Write-Warn 'monitoring\prometheus.yml not found -- skipping monitoring stack.'
        Write-Info 'See GAP_CLOSURE_GUIDE.md - Gap 2 to set it up.'
    }
}

& docker compose up -d $pullFlag @appSvcs
if ($LASTEXITCODE -ne 0) {
    Write-Fail 'Application services failed to start. Run: docker compose logs'
    Pop-Location
    exit 1
}
Write-OK 'All application services started.'
Pop-Location

# ===========================================================================
# STEP 7 -- Health checks
# ===========================================================================
Write-Header 'Step 7: Waiting for Services to Become Healthy'

function Test-Url {
    param([string]$Url)
    try {
        $r = Invoke-WebRequest -Uri $Url -TimeoutSec 4 -UseBasicParsing -ErrorAction Stop
        return ($r.StatusCode -lt 500)
    } catch { return $false }
}

$checks = @(
    [pscustomobject]@{ Name = 'API Gateway health';  Url = 'http://localhost:8080/actuator/health' },
    [pscustomobject]@{ Name = 'Eureka Dashboard';    Url = 'http://localhost:8761' },
    [pscustomobject]@{ Name = 'UI Service login';    Url = 'http://localhost:8086/ui/auth' }
)

foreach ($c in $checks) {
    Write-Step "Waiting for $($c.Name)..."
    $elapsed = 0
    $ready   = $false
    while ($elapsed -lt 120) {
        if (Test-Url $c.Url) { $ready = $true; break }
        Start-Sleep -Seconds 8
        $elapsed += 8
        Write-Info "    ...not ready ($elapsed s / 120 s)"
    }
    if ($ready) { Write-OK "$($c.Name) is up." } else { Write-Warn "$($c.Name) did not respond in 120 s -- may still be starting." }
}

# ===========================================================================
# STEP 8 -- Status table
# ===========================================================================
Write-Header 'Step 8: Container Status'

Write-Host ("  {0,-35} {1,-22} {2}" -f 'CONTAINER', 'STATUS', 'PORTS') -ForegroundColor Cyan
Write-Host ("  " + ('-' * 80)) -ForegroundColor DarkGray

$rows = & docker ps --format '{{.Names}}|{{.Status}}|{{.Ports}}'
foreach ($row in $rows) {
    $cols  = $row -split '\|', 3
    $color = if ($cols[1] -match '^Up') { 'Green' } elseif ($cols[1] -match 'Exit|Restart') { 'Red' } else { 'Yellow' }
    $ports = if ($cols.Count -ge 3) { $cols[2] } else { '' }
    Write-Host ("  {0,-35} {1,-22} {2}" -f $cols[0], $cols[1], $ports) -ForegroundColor $color
}

# ===========================================================================
# STEP 9 -- Summary
# ===========================================================================
Write-Header 'Step 9: System Ready'

Write-Host ''
Write-Host '  Application URLs:' -ForegroundColor Cyan
Write-Host ("  {0,-32} {1}" -f 'UI Login Page:',          'http://localhost:8086/ui/auth')
Write-Host ("  {0,-32} {1}" -f 'API Gateway:',             'http://localhost:8080')
Write-Host ("  {0,-32} {1}" -f 'Eureka Service Registry:', 'http://localhost:8761')
Write-Host ("  {0,-32} {1}" -f 'Gateway Health Check:',    'http://localhost:8080/actuator/health')
Write-Host ("  {0,-32} {1}" -f 'Prometheus Metrics:',      'http://localhost:8080/actuator/prometheus')
if ($MonitoringStack) {
    Write-Host ("  {0,-32} {1}" -f 'Grafana Dashboard:', 'http://localhost:3000  (login: admin / admin)')
    Write-Host ("  {0,-32} {1}" -f 'Prometheus UI:',     'http://localhost:9090')
}

Write-Host ''
$ans = Read-Host '  Open login page in browser? (Y/n)'
if ($ans -ne 'n' -and $ans -ne 'N') {
    Start-Process 'http://localhost:8086/ui/auth'
    Write-OK 'Browser opened.'
}

Write-Host ''
Write-Host '  +----------------------------------------------------------+' -ForegroundColor Cyan
Write-Host '  |  Useful commands:                                        |' -ForegroundColor Cyan
Write-Host '  |    View logs:   docker compose logs -f api-gateway       |' -ForegroundColor Cyan
Write-Host '  |    Stop all:    .\start-app.ps1 -StopAll                 |' -ForegroundColor Cyan
Write-Host '  |    Status:      docker ps                                |' -ForegroundColor Cyan
Write-Host '  +----------------------------------------------------------+' -ForegroundColor Cyan
Write-Host ''
