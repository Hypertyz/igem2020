#' dot_plot_para UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_dot_plot_para_ui <- function(id){
  ns <- NS(id)
  tagList(
      #Parameters
      tags$h3(class = "text-center",
              "Parameters"),
      #Dot plot
      selectInput(ns("xaxis"),
                  label = "X-axis",
                  choices = c("GeneRatio", "Count")),
      selectInput(ns("color"),
                  label = "Color",
                  choices = c("pvalue", "p.adjust", "qvalue")),
      sliderInput(ns("showcategory"), 
                  label = "Number of enriched terms to display",
                  min = 5,
                  max = 50,
                  value = 10),
      textInput(ns("title"), 
                label = "Title")
    
)
}
    
#' dot_plot_para Server Function
#'
#' @noRd 
mod_dot_plot_para_server <- function(input, output, session){
  ns <- session$ns
  dot_plot_para_module <- reactiveValues()
  observe({
    dot_plot_para_module$xaxis <- input$xaxis
    dot_plot_para_module$color <- input$color
    dot_plot_para_module$showcategory <- input$showcategory
    dot_plot_para_module$title <- input$title
  })
  
  return(dot_plot_para_module)
}
    
## To be copied in the UI
# mod_dot_plot_para_ui("dot_plot_para_ui_1")
    
## To be copied in the server
# callModule(mod_dot_plot_para_server, "dot_plot_para_ui_1")
 