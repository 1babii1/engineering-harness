---
type: regex
target: { source: file, path: signup.py }
pattern: 'threading|Lock\('
match: not_contains
---
