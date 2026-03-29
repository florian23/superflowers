# Architecture Characteristics
## Last Updated: 2026-03-29
## Top 3 Priority Characteristics
1. Scalability — Must handle 100k sensors sending data every 5 seconds
2. Elasticity — Traffic spikes 10x during peak hours
3. Fault Tolerance — Zero data loss during partial system failures

## Architecture Drivers
- IoT scale: Massive concurrent connections with bursty traffic
- Cloud-native: AWS deployment

## Selected Architecture Style

**Style:** Event-Driven Architecture
**Partitioning:** technical
**Cost Category:** $$$

### Selection Rationale
- Driving characteristics: Scalability (★5), Elasticity (★5), Fault Tolerance (★5)
- Fit score: 15/15
- Tied with Microservices on fit score but at significantly lower cost ($$$ vs $$$$$)
- Event-driven is the natural paradigm for IoT sensor data — sensors produce events, the system consumes and processes them asynchronously
- AWS provides mature event-driven infrastructure (Kinesis, SQS, Lambda) that directly supports the cloud-native deployment driver
- Broker topology handles 100k concurrent sensor connections with bursty 10x traffic spikes through partitioned, parallelized event consumption

### Tradeoffs Accepted
- Simplicity: Rated 2/5 — accepted because the IoT scale requirements (100k sensors, 10x spikes) inherently demand a non-trivial architecture; async complexity is managed through AWS managed services (Kinesis, Lambda) that reduce operational burden
- Testability: Rated 2/5 — mitigated through contract testing on event schemas, local event broker emulation (LocalStack), and integration test suites that verify end-to-end event flows
- Deployability: Rated 3/5 — adequate for the use case; AWS CDK/CloudFormation provides infrastructure-as-code for repeatable deployments of event-driven components

### Evolution Path
- Start with a broker topology (Kinesis streams with Lambda consumers) for sensor ingestion and processing
- Add mediator topology (Step Functions) if complex multi-step workflows emerge (e.g., alert escalation, sensor correlation)
- If distinct bounded contexts emerge over time (e.g., device management vs analytics vs alerting), extract those into separate services — evolving toward a hybrid event-driven/service-based architecture
- Space-based caching (ElastiCache/DAX) can be added at the read layer if real-time dashboards require sub-millisecond response times

## Changelog
- 2026-03-29: Initial assessment
- 2026-03-29: Selected Event-Driven Architecture (fit score 15/15, $$$) based on driving characteristics
