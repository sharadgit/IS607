# How do you feel about Obamacare? 

library(twitteR)
library(plyr)
library(tm)
library(wordcloud)
library(RColorBrewer)

# load the words
hu.liu.pos = scan("./data/positive-words.txt", what="character", comment.char=";")
hu.liu.neg = scan("./data/negative-words.txt", what="character", comment.char=";")

# add industry specific words
pos.words = c(hu.liu.pos, "upgrade")
neg.words = c(hu.liu.neg, "wtf", "wait", "waiting", "epicfail", "mechanical")


#the cainfo parameter is necessary on Windows
obamacare.tweets = searchTwitter('#Obamacare', n=1500, cainfo="cacert.pem")
obamacare.text = laply(obamacare.tweets, function(t) t$getText() )

# clean the text
source("twitterSupport.r")
obamacare.text = clean.tweets(obamacare.text)


obamacare.scores = score.sentiment(obamacare.text,
                                  pos.words,
                                  neg.words,
                                  .progress='text')

hist(obamacare.scores$score)
qplot(obamacare.scores$score)
summary(scores)


