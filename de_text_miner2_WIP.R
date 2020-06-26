#with quanteda

library(tidyverse)
library(quanteda)
library(stopwords)
library(ggplot2)
library(RColorBrewer)

playstore_HC_de <- readRDS("2020-06-26_playstore_homeconnect.android_de_975_Reviews.RDS")
istore_HC_de <- readRDS("2020-06-26_istore_901397789_de_380_Reviews.RDS")
istore_HC_at <- readRDS("2020-06-26_istore_901397789_AT_20_Reviews.RDS")

#manual fix fot playstore titles
playstore_HC_de$review_title <- as.character(playstore_HC_de$review_title)

all_reviews <- bind_rows(playstore_HC_de, istore_HC_de, istore_HC_at)

# check how it looks
g <- ggplot(all_reviews)
g + geom_density(aes(x=review_date, color=as.factor(review_star)))

create_corpus <- function(reviews_df){
    corpus(reviews_df, docid_field = "review_title", text_field = "review_text", meta = list(source=reviews_df), unique_docnames = FALSE)
} 
summary(my_corpus)

kwic(my_corpus, pattern="funktioniert")

good <- corpus_subset(my_corpus, review_star > 3)
bad <- corpus_subset(my_corpus, review_star < 3)

## words to remove

to_remove <- setdiff(c(stopwords::stopwords("de", source = "stopwords-iso"),"app"
                       , "gerät", "geräte", "geräten", "lässt", "echt", "€", "per", "läuft", "finde", "bitte"), c("nicht", "nichts", "nie"))
brands <- c("bosch", "siemens", "home", "connect", "homeconnect", "cookit" )

negativ <- c("funktioniert nicht", "nicht funktioniert",
             "funktioniert leider", "leider funktioniert")
negativ_ <-c("funktioniert_nicht", "nicht_funktioniert",
            "funktioniert_leider", "leider_funktioniert")
positiv <- c("funktioniert super", "funktioniert wunderbar",
            "funktioniert einwandfrei", "funktioniert perfekt")

createtokens <- function(corpus){
    toks <- corpus %>%
        char_tolower() %>%
        tokens(remove_punct=TRUE, remove_url = TRUE, remove_symbols = FALSE, remove_numbers = TRUE) %>%
        tokens_remove(pattern="^[<#@]<.+$", valuetype = "regex") %>%
        tokens_compound(pattern = phrase(c(negativ, positiv))) %>%
        tokens_remove(to_remove)%>%
        tokens_remove(brands) %>%
        tokens_compound(pattern = phrase(c(negativ,positiv))) %>%
        tokens_replace(negativ_, rep("funktioniert_nicht", 4)) %>%
        tokens_remove(c("nicht", "nichts", "nie"))
    toks
}

creatematrix <- function(corpus){
    toks <- createtokens(corpus)
    dfm_1 <- dfm(toks)
    dfm_1
}

topwords <- function(corpus){
    dfm_1 <- creatematrix(corpus)
    textplot_wordcloud(dfm_1, max_words= 50, random_order = FALSE,
                       rotation = .25,
                       color = RColorBrewer::brewer.pal(8, "Dark2"))
}

dfm_2 <- creatematrix(my_corpus)
df <- convert(data, to= "data.frame", row.names = NULL)

df_2 <-df[df$update==0,]

reviews_subset <- all_reviews[which(df$update == 0),]
corpus_2 <- create_corpus(reviews_subset)

#####

toks_2 <- createtokens(corpus_2)


kwic(toks_2, pattern = "funktioniert")

topwords(corpus_2)

good_2 <- corpus_subset(corpus_2, review_star > 3)
topwords(good_2)
bad_2 <- corpus_subset(corpus_2, review_star < 4)
topwords(bad_2)

mittel_2 <- corpus_subset(corpus_2, review_star %in% c(3,4))
topwords(mittel_2)
