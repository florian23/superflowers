# Project Constraints Skill — Eval Workspace

TDD-Evaluierung für den project-constraints Skill.

## Test-Fixtures

```
test-fixtures/
├── spring-boot-project/              # Realistisches Fake-Projekt
│   ├── CLAUDE.md                     # constraints_repo konfiguriert
│   ├── pom.xml                       # Spring Boot 3, PostgreSQL, Security
│   ├── Dockerfile                    # Docker Deployment
│   ├── src/main/kotlin/.../
│   │   └── PaymentController.kt      # REST API mit PII (cardNumber, iban)
│   └── src/main/resources/
│       └── application.yml           # PostgreSQL Config
└── (nutzt company-constraints aus constraint-selection-workspace)
```

Constraint-Repo: `/home/flo/superflowers/constraint-selection-workspace/test-fixtures/company-constraints/`

## Evals

| # | Name | Szenario | Assertions |
|---|------|----------|------------|
| 1 | initial-setup | Kein constraints/ Ordner, Skill soll Projekt analysieren und Constraints vorschlagen | 14 |
| 2 | review-update | constraints/ existiert, neuer Constraint im Repo, Skill soll Diff zeigen | 5 |

## Ausführung

### Eval 1: Initial Setup

**RED (Baseline):**
```bash
cd project-constraints-workspace/test-fixtures/spring-boot-project
claude --bare
```
Prompt aus `evals/evals.json` eval 1 einfügen.

**GREEN (mit Skill):**
```bash
cd project-constraints-workspace/test-fixtures/spring-boot-project
claude
```
Gleicher Prompt.

### Eval 2: Review/Update

Vor Eval 2: constraints/ aus Eval 1 Ergebnis im Projekt belassen und eine neue Constraint-Datei ins Repo legen:

```bash
cat > ~/superflowers/constraint-selection-workspace/test-fixtures/company-constraints/compliance/COMP-003-pci-dss.md << 'HEREDOC'
---
id: COMP-003
name: PCI-DSS Compliance
category: compliance
severity: mandatory
applies_to:
  - payment
  - credit-card
  - financial-data
---

## Anforderung

Systeme die Kreditkartendaten verarbeiten müssen PCI-DSS Level 1 compliant sein.
Kreditkartennummern dürfen nicht im Klartext gespeichert werden.

## Prüfkriterien

- [ ] Kreditkartennummern werden tokenisiert gespeichert
- [ ] Keine vollständigen Kartennummern in Logs
- [ ] Jährliches PCI-DSS Audit bestanden
HEREDOC
```

Dann Eval 2 Prompt laufen lassen — Skill soll die neue COMP-003 erkennen.
