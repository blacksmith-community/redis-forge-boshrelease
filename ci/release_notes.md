# Redis Forge BOSH Release v1.4.2

**Bug Fix** - Fixes cluster formation failure in TLS dual-mode deployments.

## Changes

### Bug Fix
- **Cluster MEET port for TLS dual-mode**: When TLS dual-mode is enabled,
  `CLUSTER MEET` now uses the TLS port (16379) so the cluster bus port
  resolves correctly to 26379 (16379 + 10000). Previously, using port 6379
  caused nodes to calculate bus port 16379, which didn't match the actual
  bus port, preventing cluster gossip and node discovery.

### Affected Jobs
- `cluster-6`
- `cluster-7`
