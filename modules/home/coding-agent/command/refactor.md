---
description: Targeted refactor of selected files with tests.
agent: coder
---

# /refactor $ARGUMENTS

Refactor: **$ARGUMENTS**

1. Read the listed files end-to-end first.
2. Identify the smallest possible change set. Refuse to expand scope.
3. Apply edits. Keep public APIs stable unless asked otherwise.
4. Run the project's test suite. If there are no tests, write a minimal one
   that proves the refactor is behaviour-preserving.
5. Print the diff summary (`git diff --stat`) and a 2-line rationale.
