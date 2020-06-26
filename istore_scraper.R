library(httr)
library(data.table)
library(tidyverse)
library(jsonlite)

# Individual page scraper

scrape_istore_page <- function(app_id, country, page_number = 1){
    offset <- page_number-1
    url_reviews <- paste0("https://amp-api.apps.apple.com/v1/catalog/",country,"/apps/",app_id,"/reviews?l=en-US&offset=",offset,"0&platform=web&additionalPlatforms=appletv%2Cipad%2Ciphone%2Cmac")
    
    r<- httr::GET(url_reviews, add_headers('authorization'='Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlYlBsYXlLaWQifQ.eyJpc3MiOiJBTVBXZWJQbGF5IiwiaWF0IjoxNTkxNzI2MDEyLCJleHAiOjE2MDcyNzgwMTJ9.PF8vc_52NGR-o-E8N-kXKAuky0ikAMmBS79H0oHdbfYtXIxuqeRWhAtvNfmPTwlUs3-o2RHhxNvQGSQ46lk27w'))
    retrieve_raw <- content(r, "text", encoding="UTF-8")
    retrieve_data <- fromJSON(retrieve_raw)
    my_reviews <- retrieve_data[[2]][[3]]
    
    # Retrieve data
    review_title <- my_reviews$title
    review_date <- as.POSIXct(my_reviews$date, format = "%Y-%m-%dT%H:%M:%SZ")
    review_star <- my_reviews$rating
    review_text <- my_reviews$review
    
    # Return a tibble
    tibble(review_title,
           review_date,
           review_star,
           review_text) %>% return()
    
}

# Full scraper
scrape_istore <- function(app_id, country, total_pages){
    message("Total number of pages:",total_pages)
    page_range <- 1:total_pages
    match_key <- tibble(n = page_range,
                        key = sample(page_range, length(page_range)))
    
    scraped_list <- lapply(page_range, function(i){
        j <- match_key[match_key$n==i,]$key
        
        message("Getting page ",i, " of ",length(page_range), "; Actual: page ",j) # Progress bar
        
        Sys.sleep(3) # Take a three second break
        
        if((i %% 3) == 0){ # After every three scrapes... take another two second break
            
            message("Taking a break...") # Prints a 'taking a break' message on your console
            
            Sys.sleep(2) # Take an additional two second break
        }
        scrape_istore_page(app_id, country, page_number = j)
    })
    message("Reviews retrieved. Binding tibble...")
    full_tibble <- scraped_list[[1]]
    for (val in 2:length(scraped_list)){
        full_tibble <- bind_rows(full_tibble, scraped_list[[val]])
    }
    filename <- paste0(Sys.Date(),"_istore_",app_id,"_",country,"_",dim(full_tibble)[1],"_Reviews.RDS")
    saveRDS(full_tibble, file = filename)
    message("Saved file ",filename)
}