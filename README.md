# R Basics

A hands-on introduction to R for people who have never used it. You'll learn the building blocks of the language, how to use packages, and how to take a messy survey export from Qualtrics and turn it into a clean, analysis-ready dataset.

The data used here is a made-up example of a survey on Virginia school division grading policies.

## Getting set up

1. **Install R** from [CRAN](https://cran.r-project.org/).
2. **Install RStudio** (free) from [Posit](https://posit.co/download/rstudio-desktop/).
3. **Download this course.** Click the green **Code** button at the top of this page, choose **Download ZIP**, and unzip it somewhere you'll find it again.
4. **Open the project.** Double-click `R Basics.Rproj`. This opens RStudio with everything pointed at the right folder.
5. **Install the packages** by running this once in the RStudio console:

   ```r
   install.packages(c("pacman", "writexl"))
   ```

   The scripts use `pacman` to install and load everything else automatically.

## Lessons

| # | Script | What you'll learn |
|---|--------|-------------------|
| 0 | [`scripts/00.clean data.R`](scripts/00.clean%20data.R) | R basics (vectors, data frames, lists), packages, and cleaning a Qualtrics export with the tidyverse: `filter()`, `select()`, `mutate()`, parsing JSON, `across()`, `unnest_wider()`, `pivot_longer()`, and the pipe `|>` |

Open a script in RStudio and run it line by line with **Ctrl + Enter** (**Cmd + Enter** on a Mac). Read the comments as you go; they're the lesson.

## Folder layout

```
R Basics.Rproj   <- open this first
data/            <- raw survey data
scripts/         <- lessons, in order
output/          <- cleaned data gets saved here
```

## Helpful references

- [R for Data Science](https://r4ds.hadley.nz/), a free book and the best next step after this course
- [The tidyverse](https://www.tidyverse.org/)
- [dplyr cheat sheet](https://nyu-cdsc.github.io/learningr/assets/data-transformation.pdf)

---

Created by Andrew Avitabile.
