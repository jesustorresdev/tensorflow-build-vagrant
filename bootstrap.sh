#!/bin/bash
#
# Vagrant provisioning script.
#
# Build Tensorflow
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/g3doc/get_started/os_setup.md
#

set -e

CUDA_REPO_URL=http://developer.download.nvidia.com/compute/cuda/repos/
CUDA_PKG=cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
CUDNN_PKG=cudnn-8.0-linux-x64-v6.0.tgz
TENSORFLOW_VERSION=1.3

. /etc/lsb-release
DISTRIB_ARCH=$(arch)

# Add repositories for dependencies

## Java
sudo add-apt-repository -y ppa:webupd8team/java
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections

## Bazel
echo "deb http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://storage.googleapis.com/bazel-apt/doc/apt-key.pub.gpg | sudo apt-key add -

## CUDA
curl "$CUDA_REPO_URL/${DISTRIB_ID,,}${DISTRIB_RELEASE//.}/${DISTRIB_ARCH}/$CUDA_PKG" -o "$CUDA_PKG"
sudo dpkg -i "$CUDA_PKG"

# Install dependencies
sudo apt-get update
sudo apt-get install -y --allow-unauthenticated oracle-java8-installer bazel python3-numpy swig python3-dev python3-setuptools python3-wheel libcurl3-dev cuda-8.0

# Install cuDNN
sudo ln -fs /usr/local/cuda-8.0 /usr/local/cuda
sudo tar zxvf "/vagrant/$CUDNN_PKG" -C /usr/local --no-same-owner

# Build Tensorflow
if [ ! -e "$HOME/tensorflow" ]; then
  git clone https://github.com/tensorflow/tensorflow "$HOME/tensorflow" -b "r$TENSORFLOW_VERSION"
fi

cd "$HOME/tensorflow"
source /vagrant/build-tensorflow.sh

