#!/bin/bash
DIR="$(dirname "$(readlink -f "$0")")"

# This script is to be run within the contiki docker container

CVENUM=2020-12140-real
SAMPLE_DIR=/workdir/contiki-ng/examples/hello-world

cd /workdir/contiki-ng
# Restore git state
git reset --hard
git clean -df
git checkout release/v4.4

#git apply $DIR/patches/cc2538_norom.patch

# Replace DMA-based read
#git apply $DIR/patches/cc2538_read.patch

# configure l2cap in hello-world sample
git apply $DIR/patches/l2cap_sample.patch

# bugs in target identified after paper release, patch
# git apply $DIR/patches/fix-l2cap-issues.patch

# patches for hardfault
git apply $DIR/patches/12140-hardfault.patch
git apply $DIR/patches/log.patch
git apply $DIR/patches/packet_ptr.patch

make -C $SAMPLE_DIR TARGET=cc2538dk distclean all

# Copy sample to outside-visible directory
OUT_DIR=/workdir/rebuilt/CVE-$CVENUM
rm -rf $OUT_DIR
mkdir -p $OUT_DIR
cp $SAMPLE_DIR/build/cc2538dk/hello-world.bin $SAMPLE_DIR/build/cc2538dk/hello-world.elf $OUT_DIR
