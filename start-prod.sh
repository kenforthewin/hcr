#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

rake assets:precompile
exec rails s -b 0.0.0.0