# Quality Scenarios: Payment Service

## Projekt-Kontext
- **Service:** Spring Boot 3.2 Payment Service (Kotlin)
- **Endpunkte:** POST /api/payments, GET /api/payments/{id}, GET /api/payments, POST /api/payments/{id}/refund
- **PII-Felder:** cardNumber, cardHolder, iban
- **Quelle:** Architecture Assessment (Iteration 2), Feature-Constraints 2026-03-31

---

## 1. Security

### QS-SEC-01: Unauthentifizierter Zugriff wird abgelehnt
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Externer Client ohne JWT-Token |
| **Stimulus** | HTTP-Request an POST /api/payments |
| **Umgebung** | Normalbetrieb |
| **Artefakt** | PaymentController, Security-Filter-Chain |
| **Antwort** | HTTP 401 Unauthorized, kein Zugriff auf Business-Logik |
| **Messung** | Alle 4 Business-Endpunkte liefern 401 ohne gueltigem JWT. GET /health liefert 200 ohne JWT. |
| **Constraint** | SEC-002 |
| **Test-Typ** | integration-test |

### QS-SEC-02: PII-Felder sind in der Datenbank verschluesselt
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Entwickler oder Auditor |
| **Stimulus** | Direkter SELECT auf die Payment-Tabelle in PostgreSQL |
| **Umgebung** | Normalbetrieb, Datenbank mit mindestens einem Payment-Datensatz |
| **Artefakt** | PostgreSQL Payment-Tabelle, Spalten card_number, card_holder, iban |
| **Antwort** | Spaltenwerte sind nicht als Klartext lesbar (AES-256-verschluesselt oder TDE aktiv) |
| **Messung** | SELECT card_number FROM payments liefert keinen Wert, der einem Kartennummern-Muster (z.B. 16 Ziffern) entspricht. Regex-Pruefung: kein Match auf `^\d{13,19}$`. |
| **Constraint** | SEC-001 |
| **Test-Typ** | integration-test |

### QS-SEC-03: Keine PII im Klartext in Applikations-Logs
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Automatisierter Log-Scanner |
| **Stimulus** | Ausfuehrung von POST /api/payments mit Testdaten (cardNumber=4111111111111111, cardHolder=Max Mustermann, iban=DE89370400440532013000) |
| **Umgebung** | Normalbetrieb |
| **Artefakt** | Applikations-Log-Dateien (stdout, logback) |
| **Antwort** | Kein Log-Eintrag enthaelt Klartext-PII |
| **Messung** | Regex-Scan der Logs: kein Match auf Kartennummern (`\b\d{13,19}\b`), IBAN (`\b[A-Z]{2}\d{2}[A-Z0-9]{11,30}\b`) oder den konkreten cardHolder-Wert. 0 Treffer erwartet. |
| **Constraint** | SEC-001 |
| **Test-Typ** | integration-test |

### QS-SEC-04: Encryption Keys liegen im KMS, nicht im Code
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Security-Auditor |
| **Stimulus** | Durchsicht des Source-Codes und der Konfigurationsdateien (application.yml, application.properties) |
| **Umgebung** | CI/CD-Pipeline oder manuelles Review |
| **Artefakt** | Gesamtes Repository |
| **Antwort** | Kein Encryption Key ist hardcoded. Key-Referenzen verweisen auf einen externen KMS (z.B. AWS KMS ARN, Vault-Pfad). |
| **Messung** | Kein Treffer bei Suche nach Base64-encodierten Schluesseln (>= 32 Byte) oder Klartext-Passwoertern in Konfigurationsdateien. |
| **Constraint** | SEC-001 |
| **Test-Typ** | fitness-function |

### QS-SEC-05: Rate Limiting pro Nutzer
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Authentifizierter Client |
| **Stimulus** | 100 Requests innerhalb von 10 Sekunden an POST /api/payments |
| **Umgebung** | Normalbetrieb |
| **Artefakt** | API-Gateway oder Spring Security Filter |
| **Antwort** | Ab Ueberschreitung des Rate Limits: HTTP 429 Too Many Requests |
| **Messung** | Bei 100 Requests in 10s werden mindestens die letzten N Requests mit 429 beantwortet. Exakter Schwellwert abhaengig von Konfiguration. |
| **Constraint** | SEC-002 |
| **Test-Typ** | load-test |

---

## 2. Compliance / Auditability

### QS-COMP-01: Audit-Log-Eintrag bei Payment-Erstellung
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Authentifizierter Client |
| **Stimulus** | POST /api/payments mit gueltigem Request |
| **Umgebung** | Normalbetrieb |
| **Artefakt** | Audit-Log (Datenbank-Tabelle oder dedizierter Log-Store) |
| **Antwort** | Ein neuer Audit-Eintrag wird geschrieben mit: Zeitstempel, User-ID, Operation=CREATE, Ressource-ID |
| **Messung** | Anzahl Audit-Eintraege fuer die erzeugte Payment-ID = 1. Zeitstempel liegt innerhalb von 1 Sekunde nach dem Request. |
| **Constraint** | COMP-002 |
| **Test-Typ** | integration-test |

### QS-COMP-02: Audit-Log-Eintrag bei Refund
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Authentifizierter Client |
| **Stimulus** | POST /api/payments/{id}/refund |
| **Umgebung** | Normalbetrieb, Payment mit Status COMPLETED existiert |
| **Artefakt** | Audit-Log |
| **Antwort** | Audit-Eintrag mit Operation=REFUND und zugehoeriger Payment-ID |
| **Messung** | Audit-Log enthaelt genau einen REFUND-Eintrag fuer die betroffene Payment-ID. |
| **Constraint** | COMP-002 |
| **Test-Typ** | integration-test |

### QS-COMP-03: Keine PII im Audit-Log
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Automatisierter Scanner |
| **Stimulus** | Ausfuehrung mehrerer createPayment- und refundPayment-Operationen mit bekannten PII-Testdaten |
| **Umgebung** | Normalbetrieb |
| **Artefakt** | Audit-Log-Eintraege |
| **Antwort** | Kein Audit-Eintrag enthaelt cardNumber, cardHolder oder iban im Klartext |
| **Messung** | Regex-Scan aller Audit-Eintraege: 0 Treffer auf Kartennummern, IBAN oder die konkreten Testdaten-Werte. |
| **Constraint** | COMP-002 |
| **Test-Typ** | integration-test |

### QS-COMP-04: Unveraenderlichkeit des Audit-Logs
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Angreifer oder fehlerhafter Code |
| **Stimulus** | Versuch, einen bestehenden Audit-Eintrag zu aendern oder zu loeschen (UPDATE/DELETE auf Audit-Tabelle) |
| **Umgebung** | Normalbetrieb |
| **Artefakt** | Audit-Log-Speicher |
| **Antwort** | Operation wird abgelehnt (z.B. durch fehlende Schreibrechte, Append-Only-Tabelle oder Write-Once-Storage) |
| **Messung** | UPDATE- und DELETE-Statements auf die Audit-Tabelle fuehren zu einem Fehler. Anzahl der Eintraege bleibt unveraendert. |
| **Constraint** | COMP-002 |
| **Test-Typ** | integration-test |

### QS-COMP-05: Automatische Datenloesung nach 36 Monaten
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Scheduled Job (Cron) |
| **Stimulus** | Loeschjob wird ausgefuehrt |
| **Umgebung** | Datenbank enthaelt Payment-Datensaetze mit Erstellungsdatum > 36 Monate |
| **Artefakt** | Payment-Tabelle in PostgreSQL |
| **Antwort** | Alle Datensaetze aelter als 36 Monate werden geloescht oder anonymisiert |
| **Messung** | Nach Ausfuehrung des Jobs: SELECT COUNT(*) FROM payments WHERE created_at < NOW() - INTERVAL '36 months' = 0 |
| **Constraint** | COMP-001 |
| **Test-Typ** | integration-test |

### QS-COMP-06: Right to Erasure (GDPR Art. 17)
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Betroffene Person (via authentifizierten Client) |
| **Stimulus** | DELETE /api/payments/user/{userId} (oder aequivalenter Endpunkt) |
| **Umgebung** | Normalbetrieb, Nutzer hat bestehende Payment-Datensaetze |
| **Artefakt** | Payment-Tabelle, zugehoerige PII-Daten |
| **Antwort** | HTTP 200/204. Alle PII-Daten des Nutzers sind geloescht oder anonymisiert. |
| **Messung** | Nach dem Request: SELECT card_number, card_holder, iban FROM payments WHERE user_id = {userId} liefert NULL oder anonymisierte Werte fuer alle Zeilen. |
| **Constraint** | COMP-001 |
| **Test-Typ** | integration-test |

---

## 3. Reliability

### QS-REL-01: Idempotenz bei Payment-Erstellung
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Client mit Retry-Logik |
| **Stimulus** | Zweimaliges Senden desselben POST /api/payments mit identischem Idempotency-Key |
| **Umgebung** | Normalbetrieb |
| **Artefakt** | PaymentService, Payment-Tabelle |
| **Antwort** | Nur eine Zahlung wird erzeugt. Der zweite Request liefert dieselbe PaymentResponse wie der erste. |
| **Messung** | SELECT COUNT(*) FROM payments WHERE idempotency_key = '{key}' = 1 nach beiden Requests. Beide Responses haben dieselbe id. |
| **Constraint** | -- (Domaenen-Anforderung) |
| **Test-Typ** | integration-test |

### QS-REL-02: Nur abgeschlossene Payments duerfen refunded werden
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Authentifizierter Client |
| **Stimulus** | POST /api/payments/{id}/refund auf eine Zahlung mit Status PENDING |
| **Umgebung** | Normalbetrieb |
| **Artefakt** | PaymentService, Zustandsmaschine |
| **Antwort** | HTTP 409 Conflict oder HTTP 422 Unprocessable Entity. Status bleibt PENDING. |
| **Messung** | Response-Status-Code ist 409 oder 422. Payment-Status in der Datenbank ist unveraendert. |
| **Constraint** | -- (Domaenen-Anforderung) |
| **Test-Typ** | unit-test |

### QS-REL-03: Verfuegbarkeit >= 99.9% waehrend Geschaeftszeiten
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Monitoring-System |
| **Stimulus** | Kontinuierliche Health-Checks alle 10 Sekunden waehrend Geschaeftszeiten (Mo-Fr 08:00-20:00) |
| **Umgebung** | Produktionsbetrieb |
| **Artefakt** | GET /health Endpunkt |
| **Antwort** | HTTP 200 mit Status UP |
| **Messung** | Erfolgsrate der Health-Checks pro Monat >= 99.9% (max. 43 Minuten Downtime pro Monat). |
| **Constraint** | -- (Domaenen-Anforderung) |
| **Test-Typ** | fitness-function |

### QS-REL-04: Graceful Degradation bei Ausfall des Zahlungsanbieters
| Dimension | Beschreibung |
|-----------|-------------|
| **Stimulus-Quelle** | Client |
| **Stimulus** | POST /api/payments waehrend externer Zahlungsanbieter nicht erreichbar ist |
| **Umgebung** | Degradierter Betrieb (externe Abhaengigkeit ausgefallen) |
| **Artefakt** | PaymentService, Circuit Breaker |
| **Antwort** | HTTP 503 Service Unavailable mit aussagekraeftiger Fehlermeldung. Kein Datenverlust, kein Haengen. Antwortzeit < 5 Sekunden. |
| **Messung** | Response-Status = 503. Antwortzeit < 5s. Kein Payment mit Status COMPLETED in der Datenbank. |
| **Constraint** | -- (Domaenen-Anforderung) |
| **Test-Typ** | integration-test |

---

## Szenario-Uebersicht nach Test-Typ

| Test-Typ | Szenarien | Anzahl |
|----------|-----------|--------|
| **unit-test** | QS-REL-02 | 1 |
| **integration-test** | QS-SEC-01, QS-SEC-02, QS-SEC-03, QS-COMP-01, QS-COMP-02, QS-COMP-03, QS-COMP-04, QS-COMP-05, QS-COMP-06, QS-REL-01, QS-REL-04 | 11 |
| **load-test** | QS-SEC-05 | 1 |
| **fitness-function** | QS-SEC-04, QS-REL-03 | 2 |
| **manual-review** | -- | 0 |

## Szenario-Uebersicht nach Constraint

| Constraint | Szenarien |
|-----------|-----------|
| **SEC-001** | QS-SEC-02, QS-SEC-03, QS-SEC-04 |
| **SEC-002** | QS-SEC-01, QS-SEC-05 |
| **COMP-001** | QS-COMP-05, QS-COMP-06 |
| **COMP-002** | QS-COMP-01, QS-COMP-02, QS-COMP-03, QS-COMP-04 |
| **Domaene** | QS-REL-01, QS-REL-02, QS-REL-03, QS-REL-04 |
