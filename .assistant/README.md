# ADHD Assistant System

This directory contains the behavior rules and state management for the ADHD-friendly assistant features in Claude Code Workflows.

## Files

### `personality.md`
Defines how Claude Code should interact with you:
- Intervention thresholds (when to speak up)
- Communication style and tone
- Session management rules
- Command behaviors
- Success patterns to track

**This file is the "personality" of your assistant.**

### `state.json.template`
Template for the state tracking file that will live in `~/.claude-assistant/state.json` on your machine.

Tracks:
- Current session (project, goal, focus)
- Active side quests
- Stuck signals and patterns
- Session history

### Setup

The assistant system uses a state file at:
```
~/.claude-assistant/state.json
```

**First time setup:**
```bash
# Create the assistant directory
mkdir -p ~/.claude-assistant

# Copy the template
cp .assistant/state.json.template ~/.claude-assistant/state.json

# Optional: Customize your preferences
nano ~/.claude-assistant/state.json
```

## How It Works

1. **Slash Commands** interact with the state file:
   - `/focus` - Check current goal and alignment
   - `/sidequest` - Log a tangent explicitly
   - `/stuck` - Get unstuck or pivot
   - `/reflect` - End of session review

2. **State Tracking** persists across sessions:
   - Goals and focus
   - Side quests (active and completed)
   - Stuck moments and patterns
   - Session history

3. **Proactive Interventions** (coming soon):
   - Detects scope drift automatically
   - Notices stuck patterns
   - Suggests when to pivot or pause
   - Celebrates completions

## Customization

Edit `personality.md` to adjust:
- `stuck_threshold` - How many times before strong intervention (default: 3)
- `sidequest_time_limit_minutes` - When to check in (default: 30)
- `intervention_style` - "gentle" (default) | "assertive" | "minimal"
- `celebrates_completions` - true (default) | false

Edit your `~/.claude-assistant/state.json` to set preferences:
```json
{
  "user": {
    "name": "Fred",
    "preferences": {
      "intervention_style": "gentle",
      "stuck_threshold": 3,
      "sidequest_time_limit_minutes": 30,
      "celebrates_completions": true
    }
  }
}
```

## Philosophy

The assistant works **with** your ADHD, not against it:
- Side quests are valid exploration (not failures)
- Stuck moments are learning opportunities
- Focus is a spectrum, not binary
- Progress isn't always linear
- Small wins deserve celebration

**The goal: Awareness and gentle guidance, not rigid control.**
