#####Remove old files####
mydir <- "./covid19_data/"
delcsv <- dir(path=mydir ,pattern="*.csv", recursive = T)
delxlsx <- dir(path=mydir ,pattern="*.xlsx", recursive = T)
unlink(file.path(mydir, delcsv))
unlink(file.path(mydir, delxlsx))
#####Load libraries to environment####
library(rjson)
library(gdata)
library(openxlsx)
library(epiDisplay)
library(dplyr)
library(tidyr)

#####Read data from json file####
download.file('http://github.com/covid19india/api/raw/master/raw_data.json', destfile = "raw_data.json")
data = rjson::fromJSON(file="raw_data.json")
# Extraction, assembly and naming
data_n<-data[['raw_data']]
grabInfo<-function(var){
  print(paste("Variable", var, sep=" "))  
  sapply(data_n, function(x) returnData(x, var)) 
}
returnData<-function(x, var){
  if(!is.null( x[[var]])){
    return( trim(x[[var]]))
  }else{
    return(NA)
  }
}
ncov19india<-data.frame(sapply(1:20, grabInfo), stringsAsFactors=FALSE)
columns<-names(data_n[[1]])
colnames(ncov19india)<-columns

#####Creation of raw data set - Individual####

ncov19india_raw<-ncov19india[ncov19india$dateannounced != "",c(14,18,11,8,7,6,5,3,20,1,10,4,19)]
file1 <- 'ncov19individual_raw'
write.xlsx(ncov19india_raw, file = paste0("./covid19_data/excel/individual/", sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.xlsx'))
write.csv(ncov19india_raw, file = paste0("./covid19_data/csv/individual/", sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.csv'), na = "")

#####Creation of clean data set#### Variables having more than 50% missing value will be removed####

#individual#
ncov19india_clean<-ncov19india_raw
tab1(ncov19india_clean$statepatientnumber) # missing values > 50% - will be removed
ncov19india_clean$statepatientnumber<-NULL
tab1(ncov19india_clean$detectedstate) # No missing values
tab1(ncov19india_clean$detecteddistrict) # missing values <  50% - will not be removed
tab1(ncov19india_clean$detectedcity) # missing values > 50% - will be removed
ncov19india_clean$detectedcity<-NULL
tab1(ncov19india_clean$dateannounced) # No missing values
tab1(ncov19india_clean$contractedfromwhichpatientsuspected) # missing values > 50% - will be removed
ncov19india_clean$contractedfromwhichpatientsuspected<-NULL
tab1(ncov19india_clean$typeoftransmission) #26 missing values - will be recorded as "Undefined"; "TBD" will be coded as "ToBeDecided".
ncov19india_clean$typeoftransmission<-ifelse(ncov19india_clean$typeoftransmission == "", "Undefined", ifelse(ncov19india_clean$typeoftransmission == "TBD", "ToBeDecided", as.character(ncov19india_clean$typeoftransmission)))
tab1(ncov19india_clean$typeoftransmission)
tab1(ncov19india_clean$agebracket) # missing values > 50% - will be removed
ncov19india_clean$agebracket<-NULL
tab1(ncov19india_clean$gender) # missing values > 50% - will be removed
tab1(ncov19india_clean$currentstatus) # 81 missing values - will be recorded as "Undefined"
ncov19india_clean$currentstatus<-ifelse(ncov19india_clean$currentstatus == "", "Undefined", as.character(ncov19india_clean$currentstatus))
tab1(ncov19india_clean$currentstatus)
tab1(ncov19india_clean$statuschangedate) # 84 missing values - will not be removed
tab1(ncov19india_clean$nationality) # missing values > 50% - will be removed
ncov19india_clean$nationality<-NULL
file1 <- 'ncov19individual_clean'
write.xlsx(ncov19india_clean, file = paste0("./covid19_data/excel/individual/", sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.xlsx'))
write.csv(ncov19india_clean, file = paste0("./covid19_data/csv/individual/", sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.csv'), na = "")

#####Creation of data set - State####

##Long##
ncov19india_state<- ncov19india_clean %>% group_by(detectedstate, dateannounced) %>% tally()
colnames(ncov19india_state)<-c("detectedstate", "dateannounced", "numberofcases")
file1 <- 'ncov19state_long'
write.xlsx(ncov19india_state, file = paste0("./covid19_data/excel/state/", sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.xlsx'))
write.csv(ncov19india_state, file = paste0("./covid19_data/csv/state/", sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.csv'), na = "")

##Wide##
ncov19state_wide<-spread(ncov19india_state, dateannounced, numberofcases)
names(ncov19state_wide)
file1 <- 'ncov19state_wide'
write.xlsx(ncov19state_wide, file = paste0("./covid19_data/excel/state/", sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.xlsx'))
write.csv(ncov19state_wide, file = paste0("./covid19_data/csv/state/", sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.csv'), na = "")

#####Creation of national data set####
ncov19india_timeserise<- ncov19india_clean %>% group_by(dateannounced) %>% tally()
colnames(ncov19india_timeserise)<-c("dateannounced", "numberofcases")
file1 <- 'ncov19india_timeserise'
write.xlsx(ncov19india_timeserise, file = paste0("./covid19_data/excel/national_timeseries/", sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.xlsx'))
write.csv(ncov19india_timeserise, file = paste0("./covid19_data/csv/national_timeseries/",sub('\\..*', '', file1), format(Sys.time(),'_%d%m%y_%H%M%S'), '.csv'), na = "")
unlink("raw_data.json")
