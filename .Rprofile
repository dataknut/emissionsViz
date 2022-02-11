# set local datapaths
# parameters widely re-used across the LATENT repo

repoParams <- list() # params holder as a list
listFiles <- TRUE

# Location ----
# attempt to guess the platform & user
repoParams$info <- Sys.info()
repoParams$sysname <- repoParams$info[[1]]
repoParams$nodename <- repoParams$info[[4]]
repoParams$login <- repoParams$info[[6]]
repoParams$user <- repoParams$info[[7]]

# Default data paths ----
repoParams$jPath <- "can't find J: - fix .Rprofile!"
repoParams$dbPath <- "can't find Dropbox: - fix .Rprofile!"
repoParams$spPath <- "can't find Teams/Sharepoint folders: - fix .Rprofile!"

if (repoParams$sysname == "Darwin") {
  # we're on a Mac (local) so we can set the data path to the Resource drive (if mounted)
  repoParams$jPath <- path.expand("/Volumes/Resource/CivilEnvResearch/Public/SERG/data/")
  if(repoParams$user == "ben") {
    repoParams$dbPath <- path.expand("~/Dropbox/data/") # dropbox
    repoParams$spPath <- path.expand("~/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofSouthampton") # sharepoint
  }
}

if (repoParams$sysname == "Windows") {
  # we're on Windows (local) so we can set the data path to J: drive (if mounted)
  repoParams$jPath <- "J:/CivilEnvResearch/Public/SERG/data/"
}
if (repoParams$nodename == "srv02405") {
  # we're on the UoS RStudio server so we set the data path to:
  repoParams$jPath <- path.expand("/mnt/SERG_data/")
}
if (grepl("prd-cls2k4", repoParams$nodename)) {
  # we're on the UoS SVE so we can set the output path to J: (as mounted)
  repoParams$jPath <- "J:/CivilEnvResearch/Public/SERG/data/"
}

# Feedback ----
message("You're ", repoParams$user, " using " , repoParams$sysname, " on ", repoParams$nodename)
message("Default jPath has been set to: \n", repoParams$jPath)
message("Default dbPath has been set to: \n", repoParams$dbPath)
message("Default spPath has been set to: \n", repoParams$spPath)

if (listFiles) { # optional
  message("and these are the files/folders in the paths:")
  message("J:")
  print(try(list.files(repoParams$jPath))) # in case it breaks
  message("Dropbox:")
  print(try(list.files(repoParams$dbPath))) # in case it breaks
  message("Teams/Sharepoint:")
  print(try(list.files(repoParams$spPath))) # in case it breaks
}
message("Check .Rprofile if that's not what you expected...")
