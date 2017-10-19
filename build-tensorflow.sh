#!/bin/bash
#
# Build Tensorflow
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/g3doc/get_started/os_setup.md
#

set -ae

CC_OPT_FLAGS=-march=sandybridge
TF_CUDA_VERSION=8.0
TF_CUDNN_VERSION=6
TF_CUDA_COMPUTE_CAPABILITIES=3.0

PYTHON_BIN_PATH=/usr/bin/python3
PYTHON_LIB_PATH=/usr/lib/python3/dist-packages
TF_NEED_MKL=0
TF_NEED_JEMALLOC=1
TF_NEED_GCP=0
TF_NEED_HDFS=0
TF_ENABLE_XLA=0
TF_NEED_VERBS=0
TF_NEED_CUDA=1
TF_CUDA_CLANG=0
CUDA_TOOLKIT_PATH=/usr/local/cuda
GCC_HOST_COMPILER_PATH=/usr/bin/gcc
CUDNN_INSTALL_PATH=/usr/local/cuda
TF_NEED_OPENCL=0
TF_NEED_MPI=0

./configure

# Build pip package
bazel build --config=opt --config=cuda //tensorflow/tools/pip_package:build_pip_package --verbose_failures
bazel-bin/tensorflow/tools/pip_package/build_pip_package /vagrant/tensorflow_pkg

