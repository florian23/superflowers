# Verifikations-Checkliste: Payment Service

## Projekt
- **Basispfad:** `/home/flo/superflowers/project-constraints-workspace/test-fixtures/spring-boot-project/`
- **Aktive Constraints:** SEC-001, SEC-002, COMP-001, COMP-002
- **Quellen:** Architecture Assessment, Quality Scenarios, 8 Feature Files, Implementation Plan (27 Tasks, 5 Phasen)

---

## IST-Zustand (Befund vor Verifikation)

Das Projekt enthaelt aktuell nur 2 Quelldateien:
- `src/main/kotlin/com/example/payment/PaymentController.kt` (Controller + DTOs, keine Service-Schicht)
- `src/main/resources/application.yml` (nur Datasource, kein JWT, kein Resilience4j)

Der Implementierungsplan definiert 27 Tasks in 5 Phasen. Die Verifikation prueft systematisch, ob jede Phase vollstaendig umgesetzt wurde.

---

## V1: Projektstruktur und Kompilierung

### V1.1: Alle geplanten Dateien existieren

**Command:**
```bash
PROJECT=/home/flo/superflowers/project-constraints-workspace/test-fixtures/spring-boot-project

# Phase 1: Grundlagen
ls -la $PROJECT/src/main/kotlin/com/example/payment/Payment.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/PaymentRepository.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/PaymentService.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/PaymentApplication.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/Exceptions.kt

# Phase 2: Security
ls -la $PROJECT/src/main/kotlin/com/example/payment/SecurityConfig.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/HealthController.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/RateLimitFilter.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/EncryptionConverter.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/PiiMaskingLayout.kt
ls -la $PROJECT/src/main/resources/logback-spring.xml

# Phase 3: Compliance
ls -la $PROJECT/src/main/kotlin/com/example/payment/AuditLog.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/AuditLogRepository.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/AuditAspect.kt
ls -la $PROJECT/src/main/kotlin/com/example/payment/DataRetentionJob.kt
ls -la $PROJECT/src/main/resources/db/migration/V1__create_tables.sql

# Phase 4: Reliability
ls -la $PROJECT/src/main/kotlin/com/example/payment/PaymentProviderClient.kt

# Phase 5: Tests
ls -la $PROJECT/src/test/kotlin/com/example/payment/
```

**Erwartetes Ergebnis:** Alle Dateien existieren. Kein "No such file or directory".

- [ ] Alle 17 Kotlin-Dateien vorhanden
- [ ] logback-spring.xml vorhanden
- [ ] SQL-Migration vorhanden
- [ ] Test-Verzeichnis mit Tests vorhanden

---

### V1.2: Projekt kompiliert fehlerfrei

**Command:**
```bash
cd $PROJECT && ./mvnw compile -q
echo "Exit code: $?"
```

**Erwartetes Ergebnis:** Exit code 0, keine Compile-Fehler.

- [ ] `./mvnw compile` erfolgreich (Exit code 0)

---

### V1.3: Alle Tests bestehen

**Command:**
```bash
cd $PROJECT && ./mvnw test
echo "Exit code: $?"
```

**Erwartetes Ergebnis:** Exit code 0, alle Tests gruen.

- [ ] `./mvnw test` erfolgreich (Exit code 0)
- [ ] Mindestens 20 Tests ausgefuehrt (Phase 5 definiert Tasks 20-27)

---

## V2: Dependencies (Task 1)

### V2.1: Alle benoetigten Dependencies in pom.xml

**Command:**
```bash
cd $PROJECT && grep -c "spring-boot-starter-test" pom.xml
grep -c "spring-boot-starter-validation" pom.xml
grep -c "spring-boot-starter-oauth2-resource-server" pom.xml
grep -c "spring-boot-starter-aop" pom.xml
grep -c "spring-boot-starter-actuator" pom.xml
grep -c "resilience4j-spring-boot3" pom.xml
grep -c "h2" pom.xml
grep -c "kotlin-stdlib" pom.xml
grep -c "kotlin-reflect" pom.xml
grep -c "jackson-module-kotlin" pom.xml
```

**Erwartetes Ergebnis:** Jede Zeile gibt mindestens `1` aus.

- [ ] spring-boot-starter-test vorhanden
- [ ] spring-boot-starter-validation vorhanden
- [ ] spring-boot-starter-oauth2-resource-server vorhanden
- [ ] spring-boot-starter-aop vorhanden
- [ ] spring-boot-starter-actuator vorhanden
- [ ] resilience4j-spring-boot3 vorhanden
- [ ] h2 (Test-Scope) vorhanden
- [ ] Kotlin-Dependencies (stdlib, reflect, jackson-module) vorhanden

### V2.2: Kotlin-Maven-Plugin konfiguriert

**Command:**
```bash
cd $PROJECT && grep -c "kotlin-maven-plugin" pom.xml
grep -c "allopen" pom.xml
grep -c "noarg" pom.xml
```

**Erwartetes Ergebnis:** Jeweils mindestens `1`.

- [ ] kotlin-maven-plugin konfiguriert
- [ ] allopen Plugin (Spring) konfiguriert
- [ ] noarg Plugin (JPA) konfiguriert

---

## V3: Constraint SEC-001 -- Encryption at Rest

### V3.1: PII-Felder mit @Convert annotiert

**Command:**
```bash
cd $PROJECT && grep -n "Convert.*EncryptionConverter" src/main/kotlin/com/example/payment/Payment.kt
```

**Erwartetes Ergebnis:** 3 Treffer -- cardNumber, cardHolder, iban.

- [ ] cardNumber hat @Convert(converter = EncryptionConverter::class)
- [ ] cardHolder hat @Convert(converter = EncryptionConverter::class)
- [ ] iban hat @Convert(converter = EncryptionConverter::class)

### V3.2: EncryptionConverter nutzt AES-256-GCM

**Command:**
```bash
cd $PROJECT && grep -n "AES/GCM" src/main/kotlin/com/example/payment/EncryptionConverter.kt
grep -n "GCMParameterSpec" src/main/kotlin/com/example/payment/EncryptionConverter.kt
```

**Erwartetes Ergebnis:** Mindestens 2 Treffer (Encrypt + Decrypt).

- [ ] AES/GCM/NoPadding wird verwendet
- [ ] GCM mit 128-Bit Auth-Tag

### V3.3: Encryption Key kommt aus KMS, nicht hardcoded

**Command:**
```bash
cd $PROJECT && grep -rn "KMS\|key-reference\|keyReference" src/main/kotlin/ src/main/resources/
# Negativtest: Kein hardcoded Key
grep -rn "SecretKeySpec.*\"[A-Za-z0-9+/=]\{32,\}\"" src/main/kotlin/ || echo "OK: Kein hardcoded Key gefunden"
```

**Erwartetes Ergebnis:** KMS-Referenz vorhanden, kein hardcoded Key.

- [ ] `encryption.key-reference` in application.yml konfiguriert
- [ ] Key wird aus KMS oder Umgebungsvariable geladen
- [ ] Kein hardcoded Encryption Key im Quellcode

### V3.4: PII-Log-Maskierung aktiv

**Command:**
```bash
cd $PROJECT && cat src/main/resources/logback-spring.xml
grep -n "PiiMaskingLayout" src/main/resources/logback-spring.xml
grep -n "\\\\b\\\\d{13,19}\\\\b\|MASKED" src/main/kotlin/com/example/payment/PiiMaskingLayout.kt
```

**Erwartetes Ergebnis:** PiiMaskingLayout als Layout konfiguriert, Regex fuer Kartennummern und IBAN vorhanden.

- [ ] logback-spring.xml nutzt PiiMaskingLayout
- [ ] Regex fuer Kartennummern (\d{13,19}) vorhanden
- [ ] Regex fuer IBAN ([A-Z]{2}\d{2}...) vorhanden

---

## V4: Constraint SEC-002 -- API Authentication

### V4.1: Security-Config mit JWT und Endpunkt-Absicherung

**Command:**
```bash
cd $PROJECT && grep -n "oauth2ResourceServer\|jwt\|permitAll\|authenticated" src/main/kotlin/com/example/payment/SecurityConfig.kt
```

**Erwartetes Ergebnis:** Zeilen mit: /health permitAll, anyRequest authenticated, oauth2ResourceServer jwt.

- [ ] SecurityConfig existiert
- [ ] /health ist permitAll
- [ ] Alle anderen Endpunkte erfordern Authentifizierung
- [ ] OAuth2 Resource Server mit JWT konfiguriert
- [ ] CSRF deaktiviert (Stateless API)
- [ ] Session-Management STATELESS

### V4.2: JWT-Issuer konfiguriert

**Command:**
```bash
cd $PROJECT && grep -n "issuer-uri\|JWT_ISSUER" src/main/resources/application.yml
```

**Erwartetes Ergebnis:** `issuer-uri: ${JWT_ISSUER_URI}` vorhanden.

- [ ] JWT issuer-uri ueber Umgebungsvariable konfiguriert

### V4.3: Rate Limiting implementiert

**Command:**
```bash
cd $PROJECT && grep -n "429\|maxRequests\|RateLimitFilter\|Retry-After" src/main/kotlin/com/example/payment/RateLimitFilter.kt
```

**Erwartetes Ergebnis:** HTTP 429, maxRequests-Schwellwert, Retry-After-Header.

- [ ] RateLimitFilter existiert
- [ ] Gibt HTTP 429 bei Ueberschreitung zurueck
- [ ] Setzt Retry-After-Header
- [ ] Rate Limiting ist pro Nutzer (Principal-basiert)
- [ ] Nutzt ConcurrentHashMap fuer Thread-Safety

---

## V5: Constraint COMP-001 -- GDPR Data Retention

### V5.1: Data Retention Scheduled Job

**Command:**
```bash
cd $PROJECT && grep -n "@Scheduled\|deleteOlderThan\|36" src/main/kotlin/com/example/payment/DataRetentionJob.kt
```

**Erwartetes Ergebnis:** @Scheduled-Annotation, Cutoff 36 Monate, Aufruf von deleteOlderThan.

- [ ] DataRetentionJob existiert
- [ ] @Scheduled mit Cron-Ausdruck
- [ ] Loescht Daten aelter als 36 Monate
- [ ] Nutzt @Transactional

### V5.2: @EnableScheduling in Application-Klasse

**Command:**
```bash
cd $PROJECT && grep -n "EnableScheduling" src/main/kotlin/com/example/payment/PaymentApplication.kt
```

**Erwartetes Ergebnis:** @EnableScheduling vorhanden.

- [ ] @EnableScheduling auf PaymentApplication

### V5.3: Right to Erasure Endpoint

**Command:**
```bash
cd $PROJECT && grep -n "DeleteMapping\|anonymize\|NO_CONTENT\|204" src/main/kotlin/com/example/payment/PaymentController.kt
```

**Erwartetes Ergebnis:** DELETE /user/{userId} mit 204 Status und anonymizeUser-Aufruf.

- [ ] DELETE /api/payments/user/{userId} Endpunkt vorhanden
- [ ] Gibt HTTP 204 (NO_CONTENT) zurueck
- [ ] Ruft anonymizeUser im Service auf

### V5.4: Anonymisierung in Repository

**Command:**
```bash
cd $PROJECT && grep -n "anonymizeByUserId\|SET.*cardNumber.*NULL\|SET.*cardHolder.*NULL\|SET.*iban.*NULL" src/main/kotlin/com/example/payment/PaymentRepository.kt
```

**Erwartetes Ergebnis:** UPDATE-Query setzt PII-Felder auf NULL.

- [ ] anonymizeByUserId setzt cardNumber auf NULL
- [ ] anonymizeByUserId setzt cardHolder auf NULL
- [ ] anonymizeByUserId setzt iban auf NULL

---

## V6: Constraint COMP-002 -- Audit Logging

### V6.1: Audit-Log Entity

**Command:**
```bash
cd $PROJECT && grep -n "class AuditLog\|operation\|resource_id\|user_id\|created_at\|details" src/main/kotlin/com/example/payment/AuditLog.kt
```

**Erwartetes Ergebnis:** Entity mit allen Feldern: operation, resourceId, userId, createdAt, details.

- [ ] AuditLog Entity existiert
- [ ] Felder: operation, resourceId, userId, createdAt, details
- [ ] Keine PII-Felder im Audit-Log-Entity

### V6.2: Audit-Aspect loggt schreibende Operationen

**Command:**
```bash
cd $PROJECT && grep -n "@AfterReturning\|CREATE\|REFUND\|ERASURE" src/main/kotlin/com/example/payment/AuditAspect.kt
```

**Erwartetes Ergebnis:** Drei @AfterReturning-Methoden fuer CREATE, REFUND, ERASURE.

- [ ] Audit bei PaymentService.create() -> Operation "CREATE"
- [ ] Audit bei PaymentService.refund() -> Operation "REFUND"
- [ ] Audit bei PaymentService.anonymizeUser() -> Operation "ERASURE"
- [ ] User-ID wird aus SecurityContext gelesen

### V6.3: Audit-Log Immutability (SQL-Trigger)

**Command:**
```bash
cd $PROJECT && cat src/main/resources/db/migration/V1__create_tables.sql
grep -n "REVOKE\|prevent_audit_modification\|BEFORE UPDATE OR DELETE" src/main/resources/db/migration/V1__create_tables.sql
```

**Erwartetes Ergebnis:** REVOKE UPDATE/DELETE, Trigger prevent_audit_modification.

- [ ] REVOKE UPDATE, DELETE ON audit_log
- [ ] Trigger blockiert UPDATE und DELETE
- [ ] Trigger wirft Exception mit aussagekraeftiger Meldung

---

## V7: Reliability

### V7.1: Idempotency-Key im Controller und Service

**Command:**
```bash
cd $PROJECT && grep -n "Idempotency-Key\|idempotencyKey" src/main/kotlin/com/example/payment/PaymentController.kt src/main/kotlin/com/example/payment/PaymentService.kt
```

**Erwartetes Ergebnis:** Header-Extraktion im Controller, Duplikat-Check im Service.

- [ ] Controller liest "Idempotency-Key" Header
- [ ] Service prueft auf existierenden idempotencyKey
- [ ] Bei Duplikat: vorhandenes Payment wird zurueckgegeben (kein neues Insert)
- [ ] idempotencyKey hat UNIQUE Constraint in Entity

### V7.2: Zustandsmaschine -- nur COMPLETED kann refunded werden

**Command:**
```bash
cd $PROJECT && grep -n "COMPLETED\|InvalidPaymentStateException\|409\|CONFLICT" src/main/kotlin/com/example/payment/PaymentService.kt src/main/kotlin/com/example/payment/Exceptions.kt
```

**Erwartetes Ergebnis:** Pruefung auf COMPLETED, Exception mit HTTP 409.

- [ ] Refund prueft payment.status != COMPLETED
- [ ] InvalidPaymentStateException hat @ResponseStatus(HttpStatus.CONFLICT)
- [ ] PENDING, REFUNDED, FAILED werden abgelehnt

### V7.3: Circuit Breaker fuer externen Zahlungsanbieter

**Command:**
```bash
cd $PROJECT && grep -n "CircuitBreaker\|fallback\|PaymentProviderUnavailable" src/main/kotlin/com/example/payment/PaymentProviderClient.kt
```

**Erwartetes Ergebnis:** @CircuitBreaker-Annotation, Fallback-Methode, wirft PaymentProviderUnavailableException.

- [ ] PaymentProviderClient existiert
- [ ] @CircuitBreaker auf processPayment
- [ ] @CircuitBreaker auf processRefund
- [ ] Fallback wirft PaymentProviderUnavailableException (-> HTTP 503)

### V7.4: Resilience4j in application.yml konfiguriert

**Command:**
```bash
cd $PROJECT && grep -n "resilience4j\|circuitbreaker\|paymentProvider" src/main/resources/application.yml
```

**Erwartetes Ergebnis:** Resilience4j Circuit-Breaker-Konfiguration vorhanden.

- [ ] resilience4j.circuitbreaker.instances.paymentProvider konfiguriert
- [ ] slidingWindowSize definiert
- [ ] failureRateThreshold definiert
- [ ] waitDurationInOpenState definiert

### V7.5: Health Endpoint

**Command:**
```bash
cd $PROJECT && grep -n "GetMapping.*health\|status.*UP" src/main/kotlin/com/example/payment/HealthController.kt
```

**Erwartetes Ergebnis:** GET /health gibt {"status": "UP"} zurueck.

- [ ] HealthController existiert
- [ ] GET /health gibt Status "UP" zurueck
- [ ] Ist in SecurityConfig als permitAll konfiguriert

---

## V8: Controller-Vollstaendigkeit (Vergleich Feature Files vs. Code)

### V8.1: Alle Endpunkte implementiert

**Command:**
```bash
cd $PROJECT && grep -n "Mapping\|fun " src/main/kotlin/com/example/payment/PaymentController.kt src/main/kotlin/com/example/payment/HealthController.kt
```

**Erwartetes Ergebnis:** 5 Business-Endpunkte + 1 Health:

| Endpunkt | Methode | Feature File |
|----------|---------|-------------|
| POST /api/payments | createPayment | payment-creation.feature |
| GET /api/payments/{id} | getPayment | payment-retrieval.feature |
| GET /api/payments?userId= | listPayments | payment-retrieval.feature |
| POST /api/payments/{id}/refund | refundPayment | payment-refund.feature |
| DELETE /api/payments/user/{userId} | eraseUserData | data-retention.feature |
| GET /health | health | authentication.feature, reliability.feature |

- [ ] POST /api/payments vorhanden
- [ ] GET /api/payments/{id} vorhanden
- [ ] GET /api/payments?userId= vorhanden
- [ ] POST /api/payments/{id}/refund vorhanden
- [ ] DELETE /api/payments/user/{userId} vorhanden
- [ ] GET /health vorhanden

---

## V9: Konfiguration vollstaendig

### V9.1: application.yml enthaelt alle Konfigurationen

**Command:**
```bash
cd $PROJECT && cat src/main/resources/application.yml
```

**Erwartetes Ergebnis:** Folgende Sektionen vorhanden:

- [ ] spring.datasource (URL, Username, Password)
- [ ] spring.jpa.hibernate.ddl-auto
- [ ] spring.security.oauth2.resourceserver.jwt.issuer-uri
- [ ] encryption.key-reference (KMS ARN oder Platzhalter)
- [ ] resilience4j.circuitbreaker.instances.paymentProvider
- [ ] server.port

---

## V10: Abgleich Quality Scenarios vs. Implementierung

### V10.1: Alle 15 Quality Scenarios adressiert

| QS-ID | Beschreibung | Implementierung | Pruefung |
|-------|-------------|-----------------|----------|
| QS-SEC-01 | 401 ohne JWT | SecurityConfig | V4.1 |
| QS-SEC-02 | PII verschluesselt in DB | EncryptionConverter + @Convert | V3.1, V3.2 |
| QS-SEC-03 | Keine PII in Logs | PiiMaskingLayout + logback-spring.xml | V3.4 |
| QS-SEC-04 | Keys nicht hardcoded | KMS-Referenz in application.yml | V3.3 |
| QS-SEC-05 | Rate Limiting | RateLimitFilter | V4.3 |
| QS-COMP-01 | Audit bei CREATE | AuditAspect | V6.2 |
| QS-COMP-02 | Audit bei REFUND | AuditAspect | V6.2 |
| QS-COMP-03 | Keine PII im Audit | AuditLog Entity (nur Metadaten) | V6.1 |
| QS-COMP-04 | Audit immutable | SQL-Trigger | V6.3 |
| QS-COMP-05 | Loeschung nach 36 Monate | DataRetentionJob | V5.1 |
| QS-COMP-06 | Right to Erasure | DELETE-Endpoint + anonymizeByUserId | V5.3, V5.4 |
| QS-REL-01 | Idempotenz | Idempotency-Key in Controller + Service | V7.1 |
| QS-REL-02 | Nur COMPLETED refundable | Status-Check im Service | V7.2 |
| QS-REL-03 | Health Endpoint | HealthController | V7.5 |
| QS-REL-04 | Graceful Degradation | CircuitBreaker + PaymentProviderClient | V7.3 |

- [ ] Alle 15 Quality Scenarios haben eine korrespondierende Implementierung

---

## V11: Abgleich Feature Files vs. Implementierung

### V11.1: Feature-Coverage-Check

**Command:**
```bash
# Zaehle Szenarien in allen Feature Files
cd /home/flo/superflowers/feature-design-workspace/iteration-3/eval-constraint-awareness/without_skill/outputs
grep -c "Scenario" *.feature | sort
```

**Erwartetes Ergebnis:** Alle Feature Files haben korrespondierende Tests.

| Feature File | Szenarien | Abgedeckt durch |
|-------------|-----------|-----------------|
| payment-creation.feature | 4 | Tasks 4, 5, 16 + Tests |
| payment-retrieval.feature | 4 | Tasks 4, 5 + Tests |
| payment-refund.feature | 5 | Tasks 4, 5, 17, 18 + Tests |
| authentication.feature | 5 | Tasks 6, 7, 8 + Tests |
| encryption-at-rest.feature | 3 | Tasks 9, 10 + Tests |
| audit-logging.feature | 6 | Tasks 11, 12, 13 + Tests |
| data-retention.feature | 5 | Tasks 14, 15 + Tests |
| reliability.feature | 5 | Tasks 16, 17, 18 + Tests |

- [ ] Jedes Feature File hat mindestens einen korrespondierenden Test

---

## V12: Schnell-Check -- Ist die Implementierung tatsaechlich vorhanden?

Dieser Check ist der wichtigste und sollte als **erstes** ausgefuehrt werden, da er sofort zeigt ob ueberhaupt implementiert wurde.

**Command:**
```bash
PROJECT=/home/flo/superflowers/project-constraints-workspace/test-fixtures/spring-boot-project
echo "=== Kotlin-Dateien ==="
find $PROJECT/src -name "*.kt" | wc -l
echo ""
echo "=== Erwartete Dateien ==="
for f in Payment.kt PaymentRepository.kt PaymentService.kt PaymentApplication.kt \
         Exceptions.kt SecurityConfig.kt HealthController.kt RateLimitFilter.kt \
         EncryptionConverter.kt PiiMaskingLayout.kt AuditLog.kt AuditLogRepository.kt \
         AuditAspect.kt DataRetentionJob.kt PaymentProviderClient.kt PaymentController.kt; do
    if [ -f "$PROJECT/src/main/kotlin/com/example/payment/$f" ]; then
        echo "[OK] $f"
    else
        echo "[FEHLT] $f"
    fi
done
echo ""
echo "=== Ressourcen-Dateien ==="
for f in application.yml logback-spring.xml; do
    if [ -f "$PROJECT/src/main/resources/$f" ]; then
        echo "[OK] $f"
    else
        echo "[FEHLT] $f"
    fi
done
if [ -f "$PROJECT/src/main/resources/db/migration/V1__create_tables.sql" ]; then
    echo "[OK] V1__create_tables.sql"
else
    echo "[FEHLT] V1__create_tables.sql"
fi
echo ""
echo "=== Test-Dateien ==="
find $PROJECT/src/test -name "*.kt" 2>/dev/null | wc -l
```

**Erwartetes Ergebnis:**
- 16 Kotlin-Dateien im src/main
- Alle 16 zeigen [OK]
- application.yml, logback-spring.xml, V1__create_tables.sql zeigen [OK]
- Mindestens 8 Test-Dateien im src/test

- [ ] Alle erwarteten Dateien existieren
- [ ] Mindestens 8 Test-Klassen vorhanden

---

## Zusammenfassung: Verifikations-Reihenfolge

1. **V12** zuerst -- Schnell-Check ob Dateien existieren (10 Sekunden)
2. **V2** -- Dependencies pruefen (30 Sekunden)
3. **V1.2** -- Kompilierung (1-2 Minuten)
4. **V1.3** -- Tests ausfuehren (2-5 Minuten)
5. **V3-V7** -- Constraint-spezifische Pruefungen (je 30 Sekunden)
6. **V8-V9** -- Vollstaendigkeit Controller + Config (1 Minute)
7. **V10-V11** -- Quality-Scenario- und Feature-Abgleich (Review, 5 Minuten)

## Verdikt-Kriterien

Die Implementierung gilt als **complete** wenn:
- [ ] V12: Alle 16 Kotlin-Dateien + 3 Ressourcen-Dateien existieren
- [ ] V1.2: Projekt kompiliert fehlerfrei
- [ ] V1.3: Alle Tests bestehen
- [ ] V2: Alle 10 Dependencies in pom.xml vorhanden
- [ ] V3: SEC-001 vollstaendig (Encryption, KMS, Log-Maskierung)
- [ ] V4: SEC-002 vollstaendig (JWT, Rate Limiting, Health permitAll)
- [ ] V5: COMP-001 vollstaendig (Retention Job, Erasure Endpoint, Anonymisierung)
- [ ] V6: COMP-002 vollstaendig (Audit Entity, Aspect, Immutability-Trigger)
- [ ] V7: Reliability vollstaendig (Idempotenz, Zustandsmaschine, Circuit Breaker)
- [ ] V8: Alle 6 Endpunkte implementiert
- [ ] V10: Alle 15 Quality Scenarios adressiert
