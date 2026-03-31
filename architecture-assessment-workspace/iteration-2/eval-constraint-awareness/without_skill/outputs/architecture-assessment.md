# Architecture Assessment: Payment Service

## Projekt-Kontext

- **Typ:** Spring Boot 3.2 REST-Service (Kotlin)
- **Domäne:** Zahlungsabwicklung (createPayment, refundPayment, getPayment, listPayments)
- **Datenmodell:** PII-Felder (cardNumber, cardHolder, iban), PostgreSQL-Backend
- **Dependencies:** spring-boot-starter-web, spring-boot-starter-data-jpa, spring-boot-starter-security, postgresql
- **Aktive Constraints:** SEC-001 (Encryption at Rest), SEC-002 (API Authentication), COMP-001 (GDPR Data Retention), COMP-002 (Audit Logging)

---

## Top-3 Architektur-Charakteristiken

| # | Charakteristik | Priorität | Konkretes Ziel | Fitness Function nötig? | Begründung |
|---|---------------|-----------|---------------|------------------------|------------|
| 1 | **Security** | Kritisch | Alle PII-Daten (cardNumber, cardHolder, iban) sind AES-256-verschlüsselt at rest. Alle API-Endpunkte (ausser /health) erfordern JWT-basierte Authentifizierung mit Rate Limiting pro Nutzer. Keine sensiblen Daten im Klartext in Logs. | Ja | Direkt getrieben durch die Mandatory-Constraints SEC-001 und SEC-002. Der Service verarbeitet Zahlungsdaten mit drei PII-Feldern im Request-Modell. Ohne automatisierte Pruefung ist die Einhaltung nicht sichergestellt. **Fitness Functions:** (1) ArchUnit-Test, der sicherstellt, dass kein PII-Feld ohne @Encrypted-Annotation persistiert wird. (2) Integrationstest, der alle Endpunkte ohne JWT aufruft und 401 erwartet. (3) Log-Scanner, der Regex auf Kartennummern-Muster prueft. |
| 2 | **Compliance / Auditability** | Kritisch | Unveraenderliches Audit-Log fuer alle schreibenden Operationen (POST /api/payments, POST /api/payments/{id}/refund). Automatischer Loeschjob nach 36 Monaten. DELETE-Endpunkt fuer Right to Erasure (GDPR Art. 17). Keine PII im Audit-Log. | Ja | Direkt getrieben durch die Mandatory-Constraints COMP-001 und COMP-002. Zahlungsdaten fallen unter GDPR; fehlende Compliance bedeutet regulatorisches Risiko. **Fitness Functions:** (1) Test, der nach schreibender Operation prueft, ob ein Audit-Eintrag existiert. (2) Test, der Audit-Log-Eintraege auf PII-Muster scannt (darf keine finden). (3) Scheduled Test, der prueft, ob Datensaetze aelter als 36 Monate existieren (darf keine finden). |
| 3 | **Reliability** | Hoch | Payment-Transaktionen sind idempotent (kein doppeltes Abbuchen bei Retry). Verfuegbarkeit >= 99.9% waehrend Geschaeftszeiten. Graceful Degradation bei Ausfall externer Zahlungsanbieter. Konsistente Zustandsuebergaenge (z.B. nur COMPLETED-Payments duerfen refunded werden). | Ja | Ein Payment Service muss zuverlaessig arbeiten, da finanzielle Transaktionen nicht verloren gehen oder doppelt ausgefuehrt werden duerfen. Der aktuelle Code zeigt keine Idempotenz-Mechanismen (kein Idempotency-Key im CreatePaymentRequest). **Fitness Functions:** (1) Test, der denselben Request zweimal sendet und prueft, dass nur eine Zahlung entsteht. (2) Health-Check-Endpoint mit Liveness/Readiness-Probes fuer Kubernetes. (3) Test, der Refund auf nicht-abgeschlossene Zahlung versucht und Fehler erwartet. |

---

## Zusammenfassung

Die drei Charakteristiken sind primaer durch die vier aktiven Mandatory-Constraints (SEC-001, SEC-002, COMP-001, COMP-002) sowie die inhärenten Anforderungen der Zahlungsdomaene getrieben. Security und Compliance sind beide als **kritisch** eingestuft, da Verstoesse gegen die Constraints regulatorische und finanzielle Konsequenzen haben. Reliability ist **hoch** priorisiert, da der Service finanzielle Transaktionen verarbeitet und Datenverlust oder Doppelbuchungen nicht akzeptabel sind.

Alle drei Charakteristiken benoetigen Fitness Functions, da sie kontinuierlich und automatisiert ueberprueft werden muessen -- manuelle Pruefung skaliert nicht und ist fehleranfaellig.
