#####Remove old files####
mydir <- "./covid19_data/"
delcsv <- dir(path=mydir ,pattern="*.csv", recursive = T)
delxlsx <- dir(path=mydir ,pattern="*.xlsx", recursive = T)
unlink(file.path(mydir, delcsv))
unlink(file.path(mydir, delxlsx))
#####Load libraries to environment####
library(jsonlite)
library(gdata)
library(openxlsx)
library(epiDisplay)
library(dplyr)
library(tidyr)

#####Read data from json file####
ncov19india = fromJSON("http://github.com/covid19india/api/raw/master/raw_data.json") %>% as.data.frame
names(ncov19india) <-gsub("raw_data.", "", names(ncov19india))

#####Creation of raw data set - Individual####
ncov19india_raw<-ncov19india[ncov19india$dateannounced != "",c(13,17,11,8,7,6,5,3,20,1,10,4,19)]
write.xlsx(ncov19india_raw, file = "./covid19_data/excel/individual/ncov19individual_raw.xlsx")
write.csv(ncov19india_raw, file = "./covid19_data/csv/individual/ncov19individual_raw.csv", na = "")

#####Creation of clean data set#### Variables having more than 50% missing value will be removed####

#individual#
ncov19india_clean<-ncov19india_raw
tab1(ncov19india_clean$detectedstate) # No missing values
tab1(ncov19india_clean$detecteddistrict) # missing values <  50% - will not be removed
tab1(ncov19india_clean$detectedcity) # missing values > 50% - will be removed
ncov19india_clean$detectedcity<-NULL
tab1(ncov19india_clean$dateannounced) # No missing values
tab1(ncov19india_clean$contractedfromwhichpatientsuspected) # missing values > 50% - will be removed
ncov19india_clean$contractedfromwhichpatientsuspected<-NULL
tab1(ncov19india_clean$typeoftransmission) # will be recorded as "Undefined"; "TBD" will be coded as "ToBeDecided".
ncov19india_clean$typeoftransmission<-ifelse(ncov19india_clean$typeoftransmission == "", "Undefined", ifelse(ncov19india_clean$typeoftransmission == "TBD", "ToBeDecided", as.character(ncov19india_clean$typeoftransmission)))
tab1(ncov19india_clean$typeoftransmission)
tab1(ncov19india_clean$agebracket) # missing values > 50% - will be removed
ncov19india_clean$agebracket<-NULL
tab1(ncov19india_clean$gender) # missing values > 50% - will be removed
tab1(ncov19india_clean$currentstatus) # 1 missing values - will be recorded as "Undefined"
ncov19india_clean$currentstatus<-ifelse(ncov19india_clean$currentstatus == "", "Undefined", as.character(ncov19india_clean$currentstatus))
tab1(ncov19india_clean$currentstatus)
tab1(ncov19india_clean$statuschangedate) # 84 missing values - will not be removed
tab1(ncov19india_clean$nationality) # missing values > 50% - will be removed
ncov19india_clean$nationality<-NULL
write.xlsx(ncov19india_clean, file = "./covid19_data/excel/individual/ncov19individual_clean.xlsx")
write.csv(ncov19india_clean, file = "./covid19_data/csv/individual/ncov19individual_clean.csv", na = "")

#####Creation of data set - State####

##Long##
ncov19india_state<- ncov19india_clean %>% group_by(detectedstate, dateannounced) %>% tally()
colnames(ncov19india_state)<-c("detectedstate", "dateannounced", "numberofcases")
write.csv(ncov19india_state, file = "./covid19_data/csv/state/ncov19state_long.csv", na = "")
write.xlsx(ncov19state_wide, file = "./covid19_data/excel/state/ncov19state_long.xlsx")

##Wide##
ncov19state_wide<-spread(ncov19india_state, dateannounced, numberofcases)
names(ncov19state_wide)
write.xlsx(ncov19state_wide, file = "./covid19_data/excel/state/ncov19state_wide.xlsx")
write.csv(ncov19state_wide, file = "./covid19_data/csv/state/ncov19state_wide.csv", na = "")

#####Creation of national data set####
ncov19india_timeserise<- ncov19india_clean %>% group_by(dateannounced) %>% tally()
colnames(ncov19india_timeserise)<-c("dateannounced", "numberofcases")
write.xlsx(ncov19india_timeserise, file = "./covid19_data/excel/national_timeseries/ncov19india_timeserise.xlsx")
write.csv(ncov19india_timeserise, file = "./covid19_data/csv/national_timeseries/ncov19india_timeserise.csv", na = "")
unlink("raw_data.json")
dim(ncov19india_clean)
