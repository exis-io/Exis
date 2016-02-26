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

        globalLock.acquire()
        results[endpoint] = []
        globalLock.release()

        while True:
            # Get the element
            try:
                success = driver.find_element_by_id("success_{}".format(currElement))
                #isSuccess =
                print("{}: {}".format(endpoint, success))
                currElement += 1
            except:
                break

        driver.quit()

    except Exception as e:
        failed = True
        driver.quit()
    finally:
        logMessage = time.strftime('%a, %d %b %Y %I:%M:%S %p') + " : RESULT: "
        if failed:
            logMessage = logMessage + "FAILED\n\n" + tb
        else:
            logMessage = logMessage + "PASSED\n"

        print(logMessage)


def runTest(test):
    startNextBrowser = threading.Event()
    allLoaded = threading.Event()
    resultLock = threading.Lock()
    thread_list = []
    results = {}
    for i, jsFile in enumerate(test['files']):
        print(jsFile)
        isLast = i == len(test['files']) - 1
        t = threading.Thread(target=runBrowser, args=[jsFile, startNextBrowser, allLoaded, resultLock, isLast, results])
        thread_list.append(t)
        t.start()

        startNextBrowser.wait()
        startNextBrowser.clear()

    # Wait for all to complete
    for t in thread_list:
        t.join()

def runtests():

    # Load the description of all calls we need
    with open(CONFIG_PATH, 'r') as f:
        testConfig = yaml.safe_load(f.read())

    for test in testConfig:

        runTest(test)



if __name__ == "__main__":
    runtests()
