#!/usr/bin/env python3

import time
from selenium import webdriver
import subprocess

driver_path = "/usr/bin/chromedriver"
brave_path = "/usr/bin/brave"

option = webdriver.ChromeOptions()
option.binary_location = brave_path
# option.add_argument("--profile-directory=Default")
# option.add_argument("--user-data-dir=/home/wacken/.config/BraveSoftware/Brave-Browser/Default")
# option.add_argument("--incognito")
# option.add_argument("--headless")

# Create new Instance of Chrome
browser = webdriver.Chrome(executable_path=driver_path, options=option)

# links = subprocess.check_output('./filter_holodex_links.sh')
# browser.get('http://stackoverflow.com/')
# i = 0
# for x in links.splitlines():
#     print(x)
#     i=i+1
    # browser.execute_script(f"$(window.open('{bytes.decode(x)}'))")
    # browser.close()
    # browser.switch_to.window(browser.window_handles[-1])
# browser.execute_script("$(window.open('http://facebook.com/'))")

# time.sleep(5)
# browser.close()
# browser.switch_to.window(browser.window_handles[-1])
# browser.close()
# browser.switch_to.window(browser.window_handles[-1])
# browser.close()
