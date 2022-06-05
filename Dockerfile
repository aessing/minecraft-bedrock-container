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
FROM --platform=amd64 almalinux/9-base:latest

###############################################################################
# Set some information
LABEL tag="aessing/minecraft-bedrock" \
      description="A Minecraft Bedrock server in a Docker container. Your personal Minecraft realm at home." \
      disclaimer="THE CONTENT OF THIS REPOSITORY IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE CONTENT OF THIS REPOSITORY OR THE USE OR OTHER DEALINGS BY CONTENT OF THIS REPOSITORY." \
      vendor="Andre Essing" \
      github-repo="https://github.com/aessing/minecraft-bedrock-container"

###############################################################################
# Set parameters
ENV ALLOW_CHEATS='false' \
    ALLOW_LIST='false' \
    COMPRESSION_THRESHOLD='1' \
    CONTENT_LOG_FILE='false' \
    CORRECT_PLAYER_MOVEMENT='false' \
    DEFAULT_PLAYER_PERMISSION_LEVEL='member' \
    DIFFICULTY='easy' \
    EMIT_SERVER_TELEMETRY='false' \
    EULA='false' \
    FORCE_GAMEMODE='false' \
    GAMEMODE='survival' \
    LEVEL_NAME='Bedrock level' \
    LEVEL_SEED='' \
    LEVEL_TYPE='DEFAULT' \
    MAX_PLAYERS='10' \
    MAX_THREADS='8' \
    ONLINE_MODE='true' \
    PLAYER_IDLE_TIMEOUT='30' \
    PLAYER_MOVEMENT_DISTANCE_THRESHOLD='0.3' \
    PLAYER_MOVEMENT_DURATION_THRESHOLD='500' \
    PLAYER_MOVEMENT_SCORE_THRESHOLD='20' \
    SERVER_AUTHORITATIVE_BLOCK_BREAKING='false' \
    SERVER_AUTHORITATIVE_MOVEMENT='server-auth' \
    SERVER_NAME='Dedicated Server' \
    SERVER_PORT='19132' \
    SERVER_PORTv6='19133' \
    TEXTUREPACK_REQUIRED='false' \
    TICK_DISTANCE='4' \
    VIEW_DISTANCE='32' \
    CONFIG_PATH='/srv/bedrock-config' \
    DATA_PATH='/srv/minecraft' \
    SERVER_PATH='/srv/bedrock-server'
ARG UIDGID='10999' \
    USERGROUPNAME='minecraft'
EXPOSE ${SERVER_PORT}/udp \
       ${SERVER_PORTv6}/udp
VOLUME ${DATA_PATH}

###############################################################################
# Install Minecraft Bedrock Sevrer and necessary packages
RUN dnf upgrade -y \
    && dnf install -y compat-openssl11 jq libnsl unzip \
    && dnf clean all -y \
    && mkdir -p ${SERVER_PATH} ${CONFIG_PATH} ${DATA_PATH}

###############################################################################
# Copy files
COPY container-files/* ${CONFIG_PATH}/ 
RUN chmod a+x ${CONFIG_PATH}/entrypoint.sh

###############################################################################
# Run in non-root context
RUN groupadd -g ${UIDGID} -r ${USERGROUPNAME} \
    && useradd --no-log-init -g ${USERGROUPNAME} -r -s /bin/false -u ${UIDGID} ${USERGROUPNAME} \
    && chown -R ${USERGROUPNAME}.${USERGROUPNAME} ${SERVER_PATH} ${CONFIG_PATH} ${DATA_PATH}
USER ${USERGROUPNAME}

###############################################################################
# Start Bedrock Server
WORKDIR ${CONFIG_PATH}
ENTRYPOINT [ "./entrypoint.sh" ]

###############################################################################
#EOF