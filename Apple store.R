# apple store

library(rvest)
library(tidyverse)
library(data.table)

url_reviews <- "https://apps.apple.com/fr/app/home-connect-app/id901397789#see-all/reviews"
doc <- read_html(url_reviews)

# Review Title
doc %>%
    html_nodes("[class='we-truncate we-truncate--single-line ember-view we-customer-review__title']") %>%
    html_text() -> review_title

# Review Date
doc %>%
    html_nodes("[class='we-customer-review__date']") %>%
    html_text() -> review_date

# Review Text
doc %>% 
    html_nodes("[class='we-truncate we-truncate--multi-line we-truncate--interactive ember-view we-customer-review__body']") %>%
    html_text() -> review_text

# Number of stars in review
doc %>%
    html_nodes("[???='???']") %>% # how to retrieve this?
    html_text() -> review_star

# Return a tibble
tibble(review_title,
       review_date,
       review_text,
       page = page_number) %>% return()


# Results: 
#1. only loads the 3 first results
#2. can't identify the star ratings
#3. loads the answers as separate reviews (title and text but not the date)


# second try
# https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html

library(httr)
offset <- 0
country <- "de"
app_id <- 901397789
url_reviews <- paste0("https://amp-api.apps.apple.com/v1/catalog/",country,"/apps/", app_id,"/reviews?l=en-US&offset=",offset,"0&platform=web&additionalPlatforms=appletv%2Cipad%2Ciphone%2Cmac")

r<- httr::GET(url_reviews, add_headers('authorization'='Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlYlBsYXlLaWQifQ.eyJpc3MiOiJBTVBXZWJQbGF5IiwiaWF0IjoxNTkxNzI2MDEyLCJleHAiOjE2MDcyNzgwMTJ9.PF8vc_52NGR-o-E8N-kXKAuky0ikAMmBS79H0oHdbfYtXIxuqeRWhAtvNfmPTwlUs3-o2RHhxNvQGSQ46lk27w'))
retrieve_raw <- content(r, "text", encoding="UTF-8")
retrieve_data <- fromJSON(retrieve_raw)
my_reviews <- retrieve_data[[2]][[3]]
my_reviews$date

# retrieve: date, title, rating, review

## WORKS

scrape_iappstore <- function(app_id, country, page_number = 1){
    offset <- page_number-1
    url_reviews <- paste0("https://amp-api.apps.apple.com/v1/catalog/",country,"/apps/",app_id,"/reviews?l=en-US&offset=",offset,"0&platform=web&additionalPlatforms=appletv%2Cipad%2Ciphone%2Cmac")
    
    r<- httr::GET(url_reviews, add_headers('authorization'='Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlYlBsYXlLaWQifQ.eyJpc3MiOiJBTVBXZWJQbGF5IiwiaWF0IjoxNTkxNzI2MDEyLCJleHAiOjE2MDcyNzgwMTJ9.PF8vc_52NGR-o-E8N-kXKAuky0ikAMmBS79H0oHdbfYtXIxuqeRWhAtvNfmPTwlUs3-o2RHhxNvQGSQ46lk27w'))
    retrieve_raw <- content(r, "text", encoding="UTF-8")
    retrieve_data <- fromJSON(retrieve_raw)
    my_reviews <- retrieve_data[[2]][[3]]
    
    # Retrieve data
    review_title <- my_reviews$title
    review_date <- my_reviews$date
    review_star <- my_reviews$rating
    review_text <- my_reviews$review
    
    # Return a tibble
    tibble(review_title,
           review_date,
           review_star,
           review_text,
           page = page_number) %>% return()
    
}

country <- "de"
app_id <- 901397789
page_number <- 3 

scrape_iappstore(app_id, country, page_number)

## WOOOOORKS

# phase 2: timer
page_range <- 1:10

match_key <- tibble(n= page_range,
                    key = sample(page_range, length(page_range)))

lapply(page_range, function(i){
    j <- match_key[match_key$n==i,]$key
    
    message("Getting page ",i, " of ",length(page_range), "; Actual: page ",j) # Progress bar
    
    Sys.sleep(3) # Take a three second break
    
    if((i %% 3) == 0){ # After every three scrapes... take another two second break
        
        message("Taking a break...") # Prints a 'taking a break' message on your console
        
        Sys.sleep(2) # Take an additional two second break
    }
    scrape_iappstore(app_id, country, page_number = j)
}) -> output_list