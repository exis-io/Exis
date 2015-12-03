#!/bin/bash 

if [ $# -lt 1 ]
then
    echo -e "Updating and deployment of riffle libraries\n"

    echo "Usage:"
    echo -e "  remote-init\t\t set up remotes for development"
    echo -e "  ios\t\t update swiftRiffle. Pass version number and commit message"
    echo -e "  push\t\t push updates. Pass branch name"
    echo -e "  pull\t\t pull updates. Pass branch name"
    exit
fi

init() {
    echo "Setting remotes for development"

    git remote add -f swiftRiffle git@github.com:exis-io/swiftRiffle.git
    git remote add -f iosAppBackendSeed   git@github.com:exis-io/iosAppBackendSeed.git
    git remote add -f iosAppSeed  git@github.com:exis-io/iosAppSeed.git
    git remote add -f swiftRiffle git@github.com:exis-io/swiftRiffle.git
}

push() {
    echo "Pushing subtrees"

    git push swiftRiffle `git subtree split --prefix ios/swiftRiffle master`:master --force
    git push iosAppBackendSeed `git subtree split --prefix ios/appBackendSeed master`:master --force
    git push iosAppSeed `git subtree split --prefix ios/appSeed master`:master --force

    git push origin $1
}

pull() {
    echo "Pulling subtrees"

    git pull origin $1

    git subtree pull --prefix=ios/swiftRiffle git@github.com:exis-io/swiftRiffle.git $1 --no-edit
    git subtree pull --prefix=ios/appBackendSeed git@github.com:exis-io/iosAppBackendSeed.git $1 --no-edit
    git subtree pull --prefix=ios/appSeed git@github.com:exis-io/iosAppSeed.git $1 --no-edit
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
    "push") push $2;;
    "pull") pull $2;;
    "ios") ios $2 $3;;
    *) echo "Unknown input $1"
   ;;
esac