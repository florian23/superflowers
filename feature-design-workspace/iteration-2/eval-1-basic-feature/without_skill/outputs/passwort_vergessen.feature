# language: de

Funktionalitaet: Passwort zuruecksetzen per Email
  Als Benutzer der sein Passwort vergessen hat
  moechte ich mein Passwort per Email zuruecksetzen koennen
  damit ich wieder Zugang zu meinem Konto erhalte

  Grundlage:
    Angenommen es existiert ein Benutzerkonto mit der Email "max@beispiel.de"

  Szenario: Passwort-zuruecksetzen Email anfordern
    Wenn der Benutzer auf "Passwort vergessen" klickt
    Und der Benutzer die Email "max@beispiel.de" eingibt
    Und der Benutzer auf "Zuruecksetzen anfordern" klickt
    Dann wird eine Bestaetigungsmeldung angezeigt "Eine Email zum Zuruecksetzen des Passworts wurde an max@beispiel.de gesendet"
    Und eine Email mit einem Zuruecksetzungslink wird an "max@beispiel.de" gesendet

  Szenario: Passwort-zuruecksetzen mit unbekannter Email
    Wenn der Benutzer auf "Passwort vergessen" klickt
    Und der Benutzer die Email "unbekannt@beispiel.de" eingibt
    Und der Benutzer auf "Zuruecksetzen anfordern" klickt
    Dann wird die gleiche Bestaetigungsmeldung angezeigt "Eine Email zum Zuruecksetzen des Passworts wurde an unbekannt@beispiel.de gesendet"
    Und es wird keine Email versendet

  Szenario: Neues Passwort erfolgreich setzen
    Angenommen der Benutzer hat einen gueltigen Zuruecksetzungslink erhalten
    Wenn der Benutzer den Zuruecksetzungslink aufruft
    Und der Benutzer das neue Passwort "NeuesGeheim456!" eingibt
    Und der Benutzer das neue Passwort "NeuesGeheim456!" bestaetigt
    Und der Benutzer auf "Passwort speichern" klickt
    Dann wird eine Bestaetigungsmeldung angezeigt "Ihr Passwort wurde erfolgreich geaendert"
    Und der Benutzer kann sich mit dem neuen Passwort anmelden

  Szenario: Passwort-Bestaetigungen stimmen nicht ueberein
    Angenommen der Benutzer hat einen gueltigen Zuruecksetzungslink erhalten
    Wenn der Benutzer den Zuruecksetzungslink aufruft
    Und der Benutzer das neue Passwort "NeuesGeheim456!" eingibt
    Und der Benutzer das neue Passwort "AndersGeheim789!" bestaetigt
    Und der Benutzer auf "Passwort speichern" klickt
    Dann wird eine Fehlermeldung angezeigt "Die Passwoerter stimmen nicht ueberein"

  Szenario: Abgelaufener Zuruecksetzungslink
    Angenommen der Benutzer hat einen Zuruecksetzungslink erhalten der aelter als 24 Stunden ist
    Wenn der Benutzer den Zuruecksetzungslink aufruft
    Dann wird eine Fehlermeldung angezeigt "Dieser Link ist abgelaufen. Bitte fordern Sie einen neuen Link an."
    Und es wird ein Link zur Passwort-vergessen Seite angezeigt

  Szenario: Gesperrtes Konto wird nach Passwort-Zuruecksetzung entsperrt
    Angenommen das Konto fuer "max@beispiel.de" ist gesperrt
    Und der Benutzer hat einen gueltigen Zuruecksetzungslink erhalten
    Wenn der Benutzer den Zuruecksetzungslink aufruft
    Und der Benutzer das neue Passwort "NeuesGeheim456!" eingibt
    Und der Benutzer das neue Passwort "NeuesGeheim456!" bestaetigt
    Und der Benutzer auf "Passwort speichern" klickt
    Dann wird das Konto fuer "max@beispiel.de" entsperrt
    Und der Fehlversuchszaehler wird zurueckgesetzt
    Und der Benutzer kann sich mit dem neuen Passwort anmelden
