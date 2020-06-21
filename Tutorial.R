# tutorial from https://martinctc.github.io/blog/vignette-scraping-amazon-reviews-in-r/


library(rvest)
library(tidyverse)
library(data.table)

#smartwatch url
productnumber <- "B07VXR49ZD"
producturl <- "https://www.amazon.de/dp/B07VXR49ZD"
    
scrape_amazon <- function (ASIN, page_num){
    
    url_reviews <- paste0("https://www.amazon.de/product-reviews/",ASIN,"/?pageNumber=",page_num)
    
    doc <- read_html(url_reviews)
    
    # Review Title
    doc %>%
        html_nodes("[class='a-size-base a-link-normal review-title a-color-base review-title-content a-text-bold']") %>%
        html_text() -> review_title
    
    # Review Date
    doc %>%
        html_nodes("[data-hook='review-date']") %>%
        html_text() -> review_date
    
    # Review Text
    doc %>% 
        html_nodes("[data-hook='review-body']") %>%
        html_text() -> review_text
    
    # Number of stars in review
    doc %>%
        html_nodes("[data-hook='review-star-rating']") %>%
        html_text() -> review_star
    
    # Return a tibble
    tibble(review_title,
           review_date,
           review_text,
           review_star,
           page = page_num) %>% return()
}

first_page <- scrape_amazon("B07VXR49ZD",1)

# check number of reviews of a product

reviews_number <- function(ASIN){
    url_review <- paste0("https://www.amazon.de/product-reviews/",ASIN,"/?pageNumber=1")
    doc <- read_html(url_review)
    # Retrieve info
    doc %>%
        html_nodes("[data-hook='cr-filter-info-review-count']") %>%
        html_text() -> pages_number
    pages_number
    strsplit(pages_number, " ")[[1]][3]
}
reviews_number(productnumber)

# Alle Herde: https://www.amazon.de/b/?node=1399926031  
# best sellers: https://www.amazon.de/gp/bestsellers/appliances/1399926031

#test

doc1 <- read_html("https://www.amazon.de/product-reviews/B07VXR49ZD?pageNumber=1")
doc1 %>%
    html_nodes("[class='a-size-base a-color-secondary review-date']") %>%
    html_text() -> review_date1

review_date1

doc20 <- read_html("https://www.amazon.de/product-reviews/B07VXR49ZD?pageNumber=20")
doc20 %>%
    html_nodes("[data-hook='review-date']") %>%
    html_text() -> review_date20

review_date20