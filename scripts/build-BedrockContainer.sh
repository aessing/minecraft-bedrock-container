#! /bin/bash

# =============================================================================
#                              Andre Essing
# -----------------------------------------------------------------------------
# Developer.......: Andre Essing (https://www.andre-essing.de/)
#                                (https://github.com/aessing)
# -----------------------------------------------------------------------------
# File............: build-BedrockContainer.sh
# Summary.........: This shell script builds the container from my GitHub Repo
# Part of.........: Minecraft Bedrock Server on Docker
# -----------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# =============================================================================

###############################################################################
#
# Strict mode, fail on any error
#
set -eo pipefail

on_error() {
    set +e
    echo "There was an error, the script was stopped" >&2
    echo "Error at line $1"
    exit 1
}

###############################################################################
#
# Print some help
#
usage() {
    echo ""
    echo "Usage: $0 [-v <version number>] [-l]"
    echo "-h | --help ............................: Show this help."
    echo "-v | --version .........................: Sets the version number that will be used to tag the new container image"
    echo "-l | --latest ..........................: Sets the tag \"latest\" on new container image"
    echo ""
}

###############################################################################
#
# Grabing arguments from script call
#
while [ "${1:-}" != "" ]; do
    case "$1" in
        "-h" | "--help")
            usage
            exit
            ;;
        "-v" | "--version")
            VERSION_TAG=$2
            ;;
        "-l" | "--latest")
            LATEST_TAG="true"
            ;;
        -* | --*)
            echo ""
            echo "Parameter $1 is not valid."
            usage
            exit 1
            ;;
    esac
    shift
done

###############################################################################
#
# Build the container from GitHub repository
#
docker build https://github.com/aessing/minecraft-bedrock-container.git --tag aessing/minecraft-bedrock

###############################################################################
#
# Tag the container with version and latest tags
#
if [ "$VERSION_TAG" ]; then
    eval "docker tag aessing/minecraft-bedrock aessing/minecraft-bedrock:$VERSION_TAG"
else
    eval "docker tag aessing/minecraft-bedrock aessing/minecraft-bedrock:$(date +%s)"
fi

if [ "$LATEST_TAG" ]; then
    eval "docker tag aessing/minecraft-bedrock aessing/minecraft-bedrock:latest"
fi

###############################################################################
#EOF