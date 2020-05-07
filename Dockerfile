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
# Get the base Linux image
#

# GRAB LATEST UBUNTU RELEASE
FROM ubuntu:latest



###############################################################################
#
# Set some parameters
#

# SETUP ENVS FOR BEDROCK SERVER
ENV SERVER='Dedicated Server'
ENV WORLD='level'
ENV MODE='survival'
ENV DIFFICULTY='easy'
ENV PORTv4=19132
ENV PORTv6=19133

# SETUP SOME PATH ENVS
ENV MINECRAFT_PATH='/srv/minecraft'
ENV SERVER_PATH='/srv/bedrock-server'
ENV CONFIG_PATH='/srv/bedrock-config'
ARG INSTALL_URL='https://minecraft.azureedge.net/bin-linux/bedrock-server-1.14.60.5.zip'

# TELL THE OS IT IS HEADLESS
ENV DEBIAN_FRONTEND=noninteractive 

# EXPOSE SOME PORTS
EXPOSE ${PORTv4}/udp
EXPOSE ${PORTv6}/udp

# SET MOUNTPOINT
VOLUME ${MINECRAFT_PATH}



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