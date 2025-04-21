library(shiny)

shinyUI(
  navbarPage("App Radiación UV y Melanoma",
             
             
             tabPanel("Contenido informativo",
                      sidebarLayout(
                        sidebarPanel(
                          h4("Contenido educativo")
                        ),
                        mainPanel(
                          tabsetPanel(
                            
                            
                            tabPanel("¿Qué es la radiación UV?",
                                     h3("La radiación ultravioleta (UV)"),
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
                                     )
                            ),
                            
                            
                            tabPanel("Niveles de riesgo UV",
                                     h3("Escala del índice UV"),
                                     p("Mide la intensidad de la radiación UV que alcanza la tierra. En la actualidad existe un índice de ultravioleta estandarizado por la OMS en colaboración con otras organizaciones, como la Organización Meteorológica Mundial."),
                                     tags$ul(
                                       tags$li(strong("0-2 BAJO - "), "Tener precaución en zonas donde puede reflejarse la radiación, ya que puede aumentar la exposición."),
                                       tags$li(strong("3-5 MODERADO - "), "Puede causar daño moderado si no se usa la protección necesaria: cremas, gafas de sol, permanecer a la sombra."),
                                       tags$li(strong("6-7 ALTO - "), "Una exposición al sol sin protección durante las horas 10:00 a 16:00 puede causar daños a la piel."),
                                       tags$li(strong("8-10 MUY ALTO - "), "Tomar precauciones adicionales para evitar daños graves. Aplicar protector solar SPF 30+ cada dos horas y evitar exposición directa en horas pico."),
                                       tags$li(strong("11+ EXTREMO - "), "Riesgo extremo de daño por exposición solar. Evitar completamente la exposición directa entre las 10:00 y 16:00.")
                                     ),
                                     img(src = "intervalos.png", width = "600px")
                            ),
                            
                            
                            tabPanel("Melanoma maligno de piel",
                                     h3("¿Qué es?"),
                                     p("Es un tipo de cáncer de piel que se desarrolla cuando las células que nos aportan color a la piel, los melanocitos, comienzan a crecer fuera de control. Es menos frecuente que otros tipos de cánceres de piel, pero más grave, ya que si no se detecta a tiempo puede propagarse al resto del cuerpo."),
                                     p("Son más frecuentes en zonas superiores del cuerpo como la espalda y el pecho en hombres, y en las piernas en las mujeres."),
                                     p("La radiación UV es un factor muy importante y bien reconocido en la génesis del cáncer cutáneo, pero también existen otros factores de riesgo como la predisposición genética, y la combinación de otros factores ambientales como la altitud y las temperaturas máximas."),
                                     p("Aquí un ejemplo de su expresión:"),
                                     fluidRow(
                                       column(4, img(src = "melanoma_1.jpg", width = "100%")),
                                       column(4, img(src = "melanoma_2.png", width = "100%")),
                                       column(4, img(src = "melanoma_3.png", width = "100%"))
                                     )
                            )
                            
                          )
                        )
                      )
             ),
             
             
             tabPanel("Índice UV hoy",
                      tabsetPanel(
                        tabPanel("Mapa indice UV",
                                 h3("Mapa actual del indice UV"),
                                 plotOutput("mapa_uv", height = "800px",width = "100%")
                                 ),
                        tabPanel("alerta",
                                 h3("aviso al usuario en caso de valores de riesgo de UV y temperatura máxima"),
                                 textInput("provincia_us", "Introduce tu provincia:"),
                                 textInput("email_us", "Introduce tu email:"),
                                 actionButton("alerta","comprobar zona"),
                                 br(),
                                 textOutput("mensaje_alerta")
                        )
                          
                        )
                      ),
                      
                     
             
             tabPanel("Ultima Semana",
                      fluidPage(
                        h3("g"),
                        p("b"),
                        tableOutput("tabla_historica")  
                      )
             ),
             
             
             tabPanel("base climatica ",
                      fluidPage(
                        h3("Base climatica Actual"),
                        p("En la siguiente pestaña se muestra una base de datos que ses va actualizando con los datos que vamos recibiendo 
                          de las APIs de la AEMET. Nos mostrara la fecha de los valores de indice de radiación ultravioleta, temperatura máxima y mínima de cada provincia"),
                        tableOutput("tabla_de_BC")
                      )
             ),
             
             
             tabPanel("Acerca del proyecto",
                      fluidPage(
                        h4("Trabajo de Fin de Grado de Ingeniería de la Salud"),
                        img(src="Cabecera_Escudo_Salud.png", height = "800px" ),
                        p("Autor/a: Nisrine Fariss Lamine"),
                        p("Tutor/a: Antonio Jesus Canepa Oneto"),
                        p(" Universidad de Burgos "),
                        p("Este proyecto utiliza datos meteorológicos y sanitarios con fines divulgativos y educativos."),
                        p("La idea es alertar sobre factores de riesgo para el desarrollo del cáncer de piel y reclutar datos con la base de datos climatico creada
                          por la falta de información para predecir la probabilidad de padecer esta patología ")                      )
             )
  )
)
