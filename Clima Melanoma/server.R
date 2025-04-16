library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(sf)
library(mapSpain)
library(tidyverse)
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
    mutate(fecha=Sys.Date())
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
      fecha = Sys.Date(),
      provincia = as.character(provincia)
    ) %>%
    select(provincia, uv, fecha)
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








shinyServer(function(input, output) { 
  
  Sys.setenv(AEMET_API_KEY = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJORkwxMDA2QEFMVS5VQlUuRVMiLCJqdGkiOiI2OTZlZDkyMy1iNzQ4LTQwMWMtYjdjMy05ODBlMjFjODc1ZTAiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTc0MDU4MjQ2NCwidXNlcklkIjoiNjk2ZWQ5MjMtYjc0OC00MDFjLWI3YzMtOTgwZTIxYzg3NWUwIiwicm9sZSI6IiJ9.QcTwevd3p81An2p2iQXsfy185D5Z54l_jhGYpjSE-Q0")
  api_key <- Sys.getenv("AEMET_API_KEY")
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
      fecha = Sys.Date(),
      provincia = as.character(provincia)
    ) %>%
    select(provincia, uv, fecha)
 
  

  equivalencias_mapa <- c(
    "Alacant/Alicante" = "Alicante/Alacant",
    "Coruña, A" = "Coruña, A",
    "Albacete" = "Albacete",
    "Almería" = "Almería",
    "Ávila" = "Ávila",
    "Badajoz" = "Badajoz",
    "Barcelona" = "Barcelona",
    "Bilbao" = "Bizkaia",
    "Burgos" = "Burgos",
    "Cáceres" = "Cáceres",
    "Cádiz" = "Cádiz",
    "Castellón de la Plana/Castelló de la Plana" = "Castellón/Castelló",
    "Ceuta" = "Ceuta",
    "Ciudad Real" = "Ciudad Real",
    "Córdoba" = "Córdoba",
    "Cuenca" = "Cuenca",
    "Donostia-San Sebastián" = "Gipuzkoa",
    "Girona" = "Girona",
    "Granada" = "Granada",
    "Guadalajara" = "Guadalajara",
    "Huelva" = "Huelva",
    "Huesca" = "Huesca",
    "Jaén" = "Jaén",
    "León" = "León",
    "Lleida" = "Lleida",
    "Logroño" = "Rioja, La",
    "Lugo" = "Lugo",
    "Madrid" = "Madrid",
    "Málaga" = "Málaga",
    "Melilla" = "Melilla",
    "Murcia" = "Murcia",
    "Ourense" = "Ourense",
    "Oviedo" = "Asturias",
    "Palencia" = "Palencia",
    "Palma" = "Balears, Illes",
    "Palmas de Gran Canaria, Las" = "Palmas, Las",
    "Pamplona/Iruña" = "Navarra",
    "Pontevedra" = "Pontevedra",
    "Salamanca" = "Salamanca",
    "Santa Cruz de Tenerife" = "Santa Cruz de Tenerife",
    "Santander" = "Cantabria",
    "Segovia" = "Segovia",
    "Sevilla" = "Sevilla",
    "Soria" = "Soria",
    "Tarragona" = "Tarragona",
    "Teruel" = "Teruel",
    "Toledo" = "Toledo",
    "Valencia" = "Valencia/València",
    "Valladolid" = "Valladolid",
    "Vitoria-Gasteiz" = "Araba/Álava",
    "Zamora" = "Zamora",
    "Zaragoza" = "Zaragoza"
  )
  
  provincias_validas <- names(equivalencias_mapa)
  
  datos_uv_mapa <- datos_uv %>%
    filter(provincia %in% provincias_validas) %>%
    mutate(prov_map = recode(provincia, !!!equivalencias_mapa))%>%
    select(prov_map,uv)
  datos_uv_mapa<- datos_uv_mapa%>%
    rename(provincia=prov_map)
  output$mapa_uv <- renderPlot({
    
    Provs <- esp_get_prov() %>%
      dplyr::rename(provincia = ine.prov.name)
    
    Can <- esp_get_can_box()
    
    provincias_uv <- dplyr::inner_join(Provs, datos_uv_mapa, by = "provincia") %>%
      sf::st_as_sf()
    
    ggplot(provincias_uv) +
      geom_sf(aes(fill = uv), color = "grey50", linewidth = 0.3) +
      geom_sf(data = Can, color = "grey50") +
      geom_sf_label(aes(label = uv), fill = "white", alpha = 0.7, size = 3) +
      scale_fill_gradientn(
        colors = hcl.colors(10, "YlOrRd", rev = TRUE),
        name = "Índice UV",
        n.breaks = 7
      ) +
      labs(title = paste("Índice UV por provincia -", Sys.Date())) +
      theme_void() +
      theme(
        legend.position = c(0.1, 0.6),
        plot.title = element_text(hjust = 0.5, face = "bold")
      )
  })
  
  
  
    
    
  })

