clean.tweets = function(tweets)
{
    require(stringr)

    # apply scrubbing to all tweets
    cleanTweets = sapply(tweets, function(tweet) {
      
      # clean up sentences with R's regex-driven global substitute, gsub():
      
      # remove retweet entities
      tweet = gsub("(RT|Via) ((?:\\b\\W*@\\w+)+)", "", tweet)
      # remove Atpeople
      tweet = gsub("@\\w+", "", tweet)
      # remove punctuation symbols
      tweet = gsub("[[:punct:]]", "", tweet)
      # remove numbers
      tweet = gsub("[[:digit:]]", "", tweet)
      # remove control characters
      tweet = gsub("[[:cntrl:]]", "", tweet)
      # remove links; unfortunately this does not remove links \\w is not a match for urls
      tweet = gsub("http\\w+", "", tweet)
      
      # and convert to lower case:
      tweet = tolower(tweet)
      
      return(tweet)
    })
    
    return(cleanTweets)  
}

# This function is borrowed from Jeffrey Breen's blog on sentiment analysis
# Link: http://jeffreybreen.wordpress.com/2011/07/04/twitter-text-mining-r-slides/
# 
score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
  require(plyr)
  require(stringr)
  
  # we got a vector of sentences. plyr will handle a list or a vector as an "l" for us
  # we want a simple array of scores back, so we use "l" + "a" + "ply" = laply:
  scores = laply(sentences, function(sentence, pos.words, neg.words) {
    
      # split into words. str_split is in the stringr package
      word.list = str_split(sentence, '\\s+')
      # sometimes a list() is one level of hierarchy too much
      words = unlist(word.list)
      
      # compare our word to the dictionaries of positive & negative terms
      pos.matches = match(words, pos.words)
      neg.matches = match(words, neg.words)
      
      # match() returns the position of the matched term or NA
      # we just want a TRUE/FALSE:
      pos.matches = !is.na(pos.matches)
      neg.matches = !is.na(neg.matches)
      
      # and conveniently enough, TRUE/FALSE wll be treated as 1/0 by sum():
      score = sum(pos.matches) - sum(neg.matches)
      
      return(score)
  }, pos.words, neg.words, .progress=.progress )
  
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}