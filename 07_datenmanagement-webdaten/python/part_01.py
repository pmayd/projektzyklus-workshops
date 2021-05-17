# import type hints
from typing import Dict

# import dependencies
import requests
import pandas as pd
from bs4 import BeautifulSoup

# Scrape website

# define URL
url = "https://jobs.github.com/positions"
# request URL using GET method
response = requests.get(url=url)
# check if request was successful
response.status_code == 200
# parse response
parsed_response = BeautifulSoup(markup=response.text, features="html.parser")
# find available jobs
job_nodes = parsed_response.find_all(name="tr", class_="job")


# define function to extract information
def extract_jobs(job: BeautifulSoup) -> Dict:
    """
    Extract job properties from a bs4 node.

    :param job: Bs4 job node
    :return: Dictionary including title, url, company
    """
    return {
        "title": job.find(name="h4").get_text(),
        "url": job.find(name="h4").find(name="a").get("href"),
        "company": job.find(name="p").find(name="a").get_text()
    }


# map function to all extracted nodes
job_list = [extract_jobs(job) for job in job_nodes]
# optionally the job list can be used to create a data frame
job_df = pd.DataFrame.from_records(data=job_list)

# API

# define URL
url = "https://jobs.github.com/positions.json"
# request URL using GET method
response = requests.get(url=url)
# check if request was successful
response.status_code == 200
# parse response
parsed_response = response.json()
# optionally the parsed_response can be used to create a data frame
job_df = pd.DataFrame.from_records(data=parsed_response)

# GET Request ----

# define URL
url = "https://httpbin.org/get"
# request URL using GET method
response = requests.get(url=url)
# check if request was successful
response.status_code == 200
# parse response
parsed_response = response.json()

# define URL
url = "https://httpbin.org/get/test"
# request URL using GET method
response = requests.get(url=url)
# check if request was successful
response.status_code == 200
# check if page exists
response.status_code == 404

# add query parameters to the URL
url = "https://httpbin.org/get"
# define query parameter
query = {
    "page": 2,
    "limit": 100,
    "hello": "world"
}
# request URL using GET method
response = requests.get(url=url, params=query)
# check if request was successful
response.status_code == 200
# parse response
parsed_response = response.json()

# POST Request ----

url = "https://httpbin.org/post"
# request URL using GET method
response = requests.post(url=url,
                         data={"username": "Jan", "password": "code"})
# check if request was successful
response.status_code == 200
# parse response
parsed_response = response.json()
