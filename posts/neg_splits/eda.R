#
# eda.R -- 
#

message("load libraries")

library(dplyr)
library(ggplot2)
library(reshape2)

message("load includes")
# source("runner_load.R")

#
# Functions
#
nHalfmarDistance <- 21.0975 

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
		# sDist = sub("(\\S+)\\s:.*", "\\1", sRaceInterval)
	  sDist = nHalfmarDistance
	} else {
		sDist = interval
	}
	as.numeric( sub("(\\d+)[kK]", "\\1", sDist) )
}

# race;interval;id;Rank;Bib
# ;LastName;FirstName;Team;Nation;YOB
# ;Sex;AgeClass;AcRank;NetTime;GunTime
# ;Age;NetMins
# ;GunMins

LoadBerlHb <- function(y) {
	sFile=sprintf("BerlinHb%d.csv", y);
	df <- read.csv2(sFile)[,c(1,2,4,5,9:12,15:17)]

	df <- df[(df$Age <= 70) & (!is.na(df$Bib)),]  
	df$NetMins <- as.numeric(levels(df$NetMins))[df$NetMins]
	df <- df[df$NetMins > 0,]  
	
	df$event=sprintf("BerlinHb%d", y);
	df$Division <- sapply(df$Age, BrooksDivision)
	df$Dist <- sapply(paste(df$race, ":", df$interval ), DistanceMds)
	df$interval <- sub('^(\\d+)', 'i\\1', df$interval)
	df$Speed <- df$Dist / (df$NetMins/60)
	return(df)
}

message("load data")

# MDS 2014-2016
if (exists("dfBerlHb")) {
  message("Skiping file Read. dfBerlHb")
} else {
  # 2011, 2013, 2014
  # dfBerlHb <- rbind(LoadBerlHb(2014))
  dfBerlHb <- rbind(LoadBerlHb(2011),LoadBerlHb(2013),LoadBerlHb(2015))
  dfBerlHb$event <- as.factor(dfBerlHb$event)
  dfBerlHb$Division <- as.factor(dfBerlHb$Division)
}

#
# Reformat
#
dfAux <- tbl_df(dfBerlHb)
dfAux <- dfAux %>% group_by(Bib, interval) %>% summarize(count=n())

dfAux2 <- dfAux[dfAux$count > 1,]

df <- dcast(dfBerlHb, event + Bib + Sex + Age + Division + Nation ~ interval, value.var="Speed")
df <- df[complete.cases(df),]

# df <- df[df$Sex == 'M',]

#
# computed features
#
df$dsign <- as.factor(sign(df$i10K - df$complete))
df$spd2 <- (nHalfmarDistance-10) / (nHalfmarDistance/df$complete - 10/df$i10K)
df$delta <- (df$i10K - df$spd2)
df$delta_pct <- df$delta / df$i10K * 100
df$delta_abs <- abs(df$delta_pct)

summary(df$dsign)
summary(df$delta)

dgrp_cut <- quantile(df$delta_pct, c(0,0.33,0.66,1))
dgrp_cut

df$dgrp <- cut(df$delta_pct, dgrp_cut,
               labels=c("low","mid","hi"))
summary(df$dgrp)



#
# Explore
#
summary(dfBerlHb)

summary(df$Sex, df$event)

pAgeSpeed <- ggplot(subset(dfBerlHb, interval=="complete"), aes(Speed, Age, color=Sex)) +
  geom_point(alpha=0.1) +
  facet_grid(Sex ~ event)


pDeltaSpeed <- ggplot(df, aes(delta_pct, complete, color=Sex)) +
  geom_point(alpha=0.1) +
  geom_smooth(method="lm") +
  coord_cartesian(xlim = c(-20, +40)) +
  facet_grid(Sex ~ event)

mn <- mean(df$complete)

pDeltaSpeedFast <- ggplot(subset(df, complete > mn+3), aes(delta_pct, complete, color=Sex)) +
  geom_point(alpha=0.1) +
  geom_smooth(method="lm") +
  coord_cartesian(xlim = c(-20, +40)) +
  facet_grid(Sex ~ event)


pDeltaSpeedSlow <- ggplot(subset(df, complete < mn), aes(delta_pct, complete, color=Sex)) +
  geom_point(alpha=0.1) +
  geom_smooth(method="lm") +
  coord_cartesian(xlim = c(-20, +40)) +
  facet_grid(Sex ~ event)

summary(df)

with(df, table(Sex, Division))


#
# Charts
# 


pcant <- ggplot(df, aes(x=Division, fill=Sex)) +
  geom_bar(position="dodge") +
  facet_grid(event~.)

pcat3 <- ggplot(df, aes(Division, complete, fill=Sex)) +
  geom_boxplot() +
  facet_grid(event~Sex)

pAge <- ggplot(df, aes(Age, complete, color=Sex)) +
  geom_point(alpha=0.1) +
  geom_smooth(method="lm") +
  facet_grid(Sex ~ event)

pspli <- ggplot(df, aes(delta_pct, complete, color=Sex)) +
  coord_cartesian(xlim = c(-50, +50)) +
  geom_point(alpha=0.1) +
  geom_smooth(method="lm") +
  facet_grid(Sex ~ event)

pcatdelta <- ggplot(df, aes(Division, delta_pct, fill=Sex)) +
  coord_cartesian(ylim = c(-5, +15)) +
  geom_boxplot() +
  facet_grid(event~Sex)

pdelta <- ggplot(df, aes(delta_pct, fill=Sex)) +
  geom_histogram(bins=50) +
  coord_cartesian(xlim = c(-20, +40)) +
  facet_grid(event~Sex)

pdgrp <- ggplot(df, aes(dgrp, complete, fill=Sex)) +
  coord_cartesian(ylim = c(8, +13)) +
  geom_boxplot() +
  facet_grid(event~Sex)

#
# Neg splits
#
split.t.test <- function(df) {
  vNeg <- df[df$dsign == -1, "complete"]
  vPos <- df[df$dsign != -1, "complete"]
  t.test(vNeg, vPos)
}

split.t.test <- function(pdf) {
  vNeg <- pdf[pdf$dsign == -1, "complete"]
  vPos <- pdf[pdf$dsign != -1, "complete"]
  t.test(vNeg, vPos)
}
ttstW <- split.t.test(subset(df, Sex=='W'))
ttstW
ttstM <- split.t.test(subset(df, Sex=='M'))
ttstM

#
# Rel Age ~ Delta
#
pAgeDelta <- ggplot(df, aes(Age, delta_pct, color=Sex)) +
  coord_cartesian(ylim = c(-50, +50)) +
  geom_point(alpha=0.1) +
  geom_smooth(method="lm", se=FALSE, color="black") +
  facet_grid(Sex ~ event)
cor(df$Age, df$delta_pct )
fitAgeDelta <- lm(delta_pct ~ Age , subset(df, Sex == 'M'))
summary(fitAgeDelta)

pFitAgeDelta <- qplot(.fitted, .resid, data = fitAgeDelta, alpha=0.1) +
  geom_hline(yintercept = 0) +
  geom_smooth(se = FALSE)

#
# Rel Sex ~ Delta
#
pSexDelta <- ggplot(df, aes(Sex, delta_pct, color=Sex)) +
  coord_cartesian(ylim = c(-2, +12)) +
  geom_boxplot()
vM <- df[ df$Sex == 'M', "delta_pct"]
vW <- df[ df$Sex == 'W', "delta_pct"]
t.test(vM, vW)

#
# Compare by delta% group
#

fTbyDgrp <- function(a,b) {
  x <- df[df$dgrp == a,"complete"]
  y <- df[df$dgrp == b,"complete"]
  t.test(x, y)
} 
fTbyDgrp("low", "mid")
fTbyDgrp("mid", "hi")




#
# Analysis
#



lm.M.delta <- lm(complete ~ delta_pct, subset(df, Sex == 'M'))
summary(lm.M.delta)
lm.W.delta <- lm(complete ~ delta_pct, subset(df, Sex == 'W'))
summary(lm.W.delta)

# > summary(lm.M.delta)
# 
# Call:
#   lm(formula = complete ~ delta_pct, data = dfM)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -9.5122 -1.1506 -0.1810  0.9741  9.6769 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) 11.483113   0.009839 1167.08   <2e-16 ***
#   delta_pct   -0.088035   0.001094  -80.44   <2e-16 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1.696 on 42588 degrees of freedom
# Multiple R-squared:  0.1319,	Adjusted R-squared:  0.1319 
# F-statistic:  6471 on 1 and 42588 DF,  p-value: < 2.2e-16
# 

#
# General reg
#

cor(df$Age, df$delta_pc)
cor(as.numeric(df$Sex), df$delta_pc)

fitSex <- lm(complete ~ Sex, df)
fitDelta <- lm(complete ~ delta_pct, df)
fitAge <- lm(complete ~ Age, df)

fit2 <- lm(complete ~ Age + Sex, df)
fit3 <- lm(complete ~ Age + Sex + delta_pct, df)
fit4 <- lm(complete ~ Sex + delta_pct, df)
summary(fit1)

pFitAge <- qplot(.fitted, .resid, data = fitAge, alpha=0.1) +
  geom_hline(yintercept = 0) +
  geom_smooth(se = FALSE)

pFitDelta <- qplot(.fitted, .resid, data = fitDelta, alpha=0.1) +
  geom_hline(yintercept = 0) +
  geom_smooth(se = FALSE)

pFit2 <- qplot(.fitted, .resid, data = fit2, alpha=0.05) +
  coord_cartesian(xlim = c(7, +13), ylim = c(-10, +10)) +
  geom_hline(yintercept = 0) +
  geom_smooth(se = FALSE)

pFit3 <- qplot(.fitted, .resid, data = fit3, alpha=0.05) +
  geom_hline(yintercept = 0) +
  coord_cartesian(xlim = c(5, +15)) +
  geom_smooth(se = FALSE)

pFit4 <- qplot(.fitted, .resid, data = fit4, alpha=0.05) +
  coord_cartesian(xlim = c(5, +15), ylim = c(-10, +10)) +
  geom_hline(yintercept = 0) +
  geom_smooth(se = FALSE)


