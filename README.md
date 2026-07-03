# Dotfiles

Configuración de PowerShell 7 + WezTerm para Windows.

## Incluido

- **PowerShell 7** — perfil con oh-my-posh, PSReadLine, Terminal-Icons, posh-git, ZLocation
- **WezTerm** — terminal con OpenGL, fuentes Nerd Font, Catppuccin Mocha
- **Historial por directorio** — sugerencias de comandos según la carpeta (estilo Fish)

## Instalación

```powershell
git clone https://github.com/TU_USUARIO/dotfiles.git ~/dotfiles
cd ~/dotfiles
.\install.ps1
```

Requiere ejecutar como Administrador (para instalar fuentes).

## Estructura

```
dotfiles/
├── install.ps1                          # Script de instalación
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1 # Perfil de PowerShell
├── wezterm/
│   └── .wezterm.lua                     # Configuración de WezTerm
└── poshthemes/
    └── catppuccin_mocha.omp.json        # Tema de Oh My Posh
```

## Módulos instalados

| Módulo | Función |
|---|---|
| oh-my-posh | Prompt temático |
| PSReadLine | Autocompletado + historial predictivo |
| Terminal-Icons | Iconos de archivos en `ls` |
| posh-git | Estado de git en el prompt |
| ZLocation | Navegación rápida (`z nombre_carpeta`) |

## Atajos de teclado

| Tecla | Acción |
|---|---|
| `Tab` | Menú de autocompletado |
| `↑` / `↓` | Buscar en historial |
| `Ctrl+Z` | Deshacer |
| `Ctrl+D` | Salir |
| `Ctrl+Shift+T` | Nueva pestaña |

## Comandos útiles

```powershell
g git              # Abreviatura
ll                 # ls con iconos
mkcd mi-carpeta    # Crear y entrar en carpeta
z proyecto         # Ir a carpeta visitada
dir-history        # Ver historial del directorio actual
reload             # Recargar perfil
Get-MyIP           # IP pública
```

## Requisitos

- Windows 10/11
- [PowerShell 7](https://github.com/PowerShell/PowerShell/releases)
- [WezTerm](https://wezfurlong.org/wezterm/docs/install/windows.html)
- Git
