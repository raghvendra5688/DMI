library(data.table)
library(ggplot2)

setwd('~/QCRI_PostDoc/Raghav_Related/DREAM/Results/')

df1 <- read.table('Full_data.txt',header=TRUE,sep=",")

ggsave(filename="Trend_Cutoffs.png",width = 15,height = 10, scale = 1.25, dpi=300, units="cm")
p <- ggplot(data=df1,aes(x=FDR,y=Modules,colour=NetworkId)) + 
      geom_line(data=df1,aes(linetype=NetworkId,color=NetworkId),size=1.5) + 
      geom_point(data=df1,aes(shape=NetworkId),size=4) + ylab("No of Disease Modules") +
      scale_color_manual(values=c('red','green','blue','black','purple','darkgreen')) +
      theme_bw()
