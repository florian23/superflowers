# language: de

Funktionalitaet: Cluster-spezifische Layout-Algorithmen
  Als Benutzer des Wissensgraphen
  moechte ich Layout-Algorithmen nutzen die Cluster beruecksichtigen
  damit die Cluster-Struktur im Layout sichtbar und uebersichtlich wird

  Grundlage:
    Angenommen ein Wissensgraph mit erkannten Clustern ist geoeffnet:
      | Cluster-ID | Knoten                                             |
      | C1         | Maschinelles Lernen, Neuronale Netze, Deep Learning |
      | C2         | Datenbank, SQL, NoSQL                              |
    Und der Knoten "Einzelknoten" gehoert keinem Cluster an

  @critical
  Szenario: Cluster-Layout gruppiert Knoten nach Cluster-Zugehoerigkeit
    Wenn der Benutzer den Layout-Algorithmus "Cluster-Layout" anwendet
    Dann werden die Knoten innerhalb eines Clusters nah beieinander positioniert
    Und zwischen verschiedenen Clustern wird ein deutlicher Abstand eingehalten
    Und der Knoten "Einzelknoten" wird ausserhalb der Cluster-Gruppen positioniert

  @critical
  Szenario: Cluster-internes Layout optimiert Lesbarkeit
    Wenn der Benutzer den Layout-Algorithmus "Cluster-Layout" anwendet
    Dann werden die Knoten innerhalb jedes Clusters ueberlappungsfrei angeordnet
    Und die Kanten innerhalb eines Clusters verlaufen uebersichtlich

  Szenario: Cluster-uebergreifende Kanten werden beruecksichtigt
    Angenommen es existiert eine Kante von "Deep Learning" zu "Datenbank"
    Wenn der Benutzer den Layout-Algorithmus "Cluster-Layout" anwendet
    Dann werden die Cluster so positioniert dass Cluster-uebergreifende Kanten moeglichst kurz sind

  Szenario: Layout-Algorithmus im Toolbar-Dropdown verfuegbar
    Wenn der Benutzer auf den "Layout"-Dropdown-Button in der Toolbar klickt
    Dann enthaelt das Dropdown-Menue den Eintrag "Cluster-Layout"

  Szenario: Kraftbasiertes Layout innerhalb von Clustern
    Wenn der Benutzer den Layout-Algorithmus "Cluster-Layout" anwendet
    Dann werden die Knoten innerhalb jedes Clusters mittels kraftbasiertem Algorithmus angeordnet
    Und die Cluster selbst werden als Einheiten zueinander positioniert

  Szenario: Layout behaelt Cluster-Rahmen bei
    Angenommen die Cluster-Rahmen sind sichtbar
    Wenn der Benutzer den Layout-Algorithmus "Cluster-Layout" anwendet
    Dann umschliessen die Rahmen weiterhin alle zugehoerigen Knoten
    Und die Rahmen ueberlappen sich nicht

  Szenario: Layout-Animation bei Cluster-Layout
    Wenn der Benutzer den Layout-Algorithmus "Cluster-Layout" anwendet
    Dann werden die Knoten animiert an ihre neuen Positionen verschoben
    Und die Animation dauert nicht laenger als 2 Sekunden

  Szenario: Cluster-Layout bei einzelnem Cluster
    Angenommen es existiert nur Cluster "C1"
    Wenn der Benutzer den Layout-Algorithmus "Cluster-Layout" anwendet
    Dann werden die Knoten von "C1" zentriert und uebersichtlich angeordnet
    Und nicht-zugeordnete Knoten werden am Rand positioniert

  Szenario: Cluster-Layout bei Graph ohne Cluster
    Angenommen es existieren keine Cluster
    Wenn der Benutzer den Layout-Algorithmus "Cluster-Layout" anwendet
    Dann wird stattdessen das Standard-kraftbasierte Layout angewendet
    Und der Benutzer wird darauf hingewiesen dass keine Cluster vorhanden sind
