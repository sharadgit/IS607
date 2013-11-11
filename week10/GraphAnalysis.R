# Tweet analysis using iGraph
# References:
# Social Network Analysis
# Link: http://www.rdatamining.com/examples/social-network-analysis

library(twitteR)
library(plyr)
library(tm)
library(igraph)
library(RColorBrewer)

#the cainfo parameter is necessary on Windows
obamacare.tweets = searchTwitter('#Obamacare', n=1500, cainfo="cacert.pem")
obamacare.text = laply(obamacare.tweets, function(t) t$getText() )

# clean the text
source("twitterSupport.r")
hcgov.text = clean.tweets(hcgov.text)


# create a corpus
obamacare.corpus = Corpus(VectorSource(obamacare.text))

# create document term matrix applying some transformations
tdm = TermDocumentMatrix(obamacare.corpus,
                         control = list(removePunctuation = TRUE,
                                        stopwords = c("obamacare", stopwords("english")),
                                        removeNumbers = TRUE, tolower = TRUE))

# define tdm as matrix
m = as.matrix(tdm)

# Matrix with frequent words
wc = rowSums(m)

# set the limit for popular words; 0.96 seems high, but it took a few iterations to get a decent graph
lim = quantile(wc, probs=0.96)
good = m[wc > lim,]

# remove columns with all zeroes
good = good[,colSums(good) != 0]
# Get an ajacency matrix
M = good %*% t(good)
# set zeroes in diagonal
diag(M) = 0


# graph
g = graph.adjacency(M, weighted=TRUE, mode="undirected", add.rownames=TRUE)

# layout
glay = layout.fruchterman.reingold(g)

# superimpose a cluster structure with k-means clustering
kmg = kmeans(M, centers=8)
gk = kmg$cluster

# set color palette
# create nice colors for each cluster
gbrew = c("red", brewer.pal(8, "Dark2"))
gpal = rgb2hsv(col2rgb(gbrew))
gcols = rep("", length(gk))
for (k in 1:8) {
  gcols[gk == k] = hsv(gpal[1,k], gpal[2,k], gpal[3,k], alpha=0.5)
}

# Create the graph
V(g)$size = 10
V(g)$label = V(g)$name
V(g)$degree = degree(g)
V(g)$label.cex = 1.5 * log10(V(g)$degree)
V(g)$label.color = hsv(0, 0, 0.2, 0.55)
V(g)$frame.color = NA
V(g)$color = gcols
E(g)$color = hsv(0, 0, 0.7, 0.3)

# plot
plot(g, layout=glay)
title("\nLet's talk about Obamacare", col.main="gray40", cex.main=1.5, family="serif")

