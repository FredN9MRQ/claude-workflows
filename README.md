# Claude Code Workflows

**Shared slash commands and ADHD-friendly productivity tools for Claude Code**

A collection of reusable slash commands, auto-discovery scripts, and productivity tools designed to work across all your Claude Code projects. Built with ADHD-friendly workflows in mind - consistent muscle memory, proactive assistance, and minimal friction.

---

## 🎯 What This Provides

### Productivity Commands
- **`/push`** - Quick commit and push with auto-generated messages
- **`/eod`** - End of day workflow (handles new repos, missing remotes, first-time pushes)
- **`/focus`** - Check current goals and stay on track *(coming soon)*
- **`/sidequest`** - Log tangents and decide if they should become projects *(coming soon)*
- **`/stuck`** - Get unstuck or pivot when spinning *(coming soon)*
- **`/reflect`** - End of session review *(coming soon)*

### Auto-Discovery Scripts
- Automatically finds all Claude Code projects on your system
- Sets up symlinked commands across all projects
- Works on Windows (PowerShell), Linux, macOS, and WSL
- Option to search entire drive or just user directory

### ADHD Assistant System *(in development)*
- Persistent goal tracking across sessions
- Proactive detection of scope drift and rabbit holes
- Gentle nudging when stuck or off-track
- Session continuity and reflection

---

## 🚀 Quick Start

```bash
# Clone this repo
git clone https://github.com/FredN9MRQ/claude-workflows.git
cd claude-workflows

# Copy to your home directory
cp -r . ~/claude-shared/

# Run auto-discovery script
~/claude-shared/setup-symlinks.sh
# OR on Windows PowerShell (as Admin):
# .\setup-symlinks.ps1
```

See **[QUICK-START.md](QUICK-START.md)** for detailed steps.

---

## 📖 Documentation

- **[QUICK-START.md](QUICK-START.md)** - ADHD-friendly checklist
- **[SETUP-GUIDE.md](SETUP-GUIDE.md)** - Comprehensive guide
- **README.md** - This file

---

## 🎨 Philosophy

Built around ADHD-friendly principles:

1. **Muscle Memory** - Same commands work everywhere
2. **Low Friction** - Auto-discovery, not manual configuration
3. **Proactive Help** - Assistant suggests when you're off-track
4. **Gentle Nudging** - Helps you stay focused without being pushy
5. **Celebration** - Recognizes completed work and side quests

---

## 🗺️ Roadmap

- [x] Core slash commands (/push, /eod)
- [x] Auto-discovery scripts
- [x] Cross-platform support
- [ ] ADHD assistant system
- [ ] Goal and deadline tracking
- [ ] Session continuity
- [ ] Proactive interventions

---

**Built with Claude Code (Sonnet 4.5) for ADHD-friendly development workflows**
