# Automatisierte Checks fuer Architecture Characteristics

Basierend auf den drei definierten Charakteristiken in `/tmp/ff-eval-1/architecture.md`.

---

## 1. Modularity — No circular dependencies

**Ziel:** Keine zirkulaeren Abhaengigkeiten zwischen Modulen.

### Empfohlene Checks

**a) Static Dependency Analysis (CI-Gate)**
- Tool-Optionen je nach Stack:
  - **Java/Kotlin:** ArchUnit-Test (`ArchRuleDefinition.slices().matching("com.example.(*)..").should().beFreeOfCycles()`)
  - **TypeScript/JS:** `madge --circular --extensions ts src/`
  - **Python:** `pydeps --no-show --reverse` oder `import-linter`
  - **.NET:** `NDepend` CQL-Regel gegen Zyklen
- **Trigger:** Bei jedem Pull Request / Push auf main
- **Ergebnis:** Build bricht ab, wenn zirkulaere Abhaengigkeiten gefunden werden (Exit-Code != 0)

**b) Dependency Graph Visualisierung (informativ)**
- Generierung eines Modulgraphen als Artefakt im CI (z.B. `madge --image graph.svg`)
- Kein Gate, aber Review-Hilfe

---

## 2. Testability — >80% Coverage

**Ziel:** Code-Coverage ueber 80% halten.

### Empfohlene Checks

**a) Coverage Gate im CI**
- Coverage-Tool je nach Stack:
  - **Java/Kotlin:** JaCoCo mit `minimumCoverageRatio = 0.80`
  - **TypeScript/JS:** `jest --coverage` mit `coverageThreshold: { global: { lines: 80, branches: 80, functions: 80, statements: 80 } }`
  - **Python:** `pytest --cov --cov-fail-under=80`
  - **Go:** `go test -coverprofile=coverage.out` + custom threshold check
- **Trigger:** Bei jedem Pull Request
- **Ergebnis:** PR wird blockiert wenn Coverage < 80%

**b) Coverage-Trend-Tracking**
- Integration mit Codecov, Coveralls oder SonarQube
- Regel: PR darf Coverage nicht senken (Delta-Check)
- Warnung bei Coverage-Abfall auch wenn noch ueber 80%

**c) Coverage auf neuem Code (optional, empfohlen)**
- Nur geaenderte/neue Dateien muessen mindestens 80% haben
- Verhindert, dass neue Features ohne Tests durchrutschen, waehrend Altcode den Schnitt haelt

---

## 3. Performance — API <500ms p95

**Ziel:** 95. Perzentil der API-Antwortzeiten unter 500ms.

### Empfohlene Checks

**a) Load Test im CI/CD**
- Tool-Optionen:
  - **k6:** Script mit `http_req_duration: ['p(95)<500']` als Threshold
  - **Gatling:** Assertion `global.responseTime.percentile(95).lt(500)`
  - **Apache JMeter:** mit Assertions auf p95
  - **Artillery:** `ensure: p95: 500`
- **Trigger:** Nightly oder bei Release-Branches (zu teuer fuer jeden PR)
- **Ergebnis:** Pipeline schlaegt fehl wenn p95 >= 500ms

**b) Synthetic Monitoring in Produktion**
- Regelmaeßige synthetische Requests gegen Prod-Endpunkte
- Tools: Datadog Synthetic, Grafana k6 Cloud, AWS CloudWatch Synthetics
- Alert wenn p95 ueber 500ms steigt

**c) APM-basierter Alarm (Runtime)**
- Application Performance Monitoring (Datadog, New Relic, Grafana Tempo)
- Automatischer Alert/PagerDuty wenn p95 Schwelle ueberschritten wird
- Ist kein CI-Check, aber essenziell fuer die laufende Einhaltung

---

## Zusammenfassung: Mapping Charakteristik -> Checks

| Charakteristik | Check-Typ | Tool-Beispiele | Trigger | Gate? |
|---|---|---|---|---|
| Modularity | Static Analysis | madge, ArchUnit, import-linter | Jeder PR | Ja |
| Testability | Coverage Threshold | JaCoCo, jest, pytest-cov | Jeder PR | Ja |
| Performance | Load Test (p95) | k6, Gatling, Artillery | Nightly / Release | Ja |
| Performance | Synthetic Monitoring | Datadog, k6 Cloud | Kontinuierlich | Alert |
