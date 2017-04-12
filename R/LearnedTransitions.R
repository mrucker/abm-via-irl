#     action 1, move short distance
#     action 2, move long distance
#     action 3, start conversation
#     action 4, continue conversation

#install.packages("randomForest")

library(MASS) #lda(), head(), tail()
library(randomForest) #randomForest

data = read.csv("./SampleTrajectories.csv")

nrow(data[data$Breed == "unbiased-people",])
nrow(data[data$Breed == "biased-people",])
nrow(data[data$Breed == "racists",])

unique(data[data$Breed == "racists", ]$AgentID)

#get the racists ready to examine
racists = data[data$Breed == "racists",-c(1,2,7)] #all racists without AgentID, Episode and Breed
racists$length_change = c(tail(racists, -1)$Conversation_Length - head(racists,-1)$Conversation_Length,NA)
racists = head(racists,-1) # all but the last row since it doesn't transition
racists[racists$length_change < 0, ]$length_change = -100 #treat all negatives as the same since they all reset to 0
racists$length_change = as.factor(racists$length_change) # make our observed change in conversation length a factor

unique(racists$length_change)

lda.fit = lda(length_change~., data=racists)
qda.fit = qda(length_change~., data=racists) #doesn't work
rfo.fit = randomForest(length_change~.,data=racists)

#look at improperly classified state actions change values
racists[(predict(lda.fit, newdata=racists)$class != racists[,"length_change"]),]
sum(predict(lda.fit, newdata=racists)$class == racists[,"length_change"])
sum(predict(qda.fit, newdata=racists)$class == racists[,"length_change"])

test = data.frame(Conversation_Length=c(4), Conversation_With_Like=c(0), People_Around_To_Talk=c(1), Action=c(2))
predict(rfo.fit, newdata=test, type="prob")
predict(lda.fit, newdata=test)$posterior

