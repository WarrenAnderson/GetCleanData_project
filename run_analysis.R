

# outline of key objectives:
#     	Merges the training and the test sets to create one data set.
# 	Extracts only the measurements on the mean and standard deviation for each measurement. 
# 	Uses descriptive activity names to name the activities in the data set
# 	Appropriately labels the data set with descriptive variable names. 
#	From the data set in step 4, creates a second, independent tidy data set with the average of each 		variable for each activity and each subject.

features <- read.table("features.txt") # data 561 x 2; xyz, xyz,... (variables)
activities <- read.table("activity_labels.txt") # 6 activities (6 x 2), "class"

# import training data
x <- read.table("X_train.txt") # data matrix, 7352 x 561
y <- read.table("y_train.txt") # class data (1-6), 7352 x 1
subj <- read.table("subject_train.txt") # subject names

# import testing data
xtest <- read.table("X_test.txt") # data matrix, 2947 x 561 
ytest <- read.table("y_test.txt") # data matrix, 2947 x 1

# 1. Merge the training and the test sets to create one data set.
merge1 <- as.data.frame( matrix( c(0), (nrow(x) + nrow(xtest)), (ncol(x)) ) )

indTrain <- 1:nrow(x) # training indices
indTest <- (nrow(x)+1):nrow(merge1) # testing indices
merge1[indTrain,] <- x
merge1[indTest,] <- xtest

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
indMean <- grep("mean()",features[,2])
indSd <- grep("std()",features[,2])
indsMeanSd <- sort(c(indMean, indSd))
merge2 <- merge1[,indsMeanSd]

# 3. Uses descriptive activity names to name the activities in the data set
act <- c('walk','walkUp','walkDown','sit','stand','lay')
ynew <- sapply(y, function(x) x <- act[x])
ytestnew <- sapply(ytest, function(x) x <- act[x])
merge3 <- cbind(c(ynew,ytestnew),merge2)

# 4. Appropriately labels the data set with descriptive variable names. 
varNames <- features[indsMeanSd,2]
colnames(merge3)[2:ncol(merge3)] <- as.character(varNames)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each 		variable for each activity and each subject.
tidy1 <- cbind(subj,merge3[indTrain,])
tidy2 <- as.data.frame(matrix( c(0), nrow(unique(subj))*length(act), ncol(tidy1) ))
x <- 1
for (i in 1:nrow(unique(subj))) {
	indSubj <- which(tidy1[,1] == unique(subj)[i,1])
	for (j in 1:length(act)) {
		tidy2[x,1] <- unique(subj)[i,1]
		indAct <- which(tidy1[,2]==act[j])
		indSubjAct <- intersect(indSubj,indAct)
		tidy2[x,2] <- act[j]
		tidy2[x,3:ncol(tidy2)] <- apply( data.matrix( tidy1[indSubjAct,3:ncol(tidy2)] ), 2, mean, na.rm=T )
		x <- x + 1
	}
}
colnames(tidy2)[1] <- "subject"
colnames(tidy2)[2] <- "activity"
colnames(tidy2)[3:ncol(tidy2)] <- as.character(varNames)

# output data
fname <- "projectData.txt"
write.table(tidy2,fname,row.name=FALSE) 
