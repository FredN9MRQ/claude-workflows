# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **shared commands and workflow system** for Claude Code that provides:
- Reusable slash commands that work across all Claude Code projects
- Auto-discovery scripts that set up symlinks to shared commands
- ADHD-friendly productivity tools and assistant behaviors
- Cross-platform support (Windows, Linux, macOS, WSL)

**Key Philosophy:** Muscle memory - the same commands work everywhere through symlinks, not duplication.

## Architecture

### Command Distribution System

```
~/claude-shared/                    # Canonical source (user's home directory)
├── commands/                       # Shared .md files (slash commands)
│   ├── push.md
│   ├── eod.md
│   ├── focus.md
│   └── ...
└── setup-symlinks.{sh,ps1}        # Auto-discovery scripts

~/project1/.claude/commands/        # Symlink → ~/claude-shared/commands/
~/project2/.claude/commands/        # Symlink → ~/claude-shared/commands/
~/projectN/.claude/commands/        # Symlink → ~/claude-shared/commands/
```

**How it works:**
1. User runs `setup-symlinks.sh` (bash) or `setup-symlinks.ps1` (PowerShell)
2. Script searches filesystem for all `.claude` directories (Claude Code projects)
3. Creates symlinks from each project's `.claude/commands/` → `~/claude-shared/commands/`
4. Result: One command file update propagates to ALL projects instantly

### ADHD Assistant System (In Development)

Located in `.assistant/`:
- `personality.md` - Defines assistant behavior, intervention thresholds, communication style
- `state.json.template` - Template for persistent state tracking across sessions
- Actual state file lives at `~/.claude-assistant/state.json` on user's machine

## Setup Scripts

### `setup-symlinks.sh` (Linux/Mac/WSL)

**What it does:**
- Recursively searches for `.claude` directories
- Offers choice: search entire drive vs. user directory only
- Creates symlinks to `~/claude-shared/commands/` in each project
- Backs up existing commands directories before replacing
- Handles WSL by auto-detecting Windows username and using `/mnt/c/Users/$USER/claude-shared/`

**Usage:**
```bash
chmod +x ~/claude-shared/setup-symlinks.sh
~/claude-shared/setup-symlinks.sh
```

### `setup-symlinks.ps1` (Windows PowerShell)

**What it does:**
- Same as bash version but for Windows
- **Requires Administrator privileges** (Windows symlinks need elevated permissions)
- Searches user profile by default, optionally searches entire C:\ drive
- Creates Windows symlinks that work across PowerShell and WSL

**Usage:**
```powershell
# Must run PowerShell as Administrator
cd ~\claude-shared
.\setup-symlinks.ps1
```

**Key Implementation Detail:**
- Uses `New-Item -ItemType SymbolicLink` which requires admin rights on Windows
- Script checks for admin privileges and exits with helpful message if not elevated

## Slash Commands

All commands are in `commands/*.md` files. They use Claude Code's slash command format with frontmatter:

```markdown
---
description: Brief description shown in autocomplete
---

Prompt text that tells Claude what to do when this command is invoked.
```

### Existing Commands

**`/push`** - Quick commit and push
- Auto-generates commit message based on changed files
- No confirmation required - fast workflow
- Runs: `git add .`, `git commit -m "[message]"`, `git push`

**`/eod`** - End of day workflow
- Handles edge cases: new repos, missing remotes, first-time pushes
- Asks user for commit message
- Gracefully handles uninitialized repos and missing remote configurations

**ADHD Assistant Commands (Planned):**
- `/focus` - Check current goals and alignment
- `/sidequest` - Log tangents explicitly
- `/stuck` - Get unstuck or pivot
- `/reflect` - End of session review

## ADHD Assistant Personality

Defined in `.assistant/personality.md`. Key behaviors Claude should follow:

### Core Principles
1. **Proactive, Not Reactive** - Notice patterns, intervene when helpful
2. **Gentle Nudging** - Suggest, don't command
3. **Celebrate Wins** - Acknowledge all completions
4. **No Judgment** - Side quests are valid exploration

### Intervention Triggers
- **Scope Drift:** Working on something unrelated to stated goal
- **Stuck Patterns:** Same problem mentioned 3+ times or 30+ min without progress
- **Side Quest Time Limit:** 30+ minutes on tangent
- **Circling:** Revisiting same topic without progress

### Communication Style
- **Concise** - Brevity over paragraphs
- **Visual** - Use emojis for quick scanning (🎯 🐰 ⚠️ ✅)
- **Structured** - Bullet points and clear options (1, 2, 3)
- **Supportive** - Never judgmental, always encouraging

### State Tracking
When ADHD commands are used, Claude should:
- Read/write `~/.claude-assistant/state.json`
- Track current session, goals, side quests, stuck signals
- Update state when focus changes or milestones hit

## Development Workflow

### Adding a New Command

1. Create new `.md` file in `commands/`:
   ```bash
   nano ~/claude-shared/commands/mycommand.md
   ```

2. Add frontmatter and prompt:
   ```markdown
   ---
   description: What this command does
   ---

   Prompt text for Claude...
   ```

3. Command instantly available in ALL projects (via symlinks)

### Testing Commands

Open any Claude Code project, type `/` and the new command appears in autocomplete.

### Syncing to Other Machines

**Option 1:** Direct copy
```bash
scp ~/claude-shared/commands/newcmd.md user@machine:~/claude-shared/commands/
```

**Option 2:** Git (if tracking claude-shared in a repo)
```bash
git add claude-shared/commands/newcmd.md
git commit -m "Add new command"
git push
# On other machines: git pull && cp to ~/claude-shared/
```

## Platform-Specific Notes

### Windows + WSL Dual Setup

Best approach for gaming rig with both environments:

1. **Run PowerShell script first (as Admin)**
   - Creates Windows symlinks in Windows projects
   - Sets up `C:\Users\[user]\claude-shared\commands\`

2. **Run bash script in WSL**
   - Auto-detects Windows username via `cmd.exe /c "echo %USERNAME%"`
   - Uses `/mnt/c/Users/$WINDOWS_USER/claude-shared/commands/`
   - Both environments share the same command files!

### VPS/Server Setup

Projects often in root-owned directories (`/var/www/`, `/opt/`, `/srv/`):
- Always use `-SearchAll` or answer `y` when asked to search entire drive
- Script finds projects in root-owned locations
- May need to run with sudo if creating symlinks in protected directories

### Mac

Identical to Linux - symlinks work perfectly without admin privileges.

## User Context

**User:** Fred
**Has ADHD** - This repo's entire purpose is supporting ADHD-friendly workflows
**Multi-machine setup:**
- Current laptop (Windows) - ✓ DONE
- Gaming rig (Windows PowerShell + WSL) - Pending
- VPS (Linux) - Pending
- Mac - Pending

**Related infrastructure:** User has separate `infrastructure` repo for homelab (Proxmox, networking, etc.)

## When Working in This Repo

### Do NOT:
- Suggest duplicating command files into individual projects
- Recommend copying commands instead of symlinking (defeats the purpose)
- Add complexity that breaks the "muscle memory everywhere" goal
- Make assumptions about where user's projects are located

### DO:
- Maintain simplicity - this is about reducing friction
- Preserve cross-platform compatibility (bash + PowerShell)
- Follow ADHD assistant personality when those features are active
- Test that commands work from any project directory
- Keep documentation ADHD-friendly (concise, visual, structured)

### When Adding Features:
- Consider impact on muscle memory consistency
- Test on all platforms (Windows, Linux, WSL, Mac)
- Update both setup scripts if changing command structure
- Keep personality.md updated if changing assistant behaviors
- Remember: simpler is better for ADHD workflows

## Documentation Structure

- **README.md** - High-level overview, philosophy, roadmap
- **QUICK-START.md** - ADHD-friendly checklist (minimal text, just steps)
- **SETUP-GUIDE.md** - Comprehensive guide with troubleshooting
- **GAMING-RIG-SETUP.md** - Copy/paste commands for specific machine
- **CLAUDE.md** (this file) - Context for Claude Code

Keep all docs concise and scannable - Fred's ADHD brain appreciates brevity.
