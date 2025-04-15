shinyUI(fluidPage(
  titlePanel("Información sobre Radiación UV y Melanoma"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Contenido Informativo")
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
                 p("Mide la intensidad de la radiación UV que alcanza la tierra.En la actualidad existe un indice de ultravioleta estandar de la OMS en colaboración con distintas organizaciones entre ellas la Organización Meteorologica
                   Mundial "),
                 tags$ul(
                   tags$li(strong("0-2 BAJO-"),"Tener en zonas donde pueder reflejarse la radiación ya que puede aumentar la exposición."),
                   tags$li(strong("3-5 MODERADO-"), "Puede causar daño moderado si no usa la protección necesaria, cremas, gafas de sol, permanecer a la sombra. "),
                   tags$li(strong("6-7 ALTO-"),"Una exposición al sol sin protección durante las horas 10am-4pm puede causar daños a la piel."),
                   tags$li(strong("8-10 MUY ALTO-"), "Hay que tomar precauciones adicionales para evitar daños graves a la piel y los ojos, ya que la radiación UV hace efecto rápidamente.
                           Aplicar protección solar SPF 30+ cada dos horas.Evitar la exposición al sol entre las horas 10am-4pm."),
                   tags$li(strong("+11 EXTREMO-"),"Supone un riesgo extremo de daño por la exposición al sol sin protección. Evitar la exposición al sol entre las horas 10am-4pm.")
                 ),
                 img(src="intervalos.png", width="600px")
        ),
        
        tabPanel("Melanoma maligno de piel ",
                 h3("¿Qué es?"),
                 p("Es un tipo de cáncer de piel que se desarrolla cuando las células que nos aportan color a la piel, melanocitos, comienzan a crecer fuera de control. Es menos frecuente que otros tipos de cánceres de piel pero es más grave ya que si no se descubre y se trata
                   a tiempo puede propagarse al resto del cuerpo."                 ),
                 p("Son más frecuentes en zonas superiores del cuerpo como la espalda y el pecho en hombres, en las piernas en las mujeres."),
                 p("La radiación UV es un factor muy  importante y bien reconocido en la génesis del cáncer cutáneo, pero también existen otros factores de riesgo como la predisposición genética, y la combinación de otros factores ambientales como la altitud y temperaturas 
                   maximas cuyo efecto combinado puede aumentar el riesgo de padecer melanoma cutáneo"),
                 p("Aqui un ejemplo de su expresión"),
                 fluidRow(
                   column(4,img(src="melanoma_1.jpg", width="100%")),
                   column(4,img(src="melanoma_2.png", width="100%")),
                   column(4,img(src="melanoma_3.png", width="100%"))
                   
                 )
                 
        )
        
      ),
      hr(),
      
      tabsetPanel(
  )
    )
  )
))
