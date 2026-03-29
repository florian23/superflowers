# Fitness Functions fuer das Python-Projekt "myapp"

Basierend auf der `architecture.md` und dem Technologie-Stack (Python, Flask, pytest).

---

## 1. Security -- Keine bekannten CVEs in Abhaengigkeiten (Kritisch)

**Ziel:** Keine bekannten Sicherheitsluecken in den Projekt-Abhaengigkeiten.

**Tool:** `safety` (bereits in dev-Dependencies vorhanden) oder `pip-audit`

**Ausfuehrung in CI:**

```yaml
# GitHub Actions Beispiel
- name: Security Check (safety)
  run: |
    pip install safety
    safety check --full-report
```

Alternative mit `pip-audit` (modernerer Ansatz, nutzt die OSV-Datenbank):

```bash
pip install pip-audit
pip-audit
```

**Schwellwert:** 0 bekannte Vulnerabilities. Pipeline schlaegt fehl bei jeder gefundenen CVE.

**Lokaler Check:**

```bash
# In pyproject.toml als Script definierbar:
safety check
# oder
pip-audit --strict
```

---

## 2. Testability -- >90% Code Coverage (Kritisch)

**Ziel:** Mindestens 90% Test-Abdeckung.

**Tool:** `pytest-cov` (bereits in dev-Dependencies vorhanden)

**Ausfuehrung in CI:**

```yaml
- name: Test with Coverage
  run: |
    pytest --cov=src --cov-report=term-missing --cov-fail-under=90
```

**Konfiguration in `pyproject.toml`:**

```toml
[tool.pytest.ini_options]
addopts = "--cov=src --cov-report=term-missing --cov-fail-under=90"

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
fail_under = 90
show_missing = true
```

**Schwellwert:** Pipeline schlaegt fehl bei Coverage < 90%.

---

## 3. Modularity -- Keine zirkulaeren Imports (Wichtig)

**Ziel:** Keine zirkulaeren Abhaengigkeiten zwischen Modulen.

**Tool:** `import-linter` (in architecture.md erwaehnt)

**Installation und Konfiguration:**

```bash
pip install import-linter
```

**Konfiguration in `pyproject.toml`:**

```toml
[tool.importlinter]
root_packages = ["myapp"]

[[tool.importlinter.contracts]]
name = "No circular imports"
type = "layers"
# Beispiel-Schichten -- an tatsaechliche Paketstruktur anpassen:
layers = [
    "myapp.api",
    "myapp.service",
    "myapp.domain",
    "myapp.infrastructure",
]
```

**Ausfuehrung in CI:**

```yaml
- name: Check for circular imports
  run: lint-imports
```

**Schwellwert:** 0 Verletzungen. Pipeline schlaegt bei jedem zirkulaeren Import fehl.

---

## 4. Zusaetzliche empfohlene Fitness Functions fuer Python

### 4a. Code-Qualitaet / Linting

**Tool:** `ruff` (schneller Linter und Formatter, ersetzt flake8 + isort + pyupgrade)

```toml
# pyproject.toml
[tool.ruff]
target-version = "py311"
line-length = 120

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "UP", "B", "A", "C4", "SIM"]
```

```yaml
- name: Lint
  run: ruff check src/ tests/
```

### 4b. Typ-Sicherheit / Static Type Checking

**Tool:** `mypy`

```toml
# pyproject.toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
```

```yaml
- name: Type Check
  run: mypy src/
```

### 4c. Komplexitaets-Check

**Tool:** `radon` oder `ruff` (Cyclomatic Complexity)

```bash
# Mit radon
radon cc src/ -a -nc  # schlaegt fehl bei Complexity > C

# Mit ruff
ruff check --select C901 --config "lint.mccabe.max-complexity=10" src/
```

### 4d. Abhaengigkeits-Freshness

**Tool:** `pip list --outdated`

```yaml
- name: Check outdated dependencies
  run: pip list --outdated --format=json
```

Dies ist eher ein Monitoring-Check (informativ, nicht blockierend).

---

## Zusammenfassung: CI-Pipeline Reihenfolge

| Schritt | Tool | Blockierend | Aus architecture.md |
|---|---|---|---|
| 1. Security | `safety` / `pip-audit` | Ja | Ja (Kritisch) |
| 2. Tests + Coverage | `pytest --cov-fail-under=90` | Ja | Ja (Kritisch) |
| 3. Circular Imports | `import-linter` | Ja | Ja (Wichtig) |
| 4. Linting | `ruff` | Ja | Nein (empfohlen) |
| 5. Type Checking | `mypy` | Ja | Nein (empfohlen) |
| 6. Complexity | `radon` / `ruff C901` | Optional | Nein (empfohlen) |

### Minimale pyproject.toml Erweiterung

```toml
[project.optional-dependencies]
dev = [
    "pytest",
    "pytest-cov",
    "safety",
    "import-linter",
    "ruff",
    "mypy",
]
```
