install.packages(c("shiny", "tidyverse", "leaflet", "ggplot2", "shinydashboard", 
                   "DT", "caret", "randomForest", "rpart", "plotly", "sf"))

install.packages("dplyr")
install.packages("httr")
install.packages("jsonlite")
install.packages("devtools", dependencies = TRUE)
devtools::install_github("oddworldng/INEbaseR", force = TRUE)
1

library(devtools)

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
  print("hay datos")
} else {
  stop(paste("eror:", http_status(respuesta)$message))
}

#  tipo de respuesta
tipo_respuesta <- http_type(respuesta)

if (tipo_respuesta == "application/json") {
  json_contenido <- fromJSON(content(respuesta, as = "text"))
  
  if (!is.null(json_contenido$datos)) {
    data_url <- json_contenido$datos
    print(paste(" datos:", data_url))
    
   
    archivo_destino <- "UVR.json"
    
    tryCatch({
      download.file(url = data_url, destfile = archivo_destino, mode = "wb")
      print(paste("Datos guardados en:", archivo_destino))
    }, error = function(e) {
      print(paste("error al descargar datos:", e$message))
    })
    
  } else {
    stop("No hay clave 'datos' en la respuesta.")
  }
  
} else {
  stop(paste("no es JSON. ", tipo_respuesta))
}
'----------------'

#carga de datos uvr.json

#conversion 
archivo_original <- "UVR.json"
archivo_utf8 <- "UVR_utf8.json"

# archivo en ISO-8859-1, original
contenido_bruto <- readLines(archivo_original, warn = FALSE, encoding = "ISO-8859-1")

# Conversion
contenido_corregido <- iconv(contenido_bruto, from = "ISO-8859-1", to = "UTF-8")
writeLines(contenido_corregido, archivo_utf8)

datos_uv <- fromJSON(archivo_utf8)

# lista del filtro
datos_ciudades <- datos_uv$ROOT$CIUDAD

# conversion df 
datos_df <- as.data.frame(do.call(rbind, datos_ciudades))
head(datos_df)

# traspuesto y filtrado
datos_df <- as.data.frame(t(datos_df))
colnames(datos_df)
datos_df <- datos_df[, c("uv", "valor")]
#hasta aqui limpio y funciona 
'-------------------------------------------'
#tabla enfermedades
library(stringr)
library(purrr)
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
# hasta aqui bien 

'----------------------------------------------------'
# temperaturas 

Sys.setenv(AEMET_API_KEY = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJORkwxMDA2QEFMVS5VQlUuRVMiLCJqdGkiOiI2OTZlZDkyMy1iNzQ4LTQwMWMtYjdjMy05ODBlMjFjODc1ZTAiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTc0MDU4MjQ2NCwidXNlcklkIjoiNjk2ZWQ5MjMtYjc0OC00MDFjLWI3YzMtOTgwZTIxYzg3NWUwIiwicm9sZSI6IiJ9.QcTwevd3p81An2p2iQXsfy185D5Z54l_jhGYpjSE-Q0")
api_key <- Sys.getenv("AEMET_API_KEY")

endpoint <- paste0("https://opendata.aemet.es/opendata/api/observacion/convencional/todas")

respuesta <- GET(endpoint, query = list(api_key = api_key))

if (http_status(respuesta)$category == "Success") {
  print("hay datos")
} else {
  stop(paste("eror:", http_status(respuesta)$message))
}

#  tipo de respuesta
tipo_respuesta <- http_type(respuesta)

if (tipo_respuesta == "application/json") {
  json_contenido <- fromJSON(content(respuesta, as = "text"))
  
  if (!is.null(json_contenido$datos)) {
    data_url <- json_contenido$datos
    print(paste(" datos:", data_url))
    
    
    archivo_destino <- "temp.json"
    
    tryCatch({
      download.file(url = data_url, destfile = archivo_destino, mode = "wb")
      print(paste("Datos guardados en:", archivo_destino))
    }, error = function(e) {
      print(paste("error al descargar datos:", e$message))
    })
    
  } else {
    stop("No hay clave 'datos' en la respuesta.")
  }
  
} else {
  stop(paste("no es JSON. ", tipo_respuesta))
}
'-----------------------'
install.packages("readr")
library(readr)
#tipo de encoding 
archivo_original <- "temp.json"

encoding_detectado <- guess_encoding(archivo_original)
print(encoding_detectado)

#conversion datos temperatura
archivo_temp_original <- "temp.json"
archivo_temp_utf8 <- "temp_utf8.json"

# archivo en ISO-8859-1 el original
contenido_bruto <- readLines(archivo_temp_original, warn = FALSE, encoding = "ISO-8859-1")

# conversion
contenido_corregido <- iconv(contenido_bruto, from = "ISO-8859-1", to = "UTF-8")
writeLines(contenido_corregido, archivo_temp_utf8)
library(jsonlite)  

datos_temp <- fromJSON(archivo_temp_utf8)
colnames(datos_temp)

---------------------# lista del filtro
library(dplyr)


datos_resumidos <- datos_temp %>%
  group_by(idema,ubi) %>%
  summarise(
    Tmin = ifelse(all(is.na(tamin)), NA, min(tamin, na.rm = TRUE)),
    Tmax = ifelse(all(is.na(tamax)), NA, max(tamax, na.rm = TRUE))
  ) %>%
  filter(!is.na(Tmin) & !is.na(Tmax)) 
print(datos_resumidos)

'----------------------'
#datos 2023
library(climaemet)
library(dplyr)
library(purrr)
aemet_api_key("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJORkwxMDA2QEFMVS5VQlUuRVMiLCJqdGkiOiI2OTZlZDkyMy1iNzQ4LTQwMWMtYjdjMy05ODBlMjFjODc1ZTAiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTc0MDU4MjQ2NCwidXNlcklkIjoiNjk2ZWQ5MjMtYjc0OC00MDFjLWI3YzMtOTgwZTIxYzg3NWUwIiwicm9sZSI6IiJ9.QcTwevd3p81An2p2iQXsfy185D5Z54l_jhGYpjSE-Q0",install=TRUE, overwrite = TRUE)
#IDEMA VS PROVINCIA
estaciones <- aemet_stations()
estaciones <- estaciones %>%
  select(idema = indicativo, provincia)

#prueba ver cols
datos_prueba <- aemet_monthly_clim(station = "0076", year = 2023)
print(datos_prueba)
colnames(datos_prueba)





estaciones <- aemet_stations()
ids <- estaciones$indicativo#equivale idema renombrarlo mas tarde

# por bloques porque son 947
bloques <- split(ids, ceiling(seq_along(ids) / 20))

#consultar un bloque
consultar_bloque <- function(bloque) {
  tryCatch({
    Sys.sleep(1)  
    aemet_monthly_clim(station = bloque, year = 2023)
  }, error = function(e) {
    message("error con bloque:", paste(bloque, collapse = ", "))
    return(NULL)
  })
}

#pasan todos los bloques 
datos_mensuales <- map_df(bloques, consultar_bloque)

#filtro 
datos_temperatura <- datos_mensuales %>%
  select(indicativo, fecha, ta_min, ta_max)
#unir por indicativo y luego agrupar por provincias y seleccionar la minima y la maxima 
help("function")
