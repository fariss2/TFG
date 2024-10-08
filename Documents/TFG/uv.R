install.packages("rvest")
library(httr)
library(jsonlite)
library(dplyr)
library(climaemet)
library(ggplot2)
library(rvest)
library(dplyr)
api_key <- "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZmwxMDA2QGFsdS51YnUuZXMiLCJqdGkiOiI0NGMyM2NhOC1iNjBkLTRjNDItOWFmMi0zNDc2YWJiOTVkOGMiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTcyNzY4MjA4OSwidXNlcklkIjoiNDRjMjNjYTgtYjYwZC00YzQyLTlhZjItMzQ3NmFiYjk1ZDhjIiwicm9sZSI6IiJ9.YLs"

"------------------------------------------------------------"
# WEB SCRAPING

url_uv <- "https://www.aemet.es/es/eltiempo/prediccion/radiacionuv?w=0&datos=det"

#contenido HTML de la página
pagina_uv <- read_html(url_uv)

tablas_uv <- pagina_uv %>% html_table(fill = TRUE)

# Inspeccionar una de las tablas (normalmente la primera contiene los datos de predicción UV)
predicciones_uv <- tablas_uv[[1]]  # la primera tabla tiene los datos que buscamos
print(predicciones_uv)
"--------------------------------------------"