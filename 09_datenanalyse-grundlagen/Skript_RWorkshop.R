### R code from vignette source 'Handout_RWorkshop.Rnw'

###################################################
### code chunk number 1: load data
###################################################
load("student_pisa.rda")
# dat <- read_csv("student_pisa.csv")


###################################################
### code chunk number 2: get an overview
###################################################
# first six rows
head(dat)
# last six rows
tail(dat)
# overview of the variables
colnames(dat)
str(dat)


###################################################
### code chunk number 3: summary for factors
###################################################
summary(dat$elite)
table(dat$elite)


###################################################
### code chunk number 4: generic plot for factors
###################################################
plot(dat$elite) 


###################################################
### code chunk number 5: barplot for factors
###################################################
# alternative
barplot(table(dat$elite))


###################################################
### code chunk number 6: pie plot for factors
###################################################
pie(table(dat$elite))


###################################################
### code chunk number 7: summary for ordered factors
###################################################
summary(dat$spon)
table(dat$spon)


###################################################
### code chunk number 8: generic plot for ordered factors
###################################################
plot(dat$spon)


###################################################
### code chunk number 9: barplot for ordered factors
###################################################
barplot(table(dat$spon), 
        xlab = "How often do you read Spiegel Online?", ylab = "Frequency",
        main = "Barplot")


###################################################
### code chunk number 10: pie plot for ordered factors
###################################################
pie(table(dat$spon), main = "Pie Plot")


###################################################
### code chunk number 11: summary for numeric variables
###################################################
table(dat$age)
summary(dat$age)


###################################################
### code chunk number 12: generic plot for continuous variables
###################################################
plot(dat$age, 
     xlab = "", ylab = "Age")


###################################################
### code chunk number 13: histogram
###################################################
hist(dat$age, 
     xlab = "Age", 
     main = "Histogram")


###################################################
### code chunk number 14: load the package
###################################################
# install.packages("ggplot2")
library(ggplot2)


###################################################
### code chunk number 15: ggplot for elite
###################################################
ggplot(dat, aes(x = elite)) + 
  geom_bar()


###################################################
### code chunk number 16: ggplot for elite + options
###################################################
ggplot(dat, aes(x = elite)) + 
  geom_bar() + 
  xlab("Went / Goes to Elite University") + 
  ylab("Frequency") + 
  theme_minimal()


###################################################
### code chunk number 17: ggplot Age
###################################################
ggplot(dat, aes(x = age)) + 
  geom_histogram(bins = 10) + # with "bins", we can set the number of bins
  xlab("Age") + 
  theme_minimal()


###################################################
### code chunk number 18: ggplot facets
###################################################
ggplot(dat, aes(x = age)) + 
  geom_histogram(bins = 10) +
  facet_wrap(~elite) + 
  xlab("Age") + 
  theme_minimal()


###################################################
### Exercise
# Try to create a plot of your choice
# For example: a plot (e.g., bar or pie plot) to describe the variable "semester"
# Extra challenge: try to create a pie chart for "semester" with ggplot
# Maybe this tutorial helps: https://www.statology.org/ggplot-pie-chart/
###################################################


###################################################
### code chunk number 19: subsetting
###################################################
# subset data
testItems <- dat[, 1:45]
# alternativ: 
testItems <- dat[, paste("X", 1:45, sep = "")]
# alternativ:
testItems <- dat[, grep("X", colnames(dat))]


###################################################
### code chunk number 20: compute sumscore and save it in the dataset
###################################################
dat$sumscore <- rowSums(testItems)
head(dat)


###################################################
### code chunk number 21: histogram with more bins
###################################################
hist(dat$sumscore,
     xlab = "Sum Score",
     main = "Histogram", 
     breaks = 20)


###################################################
### code chunk number 22: boxplot
###################################################
boxplot(dat$sumscore,
        main = "Boxplot")


###################################################
### code chunk number 23: ggplot histgram
###################################################
ggplot(dat, aes(x = sumscore)) + 
  geom_histogram()


###################################################
### code chunk number 24: ggplot boxplot
###################################################
ggplot(dat, aes(y = sumscore)) + 
  geom_boxplot()


###################################################
### code chunk number 25: boxplot for spon readers
###################################################
head(colors())
# boxplot for each group of spon readers
boxplot(sumscore ~ spon, data = dat, 
        col = c("cadetblue3", "indianred2", "wheat3", 
                "yellow1", "whitesmoke", "steelblue1", "tan"),
        ylab = "Sum Score",
        xlab = "How often do you read Spiegel Online?")


###################################################
### code chunk number 26: ggplot boxplot for spon readers
###################################################
ggplot(dat, aes(x = spon, y = sumscore, fill = spon)) + 
  geom_boxplot() + 
  ylab("Sum Score") + 
  xlab("How often do you read Spiegel Online?")


###################################################
### code chunk number 27: facetted ggplot boxplot for spon readers
###################################################
ggplot(dat, aes(x = spon, y = sumscore, fill = spon)) + 
  geom_boxplot() + 
  facet_wrap(~elite) + 
  theme(legend.position = "bottom") + 
  ylab("Sum Score") + 
  xlab("How often do you read Spiegel Online?")



###################################################
### Exercise
# Try to create a plot that describes the relation between 
# age (x-axis) and sumscore (y-axis)
# Extra challenge: the color should describe the variable "elite"
# You can choose R base or ggplot, that's your choice!
###################################################



###################################################
### code chunk number 28: simple regression model
###################################################
# fit model and save it in the object "lmod"
lmod <- lm(sumscore ~ age + elite, data = dat)
summary(lmod)


###################################################
### code chunk number 29: simple regression model
###################################################
# extract regression coefficients
intercept <- coefficients(lmod)[1]
age <- coefficients(lmod)[2]
eliteyes <- coefficients(lmod)[3]


###################################################
### code chunk number 30: plot of regression model
###################################################
# create plot
plot(jitter(dat$age), dat$sumscore,
     col = dat$elite,
     pch = 19,
     xlab = "Alter", ylab = "Sum Score")
# add legend
legend("topright", # Position of the legend
       col = c("black", "red"),
       legend = c("no Elite University", "Elite University"),
       pch = 19)
# add regression lines
abline(a = intercept, b = age,
       lwd = 2) # line width
abline(a = intercept + eliteyes, b = age,
       col = "red",
       lwd = 2)


###################################################
### code chunk number 31: ggplot of regression model
###################################################
# create plot
ggplot(dat, aes(x = age, y = sumscore,
                # unintuitively the argument is no named color, 
                # not fill as for the boxplot above
                color = elite)) + 
  geom_point() + 
  # this how ggplot automatically adds the regression lines
  geom_smooth(method = "lm", 
              formula = y ~ x) + 
  xlab("Alter") + 
  ylab("Sum Score") + 
  theme_minimal() + 
  # also quite unintuitively: to change legend title, the syntax has
  # nothing to do with "legend": 
  labs(color = "Elite University")


###################################################
### code chunk number 32: save plot of regression model
###################################################
# open device
png("myRegressionPlot.png", height = 500, width = 500)
# create plot
plot(jitter(dat$age), dat$sumscore,
     col = dat$elite,
     pch = 19,
     xlab = "Alter", ylab = "Sum Score")
# add legend
legend("topright", # Position of the legend
       col = c("black", "red"),
       legend = c("no Elite University", "Elite University"),
       pch = 19)
# add regression lines
abline(a = intercept, b = age,
       lwd = 2) # line width
abline(a = intercept + eliteyes, b = age,
       col = "red",
       lwd = 2)
# close device
dev.off()


###################################################
### code chunk number 33: save ggplot of regression model
###################################################
# save plot: 
regressionPlot <- 
  ggplot(dat, aes(x = age, y = sumscore, color = elite)) + 
  geom_point() + 
  geom_smooth(method = "lm", formula = y ~ x) + 
  xlab("Alter") + 
  ylab("Sum Score") + 
  theme_minimal() + 
  labs(color = "Elite University")

ggsave(filename = "myRegressionggPlot.png", regressionPlot)


###################################################
### code chunk number 34: Handout_RWorkshop.Rnw:408-409
###################################################
Stangle("Handout_RWorkshop.Rnw", output = "Skript_RWorkshop.R", quiet = TRUE)


