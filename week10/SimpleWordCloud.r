# This script creates a simple Wordcloud of tweets containing '@HealthCareGov'
# The original concept is from Mining twitter with R
# Link: https://sites.google.com/site/miningtwitter/questions/talking-about/wordclouds/wordcloud1

library(twitteR)
library(plyr)
library(tm)
library(wordcloud)
library(RColorBrewer)

#necessary step for Windows
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

# authorization required since API v1.1
reqURL =    "https://api.twitter.com/oauth/request_token"
accessURL = "http://api.twitter.com/oauth/access_token"
authURL =   "http://api.twitter.com/oauth/authorize"
consumerKey = "MoqjEx6FcZ96AqWIJpXg"
consumerSecret = "KR81nPWzRP9n1jkxrPMzMVWfGqELrXOlmpmOa521gtk"
twitCred = OAuthFactory$new(consumerKey = consumerKey,
                            consumerSecret = consumerSecret,
                            requestURL = reqURL,
                            accessURL = accessURL,
                            authURL = authURL)

#necessary setup for Windows
twitCred$handshake(cainfo="cacert.pem")
registerTwitterOAuth(twitCred)
#save for later user for Windows
save(list="twitCred", file ="twitteR_credentials")

# Get the tweets containing the word "@HealthCareGov"
#the cainfo parameter is necessary on Windows
hcgov.tweets = searchTwitter('@HealthCareGov', n=1500, cainfo="cacert.pem")

# extract the text from text; I'm using plyr package
hcgov.text = laply(hcgov.tweets, function(t) t$getText())

# clean the text
source("twitterSupport.r")
hcgov.text = clean.tweets(hcgov.text)

# create a corpus; using tm package
hcgov.corpus = Corpus(VectorSource(hcgov.text))

# create term-document matrix; remove healtcaregov and other generic words
tdm = TermDocumentMatrix(hcgov.corpus,
                         control = list(removePunctuation = TRUE,
                                        stopwords = c("healthcaregov", stopwords("english")),
                                        removeNumbers = TRUE, 
                                        tolower = TRUE))

# define tdm as matrix
m = as.matrix(tdm)
# get word counts in decreasing order
word.freqs = sort(rowSums(m), decreasing=TRUE)
# create a data frame with words and their frequencies
dm = data.frame(word=names(word.freqs), freq=word.freqs)

# plot wordcloud
wordcloud(dm$word, dm$freq, random.order=FALSE,
          colors=brewer.pal(8, "Dark2"))



