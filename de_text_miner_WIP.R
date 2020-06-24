library(magrittr)
library(tm)
library(tidyverse) #to be able to read the produced tibbles
library(lubridate)
library(ggplot2)

Home_connect_de <- readRDS("2020-06-24_901397789_de_380_Reviews.RDS")

# clean the date field
Home_connect_de$review_date <- as.POSIXct(Home_connect_de$review_date, format = "%Y-%m-%dT%H:%M:%SZ")

# let's check out the ratings
g <- ggplot(Home_connect_de)
g + geom_histogram(aes(x=review_star))

g + geom_histogram(aes(x=review_date, fill=as.factor(review_star)))

# create a data frame source for the corpus

# A data frame source interprets each row of the data frame x as a document. 
# The first column must be named "doc_id" and contain a unique string identifier for each document. 
# The second column must be named "text" and contain a UTF-8 encoded string representing the document's content. 
# Optional additional columns are used as document level metadata.

size <- nrow(Home_connect_de)

my_df_1 <- bind_cols(doc_id = paste0("HC",seq(1,size,1)), text = Home_connect_de$review_text,
                     dmeta1 = Home_connect_de$review_title,
                     dmeta2 = Home_connect_de$review_star, dmeta3 = Home_connect_de$review_date)
my_df_2 <- as.data.frame(my_df_1)

ds <- tm::DataframeSource(my_df_2)
my_corpus <- tm::Corpus(ds)

## inspect an element of the corpus
writeLines(as.character(my_corpus[[30]]))

## perform basic cleaning
getTransformations()

docs <- tm_map(my_corpus, removePunctuation)
dtm <- DocumentTermMatrix(docs, control=list(wordLengths=c(5, 100))) 
freq <- colSums(as.matrix(dtm))
ord <- order(freq,decreasing=TRUE)
freq[ord[1:100]]
head(freq)
