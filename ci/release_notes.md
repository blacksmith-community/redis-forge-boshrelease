# Breaking Changes

The service binding based on hostname requires that any new standalone plans include `single-node` in its name. If you are upgrading from a previous version make sure that your standalone plans include `single-node` in their name. Failing to do so will result in the application failing to communicate with the service instance. Important changes were also introduced on [v1.0.1](https://github.com/blacksmith-community/redis-forge-boshrelease/releases/tag/v1.0.1), Make sure you review those before proceeding.

# Improvements

* Adds hostname to Redis binding @ahartpence