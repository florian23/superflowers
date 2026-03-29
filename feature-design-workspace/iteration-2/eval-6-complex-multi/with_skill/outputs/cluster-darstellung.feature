# language: de
@cluster @darstellung
Feature: Visuelle Darstellung von Clustern
  Als Nutzer des Wissensgraphen
  moechte ich Cluster visuell durch farbige Rahmen unterscheiden koennen,
  damit ich die Zugehoerigkeit von Knoten auf einen Blick erkenne.

  Hintergrund:
    Gegeben ein Wissensgraph mit erkannten Clustern ist geoeffnet

  @critical @happy-path
  Szenario: Cluster werden mit farbigen Rahmen dargestellt
    Gegeben es existieren zwei Cluster im Graphen
    Dann wird jeder Cluster mit einem eigenen farbigen Rahmen umschlossen
    Und die Rahmenfarben der beiden Cluster unterscheiden sich

  @critical
  Szenario: Knoten innerhalb eines Clusters sind visuell gruppiert
    Gegeben ein Cluster enthaelt die Knoten "A", "B" und "C"
    Dann werden "A", "B" und "C" innerhalb desselben farbigen Rahmens angezeigt

  Szenario: Cluster-Farben bleiben bei erneutem Oeffnen konsistent
    Gegeben der Graph wurde mit Cluster-Zuordnungen gespeichert
    Wenn der Graph erneut geoeffnet wird
    Dann behalten die Cluster ihre zuvor zugewiesenen Farben

  @edge-case
  Szenario: Viele Cluster mit unterscheidbaren Farben
    Gegeben der Graph enthaelt zehn verschiedene Cluster
    Dann wird jedem Cluster eine visuell unterscheidbare Farbe zugewiesen
    Und kein Cluster teilt sich die Farbe mit einem benachbarten Cluster

  Szenario: Knoten ohne Cluster-Zuordnung haben keinen Rahmen
    Gegeben es gibt Knoten die keinem Cluster zugeordnet sind
    Dann werden diese Knoten ohne Cluster-Rahmen dargestellt

  @critical
  Szenario: Cluster-Rahmen passt sich bei Verschieben von Knoten an
    Gegeben ein Cluster wird mit einem Rahmen dargestellt
    Wenn ein Knoten innerhalb des Clusters verschoben wird
    Dann passt sich der Cluster-Rahmen automatisch an die neue Position an

  @edge-case
  Szenario: Ueberlappende Cluster-Rahmen
    Gegeben zwei Cluster liegen raeumlich nah beieinander
    Dann werden die Rahmen beider Cluster vollstaendig angezeigt
    Und die Ueberlappung ist durch Transparenz erkennbar

  Szenario: Cluster-Rahmen ein- und ausblenden
    Gegeben Cluster-Rahmen werden angezeigt
    Wenn der Nutzer die Cluster-Darstellung deaktiviert
    Dann werden keine Cluster-Rahmen mehr angezeigt
    Und die Knoten bleiben an ihrer Position
