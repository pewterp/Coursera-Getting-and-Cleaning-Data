# Created a directory called "data". Downloaded zip file into directory.

if(!file.exists("./data")){dir.create("./data")}
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile ="./data/Dataset.zip" )

# Unzipped file. Listed all files in the unzipped folder.

unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

datafolder <- file.path("./data", "UCI HAR Dataset")
allfiles <- list.files(path = datafolder, recursive = TRUE)

# Read all text files in "test" and "train" folders (except in "Inertial" folders) into data tables in R.

EventDataTest <- read.table(file.path(datafolder, "test", "y_test.txt"), header = FALSE)
EventDataTrain <- read.table(file.path(datafolder, "train", "y_train.txt"), header = FALSE)

SubjectDataTest <- read.table(file.path(datafolder, "test", "subject_test.txt"), header = FALSE)
SubjectDataTrain <- read.table(file.path(datafolder, "train", "subject_train.txt"), header = FALSE)

FeaturesDataTest <- read.table(file.path(datafolder, "test", "X_test.txt"), header = FALSE)
FeaturesDataTrain <- read.table(file.path(datafolder, "train", "X_train.txt"), header = FALSE)

# Merged Test and Train datasets to create single datasets.

EventData <- rbind(EventDataTrain, EventDataTest)
SubjectData <- rbind(SubjectDataTrain, SubjectDataTest)
FeaturesData <- rbind(FeaturesDataTrain, FeaturesDataTest)

# Read headers from features.txt. Assign header names to each dataset.

FeaturesNames <- read.table(file.path(datafolder, "features.txt"), header = FALSE)

names(EventData) <- "Event"
names(SubjectData) <- "Subject"
names(FeaturesData) <- FeaturesNames$V2

# Final merger of all datasets to create a single master set.

SubjectandActivity <- cbind(SubjectData, EventData)
DataSet <- cbind(FeaturesData, SubjectandActivity)

# Subsets dataset to only contain mean and standard deviation values.

MeanandStd <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
RequiredData <- cbind(as.character(MeanandStd), "Subject", "Event")
SubsettedData <- subset(DataSet, select = RequiredData)

# Reads in activity labels (e.g. walking, sitting). Does a vlookup to match each activity number (1-6) in master data ( var EventMatching) with their activity name.  

Eventlabels <- read.table(file.path(datafolder, "activity_labels.txt"), header = FALSE)
names(Eventlabels)[1] <- "Event"
EventMatching <- merge(SubsettedData, Eventlabels, by = "Event", all = TRUE)
EventMatching$Event <- NULL
names(EventMatching)[names(EventMatching)=="V2"] <- "Event"

# Appropriately labels the data set with descriptive variable names.

names(EventMatching)<-gsub("^t", "time", names(EventMatching))
names(EventMatching)<-gsub("^f", "frequency", names(EventMatching))
names(EventMatching)<-gsub("Acc", "Accelerometer", names(EventMatching))
names(EventMatching)<-gsub("Gyro", "Gyroscope", names(EventMatching))
names(EventMatching)<-gsub("Mag", "Magnitude", names(EventMatching))
names(EventMatching)<-gsub("BodyBody", "Body", names(EventMatching))

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject, called "independentdata.txt".

library(plyr);
Dataset2<-aggregate(. ~Subject + Event, EventMatching, mean)
Dataset2<-Dataset2[order(Dataset2$Subject,Dataset2$Event),]
write.table(Dataset2, file = "independentdata.txt",row.name=FALSE)
