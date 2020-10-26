# Improvements

* Redis upgraded from 5.0.7 to 5.0.9
(see <https://raw.githubusercontent.com/antirez/redis/5.0/00-RELEASENOTES> for
more infomation on the changes)

* The following parameters can now be set at service-provisioning time (with the -c flag to create-service in CF):
  * maxmemory-policy
  * notify-keyspace-events
  * slowlog-log-slower-than
  * slowlog-max-len

* The following parameters can now be set in the plan definition:
  * redis_maxmemory-policy
  * redis_maxmemory
  * redis_notify-keyspace-events
  * redis_slowlog-log-slower-than
  * redis_slowlog-max-len
  * redis_no-appendfsync-on-rewrite
  * redis_auto-aof-rewrite-percentage
  * redis_auto-aof-rewrite-min-size
  * client_timeout
  * client_tcpkeepalive
  * client_connections
  * lua_scripting_enabled

* The following Redis commands were disabled to the client:
  * DEBUG
  * CONFIG
  * SHUTDOWN
  * SYNC
  * SLAVEOF