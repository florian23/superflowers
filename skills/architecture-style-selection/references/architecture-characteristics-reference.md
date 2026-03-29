# Architecture Characteristics Reference

Based on the Architecture Characteristics Worksheet by Mark Richards (DeveloperToArchitect.com).
Source: "Fundamentals of Software Architecture" by Neal Ford & Mark Richards.
Last updated: March 2024 (worksheet version).

## Instructions

1. Identify no more than 7 driving characteristics
2. Pick the top 3 characteristics (in any order)
3. Implicit characteristics can become driving characteristics if they are critical concerns
4. Additional characteristics that aren't in the top 7 go to "Others Considered"

## Common Architecture Characteristics

| Characteristic | Definition |
|---|---|
| performance | The amount of time it takes for the system to process a business request |
| responsiveness | The amount of time it takes to get a response to the user |
| availability | The amount of uptime of a system; usually measured in 9's (e.g., 99.9%) |
| fault tolerance | When fatal errors occur, other parts of the system continue to function |
| scalability | A function of system capacity and growth over time; as the number of users or requests increase in the system, responsiveness, performance, and error rates remain constant |
| elasticity | The system is able to expand and respond quickly to unexpected or anticipated extreme loads (e.g., going from 20 to 250,000 users instantly) |
| data integrity | The data across the system is correct and there is no data loss in the system |
| data consistency | The data across the system is in sync and consistent across databases and tables |
| adaptability | The ease in which a system can adapt to changes in environment and functionality |
| concurrency | The ability of the system to process simultaneous requests, in most cases in the same order in which they were received; implied when scalability and elasticity are supported |
| interoperability | The ability of the system to interface and interact with other systems to complete a business request |
| extensibility | The ease in which a system can be extended with additional features and functionality |
| deployability | The amount of ceremony involved with releasing the software, the frequency in which releases occur, and the overall risk of deployment |
| testability | The ease of and completeness of testing |
| abstraction | The level at which parts of the system are isolated from other parts of the system (both internal and external system interactions) |
| workflow | The ability of the system to manage complex workflows that require multiple parts (services) of the system to complete a business request |
| configurability | The ability of the system to support multiple configurations, as well as support custom on-demand configurations and configuration updates |
| recoverability | The ability of the system to start where it left off in the event of a system crash |

## Implicit Characteristics

These are characteristics that every system should support. They only become driving characteristics when they are critical concerns that influence architecture decisions.

| Characteristic | Definition |
|---|---|
| feasibility (cost/time) | Taking into account timeframes, budgets, and developer skills when making architectural choices; tight timeframes and budgets make this a driving characteristic |
| security | The ability of the system to restrict access to sensitive information or functionality |
| maintainability | The level of effort required to locate and apply changes to the system |
| observability | The ability of a system or a service to make available and stream metrics such as overall health, uptime, response times, performance, etc. |

## Composite Characteristics

Composite characteristics are composed of other characteristics. When a composite is identified as driving, its component characteristics are also driving.

| Composite | Components |
|---|---|
| agility | maintainability + testability + deployability |
| reliability | availability + testability + data integrity + data consistency + fault tolerance |

## Related Characteristics

Some characteristics are related — depending on the system, you may need one or both. They are marked with a/b notation in the original worksheet.

| Pair | Distinction |
|---|---|
| performance / responsiveness | Performance = processing time (backend); Responsiveness = perceived response time (user-facing) |
| scalability / elasticity | Scalability = gradual growth over time; Elasticity = sudden spikes (burst capacity) |
| data integrity / data consistency | Integrity = no data loss; Consistency = data in sync across stores |
| adaptability / extensibility | Adaptability = changes to environment/config; Extensibility = adding new features/code |
