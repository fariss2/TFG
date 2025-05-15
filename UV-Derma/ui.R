library(shiny)
library(leaflet)

shinyUI(
  navbarPage("UV-Derma: Plataforma de Prevención del Melanoma", id="navegador",
             tags$head(
               tags$style(HTML(
                 " .tab-content {
                   margin-bottom: 100px;
                 }"))
             ),
             tabPanel("Inicio",
                      fluidPage(
                        tags$head(
                          tags$style(HTML("
        .hero-container {
          position: relative;
          text-align: center;
          color: white;
        }
        .hero-text {
          position: absolute;
          top: 20%;
          left: 50%;
          transform: translate(-50%, -50%);
          background-color: rgba(0,0,0,0.5);
          padding: 20px 40px;
          border-radius: 10px;
          font-size: 28px;
          font-weight: bold;
        }
        .hero-subtext {
          position: absolute;
          top: 35%;
          left: 50%;
          transform: translate(-50%, -50%);
          background-color: rgba(0,0,0,0.4);
          padding: 10px 30px;
          border-radius: 8px;
          font-size: 18px;
        }
        .img-fluid {
          width: 100%;
          height: auto;
          border-radius: 0;
        }
        .contenido-centrado {
          text-align: center;
          margin-top: 40px;
        }"))
                        ),
                        
                        
                        div(class = "hero-container",
                            img(src = "posible_portada1.png", class = "img-fluid"),
                            div(class = "hero-text", "Bienvenido/a a UV-Derma"),
                            div(class = "hero-subtext", "Plataforma interactiva para la prevención del melanoma")
                        ),
                        
                        
                        div(class = "contenido-centrado",
                            p("Esta web ofrece información educativa sobre el cáncer de piel, alertas personalizadas basadas en factores ambientales (radiación UV, temperatura máxima y altitud) y acceso a bases de datos meteorológicos para futuras actualizaciones.")
                        ),
                        br(),
                        
                        fluidRow(
                          column(6,
                                 h3(strong("¿Qué puedes hacer?")),
                                 tags$ul(
                                   tags$li("Obtener información relevante y de interes sobre el cáncer de piel, tipo melanoma y como afecta la radiación UV a nuestra piel."),
                                   tags$li("Consultar el índice UV actual por provincia, entre otras funciones "),
                                   tags$li("Visualización de las variables que aumentan el riesgo de desarrollar un melanoma "),
                                   tags$li("Cálculo aproximado de sufrir esta patología según las condiciones actuales de tu zona geográfica"),
                                   tags$li("Recomendador según tu piel y zona geográfica, indicaciones que seguir para prevenir el melanoma."),
                                   tags$li("Explorar datos ambientales y tasas de mortalidad."),
                                   tags$li("Acceder a un historial de datos meteorológicos actualizada para análisis futuros.")
                                 )
                          )
                          
                        ),
                        br(),
                        
                        h3(strong("¿Sabías que...?")),
                        img(src = "sabias_que.png", width = "550px"),
                        
                        tags$ul(
                          tags$li("Una quemadura solar en la infancia puede duplicar el riesgo de melanoma."),
                          tags$li("La radiación UV puede ser intensa incluso en días nublados."),
                          tags$li("Las zonas de mayor altitud reciben más radiación UV."),
                          tags$li("El 90% de los melanomas son evitables con protección adecuada."),
                          tags$li("El 80% del daño solar en la piel ocurre antes de los 18 años"),
                          
                        )
                      ),
                      
                      br(),
                      
                      tags$head(
                        tags$style(HTML("
    .inicio-botones {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 20px;
      margin-top: 20px;
      margin-bottom: 60px;
    }
    
    .btn-primary {
      background-color: #1e88e5;
      color: white;
      font-size: 16px;
      padding: 15px 25px;
      border-radius: 10px;
      border: none;
      box-shadow: 2px 2px 5px rgba(0,0,0,0.2);
      transition: all 0.3s ease;
    }

    .btn-primary:hover {
      background-color: #1565c0;
      transform: scale(1.05);
    }

    .btn-success {
      background-color: #f9a825;
    }

    .btn-danger:hover {
      background-color: #f57f17;
    }

    .btn-warning {
      background-color: #43a047;
    }

    .btn-secondary:hover {
      background-color: #2e7d32;
    }
  "))
                      ),
                      
                      div(class = "inicio-botones",
                          actionButton("ir_info", "Contenido informativo", class = "btn-primary"),
                          actionButton("ir_alerta", "Mapa de Variables", class = "btn-success"),
                          actionButton("ir_riesgo", "Riesgo Acumulado", class = "btn-danger"),
                          actionButton("ir_recomendador", "Recomendador", class = "btn-warning"),
                          actionButton("ir_datos", "Base Climatica", class = "btn-secondary")
                      )
                      
             ),
             
             
             
             tabPanel("Contenido informativo",
                      tabsetPanel(
                        
                        tabPanel("¿Qué es la radiación UV?",
                                 h3(strong("La radiación ultravioleta (UV)")),
                                 fluidRow(
                                   column(12,
                                          p("Es una fracción de la energía radiante que proviene del sol y representa la porción más energética del espectro electromagnético que incide sobre la superficie terrestre."),
                                          p("Tiene una capacidad para producir efectos biológicos con consecuencias significativas sobre el cuerpo debido a la interacción directa que se produce sobre el ADN y proteínas.")
                                   )
                                 ),
                                 fluidRow(
                                   column(6,
                                          h4("Existen tres tipos según la longitud de onda:"),
                                          tags$ul(
                                            tags$li(strong("UVC:"), " es la más energética (100-280nm), pero se retiene en la capa de ozono. A pesar de que no llegue naturalmente a la tierra, se puede producir artificialmente."),
                                            tags$li(strong("UVB:"), " es menos energética que UVC (280-320nm), pero es la más dañina para la salud humana causando daños directos en la piel."),
                                            tags$li(strong("UVA:"), " es menos energética que UVB (320-400nm), pero la que más abunda, produce envejecimiento prematuro por su penetración profunda en la piel.")
                                          )
                                   ),
                                   column(6,
                                          img(src = "r_UV.jpg", width = "550px")
                                   )
                                 ),
                                 br(),
                                 h3("Efectos de la radiación UV sobre el ADN"),
                                 p("La incidencia directa de la radiación UV en combinación con otros factores de riesgo ambientales y genéticos altera el ADN de los melanocitos, son las células que pigmentan la piel."),
                                 p("El ADN de una célula son las instrucciones que debe seguir la célula para seguir multiplicándose y creciendo a un ritmo sano; y finalmente cuando sea indicado el momento de la apoptosis, muerte celular."),
                                 p("El resultado más común por la luz UV es la formación de dímeros de pirimidina, lo que induce a mutaciones en las células epidérmicas, y como consecuencia se crean células cancerosas."),
                                 img(src = "dimeros.png", width = "600px"),
                                 p("Estos dímeros distorsionan localmente la estructura del ADN interfiriendo en el apareamiento de bases complementarias."),
                                 p("A veces se reparan los dímeros pero existen casos en los que no y esto afecta a los procesos de replicación y transcripción."),
                                 p("La acumulación de alteraciones en el ADN puede provocar mutaciones en genes de gran importancia, como el gen supresor de tumores p53 que es esencial para mantener el equilibrio genético."),
                                 p("Su función principal es controlar la reparación del ADN, la detención del ciclo celular y la apoptosis."),
                                 p("Promueve la apoptosis para evitar el desarrollo del cáncer cuando el daño en el ADN es demasiado severo y no se ha reparado."),
                                 img(src="p53.jpeg", width="500px"),
                                 p("El exceso de radiación UV puede causar mutaciones específicas en este gen que alterarán su función protectora."),
                                 br(),
                                 actionButton("volver_inicio_desde_dano_uv", "Volver a inicio", class = "btn btn-primary")
                        ),
                        
                        tabPanel("Niveles de riesgo UV",
                                 h3(strong("Escala del índice UV")),
                                 p("Mide la intensidad de la radiación UV que alcanza la tierra. En la actualidad existe un índice de ultravioleta estandarizado por la OMS en colaboración con otras organizaciones, como la Organización Meteorológica Mundial."),
                                 tags$ul(
                                   tags$li(strong("0-2 BAJO - "), "Tener precaución en zonas donde puede reflejarse la radiación, ya que puede aumentar la exposición."),
                                   tags$li(strong("3-5 MODERADO - "), "Puede causar daño moderado si no se usa la protección necesaria: cremas, gafas de sol, permanecer a la sombra."),
                                   tags$li(strong("6-7 ALTO - "), "Una exposición al sol sin protección durante las horas 10:00 a 16:00 puede causar daños a la piel."),
                                   tags$li(strong("8-10 MUY ALTO - "), "Tomar precauciones adicionales para evitar daños graves. Aplicar protector solar SPF 30+ cada dos horas y evitar exposición directa en horas pico."),
                                   tags$li(strong("11+ EXTREMO - "), "Riesgo extremo de daño por exposición solar. Evitar completamente la exposición directa entre las 10:00 y 16:00.")
                                 ),
                                 img(src = "intervalos.png", width = "600px"),
                                 br(),
                                 actionButton("volver_inicio_desde_intervalos", "Volver a inicio", class = "btn btn-primary")
                        ),
                        
                        tabPanel("Melanoma maligno de piel",
                                 h3(strong("¿Qué es?")),
                                 p("Es un tipo de cáncer de piel que se desarrolla cuando las células que nos aportan color a la piel, como se ha mencionado anteriormente los melanocitos, comienzan a crecer fuera de control. Es menos frecuente que otros tipos de cánceres de piel, pero más grave, ya que si no se detecta a tiempo puede propagarse al resto del cuerpo."),
                                 p("Este tipo de cáncer se suele desarrollar generalmente en la piel más expuesta a la luz solar como los brazos, cara, piernas o espalda cuando estamos tomando el sol."),
                                 p("La radiación UV es un factor muy importante y bien reconocido en la génesis del cáncer cutáneo, pero también existen otros factores de riesgo como la predisposición genética, y la combinación de otros factores ambientales como la altitud y las temperaturas máximas."),
                                 p("Se sabe que la exposición descontrolada y sin protección a la radiación ultravioleta es la culpable de la mayoría de melanomas y por ello, debemos limitar la exposición a esta."),
                                 p("Aquí un ejemplo de su expresión:"),
                                 fluidRow(
                                   column(4, img(src = "melanoma_1.jpg", width = "100%")),
                                   column(4, img(src = "melanoma_2.png", width = "100%")),
                                   column(4, img(src = "melanoma_3.png", width = "100%"))
                                 ),
                                 br(),
                                 h3(strong("Signos y síntomas tempranos del melanoma")),
                                 p("Los primeros síntomas del melanoma suelen ser cambios en la piel, tanto en el cambio de lunares o pecas ya existentes como la aparición de una nueva malformación pigmentada."),
                                 p("Todos sabemos cómo es el aspecto de un lunar sano, pero algunos presentan características anormales que indican melanomas u otros tipos de cáncer de piel."),
                                 p("Un lunar sano presenta un color uniforme, con borde definido de forma ovalada o redonda."),
                                 p("Las características que deberían llamarnos la atención son las siguientes:"),
                                 tags$ul(
                                   tags$li("Forma asimétrica"),
                                   tags$li("Cambios de color, bultos cuyo color no esté bien definido visualmente o no sea un color usual."),
                                   tags$li("Cambios de tamaño, que su diámetro sea superior a los 6 milímetros."),
                                   tags$li("Aparición de sangrado o sensación de picazón."),
                                   tags$li("Bordes inusuales, no bien definidos, que tenga cortes en la forma.")
                                 ),
                                 p("Aquí una comparación visual de cómo es un lunar sano frente a uno maligno."),
                                 img(src = "maligno_vs_benigno.png", width = "600px"),
                                 br(),
                                 actionButton("volver_inicio_desde_info_melanoma", "Volver a inicio", class = "btn btn-primary")
                        )
                        
                      )
             )
             ,
             
             
             tabPanel("Mapa de Variables",
                      tabsetPanel(
                        tabPanel("Mapa Melanoma",
                                 h3(strong("Mapa tasa de incidencias/Muertes de Melanoma de piel maligno INE")),
                                 leafletOutput("mapa_melanoma",height = "800px",width = "100%"),
                                 br(),
                                 actionButton("volver_inicio_desde_melanoma", "Volver a inicio", class = "btn btn-primary")
                        ),
                        tabPanel("Mapa UV ",
                                 h3(strong("Mapa del indice UV-",Sys.Date())),
                                 leafletOutput("mapa_uv", height = "800px",width = "100%"),
                                 br(),
                                 actionButton("volver_inicio_desde_uv", "Volver a inicio", class = "btn btn-primary")
                        ),
                        tabPanel("Mapa temperaturas",
                                 h3(strong("Mapa de temperaturas-", Sys.Date())),
                                 leafletOutput("mapa_temp", height ="800px", width ="100%"),
                                 br(),
                                 actionButton("volver_inicio_desde_temp", "Volver a inicio", class = "btn btn-primary")
                                 
                        ),
                        tabPanel("Mapa altitud",
                                 h3(strong("Altitud de las provincias.")),
                                 leafletOutput("mapa_altitud", height = "800px",width = "100%"),
                                 br(),
                                 actionButton("volver_inicio_desde_altitud", "Volver a inicio", class = "btn btn-primary")
                        )
                        
                        
                      )
             ),
             
             
             
             tabPanel("Riesgo Acumulado",
                      tabsetPanel(
                        tabPanel(strong("Riesgo Acumulado de Melanoma - "), Sys.Date()),
                        
                        
                        
                      )
                      
             ),
             tabPanel("Recomendador",
                      h3(strong("Recomendación según tipo de piel y zona geográfica")),
                      fluidRow(
                        column(6,
                               selectInput("provincia_usuario", "Selecciona tu provincia",
                                           choices = sort(unique(datos_tiempo$provincia))),
                               selectInput("tipo_piel", "Selecciona tu tipo de piel",
                                           choices = c("Muy blanca", "Blanca", "Intermedia",
                                                       "Morena clara", "Morena oscura", "Negra")),
                               actionButton("generar_recomendacion", "Obtener recomendación"),
                               br(), br(),
                               textOutput("mensaje_recomendacion"),
                               br(),
                               actionButton("volver_inicio_desde_recomendador", "Volver a inicio", class = "btn btn-primary")
                        ),
                        column(6,
                               h3(strong("Escala de Fitzpatrick")),
                               p("Esta escala es una clasificación de los tipos de piel según su capacidad para quemarse y broncearse."),
                               img(src = "escala_de_fitz.png", width = "500px"),
                               p("Existen 6 tipos:"),
                               tags$ul(
                                 tags$li(strong("Muy blanca:"), "Presente en individuos de piel muy clara, ojos azules, propia de pelirrojos con pecas en la piel. Presentan un color de piel blanco-lechoso. Se quema siempre de forma intensa sin presencia de bronceado y descama de forma ostensible."),
                                 tags$li(strong("Blanca:"), "Presente en individuos de piel clara, pelo rubio, ojos claros y con pecas, que no estan expuestas habitualmente al sol. Quemado intenso y fácil, con bronceado mínimo y descama de forma notoria "),
                                 tags$li(strong("Intermedia:"), "Presente en razas caucásicas de piel ligeramente morena que  no esta expuesta habitualmente al sol.Se quema con facilidad presentando un bronceado gradual. "),
                                 tags$li(strong("Morena clara:"), "Presente en individuos de piel morena con pelo y ojos oscuros. Se quema moderada o minímamente, bronceado o pigmentación inmediata y con bastante facilidad al exponerse al sol."),
                                 tags$li(strong("Morena oscura:"), "Presente en individuos de piel color marron. Se quema raramente y presentan bronceado muy intenso. "),
                                 tags$li(strong("Negra:"), " Fototipo propio de razas negras. Nunca se quema y pigmentación intensa.")
                               ),
                               h3(strong("¿Qué es el SPF de las cremas?")),
                               img(src="spf.jpg", width="400px"),
                               p("Estas siglas significan facto de protección solar y es una medida relativa del tiempo que el protector solar bloquea los rayos ultravioleta."),
                               p("Actua multiplicando el tiempo que puede estar una piel sin quemarse al sol, por ejemplo las pieles del fototipo I pueden estar hasta 10 minutos al sol"),
                               p("sin crema solar, usando el SPF20 podrá estar al sol 200 minutos expuesta al sol sin quemarse."),
                               img(src="spf1.jpg", width="500px"),
                               p("Como se ha dicho antes esta medida es relativa y existen factores que disminuyen la eficacia, como:"),
                               tags$ul(
                                 tags$li(strong("Sudoración")),
                                 tags$li(strong("Contacto con el agua")),
                                 tags$li(strong("Arena en la playa")),
                                 tags$li(strong("Fricción con la ropa")),
                                 
                               ),
                               p("Por estas razones los especialistas recomiendan reaplicarse la crema cada 2h, y 30 minutos antes de la primera exposición al sol para asegurar una mejor absorción.")
                               
                        )
                      )
             ),
             
             tabPanel("Datos meteorológicos ",
                      h3("Datos meteorológicos"),
                      
                      p("En la siguiente pestaña se muestra un historico de datos meteorológicos que se va actualizando con los datos que vamos recibiendo de las APIs de la AEMET. Nos mostrará la fecha de los valores de índice de radiación ultravioleta, temperatura máxima y mínima de cada provincia."),
                      p("En el siguiente grafico podemos visualizar la variación de la variable escogida y hacer una comparación visual de esta entre las diferentes provincias de España "),
                      
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("prov_select", "Selecciona las provincias a comparar:",
                                      choices = sort(unique(datos_tiempo$provincia)),
                                      multiple = TRUE,
                                      selected = "Albacete"),
                          selectInput("var_select", "Selecciona variable a visualizar:",
                                      choices = c("Temperatura máxima" = "Tmax",
                                                  "Temperatura mínima" = "Tmin",
                                                  "Índice UV" = "uv"))
                        ),
                        
                        mainPanel(
                          div(style = "display: flex; gap: 15px; margin-bottom: 20px;",
                              downloadButton("descargar_excel", "Descargar en Excel (.xlsx)", class = "btn btn-secondary"),
                              downloadButton("descargar_csv", "Descargar en CSV (.csv)", class = "btn btn-secondary")
                          ),
                          
                          plotOutput("grafico_temporal", height = "600px"),
                          br(),
                          
                          actionButton("volver_inicio_desde_datos", "Volver a inicio", class = "btn btn-primary")
                        )
                      )
             )
             ,
             
             
             tabPanel("Acerca del proyecto",
                      fluidPage(
                        h4(strong("Trabajo de Fin de Grado de Ingeniería de la Salud")),
                        div(style = "text-align: center;",
                            img(src = "Cabecera_Escudo_Salud.png", height = "200px")
                        ),
                        p("Autor/a: Nisrine Fariss Lamine"),
                        p("Tutor/a: Antonio Jesús Canepa Oneto"),
                        p(" Universidad de Burgos "),
                        p("Este proyecto utiliza datos meteorológicos y sanitarios con fines divulgativos y educativos."),
                        p("La idea es alertar sobre factores de riesgo para el desarrollo del cáncer de piel y reclutar datos meteorológicos para futuras líneas de investigaciones sobre predicciones de padecer esta patología "),
                        br(),
                        #añadir contacto o alaguna sugerencia del usario
                        #añadir repositorio git
                        actionButton("volver_inicio_desde_acerca_de", "Volver a inicio", class = "btn btn-primary")
                      )
             )
             
  )
)