# Constraints: Payment API

## Datum: 2026-03-31
## Feature: REST API für Zahlungsabwicklung

## Aktive Constraints

### SEC-001: Encryption at Rest (Security, Mandatory)
**Anforderung:** Alle persistierten Daten müssen AES-256-verschlüsselt sein.
**Relevanz:** PostgreSQL mit Zahlungsdaten
**Prüfkriterien:**
- [ ] Datenbank nutzt TDE
- [ ] Keine sensiblen Daten im Klartext in Logs
- [ ] Encryption Keys im KMS

### SEC-002: API Authentication (Security, Mandatory)
**Anforderung:** OAuth 2.0 / JWT für alle Endpunkte.
**Relevanz:** 5 REST-Endpunkte
**Prüfkriterien:**
- [ ] Alle Endpunkte (außer /health) erfordern JWT
- [ ] Rate Limiting pro Nutzer

### COMP-001: GDPR Data Retention (Compliance, Mandatory)
**Anforderung:** Max. 36 Monate Speicherung, Right to Erasure.
**Relevanz:** PII (cardNumber, cardHolder, iban)
**Prüfkriterien:**
- [ ] Automatischer Lösch-Job
- [ ] DELETE Endpunkt für Datenlöschung

### COMP-002: Audit Logging (Compliance, Mandatory)
**Anforderung:** Unveränderliches Audit-Log für schreibende Operationen.
**Relevanz:** createPayment, refundPayment
**Prüfkriterien:**
- [ ] Alle POST/PUT/DELETE geloggt
- [ ] Keine PII im Audit-Log

## Ausgeschlossene Constraints
- SEC-003: Network Segmentation — Plattform-Team
