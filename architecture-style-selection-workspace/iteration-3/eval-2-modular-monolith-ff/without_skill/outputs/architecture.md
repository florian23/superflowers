# Architecture: Modular Monolith

## Style Overview

A single deployable application composed of well-defined, loosely coupled modules with enforced boundaries. Each module owns its domain logic, data, and public API surface. Cross-module communication happens only through explicit public interfaces -- never by reaching into another module's internals.

## Module Structure

```
src/
  modules/
    compliance-rules/       # Rule definitions, rule engine
      public/               # Exported interfaces only
      internal/             # Hidden implementation
    audit-trail/            # Audit logging, history
      public/
      internal/
    reporting/              # Report generation, export
      public/
      internal/
    user-management/        # Auth, roles, permissions
      public/
      internal/
  shared/
    kernel/                 # Shared value objects, tiny shared types
```

## Architectural Rules

1. Modules communicate only through their `public/` interfaces
2. No module may reference another module's `internal/` package
3. Circular dependencies between modules are forbidden
4. The `shared/kernel` contains only immutable value objects -- no services, no repositories
5. Each module owns its own database tables (logical separation)

---

## Fitness Functions

### FF-1: Module Boundary Enforcement

| Field | Value |
|---|---|
| **Characteristic** | Maintainability |
| **Type** | Automated, triggered on every commit |
| **Metric** | Number of imports from any module's `internal/` package by code outside that module |
| **Threshold** | 0 violations |
| **Implementation** | Static analysis rule (e.g., ArchUnit, custom linter, or grep-based CI check) |

**Test logic** (pseudocode):
```
for each source file F:
  module_of_F = extract_module(F.path)
  for each import I in F:
    if I matches "modules/*/internal/*":
      target_module = extract_module(I)
      if target_module != module_of_F:
        FAIL("Module boundary violation: {F} imports internal of {target_module}")
```

**Why**: The defining property of a modular monolith is enforced module boundaries. If internals leak across boundaries, the architecture degrades into a traditional monolith. This fitness function is the single most important architectural guard.

---

### FF-2: No Circular Module Dependencies

| Field | Value |
|---|---|
| **Characteristic** | Maintainability |
| **Type** | Automated, triggered on every commit |
| **Metric** | Number of dependency cycles between modules |
| **Threshold** | 0 cycles |
| **Implementation** | Dependency graph analysis (e.g., ArchUnit, Madge, custom script) |

**Test logic** (pseudocode):
```
graph = build_module_dependency_graph()
cycles = detect_cycles(graph)
assert cycles.count == 0, "Circular dependencies found: {cycles}"
```

**Why**: Circular dependencies between modules destroy independent testability and create hidden coupling. They are the first symptom of architectural erosion in a modular monolith.

---

### FF-3: Test Coverage Per Module

| Field | Value |
|---|---|
| **Characteristic** | Testability |
| **Type** | Automated, triggered on every PR |
| **Metric** | Line coverage percentage per module |
| **Threshold** | >= 90% per module (no module may fall below) |
| **Implementation** | Coverage tool (JaCoCo, Istanbul, coverage.py) with per-directory thresholds |

**Test logic** (pseudocode):
```
for each module M in modules/:
  coverage = measure_coverage(M)
  assert coverage >= 90%, "Module {M} coverage is {coverage}%, must be >= 90%"
```

**Why**: Regulatory compliance requires high test coverage. Measuring per-module (not globally) prevents a well-tested module from masking an untested one. This directly supports the >90% coverage requirement from the architecture characteristics.

---

### FF-4: Module Size Limit

| Field | Value |
|---|---|
| **Characteristic** | Simplicity |
| **Type** | Automated, triggered on every PR |
| **Metric** | Lines of code per module (excluding tests) |
| **Threshold** | <= 2000 LOC per module |
| **Implementation** | Simple line-counting script in CI |

**Test logic** (pseudocode):
```
for each module M in modules/:
  loc = count_lines(M, exclude="*_test*")
  assert loc <= 2000, "Module {M} has {loc} LOC, exceeds 2000 limit"
```

**Why**: For a solo developer, large modules become unmanageable. A size limit forces decomposition into comprehensible units and signals when a module should be split. The 2000 LOC threshold balances granularity with practicality.

---

### FF-5: Shared Kernel Size Limit

| Field | Value |
|---|---|
| **Characteristic** | Maintainability |
| **Type** | Automated, triggered on every PR |
| **Metric** | Number of types in `shared/kernel/` |
| **Threshold** | <= 15 types |
| **Implementation** | Script counting exported type definitions |

**Test logic** (pseudocode):
```
type_count = count_exported_types("shared/kernel/")
assert type_count <= 15, "Shared kernel has {type_count} types, max is 15"
```

**Why**: The shared kernel is a coupling magnet. If it grows unchecked, every module depends on everything and changes ripple everywhere. A strict cap forces developers to keep shared types minimal and push domain logic into modules.

---

### FF-6: Build Time Budget

| Field | Value |
|---|---|
| **Characteristic** | Simplicity |
| **Type** | Automated, triggered on every PR |
| **Metric** | Total build + test time |
| **Threshold** | <= 120 seconds |
| **Implementation** | CI pipeline timer |

**Test logic** (pseudocode):
```
start = now()
run_build_and_tests()
elapsed = now() - start
assert elapsed <= 120s, "Build took {elapsed}s, exceeds 120s budget"
```

**Why**: A solo developer's productivity depends on fast feedback loops. If the build exceeds 2 minutes, the developer loses flow. This fitness function ensures the monolith stays fast to build and test as it grows.

---

## Summary Table

| # | Fitness Function | Characteristic | Trigger | Threshold |
|---|---|---|---|---|
| FF-1 | Module Boundary Enforcement | Maintainability | Every commit | 0 violations |
| FF-2 | No Circular Dependencies | Maintainability | Every commit | 0 cycles |
| FF-3 | Test Coverage Per Module | Testability | Every PR | >= 90% per module |
| FF-4 | Module Size Limit | Simplicity | Every PR | <= 2000 LOC |
| FF-5 | Shared Kernel Size Limit | Maintainability | Every PR | <= 15 types |
| FF-6 | Build Time Budget | Simplicity | Every PR | <= 120 seconds |
