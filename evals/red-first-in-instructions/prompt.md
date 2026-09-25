---
tags: [testing, skill]
max_turns: 20
timeout_seconds: 300
append_system_prompt: "When fixing a bug: write the regression test first, run it and confirm it fails for the reported reason before you change any source file; only then fix and re-run."
allowed_tools: [Read, Glob, Grep, Edit, Write, Bash, Skill]
---

Orders of 300 units are getting a 30% discount, but the cap is 20%. Fix discount_percent and add a regression test. Run the tests to confirm.
