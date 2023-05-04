

# Project: dropitlikeitsCOP
# Script: 00_setup
# Developers: Jessica Stephens (USAID), LaChandra Spencer (CDC)
# Use: To drop SNU Targets set during COP in TST to the PSNU level for IP Workplans


# Instructions:

######## ONLY RUN THESE STEPS THE FIRST TIME USING THIS CODE ON YOUR COMPUTERS #####
## Install Packages

#From CRAN
install.packages(c("tidyverse","readxl","reshape2", "janitor"))

#From GitHub
install.packages("remotes")
remotes::install_github("USAID-OHA-SI/glamr", build_vignettes = TRUE)
remotes::install_github("USAID-OHA-SI/gophr", build_vignettes = TRUE)
remotes::install_github("USAID-OHA-SI/glitr", build_vignettes = TRUE)

# Create standard folder structure from glamr
si_setup()

# Add raw data to the Data folder
# This step needs to be done physically, outside of R

########  RUN THIS SET EVERY TIME YOU START RSTUDIO #####

## Load Packages

library(tidyverse)
library(readxl)
library(reshape2)
library(janitor)

library(glamr)
library(gophr)
library(glitr)
