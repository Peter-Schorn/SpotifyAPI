#!/usr/bin/env python3

import os
import sys
from time import sleep
import argparse

extraPaths = [
    "/Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages",
    "/Library/Frameworks/Python.framework/Versions/3.10/lib/python3.10/site-packages"
]

for extraPath in extraPaths:
    if not extraPath in sys.path:
        sys.path.append(extraPath)

try:
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.chrome.service import Service as ChromeService
    from selenium.webdriver.support.wait import WebDriverWait
    from selenium.webdriver.support import expected_conditions

    from webdriver_manager.chrome import ChromeDriverManager
except ModuleNotFoundError as error:
    print("--- sys.path ---")
    for path in sys.path:
        print(path)
    print()
    raise error


parser = argparse.ArgumentParser(description="Spotify API Authorizer")

parser.add_argument("--button", type=str, default="accept")
parser.add_argument("--sp-dc", type=str)
parser.add_argument("--redirect-uri", type=str, default="http://localhost:8080")
parser.add_argument("--url", type=str)
parser.add_argument("--timeout", type=float, default=30)
parser.add_argument("--non-headless", action="store_true")

args = parser.parse_args()

all_buttons = ["accept", "cancel"]

if not args.button in all_buttons:
    all_buttons_str = ", ".join(all_buttons)
    message = f"button must be one of {all_buttons_str} (got '{args.button}')"
    raise ValueError(message)

assert args.button in ["accept", "cancel"], "button must be either 'accept' or 'cancel'"

options = Options()
options.headless = not args.non_headless
browser = webdriver.Chrome(
    service=ChromeService(ChromeDriverManager().install()),
    options=options
)

print(f"timeout: {args.timeout}")

browser.set_page_load_timeout(args.timeout)

accounts_url = "https://accounts.spotify.com/en/login"
browser.get(accounts_url)

browser.add_cookie({
    "name": "sp_dc",
    "value": args.sp_dc,
    "domain": ".spotify.com",
    "path": "/"
})

browser.get(args.url)
print(f"opened authorization URL: {args.url}")

accept_script = """document.querySelector("[data-testid='auth-accept']").click()"""
cancel_script = """document.querySelector("[data-testid='auth-cancel']").click()"""
script = accept_script if args.button == "accept" else cancel_script
print(f"will execute script: {script}")

result = browser.execute_script(script)
print(f"script result: {result}")

WebDriverWait(browser, timeout=args.timeout).until(
    expected_conditions.url_contains(args.redirect_uri)
)

redirect_uri_with_query = browser.current_url

print(f"\nredirect uri with query:\n{redirect_uri_with_query}")
