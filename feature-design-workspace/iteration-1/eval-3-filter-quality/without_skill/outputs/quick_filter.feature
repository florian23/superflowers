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

  # --- Kernverhalten ---

  Szenario: Passende Knoten bleiben hervorgehoben, nicht-passende werden ausgegraut
    Wenn ich "Daten" in das Schnellfilter-Textfeld eingebe
    Dann werden die Knoten "Datenbank" und "Datenstrom" normal dargestellt
    Und die Knoten "Webserver", "Loadbalancer" und "Cache" werden ausgegraut

  Szenario: Leeres Filterfeld zeigt alle Knoten normal an
    Angenommen ich habe "Web" in das Schnellfilter-Textfeld eingegeben
    Wenn ich das Schnellfilter-Textfeld leere
    Dann werden alle Knoten normal dargestellt

  Szenario: Filter ohne Treffer graut alle Knoten aus
    Wenn ich "xyz123" in das Schnellfilter-Textfeld eingebe
    Dann werden alle Knoten ausgegraut

  # --- Inkrementelles Tippen ---

  Szenario: Filter wird bei jedem Tastendruck aktualisiert
    Wenn ich "D" in das Schnellfilter-Textfeld eingebe
    Dann werden die Knoten "Datenbank" und "Datenstrom" normal dargestellt
    Wenn ich den Filter auf "Da" erweitere
    Dann werden die Knoten "Datenbank" und "Datenstrom" normal dargestellt
    Wenn ich den Filter auf "Dat" erweitere
    Dann werden die Knoten "Datenbank" und "Datenstrom" normal dargestellt
    Und die Knoten "Webserver", "Loadbalancer" und "Cache" werden ausgegraut

  Szenario: Eingrenzung der Treffer beim Weitertippen
    Wenn ich "Load" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Loadbalancer" normal dargestellt
    Und die Knoten "Datenbank", "Datenstrom", "Webserver" und "Cache" werden ausgegraut

  # --- Gross-/Kleinschreibung ---

  Szenario: Filter ignoriert Gross- und Kleinschreibung
    Wenn ich "datenbank" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Datenbank" normal dargestellt

  Szenario: Filter mit gemischter Schreibweise findet Treffer
    Wenn ich "CACHE" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Cache" normal dargestellt

  # --- Teilstring-Suche ---

  Szenario: Filter matched auf beliebige Teilstrings im Label
    Wenn ich "server" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Webserver" normal dargestellt
    Und die Knoten "Datenbank", "Datenstrom", "Loadbalancer" und "Cache" werden ausgegraut

  Szenario: Einzelner Buchstabe filtert alle Knoten die ihn enthalten
    Wenn ich "a" in das Schnellfilter-Textfeld eingebe
    Dann werden die Knoten "Datenbank", "Datenstrom", "Loadbalancer" und "Cache" normal dargestellt
    Und der Knoten "Webserver" wird ausgegraut
