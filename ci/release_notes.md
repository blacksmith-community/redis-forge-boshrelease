# Improvements

- Removed URI support from Redis forge. This caused too many problems with
  specific CF apps that all wanted different URI formats, but still prioritized
  it over host/port/password fields. Removing it allows apps to fallback to just
  host/port/password fields to assemble their own URI format.
