# Transcript: Layout-Dropdown Feature Files

## Ausgangslage

Bestehendes Projekt in `/tmp/eval-conflict-test-v2/` mit einer `toolbar.feature`, die einen einzelnen "Auto-Layout"-Button-Scenario enthielt:

```gherkin
Scenario: Auto-Layout anwenden
  Given die Knoten sind unuebersichtlich positioniert
  When ich den "Auto-Layout"-Button klicke
  Then werden die Knoten automatisch uebersichtlich angeordnet
```

## Aufgabe

Den einzelnen Auto-Layout-Button durch ein Dropdown-Menue mit drei Layout-Algorithmen ersetzen:
- Kraftbasiert (force-directed)
- Hierarchisch (hierarchical/tree)
- Kreisfoermig (circular)

## Durchgefuehrte Schritte

1. Bestehende `toolbar.feature` in `/tmp/eval-conflict-test-v2/features/` gelesen und analysiert.
2. Ueberarbeitete `toolbar.feature` erstellt, die das Auto-Layout-Scenario durch Dropdown-Szenarien ersetzt:
   - Dropdown oeffnen und Eintraege pruefen
   - Kraftbasiertes Layout anwenden
   - Hierarchisches Layout anwenden
   - Kreisfoermiges Layout anwenden
   - Dropdown schliesst nach Auswahl
   - Dropdown schliesst bei Klick ausserhalb
   - Bestehendes Zaehler-Scenario beibehalten
3. Separate `layout_algorithmen.feature` erstellt mit detaillierten Szenarien fuer jeden Algorithmus:
   - Kraftbasiert: Gruppierung verbundener Knoten, keine Ueberlappung
   - Hierarchisch: Ebenenzuweisung, Kantenrichtung
   - Kreisfoermig: Gleichmaessige Verteilung, Radius-Anpassung

## Erzeugte Dateien

- `outputs/toolbar.feature` -- Ueberarbeitete Toolbar mit Dropdown-Menue statt einzelnem Button (8 Szenarien)
- `outputs/layout_algorithmen.feature` -- Detaillierte Algorithmus-Szenarien (6 Szenarien)
- `outputs/transcript.md` -- Dieses Dokument

## Designentscheidungen

- **Zwei Feature Files statt eines**: Die Toolbar-Feature behandelt die UI-Interaktion (Dropdown oeffnen/schliessen, Algorithmus auswaehlen), waehrend die Algorithmen-Feature das Verhalten der einzelnen Layout-Algorithmen im Detail spezifiziert. Diese Trennung folgt dem Single-Responsibility-Prinzip.
- **Background beibehalten**: Beide Features verwenden denselben Background (`Given ein Wissensgraph mit Knoten und Kanten ist geoeffnet`), da alle Szenarien einen geoeffneten Graphen voraussetzen.
- **Zaehler-Scenario erhalten**: Das bestehende Scenario "Zaehler zeigt aktuelle Anzahl" wurde unveraendert in der toolbar.feature belassen, da es nicht vom Layout-Umbau betroffen ist.
- **Konfliktstelle**: Das alte `Scenario: Auto-Layout anwenden` wurde komplett entfernt und durch die neuen Dropdown-Szenarien ersetzt. Dies ist die zentrale Aenderung gegenueber der Ursprungsdatei.
