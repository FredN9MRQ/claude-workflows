# Gaming Rig Setup Guide

**Quick setup for your gaming rig - copy/paste these commands!**

---

## PowerShell Setup (Run as Administrator)

**Right-click PowerShell → "Run as Administrator"**

```powershell
# Clone infrastructure repo with submodules
git clone --recurse-submodules https://github.com/FredN9MRQ/infrastructure.git
cd infrastructure

# Copy claude-shared to your home directory
Copy-Item -Recurse claude-shared ~\claude-shared

# Run the auto-discovery script
cd ~\claude-shared
.\setup-symlinks.ps1

# Set up assistant state file
New-Item -ItemType Directory -Path ~\.claude-assistant -Force
Copy-Item .assistant\state.json.template ~\.claude-assistant\state.json
```

**What the script will do:**
1. Ask: "Search entire C:\ drive?"
   - Press `y` if your projects are scattered around
   - Press `n` (default) if they're all in your user folder
2. Show all Claude Code projects it finds
3. Ask for confirmation before creating symlinks
4. Set up all projects at once

---

## WSL Setup (If You Use WSL Too)

**After PowerShell setup, open WSL and run:**

```bash
# Find your Windows username first
WINDOWS_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
echo "Windows username: $WINDOWS_USER"

# WSL will use the Windows claude-shared folder automatically!
# Run the bash script
/mnt/c/Users/$WINDOWS_USER/claude-shared/setup-symlinks.sh

# Set up assistant state
mkdir -p ~/.claude-assistant
cp /mnt/c/Users/$WINDOWS_USER/claude-shared/.assistant/state.json.template ~/.claude-assistant/state.json
```

**Note:** WSL accesses Windows files at `/mnt/c/`, so both PowerShell and WSL projects share the same commands!

**If the auto-detection doesn't work, replace `$WINDOWS_USER` with your actual Windows username (e.g., `Fred`):**
```bash
# Manual version (replace Fred with your Windows username)
/mnt/c/Users/Fred/claude-shared/setup-symlinks.sh
mkdir -p ~/.claude-assistant
cp /mnt/c/Users/Fred/claude-shared/.assistant/state.json.template ~/.claude-assistant/state.json
```

---

## What You Get

**6 Slash Commands in ALL your Claude Code projects:**

### Git Workflow
- `/push` - Quick commit with auto-generated message
- `/eod` - End of day workflow (asks for commit message, handles new repos)

### ADHD Assistant
- `/focus` - Check what you're working on, stay aligned with goals
- `/sidequest` - Log a tangent explicitly (tracks time, checks in)
- `/stuck` - Get unstuck or pivot when spinning in circles
- `/reflect` - End of session review and celebration

---

## Verify It Worked

```powershell
# Check commands are installed
ls ~\claude-shared\commands\

# Should show:
# eod.md, focus.md, push.md, reflect.md, sidequest.md, stuck.md
```

In any Claude Code project, type `/` and you should see all 6 commands!

---

## Troubleshooting

**"Access Denied" when running script:**
- You need to run PowerShell as Administrator
- Right-click PowerShell → "Run as Administrator"

**"No projects found":**
- Start Claude Code in at least one project first (creates `.claude` folder)
- Or press `y` when asked to search entire drive

**Commands don't show up in Claude Code:**
- Restart Claude Code
- Check: `ls .claude\commands\` in your project directory

---

## Next Steps

Once set up:
1. Try `/focus` in any project
2. It will ask what you're working on
3. It'll track your session and help you stay focused!

**Your ADHD assistant is ready!** 🎯
