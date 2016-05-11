###################################################################################################
# R-code: APOSTL Global Variables
# Author: Brent Kuenzi

###################################################################################################
# This program performs the file merging as well as a serious of calculations
# Following merging the following parameters will be calculated:
# 1) CRAPomePCT
# 2) NSAF
# 3) NSAFscore
# The resulting table will be exported. This is performed as its own tool and should not be used
# for input into the interactive analysis tool or the standalone bubble graph tool
################################## Dependencies ###################################################
library(dplyr); library(tidyr)
################################# Read in Data ####################################################
## REQUIRED INPUTS ##
# 1) listfile (filename)
listfile <- "EGFR_list.txt"
# 2) Prey File (filename)
preyfile <- "EGFR_prey.txt"
# 3) crapome File (filename or FALSE)
crapfile <- "EGFR_crap.txt"
# 4) Inter File (filename)
interfile <- "inter.txt"
################################# Create Table ####################################################
merge_files <- function(SAINT_DF, prey_DF, crapome=FALSE) {
  SAINT <- read.table(SAINT_DF, sep='\t', header=TRUE)
  prey <- read.table(prey_DF, sep='\t', header=FALSE); colnames(prey) <- c("Prey", "Length", "PreyGene")
  DF <- merge(SAINT,prey)
  
  if(crapome!=FALSE) {
    crapome <- read.table(crapome, sep='\t', header=TRUE)
    colnames(crapome) <- c("Prey", "Symbol", "Num.of.Exp", "Ave.SC", "Max.SC")
    DF1 <- merge(DF, crapome); as.character(DF1$Num.of.Exp); DF1$Symbol <- NULL;
    DF1$Ave.SC <- NULL; DF1$Max.SC <- NULL #remove unnecessary columns
    DF1$Num.of.Exp <- sub("^$", "0 / 1", DF1$Num.of.Exp ) #replace blank values with 0 / 1
    DF <- DF1 %>% separate(Num.of.Exp, c("NumExp", "TotalExp"), " / ") #split into 2 columns
    DF$CrapomePCT <- round(100 - (as.integer(DF$NumExp) / as.integer(DF$TotalExp) * 100), digits=2) #calculate crapome %
    
  }
  DF$FoldChange <- round(log2(DF$FoldChange),digits=2)
  colnames(DF)[(colnames(DF)=="FoldChange")] <- "log2(FoldChange)"
  
  DF$SAF <- DF$AvgSpec / DF$Length
  by_bait <-  DF %>% group_by(Bait) %>% mutate("NSAF" = SAF/sum(SAF))
  by_bait$SAF <- NULL
  return(by_bait[!duplicated(by_bait),])
}

working <- as.data.frame(merge_files(listfile, preyfile, crapfile))
inter_df <- read.table(interfile, sep='\t', header=FALSE)
working$temp <- strsplit(as.character(working$ctrlCounts),"[|]")
cnt <- 0
for(i in working$temp){
  cnt <- cnt+1
  working$ctrl_mean[cnt] <- mean(as.numeric(unlist(i)))
  working$ctrl_number[cnt] <- length(i)}
working$ctrl_SAF <- working$ctrl_mean / working$Length
main.data <-  working %>% group_by(Bait) %>% mutate("control_NSAF" = ctrl_SAF/sum(ctrl_SAF))
ctrl_SAF_constant <- 1/mean(main.data$ctrl_SAF)
# add ctrl_SAF_constant to prevent dividing by 0
cnt <- 0
for(i in main.data$control_NSAF){
  cnt <- cnt + 1
  main.data$nsafScore[cnt] <- ((main.data$NSAF[cnt])+ctrl_SAF_constant)/((i/main.data$ctrl_number[cnt])+ctrl_SAF_constant)
}
main.data$NSAF <- log(main.data$NSAF)
main.data$nsafScore <- log(main.data$nsafScore)
main.data <- filter(main.data, NSAF > -Inf)
colnames(main.data)[colnames(main.data)=="NSAF"] <- "ln(NSAF)"
colnames(main.data)[colnames(main.data)=="nsafScore"] <- "NSAFScore"
main.data$SAF <- NULL; main.data$ctrl_SAF <- NULL
main.data$control_NSAF <- NULL; main.data$temp <- NULL
main.data$ctrl_mean <- NULL
write.table(main.data,file="SaintTable.txt",sep="\t",row.names=FALSE,quote=FALSE)