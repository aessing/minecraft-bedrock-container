#! /bin/bash

# =============================================================================
#                              Andre Essing
# -----------------------------------------------------------------------------
# Developer.......: Andre Essing (https://twitter.com/aessing)
#                                (https://www.linkedin.com/in/aessing/)
# -----------------------------------------------------------------------------
# File............: startup.sh
# Summary.........: This shell script prepares the container and startes the 
#                   Minecraft Bedrock Server
# Part of.........: Minecraft on Docker
# Date............: 07.05.2020
# Version.........: 1.0.0
# OS Version......: Ubuntu Linux
# Bedrock Version.: 1.14.60.5
# Note............: This Dockerfile is build from a GitHub Repository of 
#                   FirzenYogesh (Yogesh S) (https://github.com/FirzenYogesh)
#                   https://github.com/FirzenYogesh/minecraft-bedrock
# -----------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# -----------------------------------------------------------------------------
# Changes:
# DD.MM.YYYY    Developer       Version     Reason
# 07.05.2020    Andre Essing    1.0.0       Initial Release
# =============================================================================



###############################################################################
#
# Prepare the container image for running bedrock server and move important
# files out of the server directory so it can be stored on the docker server
#

# CREATE NECESSARY DIRECTORIES
mkdir -p "${MINECRAFT_PATH}/worlds"
mkdir -p "${MINECRAFT_PATH}/premium_cache"
mkdir -p "${MINECRAFT_PATH}/world_templates"

# COPY EXISTING PACKS FROM SERVER INSTALL TO THE CUSTOM PATH
cp -r "${SERVER_PATH}/resource_packs" "${MINECRAFT_PATH}/"
cp -r "${SERVER_PATH}/behavior_packs" "${MINECRAFT_PATH}/"

# CREATE SOME FILES IF THEY DO NOT EXIST
if ! [ -f "${MINECRAFT_PATH}/invalid_known_packs.json" ]; then
    echo "[]" > "${MINECRAFT_PATH}/invalid_known_packs.json"
fi

if ! [ -f "${MINECRAFT_PATH}/valid_known_packs.json" ]; then
    echo "[]" > "${MINECRAFT_PATH}/valid_known_packs.json"
fi

# COPY CONFIG TEMPLATES IF CONFIGURATION FILES DOES NOT EXIST
if ! [ -f "${MINECRAFT_PATH}/server.properties" ]; then
    cp "${CONFIG_PATH}/server.properties" "${MINECRAFT_PATH}/server.properties"
fi

if ! [ -f "${MINECRAFT_PATH}/permissions.json" ]; then
    cp "${CONFIG_PATH}/permissions.json" "${MINECRAFT_PATH}/permissions.json"
fi

if ! [ -f "${MINECRAFT_PATH}/whitelist.json" ]; then
    cp "${CONFIG_PATH}/whitelist.json" "${MINECRAFT_PATH}/whitelist.json"
fi



###############################################################################
#
# Change the server.properties file with parameters from docker container
#

# REPLACE SOME CONFIGURATION VALUES WITH DOCKER ENVIRONMNET PARAMETERS
sed -i -e "s/server-name=Dedicated Server/server-name=$SERVER/g" "${MINECRAFT_PATH}/server.properties"
sed -i -e "s/level-name=level/level-name=$WORLD/g" "${MINECRAFT_PATH}/server.properties"
sed -i -e "s/gamemode=survival/gamemode=$MODE/g" "${MINECRAFT_PATH}/server.properties"
sed -i -e "s/difficulty=easy/difficulty=$DIFFICULTY/g" "${MINECRAFT_PATH}/server.properties"
sed -i -e "s/server-port=19132/server-port=$PORTv4/g" "${MINECRAFT_PATH}/server.properties"
sed -i -e "s/server-portv6=19133/server-portv6=$PORTv6/g" "${MINECRAFT_PATH}/server.properties"



###############################################################################
#
# Link custom path folders and files into the server directory
#

# REMOVE EXISTING SERVER FOLDERS
rm -rf "${SERVER_PATH}/worlds"
rm -rf "${SERVER_PATH}/resource_packs"
rm -rf "${SERVER_PATH}/behavior_packs"
rm -rf "${SERVER_PATH}/premium_cache"
rm -rf "${SERVER_PATH}/world_templates"
rm -f "${SERVER_PATH}/server.properties"
rm -f "${SERVER_PATH}/permissions.json"
rm -f "${SERVER_PATH}/whitelist.json"
rm -f "${SERVER_PATH}/valid_known_packs.json"
rm -f "${SERVER_PATH}/invalid_known_packs.json"

# CREATE LINKS TO THE CUSTOM FILES AND FOLDERS
ln -s "${MINECRAFT_PATH}/worlds" "${SERVER_PATH}/worlds"
ln -s "${MINECRAFT_PATH}/resource_packs" "${SERVER_PATH}/resource_packs"
ln -s "${MINECRAFT_PATH}/behavior_packs" "${SERVER_PATH}/behavior_packs"
ln -s "${MINECRAFT_PATH}/premium_cache" "${SERVER_PATH}/premium_cache"
ln -s "${MINECRAFT_PATH}/world_templates" "${SERVER_PATH}/world_templates"
ln -s "${MINECRAFT_PATH}/server.properties" "${SERVER_PATH}/server.properties"
ln -s "${MINECRAFT_PATH}/permissions.json" "${SERVER_PATH}/permissions.json"
ln -s "${MINECRAFT_PATH}/whitelist.json" "${SERVER_PATH}/whitelist.json"
ln -s "${MINECRAFT_PATH}/valid_known_packs.json" "${SERVER_PATH}/valid_known_packs.json"
ln -s "${MINECRAFT_PATH}/invalid_known_packs.json" "${SERVER_PATH}/invalid_known_packs.json"



###############################################################################
#
# Get the party started and run the Bedrock server
#

# START MINECRAFT BEDROCK SERVER
echo "Starting server: ${WORLD} on ${HOSTNAME}:${PORTv4} ..."
cd ${SERVER_PATH}
LD_LIBRARY_PATH=. ./bedrock_server



###############################################################################
#EOF