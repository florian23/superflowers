# language: de
Funktionalitaet: Schnellfilter - Toolbar-Integration und Bedienbarkeit
  Als Benutzer moechte ich den Schnellfilter bequem ueber die Toolbar bedienen koennen,
  damit der Filtervorgang meinen Arbeitsfluss nicht unterbricht.

  Grundlage:
    Angenommen der Graph enthaelt folgende Knoten:
      | Label          |
      | Frontend       |
      | Backend        |
      | Middleware     |

  # --- Sichtbarkeit und Platzierung ---

  Szenario: Schnellfilter-Textfeld ist in der Toolbar sichtbar
    Dann ist das Schnellfilter-Textfeld in der Toolbar sichtbar

  Szenario: Schnellfilter-Textfeld hat einen Platzhaltertext
    Dann zeigt das Schnellfilter-Textfeld einen Platzhaltertext an

  # --- Zuruecksetzen ---

  Szenario: Filtern und anschliessend Loeschen stellt alle Knoten wieder her
    Wenn ich "Front" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Frontend" normal dargestellt
    Und die Knoten "Backend" und "Middleware" werden ausgegraut
    Wenn ich das Schnellfilter-Textfeld leere
    Dann werden alle Knoten normal dargestellt

  # --- Fokus ---

  Szenario: Textfeld behaelt den Fokus waehrend des Tippens
    Wenn ich in das Schnellfilter-Textfeld klicke
    Und ich "Back" eingebe
    Dann hat das Schnellfilter-Textfeld weiterhin den Fokus

  # --- Sofortiges Feedback ---

  Szenario: Filterung erfolgt ohne merkliche Verzoegerung
    Wenn ich "Mid" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Middleware" sofort normal dargestellt
    Und die Knoten "Frontend" und "Backend" werden sofort ausgegraut
