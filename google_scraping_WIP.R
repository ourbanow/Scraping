PLAY_STORE_BASE_URL <- "https://play.google.com"

app_id <- "com.bshg.homeconnect.android.release"
lang <- "de"
country <- "DE"

app_url <- paste0(PLAY_STORE_BASE_URL,"/store/apps/details?id=",app_id,"&hl=",lang,"&gl=",country)

reviews_url <- paste0(PLAY_STORE_BASE_URL,"/_/PlayStoreUi/data/batchexecute?hl=",lang,"&gl=",country)