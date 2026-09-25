# engineering-harness

Project-scoped skills and enforcement hooks, meant to be installed alongside
[agent-harness](https://github.com/KirillSachkov/agent-harness): that project gives a project the
core engineering skills (spec-to-tickets, TDD, code review, debugging); this repo adds the
domain-specific defect checks and the two hooks that turn a couple of rules from text into
something actually enforced.

## What's here

**`skills/`** — six project-local skills, each written from a defect that actually shipped and the
test that closed it, not from general advice:

| Skill | Covers |
|---|---|
| `test-evidence` | Proving a regression test is real evidence: break the fix and watch it fail, seed past the boundary a check should catch, tell a broken suite from a flaky one |
| `postgres-ef` | EF Core migration hazards (a renamed column becomes drop+add), composite-index direction for `ORDER BY`, `CONCURRENTLY` failure modes |
| `auth-defects` | Enumeration, session revocation on credential change, external-identity pre-hijacking, step-up, key rotation, passwords, passkeys — eleven checks, each with the test that proves it |
| `dotnet-idioms` | C#/.NET coding rules plus library-idiom checks (EF Core, Dapper, ASP.NET Core, FluentValidation, Serilog, Kafka, Testcontainers) |
| `react-idioms` | React/TypeScript/Next.js coding rules plus library-idiom checks (TanStack Query, react-hook-form+zod, App Router) |
| `security-review` | OWASP-style trust-boundary review, routes into `auth-defects` when the system has login/session flows |

**`hooks/`** — Claude Code hooks that enforce two rules instead of just stating them:

- `guard-secrets.py` (`PreToolUse`): blocks reading, writing, editing, or grepping `.env*` (except
  `.env.example`), SOPS vaults, private keys, and shell commands that dump the environment
  (`env`, `printenv`, `export -p`, `/proc/*/environ`). Defense in depth over a regex, not a
  sandbox — documented gaps and their rationale are in the file's own header.
- `verify-on-stop.sh` (`Stop`): runs a configured verification command before a turn that changed
  files may end, and blocks the turn with the failure output if it fails. Off by default; a
  project opts in with `HARNESS_VERIFY_ON_STOP=1` in its own `.pi/project/commands.sh`.

## Install into a project

```bash
# after installing agent-harness's own skills:
mkdir -p .harness/skills
cp -r /path/to/engineering-harness/skills/* .harness/skills/
mkdir -p .harness/hooks
cp /path/to/engineering-harness/hooks/*.{py,sh} .harness/hooks/
chmod +x .harness/hooks/*.sh .harness/hooks/*.py
```

Then wire the hooks into `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|Edit|Write|MultiEdit|Grep|Glob|Bash|NotebookEdit",
        "hooks": [{ "type": "command", "command": "python3 \"$CLAUDE_PROJECT_DIR/.harness/hooks/guard-secrets.py\"" }]
      }
    ],
    "Stop": [
      {
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR/.harness/hooks/verify-on-stop.sh\"" }]
      }
    ]
  }
}
```

## Use as a plugin and run the evals

The repo is also a Claude Code plugin (`.claude-plugin/plugin.json`, skills, `hooks/hooks.json`):

```bash
claude --plugin-dir /path/to/engineering-harness     # try it in a session
claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit --model haiku --no-publish
```

`evals/` holds five behavioural cases; `evals/RESULTS.md` records what they measured and what they
do not.

## Conventions

- A skill earns a line only from a verified failure (an incident, a test that caught a defect, a
  review finding) with the test that proves it closed — not from advice a model already follows.
- Each skill points to the more general engineering skill it complements (`test-evidence` alongside
  `tdd`, `security-review` into `auth-defects`) instead of restating it.
- `guard-secrets.py` is a layer on top of real permissions/sandboxing, not a replacement for them —
  it works on command text, so it can be fooled by indirection; see its header for the exact gaps.
