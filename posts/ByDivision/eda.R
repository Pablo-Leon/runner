#
# eda.R -- 
#

message("load libraries")

library(dplyr)
library(ggplot2)

message("load includes")
# source("runner_load.R")

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
BrooksDivision <- function(age) {
	if (age > 70) "70-.." else {
	r <- (age-6) %/% 10
	if (r <= 1) "15-25" else 
		if (r == 6) "66-70" else 
			sprintf("%02d-%02d", r*10+6, r*10+15)
	}
}
DistanceMds <- function(sRaceInterval) {
	interval = sub("\\S+\\s:\\s(\\S+)", "\\1", sRaceInterval)
	if (interval == "complete") {
		sDist = sub("(\\S+)\\s:.*", "\\1", sRaceInterval)
	} else {
		sDist = interval
	}
	as.numeric( sub("(\\d+)[kK]", "\\1", sDist) )
}
SpeedKmh <- function(age) {
	if (age > 70) "70-.." else {
	r <- (age-6) %/% 10
	if (r <= 1) "15-25" else 
		if (r == 6) "66-70" else 
			sprintf("%02d-%02d", r*10+6, r*10+15)
	}
}

LoadMds <- function(y) {
	sFile=sprintf("mds%d.csv", y);
	# race;interval;entryID;Rank;Name;Bib;GunTime;Pace;Hometown;Age;Sex;Division;DivRank;GunMins
	df <- read.csv2(sFile)[,c(1:2,6,9:11,14)]
	df$event=sprintf("mds%d", y);
	df$GunMins <- as.numeric(levels(df$GunMins))[df$GunMins]
	df$Division <- sapply(df$Age, BrooksDivision)
	df$Dist <- sapply(paste(df$race, ":", df$interval ), DistanceMds)
	df$Speed <- df$Dist / (df$GunMins/60)
	df
}

message("load data")

# MDS 2014-2016

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

# vs <- c("0", "1", "0:0", "0:3", "1:0", "1:1", "0:32:6", "1:07:23")
# print (vs)
# print (sapply(vs, Time2Mins))


#
# Process
#
df$mins=sapply(as.character(df$T.Chip), Time2Mins) 
levels(df$Sexo)[levels(df$Sexo)=="f"] <- "F"
levels(df$Sexo)[levels(df$Sexo)=="m"] <- "M"

# Speed
df$speed=9.85/(df$mins/60)

# Division
df$Division <- gsub("(\\d+) A.*OS.*","\\1-..", 
  gsub("(\\d+) A (\\d+) .*","\\1-\\2", 
    gsub("(\\d+) - (\\d+) .*","\\1-\\2", df$Categoria) ))
df$AgeLo <- as.numeric( gsub("^(\\d+).*","\\1", df$Categoria) ) 
df$AgeHi <- as.numeric( gsub("(\\d+) A.*OS.*", "999",
  gsub("^\\d+\\D+(\\d+).*","\\1", df$Categoria) ) )
df$AgeMid <- (df$AgeLo + df$AgeHi)/2
df <- df[df$AgeLo < 70,]


# Summary
dfDiv <- df %>%
	filter(AgeLo < 70) %>%
  group_by(Division, Sexo)  %>%
  summarise(AgeMid = mean(AgeMid), count=n(),
  	speed.mn=mean(speed), speed.s=sd(speed),
  	speed.mx=max(speed),  speed.p90=quantile(speed,0.9)) 





#
# Explore
# 
print(length(df$mins))

print(summary(df$Categoria))

print(summary(df$Sexo))

print(summary(df$mins))

qplot(data=df, mins)

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


x <- tapply(df$Division, df$Sexo, summary)
df2F <- data.frame(Division=labels(x[["F"]]), Sexo="F", Cant=x[["F"]], row.names=NULL)
df2M <- data.frame(Division=labels(x[["M"]]), Sexo="M", Cant=x[["M"]], row.names=NULL)
df2 <- rbind(df2F,df2M)

# plotSexNumbers <-ggplot(data=df2, aes(x=Division, y=Cant, fill=Sexo)) +
#    geom_bar(stat="identity", position="dodge")

plotSexNumbers <-ggplot(data=df, aes(x=Division, y=..count.., group=Sexo, fill=Sexo)) + 
	geom_bar(position="dodge")


#
# Speed by Division
#
#
# Linear Reg
#

	

pspeed <- ggplot(data=dfDiv, aes(x=AgeMid, y=speed.mn, group=Sexo, color=Sexo)) + 
     geom_line()

pspeed <- ggplot(data=dfDiv, aes(x=AgeMid)) +
     geom_line(aes(y=speed.mn, color=Sexo)) +
     geom_line(aes(y=speed.mx, color=Sexo), lty="dotted") +
     geom_line(aes(y=speed.p90, color=Sexo), lty="dashed") +
     facet_grid(Sexo ~ .)

#  geom_violin(scale="count") +
pvio <- ggplot(df, aes(Division, speed, fill=Sexo)) +
  geom_violin() +
  facet_grid(Sexo~.)


pvio2 <- ggplot(df, aes(factor(Division), Speed, fill=Sexo)) +
  geom_violin() +
  geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1)) +
  facet_grid(Sexo~.)

     
lm.speed_by_div.M = lm(speed ~ AgeMid, data = df, subset=(Sexo=="M"))
lm.speed_by_div.F = lm(speed ~ AgeMid, data = df, subset=(Sexo=="F"))

  


