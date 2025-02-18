###
# buoy data cleaning completed in class (2/13)
###

# load in libraries
library(data.table)
library(dplyr)
library(lubridate) # library that makes it easier to work with dates and times
library(ggplot2)
library(tibble)
library(readr)
library(esquisse)

# read in table
# between the file_root and tail is the year of the data that is wanted
# (this way you can easily loop through and read in each year's data)
file_root <- "https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h" 
tail <- ".txt.gz&dir=data/historical/stdmet/"

# function to easily generate url to access buoy data per year 
# (connects file_root and tail via a particular year)
# update function to read in each of the years (not just one)
load_buoy_data <- function(year) {
  path <- paste0(file_root, year, tail)
  
  if (year < 2007) {
    header <- scan(path, what = 'character', nlines = 1)
    buoy <- read.table(path, fill = T, header = T, sep = "")
    buoy <- add_column(buoy, mm = NA, .after = "hh")
    buoy <- add_column(buoy, TIDE = NA, .after = "VIS")
  } else {
    header <- scan(path, what = 'character', nlines = 1)
    buoy <- fread(path, header = F, skip = 1, fill = T)
    
    setnames(buoy, header)
  }
}

all_data1 <- lapply(1985:2024, load_buoy_data)
combined_data1 <- rbindlist(all_data1, fill = T)

# data pre processing
combined_data1 <- combined_data1 %>%
  mutate(
    YY = as.character(YY),
    `#YY` = as.character(`#YY`),
    YYYY = as.character(YYYY)
  )

# Combine year columns safely using coalesce
combined_data1 <- combined_data1 %>%
  mutate(YYYY = coalesce(YYYY, `#YY`, YY))
combined_data1 <- combined_data1 %>%
  mutate(BAR = coalesce(as.numeric(BAR), as.numeric(PRES)),  # Convert BAR and PRES to numeric
         WD = coalesce(as.numeric(WD), as.numeric(WDIR)))

combined_data1 <- combined_data1 %>%
  select(-TIDE, -TIDE.1, -mm,- WDIR, -PRES,-`#YY`,-YY)

combined_data1$datetime <- ymd_h(paste(combined_data1$YYYY, combined_data1$MM, combined_data1$DD, combined_data1$hh, sep = "-"))

combined_data1 <- combined_data1 %>%
  mutate(across(everything(), 
                ~ na_if(as.numeric(as.character(.)), 99) %>%
                  na_if(999) %>%
                  na_if(9999)))

if (!inherits(combined_data1$datetime, "POSIXct")) {
  combined_data1$datetime <- ymd_h(paste(combined_data1$YYYY, combined_data1$MM, combined_data1$DD, combined_data1$hh, sep = "-"))
}

###
# homework 
###

# use unique() to check if there is any NA values (that may need to be removed)
nat <- which(is.na(combined_data1$ATMP))
nat <- length(nat)
nat

# determine  the mean ATMP value of buoy 44013 - remove NA values when calculating
mean(combined_data1$ATMP, na.rm = T)

# generate a histogram using base r to see the spread of ATMP of the buoy over the years
hist(combined_data1$ATMP, main = "Histogram of ATMP of Buoy 44013")

# use ggplot2 to create a scatter plot of ATMP vs WTMP faceted by the month of the year
# new facet label names for MM variable (month names instead of number)
month.labs <- c("Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug",
               "Sept", "Oct", "Nov", "Dec", "")
names(month.labs) <- c("1","2","3","4","5","6","7","8","9","10","11","12","NA")
ggplot(combined_data1, aes(ATMP, WTMP)) + geom_point() + facet_wrap(combined_data1$MM) +
  facet_grid(MM ~ ., labeller = as_labeller(month.labs))
