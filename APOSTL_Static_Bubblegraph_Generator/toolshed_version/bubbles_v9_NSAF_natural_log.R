rm(list=ls())
###################################################################################################
# R-code: Multi-bubble graph generation from SAINTexpress output
# Author: Brent Kuenzi
###################################################################################################
library(dplyr); library(tidyr); library(ggplot2)
###################################################################################################
### Run program ###

## REQUIRED INPUT ##
# 1) listfile: SAINTexpress generated "list.txt" file
# 2) preyfile: SAINT pre-processing generated "prey.txt" file used to run SAINTexpress
## OPTIONAL INPUT ##
# 3) crapome: raw output from crapome Workflow 1 query (http://www.crapome.org)
# 4) color: bubble color (default = "red")
#     - color= "crapome": color bubbles based on Crapome(%)
#     - Also recognizes any color within R's built-in colors() vector
# 5) label: Adds gene name labels to bubbles within the "zoomed in" graphs (default = FALSE)
# 6) cutoff: Saintscore cutoff to be assigned for filtering the "zoomed in" graphs (default = 0.8)
###################################################################################################
main <- function(listfile, preyfile , crapome=FALSE, color="red", label=FALSE, cutoff=0.8, type="SC", inc_file = "None", exc_file = "None" ) {
  cutoff_check(cutoff)
  listfile <- list_type(listfile, inc_file, exc_file)
  if(type == "SC") {
    df <- merge_files_sc(listfile, preyfile, crapome)
  }
  if(type == "MQ") {
    df <- merge_files_mq(listfile, preyfile, crapome)
  }
  bubble_NSAF(df,color)
  bubble_SAINT(df,color)
  bubble_zoom_SAINT(df, color, label, cutoff)
  bubble_zoom_NSAF(df, color, label, cutoff)
  write.table(df,"output.txt",sep="\t",quote=FALSE, row.names=FALSE)
}

list_type <- function(df, inc_file, exc_file) {
  Saint <- read.delim(df, stringsAsFactors=FALSE)
  if (inc_file != "None") {
    if (exc_file == "None"){
      inc_prots <- read.delim(inc_file, sep='\t', header=FALSE, stringsAsFactors=FALSE)
      filtered_df = subset(Saint, Saint$Prey == inc_prots[,1])
    }
    else {
      inc_prots <- read.delim(inc_file, sep='\t', header=FALSE, stringsAsFactors=FALSE)
      exc_prots <- read.delim(exc_file, sep='\t', header=FALSE, stringsAsFactors=FALSE)
      filtered_df = subset(Saint, Saint$Prey == inc_prots[,1])
      filtered_df = subset(filtered_df, filtered_df$Prey != exc_prots[,1])
    }
  }
  else if (exc_file != "None") {
    exc_prots <- read.delim(exc_file, sep='\t', header=FALSE, stringsAsFactors=FALSE)
    filtered_df = subset(Saint, Saint$Prey != exc_prots[,1])
  }
  else {
    filtered_df = Saint
  }
  return(filtered_df)
  
}
###################################################################################################
# Merge input files and caculate Crapome(%) and NSAF for each protein for each bait
###################################################################################################
merge_files_mq <- function(SAINT, prey_DF, crapome=FALSE) {
  #SAINT <- read.table(SAINT_DF, sep='\t', header=TRUE)
  prey <- read.table(prey_DF, sep='\t', header=FALSE); colnames(prey) <- c("Prey", "Length", "PreyGene")
  DF <- merge(SAINT,prey)
  DF$SpecSum <- log2(DF$SpecSum)
  
  if(crapome!=FALSE) {
    crapome <- read.table(crapome, sep='\t', header=TRUE)
    colnames(crapome) <- c("Prey", "Symbol", "Num.of.Exp", "Ave.SC", "Max.SC")
    DF1 <- merge(DF, crapome); as.character(DF1$Num.of.Exp); DF1$Symbol <- NULL;
                    DF1$Ave.SC <- NULL; DF1$Max.SC <- NULL #remove unnecessary columns
    DF1$Num.of.Exp <- sub("^$", "0 / 1", DF1$Num.of.Exp ) #replace blank values with 0 / 1
    DF <- DF1 %>% separate(Num.of.Exp, c("NumExp", "TotalExp"), " / ") #split into 2 columns
    DF$CrapomePCT <- 100 - (as.integer(DF$NumExp) / as.integer(DF$TotalExp) * 100) #calculate crapome %
  }
  DF$SAF <- DF$AvgSpec / DF$Length
  DF2 = DF %>% group_by(Bait) %>% mutate(NSAF = SAF/sum(SAF))
  DF$NSAF = DF2$NSAF
  return(DF)
}

merge_files_sc <- function(SAINT, prey_DF, crapome=FALSE) {
  #SAINT <- read.table(SAINT_DF, sep='\t', header=TRUE)
  prey <- read.table(prey_DF, sep='\t', header=FALSE); colnames(prey) <- c("Prey", "Length", "PreyGene")
  DF <- merge(SAINT,prey)
  
  if(crapome!=FALSE) {
    crapome <- read.table(crapome, sep='\t', header=TRUE)
    colnames(crapome) <- c("Prey", "Symbol", "Num.of.Exp", "Ave.SC", "Max.SC")
    DF1 <- merge(DF, crapome); as.character(DF1$Num.of.Exp); DF1$Symbol <- NULL;
                    DF1$Ave.SC <- NULL; DF1$Max.SC <- NULL #remove unnecessary columns
    DF1$Num.of.Exp <- sub("^$", "0 / 1", DF1$Num.of.Exp ) #replace blank values with 0 / 1
    DF <- DF1 %>% separate(Num.of.Exp, c("NumExp", "TotalExp"), " / ") #split into 2 columns
    DF$CrapomePCT <- 100 - (as.integer(DF$NumExp) / as.integer(DF$TotalExp) * 100) #calculate crapome %
  }
  DF$SAF <- DF$AvgSpec / DF$Length
  DF2 = DF %>% group_by(Bait) %>% mutate(NSAF = SAF/sum(SAF))
  DF$NSAF = DF2$NSAF
  return(DF)
}
###################################################################################################
# Plot all proteins for each bait by x=ln(NSAF), y=Log2(FoldChange)
###################################################################################################
bubble_NSAF <- function(data, color) {
    if(color=="crapome") {
      a <- subset(data, CrapomePCT <80, select = c(NSAF,SpecSum, CrapomePCT, FoldChange, SaintScore, Bait))
      b <- subset(data, CrapomePCT>=80, select = c(NSAF,SpecSum, CrapomePCT, FoldChange, SaintScore, Bait))
      p <- qplot(x=log(NSAF), y=log2(FoldChange), data=a, colour=I("tan"),size=SpecSum) + scale_size(range=c(1,10)) + 
        geom_point(aes(x=log(NSAF),y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=a)
      if(length(levels(a$Bait) > 1)) {p <- p + facet_wrap(~Bait, scales="free_y")} # multiple graphs if multiple baits
      p <- p + geom_point(aes(x=log(NSAF),y=log2(FoldChange), size=SpecSum, color=CrapomePCT), data=b) + 
        scale_colour_gradient(limits=c(80, 100), low="tan", high="red") + 
        labs(colour="CRAPome Probability \nof Specific Interaction (%)", x="ln(NSAF)") + 
        geom_point(aes(x=log(NSAF),y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=b)
      return(ggsave(p, width=8,height=4,filename = "bubble_NSAF.png"))
    }
   if(color != "crapome") {
      p <- qplot(x=log(NSAF), y=log2(FoldChange), data=data, colour=I(color),size=SpecSum) + scale_size(range=c(1,10)) + 
        geom_point(aes(x=log(NSAF),y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=data) + # add bubble outlines
          labs(x="ln(NSAF)")
        if(length(levels(data$Bait) > 1)) {p <- p + facet_wrap(~Bait, scales="free_y")}
      return(ggsave(p, width=8,height=4,filename = "bubble_NSAF.png"))
    }
  }
###################################################################################################
# Plot all proteins for each bait by x=Saintscore, y=Log2(FoldChange)
###################################################################################################
bubble_SAINT <- function(data, color) {
    if(color=="crapome") {
      a <- subset(data, CrapomePCT <80, select = c(NSAF,SpecSum, CrapomePCT, FoldChange, SaintScore, Bait)) #filter on CRAPome
      b <- subset(data, CrapomePCT >=80, select = c(NSAF,SpecSum, CrapomePCT, FoldChange, SaintScore, Bait))
      p <- qplot(x=SaintScore, y=log2(FoldChange), data=a, colour=I("tan"),size=SpecSum) + 
        scale_size(range=c(1,10)) + geom_point(aes(x=SaintScore,y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=a)
      if(length(levels(a$Bait) > 1)) {p <- p + facet_wrap(~Bait, scales="free_y")}
      p <- p + geom_point(aes(x=SaintScore,y=log2(FoldChange), size=SpecSum, color=CrapomePCT), data=b) + 
        scale_colour_gradient(limits=c(80, 100), low="tan", high="red") + 
        labs(colour="CRAPome Probability \nof Specific Interaction (%)") +
        geom_point(aes(x=SaintScore,y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=b)
      return(ggsave(p, width=8,height=4,filename = "bubble_SAINT.png"))
    }
    if(color != "crapome") {
      p <- qplot(x=SaintScore, y=log2(FoldChange), data=data, colour=I(color),size=SpecSum) +
        scale_size(range=c(1,10)) + geom_point(aes(x=SaintScore,y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=data)
      if(length(levels(data$Bait) > 1)) {p <- p + facet_wrap(~Bait, scales="free_y")}
      return(ggsave(p, width=8,height=4,filename = "bubble_SAINT.png"))
    }
  }
###################################################################################################
# Filter proteins on Saintscore cutoff and plot for each bait x=Saintscore, y=Log2(FoldChange)
###################################################################################################
bubble_zoom_SAINT <- function(data, color, label=FALSE, cutoff=0.8) {
  if(color=="crapome") {
    a <- subset(data, CrapomePCT <80 & SaintScore>=cutoff, select = c(NSAF,SpecSum, CrapomePCT, FoldChange, SaintScore, Bait, PreyGene))
    b <- subset(data, CrapomePCT >=80 & SaintScore >=cutoff, select = c(NSAF,SpecSum, CrapomePCT, FoldChange, SaintScore, Bait, PreyGene))
    p <- qplot(x=SaintScore, y=log2(FoldChange), data=a, colour=I("tan"),size=SpecSum) + 
      scale_size(range=c(1,10)) + ggtitle("Filtered on SAINT score")+geom_point(aes(x=SaintScore,y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=a)
    if(label==TRUE & length(a$NSAF!=0)) {
      p <- p + geom_text(data=a, aes(label=PreyGene, size=10, vjust=0, hjust=0),colour="black")
    }
    if(length(levels(a$Bait) > 1)) {p <- p + facet_wrap(~Bait, scales="free_y")}
    p <- p + geom_point(aes(x=SaintScore,y=log2(FoldChange), size=SpecSum, color=CrapomePCT), data=b) + 
      scale_colour_gradient(limits=c(80, 100), low="tan", high="red") + 
      labs(colour="CRAPome Probability \nof Specific Interaction (%)") + 
      geom_point(aes(x=SaintScore,y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=b)
    if(label==TRUE & length(b$NSAF!=0)) {
      p <- p + geom_text(data=b, aes(label=PreyGene, size=10, vjust=0, hjust=0),colour="black", show_guide=FALSE)
    }
    return(ggsave(p, width=8,height=4,filename = "bubble_zoom_SAINT.png"))
  }
  if(color != "crapome") {
    a <- subset(data, SaintScore>=cutoff, select = c(NSAF,SpecSum, FoldChange, SaintScore, Bait, PreyGene))
    p <- qplot(x=SaintScore, y=log2(FoldChange), data=a, colour=I(color),size=SpecSum) +
      scale_size(range=c(1,10)) + ggtitle("Filtered on SAINT score") + 
      geom_point(aes(x=SaintScore,y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=a)
    if(label==TRUE & length(a$NSAF!=0)) {
      p <- p + geom_text(data=a, aes(label=PreyGene, size=10, vjust=0, hjust=0),colour="black", show_guide=FALSE)
    }
    if(length(levels(data$Bait) > 1)) {p <- p + facet_wrap(~Bait, scales="free_y")}
    return(ggsave(p, width=8,height=4,filename = "bubble_zoom_SAINT.png"))
  }
}
###################################################################################################
# Filter proteins on Saintscore cutoff and plot for each bait x=log(NSAF), y=Log2(FoldChange)
###################################################################################################
bubble_zoom_NSAF <- function(data, color, label=FALSE, cutoff=0.8) {
  if(color=="crapome") {
    a <- subset(data, CrapomePCT <80 & SaintScore>=cutoff, select = c(NSAF,SpecSum, CrapomePCT, FoldChange, SaintScore, Bait, PreyGene))
    b <- subset(data, CrapomePCT >=80 & SaintScore >=cutoff, select = c(NSAF,SpecSum, CrapomePCT, FoldChange, SaintScore, Bait, PreyGene))
    p <- qplot(x=log(NSAF), y=log2(FoldChange), data=a, colour=I("tan"),size=SpecSum) + 
      scale_size(range=c(1,10)) + ggtitle("Filtered on SAINT score") + 
      geom_point(aes(x=log(NSAF),y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=a)
    if(label==TRUE & length(a$NSAF!=0)) {
      p <- p + geom_text(data=a, aes(label=PreyGene, size=10, vjust=0, hjust=0),colour="black")
    }
    if(length(levels(a$Bait) > 1)) {p <- p + facet_wrap(~Bait, scales="free_y")}
    p <- p + geom_point(aes(x=log(NSAF),y=log2(FoldChange), size=SpecSum, color=CrapomePCT), data=b) + 
      scale_colour_gradient(limits=c(80, 100), low="tan", high="red") + 
      labs(colour="CRAPome Probability \nof Specific Interaction (%)", x="ln(NSAF)") + 
      geom_point(aes(x=log(NSAF),y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=b)
    if(label==TRUE & length(b$NSAF!=0)) {
      p <- p + geom_text(data=b, aes(label=PreyGene, size=10, vjust=0, hjust=0),colour="black", show_guide=FALSE)
    }
    return(ggsave(p, width=8,height=4,filename = "bubble_zoom_NSAF.png"))
  }
  if(color != "crapome") {
    a <- subset(data, SaintScore>=cutoff, select = c(NSAF,SpecSum, FoldChange, SaintScore, Bait, PreyGene))
    p <- qplot(x=log(NSAF), y=log2(FoldChange), data=a, colour=I(color), size=SpecSum) +
      scale_size(range=c(1,10)) + ggtitle("Filtered on SAINT score") + 
      geom_point(aes(x=log(NSAF),y=log2(FoldChange), size=SpecSum), colour="black", shape=21, data=a) + 
      labs(x="ln(NSAF)")
    if(label==TRUE & length(a$NSAF!=0)) {
      p <- p + geom_text(data=a, aes(label=PreyGene, size=10, vjust=0, hjust=0),colour="black", show_guide=FALSE)
    }
    if(length(levels(data$Bait) > 1)) {p <- p + facet_wrap(~Bait, scales="free_y")}
    return(ggsave(p, width=8,height=4,filename = "bubble_zoom_NSAF.png"))
  }
}
###################################################################################################
# Check Saintscore cutoff and stop program if not between 0 and 1
###################################################################################################
cutoff_check <- function(cutoff){
  if( any(cutoff < 0 | cutoff > 1) ) stop('SAINT score cutoff not between 0 and 1. Please correct and try again')
}

args <- commandArgs(trailingOnly = TRUE)
main(args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9])

#main("test_list.txt", "preytest.txt", crapome="craptest.txt", color="crapome", label=TRUE)
#main("Crizo_list.txt", "prey_cr.txt", crapome = "crizo_crap.txt", color="crapome", label=TRUE, cutoff=0.7)
#main("test_list.txt", "preytest.txt", crapome=FALSE, color="magenta", label=FALSE, cutoff=1.1)