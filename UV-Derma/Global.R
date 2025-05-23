library(dplyr)
library(climaemet)   
library(httr)
library(jsonlite)

# ----------------------------------------------------------------------
actualizar_datos_climaticos<- function(){
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
    mutate(fecha=as.Date(Sys.Date()))
  #-----
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
  datos_uv <- datos_uv %>%
    rename(provincia = valor) %>%
    mutate(
      uv = as.numeric(uv),
      fecha = as.Date(Sys.Date()),
      provincia = as.character(provincia)
    ) %>%
    select(provincia, uv, fecha)
  #------
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
    base_climatica <- datos_dia
  } else {
    base_climatica <- readRDS("base_climatica.rds")
    base_climatica <- base_climatica %>%
      filter(!(paste0(provincia, fecha) %in% paste0(datos_dia$provincia, datos_dia$fecha))) %>%
      bind_rows(datos_dia)
  }
  
  saveRDS(base_climatica, "base_climatica.rds")
  return(base_climatica)
  
}
# ----------------------------------------------------------------------


base_climatica <- actualizar_datos_climaticos()
equivalencias_base <- c(
  "ALICANTE" = "Alicante/Alacant",
  "A CORUÑA" = "Coruña, A",
  "ALBACETE" = "Albacete",
  "ALMERIA" = "Almería",
  "AVILA" = "Ávila",
  "BADAJOZ" = "Badajoz",
  "BARCELONA" = "Barcelona",
  "BIZKAIA" = "Bizkaia",
  "BURGOS" = "Burgos",
  "CACERES" = "Cáceres",
  "CADIZ" = "Cádiz",
  "CASTELLON" = "Castellón/Castelló",
  "CEUTA" = "Ceuta",
  "CIUDAD REAL" = "Ciudad Real",
  "CORDOBA" = "Córdoba",
  "CUENCA" = "Cuenca",
  "GIPUZKOA" = "Gipuzkoa",
  "GIRONA" = "Girona",
  "GRANADA" = "Granada",
  "GUADALAJARA" = "Guadalajara",
  "HUELVA" = "Huelva",
  "HUESCA" = "Huesca",
  "JAEN" = "Jaén",
  "LEON" = "León",
  "LLEIDA" = "Lleida",
  "LA RIOJA" = "Rioja, La",
  "LUGO" = "Lugo",
  "MADRID" = "Madrid",
  "MALAGA" = "Málaga",
  "MELILLA" = "Melilla",
  "MURCIA" = "Murcia",
  "OURENSE" = "Ourense",
  "ASTURIAS" = "Asturias",
  "PALENCIA" = "Palencia",
  "BALEARES" = "Balears, Illes",
  "LAS PALMAS" = "Palmas, Las",
  "NAVARRA" = "Navarra",
  "PONTEVEDRA" = "Pontevedra",
  "SALAMANCA" = "Salamanca",
  "SANTA CRUZ DE TENERIFE" = "Santa Cruz de Tenerife",
  "CANTABRIA" = "Cantabria",
  "SEGOVIA" = "Segovia",
  "SEVILLA" = "Sevilla",
  "SORIA" = "Soria",
  "TARRAGONA" = "Tarragona",
  "TERUEL" = "Teruel",
  "TOLEDO" = "Toledo",
  "VALENCIA" = "Valencia/València",
  "VALLADOLID" = "Valladolid",
  "ARABA/ALAVA" = "Araba/Álava",
  "ZAMORA" = "Zamora",
  "ZARAGOZA" = "Zaragoza"
)
datos_tiempo<- base_climatica%>%
  mutate(provincia = recode(provincia, !!!equivalencias_base))

datos_tiempo$fecha<-as.Date(as.character(datos_tiempo$fecha))
#print(paste("Última fecha en base_climatica:", max(datos_tiempo$fecha)))
#view(datos_tiempo)

datos_tiempo <- base_climatica %>%
  mutate(provincia = recode(provincia, !!!equivalencias_base),
         fecha     = as.Date(as.character(fecha))) %>%
  arrange(fecha)
