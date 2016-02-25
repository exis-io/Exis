from selenium import webdriver
from selenium.common.exceptions import TimeoutException, UnexpectedAlertPresentException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support import expected_conditions as EC # available since 2.26.0
import traceback
import time
import os


try:
    failed = False

    # Create a new instance of the Firefox driver
    driver = webdriver.Firefox()

    # go to the google home page
    driver.get("http://localhost:9001/backend")
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
