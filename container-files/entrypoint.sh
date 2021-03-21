#! /bin/sh

# =============================================================================
# Minecraft Bedrock Server startup script
# Minecraft Bedrock Server Container
# https://github.com/aessing/minecraft-bedrock-container
# -----------------------------------------------------------------------------
# Developer.......: Andre Essing (https://www.andre-essing.de/)
#                                (https://github.com/aessing)
#                                (https://twitter.com/aessing)
#                                (https://www.linkedin.com/in/aessing/)
# -----------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# =============================================================================

set -eo pipefail

###############################################################################
# The EULA of Mojang has to be accepted, otherwise you can't use Minecraft Bedrocks Server
if [[ "${EULA^^}" != "TRUE" ]]; then
    echo
    echo "MOJANG MINECRAFT END USER LICENSE AGREEMENT"
    echo "-------------------------------------------------------------------------------------"
    echo "You must agree to the Minecraft End User License Agreement and Privacy Policy."
    echo "See https://account.mojang.com/terms & https://privacy.microsoft.com/privacystatement"
    echo
    echo "The Environment variable EULA must be set to TRUE, to indicate your agreement with"
    echo "the Minecraft End User License Agreement."
    echo
    echo "The current value is '${EULA}'"
    echo "-------------------------------------------------------------------------------------"
    echo
    exit 1
fi

###############################################################################
# Prepare the container image for running bedrock server and move important
# files out of the server directory so it can be stored on the docker server

# CREATE NECESSARY DIRECTORIES
if ! [ -d "${DATA_PATH}/worlds" ]; then
    mkdir -p "${DATA_PATH}/worlds"
fi
if ! [ -d "${DATA_PATH}/premium_cache" ]; then
    mkdir -p "${DATA_PATH}/premium_cache"
fi
if ! [ -d "${DATA_PATH}/world_templates" ]; then
    mkdir -p "${DATA_PATH}/world_templates"
fi

# COPY EXISTING PACKS FROM SERVER INSTALL TO THE DATA PATH
cp -u -f -r "${SERVER_PATH}/resource_packs" "${DATA_PATH}"
cp -u -f -r "${SERVER_PATH}/behavior_packs" "${DATA_PATH}"

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
# Change the server.properties file with parameters from docker container
# Server- and level-name will only be set on first run of the container
if ! [ -f "${DATA_PATH}/first_run_done" ]; then
    sed -i -e "s/server-name=.*/server-name=$SERVER_NAME/g" "${DATA_PATH}/server.properties"
    sed -i -e "s/level-name=.*/level-name=$LEVEL_NAME/g" "${DATA_PATH}/server.properties"
    touch ${DATA_PATH}/first_run_done
fi
sed -i -e "s/gamemode=.*/gamemode=$GAMEMODE/g" "${DATA_PATH}/server.properties"
sed -i -e "s/difficulty=.*/difficulty=$DIFFICULTY/g" "${DATA_PATH}/server.properties"
sed -i -e "s/allow-cheats=.*/allow-cheats=$ALLOW_CHEATS/g" "${DATA_PATH}/server.properties"
sed -i -e "s/max-players=.*/max-players=$MAX_PLAYERS/g" "${DATA_PATH}/server.properties"
sed -i -e "s/online-mode=.*/online-mode=$ONLINE_MODE/g" "${DATA_PATH}/server.properties"
sed -i -e "s/white-list=.*/white-list=$WHITE_LIST/g" "${DATA_PATH}/server.properties"
sed -i -e "s/server-port=.*/server-port=$SERVER_PORT/g" "${DATA_PATH}/server.properties"
sed -i -e "s/server-portv6=.*/server-portv6=$SERVER_PORTv6/g" "${DATA_PATH}/server.properties"
sed -i -e "s/view-distance=.*/view-distance=$VIEW_DISTANCE/g" "${DATA_PATH}/server.properties"
sed -i -e "s/tick-distance=.*/tick-distance=$TICK_DISTANCE/g" "${DATA_PATH}/server.properties"
sed -i -e "s/player-idle-timeout=.*/player-idle-timeout=$PLAYER_IDLE_TIMEOUT/g" "${DATA_PATH}/server.properties"
sed -i -e "s/max-threads=.*/max-threads=$MAX_THREADS/g" "${DATA_PATH}/server.properties"
sed -i -e "s/level-type=.*/level-type=$LEVEL_TYPE/g" "${DATA_PATH}/server.properties"
sed -i -e "s/level-seed=.*/level-seed=$LEVEL_SEED/g" "${DATA_PATH}/server.properties"
sed -i -e "s/default-player-permission-level=.*/default-player-permission-level=$DEFAULT_PLAYER_PERMISSION_LEVEL/g" "${DATA_PATH}/server.properties"
sed -i -e "s/texturepack-required=.*/texturepack-required=$TEXTUREPACK_REQUIRED/g" "${DATA_PATH}/server.properties"
sed -i -e "s/content-log-file-enabled=.*/content-log-file-enabled=$CONTENT_LOG_FILE/g" "${DATA_PATH}/server.properties"
sed -i -e "s/compression-threshold=.*/compression-threshold=$COMPRESSION_THRESHOLD/g" "${DATA_PATH}/server.properties"
sed -i -e "s/server-authoritative-movement=.*/server-authoritative-movement=$SERVER_AUTHORITATIVE_MOVEMENT/g" "${DATA_PATH}/server.properties"
sed -i -e "s/player-movement-score-threshold=.*/player-movement-score-threshold=$PLAYER_MOVEMENT_SCORE_THRESHOLD/g" "${DATA_PATH}/server.properties"
sed -i -e "s/player-movement-distance-threshold=.*/player-movement-distance-threshold=$PLAYER_MOVEMENT_DISTANCE_THRESHOLD/g" "${DATA_PATH}/server.properties"
sed -i -e "s/player-movement-duration-threshold-in-ms=.*/player-movement-duration-threshold-in-ms=$PLAYER_MOVEMENT_DURATION_THRESHOLD/g" "${DATA_PATH}/server.properties"
sed -i -e "s/correct-player-movement=.*/correct-player-movement=$CORRECT_PLAYER_MOVEMENT/g" "${DATA_PATH}/server.properties"

###############################################################################
# Link custom path folders and files into the server directory
rm -rf "${SERVER_PATH}/worlds" && ln -s "${DATA_PATH}/worlds" "${SERVER_PATH}/worlds"
rm -rf "${SERVER_PATH}/resource_packs" && ln -s "${DATA_PATH}/resource_packs" "${SERVER_PATH}/resource_packs"
rm -rf "${SERVER_PATH}/behavior_packs" && ln -s "${DATA_PATH}/behavior_packs" "${SERVER_PATH}/behavior_packs"
rm -rf "${SERVER_PATH}/premium_cache" && ln -s "${DATA_PATH}/premium_cache" "${SERVER_PATH}/premium_cache"
rm -rf "${SERVER_PATH}/world_templates" && ln -s "${DATA_PATH}/world_templates" "${SERVER_PATH}/world_templates"
rm -f "${SERVER_PATH}/server.properties" && ln -s "${DATA_PATH}/server.properties" "${SERVER_PATH}/server.properties"
rm -f "${SERVER_PATH}/permissions.json" && ln -s "${DATA_PATH}/permissions.json" "${SERVER_PATH}/permissions.json"
rm -f "${SERVER_PATH}/whitelist.json" && ln -s "${DATA_PATH}/whitelist.json" "${SERVER_PATH}/whitelist.json"
rm -f "${SERVER_PATH}/valid_known_packs.json" && ln -s "${DATA_PATH}/valid_known_packs.json" "${SERVER_PATH}/valid_known_packs.json"
rm -f "${SERVER_PATH}/invalid_known_packs.json" && ln -s "${DATA_PATH}/invalid_known_packs.json" "${SERVER_PATH}/invalid_known_packs.json"

###############################################################################
# Get the party started and run Bedrock server
echo "Starting server: ${WORLD} on ${HOSTNAME}..."
cd ${SERVER_PATH}
LD_LIBRARY_PATH=. ./bedrock_server

###############################################################################
#EOF