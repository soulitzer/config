#!/bin/bash

HOME_DIR=$HOME
BASE_DIR=$HOME/local
INSTALL_DIR=$HOME/local/install
PATH_EXPORTS_DIR=$HOME/local/install/.local_path_exports
LDLIB_EXPORTS_DIR=$HOME/local/install/.local_ldlib_exports

echo "source $BASE_DIR/.local_bashrc" >> $HOME_DIR/.bashrc
echo "source $BASE_DIR/.local_vimrc" >> $HOME_DIR/.vimrc

mkdir -p $INSTALL_DIR
touch $PATH_EXPORTS_DIR
touch $LDLIB_EXPORTS_DIR

sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive TZ=America/New_York apt-get install -y --no-install-recommends \
   build-essential \
   ca-certificates \
   ccache \
   cmake \
   curl \
   libjpeg-dev \
   libpng-dev \
   vim \
   wget

curl -fSL -o $INSTALL_DIR/miniconda.sh -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x $INSTALL_DIR/miniconda.sh && \
    $INSTALL_DIR/miniconda.sh -b -p $INSTALL_DIR/miniconda3 && \
    rm $INSTALL_DIR/miniconda.sh

$INSTALL_DIR/miniconda3/bin/conda init bash
