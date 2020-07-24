#' enrichment_overview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_enrichment_overview_ui <- function(id){
  ns <- NS(id)
  tagList(
    DT::dataTableOutput(ns("enrichment_overview")),
    tags$div(`class`="row",
             tags$div(`class`="col-sm-10", style = "color:black",
                      fileInput(ns("enrichment_object"), label = "Upload an enrichment object", accept =  ".rds"),
                      uiOutput(ns("enrichment_name_chooser"))),
             tags$br(),
             tags$div(`class`="col-sm-2", style = "text-align:right", id ="buttons_enrichment_overview",
                      downloadButton(ns("download_enrichment"), "Download"))),
    uiOutput(ns("disable"))
  )
}

#' enrichment_overview Server Function
#'
#' @noRd 
mod_enrichment_overview_server <- function(input, output, session, con, main_page_v2_module){
  ns <- session$ns
  
  # Create a table
  enrichment_objects <- MODifieRDB::get_available_enrichment_objects(con)[c("module_name", "enrichment_method")]
  output$enrichment_overview <- DT::renderDataTable(enrichment_objects,
                                                    rownames = FALSE,
                                                    selection = list(selected = c(1)))
  
  #Reactive funciton for fileinput
  upload_enrichment <- reactive({
    req(input$enrichment_object)
    infile <- (input$enrichment_object$datapath)
    if (is.null(infile)){
      
      return(NULL)
    }
    
    readRDS(file = infile)
  })
  
  output$enrichment_name_chooser <- renderUI({
    module <- upload_enrichment() #reactive pop up
    tagList( 
      actionButton(ns("upload_enrichment"), "Add enrichment object to database")
    )
  })
  
  # Upload enrichment
  observeEvent(input$upload_enrichment, {
    id <- showNotification("Saving module object to database", duration = NULL, closeButton = FALSE, type = "warning")
    on.exit(removeNotification(id), add = TRUE)
    enrichment <- upload_enrichment()
    
    # MODifieRDB::enrichment_object_to_db(enrichment_object = enrichment,
    #                                     module_name = module_name, 
    #                                     enrichment_method = enrichment@ontology, 
    #                                     con = con)
    
    # Refresh
    enrichment_objects <- MODifieRDB::get_available_enrichment_objects(con)[c("module_name", "enrichment_method")]
    output$enrichment_overview <- DT::renderDataTable(enrichment_objects,
                                                      rownames = FALSE,
                                                      selection = list(selected = c(1)))
  })
  
  # Render DT
  observeEvent(main_page_v2_module$enrich, {
    enrichment_objects <- MODifieRDB::get_available_enrichment_objects(con)[c("module_name", "enrichment_method")]
    output$enrichment_overview <- DT::renderDataTable(enrichment_objects,
                                                      rownames = FALSE,
                                                      selection = list(selected = c(1)))
  })
  
  # Choose multiple options
  current_enrichment_objects <- function() {
    selected <- input$enrichment_overview_overview_rows_selected
  }
  
  retrieve_enrichment_object <- function(){
    selected <- input$enrichment_overview_rows_selected
    if (length(selected) > 1){
      lapply(current_enrichment_objects(), MODifieRDB::enrichment_object_from_db, con = con)
    } else {
      MODifieRDB::enrichment_object_from_db(selected, con)
    }
  }
  
  # Download function
  output$download_enrichment <- downloadHandler(
    filename = function() {
      paste0("enrichment_set_", Sys.Date(), ".rds", sep="")
    },
    content = function(file) {
      saveRDS(retrieve_enrichment_object(), file)
    }
  )
  
  # Observe if valid to download
  observe({
    if(is.null(input$enrichment_overview_rows_selected)) {
      output$disable <- renderUI({
        tags$script((HTML("document.getElementById('main_page_v2_ui_1-enrichment_overview_ui_1-download_enrichment').style.pointerEvents = 'none';
                         document.getElementById('buttons_enrichment_overview').style.cursor = 'not-allowed';")))
      }) 
    } else {
      output$disable <- renderUI({
        tags$script((HTML("document.getElementById('main_page_v2_ui_1-enrichment_overview_ui_1-download_enrichment').style.pointerEvents = 'auto';
                          document.getElementById('buttons_enrichment_overview').style.cursor = 'default';")))
      }) 
    }
  })
}


## To be copied in the UI
# mod_enrichment_overview_ui("enrichment_overview_ui_1")

## To be copied in the server
# callModule(mod_enrichment_overview_server, "enrichment_overview_ui_1")
