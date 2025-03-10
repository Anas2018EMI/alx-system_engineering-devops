# Postmortem: E-commerce API Gateway Outage

PS:[You can find this article also in this document](https://docs.google.com/document/d/1vx0XTMyNrv3DssonWk86MzGQknTufSrLkxhhfDak0HM/edit?usp=sharing)
## Issue Summary
**Duration**: June 12, 2024, 14:22 - 17:45 UTC  
**Impact**: Our primary e-commerce API gateway experienced severe latency issues, resulting in failed transactions and timeout errors for approximately 78% of user requests. Customer checkout flows were most severely affected, with cart abandonment rates spiking to 93% during the outage.  
**Root Cause**: Memory leak in the API gateway service caused by a recent deployment that introduced inefficient connection pooling.

## Timeline
* **14:22 UTC** - Issue began when automated monitoring detected increased latency in API gateway response times
* **14:28 UTC** - Engineering team received PagerDuty alert for API response times exceeding SLA thresholds
* **14:35 UTC** - Initial investigation focused on database load, as several query metrics showed unusual patterns
* **14:52 UTC** - Customer support reported increasing volume of checkout failure complaints
* **15:10 UTC** - Database team confirmed database performance was not the root cause, investigation pivoted to network infrastructure
* **15:25 UTC** - Network team verified all routing and load balancing systems were functioning normally
* **15:40 UTC** - Incident escalated to Platform Engineering team after exhausting initial troubleshooting paths
* **16:05 UTC** - Platform Engineering identified memory consumption issue in API gateway containers
* **16:20 UTC** - Connection pooling issue in recent deployment (v2.3.7) identified as likely cause
* **16:45 UTC** - Emergency rollback to previous stable version (v2.3.6) initiated
* **17:45 UTC** - System fully recovered after rollback completed and services restarted

## Root Cause and Resolution
The outage was caused by a memory leak in our API gateway service that was introduced in the v2.3.7 deployment earlier that day. The update included a change to how our connection pooling managed database connections, which unintentionally created a scenario where connections weren't being properly closed after use. As traffic increased during peak shopping hours, the memory usage in the gateway containers grew exponentially until the services began failing. The containers were attempting to manage too many open connections, exhausting available resources and causing request timeouts.

The issue was resolved by rolling back to the previous stable version (v2.3.6) of the API gateway service. After the rollback, we implemented a controlled restart of all affected containers to clear the accumulated memory usage and reset connection pools.

## Corrective and Preventative Measures
### Improvements Needed
1. Enhance pre-deployment testing for memory usage patterns
2. Improve monitoring and alerting around connection pooling metrics
3. Create more comprehensive canary deployment process
4. Develop better rollback procedures that can be executed more quickly

### Specific Action Items
1. Add memory leak detection tests to CI/CD pipeline (Owner: DevOps, Deadline: June 20)
2. Configure additional Prometheus alerts for connection pool utilization and memory growth patterns (Owner: SRE Team, Deadline: June 18)
3. Update container resource limits and implement automatic restarts based on memory thresholds (Owner: Platform Engineering, Deadline: June 25)
4. Review and fix connection pooling logic in v2.3.7 code before attempting redeployment (Owner: Backend Team, Deadline: June 30)
5. Develop and document emergency rollback runbook with reduced execution time (Owner: SRE Team, Deadline: June 22)
6. Implement progressive traffic shifting for API gateway deployments to catch issues before full deployment (Owner: DevOps, Deadline: July 15)
