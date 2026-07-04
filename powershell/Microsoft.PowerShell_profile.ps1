# Oh My Posh
$env:PATH += ";$env:LOCALAPPDATA\Microsoft\WindowsApps"
oh-my-posh init pwsh --config "$env:USERPROFILE\.poshthemes\catppuccin_mocha.omp.json" | Invoke-Expression

# PSReadLine - autocompletado y historial
Import-Module PSReadLine
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle Inline
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock {
    $line = $null
    $cursor = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ([string]::IsNullOrWhiteSpace($line)) {
        [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchForward()
    } else {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion()
    }
}
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Key Ctrl+e -ScriptBlock {
    $current = (Get-PSReadLineOption).PredictionViewStyle
    if ($current -eq 'Inline') {
        Set-PSReadLineOption -PredictionViewStyle ListView
        Write-Host "`nVista: Lista" -ForegroundColor Yellow
    } else {
        Set-PSReadLineOption -PredictionViewStyle Inline
        Write-Host "`nVista: Inline" -ForegroundColor Yellow
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

# Terminal-Icons - iconos en ls
Import-Module Terminal-Icons

# posh-git - info de git
Import-Module posh-git

# ZLocation - navegacion rapida (z nombre_carpeta)
Import-Module ZLocation

# Historial por directorio (estilo Fish)
$DirHistoryFile = "$env:USERPROFILE\.dir_history.json"

function Save-DirHistory {
    param([string]$Command)
    if ([string]::IsNullOrWhiteSpace($Command)) { return }
    $cmd = $Command.Split(' ')[0].Trim()
    if ($cmd -match '^(cd|ls|dir|clear|cls|exit|history|reload)$') { return }
    
    $cwd = (Get-Location).Path
    $history = @{}
    if (Test-Path $DirHistoryFile) {
        try { $history = Get-Content $DirHistoryFile -Raw | ConvertFrom-Json -AsHashtable } catch { $history = @{} }
    }
    if (-not $history.ContainsKey($cwd)) { $history[$cwd] = @() }
    $cmds = @($history[$cwd] | Where-Object { $_ -ne $cmd })
    $cmds = @($cmd) + $cmds | Select-Object -First 20
    $history[$cwd] = $cmds
    $history | ConvertTo-Json -Depth 3 | Set-Content $DirHistoryFile -Encoding UTF8
}

function Get-DirHistory {
    $cwd = (Get-Location).Path
    if (-not (Test-Path $DirHistoryFile)) { return @() }
    try {
        $history = Get-Content $DirHistoryFile -Raw | ConvertFrom-Json -AsHashtable
        if ($history.ContainsKey($cwd)) { return $history[$cwd] }
    } catch {}
    return @()
}

# Predictor personalizado por directorio
$script:DirPredictor = {
    param([string]$input, [System.Management.Automation.CommandAst]$ast, [ref]$cursorColumn)
    $cmds = Get-DirHistory
    $results = @()
    foreach ($cmd in $cmds) {
        if ($cmd -like "$input*") {
            $results += [PSCustomObject]@{
                CompletionText = $cmd
                ListItemText = $cmd
                ResultType = 2
                ToolTip = "Historial de este directorio"
            }
        }
    }
    return $results
}

# Hook para guardar comandos en historial por directorio
$script:OriginalExecuteCommand = $function:Global:Prompt
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    # cleanup
} -ErrorAction SilentlyContinue | Out-Null

Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    Save-DirHistory $line
    $blacklist = @('password', 'secret', 'token', 'key')
    foreach ($word in $blacklist) {
        if ($line -match $word) { return $false }
    }
    return $true
}

# Funcion para mostrar historial del directorio actual
function dir-history {
    $cmds = Get-DirHistory
    if ($cmds.Count -eq 0) {
        Write-Host "No hay historial en este directorio" -ForegroundColor DarkGray
        return
    }
    Write-Host "`nHistorial de: $((Get-Location).Path)" -ForegroundColor Cyan
    $cmds | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    Write-Host ""
}

# Abreviaturas
Set-Alias -Name g -Value git
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String
Set-Alias -Name touch -Value New-Item

# Funciones utiles
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function mkcd { param($path) New-Item -ItemType Directory -Path $path -Force | Set-Location }
function Get-MyIP { (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content }
function reload { . $PROFILE }

# PATH adicional
$env:PATH += ";C:\Program Files\WezTerm;C:\msys64\usr\bin"
