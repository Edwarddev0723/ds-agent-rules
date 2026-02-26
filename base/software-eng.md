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

---

## Testing Standards
- Minimum coverage: 80% for new code
- Unit tests must be isolated — no real DB, network, or filesystem calls (use mocks)
- Integration tests go in `tests/integration/` and are explicitly labeled
- Test naming: `test_{function}_{scenario}_{expected_outcome}`
- Every bug fix must include a regression test

---

## API / Service Rules
- All endpoints must be documented (OpenAPI / docstrings)
- Validate all inputs at the boundary — never trust external data
- Use proper HTTP status codes — don't return 200 for errors
- Rate limiting and auth must be considered from day one, not added later

---

## Dependency Management
- Pin all dependency versions in `pyproject.toml` or `requirements.txt`
- Regularly audit dependencies for security vulnerabilities
- Prefer stdlib over third-party when functionality is equivalent
- New dependencies must be justified — state the reason when adding them

---

## Deployment Checklist
- [ ] All tests passing
- [ ] No hardcoded secrets or env-specific values
- [ ] Migration scripts tested on staging
- [ ] Rollback plan documented
- [ ] Monitoring / alerting configured
