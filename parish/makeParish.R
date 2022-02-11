# makes pdfs

# Packages ----
library(data.table)
library(here)
library(rmarkdown)

# Functions ----
source(here::here("R", "functions.R"))

# rmarkdown::render(input = here::here("rmd", f),
#                   output_format ="all", # output all formats specified in the rmd
#                   output_dir= here::here("docs")
# )

makeReport <- function(title, subtitle, parish, district){
  # default = whatever is set in yaml
  rmarkdown::render(input = here::here("parish", "parish_Template.Rmd"),
                    params = list(title = title,
                                  subtitle = subtitle,
                                  parish = parish,
                                  district = district),
                    #output_format ="all", # output all formats specified in the rmd
                    output_file = paste0(here::here("docs/parish_"), parish, version)
  )
}

# load the data here so we can easily re-run Rmd chunks ----
#> territorial ----
parish_terr_abs <- path.expand("~/Dropbox/data/cse/cse_ImpactTool/2021-12-07/parish-all-territorial-absolute.csv")
dt <- data.table::fread(parish_terr_abs) # keep wide
parish_namesDT <- dt[, .(name, id)] # extract parish names & codes for LA matching before we melt
# how many parishes?
uniqueN(parish_namesDT$id)
mdt <- melt(dt, id.vars = c("id", "name")) # melt

# remove Power generation
# Note: "this category overlaps with electricity emissions and is provided for information only."
# In some circumstances this might be useful to look at?
# Might identify point sources of interest?
parish_terr_absDT <- mdt # [variable != "Power generation (t CO2e)"] 
parish_terr_perhh <- path.expand("~/Dropbox/data/cse/cse_ImpactTool/2021-12-07/parish-all-territorial-per-household.csv")
mdt <- melt(data.table::fread(parish_terr_perhh), id.vars = c("id", "name"))
parish_terr_perhhDT <- mdt #[variable != "Power generation (t CO2e)"]

#> consumption ----
parish_cons_abs <- path.expand("~/Dropbox/data/cse/cse_ImpactTool/2021-12-07/parish-all-consumption-absolute.csv")
parish_cons_absDT <- melt(data.table::fread(parish_cons_abs), id.vars = c("id", "name"))
parish_cons_perhh <- path.expand("~/Dropbox/data/cse/cse_ImpactTool/2021-12-07/parish-all-consumption-per-household.csv")
parish_cons_perhhDT <- melt(data.table::fread(parish_cons_perhh), id.vars = c("id", "name"))

# load district data ----
la_terr_perhh <- path.expand("~/Dropbox/data/cse/cse_ImpactTool/local-authority-all-territorial-per-household.csv.gz")
mdt <- melt(data.table::fread(la_terr_perhh), id.vars = c("id", "name"))
la_terr_perhhDT <- mdt #[variable != "Power generation (t CO2e)"]

la_cons_perhh <- path.expand("~/Dropbox/data/cse/cse_ImpactTool/local-authority-all-consumption-per-household.csv.gz")
la_cons_perhhDT <- melt(data.table::fread(la_cons_perhh), id.vars = c("id", "name"))

# parish to districts LUTs ----
# > parish to district ----
# NB this only covers civil parishes - as does the CSE data
# See https://www.carbon.place/ and inspect the ward vs parish boundaries!
# includes Wales
parish_lut_DT <- data.table::fread("~/Dropbox/data/UK_lookups/Parishes__December_2020__Names_and_Codes_in_England_and_Wales_V2.csv")
# how many parishes?
uniqueN(parish_lut_DT$PAR20CD)

# > testing other parish look-up tables ----
# parish to ward & district: this one has some parishes split across more than one ward
# includes Wales
parishToWard_lut_DT <- data.table::fread("~/Dropbox/data/UK_lookups/Parish_to_Ward_to_Local_Authority_District__December_2020__Lookup_in_England_and_Wales.csv.gz")
# how many parishes?
uniqueN(parishToWard_lut_DT$PAR20CD)
parishToWard_lut_DT[, .(nRows = .N), keyby = .(PAR20NM, WD20NM)][nRows > 1]

# postcode to parish & ward & district: this one has empty cells for parish if not a civil parish
postcodeToParishWard_lut_DT <- data.table::fread("~/Dropbox/data/UK_postcodes/pcd11_par11_wd11_lad11_ew_lu.csv.gz")
# how many parishes?
uniqueN(postcodeToParishWard_lut_DT$par11cd)
# as an example - this is an area near the University of Southampton:
head(postcodeToParishWard_lut_DT[pcd7 %like% "SO17"])
# as an example - this is Lee on Solent:
head(postcodeToParishWard_lut_DT[pcd7 %like% "PO13"])

# set parish list ----
# Fails for parishes inside unitary authorities due to look-up table (see above)
# names MUST EXACTLY match the parish name in the CSE data files
pList <- c("Botley", "Clanfield (East Hampshire)", "Hambledon (Winchester)", 
           "Oakley (Basingstoke and Deane)", "Micheldever", "Sway", 
           "Burley (New Forest)", "Cocking", # Hampshire
           "Framlingham", "Badingham", # Suffolk
           "Longnor (Staffordshire Moorlands)") # Staffordshire

message("Parishes: ", pList)

version <- "_v2"

for(p in pList){
  # set params
  title <- p
  subtitle <- "Estimated Parish Level Greenhouse Gas (GHG) Emissions 2017/18"
  parish <- p
  # select district
  # need to use the exact parish code to allow for duplicate names etc
  parish_code <- parish_namesDT[name == p, id]
  district <- parish_lut_DT[PAR20CD == parish_code, LAD20NM]
  message("Running report on: ", title, " (", parish_code , ") - ", district)
  makeReport(title, subtitle, parish, district)
}