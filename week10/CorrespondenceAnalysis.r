# What does @HealthcareGov tweet about?
# 
# References:
# 1. Mining twitter with R
# Link: https://sites.google.com/site/miningtwitter/questions/talking-about/given-users
# 2. Introduction to the tm Package
# Link: http://cran.r-project.org/web/packages/tm/vignettes/tm.pdf

library(twitteR)
library(tm)
library(cluster)
library(FactoMineR)
library(RColorBrewer)
library(ggplot2)

# Collect tweets from HealthcareGov
hcg.tweets = userTimeline("HealthcareGov", n=1500, cainfo="cacert.pem")
# extract the text from text; I'm using plyr package
hcg.text = laply(hcg.tweets, function(t) t$getText())

# clean the text
source("twitterSupport.r")
hcg.text = clean.tweets(hcg.text)

# Create Corpus
hcg.corpus = Corpus(VectorSource(hcg.text))

# convert to lower case
hcg.corpus = tm_map(hcg.corpus, tolower)
# remove stoprwords
hcg.corpus = tm_map(hcg.corpus, removeWords, c(stopwords("english"), "healthcaregov"))
# remove extra white-spaces
hcg.corpus = tm_map(hcg.corpus, stripWhitespace)

# term-document matrix
tdm = TermDocumentMatrix(hcg.corpus)
# convert as matrix
m = as.matrix(tdm)


# remove sparse terms (word frequency > 95% percentile)
wordFrequency = rowSums(m)
m1 = m[wordFrequency > quantile( wordFrequency, probs=0.95 ), ]
# remove columns with all zeros
m1 = m1[,colSums(m1) != 0]
# for convenience, every matrix entry must be binary (0 or 1)
m1[m1 > 1] = 1

# Applying cluster analysis
# distance matrix with binary distance
m1dist = dist(m1, method="binary")
# cluster with ward method
clus1 = hclust(m1dist, method="ward")
# plot dendrogram
plot(clus1, cex=0.7)


# Applying correspondance analysis
hcg.ca = CA(m1, graph=FALSE)

# plot the words
plot( hcg.ca$row$coord, type="n", xaxt="n", yaxt="n", xlab="", ylab="" )
text( hcg.ca$row$coord[,1], hcg.ca$row$coord[,2], labels=rownames(m1), col=hsv(0,0,0.6,0.5))
title( main="What does @HealthcareGov tweet about?", cex.main=1 )


# Improving visuals
# Applying clustering method; partitioning around medoids with 6 clusters
k = 6
# pam clustering
hcg.pam = pam( hcg.ca$row$coord[,1:2], k)
# get clusters
clusters = hcg.pam$clustering

# color palette
gbrew = brewer.pal(8, "Dark2")
# hsv encoding
gpal = rgb2hsv(col2rgb(gbrew))
# colors in hsv (hue, saturation, value, transparency)
gcols = rep("", k)
for (i in 1:k) {
  gcols[i] = hsv(gpal[1,i], gpal[2,i], gpal[3,i], alpha=0.65)
}


# plot with frequencies
wcex = log10(rowSums(m1))
plot( hcg.ca$row$coord, type="n", xaxt="n", yaxt="n", xlab="", ylab="" )
title( "What does @HealthcareGov tweet about?", cex.main=1 )
for (i in 1:k) {
  tmp = clusters == i
  text( hcg.ca$row$coord[tmp,1], 
        hcg.ca$row$coord[tmp,2], 
        labels=rownames(m1)[tmp], 
        cex=wcex[tmp], 
        col=gcols[i])
}


# using ggplotters
hcg.words.df = data.frame(
                          words = rownames(m1),
                          dim1 = hcg.ca$row$coord[,2],
                          dim2 = hcg.ca$row$coord[,3],
                          freq = rowSums(m1),
                          cluster = as.factor(clusters))

# plot
ggplot( hcg.words.df, aes(x=dim1, y=dim2, label=words)) +
        geom_text(aes(size=freq, colour=cluster), alpha=0.7) +
        scale_size_continuous(breaks=seq(20,80,by=10), range=c(3,8)) +
        scale_colour_manual(values=brewer.pal(8, "Dark2")) +
        labs(x="", y="") +
        labs(title = "What does @HealthcareGov tweet about?",
             plot.title = element_text(size=12),
             axis.ticks = element_blank(),
             legend.position = "none",
             axis.text.x = element_blank(),
             axis.text.y = element_blank()
        )
