library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(sf)
library(mapSpain)
library(tidyverse)
library(climaemet)
library(DT)
library(readxl)
library(writexl)
library(INEbaseR)
library(stringr)
library(purrr)
library(leaflet)
library(htmltools)

#OBTENCION ALTITUDES
#aemet_api_key("eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJORkwxMDA2QEFMVS5VQlUuRVMiLCJqdGkiOiI2OTZlZDkyMy1iNzQ4LTQwMWMtYjdjMy05ODBlMjFjODc1ZTAiLCJpc3MiOiJBRU1FVCIsImlhdCI6MTc0MDU4MjQ2NCwidXNlcklkIjoiNjk2ZWQ5MjMtYjc0OC00MDFjLWI3YzMtOTgwZTIxYzg3NWUwIiwicm9sZSI6IiJ9.QcTwevd3p81An2p2iQXsfy185D5Z54l_jhGYpjSE-Q0",install=TRUE, overwrite = TRUE)
#estaciones<- aemet_stations()
#datatable(estaciones)
#colnames(estaciones)
#estaciones_filtradas <- estaciones %>%
  #select(provincia, altitud)
#promedio_altitud_provincia <- estaciones_filtradas %>%
 # group_by(provincia) %>%         
 # summarise(promedio_altitud = mean(altitud, na.rm = TRUE)) 
#datatable(promedio_altitud_provincia)
#write_xlsx(promedio_altitud_provincia, "promedio_altitud_provincia.xlsx")


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
'  datos_temp <- datos_brutos %>%
    select(idema, ubi, tamin, tamax) %>%  
    group_by(idema, ubi) %>%
    summarise(
      Tmin = ifelse(all(is.na(tamin)), NA, min(tamin, na.rm = TRUE)),
      Tmax = ifelse(all(is.na(tamax)), NA, max(tamax, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    filter(!is.na(Tmin) & !is.na(Tmax))
  '
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

obtener_datos_melanoma <- function() {
  datos_67900 <- get_tables(67900, resource = "data")
  
  datos_melanoma <- datos_67900 %>%
    filter(grepl("021 Melanoma maligno de la piel", Nombre)) %>%
    filter(grepl("Ambos sexos", Nombre) & !grepl("Total", Nombre)) %>%
    mutate(
      provincia = str_extract(Nombre, "[^,]+$"),
      melanoma = map_dbl(Data, ~ .x$Valor[1])
    ) %>%
    select(provincia, melanoma)
  
  return(datos_melanoma)
}














shinyServer(function(input, output,session) { 
  botones_volver <- c(
    "volver_inicio_desde_uv",
    "volver_inicio_desde_melanoma",
    "volver_inicio_desde_temp",
    "volver_inicio_desde_altitud",
    "volver_inicio_desde_datos",
    "volver_inicio_desde_acerca_de",
    "volver_inicio_desde_info_melanoma",
    "volver_inicio_desde_intervalos",
    "volver_inicio_desde_dano_uv",
    "volver_inicio_desde_recomendador"
  )
  
  lapply(botones_volver, function(id_boton) {
    observeEvent(input[[id_boton]], {
      updateTabsetPanel(session, inputId = "navegador", selected = "Inicio")
    })
  })
  
  
  observeEvent(input$ir_info, {
    updateTabsetPanel(session, inputId = "navegador", selected = "Contenido informativo")
  })
  observeEvent(input$ir_alerta, {
    updateTabsetPanel(session, inputId = "navegador", selected = "Mapa de Variables")
  })
  observeEvent(input$ir_riesgo, {
    updateTabsetPanel(session, inputId = "navegador", selected = "Riesgo Acumulado")
  })
  observeEvent(input$ir_recomendador, {
    updateTabsetPanel(session, inputId = "navegador", selected = "Recomendador")
  })
  observeEvent(input$ir_datos, {
    updateTabsetPanel(session, inputId = "navegador", selected = "Base Climatica ")
  })


#--------  
  
  datos_melanoma <- obtener_datos_melanoma()
  poblacion<-read_xlsx("densidad.xlsx")
  equivalencias_densidad <- c(
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
    "ILLES BALEARS" = "Balears, Illes",
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
  
  
  poblacion <- poblacion %>%
    mutate(provincia = recode(provincia, !!!equivalencias_densidad))
  
  datos_melanoma <- datos_melanoma %>%
    mutate(provincia =str_trim(provincia))%>%
    filter(provincia!="Extranjero")%>%
    mutate(provincia = str_replace(provincia, "Valencia/Val\u008ancia", "Valencia/València"))
  datos_melanoma <- datos_melanoma %>%
    mutate(provincia = recode(provincia,
                              "Illes" = "Balears, Illes",
                              "Las" = "Palmas, Las",
                              "Avila" = "Ávila",
                              "A" = "Coruña, A",
                              "Araba/Alava" = "Araba/Álava",
                              "La" = "Rioja, La"
    ))
  
  tasa_mortalidad<-inner_join(datos_melanoma,poblacion,by="provincia")
  tasa_mortalidad<-tasa_mortalidad%>%
    mutate(tasa=round((melanoma / poblacion) * 100000, 2))
  
  
  
  output$mapa_melanoma <- renderLeaflet({
    Provs <- esp_get_prov() %>% rename(provincia = ine.prov.name)
    
    provincias_leaflet <- inner_join(Provs, tasa_mortalidad, by = "provincia") %>%
      sf::st_as_sf()
    
    pal <- colorNumeric("PuBu", domain = provincias_leaflet$tasa)
    
    leaflet(provincias_leaflet) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(
        fillColor = ~pal(tasa),
        color = "white",
        weight = 1,
        fillOpacity = 0.8,
        label = ~lapply(
          paste0(
            "<strong>", provincia, "</strong><br/>",
            "Muertes: ", melanoma, "<br/>",
            "Tasa: ", tasa, " por 100.000 Habitantes"
          ), 
          HTML
        ),
        highlightOptions = highlightOptions(
          weight = 2,
          color = "#666",
          fillOpacity = 0.7,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        pal = pal,
        values = ~tasa,
        title = "Tasa de mortalidad por 100.000 habitantes ",
        position = "bottomright"
      )
  })
  #---------------------
  
  base_climatica<-actualizar_datos_climaticos()
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
  output$grafico_temporal <- renderPlot({
    req(input$prov_select, input$var_select)
    
    datos_filtrados <- datos_tiempo %>%
      filter(provincia %in% input$prov_select) %>%
      select(fecha, provincia, variable = all_of(input$var_select))
    
    ggplot(datos_filtrados, aes(x = fecha, y = variable, color = provincia)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      labs(
        title = paste("Evolución de", input$var_select, "por provincia"),
        x = "Fecha",
        y = input$var_select,
        color = "provincia"
      ) +
      theme_minimal(base_size = 20)
  })
  
  output$descargar_excel <- downloadHandler(
    filename = function() {
      paste0("datos_tirmpo_hasta", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      write_xlsx(datos_tiempo, path = file)
    }
  )
  
  output$descargar_csv <- downloadHandler(
    filename = function() {
      paste0("datos_tiempo_hasta", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(datos_tiempo, file, row.names = FALSE)
    }
  )
  
  #------------------------
  datos_uv_hoy <- datos_tiempo %>%
    filter(fecha == Sys.Date()) %>%
    select(provincia, uv)
  
  output$mapa_uv <- renderLeaflet({
    Provs <- esp_get_prov() %>% rename(provincia = ine.prov.name)
    
    provincias_uv <- inner_join(Provs, datos_uv_hoy, by = "provincia") %>%
      sf::st_as_sf()
    
    centroides <- st_centroid(provincias_uv)  
    
    pal <- colorNumeric(palette = "YlOrRd", domain = provincias_uv$uv)
    
    leaflet(provincias_uv, options = leafletOptions(
      zoomControl = TRUE,
      dragging = TRUE,
      scrollWheelZoom = TRUE
    )) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(
        fillColor = ~pal(uv),
        color = "white",
        weight = 1,
        fillOpacity = 0.8,
        highlightOptions = highlightOptions(
          weight = 2,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLabelOnlyMarkers(
        data = centroides,
        lng = ~st_coordinates(geometry)[, 1],
        lat = ~st_coordinates(geometry)[, 2],
        label = ~as.character(uv),
        labelOptions = labelOptions(
          noHide = TRUE,
          direction = "center",
          textOnly = TRUE,
          style = list(
            "font-weight" = "bold",
            "font-size" = "12px",
            "background-color" = "white",
            "border" = "1px solid gray",
            "padding" = "2px"
          )
        )
      ) %>%
      addLegend(
        pal = pal,
        values = ~uv,
        title = paste("Índice UV -", Sys.Date()),
        position = "bottomright"
      ) %>%
      setView(lng = -3, lat = 40, zoom = 5)
  })
  
  
  
  altitud<- read_excel("promedio_altitud_provincia.xlsx")
  equivalencias_mapa_altitud <- c(
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
    "ILLES BALEARS" = "Balears, Illes",
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
  
  provincias_validas <- names(equivalencias_mapa_altitud)
  
  datos_altitud_mapa <- altitud %>%
    filter(provincia %in% provincias_validas) %>%
    mutate(provincia = recode(provincia, !!!equivalencias_mapa_altitud))%>%
    select(provincia,promedio_altitud)
  datos_altitud_mapa <- datos_altitud_mapa %>%
    mutate(
      indice = case_when(
        promedio_altitud < 200 ~ 1,
        promedio_altitud < 500 ~ 2,
        promedio_altitud < 800 ~ 3,
        promedio_altitud < 1000 ~ 4,
        TRUE ~ 5
      )
    )
  
  output$mapa_altitud <- renderLeaflet({
    Provs <- esp_get_prov() %>% rename(provincia = ine.prov.name)
    
    provincias_alt <- inner_join(Provs, datos_altitud_mapa, by = "provincia") %>%
      sf::st_as_sf()
    
    pal <- colorNumeric(palette = "BrBG", domain = provincias_alt$promedio_altitud, reverse = FALSE)
    
    leaflet(provincias_alt, options = leafletOptions(
      zoomControl = TRUE,
      dragging = TRUE,
      scrollWheelZoom = TRUE
    )) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(
        fillColor = ~pal(promedio_altitud),
        color = "white",
        weight = 1,
        fillOpacity = 0.8,
        label = ~lapply(
          paste0(
            "<strong>", provincia, "</strong><br/>",
            "Altitud promedio: ", promedio_altitud, " m<br/>",
            "Indice según la altitud:", indice
          ),
          htmltools::HTML
        ),
        highlightOptions = highlightOptions(
          weight = 2,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        pal = pal,
        values = ~promedio_altitud,
        title = "Altitud promedio (m)",
        position = "bottomright"
      ) %>%
      setView(lng = -3, lat = 40, zoom = 5)
  })
  

  
  
  
  recomendacion<-function(uv,tmax,fototipo){
    alto_riesgo<- fototipo %in% c("I","II")
    riesgo_medio<- fototipo %in% c("III","IV")
    bajo_riesgo<- fototipo %in% c("V","VI")
    if (uv >= 6 && tmax >= 20 && alto_riesgo) {
      return("¡¡ATENCIÓN!!: Alto riesgo, use protector SPF50+, evita la exposición al sol entre las 12-16h,use gafas y y protección solar capilar.")
    } else if (uv >= 6 && tmax >= 20 && (alto_riesgo || riesgo_medio)) {
      return("Riesgo MODERADO-ALTO: usa protector SPF50, evita la exposición al sol entre las 12-16h,use gafas y proteccón solar capilar.")
    } else if (uv >= 6 && fototipo %in% c("I", "II", "III")) {
      return(" Riesgo ALTO: Se recomienda usar SPF50, evita la exposición al sol entre las 12-16h,use gafas y proteccón solar capilar..")
    } else if (uv < 4 && bajo_riesgo) {
      return("Riesgo BAJO: protección solar recomendada SPF30. No olvide proteger sus ojos, use gafas de sol .")
    } else if (tmax >= 35) {
      return("¡¡ATENCÓN!!: temperatura extrema, mantengase hidratado y evita exposición al sol directa durante las horas 12-16h.")
    } else {
      return("Riesgo BAJO-MODERADO: use protección SPF20 si vas a estar  expuesto al sol por larga duración. ")
    }
  
    
    
  }
  observeEvent(input$generar_recomendacion, {
    provincia <- input$provincia_usuario

    datos_hoy <- base_climatica %>%
      filter(provincia == provincia & fecha == Sys.Date())
    
    if (nrow(datos_hoy) == 0) {
      output$mensaje_recomendacion <- renderText("No hay datos disponibles para esa provincia.")
      return()}
    uv<-datos_hoy$uv
    tmax<-datos_hoy$Tmax
    fototipo_piel<- switch(input$tipo_piel,
                           "Muy blanca"="I" ,
                           "Blanca"="II",
                           "Intermedia"="III" ,
                           "Morena clara"="IV" ,
                           "Morena oscura"="V" ,
                           "Negra"="VI" 
                    )
    mensaje<- recomendacion(uv,tmax,fototipo_piel)
    output$mensaje_recomendacion<-renderText(mensaje)
    
  })
  
  
  
  
  datos_temp_hoy <- datos_tiempo %>%
    filter(fecha == Sys.Date()) %>%
    select(provincia, Tmax)
  
  output$mapa_temp <- renderLeaflet({
    Provs <- esp_get_prov() %>% rename(provincia = ine.prov.name)
    
    provincias_temp <- inner_join(Provs, datos_temp_hoy, by = "provincia") %>%
      sf::st_as_sf()
    
    pal <- colorNumeric(palette = "Reds", domain = provincias_temp$Tmax)
    
    leaflet(provincias_temp, options = leafletOptions(
      zoomControl = TRUE,
      dragging = TRUE,
      scrollWheelZoom = TRUE
    )) %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(
        fillColor = ~pal(Tmax),
        color = "white",
        weight = 1,
        fillOpacity = 0.8,
        highlightOptions = highlightOptions(
          weight = 2,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        pal = pal,
        values = ~Tmax,
        title = "Temperatura máxima (°C) - ", Sys.Date(),
        position = "bottomright"
      ) %>%
      setView(lng = -3, lat = 40, zoom = 5)
  })
  
    
  })


