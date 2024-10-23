# Set working directory
setwd("C:/Users/Samuel/Desktop/R-Hydrological-Analysis")

getwd()

# Extract R code from the RMarkdown file
knitr::purl("Hydrological_Analysis.Rmd", output = "Hydrological_Analysis.R")
