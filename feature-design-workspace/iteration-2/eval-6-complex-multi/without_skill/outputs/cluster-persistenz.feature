# language: de

Funktionalitaet: Persistierung der Cluster-Zuordnung beim Speichern
  Als Benutzer des Wissensgraphen
  moechte ich dass meine Cluster-Zuordnungen beim Speichern erhalten bleiben
  damit ich beim naechsten Oeffnen des Graphen meine Cluster-Struktur wiederfinde

  Grundlage:
    Angenommen ein Wissensgraph mit Clustern ist geoeffnet:
      | Cluster-ID | Name       | Knoten                                             |
      | C1         | ML-Cluster | Maschinelles Lernen, Neuronale Netze, Deep Learning |
      | C2         | DB-Cluster | Datenbank, SQL, NoSQL                              |

  @critical
  Szenario: Cluster-Zuordnung wird beim Speichern persistiert
    Wenn der Benutzer den Wissensgraphen speichert
    Dann werden die Cluster-Zuordnungen in der Speicherdatei abgelegt
    Und die Zuordnung von Knoten zu Clustern bleibt erhalten

  @critical
  Szenario: Cluster-Zuordnung wird beim Laden wiederhergestellt
    Angenommen der Wissensgraph wurde mit Cluster-Zuordnungen gespeichert
    Wenn der Benutzer den Wissensgraphen erneut oeffnet
    Dann werden die gespeicherten Cluster wiederhergestellt
    Und Cluster "C1" enthaelt die Knoten "Maschinelles Lernen", "Neuronale Netze", "Deep Learning"
    Und Cluster "C2" enthaelt die Knoten "Datenbank", "SQL", "NoSQL"
    Und die farbigen Rahmen werden korrekt angezeigt

  Szenario: Manuelle Cluster-Aenderungen werden gespeichert
    Angenommen der Benutzer hat Cluster "C1" manuell aufgeloest
    Und der Benutzer hat ein neues Cluster "C3" erstellt
    Wenn der Benutzer den Wissensgraphen speichert
    Und der Benutzer den Wissensgraphen erneut oeffnet
    Dann existiert Cluster "C1" nicht mehr
    Und Cluster "C3" ist mit seinen Knoten vorhanden

  Szenario: Cluster-Namen werden persistiert
    Angenommen der Benutzer hat Cluster "C1" in "KI-Methoden" umbenannt
    Wenn der Benutzer den Wissensgraphen speichert
    Und der Benutzer den Wissensgraphen erneut oeffnet
    Dann traegt Cluster "C1" den Namen "KI-Methoden"

  Szenario: Cluster-Farben werden persistiert
    Angenommen Cluster "C1" hat die Rahmenfarbe "blau"
    Wenn der Benutzer den Wissensgraphen speichert
    Und der Benutzer den Wissensgraphen erneut oeffnet
    Dann hat Cluster "C1" weiterhin die Rahmenfarbe "blau"

  Szenario: Graph ohne Cluster laesst sich speichern und laden
    Angenommen alle Cluster wurden aufgeloest
    Wenn der Benutzer den Wissensgraphen speichert
    Und der Benutzer den Wissensgraphen erneut oeffnet
    Dann werden keine Cluster angezeigt
    Und die automatische Cluster-Erkennung wird nicht erneut ausgefuehrt

  Szenario: Abwaertskompatibilitaet bei fehlenden Cluster-Daten
    Angenommen eine Speicherdatei ohne Cluster-Informationen existiert
    Wenn der Benutzer diese Datei oeffnet
    Dann wird der Graph ohne Cluster-Zuordnungen geladen
    Und die automatische Cluster-Erkennung kann manuell gestartet werden
