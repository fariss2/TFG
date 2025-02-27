install.packages(c("shiny", "tidyverse", "leaflet", "ggplot2", "shinydashboard", 
                   "DT", "caret", "randomForest", "rpart", "plotly", "sf"))

install.packages("dplyr")
install.packages("httr")
install.packages("jsonlite")
install.packages("devtools")
devtools::install_github("oddworldng/INEbaseR")
install.packages("INEbaseR")
library(INEbaseR)
library(httr)
library(jsonlite)
library(DT)
library(dplyr)
library(climaemet)
library(ggplot2)
library(tidyr)
library(stringr)
library(purrr)
'-------------------------------------'
aemet_api_key("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJORkwxMDA2QEFMVS5VQlUuRVMiLCJqdGkiOiI2OTZlZDkyMy1iNzQ4LTQwMWMtYjdjMy05ODBlMjFjODc1ZTAiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTc0MDU4MjQ2NCwidXNlcklkIjoiNjk2ZWQ5MjMtYjc0OC00MDFjLWI3YzMtOTgwZTIxYzg3NWUwIiwicm9sZSI6IiJ9.QcTwevd3p81An2p2iQXsfy185D5Z54l_jhGYpjSE-Q0",install=TRUE, overwrite = TRUE)
estaciones<- aemet_stations()
datatable(estaciones)
colnames(estaciones)
estaciones_filtradas <- estaciones %>%
  select(provincia, altitud)
promedio_altitud_provincia <- estaciones_filtradas %>%
  group_by(provincia) %>%         
  summarise(promedio_altitud = mean(altitud, na.rm = TRUE)) 
datatable(promedio_altitud_provincia)
'------------------------------------------'


Sys.setenv(AEMET_API_KEY = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJORkwxMDA2QEFMVS5VQlUuRVMiLCJqdGkiOiI2OTZlZDkyMy1iNzQ4LTQwMWMtYjdjMy05ODBlMjFjODc1ZTAiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTc0MDU4MjQ2NCwidXNlcklkIjoiNjk2ZWQ5MjMtYjc0OC00MDFjLWI3YzMtOTgwZTIxYzg3NWUwIiwicm9sZSI6IiJ9.QcTwevd3p81An2p2iQXsfy185D5Z54l_jhGYpjSE-Q0")
api_key <- Sys.getenv("AEMET_API_KEY")

codigo <- "0"  
endpoint <- paste0("https://opendata.aemet.es/opendata/api/prediccion/especifica/uvi/", codigo)

respuesta <- GET(endpoint, query = list(api_key = api_key))

if (http_status(respuesta)$category == "Success") {
  print("Datos obtenidos correctamente")
} else {
  stop(paste("eror en la solicitud:", http_status(respuesta)$message))
}

# Verificar el tipo de respuesta
tipo_respuesta <- http_type(respuesta)

if (tipo_respuesta == "application/json") {
  json_contenido <- fromJSON(content(respuesta, as = "text"))
  
  if (!is.null(json_contenido$datos)) {
    data_url <- json_contenido$datos
    print(paste("URL de datos:", data_url))
    
   
    archivo_destino <- "UVR.json"
    
    tryCatch({
      download.file(url = data_url, destfile = archivo_destino, mode = "wb")
      print(paste("Datos guardados en:", archivo_destino))
    }, error = function(e) {
      print(paste("error al descargar datos:", e$message))
    })
    
  } else {
    stop("No se encontró la clave 'datos' en la respuesta de la API.")
  }
  
} else {
  stop(paste("no es JSON. Tipo recibido:", tipo_respuesta))
}
'-------------------------------------------'

datos_67900 <- get_tables(67900, resource = "data")


datos_melanoma <- datos_67900 %>%
  filter(grepl("021 Melanoma maligno de la piel", Nombre) | 
           grepl("022 Otros tumores malignos de la piel", Nombre))

datos_melanoma <- datos_melanoma %>%
  mutate(Provincia = str_extract(Nombre, "[^,]+$")) %>%  
  select(Provincia, everything())  


datos_melanoma <- datos_melanoma %>%
  mutate(Valor = map(Data, ~ .x$Valor)) %>% 
  select(-Data) 

head(datos_melanoma)

