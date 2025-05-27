library(dplyr)
library(climaemet)   
library(httr)
library(jsonlite)
library(readxl)  

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

#-------------------------

recomendacion <- function(uv, tmax, fototipo) {
  uv_cat<- cut(uv,
               breaks = c(0,3,6,8,11,15),
               labels=c("bajo","moderado","alto","muy alto","extremo"),
               right=FALSE)
  
  riesgo<- ifelse(fototipo %in% c("I","II"), "alto",
                  ifelse(fototipo %in% c("III","IV"), "medio", "bajo"))
  temp_cat<- cut(tmax,
                 breaks = c(-Inf,15,25,30,35,Inf),
                 labels = c("fresco","templado","cálido","caluroso","extremo"),
                 right = TRUE)
  
  mensajes <- list(
    extremo = list(
      alto = list(
        fresco=" Índice UV extremo🚨, temperaturas bajas: Máxima protección UV. Usa SPF50+, gorro🧢 y ropa larga🧥.️",
        templado=" Índice UV extremo🚨, temperaturas templadas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV extremo🚨, temperaturas cálidas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV extremo🚨, temperaturas altas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV extremo🚨, temperaturas extremas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      medio = list(
        fresco=" Índice UV extremo🚨, temperaturas bajas: Máxima protección UV. Usa SPF50+, gorro🧢 y ropa larga🧥.️",
        templado=" Índice UV extremo🚨, temperaturas templadas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV extremo🚨, temperaturas cálidas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV extremo🚨, temperaturas altas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV extremo🚨, temperaturas extremas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      bajo = list(
        fresco=" Índice UV extremo🚨, temperaturas bajas: Aunque su fototipo de piel es resistente, máxima protección UV. Usa SPF50+, gorro🧢 y ropa larga🧥.️",
        templado=" Índice UV extremo🚨, temperaturas templadas: Aunque su fototipo de piel es resistente, protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV extremo🚨, temperaturas cálidas: Aunque su fototipo de piel es resistente, protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV extremo🚨, temperaturas altas: Aunque su fototipo de piel es resistente, protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV extremo🚨, temperaturas extremas: Aunque su fototipo de piel es resistente, protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      )
    ),
    "muy alto" = list(
      alto = list(
        fresco=" Índice UV muy alto 📢, temperaturas bajas:Protección recomendada SPF50+, gorro🧢 y ropa larga🧥.️",
        templado=" Índice UV muy alto 📢, temperaturas templadas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV muy alto 📢, temperaturas cálidas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV muy alto 📢, temperaturas altas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV muy alto 📢, temperaturas extremas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      medio = list(
        fresco=" Índice UV muy alto 📢, temperaturas bajas:Protección recomendada SPF50+, gorro🧢 y ropa larga🧥.️",
        templado=" Índice UV muy alto 📢, temperaturas templadas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV muy alto 📢, temperaturas cálidas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV muy alto 📢, temperaturas altas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV muy alto 📢, temperaturas extremas: Protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      bajo = list(
        fresco=" Índice UV muy alto 📢, temperaturas bajas:Aun que su fototipo de piel sea resistente, protección recomendada SPF50+, gorro🧢 y ropa larga🧥.️",
        templado=" Índice UV muy alto 📢, temperaturas templadas: Aunque su fototipo de piel sea resistente, protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV muy alto 📢, temperaturas cálidas: Aunque su fototipo de piel sea resistente, protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV muy alto 📢, temperaturas altas: Aunque su fototipo de piel sea resistente, protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV muy alto 📢, temperaturas extremas: Aunque su fototipo de piel sea resistente, protección recomendada SPF50+, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      )
    ),
    alto = list(
      alto = list(
        fresco=" Índice UV alto ⚠️, temperaturas bajas: Protección recomendada SPF50, gorro🧢 y ropa larga🧥.️",
        templado=" Índice UV alto ⚠️, temperaturas templadas: Protección recomendada SPF50, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV alto ⚠️, temperaturas cálidas: Protección recomendada SPF50, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV alto ⚠️, temperaturas altas: Protección recomendada SPF50, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV alto ⚠️, temperaturas extremas: Protección recomendada SPF50, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      medio = list(
        fresco=" Índice UV alto ⚠️, temperaturas bajas: Protección recomendada SPF50, gorro🧢 y ropa larga🧥.️",
        templado=" Índice UV alto ⚠️, temperaturas templadas: Protección recomendada SPF50, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV alto ⚠️, temperaturas cálidas: Protección recomendada SPF50, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV alto ⚠️, temperaturas altas: Protección recomendada SPF50, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV alto ⚠️, temperaturas extremas: Protección recomendada SPF50, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      bajo = list(
        fresco=" Índice UV alto ⚠️, temperaturas bajas: Aun que su fototipo de piel sea resistente, protección recomendada SPF30, gorro🧢 y ropa larga🧥.️",
        templado=" Índice UV alto ⚠️, temperaturas templadas: Aun que su fototipo de piel sea resistente, protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV alto ⚠️, temperaturas cálidas: Aun que su fototipo de piel sea resistente, protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV alto ⚠️, temperaturas altas: Aun que su fototipo de piel sea resistente, protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV alto ⚠️, temperaturas extremas: Aun que su fototipo de piel sea resistente, protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      )
    ),
    moderado = list(
      alto = list(
        fresco=" Índice UV moderado 🔆, temperaturas bajas: Protección recomendada SPF30, gorro🧢  y ropa larga🧥 opcional.️",
        templado=" Índice UV moderado 🔆, temperaturas templadas: Protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV moderado 🔆, temperaturas cálidas: Protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV moderado 🔆️, temperaturas altas: Protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV moderado 🔆, temperaturas extremas: Protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      medio = list(
        fresco=" Índice UV moderado 🔆, temperaturas bajas: Protección recomendada SPF30, gorro🧢  y ropa larga🧥 opcional.️",
        templado=" Índice UV moderado 🔆, temperaturas templadas: Protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV moderado 🔆, temperaturas cálidas: Protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV moderado 🔆️, temperaturas altas: Protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV moderado 🔆, temperaturas extremas: Protección recomendada SPF30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      bajo = list(
        fresco=" Índice UV moderado 🔆, temperaturas bajas: Aun que su fototipo de piel sea resistente, protección recomendada SPF20-30, gorro🧢  y ropa larga🧥 opcional.️",
        templado=" Índice UV moderado 🔆, temperaturas templadas: Aun que su fototipo de piel sea resistente, protección recomendada SPF20-30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢 . Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV moderado 🔆, temperaturas cálidas: Aun que su fototipo de piel sea resistente, protección recomendada SPF20-30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV moderado 🔆️, temperaturas altas: Aun que su fototipo de piel sea resistente, protección recomendada SP20-F30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV moderado 🔆, temperaturas extremas: Aun que su fototipo de piel sea resistente, protección recomendada SPF20-30, gafas UV 🕶, ropa ligera y protectora y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      )
    ),
    bajo = list(
      alto = list(
        fresco=" Índice UV bajo ✅, temperaturas bajas: Protección recomendada SPF20-30.",
        templado=" Índice UV bajo ✅, temperaturas templadas: Protección recomendada SPF20-30, gafas UV 🕶 opcionales. Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV bajo ✅, temperaturas cálidas: Protección recomendada SPF20-30, gafas UV 🕶. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV bajo ✅️, temperaturas altas: Protección recomendada SP20-F30, gafas UV 🕶 y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV bajo ✅, temperaturas extremas: Protección recomendada SPF20-30, gafas UV 🕶 y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      medio = list(
        fresco=" Índice UV bajo ✅, temperaturas bajas: Protección recomendada SPF15-20.",
        templado=" Índice UV bajo ✅, temperaturas templadas: Protección recomendada SPF15-20, gafas UV 🕶 opcionales. Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV bajo ✅, temperaturas cálidas: Protección recomendada SPF15-20, gafas UV 🕶. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV bajo ✅️, temperaturas altas: Protección recomendada SPF15-20, gafas UV 🕶 y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV bajo ✅, temperaturas extremas: Protección recomendada SPF15-20, gafas UV 🕶 y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      ),
      bajo = list(
        fresco=" Índice UV bajo ✅, temperaturas bajas: No hay  factores de riesgo presentes.",
        templado=" Índice UV bajo ✅, temperaturas templadas: Protección recomendada gafas UV 🕶 opcionales. Limita exposición durante las horas 12-16pm ☀️.",
        cálido=" Índice UV bajo ✅, temperaturas cálidas: Protección recomendada gafas UV 🕶. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧. ",
        caluroso=" Índice UV bajo ✅️, temperaturas altas: Protección recomendada SPF15-20, gafas UV 🕶 y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧.",
        extremo=" Índice UV bajo ✅, temperaturas extremas: Protección recomendada SPF15-20, gafas UV 🕶 y gorro 🧢. Limita exposición durante las horas 12-16pm ☀️ y mantengase hidratado 💧."
      )
    )
  )
  
  mensaje <- mensajes[[as.character(uv_cat)]][[as.character(riesgo)]][[as.character(temp_cat)]]
  return(mensaje)
}

#---------------------------------
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


#---------------------
  calcular_riesgo_melanoma <- function(uv, tmax, altitud_indice, fototipo, edad, sexo, lunares, antecedentes) {
    puntos_uv <- case_when(
      uv < 3~ 0,
      uv < 6~ 1,
      uv < 8 ~ 2,
      uv < 11~ 4,
      TRUE ~ 6
    )
    
    puntos_temp <- case_when(
      tmax < 20 ~ 0,
      tmax < 30 ~ 1,
      tmax < 35 ~ 2,
      tmax >= 35 ~ 3
    )
    
    puntos_alt <- as.numeric(altitud_indice) - 1
    
    puntos_fototipo <- case_when(
      fototipo == "I" ~ 5,
      fototipo == "II"~ 4,
      fototipo == "III"~ 3,
      fototipo == "IV"~ 2,
      fototipo == "V"~ 1,
      fototipo == "VI"~ 0,
      TRUE~ NA_real_
    )
    
    puntos_edad <- case_when(
      edad < 30 ~ 1,
      edad < 50 ~ 2,
      edad < 70 ~ 3,
      TRUE ~0
    )
    
    puntos_sexo <- case_when(
      sexo == "Femenino" & edad < 50 ~ 2,
      sexo == "Femenino" & edad >= 50 ~ 1,
      sexo == "Masculino" & edad < 50 ~ 1,
      sexo == "Masculino" & edad >= 50 ~ 2,
      TRUE~ 0
    )
    
    
    puntos_lunares <- case_when(
      lunares == "Pocos" ~ 0,
      lunares == "Moderados" ~ 1,
      lunares == "Muchos" ~ 2
    )
    
    puntos_antecedentes <- ifelse(antecedentes == "Sí", 2, 0)
    
    riesgo_total <- puntos_uv + puntos_temp + puntos_alt + puntos_fototipo +
      puntos_edad + puntos_sexo + puntos_lunares + puntos_antecedentes
    
    nivel_riesgo <- case_when(
      riesgo_total <= 6 ~ "Bajo",
      riesgo_total <= 12~ "Moderado",
      riesgo_total <= 18~ "Alto",
      riesgo_total > 18 ~ "Muy alto"
    )
    
    return(list(
      puntuacion_total = riesgo_total,
      clasificacion = nivel_riesgo
    ))
  }
