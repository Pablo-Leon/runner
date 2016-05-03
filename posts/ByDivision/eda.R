#
# eda.R -- 
#

message("load libraries")

# library(dplyr)
library(ggplot2)

message("load includes")
# source("runner_load.R")

message("load data")

# rm("dfBrooks50")
if (exists("dfBrooks50")) {
  message("Skiping file Read.")
} else {
  dfBrooks50 <- read.csv2("Brooks50.csv")
}
df <- dfBrooks50[c(1,5:11)]
# df <- tbl_df(dfBrooks50)

# print("--- Race (df):")
# print(str(df))
# print(head(df))

#
# Functions
#
Time2Mins <- function(s) {
  v <- strsplit(s, ":")
  n <- length(v[[1]])
  m <- 0
  for (i in 1:n) {
    k=as.numeric(v[[1]][n])
    m <- (m*60) + (as.numeric(v[[1]][i]))
  }
  return(m/60)
}
# vs <- c("0", "1", "0:0", "0:3", "1:0", "1:1", "0:32:6", "1:07:23")
# print (vs)
# print (sapply(vs, Time2Mins))


#
# Process
#
df$mins=sapply(as.character(df$T.Chip), Time2Mins) 
levels(df$Sexo)[levels(df$Sexo)=="f"] <- "F"
levels(df$Sexo)[levels(df$Sexo)=="m"] <- "M"


#
# Explore
# 
print(length(df$mins))

print(summary(df$Categoria))

print(summary(df$Sexo))

print(summary(df$mins))

qplot(data=df, mins)

#
# Linear Reg
#
by_DivSex <- group_by(Categoria, Sexo)
dfDiv <- df %>% summarise(by_DivSex, count=n(), mn=mean()) %>%
	

#
# Plot histogram
#
psex <- ggplot(df, aes(Sexo, mins)) +
  geom_boxplot() +
  geom_jitter(aes(color=Sexo), alpha=0.2)  

pcat <- ggplot(df, aes(Categoria, mins)) +
  geom_boxplot() +
  geom_jitter(alpha=0.2)  

pcat2 <- ggplot(df, aes(Categoria, mins)) +
  geom_boxplot() +
  geom_jitter(aes(color=Sexo), alpha=0.2)  

pcat3 <- ggplot(df, aes(Categoria, mins)) +
  geom_boxplot() +
  geom_jitter(aes(color=Sexo), alpha=0.2)  +
  facet_grid(Sexo~.)


x <- tapply(df$Categoria, df$Sexo, summary)
df2F <- data.frame(Categoria=labels(x[["F"]]), Sexo="F", Cant=x[["F"]], row.names=NULL)
df2M <- data.frame(Categoria=labels(x[["M"]]), Sexo="M", Cant=x[["M"]], row.names=NULL)
df2 <- rbind(df2F,df2M)

plotSexNumbers <-ggplot(data=df2, aes(x=Categoria, y=Cant, fill=Sexo)) +
    geom_bar(stat="identity", position="dodge")

