---
name: architecture-erosion
description: Erkennt Architektur-Drift über die Zeit — FF-Schwellwert-Änderungen, BDD-Szenario-Entfernungen, ADR-Hygiene
weight: 1.0
---

## Analysis

Prüft ob die Architektur-Guardrails über die Zeit stabil bleiben oder ob Drift stattfindet. Drift ist definiert als Abschwächung von Qualitäts-Schranken ohne dokumentierte Begründung (ADR).

### Git-Commands

```bash
# Alle Änderungen an architecture.md über die gesamte Historie
git log --all -p -- architecture.md

# Alle Änderungen an .feature Dateien (Szenarien-Zählung)
git log --all --format='%H|%ai|%s' -- '*.feature'

# Szenario-Zählung pro Commit (grep auf 'Scenario:' und 'Scenario Outline:')
git show <commit>:<feature-file> | grep -c 'Scenario'

# ADR-Dateien und ihre Status
git log --all --format='%H|%ai|%s' -- 'doc/adr/*.md'

# Aktuelle ADR-Inhalte für Status-Prüfung
find doc/adr/ -name '*.md' -exec grep -l 'Status:' {} \;
```

## Checks

### 1. Fitness-Function-Schwellwert-Stabilität
- **Analyse:** Vergleiche architecture.md zwischen Feature-Zyklen
- **Suche nach:** Geänderte Zahlenwerte in Fitness-Function-Zeilen (z.B. "coverage >= 80%" → "coverage >= 60%")
- **Bestanden:** Keine Schwellwert-Absenkungen ODER Absenkung durch ADR dokumentiert
- **Drift-Warnung:** Schwellwert gesenkt ohne zugehörigen ADR im selben Zyklus
- **Methode:** Regex-Match auf Zahlen in FF-Zeilen, Vergleich zwischen Versionen

### 2. BDD-Szenario-Stabilität
- **Analyse:** Zähle `Scenario:` und `Scenario Outline:` pro .feature Datei über die Zeit
- **Bestanden:** Szenario-Anzahl ist gleich oder wachsend
- **Drift-Warnung:** Szenarien wurden entfernt ohne dass neue hinzugefügt wurden
- **Info:** Szenarien-Umbau (entfernen + neue hinzufügen im selben Zyklus) ist akzeptabel

### 3. ADR-Hygiene
- **Analyse:** Lese alle ADRs in `doc/adr/`, prüfe Status-Feld
- **Bestanden:** Jeder ADR mit Status "Superseded" hat einen Verweis auf den Nachfolger-ADR
- **Drift-Warnung:** Superseded ADR ohne Nachfolger-Verweis
- **Info:** ADRs mit Status "Accepted" oder "Proposed" sind gesund

### 4. FF-Änderung mit ADR-Begleitung
- **Analyse:** Wenn Fitness Functions in architecture.md geändert wurden, prüfe ob ein ADR im selben Zyklus existiert
- **Bestanden:** FF-Änderung + zugehöriger ADR vorhanden
- **Drift-Warnung:** FF-Änderung ohne ADR

## Scoring

Score = (Anzahl Checks ohne Drift-Warnung / Anzahl anwendbarer Checks) × 100

Checks die nicht anwendbar sind (z.B. keine ADRs im Repo) werden übersprungen.

## Visualization

### Im Feature-Detail
- Liste der Drift-Warnungen mit Schweregrad und Kontext
- FF-Änderungs-Diff (was wurde geändert, von welchem Wert zu welchem)
- BDD-Szenario-Delta (hinzugefügt/entfernt mit Dateinamen)

### Im Trend
- **FF-Verlauf Timeline:** Zeigt wann Fitness Functions geändert wurden und ob mit ADR
- **BDD-Wachstum Chart:** Kumulative Szenario-Anzahl über die Zeit (Line Chart)
- **ADR-Status-Übersicht:** Accepted / Superseded / Deprecated Verteilung
- **Drift-Warnungs-Heatmap:** Welche Zyklen haben die meisten Warnungen
