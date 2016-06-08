#!/bin/bash

# init.sh - Bootstrap Script for Redis Forge.
#           Generates username and password for the
#           new Redis environment.

safe gen ${CREDENTIALS}/redis username password
