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
       page = page_num) %>% return()


# Results: 
#1. only loads the 3 first results
#2. can't identify the star ratings
#3. loads the answers as separate reviews (title and text but not the date)
