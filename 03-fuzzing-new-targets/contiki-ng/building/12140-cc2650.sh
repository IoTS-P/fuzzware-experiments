#!/bin/bash
DIR="$(dirname "$(readlink -f "$0")")"

# This script is to be run within the contiki docker container

CVENUM=2020-12140-cc2650
SAMPLE_DIR=/workdir/contiki-ng/examples/platform-specific/cc26x0-cc13x0/ble-ipv6

cd /workdir/contiki-ng
# Restore git state
git reset --hard
git clean -df
git checkout release/v4.4

#git apply $DIR/patches/cc2538_norom.patch

# Replace DMA-based read
#git apply $DIR/patches/cc2538_read.patch

# configure l2cap in hello-world sample
#git apply $DIR/patches/l2cap_sample.patch

# bugs in target identified after paper release, patch
# git apply $DIR/patches/fix-l2cap-issues.patch

# patches for hardfault
#git apply $DIR/patches/12140-hardfault.patch
#git apply $DIR/patches/log.patch
#git apply $DIR/patches/packet_ptr.patch
#git apply $DIR/patches/no-dma.patch

make -C $SAMPLE_DIR TARGET=cc26x0-cc13x0 BOARD=launchpad/cc2650 distclean all

# Copy sample to outside-visible directory
OUT_DIR=/workdir/rebuilt/CVE-$CVENUM
rm -rf $OUT_DIR
mkdir -p $OUT_DIR
cp $SAMPLE_DIR/build/cc2538dk/* $OUT_DIR
