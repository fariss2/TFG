install.packages(c("shiny", "tidyverse", "leaflet", "ggplot2", "shinydashboard", 
                   "DT", "caret", "randomForest", "rpart", "plotly", "sf"))
install.packages("readxl")
install.packages("dplyr")
install.packages("httr")
install.packages("jsonlite")
install.packages("devtools", dependencies = TRUE)
devtools::install_github("oddworldng/INEbaseR", force = TRUE)
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
#solicitudes
library(httr)
library(jsonlite)
library(dplyr)
library(readr)
library(climaemet)

Sys.setenv(AEMET_API_KEY = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJORkwxMDA2QEFMVS5VQlUuRVMiLCJqdGkiOiI2OTZlZDkyMy1iNzQ4LTQwMWMtYjdjMy05ODBlMjFjODc1ZTAiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTc0MDU4MjQ2NCwidXNlcklkIjoiNjk2ZWQ5MjMtYjc0OC00MDFjLWI3YzMtOTgwZTIxYzg3NWUwIiwicm9sZSI6IiJ9.QcTwevd3p81An2p2iQXsfy185D5Z54l_jhGYpjSE-Q0")
api_key <- Sys.getenv("AEMET_API_KEY")

endpoint <- paste0("https://opendata.aemet.es/opendata/api/observacion/convencional/todas")

respuesta <- GET(endpoint, query = list(api_key = api_key))
json_temp<- fromJSON(content(respuesta, as = "text"))
url_datos<- json_temp$datos
download.file(url_datos,"temp.json",mode="wb")
contenido_bruto<-readLines("temp.json", warn = FALSE, encoding = "ISO-8859-1")
contenido_utf8<-iconv(contenido_bruto, from = "ISO-8859-1", to = "UTF-8")
writeLines(contenido_utf8, "temp_utf8.json")
datos_temp<-fromJSON("temp_utf8.json")%>%
  group_by(idema,ubi)%>%
  summarise(
    Tmin = ifelse(all(is.na(tamin)), NA, min(tamin, na.rm = TRUE)),
    Tmax = ifelse(all(is.na(tamax)), NA, max(tamax, na.rm = TRUE)),
    .groups = "drop"
  )%>%
  filter(!is.na(Tmin) & !is.na(Tmax))

estaciones <- aemet_stations()
estaciones_prov <- estaciones %>%
  select(idema = indicativo, provincia)
datos_temp<- datos_temp%>%
  inner_join(estaciones_prov,by="idema")%>%
  group_by(provincia)%>%
  summarise(Tmin=mean(Tmin, na.rm=TRUE),Tmax=mean(Tmax, na.rm=TRUE), .groups = "drop"  )%>%
  mutate(fecha=Sys.Date())

View(datos_temp)




codigo <- "0"  
endpoint <- paste0("https://opendata.aemet.es/opendata/api/prediccion/especifica/uvi/", codigo)

respuesta <- GET(endpoint, query = list(api_key = api_key))
json_uvi<- fromJSON(content(respuesta, as="text"))
url_uvi<- json_uvi$datos
download.file(url_uvi,"uvi.json", mode = "wb")
contenido_bruto<-readLines("uvi.json",warn = FALSE, encoding = "ISO-8859-1")
contenido_utf8<- iconv(contenido_bruto,from = "ISO-8859-1",to= "UTF-8")
writeLines(contenido_utf8,"uvi_utf8.json")

datos_uv<- fromJSON("uvi_utf8.json")$ROOT$CIUDAD
datos_uv<- as.data.frame(t(as.data.frame(do.call(rbind, datos_ciudades))))%>%
  select(uv,valor)%>%
  rename(provincia=valor)%>%
  mutate(
    uv= as.numeric(uv),
    fecha=Sys.Date(),
    provincia=as.character(provincia)
  )
View(datos_uv)
equivalencias_provincias <- c(
  "Alacant/Alicante" = "ALICANTE",
  "Albacete" = "ALBACETE",
  "Almería" = "ALMERIA",
  "Ávila" = "AVILA",
  "Badajoz" = "BADAJOZ",
  "Barcelona" = "BARCELONA",
  "Bilbao" = "BIZKAIA",
  "Burgos" = "BURGOS",
  "Cáceres" = "CACERES",
  "Cádiz" = "CADIZ",
  "Castellón de la Plana/Castelló de la Plana" = "CASTELLON",
  "Ceuta" = "CEUTA",
  "Ciudad Real" = "CIUDAD REAL",
  "Córdoba" = "CORDOBA",
  "Coruña, A" = "A CORUÑA",
  "Cuenca" = "CUENCA",
  "Donostia-San Sebastián" = "GIPUZKOA",
  "Eivissa"="BALEARES",
  "Girona" = "GIRONA",
  "Granada" = "GRANADA",
  "Guadalajara" = "GUADALAJARA",
  "Huelva" = "HUELVA",
  "Huesca" = "HUESCA",
  "Jaén" = "JAEN",
  "León" = "LEON",
  "Lleida" = "LLEIDA",
  "Logroño" = "LA RIOJA",
  "Lugo" = "LUGO",
  "Madrid" = "MADRID",
  "Málaga" = "MALAGA",
  "Melilla" = "MELILLA",
  "Murcia" = "MURCIA",
  "Ourense" = "OURENSE",
  "Oviedo" = "ASTURIAS",
  "Palencia" = "PALENCIA",
  "Palma" = "ILLES BALEARES",
  "Palmas de Gran Canaria, Las" = "LAS PALMAS",
  "Pamplona/Iruña" = "NAVARRA",
  "Pontevedra" = "PONTEVEDRA",
  "Salamanca" = "SALAMANCA",
  "Santa Cruz de Tenerife" = "SANTA CRUZ DE TENERIFE",
  "Santander" = "CANTABRIA",
  "Segovia" = "SEGOVIA",
  "Sevilla" = "SEVILLA",
  "Soria" = "SORIA",
  "Tarragona" = "TARRAGONA",
  "Teruel" = "TERUEL",
  "Toledo" = "TOLEDO",
  "Valencia" = "VALENCIA",
  "Valladolid" = "VALLADOLID",
  "Vitoria-Gasteiz" = "ARABA/ALAVA",
  "Zamora" = "ZAMORA",
  "Zaragoza" = "ZARAGOZA"
)


datos_uv <- datos_uv %>%
  mutate(provincia = recode(provincia, !!!equivalencias_provincias))
provincias_validas <- unname(equivalencias_provincias)
datos_uv <- datos_uv %>%
  filter(provincia %in% provincias_validas)
datos_dia <- full_join(datos_temp, datos_uv, by = c("provincia", "fecha"))%>%
  filter(if_all(everything(), ~ !is.na(.)))
if (!file.exists("base_climatica.rds")) {
  base_climatica <- data.frame(
    fecha = as.Date(character()),
    provincia = character(),
    Tmin = numeric(),
    Tmax = numeric(),
    uv = numeric(),
    stringsAsFactors = FALSE
  )}
  
base_climatica <- base_climatica %>%
  filter(!(paste0(provincia, fecha) %in% paste0(datos_dia$provincia, datos_dia$fecha)))
  
base_climatica <- bind_rows(base_climatica, datos_dia)
  

saveRDS(base_climatica, "base_climatica.rds")

cat("Base actualizada", format(Sys.Date(), "%Y-%m-%d"), "\n")
View(base_climatica)

'-------------------------------------------'
#tabla enfermedades
library(INEbaseR)
library(tidyr)
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

datos_melanoma_bien <- datos_melanoma %>% 
  mutate(
    Diagnostico = case_when(
      grepl("021 Melanoma", Nombre) ~ "021 Melanoma maligno de la piel",
      grepl("022 Otros tumores", Nombre) ~ "022 Otros tumores malignos",
    TRUE ~ "Otro"
    ),
    Sexo= case_when(
      grepl("Hombres", Nombre)~"Hombres",
      grepl("Mujeres", Nombre)~ "Mujeres",
      TRUE~ "Otro"
    )
  )%>%
  filter(Sexo %in% c("Hombres", "Mujeres")) %>%
  select(Provincia, Diagnostico, Sexo, Valor) %>%
  unite("Diagnostico_Sexo", Diagnostico, Sexo, sep = " - ") %>%
  pivot_wider(names_from = Diagnostico_Sexo, values_from = Valor)


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
    message("error:", paste(bloque, collapse = ", "))
    return(NULL)
  })
}

#pasan todos los bloques 
datos_mensuales <- map_df(bloques, consultar_bloque)

#filtro 
datos_temperatura <- datos_mensuales %>%
  select(indicativo, fecha, ta_min, ta_max)
#unir por indicativo y luego agrupar por provincias y seleccionar prov minima y la maxima 
library(dplyr)
library(stringr)
datos_limpios <- datos_temperatura %>% 
  rename(idema=indicativo) %>%
  filter(fecha!= "2023-13") %>%
  mutate(
    ta_min= str_remove(ta_min, "\\(.*\\)"),
    ta_min=as.numeric(str_trim(ta_min)),
    ta_max= str_remove(ta_max, "\\(.*\\)"),
    ta_max=as.numeric(str_trim(ta_max))
  )
datos_limpios_prov <-datos_limpios %>%
  inner_join(estaciones_prov_idema, by="idema") 

datos_limpios_prov_prueba <- datos_limpios_prov %>%
  filter(!is.na(ta_min) & !is.na(ta_max))
datos_limpios_prov_prueba <- datos_limpios_prov_prueba %>% 
  group_by(provincia, fecha) %>% 
  summarise(
    ta_min= min(ta_min, na.rm = TRUE),  
    ta_max= max(ta_max, na.rm = TRUE),
    .groups = "drop"
  )
print(datos_limpios_prov_prueba
      )

install.packages("writexl")
library(writexl)
write_xlsx(datos_limpios_prov_prueba, "temperaturas_extremas_provincia.xlsx")

'---------------------------------------------------------------'
#CARGA DE UVI 2023
library(readxl)
uvi_2023<- read_excel("datos_uv_2023.xlsx")
head(uvi_2023)
uvi_2023 <- uvi_2023 %>%
  rename(idema=INDICATIVO)
uvi_2023_prov<- uvi_2023 %>%
  inner_join(estaciones_prov_idema, by="idema")
uvi_2023_prov<-uvi_2023_prov%>%
  mutate(fecha= paste0(AÑO,"-",MES))%>%
  select(-AÑO,-MES)
print(uvi_2023_prov
      )
'---------------------------------------------------------'
  #modelaje
temps<- read_excel("temperaturas_extremas_provincia.xlsx")
print(temps)

#union uvi vs temps2023
resumen_ambiental <- temps %>%
  left_join(uvi_2023_prov, by = c("provincia", "fecha")) %>%
  group_by(provincia) %>%
  summarise(
    temp_max_media = mean(ta_max, na.rm = TRUE),
    uvi_max_media = mean(UVBMAX, na.rm = TRUE)
  )
View(resumen_ambiental)
  #19 provs con temps y uvi 
