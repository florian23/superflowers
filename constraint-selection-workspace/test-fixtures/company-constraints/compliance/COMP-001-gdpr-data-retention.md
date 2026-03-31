---
id: COMP-001
name: GDPR Data Retention
category: compliance
severity: mandatory
applies_to:
  - personal-data
  - user-data
  - data-storage
---

## Anforderung

Personenbezogene Daten dürfen nur so lange gespeichert werden wie für den Verarbeitungszweck erforderlich. Maximale Aufbewahrungsfrist: 36 Monate nach letzter Aktivität. Nutzer müssen ihre Daten löschen lassen können (Right to Erasure).

## Begründung

DSGVO Art. 5(1)(e) — Speicherbegrenzung. Art. 17 — Recht auf Löschung.

## Implikationen für die Entwicklung

- Automatische Löschung nach 36 Monaten Inaktivität
- API-Endpunkt für Datenlöschung (Right to Erasure)
- Löschung muss kaskadierend über alle Systeme erfolgen
- Audit-Log der Löschungen (ohne personenbezogene Daten)

## Prüfkriterien

- [ ] Automatischer Lösch-Job für inaktive Daten (>36 Monate)
- [ ] DELETE /api/users/{id}/data Endpunkt implementiert
- [ ] Kaskadierende Löschung über alle Datenbanken/Services
- [ ] Lösch-Audit-Log vorhanden (anonymisiert)
