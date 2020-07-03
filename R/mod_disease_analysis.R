#' disease_analysis UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_disease_analysis_ui <- function(id){
  ns <- NS(id)
  tagList(
    tags$div(selectInput(ns("analyse_method"), label = "Type of analysis",
                         choices = c("Disease analysis", "Gene Ontology analysis", "KEGG analysis"))
    ),
    htmlOutput(ns("enrich_type")),
    htmlOutput(ns("enrich_repo")),
    htmlOutput(ns("para"))
    )
}
    
#' disease_analysis Server Function
#'
#' @noRd 
mod_disease_analysis_server <- function(input, output, session, con){
  ns <- session$ns
  
  disease_analysis_module <- reactiveValues()
  
  observeEvent(input$analyse_method, {
    if (input$analyse_method == "Disease analysis"){
      output$enrich_type <- renderUI({
        tags$div(selectInput(ns("enrich_type1"), label = "Type of enrichment",
                             choices = c("Over-representation test", "Gene Set Enrichment Analysis"))
        )
      })
      
      output$enrich_repo <- renderUI({
        tags$div(selectInput(ns("enrich_repo1"), label = "Type of repository",
                             choices = c("DGN", "DO", "NCG"))
        )
      })
      
      observeEvent(c(input$enrich_type1, input$enrich_repo1), {
        if (input$enrich_type1 == "Over-representation test" & input$enrich_repo1 == "DGN" ){
          output$para <- renderUI({
            mod_enrichDGN_ui(ns("enrichDGN_ui_1"))})
          enrichDGN_ui_1 <- callModule(mod_enrichDGN_server, "enrichDGN_ui_1", con = con)
          observeEvent(enrichDGN_ui_1$enrich, {
            disease_analysis_module$enrich <- enrichDGN_ui_1$enrich 
            })
        }
        if (input$enrich_type1 == "Over-representation test" & input$enrich_repo1 == "DO" ){
          output$para <- renderUI({
            mod_enrichDO_ui(ns("enrichDO_ui_1"))})
          enrichDO_ui_1 <- callModule(mod_enrichDO_server, "enrichDO_ui_1", con = con)
          observeEvent(enrichDO_ui_1$enrich, {
            disease_analysis_module$enrich <- enrichDO_ui_1$enrich
            })
        }
        if (input$enrich_type1 == "Over-representation test" & input$enrich_repo1 == "NCG" ){
          output$para <- renderUI({
            mod_enrichNCG_ui(ns("enrichNCG_ui_1"))})
          enrichNCG_ui_1 <- callModule(mod_enrichNCG_server, "enrichNCG_ui_1", con = con)
          observeEvent(enrichNCG_ui_1$enrich, {
            disease_analysis_module$enrich <- enrichNCG_ui_1$enrich 
           })
        }
        if (input$enrich_type1 == "Gene Set Enrichment Analysis" & input$enrich_repo1 == "DGN" ){
          output$para <- renderUI({
            mod_gseDGN_ui(ns("gseDGN_ui_1"))})
          gseDGN_ui_1 <- callModule(mod_gseDGN_server, "gseDGN_ui_1", con = con)
          observeEvent(gseDGN_ui_1$enrich, {
            disease_analysis_module$enrich <- gseDGN_ui_1$enrich
            })
        }
        if (input$enrich_type1 == "Gene Set Enrichment Analysis" & input$enrich_repo1 == "DO" ){
          output$para <- renderUI({
            mod_gseDO_ui(ns("gseDO_ui_1"))})
          gseDO_ui_1 <- callModule(mod_gseDO_server, "gseDO_ui_1", con = con)
          observeEvent(gseDO_ui_1$enrich, {
            disease_analysis_module$enrich <- gseDO_ui_1$enrich
            })
        }
        if (input$enrich_type1 == "Gene Set Enrichment Analysis" & input$enrich_repo1 == "NCG" ){
          output$para <- renderUI({
            mod_gseNCG_ui(ns("gseNCG_ui_1"))})
          gseNCG_ui_1 <- callModule(mod_gseNCG_server, "gseNCG_ui_1", con = con)
          observeEvent(gseNCG_ui_1$enrich, {
            disease_analysis_module$enrich <- gseNCG_ui_1$enrich
            })
        }
      })
    }
    
    if (input$analyse_method == "Gene Ontology analysis"){
      output$enrich_type <- renderUI({
        tags$div(selectInput(ns("enrich_type1"), label = "Type of enrichment",
                             choices = c("GO over-representation test", "GO Gene Set Enrichment Analysis", "GO classification"))
        )
      })
      
      output$enrich_repo <- renderUI({})
      
      observeEvent(c(input$enrich_type1), {
        if (input$enrich_type1 == "GO over-representation test"){
          output$para <- renderUI({
            mod_enrichGO_ui(ns("enrichGO_ui_1"))})
          enrichGO_ui_1 <- callModule(mod_enrichGO_server, "enrichGO_ui_1", con = con)
          observeEvent(enrichGO_ui_1$enrich, {
            disease_analysis_module$enrich <- enrichGO_ui_1$enrich
            })
        }
        if (input$enrich_type1 == "GO Gene Set Enrichment Analysis"){
          output$para <- renderUI({
            mod_gseGO_ui(ns("gseGO_ui_1"))})
          gseGO_ui_1 <- callModule(mod_gseGO_server, "gseGO_ui_1", con = con)
          observeEvent(gseGO_ui_1$enrich, {
            disease_analysis_module$enrich <- gseGO_ui_1$enrich
            })
        }
        if (input$enrich_type1 == "GO classification"){
          output$para <- renderUI({
            mod_groupGO_ui(ns("groupGO_ui_1"))})
          groupGO_ui_1 <- callModule(mod_groupGO_server, "groupGO_ui_1", con = con)
          observeEvent(groupGO_ui_1$enrich, {
            disease_analysis_module$enrich <- groupGO_ui_1$enrich
            })
        }
      })
    }
    
    if (input$analyse_method == "KEGG analysis"){
      output$enrich_type <- renderUI({
        tags$div(selectInput(ns("enrich_type1"), label = "Type of enrichment",
                             choices = c("Over-representation test", "Gene Set Enrichment Analysis"))
        )
      })
      
      output$enrich_repo <- renderUI({
        tags$div(selectInput(ns("enrich_repo1"), label = "Type of repository",
                             choices = c("KEGG", "MKEGG"))
        )
      })
      
      observeEvent(c(input$enrich_type1, input$enrich_repo1), {
        if (input$enrich_type1 == "Over-representation test" & input$enrich_repo1 == "KEGG"){
          output$para <- renderUI({
            mod_enrichKEGG_ui(ns("enrichKEGG_ui_1"))})
          enrichKEGG_ui_1 <- callModule(mod_enrichKEGG_server, "enrichKEGG_ui_1", con = con)
          observeEvent(enrichKEGG_ui_1$enrich, {
            disease_analysis_module$enrich <- enrichKEGG_ui_1$enrich
          })
        }
        if (input$enrich_type1 == "Gene Set Enrichment Analysis" & input$enrich_repo1 == "KEGG"){
          output$para <- renderUI({
            mod_gseKEGG_ui(ns("gseKEGG_ui_1"))})
          gseKEGG_ui_1 <- callModule(mod_gseKEGG_server, "gseKEGG_ui_1", con = con)
          observeEvent(gseKEGG_ui_1$enrich, {
            disease_analysis_module$enrich <- gseKEGG_ui_1$enrich
            })
        }
        if (input$enrich_type1 == "Over-representation test" & input$enrich_repo1 == "MKEGG"){
          output$para <- renderUI({
            mod_enrichMKEGG_ui(ns("enrichMKEGG_ui_1"))})
          enrichMKEGG_ui_1 <- callModule(mod_enrichMKEGG_server, "enrichMKEGG_ui_1", con = con)
          observeEvent(enrichMKEGG_ui_1$enrich, {
            disease_analysis_module$enrich <- enrichMKEGG_ui_1$enrich
            })
        }
        if (input$enrich_type1 == "Gene Set Enrichment Analysis" & input$enrich_repo1 == "MKEGG"){
          output$para <- renderUI({
            mod_gseMKEGG_ui(ns("gseMKEGG_ui_1"))})
          gseMKEGG_ui_1 <- callModule(mod_gseMKEGG_server, "gseMKEGG_ui_1", con = con)
          observeEvent(gseMKEGG_ui_1$enrich, {
            disease_analysis_module$enrich <- gseMKEGG_ui_1$enrich
            })
        }
      })
    }
  }
  )
  return(disease_analysis_module)
}
    
## To be copied in the UI
# mod_disease_analysis_ui("disease_analysis_ui_1")
    
## To be copied in the server
# callModule(mod_disease_analysis_server, "disease_analysis_ui_1")
 