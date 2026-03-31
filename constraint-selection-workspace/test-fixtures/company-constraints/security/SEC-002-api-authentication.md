---
id: SEC-002
name: API Authentication
category: security
severity: mandatory
applies_to:
  - api
  - webservice
  - rest
  - grpc
---

## Anforderung

Alle externen API-Endpunkte müssen authentifiziert sein. OAuth 2.0 mit JWT ist der Standard. Kein API-Endpunkt darf ohne Authentifizierung erreichbar sein (Ausnahme: Health-Checks).

## Begründung

Unternehmensrichtlinie IT-SEC-2024-07. Verhindert unautorisierte Zugriffe auf Geschäftsdaten.

## Implikationen für die Entwicklung

- JWT-Validierung in jedem Service
- Token-Refresh-Mechanismus implementieren
- Rate Limiting pro Nutzer
- Health-Check-Endpunkte explizit von Auth ausnehmen

## Prüfkriterien

- [ ] Alle API-Endpunkte (außer /health) erfordern gültiges JWT
- [ ] Ungültige Tokens werden mit 401 abgelehnt
- [ ] Abgelaufene Tokens werden korrekt behandelt
- [ ] Rate Limiting ist pro Nutzer konfiguriert
