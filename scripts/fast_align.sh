#!/bin/bash

set -e

# check if MGIZA_DIR is set and installed
if [ -z ${FASTALIGN_DIR} ]; then
  echo "Set the variable FASTALIGN_DIR"
  exit 1
fi

if [ ! -f ${FASTALIGN_DIR}/build/fast_align ]; then
  echo "Install fastalign, file ${FASTALIGN_DIR}/build/fast_align not found"
  exit 1
fi

source_path=$1
target_path=$2
source_name=${1##*/}
target_name=${2##*/}
direction=$3
resultHandle_path=$4

# create format used for fastalign
paste ${source_path} ${target_path} | sed -E 's/\t/ ||| /g' > ${resultHandle_path}/${source_name}_${target_name}
paste ${target_path} ${source_path} | sed -E 's/\t/ ||| /g' > ${resultHandle_path}/${target_name}_${source_name}

# remove lines which have an empty source or target
sed -e '/^ |||/d' -e '/||| $/d' ${resultHandle_path}/${source_name}_${target_name} > ${source_name}_${target_name}.clean
sed -e '/^ |||/d' -e '/||| $/d' ${resultHandle_path}/${target_name}_${source_name} > ${target_name}_${source_name}.clean

# align in both directions
${FASTALIGN_DIR}/build/fast_align -i ${resultHandle_path}/${source_name}_${target_name}.clean -p ${direction}.model -d -o -v > ${direction}.talp 2> ${direction}.error
${FASTALIGN_DIR}/build/fast_align -i ${resultHandle_path}/${target_name}_${source_name}.clean -p ${direction}.reverse.model -d -o -v > ${direction}.reverse.talp 2> ${direction}.reverse.error

