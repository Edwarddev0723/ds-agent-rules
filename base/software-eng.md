# Software Engineering Project Overlay
> Appended on top of core.md for traditional SE projects.

## Project Mindset
Correctness is deterministic. Every behavior should be testable and verifiable.
Prioritize: maintainability, test coverage, clear interfaces, and minimal coupling.

---

## Architecture Rules
- Follow SOLID principles — especially Single Responsibility and Dependency Inversion
- Prefer composition over inheritance
- Define clear interface boundaries between modules (use ABCs or Protocols)
- Public APIs must be stable — breaking changes require versioning
- Separate business logic from infrastructure (DB, HTTP, filesystem) — make core logic framework-agnostic

---

## Testing Standards
- Minimum coverage: 80% for new code
- Unit tests must be isolated — no real DB, network, or filesystem calls (use mocks)
- Integration tests go in `tests/integration/` and are explicitly labeled
- Test naming: `test_{function}_{scenario}_{expected_outcome}`
- Every bug fix must include a regression test
- Performance-sensitive paths: add benchmark tests with `pytest-benchmark` or equivalent
- Flaky tests are bugs — fix or quarantine immediately, never ignore

---

## API / Service Rules
- All endpoints must be documented (OpenAPI / docstrings)
- Validate all inputs at the boundary — never trust external data
- Use proper HTTP status codes — don't return 200 for errors
- Rate limiting and auth must be considered from day one, not added later
- Pagination: default page size ≤100, require explicit opt-in for larger
- Idempotency: all write operations should be safe to retry

---

## Observability
- Structured logging (JSON) — never raw print statements in production
- Request tracing: propagate trace IDs across service boundaries
- Health check endpoint: return dependency status, not just 200 OK
- Alert on error rate, latency p99, and saturation — not just availability
- Dashboard: every service must have one before going to production

---

## Dependency Management
- Pin all dependency versions in `pyproject.toml` or `requirements.txt`
- Regularly audit dependencies for security vulnerabilities (`pip-audit`, `safety`)
- Prefer stdlib over third-party when functionality is equivalent
- New dependencies must be justified — state the reason when adding them
- Lock files must be committed (`poetry.lock`, `package-lock.json`)

---

## Documentation Standards
- Every public function/class must have a docstring
- README must contain: purpose, setup, usage, architecture overview
- ADRs (Architecture Decision Records) for significant design choices
- API changelog for breaking changes — consumers need migration guides

---

## Deployment Checklist
- [ ] All tests passing (unit + integration)
- [ ] No hardcoded secrets or env-specific values
- [ ] Migration scripts tested on staging
- [ ] Rollback plan documented
- [ ] Monitoring / alerting configured
- [ ] Load test results reviewed (for user-facing services)
