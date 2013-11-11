# This script creates a simple Wordcloud of tweets containing '@HealthCareGov'
# The original concept is from Mining twitter with R
# Link: https://sites.google.com/site/miningtwitter/questions/talking-about/wordclouds/wordcloud1

library(twitteR)
library(plyr)
library(tm)
library(wordcloud)
library(RColorBrewer)


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



