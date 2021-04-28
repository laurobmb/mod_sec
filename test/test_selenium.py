#!/usr/bin/env python3

import unittest
from selenium import webdriver
import time

headless =1

class TestWAF(unittest.TestCase):
    def setUp(self):
        self.profile = webdriver.ChromeOptions()
        self.profile.add_argument('ignore-certificate-errors')
        if headless == 0:       
            self.profile.add_argument('--headless')
            self.profile.add_argument('--no-sandbox')
            self.profile.add_argument('--disable-dev-shm-usage')
        chrome_driver_binary = "/usr/bin/chromedriver"

        self.browser = webdriver.Chrome(
            chrome_driver_binary,
            options=self.profile,
            service_args=['--verbose', '--log-path=/tmp/selenium.log']
            )
        
    def testRCE(self):
        self.browser.get('http://www2.recife.pe.gov.br/?exec=/bin/bash')
        time.sleep(1)    
        self.assertIn('403 Forbidden',self.browser.find_element_by_xpath(
            '/html/body/center/h1').text)          

    def testXSS(self):
        self.browser.get('http://www2.recife.pe.gov.br/?q="><script>alert(1)</script>"')
        time.sleep(1)    
        self.assertIn('403 Forbidden',self.browser.find_element_by_xpath(
            '/html/body/center/h1').text)          

    def testSQL(self):
        self.browser.get("http://www2.recife.pe.gov.br/?id=3 or 'a'='a'")
        time.sleep(1)    
        self.assertIn('403 Forbidden',self.browser.find_element_by_xpath(
            '/html/body/center/h1').text)          

    def tearDown(self):
        self.browser.quit()

if __name__ == '__main__':
    unittest.main(verbosity=3)
