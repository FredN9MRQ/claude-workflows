# Claude Commands Setup Guide

**Goal:** Get `/push` and `/eod` commands working on ALL your Claude Code projects across ALL your machines.

**Time:** ~5 minutes per machine (first time), ~30 seconds for future machines

---

## Quick Reference

**What this does:**
- Automatically finds all your Claude Code projects (anywhere on the drive)
- Sets up shared slash commands (`/push`, `/eod`)
- Works across VSCode and standalone Claude Code
- Muscle memory works the same everywhere

**Machines to set up:**
- [ ] Current laptop (Windows) - ✓ DONE
- [ ] Gaming rig (Windows PowerShell)
- [ ] Gaming rig (WSL)
- [ ] VPS (Linux)
- [ ] Mac

---

## Setup: New Machine (First Time)

### Step 1: Get the Scripts

**Option A: Clone from Git** (Recommended)
```bash
# Clone your infrastructure repo (which has the scripts)
git clone https://github.com/YOUR-USERNAME/infrastructure.git
cd infrastructure

# Copy the claude-shared folder to your home directory
cp -r claude-shared ~/
```

**Option B: Download from GitHub**
```bash
# Go to: https://github.com/YOUR-USERNAME/infrastructure
# Download claude-shared folder
# Extract to: ~/claude-shared or C:\Users\[you]\claude-shared
```

**Option C: Copy from Another Machine**
```bash
# From current machine
scp -r ~/claude-shared user@other-machine:~/

# Or use USB drive, etc.
```

### Step 2: Verify You Have the Files

```bash
ls ~/claude-shared/
# Should show:
#   commands/
#   setup-symlinks.sh
#   setup-symlinks.ps1
#   README.md
#   SETUP-GUIDE.md

ls ~/claude-shared/commands/
# Should show:
#   eod.md
#   push.md
```

### Step 3: Run the Setup Script

**On Linux/Mac/WSL:**
```bash
chmod +x ~/claude-shared/setup-symlinks.sh
~/claude-shared/setup-symlinks.sh
```

**On Windows PowerShell:**
```powershell
# Right-click PowerShell -> Run as Administrator
cd C:\Users\[your-username]\claude-shared
.\setup-symlinks.ps1
```

### Step 4: Answer the Prompts

```
Search entire drive? (slower but thorough) [y/N]
```
- Press `n` if all your Claude projects are in your home directory
- Press `y` if you might have projects in weird places (root, /var, /opt, etc.)

```
Found 3 Claude Code project(s):
  ○ /home/user/projects/webapp (needs setup)
  ○ /home/user/dev/api (needs setup)
  ✓ /home/user/work/app (already linked)

Set up symlinks for all projects? [y/N]
```
- Press `y` to set up commands for all found projects

### Step 5: Verify It Worked

```bash
cd /path/to/any/project
ls .claude/commands/
# Should show: eod.md, push.md
```

**Test the commands in Claude Code:**
- Type `/` and you should see `/push` and `/eod` in the suggestions
- Run `/push` to test (it'll say "no changes" if working tree is clean)

---

## Quick Setup: Machine Already Has Scripts

If you've already set up `~/claude-shared/` on this machine before:

```bash
# Just run the script again - it finds any NEW projects
~/claude-shared/setup-symlinks.sh

# Or manually link a single new project:
cd /path/to/new/project
ln -s ~/claude-shared/commands .claude/commands
```

---

## Adding New Commands (All Machines)

### Add to One Machine

```bash
# Create new command on any machine
nano ~/claude-shared/commands/review.md
# (Add your slash command prompt)
```

### Sync to Other Machines

```bash
# Copy the new command file to other machines
scp ~/claude-shared/commands/review.md user@other-machine:~/claude-shared/commands/

# That's it! All projects on that machine now have it (via symlinks)
```

**Or use Git:**
```bash
# Commit the infrastructure repo changes
cd ~/infrastructure  # or wherever you keep it
cp ~/claude-shared/commands/*.md ./claude-shared/commands/
git add claude-shared/commands/
git commit -m "Add new Claude command: review"
git push

# On other machines:
cd ~/infrastructure
git pull
cp claude-shared/commands/*.md ~/claude-shared/commands/
```

---

## Troubleshooting

### "Commands not showing up in Claude Code"

1. Verify symlink exists:
   ```bash
   ls -la .claude/commands/
   ```

2. Restart Claude Code

3. Check file permissions:
   ```bash
   ls -la ~/claude-shared/commands/
   # Files should be readable (r--)
   ```

### "Permission denied" (Windows PowerShell)

- Must run PowerShell as Administrator to create symlinks
- Right-click PowerShell → "Run as Administrator"

### "Symlinks not working" (WSL)

WSL can't create proper symlinks to Windows filesystem. Options:

**Option A:** Keep commands in actual folders (not symlinks)
```bash
# Just copy the files instead
cp ~/claude-shared/commands/*.md .claude/commands/
```

**Option B:** Use PowerShell script instead (creates Windows symlinks that WSL can use)

### "Script says 'No projects found'"

- Make sure you've started Claude Code in at least one project directory first
- Claude Code creates the `.claude` folder - that's what the script looks for
- Try searching entire drive (`y` when prompted)

### "I have projects on different drives" (D:\, E:\, etc.)

Edit the script and add additional search paths:

**PowerShell:**
```powershell
# In setup-symlinks.ps1, add:
$additionalPaths = @("D:\", "E:\Projects")
foreach ($path in $additionalPaths) {
    Get-ChildItem -Path $path -Directory -Recurse -Filter ".claude" ...
}
```

---

## Machine-Specific Notes

### Gaming Rig (Windows with WSL)

**Best approach:** Shared folder accessible to both

1. Create in Windows: `C:\Users\[you]\claude-shared\commands`
2. Run PowerShell script as Admin (sets up Windows projects)
3. In WSL, script auto-detects and uses `/mnt/c/Users/[you]/claude-shared/commands`
4. Run bash script in WSL (sets up WSL projects)

**Result:** Both environments share the same command files!

### VPS (Linux)

Projects often in `/var/www/`, `/opt/`, `/srv/`:
- **Always press `y`** when asked to search entire drive
- Script will find projects in root locations

### Mac

Same as Linux, works perfectly with symlinks:
```bash
chmod +x ~/claude-shared/setup-symlinks.sh
~/claude-shared/setup-symlinks.sh
```

---

## Reference: Manual Setup (Single Project)

If you just want to set up ONE project manually:

**Linux/Mac/WSL:**
```bash
cd /path/to/project
mkdir -p .claude
ln -s ~/claude-shared/commands .claude/commands
```

**Windows PowerShell (as Admin):**
```powershell
cd C:\path\to\project
mkdir .claude -Force
New-Item -ItemType SymbolicLink -Path .claude\commands -Target C:\Users\[you]\claude-shared\commands
```

**Windows (Copy instead of symlink):**
```powershell
cd C:\path\to\project
mkdir .claude -Force
Copy-Item -Recurse C:\Users\[you]\claude-shared\commands .claude\
```

---

## What's Next?

Once set up on all machines, your workflow is:

1. **Work in any project** → type `/push` or `/eod` → profit
2. **Add new command** → create .md file in `~/claude-shared/commands/`
3. **Sync to other machines** → copy that one .md file (or git pull)

**Muscle memory achieved!** 🎯
