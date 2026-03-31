# Constraint Selection Skill — Eval Workspace

TDD-Evaluierung für den constraint-selection Skill.

## Test-Fixtures

```
test-fixtures/
├── company-constraints/          # Fake Unternehmens-Constraint-Repo (Ebene 1)
│   ├── security/
│   │   ├── SEC-001-encryption-at-rest.md    (mandatory, data-storage)
│   │   ├── SEC-002-api-authentication.md    (mandatory, api/webservice)
│   │   └── SEC-003-network-segmentation.md  (recommended, infrastructure)
│   ├── compliance/
│   │   ├── COMP-001-gdpr-data-retention.md  (mandatory, personal-data)
│   │   └── COMP-002-audit-logging.md        (mandatory, data-mutation)
│   ├── technology/
│   │   └── TECH-001-spring-boot.md          (recommended, webservice)
│   └── process/
│       └── PROC-001-four-eyes.md            (kein Frontmatter, Freitext)
└── test-project/                 # Fake Projekt (Ebene 2)
    ├── CLAUDE.md                 # constraints_repo Pfad
    ├── constraints/
    │   ├── security.md           # referenziert SEC-001, SEC-002
    │   ├── compliance.md         # referenziert COMP-001, COMP-002
    │   └── technology.md         # referenziert TECH-001
    └── docs/superflowers/constraints/  # Feature-Constraints werden hierher geschrieben
```

## Evals (3 Szenarien)

| # | Name | Szenario | Erwartung |
|---|------|----------|-----------|
| 1 | payment-service | Payment API mit DB, PII, REST | Alle 5 Projekt-Constraints relevant |
| 2 | cli-tool-minimal | CLI ohne DB/API/PII | Fast keine Constraints relevant |
| 3 | no-constraint-repo | Kein Repo konfiguriert | Skill überspringt graceful |

## Ausführung

### RED Phase (Baseline ohne Skill)

Superflowers temporär deaktivieren, dann Session starten:

**Option A: Plugin deaktivieren**

In `~/.claude/settings.json` temporär setzen:
```json
"superflowers@local": false
```
Dann:
```bash
cd constraint-selection-workspace/test-fixtures/test-project
claude
```

**Option B: Anderes Verzeichnis ohne CLAUDE.md**

```bash
cd /tmp
claude -p "$(cat ~/superflowers/constraint-selection-workspace/evals/evals.json | python3 -c 'import sys,json; print(json.load(sys.stdin)["evals"][0]["prompt"])')"
```

**Option C: Prompt explizit ohne Skill-Nutzung**

Session mit superflowers starten, aber der Prompt enthält:
"IGNORIERE alle Skills. Antworte als Standard-Claude ohne superflowers Workflow."

Dann den Eval-Prompt aus `evals/evals.json` (eval 1) einfügen.
Beobachte: Liest der Agent die Constraints? Welche selektiert er? Welche ignoriert er?

Ergebnis dokumentieren in: `iteration-1/eval-1-payment-service/without_skill/`

**Empfohlen: Option A** — sauberste Isolation.
Nach dem Test `"superflowers@local": true` wieder setzen.

### GREEN Phase (mit Skill)

Superflowers aktiviert lassen (oder wieder aktivieren), dann:

```bash
cd constraint-selection-workspace/test-fixtures/test-project
claude
```

Gleichen Eval-Prompt einfügen. Der constraint-selection Skill sollte greifen.

Ergebnis dokumentieren in: `iteration-1/eval-1-payment-service/with_skill/`

### Grading

Für jede Assertion in evals.json: passed/failed + evidence.
Schreibe `grading.json` in den jeweiligen with_skill/without_skill Ordner.

### REFACTOR

Wenn der Skill Lücken hat → Skill anpassen → erneut testen (iteration-2/).
