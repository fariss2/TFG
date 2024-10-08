install.packages("shiny")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("httr")
install.packages("jsonlite")
install.packages("DT")
install.packages("dplyr")
library(httr)
library(jsonlite)
library(DT)
library(dplyr)
library(climaemet)
library(ggplot2)
"-------------------------------------------------------------------------------"

#Altitudes
aemet_api_key("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZmwxMDA2QGFsdS51YnUuZXMiLCJqdGkiOiI0NGMyM2NhOC1iNjBkLTRjNDItOWFmMi0zNDc2YWJiOTVkOGMiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTcyNzY4MjA4OSwidXNlcklkIjoiNDRjMjNjYTgtYjYwZC00YzQyLTlhZjItMzQ3NmFiYjk1ZDhjIiwicm9sZSI6IiJ9.YLs-0uoO-9w6La3niNanXZw_vtcsqVqxbzZ1_UENDFQ
",install=TRUE, overwrite = TRUE)
estaciones<- aemet_stations()
datatable(estaciones)
colnames(estaciones)
estaciones_filtradas <- estaciones %>%
  select(provincia, altitud)
promedio_altitud_provincia <- estaciones_filtradas %>%
  group_by(provincia) %>%         
  summarise(promedio_altitud = mean(altitud, na.rm = TRUE)) 
datatable(promedio_altitud_provincia)


"-------------------------------------------------------------------------------"

api_key <- "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZmwxMDA2QGFsdS51YnUuZXMiLCJqdGkiOiI0NGMyM2NhOC1iNjBkLTRjNDItOWFmMi0zNDc2YWJiOTVkOGMiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTcyNzY4MjA4OSwidXNlcklkIjoiNDRjMjNjYTgtYjYwZC00YzQyLTlhZjItMzQ3NmFiYjk1ZDhjIiwicm9sZSI6IiJ9.YLs-0uoO-9w6La3niNanXZw_vtcsqVqxbzZ1_UENDFQ"

codigo <- "0"  # dia actual
endpoint <- paste0("https://opendata.aemet.es/opendata/api/prediccion/especifica/uvi/", codigo)

respuesta <- GET(endpoint, query = list(api_key = api_key))

if (http_status(respuesta)$category == "Success") {
  print("exito")
} else {
  print(paste("error:", http_status(respuesta)$message))
}
tipo_respuesta <- http_type(respuesta)

#leer respuesta y acceso a indices

if (tipo_respuesta == "application/json") {
  json_contenido <- fromJSON(content(respuesta, as = "text"))
  print(json_contenido)
  data_url <- json_contenido$datos
  print(paste("Data URL:", data_url))
} else {
  print(paste("el contenido no es JSON:", tipo_respuesta))
}
#2 solicitud, indices
uv_data_respuesta <- GET(data_url)
tipo_uv_data <- http_type(uv_data_respuesta)
print(paste("tipo de los datos:", tipo_uv_data))


#hasta aqui funciona
"----------------------------------------------------------------------------"
