#!/bin/bash 

if [ $# -lt 1 ]
then
    echo -e "Updating and deployment of riffle libraries\n"

    echo "Usage:"
    echo -e "  remote-init\t\t set up remotes for development"
    echo -e "  ios\t\t update swiftRiffle. Pass version number and commit message."
    exit
fi

init() {
    echo "Setting remotes for development"

    git remote add -f swiftRiffle git@github.com:exis-io/swiftRiffle.git
    git remote add -f iosAppBackendSeed   git@github.com:exis-io/iosAppBackendSeed.git
    git remote add -f iosAppSeed  git@github.com:exis-io/iosAppSeed.git
    git remote add -f swiftRiffle git@github.com:exis-io/swiftRiffle.git
}

ios() {
    echo "Updating ios to version $1"

    git tag -a $1 -m $2
    git push swiftRiffle master
    git push swiftRiffle --tags

    pod trunk push ios/swiftRiffle/Riffle.podspec --allow-warnings

    # update the seed projects and push them 
    cd ios/appSeed
    pod update

    cd ../appBackendSeed
    pod update

    git add --all
    git commit -m 'base project update'

    git push iosAppSeed master
    git push iosAppBackendSeed master
}



case "$1" in
    "remote-init") init;;
    "ios") ios $2 $3;;
    *) echo "Unknown input $1"
   ;;
esac