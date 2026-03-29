# language: de

Funktionalitaet: Kontosperrung nach fehlgeschlagenen Anmeldeversuchen
  Als Systembetreiber
  moechte ich dass Benutzerkonten nach 3 fehlgeschlagenen Anmeldeversuchen gesperrt werden
  damit Brute-Force-Angriffe verhindert werden

  Grundlage:
    Angenommen es existiert ein aktives Benutzerkonto mit folgenden Daten:
      | Email              | Passwort     |
      | max@beispiel.de    | Geheim123!   |
    Und der Fehlversuchszaehler fuer "max@beispiel.de" steht auf 0

  Szenario: Erster fehlgeschlagener Anmeldeversuch
    Wenn der Benutzer sich mit "max@beispiel.de" und dem falschen Passwort "Falsch1" anmeldet
    Dann wird eine Fehlermeldung angezeigt "Email oder Passwort ist ungueltig"
    Und der Fehlversuchszaehler fuer "max@beispiel.de" steht auf 1
    Und das Konto ist nicht gesperrt

  Szenario: Zweiter fehlgeschlagener Anmeldeversuch
    Angenommen der Fehlversuchszaehler fuer "max@beispiel.de" steht auf 1
    Wenn der Benutzer sich mit "max@beispiel.de" und dem falschen Passwort "Falsch2" anmeldet
    Dann wird eine Fehlermeldung angezeigt "Email oder Passwort ist ungueltig. Sie haben noch 1 Versuch bevor Ihr Konto gesperrt wird."
    Und der Fehlversuchszaehler fuer "max@beispiel.de" steht auf 2
    Und das Konto ist nicht gesperrt

  Szenario: Kontosperrung nach dem dritten Fehlversuch
    Angenommen der Fehlversuchszaehler fuer "max@beispiel.de" steht auf 2
    Wenn der Benutzer sich mit "max@beispiel.de" und dem falschen Passwort "Falsch3" anmeldet
    Dann wird eine Fehlermeldung angezeigt "Ihr Konto wurde aufgrund von 3 fehlgeschlagenen Anmeldeversuchen gesperrt. Bitte nutzen Sie die Passwort-vergessen Funktion."
    Und das Konto fuer "max@beispiel.de" ist gesperrt

  Szenario: Anmeldung mit gesperrtem Konto und korrektem Passwort
    Angenommen das Konto fuer "max@beispiel.de" ist gesperrt
    Wenn der Benutzer sich mit "max@beispiel.de" und dem korrekten Passwort "Geheim123!" anmeldet
    Dann wird eine Fehlermeldung angezeigt "Ihr Konto ist gesperrt. Bitte nutzen Sie die Passwort-vergessen Funktion um Ihr Konto zu entsperren."
    Und der Benutzer wird nicht angemeldet

  Szenario: Fehlversuchszaehler wird nach erfolgreicher Anmeldung zurueckgesetzt
    Angenommen der Fehlversuchszaehler fuer "max@beispiel.de" steht auf 1
    Wenn der Benutzer sich mit "max@beispiel.de" und dem korrekten Passwort "Geheim123!" anmeldet
    Dann wird der Benutzer erfolgreich angemeldet
    Und der Fehlversuchszaehler fuer "max@beispiel.de" steht auf 0
