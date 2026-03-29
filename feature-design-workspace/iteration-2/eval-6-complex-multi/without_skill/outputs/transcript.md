# Transcript: Cluster-System Feature Files

## Aufgabe

Erstellung von Feature Files fuer ein Cluster-System im Wissensgraph mit 5 Anforderungen:
1. Automatische Cluster-Erkennung basierend auf Kantenverbindungen
2. Visuelle Darstellung von Clustern mit farbigen Rahmen
3. Manuelles Zusammenfassen/Aufloesen von Clustern
4. Persistierung der Cluster-Zuordnung beim Speichern
5. Cluster-spezifische Layout-Algorithmen

## Vorgehen

1. Bestehende Feature Files im Repository analysiert, um Stil-Konventionen zu verstehen (Sprache, Gherkin-Schluesselwoerter, Strukturierung).
2. Festgestellt, dass das Projekt deutsche Gherkin-Syntax (`# language: de`) mit Schluesselwoertern wie `Funktionalitaet`, `Szenario`, `Angenommen`, `Wenn`, `Dann` verwendet.
3. Fuer jede der 5 Anforderungen eine separate Feature-Datei erstellt, mit konsistenter Grundlage (Background) und durchgaengigem Beispiel-Datensatz (ML-Cluster und DB-Cluster).

## Erstellte Dateien

| Datei | Anforderung | Szenarien |
|-------|-------------|-----------|
| `cluster-erkennung.feature` | Automatische Cluster-Erkennung | 6 Szenarien: Erkennung, Auto-Start, Kanten-Aenderungen, Isolierte Knoten, Mindestgroesse |
| `cluster-visualisierung.feature` | Visuelle Darstellung | 7 Szenarien: Farbige Rahmen, Umschliessung, Farbunterscheidung, Drag-Anpassung, Ein-/Ausblenden |
| `cluster-manuell.feature` | Manuelles Zusammenfassen/Aufloesen | 7 Szenarien: Zusammenfassen, Aufloesen, Knoten entfernen/zuordnen, Neues Cluster, Rueckgaengig |
| `cluster-persistenz.feature` | Persistierung | 7 Szenarien: Speichern, Laden, Manuelle Aenderungen, Namen, Farben, Abwaertskompatibilitaet |
| `cluster-layout.feature` | Layout-Algorithmen | 9 Szenarien: Gruppierung, Lesbarkeit, Uebergreifende Kanten, Toolbar-Integration, Animation, Fallbacks |

## Designentscheidungen

- **Eine Feature-Datei pro Anforderung**: Klare Trennung der Verantwortlichkeiten, jede Datei ist unabhaengig lesbar.
- **Konsistenter Beispiel-Datensatz**: Alle Files verwenden das gleiche ML/DB-Cluster-Beispiel fuer Nachvollziehbarkeit.
- **`@critical`-Tags**: Kernszenarien jeder Anforderung sind markiert, um Priorisierung zu ermoeglichen.
- **Edge Cases abgedeckt**: Leerer Graph, einzelne Cluster, Abwaertskompatibilitaet, Rueckgaengig-Aktionen.
- **Deutsche Gherkin-Syntax**: Konsistent mit bestehenden Feature Files im Projekt.
