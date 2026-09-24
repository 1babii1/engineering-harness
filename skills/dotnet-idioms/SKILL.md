---
name: dotnet-idioms
description: C#/.NET coding rules and library-idiom checks (EF Core, Dapper, ASP.NET Core, FluentValidation, Serilog, Kafka, Testcontainers). Use when writing or reviewing endpoints, async code, SQL/EF access, validation, or API contracts in this repository's backend services. `code-review` owns cross-cutting smells and repo-convention drift; this skill owns the .NET/library-specific rules.
---

# .NET idioms

## While writing

- Prefer idiomatic modern C# and nullable reference types.
- Prefer composition over inheritance.
- Avoid static mutable state and reflection without a clear reason.
- Use async for I/O; never block with `.Result` or `.Wait()`.
- Propagate `CancellationToken` through meaningful async boundaries.
- Do not wrap naturally async server I/O in `Task.Run`.
- Keep endpoints thin: transport, auth, validation, mapping, status codes.
- Keep business logic outside endpoints.
- Use correct HTTP semantics and consistent error responses.
- Do not expose persistence models as public API contracts.
- Treat API contracts as stable interfaces.
- Parameterize SQL and never concatenate user input.
- Select only required columns and avoid N+1 queries.
- Keep transactions short and only as broad as needed for atomicity.
- Prefer explicit mapping for simple DTOs.
- Follow the existing validation strategy; add FluentValidation only when it improves non-trivial validation.
- Do not add MediatR/CQRS unless the project already uses it or the problem benefits from it.
- Do not raise the analyzer/warning baseline: new code adds no new warnings; suppress a rule only
  with a documented reason at the narrowest scope.
- Validate options at startup (`ValidateOnStart`) instead of failing on first use; refuse to start
  in Production when a security-relevant setting is missing rather than falling back silently.
- Schema changes go through migrations; call the Skill tool with "postgres-ef" for migration review
  and safety rules.

## Library idiom

Check that the library is used as designed, not merely made to work. Apply only the bullets for
libraries this repository actually uses; not using one of them is not a finding.

- **EF Core**: `AsNoTracking` on read-only paths; composition kept in `IQueryable` rather than
  materialised early; `ExecuteUpdate`/`ExecuteDelete` instead of load-then-save for set operations;
  split queries for multiple collection includes; no hand-edited migrations.
- **Dapper**: parameters never interpolated; `CommandDefinition` carrying the cancellation token;
  no unbounded buffered reads.
- **ASP.NET Core**: binding and validation via the framework, not hand-parsed; `IOptions<T>` with
  `ValidateOnStart` instead of `IConfiguration[...]` reads scattered through code; cancellation
  tokens plumbed to every real I/O call; middleware ordering deliberate.
- **FluentValidation**: `.When()` applies to the whole preceding chain - a guard on a different
  property silently drops the rules before it. Check every `.When()` guards the property it is
  scoping.
- **Serilog**: message templates with named holes. String interpolation into a log message
  destroys structured logging - it is the single most common idiom break in .NET.
- **OpenTelemetry**: standard activity/metric naming rather than ad-hoc parallel telemetry.
- **Kafka clients**: explicit commit semantics, consumer disposal, no silent offset advance on
  failure - this repository's own `Shared/Kafka/KafkaRetryConsumer` already owns retry and
  dead-lettering; derive from it rather than re-implementing the loop.
- **Testcontainers/xUnit**: container reuse through a shared fixture, not one per test;
  `IAsyncLifetime` over constructor side effects.

## Performance findings need evidence

Report only where it is on a hot path and only with evidence:
- allocation in loops, `string` concatenation in loops, non-static/non-compiled regex;
- multiple enumeration of `IEnumerable`;
- sync-over-async and blocking calls on request paths;
- per-request rebuilding of graphs that could be cached or singleton;
- work done eagerly that the caller usually discards.

Do not report speculative micro-optimisation. If throughput is not plausibly affected, it is style,
not performance - leave it to `code-review`.

A finding without a citation is not reportable: cite the library's intended usage plus the call
site, or a named smell plus the quoted hunk. Findings are hypotheses - say which ones were verified
and how.
