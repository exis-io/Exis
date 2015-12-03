#!/bin/bash 

# git subtree add --prefix js/ngRiffle ngRiffle master
# 

if [ $# -lt 1 ]
then
    echo -e "Updating and deployment of riffle libraries\n"

    echo "Usage:"
    echo -e "  remote-init\t\t set up remotes for development"
    echo -e "  ios\t\t update swiftRiffle. Pass version number and commit message"
    echo -e "  push\t\t push updates on master"
    echo -e "  pull\t\t pull updates on master"
    exit
fi

init() {
    echo "Setting remotes for development"

    git remote add swiftRiffle git@github.com:exis-io/swiftRiffle.git
    git remote add iosAppBackendSeed   git@github.com:exis-io/iosAppBackendSeed.git
    git remote add iosAppSeed  git@github.com:exis-io/iosAppSeed.git

    git remote add jsRiffle git@github.com:exis-io/jsRiffle.git
    git remote add ngRiffle git@github.com:exis-io/ngRiffle.git 
}

push() {
    echo "Pushing subtrees"

    # git push swiftRiffle `git subtree split --prefix ios/swiftRiffle master`:master --force
    # git push iosAppBackendSeed `git subtree split --prefix ios/appBackendSeed master`:master --force
    # git push iosAppSeed `git subtree split --prefix ios/appSeed master`:master --force

    git subtree push --prefix js/jsRiffle jsRiffle master
    git subtree push --prefix js/ngRiffle ngRiffle master

    git push origin
}

pull() {
    echo "Pulling subtrees"

    git pull origin master

    # git subtree pull --prefix=ios/swiftRiffle git@github.com:exis-io/swiftRiffle.git master
    # git subtree pull --prefix=ios/appBackendSeed git@github.com:exis-io/iosAppBackendSeed.git master
    # git subtree pull --prefix=ios/appSeed git@github.com:exis-io/iosAppSeed.git  master

    git subtree pull --prefix js/jsRiffle jsRiffle master
    git subtree pull --prefix js/ngRiffle ngRiffle master
}


ios() {
    echo "Updating ios to version $1"

    # git push swiftRiffle `git subtree split --prefix ios/swiftRiffle master`:master --force

    # git clone git@github.com:exis-io/swiftRiffle.git
    # cd swiftRiffle
    
    # git tag -a $1 -m $2
    # git push --tags

    # pod trunk push --allow-warnings --verbose

    # cd ..
    # rm -rf swiftRiffle

    # update the seed projects and push them 
    cd ios/appSeed
    pod update

    cd ../appBackendSeed
    pod update

    git add --all
    git commit -m 'base project updates'

    git push iosAppBackendSeed `git subtree split --prefix ios/appBackendSeed master`:master --force
    git push iosAppSeed `git subtree split --prefix ios/appSeed master`:master --force
}



case "$1" in
    "remote-init") init;;
    "push") push;;
    "pull") pull;;
    "ios") ios $2 $3;;
    "js") ios $2 $3;;
    *) echo "Unknown input $1"
   ;;
esac