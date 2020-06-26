# with tm

library(magrittr)
library(tm)
library(tidyverse) #to be able to read the produced tibbles
library(lubridate)
library(ggplot2)
library(stopwords)
library(SnowballC)

istore_HC_de <- readRDS("2020-06-24_901397789_de_380_Reviews.RDS")

# clean the date field
istore_HC_de$review_date <- as.POSIXct(istore_HC_de$review_date, format = "%Y-%m-%dT%H:%M:%SZ")
# should be removed for further files

playstore_HC_de <- readRDS("2020-06-26_playstore_homeconnect.android_de_975_Reviews.RDS")

# let's check out the ratings
g <- ggplot(istore_HC_de)
p <- ggplot(playstore_HC_de)

g + geom_histogram(aes(x=review_date, fill=as.factor(review_star)))

# create a data frame source for the corpus

# A data frame source interprets each row of the data frame x as a document. 
# The first column must be named "doc_id" and contain a unique string identifier for each document. 
# The second column must be named "text" and contain a UTF-8 encoded string representing the document's content. 
# Optional additional columns are used as document level metadata.

#istore
size1 <- nrow(istore_HC_de)

my_df_1 <- bind_cols(doc_id = paste0("i_HC",seq(1,size1,1)), text = istore_HC_de$review_text,
                     dmeta1 = istore_HC_de$review_star, dmeta2 = istore_HC_de$review_date)
my_df_1 <- as.data.frame(my_df_1)

ds1 <- tm::DataframeSource(my_df_1)
my_corpus1 <- tm::VCorpus(ds1)

#playstore
size2 <- nrow(playstore_HC_de)

my_df_2 <- bind_cols(doc_id = paste0("G_HC",seq(1,size2,1)), text = playstore_HC_de$review_text,
                     dmeta1 = playstore_HC_de$review_star, dmeta2 = playstore_HC_de$review_date)
my_df_2 <- as.data.frame(my_df_2)

ds2 <- tm::DataframeSource(my_df_2)
my_corpus2 <- tm::VCorpus(ds2)

my_corpus <- c(my_corpus1, my_corpus2)

## inspect an element of the corpus
writeLines(as.character(my_corpus[[30]]))

## perform basic cleaning
getTransformations()

to_remove <- c("app", "home", "connect", "homeconnect", "gerät", "geräte", "geräten")

docs <- my_corpus %>%
    tm_map(removePunctuation) %>%
    tm_map(removeNumbers) %>%
    tm_map(content_transformer(tolower)) %>%
    tm_map(function(x) SnowballC::wordStem(x, language = "german")) %>%
    tm_map(removeWords, stopwords::stopwords("de", source = "stopwords-iso")) %>%
    tm_map(removeWords, to_remove)


dtm <- DocumentTermMatrix(docs, control=list(wordLengths=c(4, 100), tolower=FALSE)) 
freq <- colSums(as.matrix(dtm))
ord <- order(freq,decreasing=TRUE)
freq[ord[1:100]]
