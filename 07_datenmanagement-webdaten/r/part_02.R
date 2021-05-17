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

# Basic Authentication ----

# define URL
url <- "https://httpbin.org/basic-auth/correlaid/password"
# request URL using GET method
response <- GET(url = url)
# check if request was successful
response$status_code == 200

# define authorization header
auth_header <- paste("Basic ", base64_enc("correlaid:password"))
# request URL using GET method adding authorization header
response <- GET(url = url, 
                add_headers("Authorization" = auth_header))
# parse response
text_response <- content(x = response, as = "text")
parsed_response <- fromJSON(txt = text_response)

# request URL using GET method using authenticate function
response <- GET(url = url,
                authenticate(user = "correlaid",
                             password = "pass",
                             type = "basic"))
# parse response
text_response <- content(x = response, as = "text")
parsed_response <- fromJSON(txt = text_response)

# Bearer Authentication ----

# define URL
url <- "https://httpbin.org/bearer"
# define a JSON web token (JWT)
jwt <- "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiQ29ycmVsQWlkIiwiaWQiOiI1YmRmNmMwYy03ODMzLTRjNWUtOTVkYy01YjA3YTRjMDIxYjIifQ.waEwnRZ8lcryPHLjAVOqFOBx6TqrOkkHWxCl6Dfjecw"
# request URL using GET method adding authorization header
response <- GET(url = url, 
                add_headers("Authorization" = paste("Bearer ", jwt)))

# define a function to decode a JWT
decode_jwt <- function(jwt) {
  payload <- strsplit(jwt, ".", fixed = TRUE)[[1]][2]
  decoded_payload <- rawToChar(base64url_decode(payload))
  return(fromJSON(txt = decoded_payload))
}
decode_jwt(jwt = jwt)


# Error handling ----

request_authentication <- function(user, password) {
  # request URL using GET method adding authorization header
  response <- GET(url = "https://httpbin.org/basic-auth/correlaid/password",
                  authenticate(user = user,
                               password = password,
                               type = "basic"))
  # parse response
  text_response <- content(x = response, as = "text")
  parsed_response <- fromJSON(txt = text_response)
  # return authenticated key
  return(parsed_response$authenticated)
}

request_url <- function(url) {
  # request URL
  response <- GET(url = url)
  # return result if successful
  if (response$status_code <= 399) {
    # show response status message
    message(paste("Request was successful:", response$status_code))
    # parse response
    text_response <- content(x = response, as = "text")
    parsed_response <- fromJSON(txt = text_response)
    return(parsed_response)
  } 
  # if 403 replace URL and call function again
  else if (response$status_code == 403) {
    # show response status message
    message(paste("Request was not successful:", response$status_code))
    # replace URL
    url <- "https://httpbin.org/json"
    # sleep to be polite
    Sys.sleep(2)
    # call same function recursively
    request_url(url = url)
  } 
  # if 401 login and replace URL
  else if (response$status_code == 401) {
    # show response status message
    message(paste("Request was not successful:", response$status_code))
    # authenticate
    request_authentication(user = "correlaid", password = "password")
    # replace URL
    url <- "https://httpbin.org/status/403"
    # sleep to be polite
    Sys.sleep(2)
    # call same function recursively
    request_url(url = url)
  }
  # if any other status throw error 
  else {
    # show response status message
    message(paste("Request was not successful:", response$status_code))
    # throw error
    warn_for_status(x = response)
    return(NULL)
  }
}

# try 200
url <- "https://httpbin.org/json"
response <- request_url(url = url)

# try 403
url <- "https://httpbin.org/status/403"
response <- request_url(url = url)

# try 401
url <- "https://httpbin.org/status/401"
response <- request_url(url = url)

# try 500
url <- "https://httpbin.org/status/500"
response <- request_url(url = url)

