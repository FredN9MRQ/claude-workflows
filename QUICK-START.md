# Quick Start - Claude Commands Setup

**ADHD-Friendly Version: Just the steps, no fluff**

---

## ☑️ New Machine Setup (5 minutes)

### 1. Get the files

```bash
# Clone the infrastructure repo
git clone https://github.com/YOUR-USERNAME/infrastructure.git

# Copy scripts to home directory
cp -r infrastructure/claude-shared ~/
```

### 2. Run the script

**Linux/Mac/WSL:**
```bash
chmod +x ~/claude-shared/setup-symlinks.sh
~/claude-shared/setup-symlinks.sh
```

**Windows PowerShell (Run as Admin):**
```powershell
cd ~\claude-shared
.\setup-symlinks.ps1
```

### 3. Answer the questions

```
Search entire drive? [y/N]
→ Press 'y' if projects might be in weird places
→ Press 'n' (default) if all in your home folder

Set up symlinks for all projects? [y/N]
→ Press 'y'
```

### 4. Done!

Test it: Open Claude Code, type `/push` or `/eod`

---

## ☑️ Add New Command (30 seconds)

### Create the command
```bash
nano ~/claude-shared/commands/review.md
# Write your command prompt
# Save and exit
```

### Sync to other machines
```bash
# Option 1: Direct copy
scp ~/claude-shared/commands/review.md user@machine:~/claude-shared/commands/

# Option 2: Via git (if you track claude-shared in a repo)
git add claude-shared/commands/review.md
git commit -m "Add review command"
git push
# Then on other machines: git pull && copy file
```

---

## ☑️ Troubleshooting

| Problem | Solution |
|---------|----------|
| Commands not showing | Restart Claude Code |
| "Permission denied" (Windows) | Run PowerShell as Administrator |
| No projects found | Start Claude Code in a project first (creates `.claude` folder) |
| WSL symlinks broken | Use PowerShell script instead, or just copy files |

---

## ☑️ Machine Checklist

- [ ] Current laptop (Windows) - ✓ DONE
- [ ] Gaming rig (PowerShell)
- [ ] Gaming rig (WSL)
- [ ] VPS (Linux)
- [ ] Mac

---

## Commands You Have

- `/push` - Quick commit and push (auto-generates message)
- `/eod` - End of day (asks for message, handles new repos)

---

**Full docs:** See `SETUP-GUIDE.md` for detailed explanations
