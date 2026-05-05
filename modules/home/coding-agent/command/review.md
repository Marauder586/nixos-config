---
description: Review the current branch's diff against main.
agent: coder
---

# /review

1. `git fetch origin` then `git diff origin/main...HEAD`.
2. For each changed file, look for: bugs, missing error handling at trust
   boundaries, dead code, untested paths, security issues (injection,
   secrets, TOCTOU), perf cliffs (N+1, accidental O(n²)).
3. Output a markdown review:
   - **Blocking** issues (must fix before merge)
   - **Suggestions** (nice-to-have)
   - **Nits** (style / typos)
4. Cite each finding with `path:line` so the user can jump to it.

Do not push or rebase. Read-only.
