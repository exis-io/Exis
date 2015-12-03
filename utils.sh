#!/bin/bash 

if [ $# -lt 1 ]
then
    echo -e "Updating and deployment of riffle libraries\n"

    echo "Usage:"
    echo -e "  ios\t\t update swiftRiffle. Pass version number and commit message."
    exit
fi

ios() {
    echo "Updating ios to version $1"
    exit
    git tag -a $1 -m $2
    exit
    pod trunk push ios/swiftRiffle/Riffle.podspec --allow-warnings
}


case "$1" in
    "ios") ios $2 $3;;
    *) echo "Unknown input $1"
   ;;
esac