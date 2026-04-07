# Thin Makefile — bootstraps the framework cache and delegates to makefile.sh
# The actual build/run logic lives in the framework (pulled at FRAMEWORK_VERSION).
# For local Docker usage: cd .devcontainer && make start

FRAMEWORK_VERSION := $(shell grep -oP ':-\K[^}"]+' util/source_framework.sh | head -1)
CACHE := .cache/dt-framework/$(FRAMEWORK_VERSION)

# Repo name and root path (CURDIR = repo/.devcontainer where this Makefile lives)
REPO_NAME := $(notdir $(patsubst %/,%,$(dir $(CURDIR))))
REPO_ROOT := $(patsubst %/,%,$(dir $(CURDIR)))

# Bootstrap: populate host cache if missing
$(CACHE)/.complete:
	@echo "Bootstrapping framework v$(FRAMEWORK_VERSION)..."
	@mkdir -p $(dir $(CACHE))
	@git clone --depth 1 --filter=blob:none --sparse \
		-b $(FRAMEWORK_VERSION) \
		https://github.com/dynatrace-wwse/codespaces-framework.git \
		$(CACHE) 2>/dev/null
	@cd $(CACHE) && git sparse-checkout set --no-cone \
		'.devcontainer/util/*' \
		'.devcontainer/p10k/*' \
		'.devcontainer/test/*' \
		'.devcontainer/apps/*' \
		'/.devcontainer/Makefile' \
		'/.devcontainer/makefile.sh' \
		'.devcontainer/runlocal/*' \
		'/.devcontainer/Dockerfile' \
		'/.devcontainer/entrypoint.sh' \
		'.devcontainer/yaml/*'
	@touch $(CACHE)/.complete
	@# Write a wrapper that sources makefile.sh safely in cache mode:
	@# - strips top-level calls to getRepositoryName/getDockerEnvsFromEnvFile
	@# - sets ENV_FILE and RepositoryName to the repo's paths
	@# - re-sources helper.sh and calls getDockerEnvsFromEnvFile
	@printf '#!/bin/bash\n\
export ENV_FILE="$(CURDIR)/.env"\n\
export RepositoryName="$(REPO_NAME)"\n\
_MAKEFILE_DIR="$$(cd "$$(dirname "$${BASH_SOURCE[0]}")" && pwd)"\n\
eval "$$(sed "/^getRepositoryName$$/d; /^getDockerEnvsFromEnvFile$$/d" "$${_MAKEFILE_DIR}/makefile.sh")"\n\
export ENV_FILE="$(CURDIR)/.env"\n\
export RepositoryName="$(REPO_NAME)"\n\
VOLUMEMOUNTS="-v /var/run/docker.sock:/var/run/docker.sock -v /lib/modules:/lib/modules -v $(REPO_ROOT):/workspaces/$(REPO_NAME)"\n\
WORKINGDIR="-w /workspaces/$(REPO_NAME)"\n\
source "$${_MAKEFILE_DIR}/runlocal/helper.sh"\n\
getDockerEnvsFromEnvFile\n' > $(CACHE)/.devcontainer/cached_makefile.sh
	@echo "Framework v$(FRAMEWORK_VERSION) cached."

start: $(CACHE)/.complete
	@cd $(CACHE)/.devcontainer && bash -c 'source cached_makefile.sh; start'

build: $(CACHE)/.complete
	@cd $(CACHE)/.devcontainer && bash -c 'source cached_makefile.sh; build'

build-nocache: $(CACHE)/.complete
	@cd $(CACHE)/.devcontainer && bash -c 'source cached_makefile.sh; buildNoCache'

buildx: $(CACHE)/.complete
	@cd $(CACHE)/.devcontainer && bash -c 'source cached_makefile.sh; buildx'

integration: $(CACHE)/.complete
	@cd $(CACHE)/.devcontainer && bash -c 'source cached_makefile.sh; integration'

clean-cache:
	@rm -rf .cache/dt-framework
	@echo "Framework cache cleared."

clean-start: clean-cache
	@docker kill $$(docker ps -q) 2>/dev/null; docker rm $$(docker ps -aq) 2>/dev/null; true
	@echo "Containers removed."
	@$(MAKE) start
