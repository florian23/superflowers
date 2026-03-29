# language: de
Funktionalitaet: Schnellfilter - Randfaelle und besondere Eingaben
  Als Benutzer erwarte ich, dass der Schnellfilter auch bei ungewoehnlichen Eingaben
  zuverlaessig und vorhersehbar funktioniert.

  Grundlage:
    Angenommen der Graph enthaelt folgende Knoten:
      | Label              |
      | HTTP-Gateway       |
      | Message Queue      |
      | Log (Fehler)       |
      | Node_1             |
      | Node_2             |

  # --- Sonderzeichen ---

  Szenario: Filter mit Bindestrich findet passende Knoten
    Wenn ich "HTTP-" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "HTTP-Gateway" normal dargestellt
    Und die uebrigen Knoten werden ausgegraut

  Szenario: Filter mit Leerzeichen findet passende Knoten
    Wenn ich "ge Qu" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Message Queue" normal dargestellt

  Szenario: Filter mit Klammern findet passende Knoten
    Wenn ich "(Fehler)" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Log (Fehler)" normal dargestellt

  Szenario: Filter mit Unterstrich findet passende Knoten
    Wenn ich "Node_" in das Schnellfilter-Textfeld eingebe
    Dann werden die Knoten "Node_1" und "Node_2" normal dargestellt

  # --- Leerraum ---

  Szenario: Nur Leerzeichen im Filter werden wie ein leerer Filter behandelt
    Wenn ich "   " in das Schnellfilter-Textfeld eingebe
    Dann werden alle Knoten normal dargestellt

  # --- Leerer Graph ---

  Szenario: Filter auf einem leeren Graphen zeigt keine Fehler
    Angenommen der Graph enthaelt keine Knoten
    Wenn ich "test" in das Schnellfilter-Textfeld eingebe
    Dann wird kein Knoten dargestellt
    Und es wird keine Fehlermeldung angezeigt

  # --- Exakte vollstaendige Uebereinstimmung ---

  Szenario: Vollstaendiges Label als Filtertext hebt genau diesen Knoten hervor
    Wenn ich "Message Queue" in das Schnellfilter-Textfeld eingebe
    Dann wird der Knoten "Message Queue" normal dargestellt
    Und die uebrigen Knoten werden ausgegraut
