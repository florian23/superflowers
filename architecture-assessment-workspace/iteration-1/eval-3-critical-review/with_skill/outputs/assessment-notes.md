# Architecture Assessment Notes — IoT Support Review

## Date: 2026-03-28

## PO Request
> "We need to support IoT devices now, that changes everything! Performance is no longer important, we need Fault Tolerance as top priority instead."

## Critical Review Summary

### Three Claims Evaluated

| PO Claim | Verdict | Reasoning |
|---|---|---|
| "Performance is no longer important" | **REJECTED** | Performance is an architecture characteristic, not an afterthought. The existing public-facing API still needs <200ms p95. IoT devices on constrained networks have *stricter* latency needs, not looser ones. Dropping Performance would harm both existing and new users. |
| "Fault Tolerance as top priority (#1)" | **PARTIALLY ACCEPTED** | Fault Tolerance is justified as Critical and enters Top 3, but not as #1. In a healthcare domain handling PII, Security must remain the top priority — breaches have legal, financial, and patient-safety consequences that outweigh intermittent device connectivity issues. |
| "That changes everything" | **REJECTED** | Architecture evolves incrementally. The core drivers (healthcare, PII, public API) are unchanged. IoT adds a new driver but does not invalidate existing ones. This is an evolution, not a revolution. |

### Red Flags Identified in PO Request
1. **Dropping a Critical characteristic without evidence** — No data presented showing Performance is no longer needed
2. **"Changes everything" framing** — Classic sign of requirements confusion rather than genuine architecture shift
3. **New feature driving complete Top-3 reshuffle** — Architecture characteristics should be stable across features

### Changes Made to architecture.md
- **Added:** Fault Tolerance (Critical, Top 3 #2)
- **Added:** Extensibility (Important) — new device types
- **Added:** Observability (Important) — device monitoring
- **Expanded:** Performance goal to include IoT ingestion (<500ms p95)
- **Expanded:** Security to include IoT device authentication (mTLS)
- **Expanded:** Scalability to include 10,000 IoT devices, upgraded to Important
- **Moved:** Testability out of Top 3 (remains Important)
- **Retained:** Performance as Critical and in Top 3
- **Retained:** Security as #1 priority

### Tradeoffs Acknowledged
- Adding Fault Tolerance (message buffering, store-and-forward) may add latency to IoT data paths — the 500ms p95 goal for IoT ingestion accounts for this
- IoT subsystem isolation adds structural complexity but prevents fault propagation to the core API
- Testability leaving Top 3 does not reduce its importance — it remains at >80% coverage with an automated fitness function
