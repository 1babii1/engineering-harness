---
name: react-idioms
description: React/TypeScript/Next.js coding rules and library-idiom checks (TanStack Query, react-hook-form+zod, App Router). Use when writing or reviewing frontend code in this repository. `code-review` owns cross-cutting smells and repo-convention drift; this skill owns the React/Next/library-specific rules.
---

# React idioms

## While writing

- Keep TypeScript strict. Avoid `any` and unsafe casts.
- Components should have one clear responsibility.
- Prefer composition and pure rendering.
- `useEffect` is for synchronization with external systems, not derived state or ordinary event
  handling.
- Use the smallest appropriate state owner:
  - local UI state -> `useState` / `useReducer`
  - server state -> TanStack Query
  - shared client-only state -> Zustand (or the project's existing equivalent) when it must cross
    components that do not share a parent
- Do not copy TanStack Query server state into another store without a concrete synchronization
  requirement.
- Use stable query keys and mutations for server writes.
- Invalidate or update the smallest relevant cache scope.
- Do not fetch manually in `useEffect` when TanStack Query should own the request.
- Do not add `useMemo`, `useCallback`, or `memo` without a measured or clear reason.
- Use existing shadcn/ui components before creating equivalents.
- Preserve semantic HTML, keyboard access, and accessibility.
- Prefer generated OpenAPI API types/clients instead of manually duplicating backend contracts.

## Next.js App Router

- Server Components by default; add `'use client'` only to the smallest subtree that actually
  needs state, effects, event handlers, or a browser API - not to a whole page or layout.
- Fetch data and read secrets/API keys in Server Components; do not pass them as props into a
  Client Component or import server-only modules from client code (guard with the `server-only`
  package if the boundary is not obvious from the file).
- Put context providers as deep in the tree as practical (wrapping `{children}`, not the whole
  `<html>`), so the static parts of the tree stay server-rendered.
- Route handlers are for what an external caller or webhook needs; page data fetching belongs in
  the Server Component, not a route handler called from an effect.
- When a BFF proxy owns backend access (the browser never holds a raw OAuth token), keep its
  allow-list of forwarded paths as the single authoritative record of what is actually wired up -
  check it directly before assuming a route reaches the backend.

## Library idiom

Apply only the bullets for libraries this repository actually uses.

- **TanStack Query**: query keys as structured arrays from a key factory, not ad-hoc strings;
  server data read straight from the cache instead of copied into `useState`/`useEffect`; `select`
  for derived shapes; one stable `QueryClient`, never constructed during render; deliberate
  `staleTime`/`gcTime` rather than defaults by accident; invalidation on mutation success instead
  of manual cache surgery; dependent queries examined for waterfalls.
- **React**: objects, arrays and functions not created inline in render when they cross a memo
  boundary; constants hoisted out of the component; `key` stable and not an index over a
  reordering list; effects only for synchronising with something outside React - anything
  derivable computed during render instead; every subscription cleaned up.
- **TypeScript**: no `any`, no `as unknown as`, no `@ts-ignore` without a documented boundary
  reason; discriminated unions instead of many optional fields; `satisfies` where a literal must
  keep its narrow type.
- **react-hook-form + zod**: schema as the single source of truth, resolver wired, no parallel
  manual validation, no controlled/uncontrolled mixing; server-side field errors applied back onto
  the form (see `applyEnvelopeErrors` in the canonical mutation form) rather than a generic toast.

## Render performance - with evidence, not reflex

- what actually triggers a re-render, and whether it is measurable;
- `memo`/`useMemo`/`useCallback` added without a memo boundary to protect - that is cost, not
  optimisation;
- long lists rendered without virtualisation;
- heavy modules imported statically where a dynamic import would do;
- sequential awaits that could run together.

Do not recommend memoisation unless you can name the boundary it protects.

A finding without a citation is not reportable: cite the library's intended usage plus the call
site, or a named smell plus the quoted hunk. Findings are hypotheses - say which ones were
verified and how.
