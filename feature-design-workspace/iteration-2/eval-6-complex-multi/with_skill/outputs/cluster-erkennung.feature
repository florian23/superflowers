# language: de
@cluster @erkennung
Feature: Automatische Cluster-Erkennung
  Als Nutzer des Wissensgraphen
  moechte ich, dass zusammenhaengende Knotengruppen automatisch als Cluster erkannt werden,
  damit ich die Struktur meines Wissensgraphen besser verstehe.

  Hintergrund:
    Gegeben ein Wissensgraph ist geoeffnet

  @critical @happy-path
  Szenario: Cluster-Erkennung bei verbundenen Knoten
    Gegeben der Graph enthaelt drei Knoten "A", "B" und "C"
    Und "A" ist mit "B" durch eine Kante verbunden
    Und "B" ist mit "C" durch eine Kante verbunden
    Wenn die automatische Cluster-Erkennung ausgeloest wird
    Dann werden "A", "B" und "C" einem gemeinsamen Cluster zugeordnet

  @critical
  Szenario: Mehrere unabhaengige Cluster werden erkannt
    Gegeben der Graph enthaelt die Knoten "A", "B", "C", "X" und "Y"
    Und "A" ist mit "B" durch eine Kante verbunden
    Und "B" ist mit "C" durch eine Kante verbunden
    Und "X" ist mit "Y" durch eine Kante verbunden
    Aber es gibt keine Kante zwischen den Gruppen "A,B,C" und "X,Y"
    Wenn die automatische Cluster-Erkennung ausgeloest wird
    Dann werden zwei separate Cluster erkannt
    Und "A", "B" und "C" gehoeren zum gleichen Cluster
    Und "X" und "Y" gehoeren zum gleichen Cluster

  @edge-case
  Szenario: Einzelne Knoten ohne Verbindungen
    Gegeben der Graph enthaelt einen einzelnen Knoten "Isoliert" ohne Kanten
    Wenn die automatische Cluster-Erkennung ausgeloest wird
    Dann wird "Isoliert" keinem Cluster zugeordnet

  @edge-case
  Szenario: Leerer Graph
    Gegeben der Graph enthaelt keine Knoten
    Wenn die automatische Cluster-Erkennung ausgeloest wird
    Dann werden keine Cluster erkannt
    Und eine Hinweismeldung wird angezeigt

  @critical
  Szenario: Cluster-Erkennung nach Hinzufuegen einer neuen Kante
    Gegeben der Graph enthaelt zwei separate Cluster
    Wenn eine neue Kante zwischen Knoten aus verschiedenen Clustern hinzugefuegt wird
    Und die automatische Cluster-Erkennung erneut ausgeloest wird
    Dann werden die beiden Cluster zu einem einzigen Cluster zusammengefuehrt

  @edge-case
  Szenario: Cluster-Erkennung nach Entfernen einer Brueckenkante
    Gegeben ein Cluster enthaelt die Knoten "A", "B", "C" und "D"
    Und die einzige Verbindung zwischen "A,B" und "C,D" ist die Kante "B-C"
    Wenn die Kante "B-C" entfernt wird
    Und die automatische Cluster-Erkennung erneut ausgeloest wird
    Dann werden zwei separate Cluster erkannt

  Szenariogrundriss: Mindestgroesse fuer Cluster-Erkennung
    Gegeben der Graph enthaelt eine Gruppe von <anzahl> verbundenen Knoten
    Wenn die automatische Cluster-Erkennung ausgeloest wird
    Dann <ergebnis>

    Beispiele:
      | anzahl | ergebnis                                  |
      | 1      | wird kein Cluster fuer diese Gruppe erkannt |
      | 2      | wird ein Cluster mit zwei Knoten erkannt    |
      | 10     | wird ein Cluster mit zehn Knoten erkannt    |
