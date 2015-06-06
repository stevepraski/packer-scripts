#!/bin/bash
set -e

if [[ ! -n "$3" ]]; then
  echo "Usage: $0 box-name cookbook-directory recipe"
  echo "Example: $0 centos-6.5 ../../rails-box-cookbook rails-box-cookbook::default"
  exit $E_BADARGS
fi

SUPPORTED_BOXES=("centos-6.5" "ubuntu-12.04")

for box in ${SUPPORTED_BOXES[@]}; do
  if [[ $box =~ $1 ]]; then
    BOX_NAME=$box
    break
  fi
done

if [[ ! $BOX_NAME ]]; then
  echo "Unsupported box $1"
  echo "Supported Boxes: ${SUPPORTED_BOXES[@]}"
  exit $E_BADARGS
fi

COOKBOOK_DIR=$2
SRC_ROOT="../../${COOKBOOK_DIR}"

# check cookbook directory existance
if [[ ! -d $COOKBOOK_DIR ]]; then
  if [[ -d $SRC_ROOT ]]; then
      COOKBOOK_DIR=$SRC_ROOT
  else
    echo "Cannot find directory: ${COOKBOOK_DIR} or ${SRC_ROOT}"
    exit $E_BADARGS
  fi
fi

PACK_SCRIPT="repack_${BOX_NAME%-*}.json"
OPS_BOX_NAME="opscode-${BOX_NAME}"
RECIPE=$3

if [[ ! -d "${HOME}/.vagrant.d/boxes/${OPS_BOX_NAME}" ]]; then
  vagrant box add ${OPS_BOX_NAME} http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_${BOX_NAME}_chef-provisionerless.box
fi

# avoid relative path conversion using directory navigation
SCRIPT_DIR=`pwd`
cd $COOKBOOK_DIR
COOKBOOK_DIR=`pwd`
cd $SCRIPT_DIR

# setup working directory
WORK_DIR="vagrant-repack-working"
cd ../..
if [[ ! -d $WORK_DIR ]]; then
  mkdir $WORK_DIR
fi 
cd $WORK_DIR
PREP_DIR=`pwd`

# Cleanup existing vendoring
if [[ -d "berks-cookbooks" ]]; then
  rm -r berks-cookbooks
fi 

# Cleanup previous run
if [[ -d "output-virtualbox-ovf" ]]; then
  rm -r output-virtualbox-ovf
fi

# vendor
berks vendor -b ${COOKBOOK_DIR}/Berksfile

# pack
packer validate -var "origin_box_name=${OPS_BOX_NAME}" -var "recipe=${RECIPE}" ${SCRIPT_DIR}/${PACK_SCRIPT}
packer build -var "origin_box_name=${OPS_BOX_NAME}" -var "recipe=${RECIPE}" ${SCRIPT_DIR}/${PACK_SCRIPT}

# notify
echo "FINISHED: prepped box is ready at ${PREP_DIR}"
