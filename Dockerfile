# =============================================================================
#                              Andre Essing
# -----------------------------------------------------------------------------
# Developer.......: Andre Essing (https://www.andre-essing.de/)
#                                (https://github.com/aessing)
# -----------------------------------------------------------------------------
# File............: Dockerfile
# Summary......---: This dockerfile describes a container image for a 
#                   Minecraft Bedrock Server
# Part of.........: Minecraft Bedrock Server on Docker
# -----------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# =============================================================================



###############################################################################
#
# Get the base Linux image
#
FROM ubuntu:latest
ARG ARCH=amd64



###############################################################################
#
# Set parameters
#

# SETUP ENVS FOR BEDROCK SERVER
ENV SERVER_NAME='Dedicated Server'
ENV LEVEL_NAME='Bedrock level'
ENV LEVEL_TYPE='DEFAULT'
ENV LEVEL_SEED=''
ENV GAMEMODE='survival'
ENV DIFFICULTY='easy'
ENV ALLOW_CHEATS='false'
ENV MAX_PLAYERS='10'
ENV ONLINE_MODE='true'
ENV WHITE_LIST='false'
ENV DEFAULT_PLAYER_PERMISSION_LEVEL='member'
ENV PLAYER_IDLE_TIMEOUT='30'
ENV VIEW_DISTANCE='32'
ENV TICK_DISTANCE='4'
ENV MAX_THREADS='8'
ENV TEXTUREPACK_REQUIRED='false'
ENV CONTENT_LOG_FILE='false'
ENV COMPRESSION_THRESHOLD='1'
ENV SERVER_AUTHORITATIVE_MOVEMENT='true'
ENV PLAYER_MOVEMENT_SCORE_THRESHOLD='20'
ENV PLAYER_MOVEMENT_DISTANCE_THRESHOLD='0.3'
ENV PLAYER_MOVEMENT_DURATION_THRESHOLD='500'
ENV CORRECT_PLAYER_MOVEMENT='false'

# SETUP PATH ENVS
ENV SERVER_PATH='/srv/bedrock-server'
ENV CONFIG_PATH='/srv/bedrock-config'
ENV DATA_PATH='/srv/minecraft'
ARG DOWNLOAD_URL='https://www.minecraft.net/en-us/download/server/bedrock'

# TELL THE OS IT IS HEADLESS
ENV DEBIAN_FRONTEND=noninteractive 

# EXPOSE PORTS
EXPOSE 19132/udp
EXPOSE 19133/udp

# SET MOUNTPOINT
VOLUME ${DATA_PATH}



###############################################################################
#
# Update Linux and install necessary packages
#

# UPDATE LINUX
RUN apt-get update -y
RUN apt-get install --no-install-recommends -y apt-utils 
RUN apt-get upgrade -y

# INSTALL PACKAGESc
RUN apt-get install --no-install-recommends -y unzip curl libcurl4 libssl1.1 ca-certificates

# CLEAN UP
RUN apt autoremove -y
RUN apt autoclean -y

# INSTALL LATEST MINECRAFT BEDROCK SERVER
RUN curl $(curl ${DOWNLOAD_URL} | grep -Eoi '<a [^>]+>' | grep -i bin-linux | grep -Eo 'href="[^\"]+"' | grep -Eo '(http|https)://[a-zA-Z0-9./?=_%:-]*') --output ${SERVER_PATH}.zip
RUN unzip ${SERVER_PATH}.zip -d ${SERVER_PATH}
RUN rm ${SERVER_PATH}.zip



###############################################################################
#
# Copy files
#

# COPY MINECRAFT SERVER CONFIG
COPY container-files/server.properties ${CONFIG_PATH}/server.properties
COPY container-files/permissions.json ${CONFIG_PATH}/permissions.json
COPY container-files/whitelist.json ${CONFIG_PATH}/whitelist.json
COPY container-files/invalid_known_packs.json ${CONFIG_PATH}/invalid_known_packs.json
COPY container-files/valid_known_packs.json ${CONFIG_PATH}/valid_known_packs.json

# COPY STARTUP SCRIPT
COPY container-files/startup.sh ${CONFIG_PATH}/startup.sh
RUN chmod a+x ${CONFIG_PATH}/startup.sh



###############################################################################
#
# Start Bedrock Server
#
WORKDIR ${CONFIG_PATH}
ENTRYPOINT [ "./startup.sh" ]



###############################################################################
#EOF