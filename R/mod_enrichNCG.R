#' enrichNCG UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_enrichNCG_ui <- function(id){
  ns <- NS(id)
  tagList(
    #Description of the method "Enrichment analysis based on the Network of Cancer Genes database"
    uiOutput(ns("module_input")),
    
    tags$a(class="collapsible", "Advanced settings", class = "btn btn-primary btn-block", "data-toggle" = 'collapse', "data-target" = '#advanced_enrich',"aria-expanded" = 'false', tags$div(class= "expand_caret caret")),
    tags$br(),
    tags$div(id = "advanced_enrich", class = "collapse",
             tags$div(
    sliderInput(ns("pvalueCutoff"), label = "P-value cut-off", min = 0, max = 1, value = 0.05, popup = "Rejecting the null hypothesis for any result with an equal or smaller value"),
    sliderInput(ns("qvalueCutoff"), label = "Q-value cut-off", min = 0, max = 1, value = 0.05, popup = "Rejecting the null hypothesis for any result with an equal or smaller value. Q-values are false discovery rate (FDR) adjusted p-values"),
    selectInput(ns("pAdjustMethod"), "Select an adjustment method",
                choices = c("holm",
                            "hochberg",
                            "hommel",
                            "bonferroni",
                            "BH",
                            "BY",
                            "fdr",
                            "none"), popup = "Correction methods used to control p-values and q-values",
                multiple = FALSE,
                selectize = TRUE),
    sliderInput(ns("mingssize"), label = "Minimum size of each gene set", min = 0, max = 100, value = 10, popup = "Minimum size of each gene set used for analyzing"),
    sliderInput(ns("maxgssize"), label = "Maximal size of each gene set", min = 0,  max = 5000, value = 500, popup = "Maximum size of each gene set used for analyzing"),
             )),
    
    tags$div(style = "text-align:center",
            actionButton(ns("load_input"), label = "Enrich", onclick="loading_modal_open(); stopWatch();"),
            htmlOutput(ns("close_loading_modal")),  # Close modal with JS 
            htmlOutput((ns("adv_settings")))
    )
  )
}

#' enrichNCG Server Function
#'
#' @noRd 
# con should ne somewhere in the code?
mod_enrichNCG_server <- function(input, output, session, con, Description1_ui_1, module_overview_ui_1){
  ns <- session$ns
  
  enrichNCG_module <- reactiveValues()
  x <- reactiveVal(1) # Reactive value to record if the input button is pressed
  
  
  output$module_input <- renderUI({
    module_objects <- unlist(MODifieRDB::get_available_module_objects(con)$module_name)
    tagList(
      selectInput(ns("module_object"), label = "Module object", choices = module_objects, popup = "The module used for enrichment analysis."),
      tags$div(id = "error_name_gseKEGG_js",
              textInput(ns("enrichment_name"), "Module object name", popup = "Object that is produced by the enrichment methods.", placeholder = "Enrichment name")),
      uiOutput(ns("error_name_descrip")),
      uiOutput(ns("error_name_js")),
      uiOutput(ns("error"))
    )
  })
  
  observeEvent(c(Description1_ui_1$infer, module_overview_ui_1$value$delete, module_overview_ui_1$value$upload), {
    module_objects <- unlist(MODifieRDB::get_available_module_objects(con)$module_name)
    updateSelectInput(session, "module_object", choices = module_objects)
  })
  
  enrichment_name <- reactive({
    input$enrichment_name
  })
  
  # Check name
  observe({
    if (any(MODifieRDB::get_available_enrichment_objects(con)$enrichment_name == enrichment_name())){
      output$error_name_js <- renderUI({
        tags$script(HTML("element = document.getElementById('error_name_enrichNCG_js');
                       element.classList.add('has-error');
                       document.getElementById('main_page_v2_ui_1-Columns_ui_1-disease_analysis_ui_1-enrichNCG_ui_1-load_input').disabled = true;"))
      })
      output$error_name_descrip <- renderUI({
        tags$p(class = "text-danger", tags$b("Error:"), "This name has been taken. Please try again!",
               style = "-webkit-animation: fadein 0.5s; -moz-animation: fadein 0.5s; -ms-animation: fadein 0.5s;-o-animation: fadein 0.5s; animation: fadein 0.5s;")
      })
    } else {
      output$error_name_js <- renderUI({
        tags$script(HTML("document.getElementById('error_name_enrichNCG_js').classList.remove('has-error');
                         document.getElementById('main_page_v2_ui_1-Columns_ui_1-disease_analysis_ui_1-enrichNCG_ui_1-load_input').disabled = false;"))
      })
      output$error_name_descrip <- NULL
    }
  })
  
  observeEvent(input$load_input, {
    id <- showNotification("Identifying disease assosciation and creating enrichment analysis object", duration = NULL, closeButton = FALSE, type = "warning")
    on.exit(removeNotification(id), add = TRUE)
    
    output$error <- renderUI({})
    output$adv_settings <- renderUI({})
    
    module_genes <- try(get_module_genes(input$module_object, con = con))
    background_genes <- try(get_background_genes(input$module_object, con = con))
    
    enrichment_object <- try(DOSE::enrichNCG(gene = module_genes,
                                               pvalueCutoff = input$pvalueCutoff,
                                               pAdjustMethod = input$pAdjustMethod,
                                               universe = background_genes,
                                               minGSSize = input$mingssize,
                                               maxGSSize = input$maxgssize,
                                               qvalueCutoff = input$qvalueCutoff,
                                               readable = FALSE
                                               
    )
    )
    if (any(c(class(enrichment_object), class(background_genes), class(module_genes)) == "try-error")){
      output$adv_settings <- renderUI({
        tags$script("if ($('.collapsible.btn.btn-primary.btn-block').eq(1).attr('aria-expanded') === 'false') {
                            $('.collapsible.btn.btn-primary.btn-block').eq(1).click();
                    }")
      })
      output$error_p_value <- renderUI({
        tags$p(class = "text-danger", tags$b("Error:"), enrichment_object,
               style = "-webkit-animation: fadein 0.5s; -moz-animation: fadein 0.5s; -ms-animation: fadein 0.5s;-o-animation: fadein 0.5s; animation: fadein 0.5s;")
      })
    } else {
      x(x() + 1)
      enrichNCG_module$enrich <- c(x(), "enrichNCG")  # Reactive value to record if the input button is pressed
      module_name <- input$module_object
      MODifieRDB::enrichment_object_to_db(enrichment_object,
                                          module_name = module_name, 
                                          enrichment_method = "enrichNCG", 
                                          enrichment_name = input$enrichment_name,
                                          con = con)
      updateTextInput(session, "enrichment_name", value = character(0))
    }
    # Close loading modal
    output$close_loading_modal <- renderUI({
      tags$script("loading_modal_close(); reset();")
    })
  })
  return(enrichNCG_module)
}


## To be copied in the UI
# mod_enrichNCG_ui("enrichNCG_ui_1")

## To be copied in the server
# callModule(mod_enrichNCG_server, "enrich_ui_1")