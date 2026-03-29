# Grading: Eval 4 (Legacy Decomposition — Insurance) — WITH Skill

| Assertion | Pass/Fail | Notes |
|-----------|-----------|-------|
| A0: Output files exist with real content | PASS | Both files are extensive and deeply detailed. |
| A1: Subdomains classified (Core/Supporting/Generic) with rationale | PASS | 5 subdomains classified: Vertragsmanagement (Core — "Kerngeschaeft"), Schadensbearbeitung (Core — "Differenzierungsmerkmal"), Praemienberechnung (Core — "wettbewerbsentscheidend"), Kundenverwaltung (Supporting), Dokumentengenerierung (Supporting). Clear rationale for each. |
| A2: Bounded contexts have clear responsibility (domain-based, not entity-based or technical) | PASS | All contexts are domain-capability-based: "Vertragswesen" (Vertragslebenszyklus), "Schadenregulierung" (Schadenmeldung bis Auszahlung), "Tarifierung & Praemie" (Praemienberechnung). The legacy Monolith is also included as a context. No entity-based or technical boundaries. |
| A3: Ubiquitous language defined per context (terms + meanings table) | PASS | Every context (including the Monolith) has a UL table with 4-6 terms. The Monolith UL deliberately shows the muddy language ("Vertrag" = "vermischt Police, Nachtrag, Antrag") vs the clean new contexts. Linguistic test in analysis shows how "Kunde", "Vertrag", "Dokument" diverge across contexts. |
| A4: Context relationships mapped with explicit DDD patterns | PASS | 11 relationships mapped with 4 patterns: ACL (5x for legacy integration), Customer-Supplier, Open Host Service, Published Language. Rich and appropriate pattern selection. |
| A5: context-map.md has structured format | PASS | Has subdomains table, context definitions with UL tables, relationships table, ASCII diagram, migration sequence table. |
| **A7: ACL recommended for legacy integration** | **PASS** | ACL is explicitly recommended for ALL 5 legacy-to-new-context relationships. Detailed ACL strategy in analysis: "Jeder neue Bounded Context kommuniziert mit dem Monolith ausschliesslich ueber einen Anti-Corruption Layer." Per-context ACL translation tables provided. Strangler Fig pattern with ACL as the routing mechanism. |

**Score: 7/7 (including A7)**

Exceptional output. The dual treatment of the Monolith as a bounded context with its own (muddy) UL is sophisticated. The ACL strategy is thorough — not just recommending ACL but detailing what each ACL translates (e.g., "80-Spalten-Vertragstabelle -> Police-Aggregat mit Deckungen, Nachtraegen"). Migration sequence with risk assessment is a valuable bonus.
