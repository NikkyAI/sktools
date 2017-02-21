#!/bin/bash
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# cd ~/src/cfpecker
# git pull

cd $DIR

git -C cfpecker pull || git clone https://github.com/NikkyAI/cfpecker.git cfpecker

# ./cfpecker
python $DIR/cfpecker/bin/cfpecker.py


for D in `find modpacks/* -maxdepth 0 -type d`
do
    echo $D
    rsync -avz $D/local/* $D/src/mods/
done