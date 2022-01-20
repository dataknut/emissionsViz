# makes Science Based Targets plots

# Packages ----
library(data.table)
library(ggplot2)
library(here)
library(rmarkdown)

# Functions ----
source(here::here("R", "functions.R"))

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

# > parish to district ----
# NB this only covers civil parishes - as does the CSE data
# See https://www.carbon.place/ and inspect the ward vs parish boundaries!
# includes Wales
parish_lut_DT <- data.table::fread("~/Dropbox/data/UK_lookups/Parishes__December_2020__Names_and_Codes_in_England_and_Wales_V2.csv")
# how many parishes?
uniqueN(parish_lut_DT$PAR20CD)

# set the territorial colours ---
# colours borrowed from https://git.soton.ac.uk/twr1m15/la_emissions_viz/-/blob/master/shiny/app.R
# for details, use set for each sector
cse_terr_domestic_pal <- RColorBrewer::brewer.pal(n = 8, name = "Blues")[3:8]    # domestic blues, 6 categories

cse_terr_industry_pal <- RColorBrewer::brewer.pal(n = 8, name = "Greys")[3:8]    # industry greys, 6 categories incl Agric

cse_terr_transport_pal <- RColorBrewer::brewer.pal(n = 9, name = "Oranges")[3:7] # transport incl aviation & shipping oranges, 5 categories

cse_terr_other_pal <- RColorBrewer::brewer.pal(n = 6, name = "RdPu")[4:5]    #  greys,  2 categories  waste & F-gases

cse_terr_lulucf_pal <- "#31A354" # pick a green

# for details, combine sets
cse_terr_colours <- c(cse_terr_domestic_pal, 
                      cse_terr_industry_pal, 
                      cse_terr_transport_pal,
                      cse_terr_lulucf_pal,
                      cse_terr_other_pal)
parish_terr_absDT[, variable := factor(variable)]
cse_terr_catList <- unique(parish_terr_absDT[variable != "Power generation (t CO2e)"]$variable) # this is not alphabetical - why?
# force into the same order as the colours
cse_terr_catList2 <- c(cse_terr_catList[1:15], 
                       cse_terr_catList[17:18], 
                       cse_terr_catList[20], 
                       cse_terr_catList[16],
                       cse_terr_catList[19] )

names(cse_terr_colours) <- cse_terr_catList2 # associate the names (in this order) with the colours

# set parish list ----
# Fails for parishes inside unitary authorities due to look-up table (see above)
# names MUST EXACTLY match the parish name in the CSE data files
pList <- c("Botley", "Clanfield (East Hampshire)", "Hambledon (Winchester)", 
           "Oakley (Basingstoke and Deane)", "Micheldever", "Sway", 
           "Burley (New Forest)", "Cocking", # Hampshire
           "Framlingham", "Badingham", # Suffolk
           "Longnor (Staffordshire Moorlands)") # Staffordshire

message("Parishes: ", pList)

for(p in pList){
  # set params
  parish <- p
  parish_code <- parish_namesDT[name == p, id]
  district <- parish_lut_DT[PAR20CD == parish_code, LAD20NM]
  
  pData <- parish_terr_absDT[name == p & variable != "Power generation (t CO2e)"]
  pData$Year <- 2018
  pData[, pc_4 := 0.04 * value] # 4% rule
  pData[, pc_5 := 0.05 * value] # 5% rule
  
  model <- pData
  
  for(year in seq(2019,2040)){
    newYear <- copy(pData)
    newYear$Year <- year
    multiplier <- year - 2018
    newYear[, value := ifelse(variable == "Land use, land-use change, and forestry (t CO2e)", 
                     value + (multiplier * pc_4), # add -ve (more sequestration)
                     value - (multiplier * pc_4) # 
                     )] 
    model <- rbind(model, newYear)
  }
  netYearly <- model[, .(value = sum(value)), keyby = .(Year)]
  
  myPlot <- ggplot2::ggplot(model, aes(x = Year, y = value)) +
    geom_col(position = "stack", aes(fill = variable)) +
    scale_fill_manual(name = "Source", values = cse_terr_colours) +
    geom_line(data = netYearly, aes(group = 1), size = 1.25, color = "pink") +
    guides(fill=guide_legend(ncol=2)) +
    theme(plot.title = element_text(hjust= 0)) +
    theme(legend.position = "bottom") +
    labs(title = paste0("Science Based Target 4% model for ", 
                        p, " (", district,")"),
         y = "T Co2e",
         caption = "Model: 4% of baseline value reduction per annum\2018 baseline data source: CSE Impact tool (https://impact-tool.org.uk/download, @cse_bristol)")
  
  fname <- paste0("parish_", p, "_SBT_4pc_model.png")
  ggsave(filename = here::here("docs", "plots", fname),
         plot = myPlot, width = 10)
  
}




