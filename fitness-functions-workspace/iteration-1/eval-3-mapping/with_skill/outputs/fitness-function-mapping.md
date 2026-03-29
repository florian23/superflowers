# Fitness Function Mapping

Derived from `/tmp/ff-eval-1/architecture.md`.
Project: **JavaScript (Node.js) with Jest** (`package.json` confirms Jest ^29).

---

## 1. Modularity -- No Circular Dependencies

| Attribute        | Value                                                    |
|------------------|----------------------------------------------------------|
| **Source**        | architecture.md: Modularity, Priority Critical           |
| **Concrete Goal** | No circular dependencies between modules                |
| **FF Type**       | Code Structure / Atomic / Triggered on commit            |
| **Tool**          | **dependency-cruiser**                                   |
| **Cadence**       | Every commit (CI) or pre-commit hook                     |

**Implementation approach:**

```javascript
// .dependency-cruiser.cjs
module.exports = {
  forbidden: [{
    name: "no-circular",
    severity: "error",
    from: {},
    to: { circular: true }
  }]
};
```

**Run command:**
```bash
npx depcruise --config .dependency-cruiser.cjs src
```

**Pass criterion:** Exit code 0 (no circular dependency violations found).

---

## 2. Testability -- >80% Test Coverage

| Attribute        | Value                                                    |
|------------------|----------------------------------------------------------|
| **Source**        | architecture.md: Testability, Priority Critical          |
| **Concrete Goal** | >80% coverage (branches, functions, lines)              |
| **FF Type**       | Coverage / Atomic / Triggered on commit                  |
| **Tool**          | **Jest with --coverage and coverageThreshold**           |
| **Cadence**       | Every commit (CI)                                        |

**Implementation approach:**

```javascript
// jest.config.js (or in package.json under "jest")
{
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80
    }
  }
}
```

**Run command:**
```bash
npx jest --coverage
```

**Pass criterion:** Jest exits with code 0; all three coverage dimensions (branches, functions, lines) >= 80%.

---

## 3. Performance -- API <500ms p95

| Attribute        | Value                                                    |
|------------------|----------------------------------------------------------|
| **Source**        | architecture.md: Performance, Priority Important         |
| **Concrete Goal** | API response time < 500ms at the 95th percentile        |
| **FF Type**       | Performance / Holistic / Triggered on PR                 |
| **Tool**          | **autocannon** (or k6 for more complex scenarios)        |
| **Cadence**       | On pull request (requires running server)                |

**Implementation approach:**

```javascript
// fitness/performance.test.js
const autocannon = require('autocannon');

test('API response time < 500ms p95', async () => {
  const result = await autocannon({
    url: 'http://localhost:3000/api/endpoint',
    connections: 10,
    duration: 10
  });
  expect(result.latency.p95).toBeLessThan(500);
}, 30000);
```

**Run command:**
```bash
# Start the server first, then:
npx jest fitness/performance.test.js
```

**Pass criterion:** p95 latency reported by autocannon is strictly below 500ms.

---

## Summary Table

| # | Characteristic | Goal                    | Tool               | Type     | Cadence   |
|---|---------------|-------------------------|--------------------|---------:|----------:|
| 1 | Modularity     | No circular deps        | dependency-cruiser | Atomic   | On commit |
| 2 | Testability    | >80% coverage           | Jest --coverage    | Atomic   | On commit |
| 3 | Performance    | API <500ms p95          | autocannon         | Holistic | On PR     |

All three characteristics are marked "Fitness Function: Yes" in architecture.md and therefore require automated verification before any implementation can be considered complete.
