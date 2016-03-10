#!/usr/bin/python

helpstr = '''Riffle maintenance and management.

Usage:
  stump init
  stump push (all | REPOS...)
  stump pull (all | REPOS...)
  stump add-subtree DIRECTORY NAME URL
  stump test (list | all | <languageOrTestNumber>)
  stump release <remote> <version>

Options:
  -h --help     Show this screen.


Testing Examples:
    ./stump test list       List all tests
    ./stump test all        Run all tests
    ./stump test python     Run all tests in language
    ./stump test 15         Run the given test number

Release Example:
    ./stump release pyRiffle 0.2.1
'''

import os
import sys
import docopt
from subprocess import call
import shutil
import tempfile

# Attempt to set the directory automatically if stump is executing
if os.environ.get("EXIS_REPO", None) is None:
    if 'stump.py' in next(os.walk('.'))[2]:
        os.environ["EXIS_REPO"] = os.getcwd()

import arbiter

# Format: (prefix: remote, url)
SUBTREES = [
    ("swift/swiftRiffle", "swiftRiffle", "git@github.com:exis-io/swiftRiffle.git"),
    ("swift/appBackendSeed", "iosAppBackendSeed", "git@github.com:exis-io/iosAppBackendSeed.git"),
    ("swift/appSeed", "iosAppSeed", "git@github.com:exis-io/iosAppSeed.git"),
    ("swift/example", "iosExample", "git@github.com:exis-io/iOSExample.git"),

    ("js/jsRiffle", "jsRiffle", "git@github.com:exis-io/jsRiffle.git"),
    ("js/ngRiffle", "ngRiffle", "git@github.com:exis-io/ngRiffle.git"),
    ("js/angularSeed", "ngSeed", "git@github.com:exis-io/ngSeed.git"),

    ("core", "core", "git@github.com:exis-io/core.git"),

    ("python/pyRiffle", "pyRiffle", "git@github.com:exis-io/pyRiffle.git"),

    ("CardsAgainstHumanityDemo/swiftCardsAgainst", "iosCAH", "git@github.com:exis-io/CardsAgainst.git"),
    ("CardsAgainstHumanityDemo/ngCardsAgainst", "ngCAH", "git@github.com:exis-io/ionicCardsAgainstEXIStence.git")
]


if __name__ == '__main__':
    args = docopt.docopt(helpstr, options_first=True, help=True)
    allLanguages = ['swift', 'js', 'python']

    if args['init']:
        print "Adding remotes"

        for p, r, u in SUBTREES:
            call("git remote add %s %s" % (r, u,), shell=True)

        print "Linking go libraries"
        gopath = os.getenv('GOPATH', None)

        if gopath is None:
            print 'You dont have a $GOPATH set. Is go installed correctly?'
        else:
            corePath = os.path.join(gopath, 'src/github.com/exis-io/core')

            # Remove existing symlinks
            if os.path.islink(corePath):
                os.unlink(corePath)

            # Delete the library if there's anything there
            if os.path.exists(corePath):
                shutil.rmtree(corePath)

            os.symlink(os.path.abspath("core"), corePath)

    elif args['push']:
        if args['all']:
            repos = SUBTREES
        else:
            repos = [x for x in SUBTREES if x[1] in args['REPOS']]

        b = 'master'

        print "Pushing: ", repos

        for p, r, u in repos:
            call("git subtree push --prefix %s %s %s" % (p, r, b,), shell=True)

    elif args['pull']:
        if args['all']:
            repos = SUBTREES
        else:
            repos = [x for x in SUBTREES if x[1] in args['REPOS']]

        b = 'master'

        print "Pulling: ", [x[0] for x in repos]

        for p, r, u in repos:
            call("git subtree pull --prefix %s %s %s -m 'Update to stump' --squash" % (p, r, b,), shell=True)

    elif args['add-subtree']:
        call("git remote add %s %s" % (args['NAME'], args['URL'],), shell=True)
        call("git subtree add --prefix %s %s master" % (args['DIRECTORY'], args['NAME'],), shell=True)

        print 'Subtree added. Please edit the SUBTREES field in this script: \n("%s", "%s", "%s")' % (args['DIRECTORY'], args['NAME'], args['URL'])

    elif args['test']:
        # os.environ["EXIS_REPO"] = os.getcwd()

        def orderedTasks(lang):
            '''
            Returns an orderd list of tasks from the arbiter 

            TODO:
                move the relative sorting down into the arbiter-- no need to repeat these steps all the time here
                Also jesus find another home for this method
            '''
            lang = None if lang == 'all' else lang
            tasks = [x for x in arbiter.arbiter.findTasks(shouldPrint=False, lang=lang)]
            tasks.sort(key=lambda x: x.index)

            return tasks

        # TODO: unit tests
        # TODO: integrate a little more tightly with unit and end to end tests

        # List the tests indexed in the order they were found
        if args['list']:
            print " #\tTest Name"
            for task in orderedTasks(None):
                print " " + str(task.index) + "\t" + task.getName()

                # TODO: seperate by language
                # TODO: seperate by file, and use the files for some reasonable ordering

        elif args['all']:
            arbiter.arbiter.testAll('all')

        elif args['<languageOrTestNumber>']:
            target = args['<languageOrTestNumber>']

            if target.isdigit():
                tasks = orderedTasks('all')
                target = next((x for x in tasks if x.index == int(target)), None)

                if target is None:
                    print "Unable to find test #" + str(target)
                    sys.exit(0)

                arbiter.repl.executeTaskSet(target)
            else:
                arbiter.arbiter.testAll(args['<languageOrTestNumber>'])

    elif args['release']:
        found = False
        for prefix, remote, url in SUBTREES:
            if remote == args['<remote>']:
                found = True
                break

        if not found:
            print("Error: unrecognized remote ({})".format(args['<remote>']))
            sys.exit(1)

        print("Pushing {} to remote {} ({})...".format(prefix, remote, url))
        call("git subtree push --prefix {} {} master".format(prefix, remote), shell=True)

        tag = args['<version>']
        if not tag.startswith("v"):
            tag = "v" + tag

        tmp = tempfile.mkdtemp()
        call("git clone {} {}".format(url, tmp), shell=True)

        print("Creating tag: {}".format(tag))
        call('git -C {0} tag -a {1} -m "Release {1}."'.format(tmp, tag), shell=True)
        call('git  tag -a {1}-{0} -m "Release {1}-{0}."'.format(args['<version>'], remote), shell=True)
        call("git push --tags origin HEAD", shell=True)
        call("git -C {} push --tags origin master".format(tmp), shell=True)
        shutil.rmtree(tmp)


'''
Deployment scripts from old stump

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

Quick scribbles for shadow subtrees. The basics are: 

    - Clone *just* the git repo, no files
    - Drop the .git dir into the target directory
    - Add and push from that directory
    - Remove the .git directory

This is for situations where you want to check in files into the subtree and not the trunk (like big binary files)
Make sure the binary files are ignored at the trunk, not in the local repo, else they'll be ignored
when pushing the shadow. You can also move gitignores too and avoid this problem 

git clone --no-checkout git@github.com:exis-io/swiftRiffleCocoapod.git swift/swiftRiffle/swiftRiffle.tmp 

mv swift/swiftRiffle/swiftRiffle.tmp/.git swift/swiftRiffle/
rm -rf swift/swiftRiffle/swiftRiffle.tmp

git -C swift/swiftRiffle add --all 
git -C swift/swiftRiffle commit -m "Some message"
git -C swift/swiftRiffle push origin master

rm -rf swift/swiftRiffle/.git
'''







