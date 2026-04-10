---
name: Do not use full-stack-developer agent
description: User prefers Claude to implement code directly, not delegate to full-stack-developer subagent
type: feedback
---

Do not use the `full-stack-developer` subagent for implementation tasks. Implement code directly in the main conversation.

**Why:** User explicitly rejected the full-stack-developer agent tool use and said to use own subagents instead (or just implement directly).

**How to apply:** When writing code, use Read/Edit/Write/Bash tools directly. Only spawn lightweight subagents (Explore, Plan) for research if needed — never delegate actual code writing to full-stack-developer.
