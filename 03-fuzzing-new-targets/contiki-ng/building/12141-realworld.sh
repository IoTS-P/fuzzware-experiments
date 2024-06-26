#!/bin/bash
DIR="$(dirname "$(readlink -f "$0")")"

# This script is to be run within the contiki docker container

CVENUM=2020-12141-real
SAMPLE_DIR=/workdir/contiki-ng/examples/snmp-server

cd /workdir/contiki-ng
# Restore git state
git reset --hard
git clean -df
git checkout release/v4.4

#git apply $DIR/patches/cc2538_norom.patch
# Replace DMA-based read
#git apply $DIR/patches/cc2538_read.patch

# Configure radio packet -> SNMP
git apply $DIR/patches/transparent_mac.patch
git apply $DIR/patches/snmp_sample.patch

# patches for hardfault
git apply $DIR/patches/12141-hardfault.patch
git apply $DIR/patches/log.patch


rm -rf $SAMPLE_DIR/build
make -C $SAMPLE_DIR TARGET=cc2538dk clean all

# Copy sample to outside-visible directory
OUT_DIR=/workdir/rebuilt/CVE-$CVENUM
rm -rf $OUT_DIR
mkdir -p $OUT_DIR
cp $SAMPLE_DIR/build/cc2538dk/snmp-server.bin $SAMPLE_DIR/build/cc2538dk/snmp-server.elf $OUT_DIR
