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

LoadMds <- function(y) {
	sFile=sprintf("mds%d.csv", y);
	# race;interval;entryID;Rank;Name;Bib;GunTime;Pace;Hometown;Age;Sex;Division;DivRank;GunMins
	df <- read.csv2(sFile)[,c(1:2,6,9:11,14)]
	df <- df[df$Age < 70,]
	df$event=sprintf("mds%d", y);
	df$GunMins <- as.numeric(levels(df$GunMins))[df$GunMins]
	df$Division <- as.factor(sapply(df$Age, BrooksDivision))
	df$Dist <- sapply(paste(df$race, ":", df$interval ), DistanceMds)
	df$Speed <- df$Dist / (df$GunMins/60)
	df$Hometown <- as.factor(sub("^(\\S+), --", "\\1", df$Hometown))
	df
}

message("load data")

# MDS 2014-2016
if (exists("dfMds")) {
  message("Skiping file Read. dfMds")
} else {
	dfMds <- rbind(LoadMds(2014),LoadMds(2015),LoadMds(2016))
	dfMds$event <- as.factor(dfMds$event)
}


# print("--- Race (df):")
# print(str(df))
# print(head(df))


#
# Process
#
dfMds <- dfMds[dfMds$Sex == "M",]

# Speed

# Division
# df$AgeLo <- as.numeric( gsub("^(\\d+).*","\\1", df$Division) ) 
# df$AgeHi <- as.numeric( gsub("^\\d+-(\\d+)","\\1", df$Division) ) 
# df$AgeMid <- (df$AgeLo + df$AgeHi)/2
# df <- df[df$AgeLo < 70,]


#
# Subsets
#
dfComplete <- dfMds[dfMds$interval == "complete",]
df10k <- dfComplete[dfComplete$race == "10k",]
df21k <- dfComplete[dfComplete$race == "21k",]
df42k <- dfComplete[dfComplete$race == "42k",]



# Summary
print("### Summary dfMds ")
print(summary(dfMds))
print("--------------")
print("#### dfMds, table by: race, interval, event")
print(with(dfMds, table(race, interval, event)))
print("#### dfMds, table by: race, interval, event ")
print(table(dfMds$race, dfMds$interval, dfMds$event))
print("")

print("### Summary dfComplete ")
print(summary(dfComplete))
print("")

print("### Summary df10k ")
print(summary(df10k))
print("")
print(with(df10k, table(Sex, race, event)))
print("table(df10k$event)")
print(with(df10k, table(event)))


#
# Explore
# 
print(length(df21k$GunMins))

print(summary(df21k$Division))

print(summary(df21k$Sex))

print(summary(df21k$GunMins))



#
# Plot histogram
#
pcat3 <- ggplot(df10k, aes(Division, Speed)) +
	geom_boxplot() +
	geom_jitter(aes(color=Sex), alpha=0.2)  +
	facet_grid(event~.)

# plotSexNumbers <-ggplot(data=df, aes(x=Division, y=..count.., group=Sexo, fill=Sexo)) + 
#	geom_bar(position="dodge")


#
# Speed by Division
#
#
# Linear Reg
#

	

# pspeed <- ggplot(data=dfDiv, aes(x=AgeMid, y=speed.mn, group=Sexo, color=Sexo)) + 
#      geom_line()

# pspeed <- ggplot(data=dfDiv, aes(x=AgeMid)) +
#      geom_line(aes(y=speed.mn, color=Sexo)) +
#      geom_line(aes(y=speed.mx, color=Sexo), lty="dotted") +
#      geom_line(aes(y=speed.p90, color=Sexo), lty="dashed") +
#      facet_grid(Sexo ~ .)

median.quartile <- function(x){
  out <- quantile(x, probs = c(0.25,0.5,0.75))
  names(out) <- c("ymin","y","ymax")
  return(out) 
}

#  geom_violin(scale="count") +
pvio10k <- ggplot(df10k, aes(Division, Speed, fill=Sex)) +
  coord_cartesian(ylim = c(3, 23)) + 
  geom_violin() +
  stat_summary(fun.y="mean", geom="point") +
  geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1)) +
  facet_grid(event~.)


pvio21k <- ggplot(df21k, aes(Division, Speed, fill=Sex)) +
  coord_cartesian(ylim = c(3, 23)) + 
  geom_violin() +
  stat_summary(fun.y="mean", geom="point") +
  geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1)) +
  facet_grid(event~.)

pvio42k <- ggplot(df42k, aes(Division, Speed, fill=Sex)) +
  coord_cartesian(ylim = c(5, 18)) + 
  geom_violin() +
  stat_summary(fun.y="mean", geom="point") +
  geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1)) +
  facet_grid(event~.)


# pvio2 <- ggplot(df, aes(factor(Division), Speed, fill=Sexo)) +
#   geom_violin() +
#   geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1)) +
#   facet_grid(Sexo~.)

#
# Regresion
#
events <- levels(dfComplete$event)
myLm10kMAge <- function(sEvent) {
	df <- df10k[df10k$Sex=="M",] 
	lm(Speed ~ Age, data = df, subset=(event == sEvent))$coef
}
lm10k <- sapply(events, myLm10kMAge)


myLm21kMAge <- function(sEvent) {
	df <- df21k[df21k$Sex=="M",] 
	lm(Speed ~ Age, data = df, subset=(event == sEvent))$coef
}
lm21k <- sapply(events, myLm21kMAge)


print( "lm10k:")
print(lm10k)
print( "lm21k:")
print(lm21k)

lm.speed_by_div.M = lm(Speed ~ Age, data = df10k, subset=(Sex=="M"))


  


