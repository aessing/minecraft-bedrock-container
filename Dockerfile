# =============================================================================
#                              Andre Essing
# -----------------------------------------------------------------------------
# Developer.......: Andre Essing (https://twitter.com/aessing)
#                                (https://www.linkedin.com/in/aessing/)
# -----------------------------------------------------------------------------
# File............: Dockerfile
# Summary......---: This dockerfile describes a container image for a 
#                   Minecraft Bedrock Server
# Part of.........: Minecraft on Docker
# Date............: 07.05.2020
# Version.........: 1.1.0
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
# 08.05.2020    Andre Essing    1.1.0       Enhanced Options
# =============================================================================

###############################################################################
#
# Get the base Linux image
#

# GRAB LATEST UBUNTU RELEASE
FROM ubuntu:latest



###############################################################################
#
# Set some parameters
#

# SETUP ENVS FOR BEDROCK SERVER
ENV SERVER_NAME='Dedicated Server'
ENV SERVER_PORTv4='19132'
ENV SERVER_PORTv6='19133'
ENV LEVEL_NAME='level'
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

# SETUP SOME PATH ENVS
ENV SERVER_PATH='/srv/bedrock-server'
ENV CONFIG_PATH='/srv/bedrock-config'
ENV DATA_PATH='/srv/minecraft'
ARG INSTALL_URL='https://minecraft.azureedge.net/bin-linux/bedrock-server-1.14.60.5.zip'

# TELL THE OS IT IS HEADLESS
ENV DEBIAN_FRONTEND=noninteractive 

# EXPOSE SOME PORTS
EXPOSE ${SERVER_PORTv4}/udp
EXPOSE ${SERVER_PORTv6}/udp

# SET MOUNTPOINT
VOLUME ${DATA_PATH}



###############################################################################
#
# Update Linux and install some necessary packages
#

# UPDATE LINUX
RUN apt-get update -y
RUN apt-get install -y apt-utils
RUN apt-get dist-upgrade -y

# INSTALL SOME PACKAGES
RUN apt-get install -y unzip curl libcurl4 libssl1.1

# CLEAN UP
RUN apt autoremove -y
RUN apt autoclean -y

# INSTALL MINECRAFT BEDROCK SERVER
RUN curl ${INSTALL_URL} --output ${SERVER_PATH}.zip
RUN unzip ${SERVER_PATH}.zip -d ${SERVER_PATH}
RUN rm ${SERVER_PATH}.zip



###############################################################################
#
# Copy some files
#

# COPY MINECRAFT SERVER CONFIG
COPY server.properties ${CONFIG_PATH}/server.properties
COPY permissions.json ${CONFIG_PATH}/permissions.json
COPY whitelist.json ${CONFIG_PATH}/whitelist.json

# COPY STARTUP SCRIPT
COPY startup.sh ${CONFIG_PATH}/startup.sh
RUN chmod a+x ${CONFIG_PATH}/startup.sh



###############################################################################
#
# Start Bedrock Server
#
WORKDIR ${CONFIG_PATH}
ENTRYPOINT [ "./startup.sh" ]



###############################################################################
#EOF