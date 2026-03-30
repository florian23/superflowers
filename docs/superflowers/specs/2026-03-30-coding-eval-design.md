# Design: Coding Eval — FeatureBench-basierte Skill-Evaluation

## Datum: 2026-03-30

## Problem

Superflowers hat 20+ Skills mit Guardrails, aber keinen Beweis dass der Framework die Coding-Qualität tatsächlich verbessert. Die bisherigen Skill-Evals prüfen ob Skills die richtigen Artefakte erzeugen — nicht ob der gesamte Workflow bessere Software produziert.

## Lösung

Ein vollautomatischer Eval-Skill (`/coding-eval`) der echte FeatureBench Tasks nimmt, zwei Subagents dispatcht (with/without superflowers), die FeatureBench Docker-Tests gegen beide Lösungen laufen lässt, und einen Vergleichs-Report erzeugt.

## Architektur

Neuer Skill im superflowers Ökosystem. Nutzt die bestehende Microkernel-Architektur nicht direkt — ist ein eigenständiges Automatisierungstool.

### Komponenten

```
skills/coding-eval/
├── SKILL.md                    # Skill-Definition und Orchestrierung
├── scripts/
│   ├── prepare_task.py         # Lädt Task aus HuggingFace, klont Repo
│   ├── run_tests.py            # Führt Docker-Tests aus
│   └── generate_report.py      # Erzeugt HTML Vergleichs-Report
├── prompts/
│   ├── without-skill-prompt.md # Prompt für den Vanilla-Agent
│   └── with-skill-prompt.md    # Prompt für den superflowers-Agent
└── tasks/                      # Wird zur Laufzeit befüllt
```

### Datenfluss

```
1. /coding-eval --task <name>
   ↓
2. prepare_task.py
   - Lädt Task-Daten aus FeatureBench HuggingFace Dataset
   - Klont Repo auf base_commit
   - Erstellt tasks/<name>/meta.json + task.md
   - Erstellt 2 Worktrees: with_skill/ und without_skill/
   ↓
3. Dispatch Subagent: without-skill (in Worktree)
   - Bekommt: Problem Statement + Repo
   - Bekommt NICHT: superflowers Skills
   - Prompt: "Implementiere dieses Feature. Keine Brainstorming, Architecture, BDD Skills."
   - Arbeitet in: tasks/<name>/without_skill/repo/
   ↓
4. Dispatch Subagent: with-skill (in Worktree)
   - Bekommt: Problem Statement + Repo + superflowers Skills
   - Prompt: "Nutze den vollen superflowers Workflow."
   - Arbeitet in: tasks/<name>/with_skill/repo/
   ↓
5. run_tests.py (für beide Lösungen)
   - Startet FeatureBench Docker-Container
   - Kopiert Agent-Änderungen (git diff) in den Container
   - Führt FAIL_TO_PASS und PASS_TO_PASS Tests aus
   - Schreibt grading.json pro Konfiguration
   ↓
6. generate_report.py
   - Liest alle grading.json Dateien
   - Aggregiert zu benchmark.json
   - Erzeugt HTML Vergleichs-Report
```

### Subagent-Prompts

**Without-Skill Prompt:**
```
Du bist ein Software-Entwickler. Implementiere das folgende Feature im Repository.

REGELN:
- Implementiere das Feature direkt
- Nutze KEINE Brainstorming, Architecture, BDD oder andere Workflow-Skills
- Lese den Code, verstehe die Struktur, implementiere die Lösung
- Teste deine Lösung lokal wenn möglich

FEATURE:
<problem_statement aus task.md>

REPOSITORY: <pfad>
```

**With-Skill Prompt:**
```
Du bist ein Software-Entwickler mit Zugriff auf superflowers Skills.

REGELN:
- Nutze den vollen superflowers Workflow
- Beginne mit dem Verständnis der Anforderung
- Verwende TDD wenn möglich
- Verifiziere deine Lösung vor Abschluss

FEATURE:
<problem_statement aus task.md>

REPOSITORY: <pfad>
```

### Test-Ausführung (Docker)

Für jeden Task:
1. FeatureBench Docker-Image pullen (`meta.json` → `image_name`)
2. Container starten mit dem Repo gemountet
3. Agent-Patch anwenden (`git diff` der Agent-Änderungen)
4. Test-Command ausführen (`pytest <test_file>`)
5. Ergebnis parsen: welche Tests bestanden, welche fehlgeschlagen

### Metriken

**Hard Metriken (pro Task):**

| Metrik | Beschreibung |
|--------|-------------|
| **Resolved** | Alle FAIL_TO_PASS Tests bestanden UND alle PASS_TO_PASS Tests bestehen |
| **Partial** | Mindestens 1 FAIL_TO_PASS Test bestanden |
| **Failed** | 0 FAIL_TO_PASS Tests bestanden |
| **Tests Passed** | Absolute Zahl bestandener Tests |
| **Tests Total** | Gesamtzahl Tests |

**Soft Metriken (pro Task):**

| Metrik | Beschreibung |
|--------|-------------|
| **Artefakte** | Welche Spec-Artefakte erzeugt? (architecture.md, .feature, quality-scenarios) |
| **Lines of Code** | Gesamtumfang der Änderungen |
| **Dateien geändert** | Anzahl betroffener Dateien |
| **Tests geschrieben** | Hat der Agent eigene Tests geschrieben? |

### Task-Auswahl (initial: 3 Tasks)

Aus FeatureBench Lite, sortiert nach Patch-Größe (einfachste zuerst):

1. **seaborn — Statistical Bootstrap** (151 Lines) — Statistik-Modul implementieren
2. **marshmallow — Type Coercion** (266 Lines) — Type-System erweitern
3. **seaborn — Data Preprocessing** (367 Lines) — Daten-Preprocessing Pipeline

### Report (HTML)

Single-File HTML Report analog zum Compliance Report:
- Gesamtergebnis: with_skill vs without_skill (Resolved Rate, Partial Rate)
- Pro Task: Side-by-Side Vergleich (Tests, Artefakte, Code-Impact)
- Trend: wenn mehr als 3 Tasks evaluiert wurden

## Referenzen

- FeatureBench: https://github.com/LiberCoders/FeatureBench
- `features/coding-eval.feature` — 9 BDD-Szenarien
- `architecture.md` — Bestehende Architektur-Charakteristiken
