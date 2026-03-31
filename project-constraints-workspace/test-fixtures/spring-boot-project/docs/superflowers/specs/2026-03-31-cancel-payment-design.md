# Cancel Payment Endpoint — Design Spec

## Datum: 2026-03-31

## Zusammenfassung

Neuer REST-Endpunkt zum Stornieren von Zahlungen. Nur Zahlungen im Status `pending` dürfen storniert werden. Folgt dem bestehenden Pattern `POST /{id}/refund`.

## API

- **Endpunkt:** `POST /api/payments/{id}/cancel`
- **Erfolg:** HTTP 200
- **Payment nicht gefunden:** HTTP 404
- **Status nicht `pending`:** HTTP 409 Conflict

## Response DTO

```kotlin
data class CancelPaymentResponse(
    val id: Long,
    val status: String,          // "cancelled"
    val amount: Double,
    val cancelledAt: LocalDateTime
)
```

## Ablauf

1. Controller empfängt `POST /api/payments/{id}/cancel`
2. Service lädt Payment per ID — wirft `PaymentNotFoundException` wenn nicht gefunden
3. Service prüft `status == "pending"` — wirft `InvalidPaymentStateException` wenn nicht
4. Service setzt Status auf `cancelled` und speichert `cancelledAt = LocalDateTime.now()`
5. Repository persistiert die Änderung
6. Response mit `CancelPaymentResponse` zurückgeben

## Error Handling

| Exception | HTTP Status | Wann |
|---|---|---|
| `PaymentNotFoundException` | 404 Not Found | Payment-ID existiert nicht |
| `InvalidPaymentStateException` | 409 Conflict | Payment nicht im Status `pending` |

Implementierung via `@ResponseStatus`-Annotation auf den Exception-Klassen.

## Dateien

| Datei | Änderung |
|---|---|
| `PaymentController.kt` | Neuer `cancelPayment()` Endpunkt, neues `CancelPaymentResponse` DTO |
| `PaymentService.kt` | Neue `cancel(id): CancelPaymentResponse` Methode (Signatur) |
| `PaymentNotFoundException.kt` | Neue Exception mit `@ResponseStatus(HttpStatus.NOT_FOUND)` |
| `InvalidPaymentStateException.kt` | Neue Exception mit `@ResponseStatus(HttpStatus.CONFLICT)` |

## Architektur-Alignment

Referenz: `architecture.md`

- **Reliability (Top 1):** Statusänderung in DB-Transaktion, kein Payment ohne Terminal-Status
- **Security (Top 2):** Endpunkt erfordert JWT-Auth (SEC-002), Input wird validiert
- **Availability (Top 3):** Einfache synchrone Operation, kein zusätzliches Ausfallrisiko

## BDD-Szenarien

Referenz: `features/cancel-payment.feature`

| Szenario | Abdeckung |
|---|---|
| Successfully cancel a pending payment | Happy Path, Response-Felder |
| Cancelling a non-pending payment is rejected | 409 mit Fehlermeldung |
| Outline: non-pending status rejected | failed, refunded, cancelled |
| Non-existent payment returns not found | 404 |
| Cancellation is persisted | Datenkonsistenz |
| Unauthenticated request is denied | SEC-002 |
| Cancellation recorded in audit log | COMP-002 |

## Offene Punkte

- Projekt-Constraints (SEC-001, SEC-002, COMP-001, COMP-002) noch nicht eingerichtet — `superflowers:project-constraints` ausführen
- PCI-DSS Relevanz klären (siehe `architecture.md` Open Items)
