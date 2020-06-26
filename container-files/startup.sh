#! /bin/bash

# =============================================================================
#                              Andre Essing
# -----------------------------------------------------------------------------
# Developer.......: Andre Essing (https://www.andre-essing.de/)
#                                (https://github.com/aessing)
# -----------------------------------------------------------------------------
# File............: startup.sh
# Summary.........: This shell script prepares the container and startes the 
#                   Minecraft Bedrock Server
# Part of.........: Minecraft Bedrock Server on Docker
# -----------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# =============================================================================



###############################################################################
#
# Prepare the container image for running bedrock server and move important
# files out of the server directory so it can be stored on the docker server
#

# CREATE NECESSARY DIRECTORIES
mkdir -p "${DATA_PATH}/worlds"
mkdir -p "${DATA_PATH}/premium_cache"
mkdir -p "${DATA_PATH}/world_templates"

# COPY EXISTING PACKS FROM SERVER INSTALL TO THE CUSTOM PATH
cp -r "${SERVER_PATH}/resource_packs" "${DATA_PATH}/"
cp -r "${SERVER_PATH}/behavior_packs" "${DATA_PATH}/"

# COPY CONFIG TEMPLATES IF CONFIGURATION FILES DOES NOT EXIST
if ! [ -f "${DATA_PATH}/server.properties" ]; then
    cp "${CONFIG_PATH}/server.properties" "${DATA_PATH}/server.properties"
fi

if ! [ -f "${DATA_PATH}/permissions.json" ]; then
    cp "${CONFIG_PATH}/permissions.json" "${DATA_PATH}/permissions.json"
fi

if ! [ -f "${DATA_PATH}/whitelist.json" ]; then
    cp "${CONFIG_PATH}/whitelist.json" "${DATA_PATH}/whitelist.json"
fi

if ! [ -f "${DATA_PATH}/invalid_known_packs.json" ]; then
    cp "${CONFIG_PATH}/invalid_known_packs.json" "${DATA_PATH}/invalid_known_packs.json"
fi

if ! [ -f "${DATA_PATH}/valid_known_packs.json" ]; then
    cp "${CONFIG_PATH}/valid_known_packs.json" "${DATA_PATH}/valid_known_packs.json"
fi



###############################################################################
#
# Change the server.properties file with parameters from docker container
# ONLY AT FIRST RUN
#
if ! [ -f "${DATA_PATH}/first_run_done" ]; then
    sed -i -e "s/server-name=Dedicated Server/server-name=$SERVER_NAME/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/gamemode=survival/gamemode=$GAMEMODE/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/difficulty=easy/difficulty=$DIFFICULTY/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/allow-cheats=false/allow-cheats=$ALLOW_CHEATS/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/max-players=10/max-players=$MAX_PLAYERS/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/online-mode=true/online-mode=$ONLINE_MODE/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/white-list=false/white-list=$WHITE_LIST/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/view-distance=32/view-distance=$VIEW_DISTANCE/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/tick-distance=4/tick-distance=$TICK_DISTANCE/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/player-idle-timeout=30/player-idle-timeout=$PLAYER_IDLE_TIMEOUT/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/max-threads=8/max-threads=$MAX_THREADS/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/level-type=DEFAULT/level-type=$LEVEL_TYPE/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/level-name=Bedrock level/level-name=$LEVEL_NAME/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/level-seed=/level-seed=$LEVEL_SEED/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/default-player-permission-level=member/default-player-permission-level=$DEFAULT_PLAYER_PERMISSION_LEVEL/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/texturepack-required=false/texturepack-required=$TEXTUREPACK_REQUIRED/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/content-log-file-enabled=false/content-log-file-enabled=$CONTENT_LOG_FILE/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/compression-threshold=1/compression-threshold=$COMPRESSION_THRESHOLD/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/server-authoritative-movement=true/server-authoritative-movement=$SERVER_AUTHORITATIVE_MOVEMENT/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/player-movement-score-threshold=20/player-movement-score-threshold=$PLAYER_MOVEMENT_SCORE_THRESHOLD/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/player-movement-distance-threshold=0.3/player-movement-distance-threshold=$PLAYER_MOVEMENT_DISTANCE_THRESHOLD/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/player-movement-duration-threshold-in-ms=500/player-movement-duration-threshold-in-ms=$PLAYER_MOVEMENT_DURATION_THRESHOLD/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/correct-player-movement=false/correct-player-movement=$CORRECT_PLAYER_MOVEMENT/g" "${DATA_PATH}/server.properties"
    touch ${DATA_PATH}/first_run_done
fi


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
ln -s "${DATA_PATH}/worlds" "${SERVER_PATH}/worlds"
ln -s "${DATA_PATH}/resource_packs" "${SERVER_PATH}/resource_packs"
ln -s "${DATA_PATH}/behavior_packs" "${SERVER_PATH}/behavior_packs"
ln -s "${DATA_PATH}/premium_cache" "${SERVER_PATH}/premium_cache"
ln -s "${DATA_PATH}/world_templates" "${SERVER_PATH}/world_templates"
ln -s "${DATA_PATH}/server.properties" "${SERVER_PATH}/server.properties"
ln -s "${DATA_PATH}/permissions.json" "${SERVER_PATH}/permissions.json"
ln -s "${DATA_PATH}/whitelist.json" "${SERVER_PATH}/whitelist.json"
ln -s "${DATA_PATH}/valid_known_packs.json" "${SERVER_PATH}/valid_known_packs.json"
ln -s "${DATA_PATH}/invalid_known_packs.json" "${SERVER_PATH}/invalid_known_packs.json"



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