from selenium import webdriver
from selenium.common.exceptions import TimeoutException, UnexpectedAlertPresentException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support import expected_conditions as EC # available since 2.26.0
import traceback
import time
import os
import yaml
from threading import Thread


CONFIG_PATH = 'configtests.yaml'


def runBrowser(endpoint):

    failed = False
    url = "http://localhost:9001/{}".format(endpoint)

    try:

        # Create a new instance of the Firefox driver
        driver = webdriver.Firefox()

        # go to the google home page
        driver.get(url)

        currElement = 0

        while True:
            # Get the element
            try:
                success = driver.find_element_by_id("success_{}".format(currElement))
                print(success)
            except:
                break

        time.sleep(5)

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

    thread_list = []
    for file in test['files']:
        t = Thread(target=runBrowser, args=[file])
        thread_list.append(t)
        t.start()

        time.sleep(2)

def runtests():

    # Load the description of all calls we need
    with open(CONFIG_PATH, 'r') as f:
        testConfig = yaml.safe_load(f.read())

    for test in testConfig:

        runTest(test)



if __name__ == "__main__":
    runtests()
