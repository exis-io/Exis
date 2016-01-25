#!/bin/bash

bash browser-generate.sh

cat >browser.py <<EOF
import os
from selenium import webdriver
from selenium.common.exceptions import TimeoutException, UnexpectedAlertPresentException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support import expected_conditions as EC # available since 2.26.0

driver = webdriver.Firefox()

driver.get("file://{}/browser.html".format(os.getcwd()))
print "___SETUPCOMPLETE___"

try:
    title = WebDriverWait(driver, 10).until(EC.text_to_be_present_in_element((By.ID, "results"), "$REPL_BROWSER_EXPECT"))
    print "___RUNCOMPLETE___"
except:
    print "Exception"
finally:
    driver.quit()
EOF


echo "___BUILDCOMPLETE___"
python -u browser.py
