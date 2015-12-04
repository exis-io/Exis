#!/bin/bash 

# git subtree add --prefix js/ngRiffle ngRiffle master
# 

if [ $# -lt 1 ]
then
    echo -e "Updating and deployment of riffle libraries\n"

    echo "Usage:"
    echo -e "  init\t\t set up remotes for development"
    echo -e "  push\t\t push updates on master"
    echo -e "  pull\t\t pull updates on master"
    echo -e "  ios\t\t update swiftRiffle. Pass version number and commit message"
    echo -e "  js\t\t update jsRiffle and ngRiffle. Pass version number and commit message"
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

    git remote add goRiffle git@github.com:exis-io/riffle.git 
    git remote add coreRiffle git@github.com:damouse/goriffle.git 
}

push() {
    echo "Pushing subtrees"

    # git subtree push --prefix ios/swiftRiffle swiftRiffle master
    # git subtree push --prefix ios/appBackendSeed iosAppBackendSeed master
    # git subtree push --prefix ios/appSeed iosAppSeed master

    # git subtree push --prefix js/jsRiffle jsRiffle master
    # git subtree push --prefix js/ngRiffle ngRiffle master
    # git subtree push --prefix js/angularSeed ngSeed master

    # git subtree push --prefix go/goRiffle goRiffle master
    git subtree push --prefix core/coreRiffle coreRiffle master

    git push origin master
}

pull() {
    echo "Pulling subtrees"

    git pull origin master

    git subtree pull --prefix ios/swiftRiffle swiftRiffle master -m 'Update to stump'
    git subtree pull --prefix ios/appBackendSeed iosAppBackendSeed master -m 'Update to stump'
    git subtree pull --prefix ios/appSeed iosAppSeed  master -m 'Update to stump'

    git subtree pull --prefix js/jsRiffle jsRiffle master -m 'Update to stump'
    git subtree pull --prefix js/ngRiffle ngRiffle master -m 'Update to stump'
    git subtree pull --prefix js/angularSeed ngSeed master -m 'Update to stump'

    git subtree pull --prefix go/goRiffle goRiffle master -m 'Update to stump'
    git subtree pull --prefix core/coreRiffle coreRiffle master -m 'Update to stump'
}

ios() {
    echo "Updating ios to version $1"

    git subtree push --prefix ios/swiftRiffle swiftRiffle master

    git clone git@github.com:exis-io/swiftRiffle.git
    cd swiftRiffle
    
    git tag -a $1 -m $2
    git push --tags

    pod trunk push --allow-warnings --verbose

    cd ..
    rm -rf swiftRiffle

    # update the seed projects and push them 
    cd ios/appSeed
    pod update

    cd ../appBackendSeed
    pod update
    cd ../..

    git add --all
    git commit -m "swRiffle upgrade to v $1"

    git subtree push --prefix ios/appBackendSeed iosAppBackendSeed master
    git subtree push --prefix ios/appSeed iosAppSeed master
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
    git tag -a $1 -m "Upgrade to v $1"
    git push --tags
    cd ..
    rm -rf jsRiffle

    git clone git@github.com:exis-io/ngRiffle.git 
    cd ngRiffle
    git tag -a $1 -m "Upgrade to v $1"
    git push --tags
    cd ..
    rm -rf ngRiffle

    # Do anything with the seed app?
}

go() {
    echo "Building go"
}

core() {
    # echo "Building OSX"
    # GOOS=darwin GOARCH=amd64 go build -buildmode=c-archive -o products/osx.a goriffle/runner/osx.go

    # # rm osx/RiffleTest/osx.h osx/RiffleTest/osx.a
    # mv products/osx.h osx/RiffleTest/osx.h 
    # mv products/osx.a osx/RiffleTest/osx.a


    # echo "Building iOS"
    # GOGCCFLAGS="--Wl,-no_pie" gomobile bind -ldflags="-extldflags=-pie" -target=ios -work github.com/exis-io/goriffle
    # rm -rf ios/Goriffle.framework
    # mv Goriffle.framework ios/Goriffle.framework


    # iOS naively like above. Doesn't work. 
    # GOARM=7 CGO_ENABLED=1 GOARCH=arm go build -buildmode=c-archive -o products/ios.a goriffle/runner/osx.go


    # echo "Building Python"
    # GOOS=darwin GOARCH=amd64 go build -buildmode=c-shared -o python/libriff.so goriffle/runner/osx.go

    echo "Building gojs"
    gopherjs build -m core/sandbox/jsRiffle.go

    mv jsRiffle.js js/jsRiffle/src/go.js
    mv jsRiffle.js js/jsRiffle/src/go.js.map
}

case "$1" in
    "init") init;;
    "push") push;;
    "pull") pull;;
    "ios") ios $2 $3;;
    "js") js $2 $3;;
    "go") go;;
    "core") core;;
    *) echo "Unknown input $1"
   ;;
esac