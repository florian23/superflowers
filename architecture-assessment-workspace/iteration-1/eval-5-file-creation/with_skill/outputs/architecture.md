# Architecture Characteristics

## Last Updated: 2026-03-28

## Top 3 Priority Characteristics
1. **Testability** -- Unit and integration tests cover all validation paths, edge cases, and error conditions; target >90% code coverage
2. **Reliability** -- Zero crashes on any input; graceful handling of malformed, empty, oversized, and binary files with clear error reporting
3. **Usability** -- Actionable error messages with line/column numbers for syntax errors; standard exit codes (0 = valid, 1 = invalid, 2 = file error); --help with usage examples

## All Characteristics

### Operational
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---------------|----------|---------------|-----------------|
| Availability | Irrelevant | CLI tool, runs on demand | No |
| Performance | Nice-to-have | Validate files <10MB in <1s | No |
| Scalability | Irrelevant | Single-user CLI, no concurrency | No |
| Reliability | Important | Zero crashes on any input, clear errors for all failure modes | Yes - fuzz testing with malformed inputs |
| Fault Tolerance | Irrelevant | No partial failure scenarios | No |

### Structural
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---------------|----------|---------------|-----------------|
| Modularity | Important | Separate CLI parsing, file I/O, and validation logic into distinct modules; no circular dependencies | Yes - dependency check |
| Extensibility | Nice-to-have | Plugin point for future schema validation or custom rules | No |
| Testability | Critical | >90% code coverage; all error paths tested; property-based tests for parser edge cases | Yes - coverage gate in CI |
| Deployability | Nice-to-have | Single binary or single-command install | No |
| Coupling | Irrelevant | No external system integrations | No |

### Cross-Cutting
| Characteristic | Priority | Concrete Goal | Fitness Function |
|---------------|----------|---------------|-----------------|
| Security | Irrelevant | Reads local files only, no auth, no network | No |
| Compliance | Irrelevant | No regulatory requirements | No |
| Accessibility | Irrelevant | CLI tool, not a UI | No |
| Usability | Important | Error messages include file path, line/column of first error; exit codes: 0=valid, 1=invalid, 2=file error; --help flag with examples | Yes - integration tests verify exit codes and message format |
| Observability | Irrelevant | stdout/stderr sufficient for CLI tool | No |

## Architecture Drivers
- **Correctness over features**: A JSON validator that produces wrong results is worse than having no validator. Testability is the top driver because every validation path must be verified.
- **Robustness on untrusted input**: Users will point this tool at arbitrary files. It must never crash, hang, or produce confusing output. This drives the reliability characteristic.
- **Developer experience as user experience**: The tool's entire value is in its output messages. Clear, precise error reporting with location information drives the usability characteristic.
- **Simplicity**: No database, no network, no multi-user concerns. The architecture should reflect this simplicity -- avoid over-engineering patterns that add complexity without addressing the top-3 characteristics.

## Architecture Decisions
- **Three-layer structure (CLI / Validation / File I/O)**: Keeps validation logic pure and independently testable, addressing testability and modularity. CLI layer handles argument parsing and output formatting. File I/O layer handles reading and encoding detection. Validation layer is a pure function: bytes/string in, result out.
- **No framework dependency for core logic**: The JSON validation logic should depend only on the language's standard library JSON parser (or a well-tested parsing library). This minimizes coupling and maximizes reliability.
- **Structured error types, not strings**: Validation errors are typed data (with file, line, column, message) that the CLI layer formats for display. This supports testability (errors can be asserted on programmatically) and usability (consistent, parseable output).
- **Exit code convention**: 0 = all files valid, 1 = at least one file invalid, 2 = operational error (file not found, permission denied, etc.). Standard Unix convention supports scripting and CI integration.

## Changelog
- 2026-03-28: Initial architecture assessment for JSON file validation CLI tool
