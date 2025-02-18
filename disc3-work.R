###
# discussion work 
###

# plots can be created in both base R and with ggplot (but ggplot will allow you to
# make much more detailed plots than base R)

# generate data table of different city information
city <- data.frame(
  porto = rnorm(100),
  aberdeen = rnorm(100),
  nairobi = c(rep(NA, 10), rnorm(90)),
  genoa = rnorm(100)
)

# create a scatter plot that plots two cities against each other
plot(city$porto, city$aberdeen)

# use par and mfrow to plot 4 graphs within one screen
# can use main to rename the title of the plot
# can use col to choose the color of the plot
# comment following line out if you want just one plot again
par(mfrow = c(2, 2))
plot(city$porto, city$genoa, type = "l", main = "Plot of Porto vs Genoa")
hist(city$porto, col = "blue", main = "Histogram of Porto")
hist(city$genoa, col = "green", main = "Histogram of Genoa")
hist(city$aberdeen, col = "purple", main = "Histogram of Aberdeen")

par(mfrow = c(1,1))
hist(city$porto, freq = F) # need to set freq = F for correct density line 
lines(density(city$porto))

# use pairs() to create a multi-panel scatter plot with plot of all combo of vars
png(filename = "city_pair_plot.png")
pairs(city, panel = panel.smooth)

###
# homework
###

# box plots
# create a box plot of Porto using the generated city data
boxplot(city$porto, main = "Box Plot of Porto") 

# generate a box plot and violin plot using the penguin data from class
# load in necessary libraries 
library(tidyverse)
library(palmerpenguins)

# load in penguin data set into r
data("penguins")

# generate a box plot to see how the bill_depth_mm variable changes with each species
boxplot(bill_depth_mm ~ species, data = penguins, ylab = "bill depth (mm)",
        xlab = "species", main = "Box Plot of Bill Depth over Species")

# facets in ggplot


# legends in ggplot