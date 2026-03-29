# language: de

Funktionalitaet: Visuelle Darstellung von Clustern mit farbigen Rahmen
  Als Benutzer des Wissensgraphen
  moechte ich Cluster visuell durch farbige Rahmen unterscheiden koennen
  damit ich die Zugehoerigkeit von Knoten auf einen Blick erkennen kann

  Grundlage:
    Angenommen ein Wissensgraph mit erkannten Clustern ist geoeffnet:
      | Cluster-ID | Knoten                          |
      | C1         | Maschinelles Lernen, Neuronale Netze, Deep Learning |
      | C2         | Datenbank, SQL, NoSQL           |

  @critical
  Szenario: Jedes Cluster erhaelt einen farbigen Rahmen
    Wenn die Cluster im Graphen dargestellt werden
    Dann wird um die Knoten von Cluster "C1" ein farbiger Rahmen angezeigt
    Und wird um die Knoten von Cluster "C2" ein farbiger Rahmen angezeigt
    Und die Rahmenfarben von "C1" und "C2" sind unterschiedlich

  @critical
  Szenario: Cluster-Rahmen umschliesst alle zugehoerigen Knoten
    Wenn die Cluster im Graphen dargestellt werden
    Dann umschliesst der Rahmen von Cluster "C1" alle drei Knoten des Clusters
    Und kein Knoten von "C2" liegt innerhalb des Rahmens von "C1"

  Szenario: Cluster-Farben sind visuell gut unterscheidbar
    Angenommen es existieren 5 Cluster
    Wenn die Cluster im Graphen dargestellt werden
    Dann erhaelt jedes Cluster eine eindeutige Rahmenfarbe
    Und die Farben haben ausreichend Kontrast zueinander

  Szenario: Cluster-Rahmen passt sich bei Knotenverschiebung an
    Angenommen Cluster "C1" wird mit einem Rahmen dargestellt
    Wenn der Benutzer den Knoten "Neuronale Netze" an eine neue Position zieht
    Dann wird der Rahmen von Cluster "C1" automatisch an die neue Knotenposition angepasst

  Szenario: Knoten ohne Cluster haben keinen Rahmen
    Angenommen der Knoten "Einzelknoten" gehoert keinem Cluster an
    Wenn die Cluster im Graphen dargestellt werden
    Dann wird um "Einzelknoten" kein Cluster-Rahmen angezeigt

  Szenario: Cluster-Label wird im Rahmen angezeigt
    Wenn die Cluster im Graphen dargestellt werden
    Dann wird der Name des Clusters im oberen Bereich des Rahmens angezeigt

  Szenario: Cluster-Rahmen kann ein- und ausgeblendet werden
    Angenommen die Cluster-Rahmen sind sichtbar
    Wenn der Benutzer die Cluster-Ansicht deaktiviert
    Dann werden alle Cluster-Rahmen ausgeblendet
    Und die Knoten bleiben an ihren Positionen
