---
name: code-impact
description: Analysiert den Code-Impact pro Feature-Zyklus — Dateien, Lines, Churn und Hotspots
weight: 0.5
---

## Analysis

Für jeden Feature-Zyklus wird der Umfang der Code-Änderungen gemessen. Dies ist keine Compliance-Prüfung, sondern eine deskriptive Metrik die zeigt wie stark ein Feature die Codebasis beeinflusst.

### Git-Commands

```bash
# Geänderte Dateien mit Statistik im Zyklus
git diff --stat <before-commit> <last-commit>

# Detaillierte Änderungen (additions/deletions pro Datei)
git diff --numstat <before-commit> <last-commit>

# Neue vs. modifizierte Dateien
git diff --diff-filter=A --name-only <before-commit> <last-commit>  # Added
git diff --diff-filter=M --name-only <before-commit> <last-commit>  # Modified

# Für Hotspot-Erkennung: alle Zyklen-übergreifend
git log --all --name-only --format='' -- '*.ts' '*.js' '*.py' '*.go' '*.java' '*.kt' '*.rs'
```

## Checks

### 1. Dateien-Zählung
- Neue Dateien: Anzahl Dateien mit Filter `A` (Added)
- Geänderte Dateien: Anzahl Dateien mit Filter `M` (Modified)
- Gelöschte Dateien: Anzahl Dateien mit Filter `D` (Deleted)

### 2. Lines Added / Removed
- Aus `git diff --numstat`: Summe der Additions und Deletions
- Netto-Änderung: Additions - Deletions

### 3. Churn-Ratio
- **Formel:** Geänderte Zeilen in bestehenden Dateien / Neue Zeilen in neuen Dateien
- **Interpretation:**
  - < 0.5: Niedrig — Feature ist hauptsächlich additiv
  - 0.5 - 1.0: Mittel — Mix aus neuem Code und Änderungen
  - > 1.0: Hoch — Feature greift stark in bestehenden Code ein
- **Edge Case:** Wenn keine neuen Dateien: Ratio = "nur Änderungen" (kein Division-by-Zero)

### 4. Blast Radius
- Anzahl der unterschiedlichen Top-Level-Verzeichnisse die betroffen sind
- Liste der betroffenen Verzeichnisse

### 5. Hotspot-Erkennung
- Dateien die in ≥3 verschiedenen Feature-Zyklen geändert wurden
- Sortiert nach Häufigkeit der Änderungen

## Scoring

Code Impact hat keinen Pass/Fail-Score — es ist eine deskriptive Metrik. Stattdessen:
- **Impact-Level:** Low / Medium / High basierend auf Kombination aus Dateien-Anzahl, Churn und Blast Radius
- Low: ≤5 Dateien, Churn <0.5, ≤2 Verzeichnisse
- Medium: 6-20 Dateien, Churn 0.5-1.0, 3-5 Verzeichnisse
- High: >20 Dateien, Churn >1.0, >5 Verzeichnisse

Der Impact-Level geht NICHT in den Compliance-Score ein (weight dient nur der Darstellungsreihenfolge).

## Visualization

### Im Feature-Detail
- Tabelle: Neue / Geänderte / Gelöschte Dateien mit Zahlen
- Lines Added/Removed als +/- Anzeige
- Churn-Ratio mit Farbindikator (Grün/Gelb/Rot)
- Blast Radius: Liste betroffener Verzeichnisse

### Im Trend
- Stacked Area Chart: Neue vs. geänderte Dateien pro Feature über die Zeit
- Churn-Ratio als Linie über die Zeit
- Hotspot-Tabelle: Dateien sortiert nach Änderungshäufigkeit
