# makes pdfs

# Packages ----
library(here)

# Functions ----
source(here::here("R", "functions.R"))

makeReport <- function(p, title, subtitle, authors, la){
  # default = html
  rmarkdown::render(input = here::here("parish_pdfTemplate.Rmd"),
                    params = list(title = title,
                                  subtitle = subtitle,
                                  authors = authors,
                                  parish = parish,
                                  la = la),
                    output_file = paste0(here::here("docs/parish_"), parish, ".pdf")
  )
}

pList <- c("Framlingham", "Badingham")

la <- "East Suffolk" # Too do: needs to lookup LA for each supplied parish

for(p in pList){
  title <- "Estimated Parish Level Emissions"
  subtitle <- p
  authors <- "Ben Anderson (@dataknut)"
  parish <- p
  la <- la
  makeReport(parish, title, subtitle, authors, la)
}