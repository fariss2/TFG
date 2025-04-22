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
                                       ),
                                       br(),
                                       h3("Efectos de la radiación UV sobre el ADN"),
                                       p("La incidencia directa de la radiación UV en combinación con otros factores de riesgo ambientales y genéticos altera el ADN de los melanocitos,son las células que pigmentan la piel."),
                                       p("El ADN de una célula son las instrucciones que debe seguir la célula para seguir multiplicándose y creciendo a un ritmo sano; y finalmente cuando sea indicado el momento de la apoptosis, muerte celular."),
                                       p("El resultado más común por la luz UV es la formación de dímeros de pirimidina, lo que induce a mutaciones en las células epidérmicas, y como consecuencia se crean células cancerosas."),
                                       img(src = "dimeros.png", width = "600px"),
                                       p("Estos dímeros distorsionan localmente la estructura del ADN interfiriendo en el apareamiento de bases complementarias. "),
                                       p("A veces se reparan los dímeros pero existen casos en los que no y esto afecta a los procesos de replicación y transcripción."),
                                       p("La acumulación de alteraciones en el ADN puede provocar mutaciones en genes de gran importancia, como el gen supresor de tumores p53 que es esencial para mantener el equilibrio genético."),
                                       p("Su función principal es controlar la reparación del ADN, la detención del ciclo celular y la apoptosis."),
                                       p("Promueve la apoptosis para evitar el desarrollo del cáncer cuando el daño en el ADN es demasiado severo y no se ha reparado."),
                                       img(src="p53.jpeg", width="500px"),
                                       p("El exceso de radiación UV puede causar mutaciones específicas en este gen que alterarán su función protectora.")
                                       
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
                                     p("Es un tipo de cáncer de piel que se desarrolla cuando las células que nos aportan color a la piel, como se ha mencionado anteriormente los melanocitos, comienzan a crecer fuera de control. Es menos frecuente que otros tipos de cánceres de piel, pero más grave, ya que si no se detecta a tiempo puede propagarse al resto del cuerpo."),
                                     p("Este tipo de cancer se suele desarrollar generalmente en la piel más expuesta a la luz solar como los brazos,cara, piernas o espalda cuando estamos tomando el sol. "),
                                     p("La radiación UV es un factor muy importante y bien reconocido en la génesis del cáncer cutáneo, pero también existen otros factores de riesgo como la predisposición genética, y la combinación de otros factores ambientales como la altitud y las temperaturas máximas."),
                                     p("Se sabe que la exposicion descontrolada y sin proteccion a la radiación ultravioleta es la culpable de la mayoría de melanomas y por ello, debemos limitar la exposición a esta. "),
                                     p("Aquí un ejemplo de su expresión:"),
                                     fluidRow(
                                       column(4, img(src = "melanoma_1.jpg", width = "100%")),
                                       column(4, img(src = "melanoma_2.png", width = "100%")),
                                       column(4, img(src = "melanoma_3.png", width = "100%"))
                                     ),
                                     br(),
                                     h3("Signos y síntomas tempranos del melanoma"),
                                     p("Los primeros síntomas del melanoma suelen ser cambion en la piel, tanto en el cambio de lunares o pecas ya existentes como la aparición de una nueva malformación pigmentada. "),
                                     p("Todos sabemos como es el aspecto de un lunar sano, pero algunos presentan características anormales que indican melanomas u otros tipos de cáncer de piel."),
                                     p("Un lunar sano presenta un color uniforme, con borde definido de forma ovalada o redonda."),
                                     p("Las características que deberían llamarnos la atención son las siguientes:"),
                                     tags$ul(
                                       tags$li("Forma asímetrica"),
                                       tags$li("Cambios de color,bultos cuyo color no este bien definido visualmente o no se un color usual."),
                                       tags$li("Cambios de tamaño, que su diametros sea superior a los 6 milimetros."),
                                       tags$li("Aparición de sangrado o tenga apariencia de picazón."),
                                       tags$li("Bordes inusuales, no bien definidos, que tenga cortes en la forma.")
                                     ),
                                     p("Aquí una comparación visual de como es un lunar sano de uno maligno."),
                                     img(src = "maligno_vs_benigno.png", width = "600px")
                                     
                                     
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
