#! /bin/bash

# =============================================================================
#                              Andre Essing
# -----------------------------------------------------------------------------
# Developer.......: Andre Essing (https://www.andre-essing.de/)
#                                (https://github.com/aessing)
# -----------------------------------------------------------------------------
# File............: create-BedrockContainer.sh
# Summary.........: This shell script creates and runs a container with
#                   Minecraft Bedrock Server
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
    echo "Usage: $0 -s <server-name> -p <server-port> -l <level-name> [-t <level-type>] [-d difficulty>] [...]"
    echo "-h | --help ............................: Show this help."
    echo "-v | --volume ..........................: Sets the path, where the Minecraft container should store the world data."
    echo "                                          The name of the container will automatically be added to the path"
    echo "                                              - Allowed values: Any path on the system"
    echo "                                              - Default value: /srv/minecraft/<CONTAINER_NAME>"
    echo "-s | --server-name (required) ..........: Used as the server name."
    echo "                                              - Allowed values: Any string"
    echo "                                              - Default value: Dedicated Server"
    echo "-p | --server-port: (required) .........: Which IPv4 port the server should listen to."
    echo "                                              - Allowed values: Integers in the range [1, 65535]"
    echo "                                              - Default value: 19132"
    echo "-6 | --server-portv6 (recommended) .....: Which IPv6 port the server should listen to."
    echo "                                              - If you not specify an IPv6 port, the script will use IPv4 port + 1"
    echo "                                              - Allowed values: Integers in the range [1, 65535]"
    echo "                                              - Default value: 19133"
    echo "-l | --level-name (required) ...........: Used as name of the world"
    echo "                                              - Allowed values: Any string"
    echo "                                              - Default value: Bedrock level"
    echo "-t | --level-type ......................: Choose which kind of world you want to play in"
    echo "                                              - Allowed values: \"FLAT\", \"LEGACY\", \"DEFAULT\""
    echo "                                              - Default value: DEFAULT"
    echo "--level-seed ...........................: Use to randomize the world"
    echo "                                              - Allowed values: Any string"
    echo "                                              - Default value:"
    echo "-g | --game-mode .......................: Sets the game mode for new players."
    echo "                                              - Allowed values: \"survival\", \"creative\", or \"adventure\""
    echo "                                              - Default value: survival"
    echo "-d | --difficulty ......................: Sets the difficulty of the world."
    echo "                                              - Allowed values: \"peaceful\", \"easy\", \"normal\", or \"hard\""
    echo "                                              - Default value: easy"
    echo "--allow-cheats .........................: If true then cheats like commands can be used."
    echo "                                              - Allowed values: \"true\" or \"false\""
    echo "                                              - Default value: false"
    echo "--max-players ..........................: The maximum number of players that can play on the server."
    echo "                                              - Allowed values: Any positive integer"
    echo "                                              - Default value: 10"
    echo "-o | --online-mode .....................: If true then all connected players must be authenticated to Xbox Live. Clients connecting"
    echo "                                          to remote (non-LAN) servers will always require Xbox Live authentication regardless of"
    echo "                                          this setting. If the server accepts connections from the Internet, then it's highly"
    echo "                                          recommended to enable online-mode."
    echo "                                              - Allowed values: \"true\" or \"false\""
    echo "                                              - Default value: true"
    echo "-w | --whitelist .......................: If true then all connected players must be listed in the separate whitelist.json file."
    echo "                                              - Allowed values: \"true\" or \"false\""
    echo "                                              - Default value: false"
    echo "--default-player-permission-level ......: Permission level for new players joining for the first time."
    echo "                                              - Allowed values: \"visitor\", \"member\", \"operator\""
    echo "                                              - Default value: member"
    echo "--player-idle-timeout ..................: After a player has idled for this many minutes they will be kicked. If set to 0 then players"
    echo "                                          can idle indefinitely."
    echo "                                              - Allowed values: Any positive integer"
    echo "                                              - Default value: 30"
    echo "--view-distance ........................: The maximum allowed view distance in number of chunks."
    echo "                                              - Allowed values: Any positive integer"
    echo "                                              - Default value: 32"
    echo "--tick-distance ........................: The world will be ticked this many chunks away from any player."
    echo "                                              - Allowed values: Integers in the range [4, 12]"
    echo "                                              - Default value: 4"
    echo "--max-threads ..........................: Maximum number of threads the server will try to use. If set to 0 or removed then it will use"
    echo "                                          as many as possible."
    echo "                                              - Allowed values: Any positive integer"
    echo "                                              - Default value: 8"
    echo "--texturepack-required .................: Force clients to use texture packs in the current world"
    echo "                                              - Allowed values: \"true\" or \"false\""
    echo "                                              - Default value: false"
    echo "--content-log-file .....................: Enables logging content errors to a file"
    echo "                                              - Allowed values: \"true\" or \"false\""
    echo "                                              - Default value: false"
    echo "--compression-threshold ................: Determines the smallest size of raw network payload to compress."
    echo "                                              - Allowed values: Integers in the range [1, 65535]"
    echo "                                              - Default value: 1"
    echo "--server-authoritative-movement ........: Enables server authoritative movement. If true, the server will replay local user input on"
    echo "                                          the server and send down corrections when the client's position doesn't match the server's."
    echo "                                          Corrections will only happen if correct-player-movement is set to true."
    echo "                                              - Allowed values: \"true\" or \"false\""
    echo "                                              - Default value: true"
    echo "--player-movement-score-threshold ......: The number of incongruent time intervals needed before abnormal behavior is reported."
    echo "                                              - Disabled by server-authoritative-movement."
    echo "                                              - Default value: 20"
    echo "--player-movement-distance-threshold ...: The difference between server and client positions that needs to be exceeded before abnormal"
    echo "                                          behavior is detected."
    echo "                                              - Disabled by server-authoritative-movement."
    echo "                                              - Default value: 0.3"
    echo "--player-movement-duration-threshold ...: The duration of time the server and client positions can be out of sync (as defined by"
    echo "                                          player-movement-distance-threshold) before the abnormal movement score is incremented."
    echo "                                          This value is defined in milliseconds."
    echo "                                              - Disabled by server-authoritative-movement."
    echo "                                              - Default value: 500"
    echo "--correct-player-movement ..............: If true, the client position will get corrected to the server position if the movement"
    echo "                                          score exceeds the threshold."
    echo "                                              - Allowed values: \"true\" or \"false\""
    echo "                                              - Default value: false"
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
        "-s" | "--server-name")
            SERVER_NAME=$2
            ;;
        "-p" | "--server-port")
            SERVER_PORT=$2
            ;;
        "-6" | "--server-portv6")
            SERVER_PORTv6=$2
            ;;
        "-l" | "--level-name")
            LEVEL_NAME=$2
            ;;
        "-t" | "--level-type")
            LEVEL_TYPE=$2
            ;;
        "--level-seed")
            LEVEL_SEED=$2
            ;;
        "-g" | "--game-mode")
            GAMEMODE=$2
            ;;
        "-d" | "--difficulty")
            DIFFICULTY=$2
            ;;
        "--allow-cheats")
            ALLOW_CHEATS=$2
            ;;
        "--max-players")
            MAX_PLAYERS=$2
            ;;
        "-o" | "--online-mode")
            ONLINE_MODE=$2
            ;;
        "-w" | "--whitelist")
            WHITE_LIST=$2
            ;;
        "--default-player-permission-level")
            DEFAULT_PLAYER_PERMISSION_LEVEL=$2
            ;;
        "--player-idle-timeout")
            PLAYER_IDLE_TIMEOUT=$2
            ;;
        "--view-distance")
            VIEW_DISTANCE=$2
            ;;
        "--tick-distance")
            TICK_DISTANCE=$2
            ;;
        "--max-threads")
            MAX_THREADS=$2
            ;;
        "--texturepack-required")
            TEXTUREPACK_REQUIRED=$2
            ;;
        "--content-log-file")
            CONTENT_LOG_FILE=$2
            ;;
        "--compression-threshold")
            COMPRESSION_THRESHOLD=$2
            ;;
        "--server-authoritative-movement")
            SERVER_AUTHORITATIVE_MOVEMENT=$2
            ;;
        "--player-movement-score-threshold")
            PLAYER_MOVEMENT_SCORE_THRESHOLD=$2
            ;;
        "--player-movement-distance-threshold")
            PLAYER_MOVEMENT_DISTANCE_THRESHOLD=$2
            ;;
        "--player-movement-duration-threshold")
            PLAYER_MOVEMENT_DURATION_THRESHOLD=$2
            ;;
        "--correct-player-movement")
            CORRECT_PLAYER_MOVEMENT=$2
            ;;
        "-v" | "--volume")
            VOLUME=$2
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
# Set some default docker run options for Bedrock server
#
DOCKER_OPTS="-d -i -t"

# SET CONTAINER AUTORESTART
DOCKER_OPTS="$DOCKER_OPTS --restart='unless-stopped'"

###############################################################################
#
# Set user input parameters for docker run
#
if [ "$LEVEL_NAME" ]; then
    CONTAINER_NAME=$(echo $LEVEL_NAME | sed -e 's/ /_/g')
    DOCKER_OPTS="$DOCKER_OPTS --name='$CONTAINER_NAME'"
    DOCKER_OPTS="$DOCKER_OPTS -e LEVEL_NAME='$LEVEL_NAME'"
else
    echo ""
    echo "ERROR: A level name (-l | --level-name) argumemnt has to be set - Please re-run the script with a name for your world." >&2
    usage
    exit 1
fi

if [ "$SERVER_NAME" ]; then
    DOCKER_OPTS="$DOCKER_OPTS -e SERVER_NAME='$SERVER_NAME - $LEVEL_NAME'"
else
    echo ""
    echo "ERROR: A server name (-s | --server-name) has to be set - Please re-run the script and define a server name." >&2
    usage
    exit 1
fi

if [ "$SERVER_PORT" ]; then
    if [[ $SERVER_PORT =~ ^[0-9]+$ ]] && [[ $SERVER_PORT -ge 1 ]] && [[ $SERVER_PORT -le 65535 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -p $SERVER_PORT:19132/udp"
    else
        echo ""
        echo "ERROR: --server-port is not a valid number." >&2
        usage
        exit 1
    fi
else
    echo ""
    echo "ERROR: A server port (-p | --server-port) has to be set - Please re-run the script with a port on which the server can be reached." >&2
    usage
    exit 1
fi

if [ "$SERVER_PORTv6" ]; then
    if [[ $SERVER_PORTv6 =~ ^[0-9]+$ ]] && [[ $SERVER_PORTv6 -ge 1 ]] && [[ $SERVER_PORTv6 -le 65535 ]] && [[ $SERVER_PORTv6 -ne $SERVER_PORT ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -p $SERVER_PORTv6:19133/udp"
    else
        echo ""
        echo "ERROR: --server-portv6 is not a valid number." >&2
        usage
        exit 1
    fi
else
    DOCKER_OPTS="$DOCKER_OPTS -p $(echo $SERVER_PORT+1 | bc):19133/udp"
fi

if [ "$LEVEL_TYPE" ]; then
    LEVEL_TYPE=${LEVEL_TYPE^^}
    if [[ $LEVEL_TYPE == "FLAT" ]] || [[ $LEVEL_TYPE == "LEGACY" ]] || [[ $LEVEL_TYPE == "DEFAULT" ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e LEVEL_TYPE='$LEVEL_TYPE'"
    else
        echo ""
        echo "ERROR: --level-type has an invalid value." >&2
        usage
        exit 1
    fi
fi

if [ "$LEVEL_SEED" ]; then
    DOCKER_OPTS="$DOCKER_OPTS -e LEVEL_SEED='$LEVEL_SEED'"
fi

if [ "$GAMEMODE" ]; then
    GAMEMODE=${GAMEMODE,,}
    if [[ $GAMEMODE == "survival" ]] || [[ $GAMEMODE == "creative" ]] || [[ $GAMEMODE == "adventure" ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e GAMEMODE='$GAMEMODE'"
    else
        echo ""
        echo "ERROR: --game-mode has an invalid value." >&2
        usage
        exit 1
    fi
fi

if [ "$DIFFICULTY" ]; then
    DIFFICULTY=${DIFFICULTY,,}
    if [[ $DIFFICULTY == "peaceful" ]] || [[ $DIFFICULTY == "easy" ]] || [[ $DIFFICULTY == "normal" ]] || [[ $DIFFICULTY == "hard" ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e DIFFICULTY='$DIFFICULTY'"
    else
        echo ""
        echo "ERROR: --difficulty has an invalid value." >&2
        usage
        exit 1
    fi
fi

if [ "$ALLOW_CHEATS" ]; then
    ALLOW_CHEATS=${ALLOW_CHEATS,,}
    if [[ $ALLOW_CHEATS == true ]] || [[ $ALLOW_CHEATS == false ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e ALLOW_CHEATS='$ALLOW_CHEATS'"
    else
        echo ""
        echo "ERROR: --allow-cheats has to be true or false." >&2
        usage
        exit 1
    fi
fi

if [ "$MAX_PLAYERS" ]; then
    if [[ $MAX_PLAYERS =~ ^[0-9]+$ ]] && [[ $MAX_PLAYERS -ge 1 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e MAX_PLAYERS='$MAX_PLAYERS'"
    else
        echo ""
        echo "ERROR: --max-players is not a valid number." >&2
        usage
        exit 1
    fi
fi

if [ "$ONLINE_MODE" ]; then
    ONLINE_MODE=${ONLINE_MODE,,}
    if [[ $ONLINE_MODE == true ]] || [[ $ONLINE_MODE == false ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e ONLINE_MODE='$ONLINE_MODE'"
    else
        echo ""
        echo "ERROR: --online-mode has to be true or false." >&2
        usage
        exit 1
    fi
fi

if [ "$WHITE_LIST" ]; then
    WHITE_LIST=${WHITE_LIST,,}
    if [[ $WHITE_LIST == true ]] || [[ $WHITE_LIST == false ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e WHITE_LIST='$WHITE_LIST'"
    else
        echo ""
        echo "ERROR: --whitelist has to be true or false." >&2
        usage
        exit 1
    fi
fi

if [ "$DEFAULT_PLAYER_PERMISSION_LEVEL" ]; then
    DEFAULT_PLAYER_PERMISSION_LEVEL=${DEFAULT_PLAYER_PERMISSION_LEVEL,,}
    if [[ $DEFAULT_PLAYER_PERMISSION_LEVEL == "visitor" ]] || [[ $DEFAULT_PLAYER_PERMISSION_LEVEL == "member" ]] || [[ $DEFAULT_PLAYER_PERMISSION_LEVEL == "operator" ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e DEFAULT_PLAYER_PERMISSION_LEVEL='$DEFAULT_PLAYER_PERMISSION_LEVEL'"
    else
        echo ""
        echo "ERROR: --default-player-permission-level  has an invalid value." >&2
        usage
        exit 1
    fi
fi

if [ "$PLAYER_IDLE_TIMEOUT" ]; then
    if [[ $PLAYER_IDLE_TIMEOUT =~ ^[0-9]+$ ]] && [[ $PLAYER_IDLE_TIMEOUT -ge 1 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e PLAYER_IDLE_TIMEOUT='$PLAYER_IDLE_TIMEOUT'"
    else
        echo ""
        echo "ERROR: --player-idle-timeout is not a valid number." >&2
        usage
        exit 1
    fi
fi

if [ "$VIEW_DISTANCE" ]; then
    if [[ $VIEW_DISTANCE =~ ^[0-9]+$ ]] && [[ $VIEW_DISTANCE -ge 1 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e VIEW_DISTANCE='$VIEW_DISTANCE'"
    else
        echo ""
        echo "ERROR: --view-distance is not a valid number." >&2
        usage
        exit 1
    fi
fi

if [ "$TICK_DISTANCE" ]; then
    if [[ $TICK_DISTANCE =~ ^[0-9]+$ ]] && [[ $TICK_DISTANCE -ge 4 ]] && [[ $TICK_DISTANCE -le 12 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e TICK_DISTANCE='$TICK_DISTANCE'"
    else
        echo ""
        echo "ERROR: --tick-distance is not a valid number." >&2
        usage
        exit 1
    fi
fi

if [ "$MAX_THREADS" ]; then
    if [[ $MAX_THREADS =~ ^[0-9]+$ ]] && [[ $MAX_THREADS -ge 1 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e MAX_THREADS='$MAX_THREADS'"
    else
        echo ""
        echo "ERROR: --max-threads is not a valid number." >&2
        usage
        exit 1
    fi
fi

if [ "$TEXTUREPACK_REQUIRED" ]; then
    TEXTUREPACK_REQUIRED=${TEXTUREPACK_REQUIRED,,}
    if [[ $TEXTUREPACK_REQUIRED == true ]] || [[ $TEXTUREPACK_REQUIRED == false ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e TEXTUREPACK_REQUIRED='$TEXTUREPACK_REQUIRED'"
    else
        echo ""
        echo "ERROR: --texturepack-required has to be true or false." >&2
        usage
        exit 1
    fi
fi

if [ "$CONTENT_LOG_FILE" ]; then
    CONTENT_LOG_FILE=${CONTENT_LOG_FILE,,}
    if [[ $CONTENT_LOG_FILE == true ]] || [[ $CONTENT_LOG_FILE == false ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e CONTENT_LOG_FILE='$CONTENT_LOG_FILE'"
    else
        echo ""
        echo "ERROR: --content-log-file has to be true or false." >&2
        usage
        exit 1
    fi
fi

if [ "$COMPRESSION_THRESHOLD" ]; then
    if [[ $COMPRESSION_THRESHOLD =~ ^[0-9]+$ ]] && [[ $COMPRESSION_THRESHOLD -ge 1 ]] && [[ $COMPRESSION_THRESHOLD -le 65535 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e COMPRESSION_THRESHOLD='$COMPRESSION_THRESHOLD'"
    else
        echo ""
        echo "ERROR: --compression-threshold is not a valid number." >&2
        usage
        exit 1
    fi
fi

if [ "$SERVER_AUTHORITATIVE_MOVEMENT" ]; then
    SERVER_AUTHORITATIVE_MOVEMENT=${SERVER_AUTHORITATIVE_MOVEMENT,,}
    if [[ $SERVER_AUTHORITATIVE_MOVEMENT == true ]] || [[ $SERVER_AUTHORITATIVE_MOVEMENT == false ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e SERVER_AUTHORITATIVE_MOVEMENT='$SERVER_AUTHORITATIVE_MOVEMENT'"
    else
        echo ""
        echo "ERROR: --server-authoritative-movement has to be true or false." >&2
        usage
        exit 1
    fi
fi

if [ "$PLAYER_MOVEMENT_SCORE_THRESHOLD" ]; then
    if [[ $PLAYER_MOVEMENT_SCORE_THRESHOLD =~ ^[0-9]+$ ]] && [[ $PLAYER_MOVEMENT_SCORE_THRESHOLD -ge 1 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e PLAYER_MOVEMENT_SCORE_THRESHOLD='$PLAYER_MOVEMENT_SCORE_THRESHOLD'"
    else
        echo ""
        echo "ERROR: --player-movement-score-threshold is not a valid number." >&2
        usage
        exit 1
    fi
fi

if [ "$PLAYER_MOVEMENT_DISTANCE_THRESHOLD" ]; then
    if [[ $PLAYER_MOVEMENT_DISTANCE_THRESHOLD =~ ^[0-9]+(\.[0-9]+)?$ ]] && [[ ${PLAYER_MOVEMENT_DISTANCE_THRESHOLD%%.*} -ge 0 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e PLAYER_MOVEMENT_DISTANCE_THRESHOLD='$PLAYER_MOVEMENT_DISTANCE_THRESHOLD'"
    else
        echo ""
        echo "ERROR: --player-movement-distance-threshold is not a valid number." >&2
        usage
        exit 1
    fi
fi

if [ "$PLAYER_MOVEMENT_DURATION_THRESHOLD" ]; then
    if [[ $PLAYER_MOVEMENT_DURATION_THRESHOLD =~ ^[0-9]+$ ]] && [[ $PLAYER_MOVEMENT_DURATION_THRESHOLD -ge 1 ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e PLAYER_MOVEMENT_DURATION_THRESHOLD='$PLAYER_MOVEMENT_DURATION_THRESHOLD'"
    else
        echo ""
        echo "ERROR: --player-movement-duration-threshold is not a valid number." >&2
        usage
        exit 1
    fi
fi

if [ "$CORRECT_PLAYER_MOVEMENT" ]; then
    CORRECT_PLAYER_MOVEMENT=${CORRECT_PLAYER_MOVEMENT,,}
    if [[ $CORRECT_PLAYER_MOVEMENT == true ]] || [[ $CORRECT_PLAYER_MOVEMENT == false ]]; then
        DOCKER_OPTS="$DOCKER_OPTS -e CORRECT_PLAYER_MOVEMENT='$CORRECT_PLAYER_MOVEMENT'"
    else
        echo ""
        echo "ERROR: --correct-player-movement has to be true or false." >&2
        usage
        exit 1
    fi
fi

if [ "$VOLUME" ]; then
    if [[ "$VOLUME" = /* ]]; then
        mkdir -p "$VOLUME/$CONTAINER_NAME"
        DOCKER_OPTS="$DOCKER_OPTS -v '$VOLUME/$CONTAINER_NAME:/srv/minecraft'"
    else
        echo ""
        echo "ERROR: --volume has to be a fully qualified path like '/srv/minecraft'." >&2
        echo "       Or if you don't specify a path, a docker volume will be used. " >&2
        usage
        exit 1
    fi
else
    if ! [ "$( docker volume inspect -f '{{ .Name }}' $CONTAINER_NAME 2> /dev/null )" == "$CONTAINER_NAME" ]; then
        docker volume create $CONTAINER_NAME > /dev/null
    fi
    DOCKER_OPTS="$DOCKER_OPTS -v '$CONTAINER_NAME:/srv/minecraft'"
fi

###############################################################################
#
# Run the docker image
#
eval "docker run $DOCKER_OPTS aessing/minecraft-bedrock:latest"

###############################################################################
#EOF