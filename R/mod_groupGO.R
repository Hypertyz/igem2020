#' GO UI Function 
#' 
#' @description A shiny Module.
#' 
#' @param id,input,output,session Internal parameters for {shiny}.
#' 
#' @noRd
#' 
#' @importFrom shiny NS tagList
mod_groupGO_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(
      ns("module_input")),
    selectInput(
      ns("keytype"), 
      label = "Select the type of gene input", 
      choices = c(keytypes(org.Hs.eg.db::org.Hs.eg.db)),
      popup = "Select the type of the input data"
    ),
    selectInput(
      ns("ont"),
      label = "Select subontologies", 
      choices= c("BP", "MF", "CC"),
      popup = "Either biological process (BP), cellular component (CC) or molecular function (MF)."
    ),
    sliderInput(
      ns("level"),
      label = "Select specific GO Level", 
      min = 1, 
      max = 5, 
      value = 2, 
      popup = "Select the level that should return the GO profile"
    ),
    prettySwitch(
      ns("readable"), 
      label = "Readable",
      value = FALSE, 
      status = "warning",
      popup = "Whether the gene IDs will mapping to gene symbols"
    ),
    
    tags$div( style = "text-align:center",
              actionButton(ns("load_input"), label = "Group") 
    )
  )
}

#' GO Server Function 
#' 
#' @noRd
mod_groupGO_server <- function(input, output, session, con){
  ns <- session$ns
  
  output$module_input <- renderUI({
    module_objects <- unlist(MODifieRDB::get_available_module_objects(con)$module_name)
    selectInput(ns("module_object"), label = "Module object", choices = module_objects, 
                popup = "The module used for gene set enrichment analysis.")
  })
  
  observeEvent(input$load_input, {
    id <- showNotification("Creating enrichment analysis object", duration = NULL, closeButton = FALSE, type = "warning")
    on.exit(removeNotification(id), add = TRUE)
    
    module_genes <- get_module_genes(input$module_object, con = con)
    background_genes <- get_background_genes(input$module_object, con = con)
    
    group_object <- try(clusterProfiler::groupGO(gene = module_genes,
                                                 OrgDb = 'org.Hs.eg.db',
                                                 keyType = input$keytype, 
                                                 ont = input$ont, 
                                                 level = input$level, 
                                                 readable = input$readable
  ))
    
    if (class(group_object) == "try-error"){
      output$error_p_value <- renderUI({
        tags$p(class = "text-danger", tags$b("Error:"), group_object)
      })
    }
  })
}

## To be copies in the UI 
# mod_groupGO_ui("groupGO_ui_1")

## To be copied in the server
# callModule(mod_groupGO_server, "groupGO_ui_1")
                                              
                                                       
                                                       
                                                       
    
    
    