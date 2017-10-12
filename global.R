## global.R ##
library(dplyr)
library(ggplot2)
library(tidyr)
library(lazyeval)
library(plotly)


#Read NFL data into data.frame
nfl = read.csv('NFLPlaybyPlay2015.csv')

#Remove row names
rownames(nfl) = NULL

#Convert play types of sacks to be passes
nfl$PlayType[which(nfl$PlayType == 'Sack')] = 'Pass'

#Flip yrdline100
nfl$yrdline100 = 100 - nfl$yrdline100

#Rename columns
nfl = nfl %>% 
  rename(., TimeOfPoss = PlayTimeDiff)
nfl = nfl %>%
  rename(., Offense = posteam)
nfl = nfl %>%
  rename(., Defense = DefensiveTeam)
nfl = nfl %>%
  rename(., YardsToFirst = ydstogo)
nfl = nfl %>%
  rename(., Down = down)
nfl = nfl %>%
  rename(., YardLine = yrdline100)
nfl = nfl %>%
  rename(., Interception = InterceptionThrown)

#Convert Down to factor
nfl$Down = factor(nfl$Down)

#Add columns for points scored per play
nfl = nfl %>%
  mutate(., FieldGoalResult = 
           ifelse(nfl$FieldGoalResult == 'Good', 1, 0))
nfl$FieldGoalResult[is.na(nfl$FieldGoalResult)] = 0
nfl = nfl %>%
  mutate(., TwoPointConv = 
           ifelse(nfl$TwoPointConv == 'Success', 1, 0))
nfl$TwoPointConv[is.na(nfl$TwoPointConv)] = 0
nfl = nfl %>%
  mutate(., ExPointResult = 
           ifelse(nfl$ExPointResult == 'Made', 1, 0))
nfl$ExPointResult[is.na(nfl$ExPointResult)] = 0

nfl$PointsScored = 
  6*nfl$Touchdown + 3*nfl$FieldGoalResult + 2*nfl$TwoPointConv + nfl$ExPointResult

#List of teams
teams = nfl %>%
  filter(., !(is.na(Offense) | Offense == '')) %>%
  select(., Offense) %>%
  arrange(., Offense) %>%
  unique(.) %>%
  rename(., Team = Offense)

#Quarterbacks
quarterbacks = nfl %>%
  filter(., !(is.na(Passer) | Passer == '')) %>%
  select(., Offense, Passer) %>%
  arrange(., Offense, Passer) %>%
  unique(.) %>%
  rename(., Team = Offense)

#Receivers
receivers = nfl %>%
  filter(., !(is.na(Receiver) | Receiver == '')) %>%
  select(., Offense, Receiver) %>%
  arrange(., Offense, Receiver) %>%
  unique(.) %>%
  rename(., Team = Offense)

#Running Backs
rushers = nfl %>%
  filter(., !(is.na(Rusher) | Rusher == '')) %>%
  select(., Offense, Rusher) %>%
  arrange(., Offense, Rusher) %>%
  unique(.) %>%
  rename(., Team = Offense)

#Stats
stats = c('PointsScored','Yards.Gained','RushAttempt','PassAttempt','Reception',
          'Interception','Fumble','Sack','TimeOfPoss')

#Function to insert row into data frame
insertRow <- function(existingDF, newrow, r) {
  existingDF[seq(r+1,nrow(existingDF)+1),] <- existingDF[seq(r,nrow(existingDF)),]
  existingDF[r,] <- newrow
  existingDF
}