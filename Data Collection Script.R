#### Time Series Analysis Group Project ####
#### Load Libraries ####
library(cdcfluview)
library(tidyverse)
library(ggplot2)
library(tseries)
library(forecast)
library(lubridate)

#Set Working directory
setwd("~/MSA16/Time Series/TimeSeriesProject2018")

#Read in flu data
flu.data <- read.csv("FluCasesReported.csv")

flu.data$pctposcases <- flu.data$ALL_INF / flu.data$SPEC_PROCESSED_NB
flu.data$pctposacases <- flu.data$INF_A / flu.data$SPEC_PROCESSED_NB
flu.data$pctposbcases <- flu.data$INF_B / flu.data$SPEC_PROCESSED_NB

flu.data$SDATE <- as.Date(flu.data$SDATE, "%m/%d/%Y")
flu.data$EDATE <- as.Date(flu.data$EDATE, "%m/%d/%Y")

flu.data$TITLE <- as.factor(flu.data$TITLE)
flu.data <- select(flu.data, Year:TITLE)


flu.ts <- ts(flu.data[,c(12,16,17,19)], start = 2009, frequency = 52)

flu.ts

# Plot All cases reported for flu data
autoplot(flu.ts[,3]) +
        ggtitle("Flu Cases per Week") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()

# Plot Cases of A against B
autoplot(flu.ts[,c(1:2)]) +
        ggtitle("Flu Cases A and B per Week") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()


# Plot onto a polar plot
ggseasonplot(flu.ts[ ,3], polar = TRUE) +
        ylab("Flu Cases")+
        ggtitle("Flu Cases by Week")


# Plot onto a subseries plot
ggsubseriesplot(flu.ts[ ,3], polar = TRUE) +
        ylab("Flu Cases")+
        ggtitle("Flu Cases by Week") + 
        theme_classic()

## Decompose the time series
flu_decomp <- decompose(flu.ts[,3], type = "multiplicative")
plot(flu_decomp)

##ACF Plot
flu_acf <- acf(flu.ts[,3])

flu.diff <- diff(flu.ts[,3])
flu.acfd <- acf(flu.diff)

# Looking at Flu Strain, starting with H1N1 outbreak of 2009
flu.h1n1 <- ts(flu.data[,c(11,15,19,20,22)], start = 2009, frequency = 52)

# Plot cases of H1N1 compared to total flu cases
autoplot(flu.h1n1[,c(1,4)]) +
        ggtitle("Strain AH1N1 Flu Cases per Week") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()


# Looking at Flu A Strains compared to overall flu cases
flu.typea <- ts(flu.data[,c(10:14,19,20,22)], start = 2009, frequency = 52)

# Plot cases of H1N1 compared to total flu cases
autoplot(flu.typea[,c(1:5,7)]) +
        ggtitle("Flu A Cases per Week Compared to All") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()

# Looking at Flu B Strains compared to overall flu cases
flu.typeb <- ts(flu.data[,c(16:18,19,20,22)], start = 2009, frequency = 52)

# Plot cases of H1N1 compared to total flu cases
autoplot(flu.typeb[,c(1:3,5)]) +
        ggtitle("Flu B Cases per Week Compared to All") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()


# Tests for the flu compared to flu cases
flu.test <- ts(flu.data[,c(6,17,20:22)], start = 2009, frequency = 52)

# Plot cases of H1N1 compared to total flu cases....changed themes to remove gridlines
autoplot(flu.test[,c(1:2)]) +
        ggtitle("Processed Flu Tests and Cases") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()

autoplot(flu.test[,3])+
        ggtitle("Processed Flu Tests and Cases") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()

autoplot(flu.test[,3:4])+
        ggtitle("Processed Flu Tests and Cases Comparing A vs. Total") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()

autoplot(flu.test[,3:5])+
        ggtitle("Processed Flu Tests and Cases Comparing B vs. Total") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()

autoplot(flu.test[,4:5])+
        ggtitle("Processed Flu Tests and Cases Comparing A vs. B") +
        xlab("Weeks, 2009-present") +
        ylab("Flu Cases") + 
        theme_classic()


## Create a Forcast Model with Flu A with and without differencing
fitA <- stlf(flu.ts[,1])
plot(fitA)

fitA.diff <- stlf(diff(flu.ts[,1]))
plot(fitA.diff)

## Forcast for Flu B
fitB <- stlf(flu.ts[,2]) 
plot(fitB)

fitB.diff <- stlf(diff(flu.ts[,2]))
plot(fitB.diff)

# Forcast for all Flu
fitall <- stlf(flu.ts[,3])
plot(fitall)

### Differencing
fitC.diff <- stlf(diff(flu.ts[,3]))
plot(fitC.diff)


#Tests with decomposing and differencing...
autoplot(decompose(diff(flu.ts[,1]), type = "mult"))

plot(acf(diff(flu.ts[,1])))

adf.test(diff(flu.ts[,1]), k = 52)
# Arima_models


=======
=======

#Arima models with boxcox transformation to stabilize variance
lambda <- BoxCox.lambda(flu.ts[,1])

flua.boxcox <- BoxCox(flu.ts[,1], lambda = lambda)
flua.arima <- auto.arima(flua.boxcox, D = 1)
autoplot(forecast(flua.arima, level = c(80, 95), h = 100)) +
      ggtitle("Forecast for Flu A") +
      xlab("Weeks, 2009-2020") +
      ylab("Flu Cases") + 
      theme_classic() +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"))

checkresiduals(flua.arima)

lambda2 <- BoxCox.lambda(flu.ts[,2])

flub.boxcox <- BoxCox(flu.ts[,2], lambda = lambda2)
flub.arima <- auto.arima(flub.boxcox, D = 1)
autoplot(forecast(flub.arima, level = c(80, 95), h = 100)) +
      ggtitle("Forecast for Flu B") +
      xlab("Weeks, 2009-2020") +
      ylab("Flu Cases") + 
      theme_classic() +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"))

checkresiduals(flub.arima)

lambda3 <- BoxCox.lambda(flu.ts[,3])

fluall.boxcox <- BoxCox(flu.ts[,3], lambda = lambda3)
fluall.arima <- auto.arima(fluall.boxcox, D = 1)
autoplot(forecast(fluall.arima, level = c(80, 95), h = 100)) +
      ggtitle("Forecast for A and B") +
      xlab("Weeks, 2009-2020") +
      ylab("Flu Cases") + 
      theme_classic() +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"))

checkresiduals(fluall.arima)
