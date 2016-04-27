#!/bin/bash

set -e

stack setup

mkdir -p 3rdParty/cc i18n
cd 3rdParty/cc
wget http://dl.google.com/closure-compiler/compiler-20160315.tar.gz
tar -xvf compiler-20160315.tar.gz
rm -rf compiler-20160315.tar.gz
cd ../..
