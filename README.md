## Install Instructions
Basic setup:
```
sudo apt-get update && \
    sudo apt-get install -y git && \
    cd && \
    git clone -q https://github.com/soulitzer/config.git local && \
    cd local && \
    . ubuntu_install.sh && \
    mkdir -p $HOME/local/install/bin && \
    echo "export PATH=$HOME/local/install/bin:\$PATH" >> \
        $HOME/local/install/.local_path_exports && \
    source ~/.bashrc
```
 - Creates local and install directories and properly source bashrc, vimrc
 - Installs build-essential, ccache, cmake, curl, miniconda3

### SSH key + Github setup (and ghstack):
 - `ssh-keygen && cat $HOME/.ssh/id_rsa.pub`
 - https://github.com/settings/keys
 - `~/.gitconfig`
 - `~/.ghstackrc`(can be installed from source https://github.com/ezyang/ghstack)

```
[user]
    name = example
    email = email@domain.com
[core]
    editor = vim
```

### Temporary conda env:
```
conda create -y -n temp python=3.8 ninja && \
    conda activate temp
```
### VSCode:
```
sudo apt update && \
    sudo apt install -y software-properties-common apt-transport-https wget && \
    wget -q --no-check-certificate https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add - && \
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" && \
    sudo apt update && \
    sudo apt install -y code
```
After opening code (to copy settings + keybindings):
```
cp $HOME/local/.config/Code/User/* $HOME/.config/Code/User/
```

### gcc
Use `update-alternatives` to manage multiple versions

### nvcc
```
wget https://developer.download.nvidia.com/compute/cuda/11.2.0/local_installers/cuda_11.2.0_460.27.04_linux.run && \
    sh cuda_11.2.0_460.27.04_linux.run
```
 - Apt does not have nvidia-cuda-toolkit-11
 - So this installs via the runfile from: https://developer.nvidia.com/cuda-downloads

```
export CUDA_INSTALL_DIR=/usr/local/cuda-11.2

echo "export PATH=$CUDA_INSTALL_DIR/bin:\$PATH" \
        >> $HOME/local/install/.local_path_exports && \
    echo "$CUDA_INSTALL_DIR/lib64" \
        | sudo tee -a /etc/ld.so.conf.d/user.conf && \
    echo "export LD_LIBRARY_PATH=$CUDA_INSTALL_DIR/lib64:\$LD_LIBRARY_PATH" \
        >> $HOME/local/install/.local_ldlib_exports && \
    unset CUDA_INSTALL_DIR && \
    sudo ldconfig && \
    source ~/.bashrc

# Configure ccache for nvcc
/usr/sbin/update-ccache-symlinks && \
    sudo ln -s /usr/bin/ccache /usr/lib/ccache/nvcc
```

### Configure ccache
```
ccache -M 25Gi && \
    ccache -F 0
```
 - http://manpages.ubuntu.com/manpages/trusty/man1/ccache.1.html
 - Cache dir is `~/.ccache`, conf file `~/.ccache/ccache.conf`
 - When we install ccache through apt, setup is already done for gcc, g++ etc.
   in the `/usr/lib/ccache`

### A better linker
```
git clone https://github.com/llvm/llvm-project.git $HOME/local/install/llvm-project && \
    cd $HOME/local/install/llvm-project && \
    cmake -S llvm -B build -G Ninja \
        -DLLVM_ENABLE_PROJECTS="lld" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$HOME/local/install/llvm-project/bin && \
    cmake --build build && \
    ln -s $HOME/local/install/llvm-project/build/bin/ld.lld $HOME/local/install/bin/ld
```

### CuDNN
```
tar -xvzf ${CUDNN_FILE} && \
    export CUDA_INSTALL_DIR=/usr/local/cuda-11.2 && \
    sudo mv cuda/include/* $CUDA_INSTALL_DIR/include/ && \
    sudo mv cuda/lib64/* $CUDA_INSTALL_DIR/lib64 && \
    rm -rf cuda && \
    rm -rf ${CUDNN_FILE}
```

### OpenBLAS (with LAPACK)
```
sudo apt-get update && \
    sudo apt-get install -y gfortran && \
    git clone https://github.com/xianyi/OpenBLAS $HOME/local/install/openblas_tmp && \
    pushd $HOME/local/install/openblas_tmp && \
    make -j$(nproc) && \
    make PREFIX=$HOME/local/install/OpenBLAS install && \
    popd && \
    rm -rf $HOME/local/install/openblas_tmp && \
    echo "$HOME/local/install/OpenBLAS/lib" \
        | sudo tee -a /etc/ld.so.conf.d/user.conf && \
    echo "export LD_LIBRARY_PATH=$HOME/local/install/OpenBLAS/lib:\$LD_LIBRARY_PATH" \
        >> $HOME/local/install/.local_ldlib_exports && \
    sudo ldconfig && \
    source ~/.bashrc
```
 - Installs a Fortran compiler (required for LAPACK).
 - For ubuntu, ld.so.conf.d is used instead of exporting to LD_LIBRARY_PATH, but
   cmake reads from LD_LIBRARY_PATH.

### Replace keybindings and settings:
```
gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs" && \
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ \
        next-tab '<Primary>Tab' && \
    gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ \
        prev-tab '<Primary><Shift>Tab'
```
### Install PyTorch
```
export _current_profile=1

conda create -y -n pytorch${_current_profile} python=3.8 ninja && \
    conda activate pytorch${_current_profile} && \
    export PYTORCH_DIR=$HOME/local/pytorch${_current_profile} && \
    git clone https://github.com/pytorch/pytorch.git $PYTORCH_DIR && \
    cd $PYTORCH_DIR && \
    pip install -r requirements.txt && \
    git submodule update --init --recursive --jobs 0 && \
    git remote remove origin && \
    git remote add origin git@github.com:soulitzer/pytorch.git && \
    git remote add upstream https://github.com/pytorch/pytorch.git
```
 - This is ready to `mkbr`