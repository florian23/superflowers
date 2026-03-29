# language: de
@cluster @verwaltung
Feature: Manuelle Cluster-Verwaltung
  Als Nutzer des Wissensgraphen
  moechte ich Cluster manuell zusammenfassen und aufloesen koennen,
  damit ich die automatische Erkennung nach meinen Beduerfnissen anpassen kann.

  Hintergrund:
    Gegeben ein Wissensgraph mit erkannten Clustern ist geoeffnet

  @critical @happy-path
  Szenario: Zwei Cluster manuell zusammenfassen
    Gegeben es existieren Cluster "Alpha" und Cluster "Beta"
    Wenn der Nutzer Cluster "Alpha" und "Beta" zum Zusammenfassen auswaehlt
    Dann werden alle Knoten beider Cluster in einem neuen gemeinsamen Cluster vereint
    Und der neue Cluster erhaelt einen einheitlichen Rahmen

  @critical @happy-path
  Szenario: Cluster manuell aufloesen
    Gegeben es existiert ein Cluster "Gamma" mit fuenf Knoten
    Wenn der Nutzer den Cluster "Gamma" aufloest
    Dann sind die fuenf Knoten keinem Cluster mehr zugeordnet
    Und es wird kein Rahmen mehr um diese Knoten angezeigt

  Szenario: Einzelnen Knoten aus Cluster entfernen
    Gegeben ein Cluster enthaelt die Knoten "A", "B" und "C"
    Wenn der Nutzer den Knoten "A" aus dem Cluster entfernt
    Dann gehoeren nur noch "B" und "C" zum Cluster
    Und "A" ist keinem Cluster mehr zugeordnet

  Szenario: Einzelnen Knoten einem bestehenden Cluster hinzufuegen
    Gegeben ein Cluster enthaelt die Knoten "A" und "B"
    Und der Knoten "C" ist keinem Cluster zugeordnet
    Wenn der Nutzer den Knoten "C" dem Cluster hinzufuegt
    Dann gehoeren "A", "B" und "C" zum selben Cluster

  @edge-case
  Szenario: Letzten Knoten aus Cluster entfernen loest Cluster auf
    Gegeben ein Cluster enthaelt nur den Knoten "A"
    Wenn der Nutzer den Knoten "A" aus dem Cluster entfernt
    Dann wird der Cluster vollstaendig aufgeloest

  @edge-case
  Szenario: Zusammenfassen von Clustern mit identischen Knoten
    Gegeben es existiert nur ein einzelner Cluster
    Wenn der Nutzer versucht diesen Cluster mit sich selbst zusammenzufassen
    Dann wird eine Hinweismeldung angezeigt
    Und der Cluster bleibt unveraendert

  @critical
  Szenario: Manuelle Aenderungen ueberschreiben automatische Erkennung
    Gegeben der Nutzer hat Cluster "Alpha" und "Beta" manuell zusammengefasst
    Wenn die automatische Cluster-Erkennung erneut ausgeloest wird
    Dann wird die manuelle Zusammenfassung beibehalten
    Und der Nutzer wird gefragt ob die manuelle Zuordnung ueberschrieben werden soll

  Szenario: Rueckgaengig machen einer manuellen Cluster-Aenderung
    Gegeben der Nutzer hat einen Cluster aufgeloest
    Wenn der Nutzer die letzte Aenderung rueckgaengig macht
    Dann wird der Cluster wiederhergestellt
    Und alle Knoten sind wieder dem Cluster zugeordnet
