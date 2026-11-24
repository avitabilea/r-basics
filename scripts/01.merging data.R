################################################################
# Purpose: Practice filtering, cleaning, and merging two datasets
# Author: Andrew Avitabile
################################################################

# Clear everything
rm(list = ls())

# Load packages
pacman::p_load(tidyverse)

################################################################
# Make two example datasets
# (You don't need to understand how these are made. Just run this block!)
################################################################

# Dataset 1: enrollment by division and school year. This one is already clean.
# tribble() lets us type a small dataset row by row, which is easy to read.
enrollment <- tribble(
  ~division,              ~year,     ~students,
  "Albemarle County",     "2022-23", 14102,
  "Albemarle County",     "2023-24", 14250,
  "Albemarle County",     "2024-25", 14388,
  "Charlottesville City", "2022-23",  4310,
  "Charlottesville City", "2023-24",  4275,
  "Charlottesville City", "2024-25",  4198,
  "Fairfax County",       "2022-23", 180216,
  "Fairfax County",       "2023-24", 181701,
  "Fairfax County",       "2024-25", 182494,
  "Richmond City",        "2022-23", 21004,
  "Richmond City",        "2023-24", 20811,
  "Richmond City",        "2024-25", 20650
)

# Dataset 2: test pass rates. This one is MESSY, like real data from another source:
#   - division names are in ALL CAPS
#   - the year is just the spring year (2023), not the school year ("2022-23")
#   - pass_rate is text with a "%" sign, not a number
#   - it has both Math and Reading, and an extra year we don't need
set.seed(123)  # makes the random numbers the same every time you run this
test_scores <- expand_grid(
  division    = c("ALBEMARLE COUNTY", "CHARLOTTESVILLE CITY", "FAIRFAX COUNTY", "RICHMOND CITY"),
  spring_year = 2022:2025,
  subject     = c("Math", "Reading")
) |>
  mutate(pass_rate = paste0(round(runif(n(), min = 55, max = 90)), "%"))

# Take a look at both
enrollment
test_scores

################################################################
# Your task: make ONE dataset with enrollment AND math pass rates,
# with one row per division per school year.
#
# Hint: try merging the two datasets right away with left_join().
# What goes wrong? To merge, the datasets need columns that match
# EXACTLY, in both name and content.
################################################################

# Step 1: Filter test_scores to the rows you need
# (Which subject? Which years show up in enrollment?)


# Step 2: Clean the variables so they match enrollment
#   - division: make the names match. Try str_to_title().
#   - year: turn the spring year (2023) into a school year ("2022-23").
#     paste0() glues text together, and str_sub() grabs part of a string.
#   - pass_rate: turn "72%" into the number 72. Try parse_number().


# Step 3: Keep only the columns you need, and give pass_rate a clearer name


# Step 4: Merge the two datasets with left_join()


# Step 5: Check your merge! Did every row find a match?
# (Hint: if a row didn't match, its pass rate will be NA.)


################################################################
# Bonus:
#   1. Do it again for Reading instead of Math.
#   2. Rewrite Steps 1-4 as ONE pipe, like at the end of the last script.
################################################################
