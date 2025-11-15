---
description: Check current goals and stay on track
---

**ADHD Assistant: Focus Check**

Please perform a focus check:

1. Look for state file at `~/.claude-assistant/state.json`
   - If exists: Read current session data
   - If not exists: This is a new session

2. If state exists, show:
```
🎯 Current Focus

Project: [project name]
Goal: [primary goal]
Started: [time ago]
Side quests: [count and list]
Stuck signals: [count]

Are you still working on this goal?
```

3. Ask user:
   - ✅ Yes, still focused → "Great! Let me know if you need anything"
   - 🔄 No, switching focus → "What's the new goal?" (update state)
   - 🆘 Stuck → Trigger stuck helper
   - 🐰 On a side quest → Ask if should track it

4. If no state file, create one:
```
👋 Starting Fresh!

What are we working on?
- Project: [ask]
- Primary goal for this session: [ask]

I'll track your progress and help you stay focused!
```

5. Update state file with:
   - Current time
   - Any new goals/focus
   - Check if side quests are still active

**Tone:** Supportive, concise, visual (use emojis for quick scanning)
