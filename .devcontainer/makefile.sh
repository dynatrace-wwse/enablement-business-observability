#!/bin/bash
# Build script for building locally and launching the training environment in a Docker container without Visual Studio Code.
# Tested on Ubuntu 22.04 and 24.04 LTS with Docker installed.

source runlocal/helper.sh
ENV_FILE=runlocal/.env

NAMESPACE="shinojosa"
IMAGENAME="dt-enablement"
REPOSITORY=$NAMESPACE/$IMAGENAME
TAG="v1.0"

REPOTAG=$REPOSITORY:$TAG

# Commands to be executed in the container after it is created (as in VSCode devcontainer.json)
CMD="./.devcontainer/post-create.sh; ./.devcontainer/post-start.sh; zsh ;"

# Calculates the RepositoryName from the base path, needed for loading the framework inside the container.
getRepositoryName

# Loads variables k=v from the .env file into DOCKER_ENVS such as DT_TENANT, so they can be added as environment variables to the Docker container.
getDockerEnvsFromEnvFile


buildNoCache(){
    # Build the image with no cache
    docker build --no-cache -t $REPOTAG .
    echo "Building completed."   
}


buildx(){
    docker buildx build --no-cache --platform linux/amd64,linux/arm64 -t $REPOTAG --push .
}

build(){
    # Build the image
    echo "Building the image $REPOTAG ..."
    docker build -t $REPOTAG .
    echo "Building completed."
}

runForProfessors(){
    # Same as run but with exposure of port 8000 for Labguides

    # Add repository name to the environment variables for the container
    DOCKER_ENVS+=" -e RepositoryName=$RepositoryName"

    docker run $DOCKER_ENVS \
        --name $IMAGENAME \
        --privileged \
        --dns=8.8.8.8 \
        --network=host \
        -p 8000:8000 \
        -p 30100:30100 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /lib/modules:/lib/modules \
        -v $(dirname "$PWD"):/workspaces/$RepositoryName \
        -w /workspaces/$RepositoryName \
        -it $REPOTAG \
        /usr/bin/zsh -c "$CMD"
}

run(){
    # Add repository name to the environment variables for the container
    DOCKER_ENVS+=" -e RepositoryName=$RepositoryName"

    docker run $DOCKER_ENVS \
        --name $IMAGENAME \
        --privileged \
        --dns=8.8.8.8 \
        --network=host \
        -p 30100:30100 \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /lib/modules:/lib/modules \
        -v $(dirname "$PWD"):/workspaces/$RepositoryName \
        -w /workspaces/$RepositoryName \
        -it $REPOTAG \
        /usr/bin/zsh -c "$CMD"
}

start(){
    status=$(docker inspect -f '{{.State.Status}}' "$IMAGENAME")
    if [ "$status" = "exited" ] || [ "$status" = "dead" ]; then
        echo "Container is stopped removing container."
        # Add repository name to the environment variables for the container
        docker rm $IMAGENAME
        echo "Starting a new container"
        run 
    elif  [ "$status" = "running" ]; then 
        echo "Container $IMAGENAME is running, attaching new shell to it"
        docker exec -it $IMAGENAME zsh 
    else
        echo "Image $IMAGENAME is not found."
        if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$IMAGENAME$"; then
            echo "Image exists locally, running it."
        else
            echo "Image does not exist locally. Building it first, if you want to build your own, do 'make build'"
        fi
        run
    fi
}