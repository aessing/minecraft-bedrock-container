#! /bin/bash

# =============================================================================
#                              Andre Essing
# -----------------------------------------------------------------------------
# Developer.......: Andre Essing (https://twitter.com/aessing)
#                                (https://www.linkedin.com/in/aessing/)
# -----------------------------------------------------------------------------
# File............: build-BedrockContainer.sh
# Summary.........: This shell script builds the container from my GitHub Repo
# Part of.........: Minecraft on Docker
# Date............: 07.05.2020
# Version.........: 1.1.0
# OS Version......: Ubuntu Linux
# Bedrock Version.: 1.14.60.5
# -----------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# -----------------------------------------------------------------------------
# Changes:
# DD.MM.YYYY    Developer       Version     Reason
# 07.05.2020    Andre Essing    1.0.0       Initial Release
# 08.05.2020    Andre Essing    1.1.0       Enhanced Options
# =============================================================================



###############################################################################
#
# Build the container from GitHub repository
#
docker build https://github.com/aessing/minecraft-bedrock.git --tag aessing/minecraft-bedrock



###############################################################################
#
# Tag the container with version and latest tags
#
docker tag aessing/minecraft-bedrock aessing/minecraft-bedrock:1.1.0
docker tag aessing/minecraft-bedrock aessing/minecraft-bedrock:latest



###############################################################################
#EOF