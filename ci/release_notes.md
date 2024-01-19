# Bug Fixes

* **Enhanced Cluster Formation & Communication** @itsouvalas
    * **Reintroduced SYNC Command:** Essential for cluster formation.
    * **Node Introduction Resolution:** Implements a mechanism for seamless node integration into clusters
    * **Optimized Node Introductions:**  Limits introductions to only necessary instances, enhancing efficiency.
    * **Updated Primary/Replica Logic:** Facilitates even distribution across the available nodes.
    * **Master Authentication:** Introduces masterauth for secure replica communication within clusters.
    * **TLS-Enabled Replication:** Adds `tls-replication yes`` option for secure replication over TLS.

# Documentation

* **Redis Cluster Troubleshooting:** A comprehensive guide to troubleshooting Redis cluster formation is now available.[View Documentation](docs/redis_cluster_troubleshooting.md) @itsouvalas

# Important Upgrade Information

If you've previously used the default value of the disabled `SYNC` command, reenabled in this release, any nodes of clusters currently in operation would have failed to introduce themselves to each other. If you rely on persistent data, identify the master(s) currently holding your data and make sure you create a backup before you proceed. You may review the [Redis Cluster Troubleshooting](docs/redis_cluster_troubleshooting.md) above to get a better understanding of the intricacies of cluster formation.