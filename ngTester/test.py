from selenium import webdriver
from selenium.common.exceptions import TimeoutException, UnexpectedAlertPresentException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support import expected_conditions as EC # available since 2.26.0
import traceback
import time
import os
import yaml
import threading


CONFIG_PATH = 'configtests.yaml'

def runBrowser(endpoint, startNextBrowser, allLoaded, globalLock, isLast, results):

    failed = False
    url = "http://localhost:9001/#/{}".format(endpoint)

    try:

        # Create a new instance of the Firefox driver
        driver = webdriver.Firefox()

        # go to the test page
        driver.get(url)

        # use event to tell main thread that it can launch next brower
        startNextBrowser.set()

        # Wait until all browsers all loaded
        if isLast:
            allLoaded.set()
        else:
            allLoaded.wait()

        # We need to currently sleep so server side doesn't exit before
        # client had a chance to call it
        time.sleep(1)

        currElement = 0


        while True:
            # Get the element
            try:
                result = driver.find_element_by_id("success_{}".format(currElement))
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
            except:
                break

        driver.quit()

    except Exception as e:
        driver.quit()

def runSingleTest(test):


    print("START TEST: {}".format(test['name']))
    startNextBrowser = threading.Event()
    allLoaded = threading.Event()
    resultLock = threading.Lock()
    thread_list = []
    results = {}
    for i, jsFile in enumerate(test['files']):
        isLast = i == len(test['files']) - 1
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
    for description, endpointResults in results.iteritems():
        print("   test: {}".format(description))

        seen = {endpoint:False for endpoint in test['files']}
        success = True

        for endpoint, endpointResult in endpointResults.iteritems():
            seen[endpoint] = True
            if not endpointResult['success']:
                success = False
                print("    ERROR ({}) - {}".format(endpoint, endpointResult['description']))
                print("        {}".format(endpointResult['output']))

        for endpoint in test['files']:
            if not seen[endpoint]:
                success = False
                print("    Error: didn't find result for {}".format(endpoint))

        if success:
            print("     success!")
        else:
            numFailures += 1

        numTests += 1

    print("COMPLETE TEST: {}. {}/{} tests succeeded".format(test['name'], numTests-numFailures, numTests))


def runtests():

    # Load the description of all calls we need
    with open(CONFIG_PATH, 'r') as f:
        testConfig = yaml.safe_load(f.read())

    for test in testConfig:
        runSingleTest(test)



if __name__ == "__main__":
    runtests()
