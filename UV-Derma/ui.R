library(shiny)
library(leaflet)

shinyUI(
  navbarPage(strong("UV-Derma: Plataforma de Prevención del Melanoma"), id="navegador",
             tags$head(
               tags$style(HTML(
                 " .tab-content {
                   margin-bottom: 100px;
                 } 
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
                  }
                  .inicio-botones {
                  display: flex;
                  flex-wrap: wrap;
                  justify-content: center;
                  gap: 20px;
                  margin-top: 20px;
                  margin-bottom: 60px;
                  }
                  .btn-personal {
                  font-size: 16px;
                  padding: 15px 25px;
                  border-radius: 8px;
                  border: 2px solid transparent;
                  font-weight: bold;
                  transition: all 0.3s ease;
                  }
                  .btn-azul {
                  background-color: #2196f3;
                  color: white; 
                  border-color: #2196f3;
                  }
                  .btn-amarillo{ 
                  background-color: #fbc02d; 
                  color: white; 
                  border-color: #fbc02d;}
                  .btn-rojo { 
                  background-color: #e53935; 
                  color: white; 
                  border-color: #e53935;}
                  .btn-verde { 
                  background-color: #43a047;
                  color: white; 
                  border-color: #43a047;}
                  .btn-gris { 
                  background-color: #546e7a; 
                  color: white; 
                  border-color: #546e7a;}
                  .btn-marron {
                  background-color: #8d6e63;
                  color: white; 
                  border-color: #8d6e63;}
                  .btn-personal:hover {
                  filter: brightness(0.9);
                  cursor: pointer;
                  }
                  
                  .resalto-rojo {
                  background-color:#d9534f;
                  }
                  .restalto-amarillo {
                  background-color:#f0ad4e;
                  }
                  .resalto-verde {
                  background-color:#5cb85c;
                  }
                  .resalto-naranja{
                  background-color:#f0ad4e;}
                 
                 "))
             ),
             tabPanel(strong("Inicio"),
                      fluidPage(
                        div(class = "hero-container",
                            img(src = "posible_portada1.png", class = "img-fluid"),
                            div(class = "hero-text", "Bienvenido/a a UV-Derma"),
                            div(class = "hero-subtext", "Plataforma interactiva para la prevención del melanoma")
                        ),
                        
                        
                        div(class = "contenido-centrado",
                            h2(strong("Esta web ofrece información educativa sobre el cáncer de piel, alertas personalizadas basadas en factores ambientales (radiación UV, temperatura máxima y altitud) y acceso a bases de datos meteorológicos para futuras actualizaciones."))
                        ),
                        br(),
                        
                        fluidRow(
                          wellPanel(
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
                                 ),
                          br(),
                          wellPanel(
                            h3(strong("¿Sabías que...?")),
                            
                            img(src = "sabias_que.png", width = "550px"),
                            br(),br(),
                            tags$ul(
                              tags$li("Una quemadura solar en la infancia puede duplicar el riesgo de melanoma."),
                              tags$li("La radiación UV puede ser intensa incluso en días nublados."),
                              tags$li("Las zonas de mayor altitud reciben más radiación UV."),
                              tags$li("El 90% de los melanomas son evitables con protección adecuada."),
                              tags$li("El 80% del daño solar en la piel ocurre antes de los 18 años")
                            )
                          )
                          
                          )
                      ),
                      
                      br(),
                      
                      div(class = "inicio-botones",
                          actionButton("ir_info", "Contenido informativo", class = "btn-personal btn-azul"),
                          actionButton("ir_alerta", "Mapa de Variables", class = "btn-personal btn-amarillo"),
                          actionButton("ir_riesgo", "Riesgo Acumulado", class = "btn-personal btn-rojo"),
                          actionButton("ir_recomendador", "Recomendador", class = "btn-personal btn-verde"),
                          actionButton("ir_datos", "Datos Meteorológicos", class = "btn-personal btn-marron"),
                          actionButton("ir_acerca_de", "Acerca del Proyecto", class = "btn-personal btn-gris"),
                      )
                      
             ),
             tabPanel(strong("Contenido informativo"),value = "info",
                      tabsetPanel(id="navegador-interno",
                        tabPanel(strong("¿Qué es la radiación UV?"),
                                 wellPanel(
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
                                 )
                                 ),
                                 br(),
                                 wellPanel(
                                   h3(strong("Efectos de la radiación UV sobre el ADN")),
                                   p("La incidencia directa de la radiación UV en combinación con otros factores de riesgo ambientales y genéticos altera el ADN de los melanocitos, son las células que pigmentan la piel."),
                                   p("El ADN de una célula son las instrucciones que debe seguir la célula para seguir multiplicándose y creciendo a un ritmo sano; y finalmente cuando sea indicado el momento de la apoptosis, muerte celular."),
                                   p("El resultado más común por la luz UV es la formación de dímeros de pirimidina, lo que induce a mutaciones en las células epidérmicas, y como consecuencia se crean células cancerosas."),
                                   img(src = "dimeros.png", width = "600px"),
                                   p("Estos dímeros distorsionan localmente la estructura del ADN interfiriendo en el apareamiento de bases complementarias."),
                                   p("A veces se reparan los dímeros pero existen casos en los que no y esto afecta a los procesos de replicación y transcripción."),
                                   p("La acumulación de alteraciones en el ADN puede provocar mutaciones en genes de gran importancia, como el gen supresor de tumores p53 que es esencial para mantener el equilibrio genético."),
                                   p("Su función principal es controlar la reparación del ADN, la detención del ciclo celular y la apoptosis."),
                                   p("Promueve la apoptosis para evitar el desarrollo del cáncer cuando el daño en el ADN es demasiado severo y no se ha reparado."),
                                   p("El exceso de radiación UV puede causar mutaciones específicas en este gen que alterarán su función protectora."),
                                   img(src="p53.jpeg", width="500px")
                                 ),
                                 
                                 br(),
                                 actionButton("volver_inicio_desde_dano_uv", "Volver a inicio", class = "btn btn-primary")
                        ),
                        tabPanel(strong("Intervalos de los índices UV"),value = "intervalos",
                                 wellPanel(
                                   h3(strong("Escala del índice UV")),
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
                                 
                                 br(),br(),
                                 actionButton("volver_inicio_desde_intervalos", "Volver a inicio", class = "btn btn-primary")
                        ),
                        tabPanel(strong("Melanoma maligno de piel"),
                                 wellPanel(
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
                                   )
                                 ),
                                 
                                 br(),
                                 wellPanel(
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
                                   img(src = "maligno_vs_benigno.png", width = "600px")
                                 ),
                                 
                                 br(),
                                 actionButton("volver_inicio_desde_info_melanoma", "Volver a inicio", class = "btn btn-primary")
                        )
                      )
             ),
             tabPanel(strong("Mapa de Variables"),value = "mapas",
                      tabsetPanel(
                        tabPanel(strong("Mapa Melanoma"),
                                 h3(strong("Mapa tasa de incidencias/Muertes de Melanoma de piel maligno INE")),
                                 leafletOutput("mapa_melanoma",height = "800px",width = "100%"),
                                 br(),
                                 actionButton("volver_inicio_desde_melanoma", "Volver a inicio", class = "btn btn-primary")
                        ),
                        tabPanel(strong("Mapa UV "),
                                 h3(strong("Mapa del indice UV-",Sys.Date())),
                                 leafletOutput("mapa_uv", height = "800px",width = "100%"),
                                 br(),
                                 actionButton("volver_inicio_desde_uv", "Volver a inicio", class = "btn btn-primary")
                        ),
                        tabPanel(strong("Mapa temperaturas"),
                                 h3(strong("Mapa de temperaturas-", Sys.Date())),
                                 leafletOutput("mapa_temp", height ="800px", width ="100%"),
                                 br(),
                                 actionButton("volver_inicio_desde_temp", "Volver a inicio", class = "btn btn-primary")
                        ),
                        tabPanel(strong("Mapa altitud"),
                                 h3(strong("Altitud de las provincias.")),
                                 leafletOutput("mapa_altitud", height = "800px",width = "100%"),
                                 br(),
                                 actionButton("volver_inicio_desde_altitud", "Volver a inicio", class = "btn btn-primary")
                        )
                      )
             ),
             tabPanel(strong("Riesgo Acumulado"),value = "riesgo",
                      tabsetPanel(
                        tabPanel(strong("Calculadora de Riesgo Acumulado Melanoma "),
                                 wellPanel(
                                   h3(strong("Riesgo acumulado de Melanoma")),
                                   p("Esta herramienta proporciona una estimación orientativa del riesgo acumulado de melanoma del presente día de hoy."),
                                   p("Introduce tus datos para calcular tu riesgo acumulado de melanoma según tus datos geográficos y fototipo de piel."),
                                   
                                 ),
                                 fluidRow(
                                   column(
                                     width = 6,
                                     wellPanel(
                                       
                                       fluidRow(
                                         column(width = 2,
                                                img(src = "provincias.png", style = "max-width: 100%; height: 40px; margin-top: 8px;")
                                         ),
                                         column(width = 10,
                                                selectInput("provincia_usuario_riesgo", "Provincia:",
                                                            choices = sort(unique(datos_tiempo$provincia)))
                                         )
                                       ),
                                       
                                       fluidRow(
                                         column(width = 2,
                                                img(src="Fitzpatrick.jpg", style = "max-width: 100%; height: 40px; margin-top: 8px;")
                                                ),
                                         column(width = 10,
                                                selectInput("fototipo_usuario_riesgo", "Tipo de piel:",
                                                            choices = c("Muy blanca", "Blanca", "Intermedia", "Morena clara", "Morena oscura", "Negra"))
                                         )
                                       ),
                                       
                                       fluidRow(
                                         column(width = 2,
                                                img(src="sexo.png", style = "max-width: 100%; height: 40px; margin-top: 8px;")
                                                ),
                                         column(width = 10,
                                                selectInput("sexo", "Sexo:",
                                                            choices = c("Femenino", "Masculino"))
                                         )
                                       ),
                                       
                                       fluidRow(
                                         column(width = 2,
                                                img(src = "edad.avif", style = "max-width: 100%; height: 40px; margin-top: 8px;")
                                         ),
                                         column(width = 10,
                                                sliderInput("edad", "Edad:", min = 0, max = 100, value = 30)
                                         )
                                       ),
                                       
                                       fluidRow(
                                         column(width = 2,
                                                img(src = "lunares3.png", style = "max-width: 100%; height: 40px; margin-top: 8px;")
                                         ),
                                         column(width = 10,
                                                selectInput("lunares", "Presencia de lunares:",
                                                            choices = c("Pocos", "Moderados", "Muchos"))
                                         )
                                       ),
                                       
                                       fluidRow(
                                         column(width = 2,
                                                img(src = "fam.png", style = "max-width: 100%; height: 40px; margin-top: 8px;")
                                         ),
                                         column(width = 10,
                                                selectInput("antecedentes", "Antecedentes familiares:",
                                                            choices = c("No", "Sí"))
                                         )
                                       ),
                                       
                                       br(),
                                       actionButton("calcular_riesgo", "Calcular Riesgo 🧮", class = "btn btn-danger")
                                       
                                     )
                                   ),
                                   column(
                                     width = 6,
                                     wellPanel(
                                       h4(strong("Resultado del cálculo")),
                                       br(),
                                       htmlOutput("resultado_riesgo")
                                     )
                                   )
                                 )
                                 ),
                                 
                        tabPanel(strong("Marco Teórico Calculadora"),
                                 br(),
                                 wellPanel(
                                   h3(strong("¿Por qué estas variables?")),
                                   p("El desarrollo y la evolución del melanoma es el resultado de una interacción compleja de factores ambientales y características individuales como pueden ser los antecedentes familiares y el tipo de piel que poseemos."),
                                   p("El principal factor ambiental reconocido científicamente como factor cancerígeno es la radiación ultravioleta, la cual aumenta con la altitud y a temperaturas altas, por ello estas dos últimas también son factores de riesgo."),
                                   p("Como se ha mencionado antes las características individuales también forman parte del resultado de esta combinación, y las más accesibles a nuestra examinación son nuestros lunares, antecedentes familiares y nuestro fototipo de piel.")
                                 ),
                                 wellPanel(
                                   h3(strong("Factores ambientales")),
                                   br(),
                                   tags$ul(
                                     tags$li(h4(strong("Radiación Ultravioleta UV")),
                                             p("La OMS y la Agencia Internacional investigadora del Cáncer han declarado la radiación ultravioleta como el principal factor cancerígeno para el ser humano."),
                                             p("Varios estudios científicos y de investigación han demostrado que es el principal agente ambiental relacionado con esta patología, melanoma. Por estos motivos se incluye en esta calculadora de riesgo.")),
                                     tags$li(h4(strong("Altitud")),
                                             p("Esta variable no es de efecto directo al desarrollo del melanoma, pero sí que aumenta el riesgo de desarrollarlo ya que es directamente proporcional a la radiación ultravioleta."),
                                             p("La radiación ultravioleta aumenta hasta un 12% por cada 1000 metros de altitud ascendidos. Esto se debe a que la atmósfera se hace cada vez más delgada a mayores altitudes y filtra y absorbe menos la radiación."),
                                             p("Dado que España se caracteriza por una geografía diversa con un amplio rango de paisajes y altitudes, resulta interesante y relevante incluir esta variable.")),
                                     tags$li(h4(strong("Temperatura")),
                                             p("La temperatura no es una variable que tenga efecto directo sobre la piel, pero sí que influye en nuestros comportamientos."),
                                             p("Esto significa que en los días calurosos tendemos a llevar menos prendas y por ende estamos más expuestos a la radiación."))
                                   )
                                 ),
                                 wellPanel(
                                   h3(strong("Factores personales")),
                                   br(),
                                   tags$ul(
                                     tags$li(h4(strong("Fototipo de piel")),
                                             p("Según la escala de Fitzpatrick, los individuos con fototipos de piel claros, I/II, tienen mayor riesgo de sufrir quemaduras solares y desarrollar melanoma, ya que presentan menor concentración de melanina, lo que reduce la defensa frente a esta radiación.")
                                             ),
                                     tags$li(h4(strong("Edad y sexo")),
                                             p("El riesgo de melanoma aumenta de forma progresiva con la edad al irse debilitando el sistema inmunitario, sin embargo, la incidencia está aumentando también en adultos jovenes, sobre todo mujeres que presentan mayor incidencia antes de los 50años."),
                                             p("Según la", "American Academy of Dermatology" ,"no es hasta los 50 años que los hombres son más propensos que las mujeres de la misma edad a padecer melanoma. Esta cifra se duplica a los 65años y triplica a los 80años."),
                                             p("Por estas razones el sexo y la edad se consideran moduladores de la probabilidad de desarrollar un melanoma.")
                                             ),                                                                                  
                                     tags$li(h4(strong("Lunares")),
                                             p("Estos son tumores pigmentados benignos para nada problemáticos que van apareciendo a medida que crecemos. Los lunares en cantidad aumentan la probabilidad de desarrollar melanoma y más si son atípicos.")
                                             ),
                                     tags$li(h4(strong("Antecedentes familiares")),
                                            p("Como se ha mencionado antes, los lunares atípicos o personas que padecen enfermedades hereditarias como el Síndrome del nevo displásico (Síndrome del lunar atípico) entre otras patologías cutáneas aumentan el riesgo de desarrollar melanoma y por eso los antecedentes familiares son importantes de analizar.")
                                            )
                                   )
                                   ),                                   
                                 wellPanel(
                                   h4(strong("¿Por qué una calculadora de riesgo acumulado del melanoma?")),
                                   p("El melanoma es una enfermedad influenciada por múltiples factores ambientales y personales, entre ellas las descritas previamente."),
                                   p("Esta herramienta esta inspirada en la calculadora de predicción del Instituto Australiano del Melanoma. El objetivo de esta es realizar una estimación aproximada del riesgo existente con la información disponible, facilitando su prevención adaptada al contexto geográfico y biológico de cada usuario. En ningún momento sustituye la asistencia médica ya que el riesgo personal puede diferir de la estimación por factores externos."),
                                   p("La estructura interna de esta herramienta se fundamenta en metodologías ampliamente validadas y usadas en medicina preventiva, como los modelos de predicción desarrollados en el estudio del corazón en Framingham (Framingham Risk Score) para enfermedades cardiovasculares, o el FINDRISC para el diagnóstico de diabetes tipo 2. Estos modelos convierten variables clínicas en categorías puntuadas según su riesgo aportado a cada enfermedad."),
                                   p("UV-Derma adopta este enfoque para cuantificar el riesgo del melanoma, asignando puntuaciones a cada variable según su impacto documentado en los estudios científicos existentes. Esta suma de factores ofrece una estimación aproximada, comprensible y útil para la población general, sin perder su base científica. De esta manera, al igual que los modelos mencionados, permite implementar medidas preventivas contra el melanoma.")
                                 ),
                                 br(),br(),
                                 actionButton("volver_inicio_desde_riesgo_factores", "Volver a inicio", class = "btn btn-primary")
                                 )
                      )
             ),
             tabPanel(strong("Recomendador"),value ="recomendador",
                      wellPanel(
                        h3(strong("Recomendación según tipo de piel y zona geográfica")),
                        p("Esta sección te recomendara medidas de protección frente a la presencia de factores de riesgo en tu zona geográfica."),
                        p("Selecciona tu provincia y el recomendador analiza el índice de radiación ultravioleta y temperatura máxima de la zona y los riesgos que generan para hoy", Sys.Date())
                      ),
                      fluidRow(
                        column(6,
                               wellPanel(
                                 div(style = "text-align: center;",
                                             img(src = "recomendador.avif",
                                                 style = "max-width: 100%; height: auto; margin-bottom: 20px;")
                               ),
                               selectInput("provincia_usuario", "Selecciona tu provincia",
                                           choices = sort(unique(datos_tiempo$provincia))),
                               selectInput("tipo_piel", "Selecciona tu tipo de piel",
                                           choices = c("Muy blanca", "Blanca", "Intermedia",
                                                       "Morena clara", "Morena oscura", "Negra")),
                               actionButton("generar_recomendacion", "Obtener recomendación"),
                               br(), br(),
                               textOutput("mensaje_recomendacion"),
                               br(),
                               p("Puede consultar los intervalos de la radiación ultravioleta UV en la siguiente pestaña"),
                               actionButton("ir_intervalos_desde_recomendador", "Ir a Intervalos", class = "btn btn-secondary")),
                               
                               br(),br(),br(),
                               actionButton("volver_inicio_desde_recomendador", "Volver a inicio", class = "btn btn-primary")
                        ),
                        column(6,
                               wellPanel(
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
                                    )),
                               wellPanel(
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
                      )
             ),
             tabPanel(strong("Datos Meteorológicos"),value="datos",
                      wellPanel(h3(strong("Datos meteorológicos")),
                                p("En la siguiente pestaña se muestra un historico de datos meteorológicos que se va actualizando con los datos que vamos recibiendo de las APIs de la AEMET. Nos mostrará la fecha de los valores de índice de radiación ultravioleta, temperatura máxima y mínima de cada provincia."),
                                p("En el siguiente grafico podemos visualizar la variación de la variable escogida y hacer una comparación visual de esta entre las diferentes provincias de España "),
                      ),
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
             ),
             tabPanel(strong("Acerca Del Proyecto"),value = "acerca_de",
                      fluidPage(
                        h4(strong("Trabajo de Fin de Grado de Ingeniería de la Salud")),
                        div(style = "text-align: center;",
                            img(src = "Cabecera_Escudo_Salud.png", height = "200px")
                        ),
                        wellPanel( 
                          
                          p(strong("Autora:"), " Nisrine Fariss Lamine"),
                          p(strong("Tutor:"), " Antonio Jesús Canepa Oneto"),
                          br(),
                          p("Este proyecto utiliza datos meteorológicos y sanitarios con fines divulgativos y educativos."),
                          p("La idea es alertar sobre factores de riesgo para el desarrollo del cáncer de piel y reclutar datos meteorológicos para futuras líneas de investigaciones sobre predicciones de padecer esta patología ")),
                        br(),
                        wellPanel(
                          h4(strong("Contacto")),
                          p("Toda la información redactada y mencionada en  esta plataforma se encuentra citada en la memoria y anexos de este trabajo que puede consultarlo en el repositorio GitHub del mismo trabajo."),
                          p("También puede consultarlo para más información sobre la estructura interna de la aplicación. En caso de tener alguna otra sugerencia o algún problema al acceder a alguna pestaña web, dejanoslo saber en una issue del mismo repositorio."),
                          tags$a(href="https://github.com/fariss2/TFG" , "Ir al Repositorio Github🔗")),
                        br(),br(),
                        
                        actionButton("volver_inicio_desde_acerca_de", "Volver a inicio", class = "btn btn-primary")
                      )
             )
             
  )
)