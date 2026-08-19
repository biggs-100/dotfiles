# ============================================================
# PowerShell 7 Profile — Catppuccin Mocha + Fish Style (Optimized)
# ============================================================

# --- Starship prompt (Rust binary, ~100ms vs oh-my-posh ~800ms) ---
$env:PATH += ";$env:LOCALAPPDATA\Microsoft\WindowsApps;$env:LOCALAPPDATA\starship"
Invoke-Expression (& starship init powershell)

# --- PSReadLine (always loaded — it's fast) ---
Import-Module PSReadLine

# --- Lazy-load modules (load on first use) ---
# posh-git: loads when you first run git
Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $cursorPosition)
    if (-not (Get-Module posh-git)) { Import-Module posh-git -ErrorAction SilentlyContinue }
    $cmds = @('add','bisect','branch','checkout','cherry-pick','clean','clone','commit','diff','fetch','grep','init','log','merge','mv','pull','push','rebase','reflog','remote','reset','restore','rm','show','stash','status','submodule','switch','tag','worktree')
    $w = $wordToComplete -replace '^-',''
    $cmds | Where-Object { $_ -like "$w*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "git $_")
    }
}

# Terminal-Icons — always loaded (fast, ~100ms, needed for ls icons)
Import-Module Terminal-Icons
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem

# ZLocation — always loaded (needed for z navigation)
Import-Module ZLocation

# ============================================================
# PSReadLine — Fish-style suggestions & completion
# ============================================================
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 50000
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -CompletionQueryItems 100
Set-PSReadLineOption -ShowToolTips

# Colors (Catppuccin Mocha compatible)
Set-PSReadLineOption -Colors @{
    InlinePrediction = '#585b70'
    Command          = '#89b4fa'
    Parameter        = '#89dceb'
    Variable         = '#cdd6f4'
    String           = '#a6e3a1'
    Keyword          = '#cba6f7'
    Comment          = '#6c7086'
    Operator         = '#94e2d5'
    Type             = '#f9e2af'
    Number           = '#fab387'
    Member           = '#f5c2e7'
    Error            = '#f38ba8'
    Selection        = '#45475a'
    Emphasis         = '#f9e2af'
    Default          = '#cdd6f4'
    ContinuationPrompt = '#585b70'
}

# History search with arrows
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory

# Accept suggestions
Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardWord
Set-PSReadLineKeyHandler -Key Alt+RightArrow -Function ForwardWord
Set-PSReadLineKeyHandler -Key End -Function EndOfLine

# Tab completion — Fish-style (accept suggestion OR complete)
Set-PSReadLineKeyHandler -Key Tab -BriefDescription "FishTabComplete" -LongDescription "Tab acepta sugerencia o completa" -ScriptBlock {
    $line = $null
    $cursor = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # Si la linea esta vacia, buscar en historial
    if ([string]::IsNullOrWhiteSpace($line)) {
        [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchForward()
        return
    }

    # Si hay sugerencia inline (texto gris subrayado), aceptarla toda
    $predictions = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$null, [ref]$null, [ref]$predictions, [ref]$null)
    if ($predictions -and $predictions.Count -gt 0 -and $cursor -eq $line.Length) {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion()
        return
    }

    # Si no hay sugerencia, completar normalmente
    $completions = $null
    $completionCount = 0
    try {
        [Microsoft.PowerShell.PSConsoleReadLine]::Complete([ref]$completions, [ref]$completionCount)
    } catch {}

    # Si hay varias opciones, mostrar menu
    if ($completionCount -gt 1) {
        [Microsoft.PowerShell.PSConsoleReadLine]::MenuComplete()
    }
}
Set-PSReadLineKeyHandler -Key Shift+Tab -Function TabCompletePrevious

# Fish keybindings
Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -Key Ctrl+d -Function ViExit
Set-PSReadLineKeyHandler -Key Ctrl+l -Function ClearScreen
Set-PSReadLineKeyHandler -Key Ctrl+k -Function KillLine
Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardKillLine
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Alt+d -Function KillWord
Set-PSReadLineKeyHandler -Key Ctrl+y -Function Yank
Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
Set-PSReadLineKeyHandler -Key Ctrl+Shift+z -Function Redo

# Toggle prediction view style
Set-PSReadLineKeyHandler -Key Ctrl+e -ScriptBlock {
    $current = (Get-PSReadLineOption).PredictionViewStyle
    if ($current -eq 'InlineView') {
        Set-PSReadLineOption -PredictionViewStyle ListView
        Write-Host "`nVista: Lista" -ForegroundColor Yellow
    } else {
        Set-PSReadLineOption -PredictionViewStyle InlineView
        Write-Host "`nVista: Inline" -ForegroundColor Yellow
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

# ============================================================
# Docker & npm completions
# ============================================================
Register-ArgumentCompleter -Native -CommandName docker -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $cursorPosition)
    $cmds = @('attach','build','commit','cp','create','diff','events','exec','export','history','images','import','info','inspect','kill','load','login','logs','pause','port','ps','pull','push','rename','restart','rm','rmi','run','save','search','start','stats','stop','tag','top','unpause','update','version','volume','wait')
    $w = $wordToComplete -replace '^-',''
    $cmds | Where-Object { $_ -like "$w*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "docker $_")
    }
}

Register-ArgumentCompleter -Native -CommandName npm -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $cursorPosition)
    $cmds = @('access','audit','bin','bugs','cache','ci','config','dedupe','deprecate','diff','dist-tag','docs','doctor','edit','exec','explore','fund','help','init','install','link','login','ls','org','outdated','owner','pack','ping','pkg','prefix','profile','prune','publish','query','rebuild','repo','restart','root','run-script','search','set','star','start','stop','team','test','token','uninstall','update','version','view','whoami')
    $w = $wordToComplete -replace '^-',''
    $cmds | Where-Object { $_ -like "$w*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "npm $_")
    }
}

# ============================================================
# Directory history (Fish-style)
# ============================================================
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

Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    Save-DirHistory $line
    $blacklist = @('password', 'secret', 'token', 'key')
    foreach ($word in $blacklist) {
        if ($line -match $word) { return $false }
    }
    return $true
}

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

# ============================================================
# Aliases
# ============================================================
Set-Alias -Name g -Value git
Set-Alias -Name grep -Value Select-String
Set-Alias -Name touch -Value New-Item

# ============================================================
# Utility functions
# ============================================================
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function mkcd { param($path) New-Item -ItemType Directory -Path $path -Force | Set-Location }
function Get-MyIP { (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content }
function reload { . $PROFILE }

# ============================================================
# PATH
# ============================================================
$env:PATH += ";C:\Program Files\WezTerm;C:\msys64\usr\bin"
