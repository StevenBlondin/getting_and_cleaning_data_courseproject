#load necessary packages
library(plyr)
library(dplyr)

###Download working data package###
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "dataset.zip"
download.file(url, fileName, method="curl")

###unzip and set working directory
workingDirectory <- "UCI HAR Dataset"
unzip(fileName)
setwd(workingDirectory)


###Begin 1. Merges the training and the test sets to create one data set.###
#read data in from "X_train" dataset
X_train <- read.table("train/X_train.txt")

#read data in from "y_train" dataset
y_train <- read.table("train/y_train.txt")

#read data in from "subject_train" dataset
subject_train <- read.table("train/subject_train.txt")

#read data in from "X_test" dataset
X_test <- read.table("test/X_test.txt")

#read data in from "y_test" dataset
y_test <- read.table("test/y_test.txt")

#read data in from "subject_test" dataset
subject_test <- read.table("test/subject_test.txt")

#merge the "X" datasets
X_merged_data <- rbind(X_train, X_test)

#merge the "y" datasets
y_merged_data <- rbind(y_train, y_test)

#merge the "subject" datasets
merged_subject_data <- rbind(subject_train, subject_test)

###Begin 2. Extracts only the measurements on the mean and standard deviation for each measurement.###
#read in the features dataset
features <- read.table("features.txt")

#isolate columns that pertain to "mean" and "standard deviation"
mean_and_stdev_features <- grep("-(mean|std)\\(\\)", features[, 2])

#subset the required columns into X_merged_data.  X_merged_data as it was, is replaced by this new result.
X_merged_data <- X_merged_data[, mean_and_stdev_features, 2]

#fix column headings
names(X_merged_data) <- features[mean_and_stdev_features, 2]

###Begin 3. Uses descriptive activity names to name the activities in the data set###
#read in activity labels
activity_labels <- read.table("activity_labels.txt")

#assign activity labels to y
y_merged_data[, 1] <- activity_labels[y_merged_data[, 1], 2]

#correct column name
names(y_merged_data) <- "activity"

###Begin 4. Appropriately labels the data set with descriptive variable names.###
names(merged_subject_data) <- "subject"

single_dataset <- cbind(X_merged_data, y_merged_data, merged_subject_data)


###Begin 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#determine how many columns have data that is in scope.  Last 2 columns do not have in scope data
ncol(single_dataset)-2
#result is 66

mean_all <- ddply(single_dataset, .(subject, activity), function(x) colMeans(x[, 1:66]))

#file is created in working directory with results
write.table(mean_all, "mean_all.txt", row.name=FALSE)
