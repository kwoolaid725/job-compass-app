#!/bin/bash
set -e

echo ">>> Running airflow-init.sh as $(whoami)."

# Fix Docker socket permissions if it exists
if [ -S /var/run/docker.sock ]; then
    echo ">>> Setting docker.sock permissions."
    chmod 660 /var/run/docker.sock
    chown root:docker /var/run/docker.sock
fi

# Finally, run the actual command passed by docker-compose
echo ">>> Passing on to final command: $*"
exec "$@"