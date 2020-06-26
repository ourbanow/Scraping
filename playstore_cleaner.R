# load google reviews

library(jsonlite)
library(tidyverse) 

clean_playstore_reviews <- function(reviews_file, app_id, country){
    rawfile <- fromJSON(txt = reviews_file)

    # Retrieve data
    review_title <- rawfile$score # There is no title
    review_date <- as.POSIXct(rawfile$at, format = "datetime.datetime(%Y, %m, %d, %H, %M, %S)")
    review_star <- rawfile$score
    review_text <- rawfile$content
    
    # Return a tibble
    my_tibble <- tibble(review_title,
           review_date,
           review_star,
           review_text)

    filename <- paste0(Sys.Date(),"_playstore_",app_id,"_",country,"_",dim(my_tibble)[1],"_Reviews.RDS")
    saveRDS(my_tibble, file = filename)
    message("Saved file ",filename)
    } 

