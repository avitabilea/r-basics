################################################################
# Purpose: Short example script to clean data from Qualtrics
# Author: Andrew Avitabile
################################################################

# Clear everything in the environment
rm(list = ls())

################################################################
#Basics of R
################################################################

# The colon allows us to write sequences of numbers
1:10

# The mean function is built into base R
mean(1:10)

# Generally we use the equals sign within functions to assign a value parameter in the function.
mean(x = 1:10)
# Notice how this does not create a value in the top right panel
exists("x")

# Whereas we generally use "<-" to assign things to R's memory 
y <- mean(1:10)
exists("y")

# There are many types of objects in R
## Here are a few, increasing in terms of complexity
### Vector - one dimensional---even a single number is a vector. usually defined with "c()"
vector_of_one <- c(1)
vector_of_two <- c(1, 2)
vector_of_strings <- c("a", "b", "c")

### Matrix - 2D --- not super common. Columns all need same type (e.g., character, numeric)
matrix1 <- matrix(data = 1:6, nrow = 2, ncol = 3)
matrix2 <- matrix(data = c("a", "b", "c"), nrow = 2, ncol = 3)

### Data frame - 2D --- General tabular dataset; think Excel. notice you can name rows.
df1 <- data.frame(col1 = c(1, 2, 3), COLUMN2 = c("a", "b", "c"), row.names = c("row number 1", "some name", "three"))

### List - 1D - can hold vectors, data frames, other objects
list <- list(vector_of_one, df1, matrix1)

#In base R, you can access objects inside of vectors, dataframes, and lists using brackets
##Code below pulls third object in vector "vector_of_strings"
vector_of_strings[3]

# For data frames
##Get first column
df1[1]
##Get first row
df1[1,]
##Get first column
df1[,2]

# Lists function similarly, although we need to use double brackets to access the actual object
list[1] #Gives the first object AS A LIST 
list[[1]] #Gives the first object AS ITSELF

# Notice the difference in classes here
class(list[2])
class(list[[2]])

# Throws an error--we cannot request the second row of a list because it's unidimensional!
list[2][2,]
# Gives us the first row of the data frame that is the second object of the list
list[[2]][1,]

################################################################
#Packages
################################################################
#What's great about R is that we are not limited to the base language
# R is open source, meaning 1) it's free, always 2) folks can contribute to it, generally via packages
# The most commonly used collection of packages is called the "tidyverse"
# The tidyverse is a collection of packages for data processing, analysis, visualization, etc.
# The best part about the tidyverse is that it uses a common set of inputs for all functions, 
# that is it's very readable and things "play well" together.
# We'll use mostly tidyverse functions from here on out
# Learn more about the tidyverse here: https://tidyverse.org/

# In order to use packages, we need to install them from the internet. 
# Most packages are stored on CRAN (Comprehensive R Archive Network)
# You don't really need to know anything about this, other than that when people develop packages and put them 
# on CRAN you can access them directly via RStudio.

# Usually, we download packages using the following function:
# install.packages("tidyverse")
# Then we load them into R each sessions using the function
# library(tidyverse)

# I am partial to a package called "pacman", which does this automatically for us in one step
requireNamespace("pacman")
pacman::p_load(tidyverse)
# Notice that I used "pacman::" this tells R, use the function p_load within the package "pacman".
# This is not required, but can be helpful if packages have functions with the same name.
# Notice in the Packages window that the tidyverse is actually a collection of packages (e.g., "dplyr", "ggplot2")

# Another package I like is called "here"
pacman::p_load(here)
# The here function works very well with R projects in that it always points to the folder where the project lives
# This is extremely helpful if you (or collaborators!) access things from different computers
here()

# Now that we have access to the packages we need, let's get started processing data.

################################################################
#Processing data
################################################################

# Clear everything
rm(list = ls())

# Load data
here("data", "VA Grading Policies_November 17, 2026_18.26.csv")
read.csv(here("data", "VA Grading Policies_November 17, 2026_18.26.csv"))
data <- read.csv(here("data", "VA Grading Policies_November 17, 2026_18.26.csv"))
names(data)

# Personally, I like to follow tidyverse guidelines for naming variables
data <- janitor::clean_names(data)
# Notice how this overwrote my dataset
names(data)

# Dyplr is the tidyverse package for manipulating data
# We're going to use a few dplyr functions to clean this dataset.
# There is a great cheat sheet for this here: https://nyu-cdsc.github.io/learningr/assets/data-transformation.pdf

# Filter subsets your data. One thing to note---dplyr functions are generally "verbs" in that they denote an action
data <- dplyr::filter(data, row_number() > 2)

# Let's keep just the columns we want.
# Notice we can reorder and rename columns in the select function
data <- select(data, division, date = recorded_date, name:sat_act_payment)

# Date is currently stored as a character. We would like it to be an actual date, so let's do some cleaning.
# Luckily this date format is somewhat common, so the tidyverse has functions that automatically do this.
# Sometimes (often?) dates are stored in weird formats that require manipulating
class(data$date)
data <- mutate(data, date = date(ymd_hms(date)))
class(data$date)

# Now we need to work with these big, messy variables
data$grade_scale

# Notice how this variable is stored as one big block of text (actually a format called JSON).
# Luckily, there is a package called "jsonlite" that reads this format and turns it into an R list.
pacman::p_load(jsonlite)

# Let's see what happens when we run fromJSON() on just the first row of that column
first_row_list <- fromJSON(data$grade_scale[1])
names(first_row_list)

# We only want the "values" part
first_row_list[["values"]]

# Now let's do this for EVERY row in our dataset using mutate() and rowwise()
# rowwise() tells dplyr: "do the next step one row at a time"
data <- rowwise(data)
data <- mutate(data, values_list = list(fromJSON(grade_scale)$values))
data <- ungroup(data)

# That worked for ONE column. But every survey question from grade_scale to
# sat_act_payment is stored as JSON.Instead of copying that line 10 times,
# we can use across(), which says: "do this same thing to each of these columns."
# Inside across(), ".x" is a stand-in for "whichever column we're on right now."

# First, let's drop the values_list column we just made, since we're about to redo it for everything
data <- select(data, -values_list)

data <- rowwise(data)
data <- mutate(data, across(.cols = grade_scale:sat_act_payment, ~ list(fromJSON(.x)$values)))
data <- ungroup(data)

# Now each of those columns is a list column. unnest_wider() can spread out
# several columns at once. names_sep = "__" glues the original column name onto
# each school year, so we get e.g. "retake__2015-16" instead of ten columns all called "2015-16".
# We use a DOUBLE underscore because the question names already have single
# underscores in them (e.g., "grade_scale"). That will matter in the next step.
data <- unnest_wider(data, grade_scale:sat_act_payment, names_sep = "__")
names(data)

# Right now the data is "wide": one row per division, with a separate column
# for every question in every year. That's hard to work with.
# We'd rather have it "long": one row per division per year, with one column per question.
# pivot_longer() helps here.
#   - contains("__") picks every column with a double underscore in its name
#   - names_sep = "__" splits each name in two, e.g. "retake__2015-16" -> "retake" and "2015-16"
#   - names_to = c(".value", "year") says: the first piece stays a column name,
#     and the second piece goes into a new column called "year"
# You will ALWAYS need to look up how to use pivot_longer and pivot_wider--they're hard to remember!
data <- pivot_longer(data, contains("__"), names_to = c(".value", "year"), names_sep = "__")

# Now each division now has one row per school year.
names(data)

################################################################
# The example above was a longer program than needed. 
# In reality, we might do many of these steps at once
# Notice in the "clean" block, I use "|>", which is called the "pipe"
# This is part of the tidyverse and tells R to "use the result of the previous
# as the first parameter for the next
################################################################

# Clear everything
rm(list = ls())

# Load packages
pacman::p_load(tidyverse, here, janitor, jsonlite)

# Read in data
data <- read.csv(here("data", "VA Grading Policies_November 17, 2026_18.26.csv"))

# Clean
data <- data |>
  clean_names() |>
  filter(row_number() > 2) |>
  select(division, date = recorded_date, name:sat_act_payment) |>
  mutate(date = date(ymd_hms(date))) |>
  rowwise() |>
  mutate(across(grade_scale:sat_act_payment, ~ list(fromJSON(.x)$values))) |>
  ungroup() |>
  unnest_wider(grade_scale:sat_act_payment, names_sep = "__") |>
  pivot_longer(contains("__"), names_to = c(".value", "year"), names_sep = "__")

# Save the dataset
writexl::write_xlsx(data, here("output", "cleaned_qualtrics_data.xlsx"))