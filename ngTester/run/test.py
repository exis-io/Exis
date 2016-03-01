from selenium import webdriver
from selenium.common.exceptions import TimeoutException, UnexpectedAlertPresentException
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities    
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support import expected_conditions as EC # available since 2.26.0
import traceback
import time
import os
import yaml
import threading
import sys
import runnode
node = None

CONFIG_PATH = 'run/configtests.yaml'
d = DesiredCapabilities.CHROME
d['loggingPrefs'] = { 'browser':'ALL' }

def runBrowser(endpoint, startNextBrowser, allLoaded, globalLock, isLast, results):

    failed = False
    url = "http://localhost:9001/#/{}".format(endpoint)

    try:

        # Create a new instance of the Firefox driver
        driver = webdriver.Chrome('run/chromedriver', desired_capabilities=d)

        # go to the test page
        driver.get(url)

        # use event to tell main thread that it can launch next brower
        startNextBrowser.set()

        # Wait until all browsers are loaded
        # This is because all browsers are communicating with each other
        if isLast:
            allLoaded.set()
        else:
            allLoaded.wait()


        # Sleep for awhile
        # Check web logs to see if we need to restart the node
        # We need to currently sleep so server side doesn't exit before
        # client had a chance to call it
        WAITTIME = 10
        starttime = time.time()
        # Log index always points to the next log we want
        # So we have seen everything before log index
        logIndex = 0

        while (time.time() < starttime + WAITTIME):
            logs = driver.get_log('browser')
            for i in range(logIndex, len(logs)):
                line = logs[i]
                #print(line)
                if "___NODERESTART___" in line['message']:
                    #print("restarting node")
                    node.restart(line)

            # we dont want to look at these logs next time
            logIndex = len(logs)

            time.sleep(1)

        currElement = 0

        # figure out how to restart node 


        while True:
            # Get the element
            try:
                result = driver.find_element_by_id("success_{}".format(currElement))
            except:
                break

            success, description, output = result.text.split(" - ")
            isSuccess = (success == "SUCCESS")

            globalLock.acquire()
            if description not in results:
                results[description] = {}

            results[description][endpoint] = {
                    'success': isSuccess,
                    'description': description,
                    'output': output
                }
            globalLock.release()

            currElement += 1

        driver.quit()

    except Exception as e:
        if driver: 
            driver.quit()
    finally:
        pass

def runSingleTest(test):


    print("START TEST: {}".format(test['name']))
    startNextBrowser = threading.Event()
    allLoaded = threading.Event()
    resultLock = threading.Lock()
    thread_list = []
    results = {}

    for i, jsFile in enumerate(test['files']):
        isLast = (i == (len(test['files']) - 1))
        t = threading.Thread(target=runBrowser, args=[jsFile, startNextBrowser, allLoaded, resultLock, isLast, results])
        thread_list.append(t)
        t.start()

        startNextBrowser.wait()
        startNextBrowser.clear()

    # Wait for threads to complete
    for t in thread_list:
        t.join()

    # Go through tests to see which failed
    numTests = 0
    numFailures = 0
    for description, endpointResults in sorted(results.iteritems()):
        print("   {}".format(description))

        seen = {endpoint:False for endpoint in test['files']}
        success = True

        for endpoint, endpointResult in endpointResults.iteritems():
            seen[endpoint] = True
            if not endpointResult['success']:
                success = False
                print("      ERROR ({})".format(endpoint, endpointResult['output']))
                outputSplit = endpointResult['output'].split("...")
                for o in outputSplit:
                    if o != "" and o != None:
                        print("        {}".format(o))

        for endpoint in test['files']:
            if not seen[endpoint]:
                success = False
                print("    Error: didn't find result for {}".format(endpoint))

        if success:
            # dont print anything on success for shorter output
            #print("     success!")
            pass
        else:
            numFailures += 1

        numTests += 1

    print("COMPLETE TEST: {}. {}/{} tests succeeded".format(test['name'], numTests-numFailures, numTests))


def runtests(whichTests):

    # Load the description of all calls we need
    with open(CONFIG_PATH, 'r') as f:
        testConfig = yaml.safe_load(f.read())

    if whichTests is None:
        runningTests = testConfig
    else:
        runningTests = [test for test in testConfig if test['name'] in whichTests]

    for test in runningTests:
        runSingleTest(test)


# TODO replicated code, needs to be consistent/moved into arbiter
def launchNode():
    global node
    node = runnode.Node()
    node.setup()
    node.start()

def killNode():
    if node:
        node.kill()

if __name__ == "__main__":
    if len(sys.argv) > 1: 
        whichTests = sys.argv[1:] 
    else:
        whichTests = None


    launchNode()
    runtests(whichTests)
    killNode()

