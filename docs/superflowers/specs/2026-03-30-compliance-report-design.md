# Design: Git-basierter Compliance & Quality Tracker

## Datum: 2026-03-30

## Problem

Superflowers hat ein umfassendes System aus Guardrails: Hard Gates, immutable ADRs, Fitness Functions, BDD-Szenarien, Quality Scenarios, Verification Gates. Es fehlt die **Beobachtbarkeit über die Zeit** — ein Mechanismus der zeigt, ob diese Schranken tatsächlich greifen und die Entwicklung on track halten.

## Lösung

Ein Claude Code Skill (`/compliance-report`) der die Git-Historie und den aktuellen Zustand der Artefakte analysiert. Zwei Kernfragen:

1. **Workflow-Compliance:** Wurde der vorgeschriebene Workflow eingehalten?
2. **Inhaltliche Stabilität:** Werden die Guardrails über die Zeit aufrecht erhalten?

Output ist ein **interaktiver, offline-fähiger Single-File HTML-Report** mit Timeline-Navigation.

## Architektur

- **Stil:** Microkernel (Core + Plugin-Metriken)
- **Top-3 Charakteristiken:** Extensibility, Usability, Portability
- **Referenz:** `architecture.md` (mit Style Fitness Functions)

### Microkernel-Aufbau

**Core (Skill-Orchestrierung):**
- `skills/compliance-report/SKILL.md` — Skill-Definition, Orchestrierung
- Git-Daten-Extraktor — sammelt Rohdaten via Git-Commands
- Plugin-Registry — entdeckt und lädt Metrik-Definitionen aus `metrics/`
- Report-Generator — erzeugt Single-File HTML mit eingebetteten Daten

**Plugins (Metrik-Definitionen):**
- `skills/compliance-report/metrics/workflow-compliance.md`
- `skills/compliance-report/metrics/code-impact.md`
- `skills/compliance-report/metrics/architecture-erosion.md`
- Neue Metrik = neue `.md` Datei, 0 Änderungen am Core

### Metrik-Datei-Format

Jede Metrik-Datei in `metrics/` definiert:

```markdown
---
name: Workflow Compliance
description: Prüft ob der vorgeschriebene Workflow eingehalten wurde
weight: 1.0
---

## Analyse

[Beschreibung was analysiert wird und welche Git-Commands dafür nötig sind]

## Prüfungen

[Liste der einzelnen Checks mit Bewertungslogik]

## Scoring

[Wie der Score berechnet wird (0-100%)]

## Visualisierung

[Wie die Ergebnisse im Report dargestellt werden sollen]
```

### Datenfluss

```
1. Skill-Aufruf (/compliance-report)
   ↓
2. Git-Daten-Extraktor
   - git log, git diff, git branch
   - Commit-Historie, Branch-Struktur, Datei-Änderungen
   ↓
3. Feature-Zyklus-Erkennung
   - Worktree-Branches
   - Spec-Commits
   - Feature-File-Commits
   ↓
4. Plugin-Registry lädt Metriken aus metrics/
   ↓
5. Jede Metrik analysiert die Feature-Zyklen
   - Workflow Compliance: Artefakt-Reihenfolge, Vollständigkeit
   - Code Impact: Dateien, Lines, Churn, Hotspots
   - Architecture Erosion: FF-Drift, BDD-Stabilität, ADR-Hygiene
   ↓
6. Aggregation
   - Compliance-Score pro Feature (0-100%)
   - Trend-Berechnung über alle Features
   - Drift-Warnungen sammeln
   ↓
7. HTML-Report-Generierung
   - Daten als JSON in HTML einbetten
   - Chart.js inline für Visualisierungen
   - Interaktive Timeline-Navigation
   ↓
8. Report speichern
   docs/superflowers/reports/YYYY-MM-DD-compliance-report.html
```

## Feature-Zyklus-Erkennung

Ein Feature-Zyklus wird erkannt durch:

1. **Worktree-Branches:** `worktree/<name>` Branches die in main gemergt wurden
2. **Spec-Commits:** Commits die `docs/superflowers/specs/*-design.md` erstellen
3. **Feature-File-Commits:** Commits die `.feature` Dateien erstellen/ändern
4. **Branch-Gruppen:** Zusammenhängende Commits auf einem Feature-Branch

Commits die keinem Zyklus zugeordnet werden können, werden als "unzugeordnet" gruppiert.

## Metriken (initiale Plugins)

### 1. Workflow Compliance

Prüft pro Feature-Zyklus:

| Prüfung | Methode |
|---------|---------|
| Spec vor Code? | Commit-Reihenfolge: Spec vor Implementierung |
| architecture.md aktualisiert? | Git diff im Feature-Zeitraum |
| Feature Files vorhanden? | .feature Dateien committed |
| ADR geschrieben? | Neue Dateien in doc/adr/ |
| Quality Scenarios vorhanden? | quality-scenarios.md geändert |
| Artefakt-Reihenfolge korrekt? | Spec → Feature Files → Implementierung |

**Score:** Anteil bestandener Prüfungen (0-100%)

### 2. Code Impact

Analysiert pro Feature-Zyklus:

| Metrik | Berechnung |
|--------|------------|
| Neue Dateien | Dateien die im Zyklus erstellt wurden |
| Geänderte Dateien | Bestehende Dateien mit Änderungen |
| Lines added/removed | git diff --stat Auswertung |
| Churn-Ratio | Geänderte Zeilen in bestehenden Dateien / Neue Zeilen in neuen Dateien |
| Blast Radius | Anzahl betroffener Verzeichnisse |
| Hotspots | Dateien die in ≥3 Zyklen geändert wurden |

### 3. Architecture Erosion

Erkennt Drift über die Zeit:

| Prüfung | Methode |
|---------|---------|
| FF-Schwellwert-Absenkung | Git diff auf architecture.md: Schwellwerte gesenkt ohne ADR? |
| BDD-Szenario-Entfernungen | Git diff auf .feature Dateien: Szenarien entfernt ohne Ersatz? |
| ADR-Hygiene | Superseded ADRs ohne Nachfolger? |
| FF-Verlauf | Timeline der FF-Änderungen über Zyklen |
| BDD-Wachstum | Kumulative Szenario-Anzahl über Zeit |

**Drift-Warnungen** werden generiert wenn:
- FF-Schwellwerte ohne ADR gesenkt werden
- BDD-Szenarien entfernt werden ohne Ersatz
- Superseded ADRs keinen Nachfolger haben

## HTML-Report

### Sektionen

1. **Executive Summary** — Durchschnitts-Score, Trend-Pfeil, Key Findings
2. **Interaktive Timeline** — Klickbare Feature-Punkte, Feature-Fokus + Trend-Fokus
3. **Feature-Detailansicht** (aufklappbar) — Compliance Checklist, Code Impact, Commits, Artefakte
4. **Architektur-Stabilität** — FF-Verlauf, BDD-Wachstum, ADR-Status, Hotspot-Heatmap
5. **Drift-Warnungen** — Betroffenes Feature, Grund, Schweregrad
6. **Empfehlungen** — Priorisierte Maßnahmen basierend auf den Findings

### Technische Anforderungen

- **1 HTML-Datei**, exakt, keine weiteren Dateien
- **0 externe Requests** — CSS, JS, Chart.js alles inline
- **Offline-fähig** — funktioniert ohne Internet
- **Responsive** — lesbar auf 1024px und 1920px
- **Valides HTML5** — keine Validation Errors
- **Max. 3 Klicks** — von Landing zu jedem Feature-Detail
- **Farbcodierung** — Grün (>85%), Gelb (60-85%), Rot (<60%)
- **Collapsible Sektionen** — `<details>` Tags für Feature-Details
- **Eingebettete Daten** — alle Compliance-Daten als JSON-Block im HTML
- **URL-Hash Deep-Links** — `#feature=auth-system` für direkten Zugriff

### Timeline-Navigation

- Klickbare Punkte auf Zeitachse (ein Punkt pro Feature)
- **Feature-Fokus:** Klick auf Punkt → alle Details + Metriken bis zu diesem Zeitpunkt
- **Trend-Fokus:** Zeitraum-Ansicht → aggregierte Charts über gewählten Bereich
- Navigations-Buttons (Vor/Zurück) durch Features

## Skill-Integration

### Aufruf

```
/compliance-report                          # Vollständiger Report
/compliance-report --feature=<name>         # Spezifisches Feature
/compliance-report --since=YYYY-MM-DD       # Ab Datum
```

### Output

```
docs/superflowers/reports/YYYY-MM-DD-compliance-report.html
```

### Fehlerbehandlung

- **Fehlende Artefakte:** Warnung im Report, verfügbare Metriken werden berechnet
- **Shallow Clone:** Report mit verfügbaren Daten, Hinweis auf begrenzte Historie
- **Leeres Repo:** Meldung "Keine Commits gefunden", kein Report
- **Ungültige Parameter:** Fehlermeldung mit Hinweis zum korrekten Format
- **Metrik-Fehler:** Warnung im Report, andere Metriken unbeeinträchtigt

## Referenzen

- `architecture.md` — Architektur-Charakteristiken und Style Fitness Functions
- `quality-scenarios.md` — 13 Quality Scenarios (QS-001 bis QS-013)
- `features/*.feature` — 8 Feature Files mit ~50 BDD-Szenarien
