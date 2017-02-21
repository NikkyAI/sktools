#!/usr/bin/zsh
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
launcher=Launcher
upload_folder=$DIR/.upload/.launcher/
tools=tools

URLBASE="https://nikky.moe/mc/.launcher"
echo $DIR
name=launcher
pack_name=launcher
json_name=latest
_fancy=-dark

cd $DIR
mkdir $upload_folder

function copy () {
    FOLDER="$launcher/$1/build/libs/"
    ARG2=${2:-$1.jar}
    ARG3=${3:-$upload_folder}
    DEST="$ARG3/$ARG2"
    FILE=$( find $FOLDER | grep all | sort -n | tail -1 )
    VERSION=$( echo $FILE | sed 's/[^0-9\.]*\([0-9\.]*-[a-Z]*\)-all.jar/\1/' )

    echo "file: $ARG2"
    echo "version: $VERSION"
    cp -v $FILE $DEST
    echo
}

function json () {
    VERSION=${1:-VERSION}
    URL=$URLBASE/${2:-no_file_provided}
    JSONFILE=$upload_folder${3:-"$(basename $URL ".jar.pack").json"}

    json="{\n \"version\": \"$VERSION\",\n \"url\": \"$URL\"\n}"

    echo -e $json > $JSONFILE
    echo -e "$JSONFILE = $json"
}

function pack () {
    FOLDER="$launcher/$1/build/libs/"
    echo $FOLDER
    ARG2=${2:-$1.jar}
    PACK_FILE="$ARG2.pack"
    DEST="$upload_folder/$PACK_FILE"
    FILE=$( find $FOLDER | grep all | sort -n | tail -1 )
    VERSION=$( echo $FILE | sed 's/[^0-9\.]*\([0-9\.]*-[a-Z]*\)-all.jar/\1/' )

    json_string=$(json $VERSION $PACK_FILE $3)
    echo $json_string

    echo "$2 version $VERSION"
    echo "packing $FILE -> $DEST"
    
    cp -v $FILE "$upload_folder/full-$ARG2"
    pack200 --no-gzip $DEST $FILE
}

cd $DIR
# git pull
git -C Launcher pull || git clone https://github.com/NikkyAI/Launcher.git Launcher
#clean build
#$DIR/$launcher/gradlew -p $launcher/ clean build
cd $launcher
./gradlew clean build

cd $DIR
echo

echo "copy files from $launcher into $upload_folder"

copy launcher-bootstrap $name.jar
copy launcher-bootstrap-fancy $name$_fancy.jar

echo
echo "copy creator-tools and launcher builder from $launcher into $tools"

copy creator-tools "" $tools
copy launcher-builder "" $tools

echo
echo "package launcher jars from $launcher into $upload_folder"

pack launcher "$pack_name.jar" $json_name.json
pack launcher-fancy "$pack_name-dark.jar" $json_name$_fancy.json

cd $DIR
$DIR/upload.sh