#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Instala dotfiles (PowerShell + WezTerm)
.DESCRIPTION
    Instala oh-my-posh, módulos de PowerShell, fuentes Nerd Font,
    y configura el perfil y WezTerm.
#>

$ErrorActionPreference = "Stop"
$dotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`n=== Dotfiles Installer ===" -ForegroundColor Cyan

# --- 1. Instalar oh-my-posh ---
Write-Host "`n[1/6] Instalando oh-my-posh..." -ForegroundColor Yellow
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
} else {
    Write-Host "  ya instalado" -ForegroundColor Green
}

# --- 2. Instalar módulos de PowerShell ---
Write-Host "`n[2/6] Instalando módulos de PowerShell..." -ForegroundColor Yellow
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -ErrorAction SilentlyContinue | Out-Null

$modules = @('PSReadLine', 'Terminal-Icons', 'posh-git', 'ZLocation')
foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "  Instalando $mod..."
        Install-Module -Name $mod -Force -SkipPublisherCheck -Scope CurrentUser
    } else {
        Write-Host "  $mod ya instalado" -ForegroundColor Green
    }
}

# --- 3. Instalar fuente Nerd Font ---
Write-Host "`n[3/6] Instalando Cascadia Code Nerd Font..." -ForegroundColor Yellow
$fontName = "CaskaydiaCoveNerdFont"
$fontInstalled = Get-ChildItem "C:\Windows\Fonts" -Filter "*$fontName*" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $fontInstalled) {
    $tempDir = "$env:TEMP\CascadiaCodeNF"
    if (-not (Test-Path $tempDir)) {
        Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip" -OutFile "$env:TEMP\CascadiaCode.zip"
        Expand-Archive -Path "$env:TEMP\CascadiaCode.zip" -DestinationPath $tempDir -Force
    }
    Copy-Item "$tempDir\*.ttf" "C:\Windows\Fonts" -Force
    $fonts = Get-ChildItem $tempDir -Filter "*.ttf"
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    foreach ($font in $fonts) {
        New-ItemProperty -Path $regPath -Name "$($font.BaseName) (TrueType)" -Value $font.Name -PropertyType String -Force | Out-Null
    }
    Write-Host "  Fuente instalada" -ForegroundColor Green
} else {
    Write-Host "  Fuente ya instalada" -ForegroundColor Green
}

# --- 4. Copiar perfil de PowerShell ---
Write-Host "`n[4/6] Configurando perfil de PowerShell..." -ForegroundColor Yellow
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
Copy-Item "$dotfilesDir\powershell\Microsoft.PowerShell_profile.ps1" $PROFILE -Force
Write-Host "  Perfil copiado a: $PROFILE" -ForegroundColor Green

# --- 5. Copiar configuración de WezTerm ---
Write-Host "`n[5/6] Configurando WezTerm..." -ForegroundColor Yellow
$weztermDir = "$env:USERPROFILE"
Copy-Item "$dotfilesDir\wezterm\.wezterm.lua" "$weztermDir\.wezterm.lua" -Force
Write-Host "  WezTerm configurado" -ForegroundColor Green

# --- 6. Copiar tema de Oh My Posh ---
Write-Host "`n[6/6] Copiando tema de Oh My Posh..." -ForegroundColor Yellow
$themesDir = "$env:USERPROFILE\.poshthemes"
if (-not (Test-Path $themesDir)) { New-Item -ItemType Directory -Path $themesDir -Force | Out-Null }
Copy-Item "$dotfilesDir\poshthemes\*.omp.json" $themesDir -Force
Write-Host "  Tema copiado" -ForegroundColor Green

# --- Listo ---
Write-Host "`n=== Instalacion completa ===" -ForegroundColor Green
Write-Host "Reinicia WezTerm para aplicar los cambios.`n" -ForegroundColor Yellow
