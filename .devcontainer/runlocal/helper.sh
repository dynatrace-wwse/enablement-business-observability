#!/bin/bash
# Helper script for loading environment variables and functions for building and running the Docker container locally. 

getRepositoryName() {
    # Sets RepositoryName from the 'current' working directory.
    RepositoryName=$(basename "$(dirname "$PWD")")
    export RepositoryName=$RepositoryName
    echo "RepositoryName is set to: $RepositoryName"
}



getDockerEnvsFromEnvFile() {
  if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: .env file not found at $ENV_FILE, before running locally read \
the '.devcontainer/runlocal/README' file and make sure you have all the secrets \
needed for this devcontainer to run successfully inside the .env file "
    exit 1
  fi

  while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
    # Remove surrounding quotes from value if present
    value="${value%\"}"
    value="${value#\"}"
    DOCKER_ENVS+=" -e ${key}=${value}"
  done < "$ENV_FILE"

  export DOCKER_ENVS
  echo "Loaded DOCKER_ENVS: $DOCKER_ENVS"
}

