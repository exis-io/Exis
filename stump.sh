#!/bin/bash 
#
# git subtree add --prefix js/ngRiffle ngRiffle master
# 
#
# Its nice to have the go code in this directory and not go/src, symlink something like this
  ln -s /home/damouse/Documents/merged/riffle/go/goRiffle/ /home/damouse/Documents/go/src/github.com/exis-io/goRiffle
  ln -s /home/damouse/Documents/merged/riffle/go/coreRiffle /home/damouse/Documents/go/src/github.com/exis-io/coreRiffle
#

if [ $# -lt 1 ]
then
    echo -e "Updating and deployment of riffle libraries.\n"

    echo "Usage:"
    echo -e "  init\t\t set up remotes for development"
    echo -e "  push\t\t push updates on master"
    echo -e "  pull\t\t pull updates on master"

    echo -e "\nBuild client libraries:"
    echo -e "  [js, core, go]"


    echo -e "\nUpdate and deploy libraries. Pass a version number"
    echo -e "  [js, ios, go]\n"

    exit
fi

init() {
    echo "Setting remotes for development"

    git remote add swiftRiffle git@github.com:exis-io/swiftRiffle.git
    git remote add iosAppBackendSeed git@github.com:exis-io/iosAppBackendSeed.git
    git remote add iosAppSeed git@github.com:exis-io/iosAppSeed.git

    git remote add jsRiffle git@github.com:exis-io/jsRiffle.git
    git remote add ngRiffle git@github.com:exis-io/ngRiffle.git 
    git remote add ngSeed git@github.com:exis-io/ngSeed.git 

    git remote add goRiffle git@github.com:exis-io/goRiffle.git 
    git remote add coreRiffle git@github.com:exis-io/coreRiffle.git 

    git remote add pyRiffle git@github.com:exis-io/pyRiffle.git

    git remote add ngCAH git@github.com:exis-io/ionicCardsAgainstEXIStence.git
    git remote add iosCAH git@github.com:exis-io/CardsAgainst.git
}

push() {
    echo "Pushing subtrees"

    git subtree push --prefix ios/swiftRiffle swiftRiffle master 
    git subtree push --prefix ios/appBackendSeed iosAppBackendSeed master 
    git subtree push --prefix ios/appSeed iosAppSeed master

    git subtree push --prefix js/jsRiffle jsRiffle master 
    git subtree push --prefix js/ngRiffle ngRiffle master 
    git subtree push --prefix js/angularSeed ngSeed master 

    git subtree push --prefix go/goRiffle goRiffle master 
    git subtree push --prefix go/coreRiffle coreRiffle master 

    git subtree push --prefix python/pyRiffle pyRiffle master 

    git subtree push --prefix CardsAgainstHumanityDemo/swiftCardsAgainst iosCAH master 
    git subtree push --prefix CardsAgainstHumanityDemo/ngCardsAgainst ngCAH master 

    git push origin danger
}

pull() {
    echo "Pulling subtrees"

    git pull origin master

    git subtree pull --prefix ios/swiftRiffle swiftRiffle master -m 'Update to stump' --squash
    git subtree pull --prefix ios/appBackendSeed iosAppBackendSeed master -m 'Update to stump' --squash
    git subtree pull --prefix ios/appSeed iosAppSeed  master -m 'Update to stump' --squash

    git subtree pull --prefix js/jsRiffle jsRiffle master -m 'Update to stump' --squash
    git subtree pull --prefix js/ngRiffle ngRiffle master -m 'Update to stump' --squash
    git subtree pull --prefix js/angularSeed ngSeed master -m 'Update to stump' --squash

    git subtree pull --prefix go/goRiffle goRiffle master -m 'Update to stump' --squash
    git subtree pull --prefix go/coreRiffle coreRiffle master -m 'Update to stump' --squash

    # Link them forward so this version can be edited
    # ln -s go/goRiffle $GOPATH/src/github.com/exis-io/goRiffle
    # ln -s go/coreRiffle $GOPATH/src/github.com/exis-io/coreRiffle

}

ios() {
    echo "Updating riffle, seeds, and cards to version $1"

    git subtree push --prefix swift/swiftRiffle swiftRiffle master

    git clone git@github.com:exis-io/swiftRiffle.git
    cd swiftRiffle
    
    git tag $1 
    git push --tags

    pod trunk push --allow-warnings --verbose

    cd ..
    rm -rf swiftRiffle

    # update the seed projects and push them 
    cd swift/appSeed
    pod update

    cd ../appBackendSeed
    pod update
    cd ../..

    git add --all
    git commit -m "swRiffle upgrade to v $1"

    git subtree push --prefix swift/appBackendSeed iosAppBackendSeed master
    git subtree push --prefix swift/appSeed iosAppSeed master
    git push origin master
}

js() {
    echo "Updating js to version $1"

    browserify js/jsRiffle/index.js --standalone jsRiffle -o jsRiffle.js
    browserify js/jsRiffle/index.js --standalone jsRiffle | uglifyjs > jsRiffle.min.js

    mv jsRiffle.js js/jsRiffle/release/jsRiffle.js
    mv jsRiffle.min.js js/jsRiffle/release/jsRiffle.min.js

    cd js/jsRiffle
    npm version $1
    npm publish

    cd ../ngRiffle
    npm version $1
    npm publish

    cd ../..

    git add --all
    git commit -m "jsRiffle upgrade to v $1"

    git push origin master
    git subtree push --prefix js/jsRiffle jsRiffle master
    git subtree push --prefix js/ngRiffle ngRiffle master

    git clone git@github.com:exis-io/jsRiffle.git
    cd jsRiffle
    git tag $1 
    git push --tags
    cd ..
    rm -rf jsRiffle

    git clone git@github.com:exis-io/ngRiffle.git 
    cd ngRiffle
    git tag $1 
    git push --tags
    cd ..
    rm -rf ngRiffle

    # Do something with the seed app!
}

go() {
    echo "Building go"
    exit
}

core() {
    # echo "Building OSX"
    # GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o products/osx.a goriffle/runner/osx.go

    # # rm osx/RiffleTest/osx.h osx/RiffleTest/osx.a
    # mv products/osx.h osx/RiffleTest/osx.h 
    # mv products/osx.a osx/RiffleTest/osx.a

    echo "Building Swift Container"
    go build -buildmode=c-shared -o swift/container/libriff.so go/coreRiffle/wrappers/swiftlinux.go


    # echo "Building iOS"
    # GOGCCFLAGS="--Wl,-no_pie" gomobile bind -ldflags="-extldflags=-pie" -target=ios -work github.com/exis-io/goriffle
    # rm -rf swift/Goriffle.framework
    # mv Goriffle.framework swift/Goriffle.framework


    # iOS naively like above. Doesn't work. 
    # GOARM=7 CGO_ENABLED=1 GOARCH=arm go build -buildmode=c-archive -o products/ios.a goriffle/runner/osx.go


    # echo "Building Python"
    # go build -buildmode=c-shared -o python/pyRiffle/riffle/libriff.so go/coreRiffle/wrappers/osx.go


    # echo "Building gojs"
    # gopherjs build -m go/coreRiffle/wrappers/jsRiffle.go

    # mv jsRiffle.js js/jsRiffle/src/go.js
    # mv jsRiffle.js.map js/jsRiffle/src/go.js.map

    exit
}

# run() {
#     # Run
#     LD_LIBRARY_PATH=./swift/container:$LD_LIBRARY_PATH ./swift/container/biddly
#     exit 
# }

python() {
    echo "Updating python"
    exit
}

case "$1" in
    "init") init;;
    "push") push;;
    "pull") pull;;
    "ios") ios $2 $3;;
    "js") js $2 $3;;
    "go") go;;
    "core") core;;
    "python") python;;
    "run") run;;
    *) echo "Unknown input $1"
   ;;
esac