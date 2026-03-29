# language: de
Funktionalitaet: Schnellfilter fuer Knoten nach Label
  Als Benutzer moechte ich Knoten ueber ein Textfeld in der Toolbar nach ihrem Label filtern,
  damit ich in grossen Graphen schnell die relevanten Knoten finden kann.

  Grundlage:
    Angenommen der Graph enthaelt folgende Knoten:
      | Label            |
      | Datenbank        |
      | Datenstrom       |
      | Webserver        |
      | Loadbalancer     |
      | Cache            |

  # --- Filterung bei Texteingabe ---

  Szenario: Passende Knoten bleiben normal, nicht-passende werden ausgegraut
    Wenn ich "Daten" in das Schnellfilter-Textfeld eingebe
    Dann werden die Knoten "Datenbank" und "Datenstrom" normal dargestellt
    Und die Knoten "Webserver", "Loadbalancer" und "Cache" werden ausgegraut

  Szenario: Filter ohne Treffer graut alle Knoten aus
    Wenn ich "xyz123" in das Schnellfilter-Textfeld eingebe
    Dann werden alle Knoten ausgegraut

  Szenario: Filter der auf alle Knoten zutrifft laesst keinen ausgegraut
    Wenn ich "a" in das Schnellfilter-Textfeld eingebe
    Dann werden die Knoten "Datenbank", "Datenstrom", "Loadbalancer" und "Cache" normal dargestellt
    Und der Knoten "Webserver" wird ausgegraut

  # --- Leerer Filter stellt Normalzustand wieder her ---

  Szenario: Leeren des Filters zeigt alle Knoten wieder normal an
    Angenommen ich habe "Web" in das Schnellfilter-Textfeld eingegeben
    Wenn ich das Schnellfilter-Textfeld leere
    Dann werden alle Knoten normal dargestellt

  Szenario: Bei leerem Filter beim Laden sind alle Knoten normal sichtbar
    Wenn der Graph angezeigt wird
    Dann ist das Schnellfilter-Textfeld leer
    Und alle Knoten werden normal dargestellt

  # --- Inkrementelles Filtern beim Tippen ---

  Szenario: Filter wird bei jedem Tastendruck sofort aktualisiert
    Wenn ich "D" in das Schnellfilter-Textfeld eingebe
    Dann werden die Knoten "Datenbank" und "Datenstrom" normal dargestellt
    Wenn ich den Filter auf "Dat" erweitere
    Dann werden die Knoten "Datenbank" und "Datenstrom" normal dargestellt
    Und die Knoten "Webserver", "Loadbalancer" und "Cache" werden ausgegraut

  Szenario: Weitertippen grenzt Treffer weiter ein
    Wenn ich "Load" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Loadbalancer" normal dargestellt
    Und die Knoten "Datenbank", "Datenstrom", "Webserver" und "Cache" werden ausgegraut

  # --- Gross-/Kleinschreibung ---

  Szenario: Filter ignoriert Gross- und Kleinschreibung
    Wenn ich "datenbank" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Datenbank" normal dargestellt

  Szenario: Gemischte Schreibweise findet Treffer
    Wenn ich "CACHE" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Cache" normal dargestellt

  # --- Teilstring-Suche ---

  Szenario: Filter matched auf beliebige Teilstrings im Label
    Wenn ich "server" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Webserver" normal dargestellt
    Und die Knoten "Datenbank", "Datenstrom", "Loadbalancer" und "Cache" werden ausgegraut
