#!/bin/sh
export SRCGEN=$SRCROOT/$TARGET_NAME/source/config/generated
echo $SRCGEN
rm -f $SRCGEN/*
dipgen --output $SRCGEN --verbose
