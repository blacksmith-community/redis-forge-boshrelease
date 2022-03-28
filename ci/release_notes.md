# TLS Support

Added TLS Support with Dual-Mode as an option. 

To turn on TLS Support set `redis.tls.enabled: true`. 
Be sure to set the associated certificates (see `spec`).

If you wish to run with dual-mode support `redis.tls.dual-mode: true`.
This will run TLS as default on `:6379` and also bind to listen insecurely on
port `:6380`.

