---
description: Log a tangent and decide if it should become a project
---

**ADHD Assistant: Side Quest Tracker**

Please help me track this side quest:

1. Read state file `~/.claude-assistant/state.json`

2. Ask me:
   - What's the side quest topic?
   - Why is it interesting/valuable right now?
   - Should I set a time limit? (default: 30 min)

3. Show confirmation:
```
🐰 Side Quest Logged!

Topic: [topic]
Reason: [why]
Time limit: [X] minutes
Started: [timestamp]

Original goal: [show main goal to keep visible]

Go explore! I'll check in at the time limit.
```

4. Add to state file:
```json
{
  "side_quests": [
    {
      "topic": "[topic]",
      "started_at": "[ISO timestamp]",
      "reason": "[reason]",
      "time_limit_minutes": 30,
      "status": "in_progress",
      "value_assessment": "pending"
    }
  ]
}
```

5. Set a mental reminder to check in after time limit

**When time limit reached** (user mentions it or I notice):
```
📊 Side Quest Check-In

Topic: [topic]
Time spent: [duration]

How's it going?
1. ✅ Wrapping up (mark complete)
2. ⏰ Need more time (extend)
3. 🎯 Make this its own project
4. 🔙 Park it and return to main goal

What feels right?
```

**Tone:** Encouraging - side quests aren't failures, they're valid exploration!
