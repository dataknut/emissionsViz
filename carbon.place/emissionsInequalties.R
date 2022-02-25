# attempt to replicate some of the plots in https://www.creds.ac.uk/publications/curbing-excess-high-energy-consumption-and-the-fair-energy-transition/
library(dkUtils) # https://github.com/dataknut/dkUtils
libs <- c("data.table", "ggplot2", "here")

dkUtils::loadLibraries(libs)

# https://www.carbon.place/data/
dp <- paste0(repoParams$dbPath, "CREDS/carbon.place/PBCC_LSOA_data/")

dt <- data.table::fread(paste0(dp, "PBCC_LSOA_data.csv"))

# we want emissions per capita for:
# flying - flights_percap_2018
# driving - car_percap_2018 

# shold we add + van_percap_2018 ??
summary(dt$van_percap_2018)
# we have some stonkingly huge van emissions estimates - why?
head(dt[van_percap_2018 > 40000, .(LSOA11, LSOA11NM, van_percap_2018, km_CarOrVan, car_percap_2018, pop_2018)])

# domestic gas - gas_percap_2018
# domestic elec - elec_percap_2018
# other heat - other_heat_percap_2011

# and why not add...
# nutrition_kgco2e_percap

# and we need the IMD deciles
imd <- data.table::fread(paste0(repoParams$dbPath,
                                "EW_IMD/2019/Indices_of_Multiple_Deprivation_(IMD)_2019_BA.csv")
                         )
imd[, lsoa11code := `LSOA code (2011)`]
imd[, imdDecile := `Index of Multiple Deprivation (IMD) Decile`]
setkey(imd, lsoa11code)
dt[, lsoa11code := LSOA11]

setkey(imd, lsoa11code)

# select vars to plot here
mdt <- melt(dt[, .(lsoa11code, flights_percap_2018, car_percap_2018,
                   gas_percap_2018, elec_percap_2018, other_heat_percap_2011, 
                   nutrition_kgco2e_percap, consumables_kgco2e_percap,
                   recreation_kgco2e_percap,
                   services_kgco2e_percap,
                   total_kgco2e_percap)])
setkey(mdt, lsoa11code)
mdt <- mdt[imd[, .(lsoa11code, imdDecile)]]

# checks
summary(mdt)
mdt[, .(meankgCO2e = mean(value, na.rm = TRUE),
        min = min(value, na.rm = TRUE),
        max = max(value, na.rm = TRUE)), keyby = .(variable)]

ggplot2::ggplot(mdt[variable == "car_percap_2018" |
                      variable == "gas_percap_2018" |
                      variable == "elec_percap_2018"],
                aes(x = imdDecile, y = value/1000, color = variable, group = imdDecile)) +
  geom_boxplot() +
  facet_wrap(. ~ variable, scales = "free") +
  scale_color_viridis_d() +
  labs(y = "Annual T CO2e/capita",
       x = "IMD decile 2019",
       caption = "CREDS carbon.place data (English LSOAs)")

ggplot2::ggsave(filename = here::here("carbon.place", "plots", "measuredPerCapitaEmissionsByIMDdecile_LSOA.png"),
                width = 10)

ggplot2::ggplot(mdt[variable != "car_percap_2018" &
                      variable != "gas_percap_2018" &
                      variable != "elec_percap_2018"],
                aes(x = imdDecile, y = value/1000, color = variable, group = imdDecile)) +
  geom_boxplot() +
  facet_wrap(. ~ variable, scales = "free") +
  scale_color_viridis_d() +
  labs(y = "Annual T CO2e/capita",
       x = "IMD decile 2019",
       caption = "CREDS carbon.place data (English LSOAs)")

ggplot2::ggsave(filename = here::here("carbon.place", "plots", "modelledPerCapitaEmissionsByIMDdecile_LSOA.png"),
                width = 10)

ggplot2::ggplot(mdt[variable == "total_kgco2e_percap"], 
                aes(x = imdDecile, y = value/1000, color = variable, group = imdDecile)) +
  geom_boxplot() +
  facet_wrap(. ~ variable) +
  scale_color_viridis_d() +
  labs(y = "Annual T CO2e/capita",
       x = "IMD decile 2019",
       caption = "CREDS carbon.place data (English LSOAs)")

ggplot2::ggsave(filename = here::here("carbon.place", "plots", "total_kgco2e_percapByIMDdecile_LSOA.png"),
                width = 10)


library(ineq)
ineq::Gini(dt$gas_percap_2018)
plot(ineq::Lc(dt$gas_percap_2018))
ineq::Gini(dt$elec_percap_2018)
plot(ineq::Lc(dt$elec_percap_2018))
ineq::Gini(dt$total_kgco2e_percap)
plot(ineq::Lc(dt$total_kgco2e_percap))
ineq::Gini(dt$flights_percap_2018)
plot(ineq::Lc(dt$flights_percap_2018))
ineq::Gini(dt$other_heat_percap_2011)
plot(ineq::Lc(dt$other_heat_percap_2011))

mdt[, .(gini = ineq::Gini(value)), keyby = .(variable)]

ggplot2::ggplot(mdt[variable == "other_heat_percap_2011", .(variable, value, imdDecile)], 
                aes(x = imdDecile, y = value/1000, color = variable, group = imdDecile)) +
  geom_boxplot() +
  facet_wrap(. ~ variable) +
  scale_color_viridis_d() +
  labs(y = "Annual T CO2e/capita",
       x = "IMD decile 2019",
       caption = "CREDS carbon.place data (English LSOAs)")
