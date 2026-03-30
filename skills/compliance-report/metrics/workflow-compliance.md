---
name: workflow-compliance
description: Prüft ob der vorgeschriebene Entwicklungs-Workflow pro Feature-Zyklus eingehalten wurde
weight: 1.0
---

## Analysis

Für jeden Feature-Zyklus wird geprüft ob die erwarteten Artefakte erzeugt wurden und ob die Reihenfolge stimmt. Die Analyse basiert auf der Commit-Historie und den Datei-Änderungen innerhalb des Zyklus.

### Git-Commands

```bash
# Commits im Zyklus mit geänderten Dateien
git log <first-commit>..<last-commit> --name-only --format='COMMIT:%H|%ai|%s'

# Prüfe ob architecture.md im Zyklus geändert wurde
git log <first-commit>..<last-commit> -- architecture.md

# Prüfe ob Feature Files im Zyklus geändert wurden
git log <first-commit>..<last-commit> -- '*.feature'

# Prüfe ob ADRs im Zyklus erstellt wurden
git log <first-commit>..<last-commit> -- 'doc/adr/'

# Prüfe ob Quality Scenarios im Zyklus geändert wurden
git log <first-commit>..<last-commit> -- quality-scenarios.md

# Prüfe ob Spec im Zyklus erstellt wurde
git log <first-commit>..<last-commit> -- 'docs/superflowers/specs/*-design.md'
```

## Checks

### 1. Spec vorhanden
- **Bestanden:** Mindestens ein Commit ändert eine `*-design.md` Datei in `docs/superflowers/specs/`
- **Nicht bestanden:** Kein Spec-Commit im Zyklus

### 2. Spec vor Code
- **Bestanden:** Der erste Spec-Commit liegt zeitlich VOR dem ersten Commit der Implementierungsdateien ändert (nicht-Spec, nicht-Feature, nicht-ADR, nicht-Docs)
- **Nicht bestanden:** Implementierungs-Commits liegen vor dem Spec-Commit
- **N/A:** Kein Spec vorhanden (wird durch Check 1 abgedeckt)

### 3. Feature Files vorhanden
- **Bestanden:** Mindestens ein Commit ändert eine `.feature` Datei
- **Nicht bestanden:** Keine Feature-File-Commits im Zyklus

### 4. Architecture aktualisiert
- **Bestanden:** `architecture.md` wurde im Zyklus geändert ODER existierte bereits unverändert (stabiles Architektur = ok)
- **Nicht bestanden:** `architecture.md` existiert nicht im Repository

### 5. ADR dokumentiert
- **Bestanden:** Mindestens ein neuer Commit in `doc/adr/`
- **Nicht bestanden:** Keine ADR-Commits im Zyklus
- **Info:** Nicht jedes Feature braucht zwingend ein ADR — dieser Check ist informativ, nicht blockierend

### 6. Artefakt-Reihenfolge
- **Bestanden:** Commits folgen der Reihenfolge: Spec → Feature Files → Implementierung
- **Nicht bestanden:** Implementierungs-Commits vor Spec oder Feature Files
- **Teilweise:** Feature Files vor Spec, aber Implementierung nach beiden

## Scoring

Score = (Anzahl bestandener Checks / Anzahl anwendbarer Checks) × 100

Checks die "N/A" sind, werden nicht gezählt. Check 5 (ADR) geht mit halbem Gewicht ein (informativ).

## Visualization

### Im Feature-Detail
- Checklist mit ✓/✗ pro Check
- Farbcodierung: Grün für bestanden, Rot für nicht bestanden, Grau für N/A
- Score als Prozentzahl mit Farbbalken

### Im Trend
- Compliance-Score pro Feature als Linie über die Zeit
- Stacked Bar Chart: welche Checks über die Features bestanden/nicht bestanden
