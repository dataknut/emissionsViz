# makes pdfs

# Packages ----
library(here)

# Functions ----
source(here::here("R", "functions.R"))

makeReport <- function(p, title, subtitle, authors, la){
  # default = whatever is set in yaml
  rmarkdown::render(input = here::here("parish", "parish_Template.Rmd"),
                    params = list(title = title,
                                  subtitle = subtitle,
                                  parish = parish),
                    output_file = paste0(here::here("docs/parish_"), parish)
  )
}

# Fails for parishes inside unitary authorities due to look-up table (see rmd)
pList <- c("Botley", "Framlingham", "Badingham")

for(p in pList){
  title <- p
  subtitle <- "Estimated Parish Level Greenhouse Gas (GHG) Emissions 2017/18"
  parish <- p
  la <- la
  makeReport(parish, title, subtitle)
}