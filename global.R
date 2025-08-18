MAX_FILE_SIZE_MB <- 10L
options(shiny.maxRequestSize = MAX_FILE_SIZE_MB*1024^2)
options(shiny.sanitize.errors = TRUE)

library(shiny)
library(rmarkdown)
library(anytime)
library(data.table)
library(readr)
library(shinydisconnect)
library(dotenv)
load_dot_env()
ga_id <- Sys.getenv("GA_TRACKING_ID")

source("helpers/chooser.R")
source("helpers/Functions.R")
source("helpers/Function_Investigate2.R")
source("helpers/Function_createRmd2.R")
