(1)

A = double(15)
for (x in 1:15) {
  A[x] = P * (1 + R / 100)^x
}

(2)

Heights = c(180, 165, 160, 193)
Weights = c(87, 58, 65, 100)
BMI = Weights / (Heights / 100) ^ 2

(3)

data(cars)
print(head(cars, 5))
state = sample(c('NY', 'CA', 'CT'), nrow(cars), replace = TRUE)
cars$state = state
cars$ratio = cars$dist / cars$speed
mean(cars$ratio)
sd(cars$ratio)

(4)

timessquare = read.csv("/Users/davidkogan/Downloads/RPart1_Homework/TimesSquareSignage.csv")
nrow(timessquare)
ncol(timessquare)
lapply(timessquare, typeof)

#Total number of missing values
sum(is.na(timessquare))

#Rows with missing values
tmp = logical(nrow(timessquare))
for (i in 1:nrow(timessquare)) {
  tmp[i] = T %in% is.na(timessquare)[i,]
}
misrows = timessquare[tmp,]

#Columns with missing values
tmp = logical(ncol(timessquare))
for (i in 1:ncol(timessquare)) {
  tmp[i] = T %in% is.na(timessquare)[,i]
}
miscols = timessquare[,tmp]

(5)
#Observations from Upper Broadway
write.csv(timessquare[timessquare$Location == 'Upper Bway',], file = 'upper_broadway.csv')

#Observations with greater-than-average square footage
write.csv(timessquare[timessquare$TOTAL.SF > mean(timessquare$TOTAL.SF),], file = 'high_sqft.csv')

#The name, address and location of the top observations in terms of total square footage
write.csv(timessquare[timessquare$TOTAL.SF > mean(timessquare$TOTAL.SF),c('Screen.Name..LED...Vinyl.Signs.', 'Building.Address', 'Location.Description')]
, file = 'high_sqft_nameadloc.csv')

