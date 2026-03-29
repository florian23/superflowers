# Grading: Eval 2 — REST vs GraphQL (WITHOUT skill)

| Assertion | Pass/Fail | Notes |
|-----------|-----------|-------|
| A0: Output files exist with real content | PASS | Substantive ADR |
| A1: Nygard format (Status, Context, Decision, Consequences) | FAIL | Uses non-standard section names: "Kontext", "Entscheidung", "Begruendung", "Verworfene Alternativen", "Konsequenzen". Missing a unified "Decision" section (split into "Entscheidung" and "Begruendung"). No standard "Consequences" heading. Also has "Verworfene Alternativen" as a separate section not part of Nygard format. |
| A2: Title in imperative form | FAIL | "REST als API-Stil fuer die Booking API" is a noun phrase, not imperative |
| A3: Context mentions at least 2 alternatives | PASS | REST, GraphQL, and gRPC listed (though detail is in "Verworfene Alternativen" rather than Context) |
| A4: Consequences include positive AND negative | FAIL | Consequences section has only 3 bullet points that are neutral/operational ("API folgt REST-Konventionen", "OpenAPI/Swagger wird zur Dokumentation verwendet", re-evaluation note). No explicit positive/negative separation. The negative consequences are missing entirely from the Konsequenzen section. |
| A5: Correct sequential numbering | PASS | ADR-001 |

**Score: 3/6**
