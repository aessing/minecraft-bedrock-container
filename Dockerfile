# =============================================================================
# Dockerfile
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

###############################################################################
# Get the base Linux image
FROM amd64/ubuntu:latest

###############################################################################
# Set some information
LABEL tag="aessing/minecraft-bedrock" \
      description="A Minecraft Bedrock server in a Docker container. Your personal Minecraft realm at home." \
      disclaimer="THE CONTENT OF THIS REPOSITORY IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE CONTENT OF THIS REPOSITORY OR THE USE OR OTHER DEALINGS BY CONTENT OF THIS REPOSITORY." \
      vendor="Andre Essing" \
      github-repo="https://github.com/aessing/minecraft-bedrock-container"

###############################################################################
# Set parameters
ENV SERVER_NAME='Dedicated Server' \
    GAMEMODE='survival' \
    FORCE_GAMEMODE='false' \
    DIFFICULTY='easy' \
    ALLOW_CHEATS='false' \
    MAX_PLAYERS='10' \
    ONLINE_MODE='true' \
    WHITE_LIST='false' \
    SERVER_PORT='19132' \
    SERVER_PORTv6='19133' \
    VIEW_DISTANCE='32' \
    TICK_DISTANCE='4' \
    PLAYER_IDLE_TIMEOUT='30' \
    MAX_THREADS='8' \
    LEVEL_NAME='Bedrock level' \
    LEVEL_SEED='' \
    DEFAULT_PLAYER_PERMISSION_LEVEL='member' \
    TEXTUREPACK_REQUIRED='false' \
    CONTENT_LOG_FILE='false' \
    COMPRESSION_THRESHOLD='1' \
    SERVER_AUTHORITATIVE_MOVEMENT='server-auth' \
    PLAYER_MOVEMENT_SCORE_THRESHOLD='20' \
    PLAYER_MOVEMENT_DISTANCE_THRESHOLD='0.3' \
    PLAYER_MOVEMENT_DURATION_THRESHOLD='500' \
    CORRECT_PLAYER_MOVEMENT='false' \
    SERVER_AUTHORITATIVE_BLOCK_BREAKING='false' \
    LEVEL_TYPE='DEFAULT' \
    EULA='FALSE' \
    DEBIAN_FRONTEND='noninteractive' \
    SERVER_PATH='/srv/bedrock-server' \
    CONFIG_PATH='/srv/bedrock-config' \
    DATA_PATH='/srv/minecraft'
ARG DOWNLOAD_URL='https://www.minecraft.net/en-us/download/server/bedrock' \
    UIDGID='10999' \
    USERGROUPNAME='minecraft'
EXPOSE ${SERVER_PORT}/udp \
       ${SERVER_PORTv6}/udp
VOLUME ${DATA_PATH}

###############################################################################
# Install Minecraft Bedrock Sevrer and necessary packages
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        libcurl4 \
        libssl1.1 \
        unzip \
    && apt-get dist-upgrade -y \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${SERVER_PATH} \
    && mkdir -p ${CONFIG_PATH} \
    && mkdir -p ${DATA_PATH} \
    && curl $(curl --user-agent "aessing/minecraft-bedrock-container" --header "accept-language:*" "${DOWNLOAD_URL}" | grep -Eoi '<a [^>]+>' | grep -i bin-linux | grep -Eo 'href="[^\"]+"' | grep -Eo '(http|https)://[a-zA-Z0-9./?=_%:-]*') --output ${SERVER_PATH}.zip \
    && unzip ${SERVER_PATH}.zip -d ${SERVER_PATH} \
    && chmod 755 ${SERVER_PATH}/bedrock_server \
    && rm ${SERVER_PATH}.zip

###############################################################################
# Copy files
COPY container-files/* ${CONFIG_PATH}/ 
RUN chmod a+x ${CONFIG_PATH}/entrypoint.sh

###############################################################################
# Run in non-root context
RUN groupadd -g ${UIDGID} -r ${USERGROUPNAME} \
    && useradd --no-log-init -g ${USERGROUPNAME} -r -s /bin/false -u ${UIDGID} ${USERGROUPNAME} \
    && chown -R ${USERGROUPNAME}.${USERGROUPNAME} ${SERVER_PATH} \
    && chown -R ${USERGROUPNAME}.${USERGROUPNAME} ${CONFIG_PATH} \
    && chown -R ${USERGROUPNAME}.${USERGROUPNAME} ${DATA_PATH}
USER ${USERGROUPNAME}

###############################################################################
# Start Bedrock Server
WORKDIR ${CONFIG_PATH}
ENTRYPOINT [ "./entrypoint.sh" ]

###############################################################################
#EOF
