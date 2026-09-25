# Behavioural evals

Cases run with `claude plugin eval` against this plugin (skills + secrets hook), each in an empty
workspace built by `fixture.sh`. Graders are free checks (regex over the reply or produced files,
tool-call order and counts); no case uses a judge model.

```bash
claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit \
  --model haiku --runs 3 --max-cost-usd 5 --no-publish
```

What is and is not measured: only what the plugin ships (skills, hooks) is loaded in a run. A
project's own instruction file and personal settings are not, so they are not evaluated here.
