# Setup ----

# install dependencies
packages <- c("dplyr", "purrr", "httr", "rvest", "jsonlite")
install.packages(pkgs = packages)

# load dependencies
library(dplyr)
library(purrr)
library(httr)
library(rvest)
library(jsonlite)

# Website ----

# define URL
url <- "https://jobs.github.com/positions"
# request URL using GET method
response <- GET(url = url)
# check if request was successful
response$status_code == 200
# parse response
parsed_response <- content(x = response)
# find available jobs
job_nodes <- parsed_response %>% html_elements("tr.job")
# define function to extract information
extract_job <- function(job) {
  title <- job %>% html_element("td.title h4") %>% html_text()
  url <- job %>% html_element("td.title h4 a") %>% html_attr("href")
  company <- job %>% html_element("td.title p a") %>% html_text()
  return(data.frame(
    title = title,
    url = url,
    company = company
  ))
}
# map function to all extracted nodes
job_list <- map_dfr(job_nodes, extract_job)

# API ----

# define URL
url <- "https://jobs.github.com/positions.json"
# request URL using GET method
response <- GET(url = url)
# check if request was successful
response$status_code == 200
# parse response
text_response <- content(x = response, as = "text")
parsed_response <- fromJSON(txt = text_response)


# GET Request ----

# define URL
url <- "https://httpbin.org/get"
# request URL using GET method
response <- GET(url = url)
# check if request was successful
response$status_code == 200
# parse response
text_response <- content(x = response, as = "text")
parsed_response <- fromJSON(txt = text_response)

# define URL
url <- "https://httpbin.org/get/test"
# request URL using GET method
response <- GET(url = url)
# check if request was successful
response$status_code == 200
# check if page exists
response$status_code == 404

# add query parameters to the URL
url <- "https://httpbin.org/get"
url <-  parse_url(url = url)
url$query <- list(page = 2,
                  limit = 100,
                  hello = "world")
url <- build_url(url = url)
# request URL using GET method
response <- GET(url = url)
# check if request was successful
response$status_code == 200
# parse response
text_response <- content(x = response, as = "text")
parsed_response <- fromJSON(txt = text_response)


# POST Request ----

url <- "https://httpbin.org/post"
# request URL using GET method
response <- POST(url = url,
                 body = list(username = "Jan", password = "code"))
# check if request was successful
response$status_code == 200
# parse response
text_response <- content(x = response, as = "text")
parsed_response <- fromJSON(txt = text_response)
