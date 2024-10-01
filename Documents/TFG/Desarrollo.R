install.packages("shiny")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("httr")
install.packages("jsonlite")

library(climaemet)
library(ggplot2)
aemet_api_key("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZmwxMDA2QGFsdS51YnUuZXMiLCJqdGkiOiI0NGMyM2NhOC1iNjBkLTRjNDItOWFmMi0zNDc2YWJiOTVkOGMiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTcyNzY4MjA4OSwidXNlcklkIjoiNDRjMjNjYTgtYjYwZC00YzQyLTlhZjItMzQ3NmFiYjk1ZDhjIiwicm9sZSI6IiJ9.YLs-0uoO-9w6La3niNanXZw_vtcsqVqxbzZ1_UENDFQ
",install=TRUE, overwrite = TRUE)
