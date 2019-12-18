# =-=-==-=-=-=-  INSTRUCTIONS  =-=-==-=-=-=-
# To build the image:
# docker build -f ./Dockerfile_Quartus_v181 . --network=host -t quartus181

# To run the image:
# Command from: https://www.reddit.com/r/FPGA/comments/6t9z0a/running_quartus_prime_inside_docker/
# docker run -it --rm --net=host -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -v /etc/machine-id:/etc/machine-id quartus181
# =-=-==-=-=-=-=-=-=-=-=-=-=-=-=-==-=-==-=-

#FROM ubuntu_base:latest
FROM ubuntu:latest
MAINTAINER Dwaine P Garden <DwaineGarden@rogers.com>

# =-=-==-=-=-=-  COPY THE INSTALLATION FILES  =-=-==-=-=-=-
# To install quartus we need the installer files. 
# They are so large, that they have not been added to the repository. 
# One can download them and storem them in the folder with the
# Docker_files, so that they will be copied and run into the docker image.

# ADD home/QuartusSetup-17.1.0.590-linux.run home/cyclone-17.1.0.590.qdz /tmp/
RUN cd /tmp && \
    apt-get -qq update && \
    apt-get -qq -y install wget git && \
    cd /usr/src && \
    git clone https://github.com/MiSTer-devel/Main_MiSTer.git && \
    wget http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/QuartusSetup-17.1.0.590-linux.run && \
    wget http://download.altera.com/akdlm/software/acdsinst/17.1std/590/ib_installers/cyclone-17.1.0.590.qdz
    

# Change rights so that the user can run it
RUN cd /tmp && \
    chmod +x *.run && \
    chmod +r *

# =-=-==-=-=-=-  RUN INSTALLATION FILE  =-=-==-=-=-=-
# Install as the user (Not sure if this absolutely required, but just in case)
# If the root can also install it, then no need to copy the file, access it from a host shared folder

USER root
RUN  /tmp/QuartusSetup-17.1.0.590-linux.run --mode unattended --accept_eula 1

# =-=-==-=-=-=-  REMOVE FILES TO SAVE IMAGE SPACE  =-=-==-=-=-=-
# Do not forget to clean up to save some storage space

USER root
RUN    rm /home/developer/intelFPGA/17.1/uninstall -rf &&\
       apt-get clean &&\
       rm /tmp/QuartusSetup-17.1.0.590-linux.run

# =-=-==-=-=-=-  SETUP ENV VARIABLES  =-=-==-=-=-=-
# Setup the required variables:

USER root
ENV    ALTERAPATH=/home/developer/intelFPGA/17.1                                     \
       ALTERAOCLSDKROOT=/home/developer/intelFPGA/17.1/hld                           \
       QUARTUS_ROOTDIR=/home/developer/intelFPGA/17.1/quartus                        \
       QUARTUS_ROOTDIR_OVERRIDE=/home/developer/intelFPGA/17.1/quartus               \
       QSYS_ROOTDIR=/home/developer/intelFPGA/17.1/quartus/sopc_builder/bin          \
       SOPC_KIT_NIOS2=/home/developer/intelFPGA/17.1/nios2eds                        \
       LD_LIBRARY_PATH=/home/developer/intelFPGA/17.1/quartus/linux64                \
       QUARTUS_64BIT=1                                                            \
       LM_LICENSE_FILE=1800@lxlicen01,1800@lxlicen02,1800@lxlicen03

# Setup the PATH:
RUN    echo "PATH=$PATH:/home/developer/intelFPGA/17.1/quartus/bin:/home/developer/intelFPGA/17.1/nios2eds/bin:/home/developer/intelFPGA/17.1/quartus" >> /home/developer/.bashrc &&\

#Some websites claim that these files conflict with the Ubuntu versions and cause random segfaults.
       cd /home/developer/intelFPGA/17.1/quartus/linux64 &&\
#      mv libstdc++.so libstdc++.so_ori &&\
       mv libstdc++.so.6 libstdc++.so.6_bak &&\
#      mv libccl_curl_drl.so libccl_curl_drl.so_bak &&\
       mv libcrypto.so.1.0.0 libcrypto.so.1.0.0_bak &&\
       mv libssl.so.1.0.0 libssl.so.1.0.0_bak &&\
       mv libcurl.so.4 libcurl.so.4_bak

# =-=-==-=-=-=-  INSTALL DEVICE LIBRARIES  =-=-==-=-=-=-
# Devices can not be installed from the CLI in version 18.1.
# They should be installed manually
# Run the docker as described at the beggining of the file. 
# Launch quartus tool and install the devices. 
# Don't forget to remove the file: cyclone-18.1.0.625.qdz once installed to save space!
 

# =-=-==-=-=-=-  REDUCE IMAGE SIZE  =-=-==-=-=-=-
# From: https://github.com/cdsteinkuehler/QuartusBuildVMs/blob/master/Jessie-Quartus-15.1.2/Dockerfile
# !!!-WARNING-!!!
# Flatten the resulting image or it will be GIGANTIC!
# Create a container from the image:
#   docker run <docker-image:big> /bin/true
#
# Find the container ID:
#   docker ps -a
#
# Get the docker-rebase script from here:
#   https://github.com/docbill/docker-scripts
#
# Rebase the big image to make it MUCH smaller:
#   docker-rebase <container-ID> <docker-image:little>
#
# Tag the image as needed:
#   docker tag <docker-image:little> <final-name:version>
# Or commit it:
#  docker commit <container-ID> <docker-image-name>
