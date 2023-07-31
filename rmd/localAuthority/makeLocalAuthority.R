# makes pdfs

# Packages ----
library(here)
library(rmarkdown)
library(bookdown)

# Functions ----
source(here::here("R", "functions.R"))

# rmarkdown::render(input = here::here("rmd", f),
#                   output_format ="all", # output all formats specified in the rmd
#                   output_dir= here::here("docs")
# )

makeReport <- function(title, subtitle, district){
  # default = whatever is set in yaml
  rmarkdown::render(input = here::here("rmd","localAuthority", "localAuthority_Template.Rmd"),
                    params = list(title = title,
                                  subtitle = subtitle,
                                  district = district),
                    #output_format ="all", # output all formats specified in the rmd
                    output_file = paste0(here::here("docs/localAuthority/localAuthority_"), district, version)
  )
}

#> set district list ----
# names MUST EXACTLY match the district name in the data files
laList <- c("Southampton", 
           "Staffordshire Moorlands", 
           "East Suffolk") 

message("Districts: ", laList)

version <- "_v1"

#> run the report ----
for(la in laList){
  # set params
  title <- "Estimated Local Authority Level Greenhouse Gas (GHG) Emissions 2005 - current:"
  subtitle <- la
  message("Running report on: ", subtitle)
  makeReport(title, subtitle, la)
}