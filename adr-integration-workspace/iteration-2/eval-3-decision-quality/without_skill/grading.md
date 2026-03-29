# Eval 3: Decision Quality -- WITHOUT SKILL

## A1: All 3 ADRs list at least 2 alternatives with CONCRETE pros/cons
**PARTIAL PASS**

- **ADR-001:** 3 alternatives (Event-Driven, Microservices, Service-Based) with a scoring table and concrete reasoning in the "Alternatives Considered" section. Microservices: "4 developers cannot effectively own, deploy, and operate the number of independent services." Service-Based: "does not leverage the inherently event-driven nature of IoT data as effectively." Concrete enough.
- **ADR-002:** 3 alternatives (PostgreSQL, MongoDB, DynamoDB) discussed in "Alternatives Considered" with concrete reasoning. MongoDB: "Schema-less storage creates risk of inconsistent data shapes that complicate auditing. Transactions are a bolted-on feature." DynamoDB: "limited transaction support, lack of ad-hoc SQL querying." Concrete but less detailed than with-skill (no specific numbers like transaction limits or ramp-up times).
- **ADR-003:** Only 1 alternative (Strong Consistency) discussed. Session consistency is not mentioned at all. The "Alternatives Considered" section only has "Strong Consistency (Rejected)."

ADR-003 fails to meet the "at least 2 alternatives" requirement.

## A2: All 3 ADRs have at least 1 NEGATIVE consequence
**PASS**

- **ADR-001:** "Event-driven debugging is harder than request-response"; "Event ordering and exactly-once processing require careful design"; "Vendor lock-in to AWS event services"
- **ADR-002:** "Vertical scaling has limits"; "Operational burden of managing PostgreSQL instances"; "Schema migrations require careful planning"
- **ADR-003:** "Users may occasionally see a feed that is up to 500ms behind"; "New posts may appear with a brief delay"; "Write-then-read patterns may not reflect the new post instantly"

All three have negative consequences, though they are more briefly stated and some include immediate mitigations that soften the honesty (e.g., "mitigated by...").

## A3: Quantified data present in at least 2 of 3 ADRs
**PARTIAL PASS**

- **ADR-001:** Scores (15/15, 11/15, 13/15), cost estimates ($2,000-4,000, $5,000-10,000, $3,000-6,000). Quantified.
- **ADR-002:** No specific numbers. No TPS limits, no transaction size limits, no ramp-up estimates. The discussion is qualitative only.
- **ADR-003:** "10x baseline" throughput, "500ms" staleness. Some quantification, but no specific reads/sec numbers, no latency measurements, no cost data.

ADR-001 has strong quantification. ADR-003 has minimal quantification. ADR-002 has none. Borderline on the "at least 2 of 3" requirement -- ADR-003's quantification is thin (ratios and a single time value, no absolute numbers).

## Score: 1.5/3
