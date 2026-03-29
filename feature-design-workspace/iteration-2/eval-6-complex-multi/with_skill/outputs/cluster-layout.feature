# language: de
@cluster @layout
Feature: Cluster-spezifische Layout-Algorithmen
  Als Nutzer des Wissensgraphen
  moechte ich Layout-Algorithmen pro Cluster anwenden koennen,
  damit die Knoten innerhalb eines Clusters uebersichtlich angeordnet werden.

  Hintergrund:
    Gegeben ein Wissensgraph mit erkannten Clustern ist geoeffnet

  @critical @happy-path
  Szenario: Layout-Algorithmus auf einen Cluster anwenden
    Gegeben ein Cluster enthaelt ungeordnete Knoten
    Wenn der Nutzer einen Layout-Algorithmus fuer diesen Cluster auswaehlt
    Dann werden die Knoten innerhalb des Clusters neu angeordnet
    Und die Knoten ausserhalb des Clusters bleiben an ihrer Position

  @critical
  Szenario: Verschiedene Algorithmen fuer verschiedene Cluster
    Gegeben es existieren Cluster "Alpha" und Cluster "Beta"
    Wenn der Nutzer fuer "Alpha" ein kreisfoermiges Layout waehlt
    Und fuer "Beta" ein hierarchisches Layout waehlt
    Dann wird "Alpha" kreisfoermig angeordnet
    Und "Beta" wird hierarchisch angeordnet

  Szenariogrundriss: Verfuegbare Layout-Algorithmen
    Gegeben ein Cluster mit mehreren Knoten existiert
    Wenn der Nutzer den Layout-Algorithmus "<algorithmus>" anwendet
    Dann werden die Knoten des Clusters nach dem "<algorithmus>"-Schema angeordnet

    Beispiele:
      | algorithmus   |
      | Kreisfoermig  |
      | Hierarchisch  |
      | Kraefte-basiert |
      | Raster        |

  @critical
  Szenario: Cluster-Layout beeinflusst nicht andere Cluster
    Gegeben es existieren zwei Cluster mit jeweils fuenf Knoten
    Wenn ein Layout-Algorithmus auf den ersten Cluster angewendet wird
    Dann aendert sich die Anordnung nur im ersten Cluster
    Und der zweite Cluster bleibt unveraendert

  @edge-case
  Szenario: Layout fuer Cluster mit nur einem Knoten
    Gegeben ein Cluster enthaelt nur einen einzigen Knoten
    Wenn der Nutzer einen Layout-Algorithmus anwendet
    Dann bleibt der Knoten an seiner Position
    Und es wird kein Fehler angezeigt

  Szenario: Layout auf alle Cluster gleichzeitig anwenden
    Gegeben es existieren mehrere Cluster im Graphen
    Wenn der Nutzer das Layout auf alle Cluster gleichzeitig anwendet
    Dann wird jeder Cluster nach seinem zugewiesenen Algorithmus neu angeordnet

  @edge-case
  Szenario: Layout beibehalten nach manueller Knoten-Verschiebung
    Gegeben ein Cluster wurde mit einem Layout-Algorithmus angeordnet
    Wenn der Nutzer einen Knoten manuell verschiebt
    Dann wird das automatische Layout fuer diesen Cluster nicht erneut ausgefuehrt
    Und die manuelle Position wird beibehalten

  Szenario: Cluster-Layout wird beim Speichern persistiert
    Gegeben jedem Cluster wurde ein Layout-Algorithmus zugewiesen
    Wenn der Graph gespeichert und erneut geladen wird
    Dann sind die Layout-Zuordnungen der Cluster erhalten geblieben
