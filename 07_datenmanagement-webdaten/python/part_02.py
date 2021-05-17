# import type hints
from typing import Dict, Optional

# import dependencies
import requests
import jwt
import logging
import time
from base64 import b64encode

# Basic Authentication

# define URL
url = "https://httpbin.org/basic-auth/correlaid/password"
# request URL using GET method
response = requests.get(url=url)
# check if request was successful
response.status_code == 200

# define authorization header
auth_header = f"Basic {b64encode(b'correlaid:password').decode('ascii')}"
# request URL using GET method adding authorization header
response = requests.get(url=url, headers={"Authorization": auth_header})
# check if request was successful
response.status_code == 200
# parse response
parsed_response = response.json()

# request URL using GET method using auth helper
response = requests.get(url=url, auth=("correlaid", "password"))
# check if request was successful
response.status_code == 200
# parse response
parsed_response = response.json()

# Bearer Authentication

# define URL
url = "https://httpbin.org/bearer"
# define a JSON web token (JWT)
token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiQ29ycmVsQWlkIiwiaWQiOiI1YmRmNmMwYy03ODMzLTRjNWUtOTVkYy01YjA3YTRjMDIxYjIifQ.waEwnRZ8lcryPHLjAVOqFOBx6TqrOkkHWxCl6Dfjecw"
# request URL using GET method adding authorization header
response = requests.get(url=url,
                        headers={"Authorization": f"Bearer {token}"})
# check if request was successful
response.status_code == 200
# parse response
parsed_response = response.json()

# decode JWT using pyjwt package
jwt.decode(jwt=token, options={"verify_signature": False})

# Error handling

# initialize logger
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()


def request_authentication(user: str, password: str) -> bool:
    """
    Request authentication for a predefined URL.

    :param user: User name
    :param password: Password
    :return: Authentication status as boolean
    """
    # request URL using GET method adding authorization header
    response = requests.get(url="https://httpbin.org/basic-auth/correlaid/password",
                            auth=(user, password))
    # parse response
    parsed_response = response.json()
    # return authenticated key
    return parsed_response["authenticated"]


def request_url(url: str) -> Optional[Dict]:
    """
    Request a provided URL. Requests are automatically retried for status code 403 and 401.

    :param url: URL to request
    :return: Response body or None if error
    """
    # request URL
    response = requests.get(url=url)
    # return result if successful
    if response.status_code <= 399:
        # show response status message
        logger.info(f"Request was successful: {response.status_code}")
        # parse response
        return response.json()
    elif response.status_code == 403:
        # show response status message
        logger.warning(f"Request was not successful: {response.status_code}")
        # replace URL
        url = "https://httpbin.org/json"
        # sleep to be polite
        time.sleep(2)
        # call same function recursively
        request_url(url=url)
    elif response.status_code == 401:
        # show response status message
        logger.warning(f"Request was not successful: {response.status_code}")
        # authenticate
        request_authentication(user="correlaid", password="password")
        # replace URL
        url = "https://httpbin.org/json"
        # sleep to be polite
        time.sleep(2)
        # call same function recursively
        request_url(url=url)
    else:
        # show response status message
        logger.error(f"Request was not successful: {response.status_code}")
        return None


# try 200
url = "https://httpbin.org/json"
response = request_url(url=url)

# try 403
url = "https://httpbin.org/status/403"
response = request_url(url=url)

# try 401
url = "https://httpbin.org/status/401"
response = request_url(url=url)

# try 500
url = "https://httpbin.org/status/500"
response = request_url(url=url)
