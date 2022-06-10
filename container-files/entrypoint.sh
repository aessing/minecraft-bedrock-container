#!/bin/bash

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
# Set some variables
DOWNLOAD_URL='https://www.minecraft.net/en-us/download/server/bedrock'

###############################################################################
# Print header
echo ""
echo ""
echo "# ============================================================================="
echo "# Minecraft Bedrock Server startup script"
echo "# $(cat /etc/redhat-release)"
echo "# -----------------------------------------------------------------------------"
echo "# Developer.......: Andre Essing (https://www.andre-essing.de/)"
echo "#                                (https://github.com/aessing)"
echo "#                                (https://twitter.com/aessing)"
echo "#                                (https://www.linkedin.com/in/aessing/)"
echo "# -----------------------------------------------------------------------------"
echo "# THIS CODE AND INFORMATION ARE PROVIDED \"AS IS\" WITHOUT WARRANTY OF ANY KIND,"
echo "# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED"
echo "# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE."
echo "# ============================================================================="
echo ""

###############################################################################
# The EULA of Mojang has to be accepted, otherwise you can't use Minecraft Bedrocks Server
if [[ "${EULA^^}" != "TRUE" ]]; then
    echo ""
    echo "MOJANG MINECRAFT END USER LICENSE AGREEMENT"
    echo "-------------------------------------------------------------------------------------"
    echo "You must agree to the Minecraft End User License Agreement and Privacy Policy."
    echo "See https://account.mojang.com/terms & https://privacy.microsoft.com/privacystatement"
    echo
    echo "The environment variable EULA must be set to TRUE, to indicate your agreement with"
    echo "the Minecraft End User License Agreement."
    echo
    echo "The current value is '${EULA}'"
    echo "-------------------------------------------------------------------------------------"
    echo ""
    exit 1
fi

###############################################################################
# Install Minecraft if not exists
if ! [ -f "${SERVER_PATH}/bedrock_server" ]; then
    echo ""
    echo "- Minecraft Bedrock Server will be downloaded from ${DOWNLOAD_URL}"

    if [ -n "${MINECRAFT_VERSION}" ]; then
       if curl --head --silent --fail "https://minecraft.azureedge.net/bin-linux/bedrock-server-${MINECRAFT_VERSION}.zip" 2>&1 > /dev/null; then
            echo "- Installing Minecraft Bedrock Server version ${MINECRAFT_VERSION}"
            curl "https://minecraft.azureedge.net/bin-linux/bedrock-server-${MINECRAFT_VERSION}.zip" --output /tmp/bedrock.zip
        else
            echo ""
            echo "MINECRAFT VERSION DOES NOT EXIST ON DOWNLOAD SERVER"
            echo "--------------------------------------------------------------------------------"
            echo "This Minecraft Bedrocks Server version does not exist."
            echo "Please check https://minecraft.fandom.com/de/wiki/Bedrock_Dedicated_Server for "
            echo "available versions."
            echo "--------------------------------------------------------------------------------"
            echo ""
            exit 1
        fi
    else
        echo "- Installing latest Minecraft Bedrock Server version"
        curl $(curl --user-agent "aessing/minecraft-bedrock-container" --header "accept-language:*" "${DOWNLOAD_URL}" | grep -Eoi '<a [^>]+>' | grep -i bin-linux | grep -Eo 'href="[^\"]+"' | grep -Eo '(http|https)://[a-zA-Z0-9./?=_%:-]*') --output /tmp/bedrock.zip
    fi    
    
    unzip /tmp/bedrock.zip -d ${SERVER_PATH}
    chmod 755 ${SERVER_PATH}/bedrock_server
    rm /tmp/bedrock.zip
fi

###############################################################################
# Save and load the server- and level-name
if ! [ -f "${DATA_PATH}/names" ]; then
    echo ""
    echo "- Save and load the SERVER_NAME and LEVEL_NAME"
    echo "SERVER_NAME='$SERVER_NAME'" > "${DATA_PATH}/names"
    echo "LEVEL_NAME='$LEVEL_NAME'" >> "${DATA_PATH}/names"
else
    source "${DATA_PATH}/names"
fi

###############################################################################
# Prepare the container image for running bedrock server and move important
# files out of the server directory so it can be stored on the docker server

# CREATE NECESSARY DIRECTORIES
echo ""
echo "- Creating necessary directories if directories don't exist"
if ! [ -d "${DATA_PATH}/behavior_packs" ]; then
    mkdir -p "${DATA_PATH}/behavior_packs"
fi
if ! [ -d "${DATA_PATH}/resource_packs" ]; then
    mkdir -p "${DATA_PATH}/resource_packs"
fi
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
if ! [ -f "${CONFIG_PATH}/first_run_done" ]; then
    echo ""
    echo "- Copy / updating existing packs from server install to data path"
    cp -u -f -r "${SERVER_PATH}/resource_packs" "${DATA_PATH}"
    cp -u -f -r "${SERVER_PATH}/behavior_packs" "${DATA_PATH}"
fi

# COPY CONFIG TEMPLATES IF CONFIGURATION FILES DOES NOT EXIST
echo ""
echo "- Copy config templates if configuration files does not exist"
if ! [ -f "${DATA_PATH}/server.properties" ]; then
    cp "${SERVER_PATH}/server.properties" "${DATA_PATH}/server.properties"
fi
if ! [ -f "${DATA_PATH}/permissions.json" ]; then
    echo "[]" > "${DATA_PATH}/permissions.json"
fi
if ! [ -f "${DATA_PATH}/allowlist.json" ]; then
    echo "[]" > "${DATA_PATH}/allowlist.json"
fi
if ! [ -f "${DATA_PATH}/invalid_known_packs.json" ]; then
    echo "[]" > "${DATA_PATH}/invalid_known_packs.json"
fi
if ! [ -f "${DATA_PATH}/valid_known_packs.json" ]; then
    echo "[]" > "${DATA_PATH}/valid_known_packs.json"
fi

###############################################################################
# Link custom path folders and files into the server directory
if ! [ -f "${CONFIG_PATH}/first_run_done" ]; then
    echo ""
    echo "- Link custom path folders and files into the server directory"
    rm -rf "${DATA_PATH}/server.properties.mojang" && cp -f "${SERVER_PATH}/server.properties" "${DATA_PATH}/server.properties.mojang"
    rm -rf "${SERVER_PATH}/worlds" && ln -s "${DATA_PATH}/worlds" "${SERVER_PATH}/worlds"
    rm -rf "${SERVER_PATH}/resource_packs" && ln -s "${DATA_PATH}/resource_packs" "${SERVER_PATH}/resource_packs"
    rm -rf "${SERVER_PATH}/behavior_packs" && ln -s "${DATA_PATH}/behavior_packs" "${SERVER_PATH}/behavior_packs"
    rm -rf "${SERVER_PATH}/premium_cache" && ln -s "${DATA_PATH}/premium_cache" "${SERVER_PATH}/premium_cache"
    rm -rf "${SERVER_PATH}/world_templates" && ln -s "${DATA_PATH}/world_templates" "${SERVER_PATH}/world_templates"
    rm -f "${SERVER_PATH}/server.properties" && ln -s "${DATA_PATH}/server.properties" "${SERVER_PATH}/server.properties"
    rm -f "${SERVER_PATH}/permissions.json" && ln -s "${DATA_PATH}/permissions.json" "${SERVER_PATH}/permissions.json"
    rm -f "${SERVER_PATH}/allowlist.json" && ln -s "${DATA_PATH}/allowlist.json" "${SERVER_PATH}/allowlist.json"
    rm -f "${SERVER_PATH}/valid_known_packs.json" && ln -s "${DATA_PATH}/valid_known_packs.json" "${SERVER_PATH}/valid_known_packs.json"
    rm -f "${SERVER_PATH}/invalid_known_packs.json" && ln -s "${DATA_PATH}/invalid_known_packs.json" "${SERVER_PATH}/invalid_known_packs.json"
fi

###############################################################################
# Change the server.properties file with parameters from docker container
# Server- and level-name will only be set on first run of the container
echo ""
echo "- Set settings in server.properties"
cat > "${DATA_PATH}/server.properties" <<EOL
server-name=${SERVER_NAME}
level-name=${LEVEL_NAME}
gamemode=${GAMEMODE,,}
force-gamemode=${FORCE_GAMEMODE,,}
difficulty=${DIFFICULTY,,}
allow-cheats=${ALLOW_CHEATS,,}
max-players=${MAX_PLAYERS}
online-mode=${ONLINE_MODE,,}
allow-list=${ALLOW_LIST,,}
server-port=${SERVER_PORT}
server-portv6=${SERVER_PORTv6}
view-distance=${VIEW_DISTANCE}
tick-distance=${TICK_DISTANCE}
player-idle-timeout=${PLAYER_IDLE_TIMEOUT}
max-threads=${MAX_THREADS}
level-seed=${LEVEL_SEED}
default-player-permission-level=${DEFAULT_PLAYER_PERMISSION_LEVEL,,}
texturepack-required=${TEXTUREPACK_REQUIRED,,}
content-log-file-enabled=${CONTENT_LOG_FILE_ENABLED,,}
compression-threshold=${COMPRESSION_THRESHOLD}
server-authoritative-movement=${SERVER_AUTHORITATIVE_MOVEMENT,,}
player-movement-score-threshold=${PLAYER_MOVEMENT_SCORE_THRESHOLD}
player-movement-action-direction-threshold=${PLAYER_MOVEMENT_ACTION_DIRECTION_THRESHOLD}
player-movement-distance-threshold=${PLAYER_MOVEMENT_DISTANCE_THRESHOLD}
player-movement-duration-threshold-in-ms=${PLAYER_MOVEMENT_DURATION_THRESHOLD}
correct-player-movement=${CORRECT_PLAYER_MOVEMENT,,}
server-authoritative-block-breaking=${SERVER_AUTHORITATIVE_BLOCK_BREAKING,,}
level-type=${LEVEL_TYPE,,}
emit-server-telemetry=${EMIT_SERVER_TELEMETRY,,}
EOL

###############################################################################
# Build permissions and allowlist files
if [ -n "$PERMISSION_OPS_XUIDS" ] || [ -n "$PERMISSION_MEMBERS_XUIDS" ] || [ -n "$PERMISSION_VISITORS_XUIDS" ]; then
    echo ""
    echo "- Build permissions files"
    jq -n --arg ops "$PERMISSION_OPS_XUIDS" --arg members "$PERMISSION_MEMBERS_XUIDS" --arg visitors "$PERMISSION_VISITORS_XUIDS" '[
            [$ops      | split(",") | map({permission: "operator", xuid:.})],
            [$members  | split(",") | map({permission: "member", xuid:.})],
            [$visitors | split(",") | map({permission: "visitor", xuid:.})]
        ] | flatten' > "${DATA_PATH}/permissions.json"
fi
if [ -n "$ALLOWED_USER_GAMERTAGS" ]; then
    echo ""
    echo "- Build allowlist"
    jq -n --arg users "$ALLOWED_USER_GAMERTAGS" '[
            [$users | split(",") | map({"name":.})]
        ] | flatten' > "${DATA_PATH}/allowlist.json"
fi

###############################################################################
# Set status files that first configuration is done
if ! [ -f "${CONFIG_PATH}/first_run_done" ]; then
    echo ""
    echo "- Creating status files after first run"
    date > ${CONFIG_PATH}/first_run_done
fi

###############################################################################
# Get the party started and run Bedrock server
echo ""
echo "- Starting server: ${WORLD} on ${HOSTNAME}..."
cd ${SERVER_PATH}
export LD_LIBRARY_PATH=.
exec ./bedrock_server

###############################################################################
#EOF