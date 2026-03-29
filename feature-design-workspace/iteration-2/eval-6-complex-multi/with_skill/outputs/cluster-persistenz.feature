# language: de
@cluster @persistenz
Feature: Cluster-Persistenz beim Speichern
  Als Nutzer des Wissensgraphen
  moechte ich, dass Cluster-Zuordnungen beim Speichern erhalten bleiben,
  damit ich meine Cluster-Struktur nicht bei jedem Oeffnen neu erstellen muss.

  Hintergrund:
    Gegeben ein Wissensgraph mit Cluster-Zuordnungen ist geoeffnet

  @critical @happy-path
  Szenario: Cluster-Zuordnungen werden beim Speichern persistiert
    Gegeben es existieren drei Cluster mit zugeordneten Knoten
    Wenn der Nutzer den Graphen speichert
    Dann werden alle Cluster-Zuordnungen in der Speicherdatei abgelegt

  @critical @happy-path
  Szenario: Cluster-Zuordnungen werden beim Laden wiederhergestellt
    Gegeben der Graph wurde mit Cluster-Zuordnungen gespeichert
    Wenn der Graph erneut geladen wird
    Dann werden alle Cluster mit ihren Knoten-Zuordnungen wiederhergestellt
    Und die visuelle Darstellung entspricht dem Zustand vor dem Speichern

  Szenario: Manuelle Cluster-Aenderungen werden persistiert
    Gegeben der Nutzer hat Cluster manuell zusammengefasst
    Wenn der Graph gespeichert und erneut geladen wird
    Dann sind die manuellen Zusammenfassungen erhalten geblieben

  @edge-case
  Szenario: Graph ohne Cluster speichern
    Gegeben der Graph enthaelt keine Cluster-Zuordnungen
    Wenn der Nutzer den Graphen speichert
    Dann wird die Speicherdatei ohne Cluster-Informationen erzeugt
    Und beim erneuten Laden werden keine Cluster angezeigt

  @edge-case
  Szenario: Kompatibilitaet mit aelteren Speicherdateien ohne Cluster-Daten
    Gegeben eine Speicherdatei wurde vor der Cluster-Funktion erstellt
    Wenn der Nutzer diese Datei laedt
    Dann wird der Graph ohne Cluster-Zuordnungen angezeigt
    Und es tritt kein Fehler auf

  Szenario: Cluster-Farben werden beim Speichern beibehalten
    Gegeben Cluster haben zugewiesene Farben
    Wenn der Graph gespeichert und erneut geladen wird
    Dann haben die Cluster die gleichen Farben wie vor dem Speichern

  @critical
  Szenario: Gespeicherte Cluster-Daten bleiben konsistent nach Knoten-Loeschung
    Gegeben ein Cluster enthaelt die Knoten "A", "B" und "C"
    Und der Graph wurde gespeichert
    Wenn der Knoten "B" geloescht wird
    Und der Graph erneut gespeichert wird
    Dann enthaelt der Cluster nur noch "A" und "C"
    Und die Speicherdatei enthaelt keine Referenz auf den geloeschten Knoten
