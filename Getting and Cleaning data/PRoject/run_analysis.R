#Insturctions
# You should create one R script called run_analysis.R that does the following.
# 
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# Good luck!

#file has been downloaded, extracted and is in the R-directory

#Loading the package
a<-c("data.table", "reshape2")
sapply(a, require, character.only = TRUE, quietly = TRUE)

#Loading the dataset and labels as variables (Activity)
aL<- fread(file.path(getwd(), "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityNames"))

fr<-fread(file.path(getwd(), "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))

frw<-grep("(mean|std)\\(\\)", fr[, featureNames])

mst<-fr[frw, featureNames]

mst<-gsub('[()]', '', mst)

#Loading the dataset and labels as variables (Training)

tr<-fread(file.path(getwd(), "UCI HAR Dataset/train/X_train.txt"))[, frw, with=FALSE ]

data.table::setnames(tr, colnames(tr), mst)

trAct <- fread(file.path(getwd(), "UCI HAR Dataset/train/y_train.txt"), col.names = c("Activity"))

trSub<- fread(file.path(getwd(), "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))

tr <- cbind(trAct, trSub, tr)

##Loading the dataset and labels as variables (Test)

tst<-fread(file.path(getwd(), "UCI HAR Dataset/test/X_test.txt"))[, frw, with=FALSE ]

data.table::setnames(tst, colnames(tst), mst)

tstAct <- fread(file.path(getwd(), "UCI HAR Dataset/test/y_test.txt"), col.names = c("Activity"))

tstSub<- fread(file.path(getwd(), "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))

tst <- cbind(tstAct, tstSub, tst)

#Now merging test and train datasets as required in the instructions


tot <- rbind(tr, tst)



#Changing the classLabels to activity names and writing the output as tidyData.txt


tot[["Activity"]]<- factor(tot[, Activity], levels=aL[["classLabels"]], labels = aL[["activityNames"]])

tot[["SubjectNum"]] <- as.factor(tot[, SubjectNum])



tot <- reshape2::melt(data = tot, id = c("SubjectNum", "Activity"))

tot <- reshape2::dcast(data = tot, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = tot, file = "tidyData.txt", quote = FALSE )