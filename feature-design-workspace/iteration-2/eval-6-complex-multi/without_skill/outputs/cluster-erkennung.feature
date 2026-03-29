# language: de

Funktionalitaet: Automatische Cluster-Erkennung im Wissensgraph
  Als Benutzer des Wissensgraphen
  moechte ich dass zusammenhaengende Knotengruppen automatisch als Cluster erkannt werden
  damit ich die Struktur meines Graphen besser verstehen kann

  Grundlage:
    Angenommen ein Wissensgraph mit folgenden Knoten ist geoeffnet:
      | Knoten-ID | Label             |
      | K1        | Maschinelles Lernen |
      | K2        | Neuronale Netze     |
      | K3        | Deep Learning       |
      | K4        | Datenbank           |
      | K5        | SQL                 |
      | K6        | NoSQL               |
      | K7        | Einzelknoten        |
    Und folgende Kanten existieren:
      | Von | Nach |
      | K1  | K2   |
      | K2  | K3   |
      | K1  | K3   |
      | K4  | K5   |
      | K4  | K6   |
      | K5  | K6   |

  @critical
  Szenario: Cluster werden automatisch aus Kantenverbindungen erkannt
    Wenn die automatische Cluster-Erkennung ausgefuehrt wird
    Dann werden 2 Cluster erkannt
    Und Cluster 1 enthaelt die Knoten "K1", "K2", "K3"
    Und Cluster 2 enthaelt die Knoten "K4", "K5", "K6"
    Und der Knoten "K7" gehoert keinem Cluster an

  @critical
  Szenario: Cluster-Erkennung wird bei neuem Graphen automatisch ausgefuehrt
    Wenn der Wissensgraph geladen wird
    Dann wird die Cluster-Erkennung automatisch gestartet
    Und die erkannten Cluster werden im Graphen angezeigt

  Szenario: Neue Kante erzeugt Cluster-Aktualisierung
    Angenommen die automatische Cluster-Erkennung wurde ausgefuehrt
    Und es existieren 2 Cluster
    Wenn eine neue Kante von "K3" nach "K4" hinzugefuegt wird
    Und die Cluster-Erkennung erneut ausgefuehrt wird
    Dann werden die beiden Cluster zu einem einzelnen Cluster zusammengefasst
    Und das zusammengefasste Cluster enthaelt die Knoten "K1", "K2", "K3", "K4", "K5", "K6"

  Szenario: Entfernte Kante kann Cluster aufteilen
    Angenommen die automatische Cluster-Erkennung wurde ausgefuehrt
    Und Cluster 1 enthaelt die Knoten "K1", "K2", "K3"
    Wenn die Kante zwischen "K1" und "K2" entfernt wird
    Und die Kante zwischen "K1" und "K3" entfernt wird
    Und die Cluster-Erkennung erneut ausgefuehrt wird
    Dann gehoert "K1" keinem Cluster mehr an
    Und "K2" und "K3" bilden weiterhin ein Cluster

  Szenario: Isolierte Knoten bilden kein Cluster
    Wenn die automatische Cluster-Erkennung ausgefuehrt wird
    Dann wird der Knoten "K7" keinem Cluster zugeordnet

  Szenario: Mindestgroesse fuer Cluster
    Angenommen es existiert ein Knotenpaar "K8" und "K9" mit genau einer Kante
    Wenn die automatische Cluster-Erkennung ausgefuehrt wird
    Dann bilden "K8" und "K9" ein Cluster
