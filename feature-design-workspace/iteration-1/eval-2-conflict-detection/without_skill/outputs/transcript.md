# Transcript: Layout-Dropdown Feature Files

## Aufgabe

Ersetze den einzelnen "Auto-Layout"-Button in der Toolbar durch ein Dropdown-Menue mit drei Layout-Algorithmen: kraftbasiert, hierarchisch und kreisfoermig.

## Ausgangslage

Die bestehende `toolbar.feature` enthielt ein einfaches Szenario "Auto-Layout anwenden", das beim Klick auf einen Button die Knoten automatisch anordnet. Daneben gab es ein Szenario fuer den Knotenzaehler.

## Was wurde gemacht

### 1. toolbar.feature (modifiziert)

- Das Szenario "Auto-Layout anwenden" wurde entfernt.
- Ein neues Szenario "Layout-Dropdown oeffnen" wurde eingefuegt, das das Oeffnen des Dropdown-Menues und die Anzeige der drei Algorithmus-Optionen prueft.
- Das bestehende Zaehler-Szenario blieb unveraendert.

### 2. layout-dropdown.feature (neu erstellt)

Dieses Feature beschreibt das Verhalten des Layout-Dropdown-Menues im Detail:

- **Kraftbasiertes Layout anwenden** -- Verbundene Knoten werden naeher zusammen platziert, nicht verbundene weiter auseinander.
- **Hierarchisches Layout anwenden** -- Knoten werden in einer Baumstruktur angeordnet, uebergeordnete Knoten oberhalb ihrer Kindknoten.
- **Kreisfoermiges Layout anwenden** -- Knoten werden gleichmaessig auf einer Kreisform verteilt.
- **Dropdown schliesst sich bei Klick ausserhalb** -- UX-Verhalten: kein Layout wird angewendet.
- **Aktuell ausgewaehlter Algorithmus ist markiert** -- Der zuletzt verwendete Algorithmus wird visuell hervorgehoben.

## Erzeugte Dateien

- `toolbar.feature` -- Modifizierte Toolbar-Feature-Datei
- `layout-dropdown.feature` -- Neues Feature fuer das Layout-Dropdown-Menue
- `transcript.md` -- Dieses Dokument
