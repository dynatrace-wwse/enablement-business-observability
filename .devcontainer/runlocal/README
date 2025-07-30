# What this is all about
This directory is a helper for building and starting the .devcontainer locally in two modes:
- with a remote connection using VisualStudio Code
- as a plain Docker Container without VisualStudio Code or Github Codespaces

# Building and Running the container
there is a file called makefile.sh that includes the build logic (this loaded with a Makefile). If the host does not have Make installed it can be runned separately.

## Build and start the container
```sh 
make start
source ./makefile.sh && start 
```


## Files
### .env file
create one. is ommited in .gitignore to avoid token leaks in git.
Just copy and paste the contents in a file named .env in this directory '.devcontainer/runlocal/.env'.
All variables will be read and will be passed on dynamically as environment variables to the container.

-----Sample Contents -----
```sh
# Mapping of the Secrets defined in the .devcontainer.json file
# Dynatrace Tenant
DT_TENANT=https://abc123.live.dynatrace.com 
#Description: eg. abc123 for live -> https://abc123.live.dynatrace.com or sprint -> https://abc123.sprint.dynatracelabs.com no apps in the URL

# Dynatrace Operator Token
DT_OPERATOR_TOKEN=dt0c01.XXXZZZZAAAA.XXXZZZZAAAA
#it will be created automatically when adding a new Cluster over the UI. It contains the following permissions: 'Create ActiveGate tokens' 'Read entities' 'Read settings' 'Write settings' 'Access probrem and event feed, metrics and topology' 'PaaS Integration - installer download

#Dynatrace Ingest Token
DT_INGEST_TOKEN=dt0c01.XXXZZZZAAAA.XXXZZZZAAAA
#it will be created automatically when adding a new Cluster over the UI. It contains the following permissions: 'Ingest logs' 'Ingest metrics' 'Ingest OpenTelemetry traces'
```
-------

### helper.sh
helper script for calculating the repository name which is needed for the framework to work inside the container and reading the key and values defined in the .env file.


## Running inside a devcontainer locally using VisualStudio Code with Secrets
If you have VisualStudio Code with this repository open, it'll ask if you want to open it inside a devcontainer. It'll build the image and load VSCode inside the container. Github Codespaces manages to pass on the secrets to the container, so if we are to run locally we need to pass the secrets ourselves as environment variables via the .devcontainer.json definition. We read the environment variables from '.devcontainer/runlocal/.env' which is the same file when running in a plain docker container.

Modify the parameter 'runArgs' from the devcontainer.json

From:
```json
"runArgs": ["--init", "--privileged", "--network=host"],
```

to:
```json
"runArgs": ["--init", "--privileged", "--network=host","--env-file",".devcontainer/runlocal/.env"],
```

If you don't create the file VSCode will throw an error and won't be able to load locally.



# Building for AMD64 and ARM64 with buildx 
## Building for multiple architectures in one shot
You need to be running on a Linux HOST on ARM. We recommend to use UbuntuLTS 22 or 24 running on AMD or ARM. 
The image cab be built for AMD and for ARM on each host but crossbuilding works at the moment only from ARM -> AMD since when downloading the HELM libraries vial CURL an SSL error is thrown. Since crosscompiling is a step that is done only for pushing the final image to a registry, this should not be improved.

Good to know, when crosscompiling be sure to run on a ARM64 architecture and not AARCH64 (as MAC) since the TARGETARCH variable is used in the dockerfile to dowload the needed binaries, if the URL does not match the build might fail. 

# Install Buildx
First make sure you have buildx installed.
```sh
sudo apt install docker-buildx
```

## Enable buildx, create a builder for emulating.
```bash
docker buildx create --use --name multiarch-builder
```
it will give generate a multiarchitecture builder

## Login to the Registry
Before crosscompiling you need to login to the registry for the namespace so the repository:tag can be pushed. We are using Dockerhub at the moment. So we do
```sh
docker login
```
so we can push the images with the specific manifest. more information can be found here about crosscompiling 
https://docs.docker.com/build/building/multi-platform/


## Now you can crosscompile
```sh
make buildx
# if make is not installed then run 
source ./makefile.sh && buildx 
```









# CHEATSHEET


Copy Kind cluster config if already running


docker run -v ~/.kube:/root/.kube -v ~/.config:/root/.config -it your-image



docker exec -it kind-control-plane sh -c 'kubectl config view --raw'

kubectl config view --raw > dockerconfig 