# dcli

**A declarative package management tool for Arch Linux** that brings NixOS-style configuration management to Arch. Define your entire system in YAML files, organize packages into reusable modules, and sync your setup across multiple machines with confidence. No more manually tracking what you installed - your configuration is the source of truth.

**Why use dcli?**
- 🎯 **Declarative**: Define what you want, not how to get there
- 🔄 **Reproducible**: Same config = same system, every time
- 📦 **Organized**: Modules keep related packages together (gaming, dev, media)
- 🖥️ **Multi-machine**: Share configs, customize per host
- 🔒 **Safe**: Automatic backups, conflict detection, validation
- ⚡ **Fast**: Rust-powered, zero runtime dependencies

Built with Rust for performance and reliability.

> **⚠️ ALPHA SOFTWARE** - Use at your own risk. Always maintain backups before major operations.

---

**💖 Support the Project**

If dcli saves you time or makes your Arch life easier, consider supporting development:

**[☕ Buy me a coffee on Ko-fi](https://ko-fi.com/theblackdon)**

## Quick Links

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Commands](#core-commands)
- [Configuration](#configuration)
- [Dotfiles Management](#dotfiles-management)
- [Services Management](#services-management)
- [AUR Package](#aur-package)

---

## Features

### Package Management
- **Declarative Configuration** - Define packages in YAML, sync your system to match
- **Module System** - Organize packages into reusable modules (gaming, development, etc.)
- **Host-Specific Configs** - Different package sets per machine with shared modules
- **Flatpak Support** - Seamlessly manage flatpak apps alongside pacman packages
- **Safe Merge** - Capture manually installed packages without dependencies
- **Conflict Detection** - Prevents enabling conflicting modules

### Interactive TUI (powered by fzf)
- **`dcli search`** - Multi-select package search with live preview
- **`dcli module enable/disable`** - Interactive module selection
- **`dcli restore`** - Browse and restore snapshots
- **`dcli hooks run`** - Select and run post-install hooks
- **`dcli edit`** - Interactive config file editor

### System Management
- **Dotfiles Management** - GNU Stow-like dotfiles with conflict detection and flexible path mapping
- **Services** - Declaratively manage systemd services alongside packages
- **Backups** - Config backups + system snapshots (Timeshift/Snapper)
- **Post-Install Hooks** - Run scripts after package installation with fine-grained control
- **Git Integration** - Built-in commands to sync configs across machines
- **Self-Updating** - Update dcli with a single command

### Developer Features
- **Zero Runtime Dependencies** - Self-contained Rust binary
- **JSON Output** - All commands support `--json` for scripting
- **Validation** - `dcli validate` checks config integrity
- **Migration Tool** - Safely migrate from old config structure

---

## Installation

### From AUR (Recommended)

```bash
# Using an AUR helper
yay -S dcli-arch-git
# or
paru -S dcli-arch-git
```


The installer will:
1. Install Rust toolchain if needed
2. Build the release binary
3. Install to `/usr/local/bin/dcli`
4. Check for optional dependencies (AUR helper, backup tools)

**Prerequisites:**
- Arch Linux or Arch-based distro
- Rust toolchain (installer handles this)

**Optional:**
- `fzf` - For interactive TUI features
- `paru` or `yay` - AUR package support
- `timeshift` or `snapper` - System backups

---

## Quick Start

### 1. Initialize Configuration

**Option A: Start from scratch**
```bash
dcli init
```

**Option B: Bootstrap from example config**
```bash
dcli init -b
```

This creates `~/.config/arch-config/` with:
```
arch-config/
├── config.yaml           # Pointer to active host
├── hosts/
│   └── {hostname}.yaml   # Your full configuration
├── modules/
│   ├── base.yaml         # Base packages
│   └── example.yaml      # Example module
└── scripts/              # Post-install hooks
```

### 2. Define Packages

Edit your host file: `~/.config/arch-config/hosts/{hostname}.yaml`

```yaml
host: desktop
description: My desktop computer

# Enable modules
enabled_modules:
  - gaming
  - development

# Host-specific packages
packages:
  - firefox
  - discord
  - flatpak:com.spotify.Client

# Exclude packages from modules
exclude:
  - steam  # Don't want from gaming module

# Settings
flatpak_scope: user     # "user" or "system"
auto_prune: false       # Auto-remove unmanaged packages during sync
aur_helper: paru        # AUR helper to use (paru, yay, etc.)
editor: nano            # Editor for config files (falls back to $EDITOR)

# Config backups
config_backups:
  enabled: true         # Auto-backup configs before sync
  max_backups: 5        # Keep last N backups (0 = unlimited)

# System backups (Timeshift/Snapper)
system_backups:
  enabled: true         # Global toggle for system backups
  backup_on_sync: true  # Create backup during dcli sync
  backup_on_update: true # Create backup during dcli update
  tool: timeshift       # Backup tool: timeshift or snapper
  snapper_config: root  # Snapper config name (if using snapper)
```

### 3. Create Modules

Create `~/.config/arch-config/modules/gaming.yaml`:

```yaml
description: Gaming packages

packages:
  - steam
  - lutris
  - wine
  - gamemode

post_install_hook: scripts/setup-gaming.sh
hook_behavior: ask
```

### 4. Sync Your System

```bash
dcli sync              # Install missing packages
dcli sync --dry-run    # Preview changes first
dcli sync --prune      # Also remove unmanaged packages
```

---

## Core Commands

### Package Management

```bash
dcli search                    # Interactive package search (TUI)
dcli install <package>         # Install and add to config
dcli remove <package>          # Remove package
dcli update                    # Update system
dcli find <package>            # Find where package is defined
dcli merge                     # Add unmanaged packages to config
dcli merge --services          # Add enabled services to config
```

### Modules

```bash
dcli module list               # Show all modules
dcli module enable             # Interactive selection (TUI)
dcli module enable gaming      # Enable specific module
dcli module disable            # Interactive selection (TUI)
```

### Configuration

```bash
dcli status                    # Show config and sync status
dcli validate                  # Check config integrity
dcli edit                      # Interactive file editor (TUI)
dcli migrate                   # Migrate to new structure
```

### Backups

**Configuration Backups:**
```bash
dcli save-config               # Backup current config
dcli restore-config            # Interactive restore (TUI)
```

**System Snapshots:**
```bash
dcli backup                    # Create system snapshot
dcli backup list               # List snapshots
dcli restore                   # Interactive restore (TUI)
```

### Hooks

```bash
dcli hooks list                # Show all hooks and status
dcli hooks run                 # Interactive selection (TUI)
dcli hooks skip <module>       # Mark hook as skipped
dcli hooks reset <module>      # Reset hook to run again
```

### Git Repository

```bash
dcli repo init                 # Set up git for arch-config
dcli repo clone                # Clone existing arch-config
dcli repo push                 # Commit and push changes
dcli repo pull                 # Pull updates from remote
dcli repo status               # Show git status
```

### Maintenance

```bash
dcli self-update               # Update dcli itself
dcli help                      # Show help
dcli <command> --json          # JSON output for scripting
```

---

## Configuration

### Host File Format

Full host configuration in `hosts/{hostname}.yaml`:

```yaml
host: desktop
description: Gaming Desktop

# Import shared configs (optional)
import:
  - hosts/shared/common.yaml

# Enable modules
enabled_modules:
  - gaming
  - development

# Host-specific packages
packages:
  - firefox
  - discord
  - flatpak:com.spotify.Client  # Flatpak using prefix
  - name: org.videolan.VLC       # Flatpak using object format
    type: flatpak

# Exclude from base/modules
exclude:
  - vim  # Use neovim instead

# Services
services:
  enabled:
    - bluetooth
    - sshd
  disabled:
    - cups

# Settings
flatpak_scope: user     # "user" or "system"
auto_prune: false
aur_helper: paru

# Config backups
config_backups:
  enabled: true
  max_backups: 5

# System backups (Timeshift/Snapper)
system_backups:
  enabled: true         # Global toggle
  backup_on_sync: true  # Backup during sync
  backup_on_update: true # Backup during update
  tool: timeshift       # timeshift or snapper
  snapper_config: root  # Snapper config name
```

### Module Format

Modules in `modules/{name}.yaml`:

```yaml
description: Gaming packages

packages:
  - steam
  - lutris
  - wine

conflicts:
  - office-suite  # Can't coexist with this module

post_install_hook: scripts/setup-gaming.sh
hook_behavior: ask  # ask | always | once | skip
```

### Directory-Based Modules

For complex modules, use a directory:

```
modules/
└── hyprland/
    ├── module.yaml          # Main module definition
    ├── packages.yaml        # Package list
    └── wayland-tools.yaml   # Additional package lists
```

`module.yaml`:
```yaml
description: Hyprland window manager
post_install_hook: scripts/install-hypr-dotfiles.sh
```

`packages.yaml`:
```yaml
packages:
  - hyprland
  - waybar
  - wofi
```

### Hook Behaviors

Control when post-install hooks run:

| Behavior | Description |
|----------|-------------|
| `ask` | Prompt before running (default) |
| `always` | Run every sync, no questions |
| `once` | Run once without prompting |
| `skip` | Never run this hook |

---

## Flatpak Support

### Setup

```bash
sudo pacman -S flatpak
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Usage

Two ways to declare flatpak packages:

```yaml
packages:
  - firefox                          # Regular pacman package
  - flatpak:com.spotify.Client      # Flatpak (prefix format)
  - name: org.videolan.VLC           # Flatpak (object format)
    type: flatpak
```

### Configuration

Set installation scope in your host file:

```yaml
flatpak_scope: user  # "user" (default) or "system"
```

---

## Services Management

Declaratively manage systemd services:

```yaml
services:
  enabled:
    - bluetooth    # Enable and start
    - sshd
    - docker
  disabled:
    - cups         # Stop and disable
```

Bootstrap from current system:

```bash
dcli merge --services           # Add enabled services to config
dcli merge --services --dry-run # Preview first
```

Services sync automatically during `dcli sync`.

---

## Multi-Machine Setup

### First Machine

```bash
# Initialize config
dcli init

# Set up git repo
dcli repo init
```

### Additional Machines

```bash
# Clone your config
dcli repo clone

# Sync packages
dcli sync
```

### Workflow

**On desktop:**
```bash
dcli module enable gaming
dcli sync
dcli repo push
```

**On laptop:**
```bash
dcli repo pull
dcli module enable gaming  # Shared module, different packages per host
dcli sync
```

---

## Dotfiles Management

dcli includes a powerful dotfiles management system inspired by GNU Stow, with automatic conflict detection and flexible path mapping.

### Quick Start

**Legacy Mode (Automatic):**
Modules with a `dotfiles/` directory automatically sync to `~/.config/`:

```
modules/hyprland/
├── module.yaml
└── dotfiles/
    ├── hypr/      → symlinked to ~/.config/hypr
    └── waybar/    → symlinked to ~/.config/waybar
```

**New Mode (Explicit Control):**
Create `dotfiles.yaml` for fine-grained control:

```yaml
# modules/hyprland/dotfiles.yaml

# Shorthand form (implies ~/.config/)
dotfiles:
  - hypr          # dotfiles/hypr → ~/.config/hypr
  - waybar        # dotfiles/waybar → ~/.config/waybar

# Explicit form (custom paths)
  - source: zshrc
    target: ~/.zshrc
  - source: scripts/startup.sh
    target: ~/.local/bin/hypr-startup

# Or use automatic mode (same as legacy)
automatic: true
```

### Features

**✅ Conflict Detection**
If multiple modules try to sync to the same target, dcli will error with details:

```
Error: Dotfile conflicts detected:

  Target: /home/user/.config/hypr
  Conflicting modules:
    - hyprland (source: /path/to/hyprland/dotfiles/hypr)
    - niri (source: /path/to/niri/dotfiles/hypr)

Resolution: Update dotfiles.yaml in conflicting modules to use different target paths.
```

**✅ Flexible Paths**
Not limited to `~/.config/` - sync anywhere:

```yaml
dotfiles:
  - source: bashrc
    target: ~/.bashrc
  - source: config/nvim
    target: ~/.config/nvim
  - source: bin/my-script
    target: ~/.local/bin/my-script
```

**✅ Backwards Compatible**
Existing modules with `dotfiles/` directories work without changes. Migrate when ready:

```yaml
# Option 1: Keep automatic behavior explicitly
automatic: true

# Option 2: List what to sync (more control)
dotfiles:
  - hypr
  - waybar
  # kitty intentionally not synced
```

### Configuration Modes

**Mode 1: Automatic (Legacy)**
```yaml
automatic: true
```
Syncs everything in `dotfiles/` to `~/.config/` (only directories)

**Mode 2: Shorthand**
```yaml
dotfiles:
  - hypr                    # → ~/.config/hypr
  - waybar                  # → ~/.config/waybar
  - config/nvim             # → ~/.config/config/nvim (nested source)
```

**Mode 3: Explicit**
```yaml
dotfiles:
  - source: zshrc
    target: ~/.zshrc
  - source: local/bin/script.sh
    target: ~/.local/bin/script.sh
```

**Mode 4: Mixed**
```yaml
dotfiles:
  - hypr                    # Shorthand
  - source: bashrc          # Explicit
    target: ~/.bashrc
```

### Resolving Conflicts

When two modules have overlapping dotfiles:

```yaml
# modules/hyprland/dotfiles.yaml
dotfiles:
  - hypr
  - source: kitty
    target: ~/.config/kitty-hypr

# modules/niri/dotfiles.yaml
dotfiles:
  - niri
  - source: kitty
    target: ~/.config/kitty-niri
```

### Directory Structure Examples

**Basic Module:**
```
modules/hyprland/
├── module.yaml
├── dotfiles.yaml          # NEW: explicit control
└── dotfiles/
    ├── hypr/
    └── waybar/
```

**Flexible Source Paths:**
```
modules/shell/
├── module.yaml
├── dotfiles.yaml
├── zshrc                  # Source: zshrc (not in dotfiles/)
├── bashrc                 # Source: bashrc
└── config/
    └── starship.toml      # Source: config/starship.toml
```

`dotfiles.yaml`:
```yaml
dotfiles:
  - source: zshrc
    target: ~/.zshrc
  - source: bashrc
    target: ~/.bashrc
  - source: config/starship.toml
    target: ~/.config/starship.toml
```

### Commands

```bash
dcli sync                    # Sync dotfiles during normal sync
dcli sync --force-dotfiles   # Force re-sync even if already synced
dcli sync --prune            # Remove dotfiles from disabled modules
```

### Validation Rules

- `automatic` and `dotfiles` list are mutually exclusive
- Source paths are relative to module root
- Source paths must exist when syncing
- Target paths support `~` expansion
- Parent directories are created automatically
- Backups are created before replacing existing files

### Migration Guide

**From Legacy to Explicit:**

Before (automatic):
```
modules/hyprland/dotfiles/
├── hypr/
├── waybar/
└── kitty/
```

After (explicit with same behavior):
```yaml
# dotfiles.yaml
dotfiles:
  - hypr
  - waybar
  - kitty
```

After (selective sync):
```yaml
# dotfiles.yaml
dotfiles:
  - hypr
  - waybar
  # kitty not included - won't sync
```

---

## Advanced Features

### Config Import

Share configurations across hosts:

```yaml
# hosts/laptop.yaml
import:
  - hosts/shared/common.yaml
  - hosts/shared/laptop-base.yaml
```

### Package Finding

Find where a package is defined:

```bash
dcli find steam
# → Module: gaming
#   File: /home/user/.config/arch-config/modules/gaming.yaml
```

### Config Backups

Automatic validation and backup before syncing:

```yaml
config_backups:
  enabled: true      # Auto-backup on sync
  max_backups: 5     # Keep last 5 backups
```

```bash
dcli save-config       # Manual backup
dcli restore-config    # Interactive restore
```

Backups include:
- Active host configuration
- All modules and scripts
- Dotfiles and state

### AUR Helper

Configure your preferred AUR helper:

```yaml
aur_helper: paru  # or "yay"
```

Auto-detects if not specified (prefers paru → yay).

### JSON Output

All commands support JSON for scripting:

```bash
dcli status --json
dcli module list --json
dcli find vim --json
```

---

## Migration

Migrate from old structure (`packages/` directory) to new clean structure:

```bash
dcli migrate --dry-run  # Preview changes
dcli migrate            # Perform migration (creates backup)
```

Changes:
- `packages/modules/` → `modules/`
- `packages/hosts/` → `hosts/`
- `packages/base.yaml` → `modules/base.yaml`
- Converts `config.yaml` to pointer format
- Creates full host configuration

**Note:** Old structure still works! Migration is optional.

---

## Troubleshooting

### dcli not found after installation

```bash
hash -r  # Refresh shell cache
# or restart terminal
```

### Build fails

```bash
source $HOME/.cargo/env  # Load Rust environment
./install.sh
```

### Sync fails with conflicts

```bash
sudo pacman -S <conflicting-package>
dcli sync
```

### TUI commands don't work

```bash
sudo pacman -S fzf  # Install fzf for TUI features
```

### Backup commands fail

```bash
sudo pacman -S timeshift  # or snapper
```

---

## AUR Package

dcli is available on the AUR as `dcli-arch-git`:

```bash
yay -S dcli-arch-git
# or
paru -S dcli-arch-git
```

**Package Details:**
- **Name:** dcli-arch-git
- **Type:** VCS package (builds from latest git)
- **Maintainer:** Don <theblackdonatello@gmail.com>
- **URL:** https://aur.archlinux.org/packages/dcli-arch-git

---

## Examples

### Gaming Setup

```yaml
# modules/gaming.yaml
description: Gaming packages and tools

packages:
  - steam
  - lutris
  - wine
  - gamemode
  - mangohud

services:
  enabled:
    - gamemode

post_install_hook: scripts/setup-gaming.sh
hook_behavior: ask
```

### Development Environment

```yaml
# modules/development.yaml
description: Development tools

packages:
  - git
  - neovim
  - rust
  - nodejs
  - docker
  - code

services:
  enabled:
    - docker

post_install_hook: scripts/setup-dev-env.sh
hook_behavior: once
```

### Media Production

```yaml
# modules/media.yaml
description: Media production tools

packages:
  - ffmpeg
  - audacity
  - gimp
  - flatpak:com.obsproject.Studio
  - flatpak:org.kde.kdenlive
  - name: org.blender.Blender
    type: flatpak

post_install_hook: scripts/setup-media.sh
```

---

## Documentation

- **Configuration Guide:** See examples above
- **Hook System:** Run `dcli hooks list` for overview
- **Service Management:** [SERVICES.md](SERVICES.md)
- **Module Sharing:** [MODULE_SHARING_PLAN.md](MODULE_SHARING_PLAN.md)
- **Directory Modules:** [DIRECTORY-MODULES.md](DIRECTORY-MODULES.md)
- **Dotfiles:** [DOTFILES-SYMLINK-GUIDE.md](DOTFILES-SYMLINK-GUIDE.md)

---

## Contributing

Contributions welcome! Open an issue or submit a pull request.

**Repository:** https://gitlab.com/theblackdon/dcli

---

## License

0BSD License - See [LICENSE](LICENSE)

---

## Credits

Special thanks to:
- **Alice Alysia** - https://gitlab.com/alicealysia
- **Ddubs** - https://gitlab.com/dwilliam62
- **Tyler Kelly** - https://gitlab.com/Zaney

Built with ❤️ for the Arch Linux community.
