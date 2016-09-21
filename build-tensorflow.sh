#!/bin/bash
#
# Vagrant provisioning script.
#
# Build Tensorflow
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/g3doc/get_started/os_setup.md
#

set -e

CUDA_PKG=cuda-repo-ubuntu1504_7.5-18_amd64.deb
CUDNN_PKG=cudnn-7.5-linux-x64-v5.0-ga.tgz
TENSORFLOW_VERSION=0.9

# Add repositories for dependencies

## Java
sudo add-apt-repository -y ppa:webupd8team/java
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections

## Bazel
echo "deb http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://storage.googleapis.com/bazel-apt/doc/apt-key.pub.gpg | sudo apt-key add -

## CUDA
curl "http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1504/x86_64/$CUDA_PKG" -o "$CUDA_PKG"
sudo dpkg -i "$CUDA_PKG"

# Install dependencies
sudo apt-get update
sudo apt-get install -y oracle-java8-installer bazel python3-numpy swig python3-dev python3-setuptools python3-wheel libcurl3-dev cuda

# cuDNN
sudo tar zxvf "/vagrant/$CUDNN_PKG" -C /usr/local --no-same-owner

# Tensorflow
if [ ! -e "$HOME/tensorflow" ]; then
  git clone https://github.com/tensorflow/tensorflow "$HOME/tensorflow" -b "r$TENSORFLOW_VERSION"
fi

cd "$HOME/tensorflow"
PYTHON_BIN_PATH=/usr/bin/python3 \
TF_NEED_CUDA=1 \
TF_CUDA_VERSION=7.5 \
TF_CUDNN_VERSION=5 \
TF_CUDA_COMPUTE_CAPABILITIES=3.0 \
TF_UNOFFICIAL_SETTING=1 ./configure <<-EOF
EOF

# Build pip package
bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package --spawn_strategy=standalone  --verbose_failures
bazel-bin/tensorflow/tools/pip_package/build_pip_package /vagrant/tensorflow_pkg

