# this script creates all of the data that lives in the puntr-data repo

# import packages ####
library(tidyverse)

library(puntr)
library(nflfastR)

library(DBI)
library(RSQLite)
library(gsisdecoder)

# import all pbp data
update_db(force_rebuild = FALSE)
connection <- dbConnect(SQLite(), "./pbp_db") # not pushing the pbp_db to github, sorry! it's huge
pbp <- tbl(connection, "nflfastR_pbp")

punts <- pbp %>%
  filter(play_type=="punt") %>%
  collect() %>%
  trust_the_process(
    seasontype = NULL, # include regular season and postseason
    ) %>%
  calculate_all()

dbDisconnect(connection)

write_year <- function(data, season) {
  punts_this_year <- punts %>% filter(season==season)

  write_rds(punts_this_year, glue('~/github/puntr-data/data/punts_{season}.rds'))

  write_csv(punts_this_year, glue('~/github/puntr-data/data/punts_{season}.csv.gz'))
}

for (season in 1999:2022) {
  write_year(punts, season = season)
}
