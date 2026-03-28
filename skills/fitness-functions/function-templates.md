# Fitness Function Templates

Templates for common architecture characteristics. Adapt to the project's language and tooling.

## Code Structure / Dependencies

### No Circular Dependencies

**JS/TS (dependency-cruiser):**
```json
// .dependency-cruiser.cjs
module.exports = {
  forbidden: [{
    name: "no-circular",
    severity: "error",
    from: {},
    to: { circular: true }
  }]
};
// Run: npx depcruise --config .dependency-cruiser.cjs src
```

**Java (ArchUnit):**
```java
@ArchTest
static final ArchRule noCycles =
    slices().matching("com.example.(*)..").should().beFreeOfCycles();
```

**Python (import-linter):**
```ini
# .importlinter
[importlinter]
root_package = myapp

[importlinter:contract:no-circular]
name = No circular imports
type = independence
modules =
    myapp.domain
    myapp.infrastructure
    myapp.api
```

### Layer Dependency Direction

**JS/TS (dependency-cruiser):**
```json
{
  "name": "no-domain-to-infra",
  "severity": "error",
  "from": { "path": "^src/domain" },
  "to": { "path": "^src/infrastructure" }
}
```

**Java (ArchUnit):**
```java
@ArchTest
static final ArchRule layerDeps = layeredArchitecture()
    .consideringAllDependencies()
    .layer("Domain").definedBy("..domain..")
    .layer("Application").definedBy("..application..")
    .layer("Infrastructure").definedBy("..infrastructure..")
    .whereLayer("Domain").mayNotAccessAnyLayer()
    .whereLayer("Application").mayOnlyAccessLayers("Domain")
    .whereLayer("Infrastructure").mayOnlyAccessLayers("Application", "Domain");
```

**Python (import-linter):**
```ini
[importlinter:contract:layers]
name = Layer dependencies
type = layers
layers =
    myapp.api
    myapp.application
    myapp.domain
```

## Complexity

### Cyclomatic Complexity

**JS/TS (eslint):**
```json
// .eslintrc.json (rule)
{ "complexity": ["error", 10] }
// Run: npx eslint src --rule 'complexity: [error, 10]'
```

**Python (radon):**
```bash
# Run: radon cc src -a -nc
# Assert: no function with rank C or worse
radon cc src --min C --json | python -c "import sys,json; d=json.load(sys.stdin); sys.exit(1 if d else 0)"
```

**Go:**
```bash
# Run: gocyclo -over 10 .
# Assert: no functions above threshold
gocyclo -over 10 . && echo "PASS" || echo "FAIL"
```

## Performance

### Response Time Under Load

**JS/TS (autocannon):**
```javascript
// fitness/performance.test.js
const autocannon = require('autocannon');

test('API response time < 200ms p95', async () => {
  const result = await autocannon({
    url: 'http://localhost:3000/api/endpoint',
    connections: 10,
    duration: 10
  });
  expect(result.latency.p95).toBeLessThan(200);
});
```

**Python (locust — simplified):**
```python
# fitness/test_performance.py
import subprocess, json

def test_api_response_time():
    result = subprocess.run([
        'locust', '--headless', '-u', '10', '-r', '5',
        '--run-time', '10s', '--json'
    ], capture_output=True, text=True)
    data = json.loads(result.stdout)
    p95 = data['requests']['p95']
    assert p95 < 200, f"p95 latency {p95}ms exceeds 200ms threshold"
```

## Security

### No Known Vulnerabilities

**JS/TS:**
```bash
# Run: npm audit --audit-level=high
# Assert: exit code 0 (no high/critical vulnerabilities)
npm audit --audit-level=high
```

**Python:**
```bash
# Run: safety check (or pip-audit)
pip-audit --strict
```

**Go:**
```bash
govulncheck ./...
```

**Java:**
```xml
<!-- OWASP Dependency-Check Maven plugin -->
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
    </configuration>
</plugin>
```

## Coverage

### Test Coverage Threshold

**JS/TS (Jest):**
```json
// jest.config.js
{
  "coverageThreshold": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80
    }
  }
}
// Run: npx jest --coverage
```

**Python (pytest-cov):**
```bash
pytest --cov=src --cov-fail-under=80
```

**Go:**
```bash
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out | grep total | awk '{print $3}' | \
  awk -F. '{if ($1 < 80) exit 1}'
```

## Module Size

### File/Module Size Limits

**JS/TS (eslint):**
```json
{ "max-lines": ["error", { "max": 300, "skipBlankLines": true, "skipComments": true }] }
```

**Python (custom check):**
```bash
# Find files with more than 300 lines of code (excluding comments/blanks)
find src -name '*.py' -exec awk 'END{if(NR>300) print FILENAME": "NR" lines"}' {} \; | \
  grep -c . && echo "FAIL: files exceed 300 lines" && exit 1 || echo "PASS"
```
