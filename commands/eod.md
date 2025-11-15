---
description: End of day - commit and push all changes to GitHub
---

Please perform the end-of-day workflow:

1. Check if this is a git repository
   - If NOT a git repo, ask if I want to initialize one (git init)

2. Check git status to see what's changed
   - If there are changes, continue
   - If no changes, let me know and exit

3. Ask me for a commit message (suggest a default based on the changes)

4. Run: git add .

5. Run: git commit -m "[my message]"

6. Check if remote exists:
   - If NO remote: Ask if I want to add one (I'll provide the URL)
   - If remote EXISTS but branch not pushed: Run git push -u origin [branch]
   - If already tracking remote: Run git push

7. Confirm what was pushed and show the commit hash

Handle these edge cases gracefully:
- First commit in a new repo
- No remote configured yet
- Branch never pushed to remote
- Already up to date
