# Grading: Eval 3 — Unplanned Message Queue (WITHOUT skill)

| Assertion | Pass/Fail | Notes |
|-----------|-----------|-------|
| A0: Output files exist with real content | PASS | Detailed ADR |
| A1: Nygard format (Status, Context, Decision, Consequences) | FAIL | Uses non-standard section names: "Kontext", "Entscheidung", "Betrachtete Alternativen", "Konsequenzen", "Bezug zu bestehenden Entscheidungen". Also has extra sections not in the Nygard format ("Datum", "Betrachtete Alternativen", "Bezug zu bestehenden Entscheidungen"). Missing the standard English headings. |
| A2: Title in imperative form | FAIL | "Asynchrone Kommunikation zwischen Order- und Inventory-Service via Message Queue" is a descriptive noun phrase, not imperative |
| A3: Context mentions at least 2 alternatives | PASS | 3 alternatives listed: synchronous HTTP with retry/circuit breaker, message queue, gRPC |
| A4: Consequences include positive AND negative | PASS | Positiv (3 items) and Negativ (3 items) clearly separated |
| A5: Correct sequential numbering | PASS | ADR-003 |

**Score: 4/6**
