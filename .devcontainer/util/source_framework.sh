#!/bin/bash
# Versioned framework pull mechanism
# sync push-update updates the FRAMEWORK_VERSION line only.
#
# Two modes:
#   DEV MODE:   Local functions.sh exists -> source directly (for codespaces-framework development)
#   CACHE MODE: No local files -> two-tier cache (host cache -> container cache -> git clone)
#
# Two-tier cache:
#   HOST_CACHE:      $REPO_PATH/.devcontainer/.cache/dt-framework/<version>/
#                    Lives inside the volume-mounted repo dir -> persists across container rebuilds
#   CONTAINER_CACHE: $HOME/.cache/dt-framework/<version>/
#                    Local to the container -> fast access, lost on container rebuild

# Framework version pin — sync push-update updates this line
FRAMEWORK_VERSION="${FRAMEWORK_VERSION:-v1.3.1}"

REPO_PATH="$(pwd)"
RepositoryName="$(basename "$REPO_PATH")"

# -- DEV MODE: local files exist -> source directly, no cache --
if [ -f "${REPO_PATH}/.devcontainer/util/functions.sh" ]; then
  FRAMEWORK_CACHE=""
  FRAMEWORK_APPS_PATH="${REPO_PATH}/.devcontainer/apps"
  export FRAMEWORK_VERSION REPO_PATH RepositoryName FRAMEWORK_CACHE FRAMEWORK_APPS_PATH

  source "${REPO_PATH}/.devcontainer/util/functions.sh"
  return 0 2>/dev/null || exit 0
fi

# -- CACHE MODE: enablement repo (no local framework files) --
HOST_CACHE="${REPO_PATH}/.devcontainer/.cache/dt-framework/${FRAMEWORK_VERSION}"
CONTAINER_CACHE="${HOME}/.cache/dt-framework/${FRAMEWORK_VERSION}"
FRAMEWORK_CACHE="${CONTAINER_CACHE}"
FRAMEWORK_APPS_PATH="${FRAMEWORK_CACHE}/.devcontainer/apps"
export FRAMEWORK_VERSION REPO_PATH RepositoryName FRAMEWORK_CACHE FRAMEWORK_APPS_PATH

# Tier 1: Container cache exists -> use it directly
if [ -f "${CONTAINER_CACHE}/.complete" ]; then
  source "${FRAMEWORK_CACHE}/.devcontainer/util/functions.sh"
  return 0 2>/dev/null || exit 0
fi

# Tier 2: Host cache exists -> copy to container cache
if [ -f "${HOST_CACHE}/.complete" ]; then
  echo "Copying framework v${FRAMEWORK_VERSION} from host cache..."
  mkdir -p "${CONTAINER_CACHE}"
  cp -a "${HOST_CACHE}/." "${CONTAINER_CACHE}/"
  source "${FRAMEWORK_CACHE}/.devcontainer/util/functions.sh"
  return 0 2>/dev/null || exit 0
fi

# Tier 3: Neither cache exists -> git clone into host cache, then copy to container cache
echo "Pulling framework v${FRAMEWORK_VERSION}..."
if ! (
  mkdir -p "$(dirname "${HOST_CACHE}")" && \
  git clone --depth 1 --filter=blob:none --sparse \
    -b "${FRAMEWORK_VERSION}" \
    https://github.com/dynatrace-wwse/codespaces-framework.git \
    "${HOST_CACHE}" 2>/dev/null && \
  cd "${HOST_CACHE}" && \
  git sparse-checkout set --no-cone \
    '.devcontainer/util/*' \
    '.devcontainer/p10k/*' \
    '/.devcontainer/test/test_functions.sh' \
    '.devcontainer/apps/*' \
    '/.devcontainer/Makefile' \
    '/.devcontainer/makefile.sh' \
    '.devcontainer/runlocal/*' \
    '/.devcontainer/Dockerfile' \
    '/.devcontainer/entrypoint.sh' \
    '.devcontainer/yaml/*' && \
  touch "${HOST_CACHE}/.complete"
); then
  echo "Failed to pull framework v${FRAMEWORK_VERSION} -- check network and retry"
  return 1 2>/dev/null || exit 1
fi

# Copy host cache to container cache
mkdir -p "${CONTAINER_CACHE}"
cp -a "${HOST_CACHE}/." "${CONTAINER_CACHE}/"

source "${FRAMEWORK_CACHE}/.devcontainer/util/functions.sh"
