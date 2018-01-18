# Improvements

- We have documentation now!

- Kernel tuning has been performed against both standalone and
  clustered deployment types.

- The standalone deployment type can now be persistent: true, to
  run AOF dumps with per-second fsyncs, to the BOSH persistent
  disk, for durability and persistence.

- A new `cluster` deployment type can be used to deploy Redis in a
  clustered (sharded) configuration, with multiple masters and a
  set number of replicas per master.

- Operators can now override the default network on a per-plan
  basis, allowing a single forge to deploy to different networks.
