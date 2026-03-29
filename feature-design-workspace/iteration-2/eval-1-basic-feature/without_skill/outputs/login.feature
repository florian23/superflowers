# language: de

Funktionalitaet: Benutzer-Anmeldung mit Email und Passwort
  Als registrierter Benutzer
  moechte ich mich mit meiner Email-Adresse und meinem Passwort anmelden
  damit ich auf mein Benutzerkonto zugreifen kann

  Grundlage:
    Angenommen es existiert ein Benutzerkonto mit folgenden Daten:
      | Email              | Passwort     |
      | max@beispiel.de    | Geheim123!   |

  Szenario: Erfolgreiche Anmeldung mit gueltigen Zugangsdaten
    Wenn der Benutzer die Email "max@beispiel.de" eingibt
    Und der Benutzer das Passwort "Geheim123!" eingibt
    Und der Benutzer auf "Anmelden" klickt
    Dann wird der Benutzer erfolgreich angemeldet
    Und der Benutzer wird zur Startseite weitergeleitet

  Szenario: Fehlgeschlagene Anmeldung mit falschem Passwort
    Wenn der Benutzer die Email "max@beispiel.de" eingibt
    Und der Benutzer das Passwort "FalschesPasswort" eingibt
    Und der Benutzer auf "Anmelden" klickt
    Dann wird eine Fehlermeldung angezeigt "Email oder Passwort ist ungueltig"
    Und der Benutzer bleibt auf der Anmeldeseite

  Szenario: Fehlgeschlagene Anmeldung mit unbekannter Email
    Wenn der Benutzer die Email "unbekannt@beispiel.de" eingibt
    Und der Benutzer das Passwort "Geheim123!" eingibt
    Und der Benutzer auf "Anmelden" klickt
    Dann wird eine Fehlermeldung angezeigt "Email oder Passwort ist ungueltig"

  Szenario: Anmeldung mit leerer Email
    Wenn der Benutzer die Email "" eingibt
    Und der Benutzer das Passwort "Geheim123!" eingibt
    Und der Benutzer auf "Anmelden" klickt
    Dann wird eine Fehlermeldung angezeigt "Bitte geben Sie Ihre Email-Adresse ein"

  Szenario: Anmeldung mit leerem Passwort
    Wenn der Benutzer die Email "max@beispiel.de" eingibt
    Und der Benutzer das Passwort "" eingibt
    Und der Benutzer auf "Anmelden" klickt
    Dann wird eine Fehlermeldung angezeigt "Bitte geben Sie Ihr Passwort ein"

  Szenario: Anmeldung mit ungueltiger Email-Adresse
    Wenn der Benutzer die Email "keine-gueltige-email" eingibt
    Und der Benutzer das Passwort "Geheim123!" eingibt
    Und der Benutzer auf "Anmelden" klickt
    Dann wird eine Fehlermeldung angezeigt "Bitte geben Sie eine gueltige Email-Adresse ein"
