# language: de

Funktionalitaet: Manuelles Zusammenfassen und Aufloesen von Clustern
  Als Benutzer des Wissensgraphen
  moechte ich Cluster manuell zusammenfassen oder aufloesen koennen
  damit ich die automatische Gruppierung an meine Beduerfnisse anpassen kann

  Grundlage:
    Angenommen ein Wissensgraph mit erkannten Clustern ist geoeffnet:
      | Cluster-ID | Name       | Knoten                                             |
      | C1         | ML-Cluster | Maschinelles Lernen, Neuronale Netze, Deep Learning |
      | C2         | DB-Cluster | Datenbank, SQL, NoSQL                              |

  @critical
  Szenario: Zwei Cluster manuell zusammenfassen
    Wenn der Benutzer Cluster "C1" auswaehlt
    Und der Benutzer bei gehaltener Shift-Taste Cluster "C2" auswaehlt
    Und der Benutzer die Aktion "Cluster zusammenfassen" ausfuehrt
    Dann werden "C1" und "C2" zu einem neuen Cluster zusammengefasst
    Und das neue Cluster enthaelt alle Knoten beider Cluster
    Und ein einzelner Rahmen umschliesst alle zusammengefassten Knoten

  @critical
  Szenario: Cluster manuell aufloesen
    Wenn der Benutzer per Rechtsklick auf den Rahmen von Cluster "C1" klickt
    Und der Benutzer im Kontextmenue "Cluster aufloesen" waehlt
    Dann wird Cluster "C1" aufgeloest
    Und die Knoten von "C1" gehoeren keinem Cluster mehr an
    Und der Rahmen von "C1" wird entfernt
    Und Cluster "C2" bleibt unveraendert

  Szenario: Knoten manuell aus Cluster entfernen
    Wenn der Benutzer per Rechtsklick auf den Knoten "Deep Learning" klickt
    Und der Benutzer im Kontextmenue "Aus Cluster entfernen" waehlt
    Dann gehoert "Deep Learning" keinem Cluster mehr an
    Und Cluster "C1" enthaelt nur noch "Maschinelles Lernen" und "Neuronale Netze"
    Und der Rahmen von "C1" wird entsprechend verkleinert

  Szenario: Knoten manuell einem bestehenden Cluster zuordnen
    Angenommen der Knoten "Einzelknoten" gehoert keinem Cluster an
    Wenn der Benutzer den Knoten "Einzelknoten" in den Rahmen von Cluster "C1" zieht
    Dann wird "Einzelknoten" dem Cluster "C1" zugeordnet
    Und der Rahmen von "C1" wird erweitert um "Einzelknoten" einzuschliessen

  Szenario: Neues Cluster manuell aus selektierten Knoten erstellen
    Angenommen die Knoten "Einzelknoten1" und "Einzelknoten2" gehoeren keinem Cluster an
    Wenn der Benutzer die Knoten "Einzelknoten1" und "Einzelknoten2" auswaehlt
    Und der Benutzer die Aktion "Neues Cluster erstellen" ausfuehrt
    Dann wird ein neues Cluster mit diesen beiden Knoten erstellt
    Und ein farbiger Rahmen umschliesst die ausgewaehlten Knoten

  Szenario: Zusammenfassen rueckgaengig machen
    Angenommen die Cluster "C1" und "C2" wurden manuell zusammengefasst
    Wenn der Benutzer die Aktion "Rueckgaengig" ausfuehrt
    Dann werden die urspruenglichen Cluster "C1" und "C2" wiederhergestellt
    Und die Knoten befinden sich wieder in ihren urspruenglichen Clustern

  Szenario: Aufloesen rueckgaengig machen
    Angenommen Cluster "C1" wurde manuell aufgeloest
    Wenn der Benutzer die Aktion "Rueckgaengig" ausfuehrt
    Dann wird Cluster "C1" mit allen urspruenglichen Knoten wiederhergestellt
