# Transcript: Erstellung der Feature Files fuer das Benutzer-Login-System

## Aufgabe

Basierend auf den abgenommenen Design-Anforderungen wurden Gherkin Feature Files fuer ein Benutzer-Login-System erstellt. Die drei Kernanforderungen waren:

1. Benutzer koennen sich mit Email und Passwort anmelden
2. Nach 3 Fehlversuchen wird das Konto gesperrt
3. Passwort-vergessen Funktion per Email

## Erstellte Dateien

### 1. login.feature

Deckt die grundlegende Anmeldung ab mit folgenden Szenarien:
- Erfolgreiche Anmeldung mit gueltigen Zugangsdaten
- Fehlgeschlagene Anmeldung mit falschem Passwort
- Fehlgeschlagene Anmeldung mit unbekannter Email
- Validierung: leere Email, leeres Passwort, ungueltiges Email-Format

### 2. kontosperrung.feature

Deckt die Kontosperrung nach Fehlversuchen ab mit folgenden Szenarien:
- Erster und zweiter fehlgeschlagener Anmeldeversuch (Zaehler wird hochgezaehlt)
- Kontosperrung nach dem dritten Fehlversuch
- Anmeldeversuch mit gesperrtem Konto (auch mit korrektem Passwort)
- Zuruecksetzen des Fehlversuchszaehlers nach erfolgreicher Anmeldung

### 3. passwort_vergessen.feature

Deckt die Passwort-vergessen Funktion ab mit folgenden Szenarien:
- Anfordern einer Zuruecksetzungs-Email
- Verhalten bei unbekannter Email (gleiche Meldung aus Sicherheitsgruenden)
- Erfolgreiches Setzen eines neuen Passworts
- Fehler bei nicht uebereinstimmenden Passwort-Bestaetigungen
- Abgelaufener Zuruecksetzungslink
- Entsperrung eines gesperrten Kontos nach Passwort-Zuruecksetzung

## Anmerkungen

- Alle Feature Files sind in deutscher Sprache verfasst (Gherkin `# language: de`)
- Die Fehlermeldung bei falschem Passwort und unbekannter Email ist absichtlich identisch, um keine Rueckschluesse auf existierende Konten zu ermoeglichen (Security Best Practice)
- Die Passwort-vergessen Funktion zeigt auch bei unbekannten Email-Adressen die gleiche Bestaetigungsmeldung (verhindert Email-Enumeration)
- Das letzte Szenario in passwort_vergessen.feature verbindet die Kontosperrung mit der Passwort-Zuruecksetzung und stellt sicher, dass gesperrte Konten ueber diesen Weg entsperrt werden koennen
