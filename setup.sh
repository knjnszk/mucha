#!/bin/sh

# Run the following to set MUCHA_PATH
#
#     cd /path/to/mucha
#     . setup.sh
#

export MUCHA_PATH="$(pwd -P)"
echo "MUCHA_PATH is set to $MUCHA_PATH"
