# Unreal Editor Launcher

Tiny Windows scripts that find and launch the Unreal Engine Editor from the command prompt — no Epic Games Launcher required.

## What's in here

| File | Purpose |
| ---- | ------- |
| `launch-unreal-editor.bat` | Classic Windows batch script. Runs from `cmd.exe`. |
| `launch-unreal-editor.ps1` | PowerShell script with version selection and richer error messages. |

Both scripts:

1. Honor an explicit override (`UE_PATH` env var, or `-EditorPath` for PowerShell).
2. Otherwise scan the standard Epic Games install roots:
   - `C:\Program Files\Epic Games\UE_*`
   - `D:\Program Files\Epic Games\UE_*`
   - `C:\Epic Games\UE_*`
   - `D:\Epic Games\UE_*`
3. Launch the newest installed `UnrealEditor.exe` (or a specific version).

## One-line install (PowerShell)

On a Windows machine (including a Shadow PC), open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/jdot274/unreal-editor-launcher/main/install.ps1 | iex
```

This downloads the scripts to `%USERPROFILE%\unreal-editor-launcher` and adds that folder to your user `PATH`, so you can run `launch-unreal-editor.bat` from any new terminal. To install without touching `PATH`:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jdot274/unreal-editor-launcher/main/install.ps1))) -SkipPath
```

## Prerequisites

- Windows 10 or 11
- A working install of Unreal Engine 4.27+ or 5.x via the Epic Games Launcher (or any location you point `UE_PATH` to)
- For the PowerShell script, the default execution policy is fine; if your machine is locked down, run it as:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .\launch-unreal-editor.ps1
  ```

## Usage

### Batch

```cmd
:: Launch the newest installed editor
launch-unreal-editor.bat

:: Open a specific project
launch-unreal-editor.bat "C:\Projects\MyGame\MyGame.uproject"

:: Override the engine path for this session
set UE_PATH=D:\Epic\UE_5.4\Engine\Binaries\Win64\UnrealEditor.exe
launch-unreal-editor.bat
```

### PowerShell

```powershell
# Newest installed editor
.\launch-unreal-editor.ps1

# Pick a specific engine version
# (use the form that appears in the install folder name, e.g. UE_5.3 -> "5.3")
.\launch-unreal-editor.ps1 -Version 5.3

# Open a project
.\launch-unreal-editor.ps1 -Project "C:\Projects\MyGame\MyGame.uproject"

# Use a custom editor path
.\launch-unreal-editor.ps1 -EditorPath "D:\Epic\UE_5.4\Engine\Binaries\Win64\UnrealEditor.exe"
```

## Customizing the engine path permanently

Set `UE_PATH` as a user environment variable so every shell picks it up:

```powershell
[Environment]::SetEnvironmentVariable('UE_PATH',
    'D:\Epic\UE_5.4\Engine\Binaries\Win64\UnrealEditor.exe',
    'User')
```

Open a new terminal afterwards for the change to take effect.

## Troubleshooting

- **"Could not find an installed Unreal Editor"** — Either Unreal isn't installed in one of the default roots, or it's installed in a custom location. Set `UE_PATH` (or use `-EditorPath`) to the full path of `UnrealEditor.exe`.
- **Script blocked by execution policy (PowerShell)** — Use `-ExecutionPolicy Bypass` as shown above.
- **Editor opens then immediately closes** — Run the script from an open `cmd` window (not by double-clicking) to keep the console alive and read the error message printed by Unreal.

## License

MIT
