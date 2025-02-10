library(shiny)
library(shinythemes)
library(rmarkdown)
library(markdown)
library(bslib)
library(bsicons)

# Define the folder where ISMS documents are stored
docs_folder <- normalizePath("documents", mustWork = TRUE)

# Ensure the folder exists
if (!dir.exists(docs_folder)) {
  dir.create(docs_folder)
}

# UI
ui <- page_navbar(
  theme = bs_theme(bootswatch = "flatly"),  # Default theme
  title = "ISMS Document Manager",
  window_title = "ISMS Document Manager",
  h3("Edit Document"),
  textAreaInput("doc_content", "Edit the document:", value = "", rows = 10, width = "100%"),
  h3("Rendered Preview"),
  card(uiOutput("rendered_doc")),
  verbatimTextOutput("save_status"),
  
  sidebar=sidebar(
    h4("Select a Document"),
    selectInput("selected_doc", "Choose a document:", 
                choices = list.files(docs_folder, pattern = "\\.(Rmd|md|txt)$", full.names = FALSE)),
    actionButton("load_doc", "Load Document"),
    hr(),
    actionButton("save_doc", "Save Changes", class = "btn-primary"),
    hr(),
    h4("Export / Print"),
    downloadButton("export_pdf", "Download PDF"),
    downloadButton("export_html", "Download HTML"),
    downloadButton("export_docx", "Download Word"),
    actionButton("print_doc", "Print Document", class = "btn-secondary"),
    # theme picker
    selectInput("theme", "Select Theme", 
                choices = c("Flatly", "Minty", "Darkly", "Cyborg", "Journal", "Litera", "Lux", "Materia", "Pulse", "Sandstone", "Simplex", "Sketchy", "Slate", "Solar", "Spacelab", "Superhero", "United", "Yeti")),
    
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive value to store document content
  doc_content <- reactiveVal("")
  
  # Load selected document
  observeEvent(input$load_doc, {
    req(input$selected_doc)  
    file_path <- file.path(docs_folder, input$selected_doc)
    
    if (file.exists(file_path)) {
      ext <- tools::file_ext(file_path)
      
      # Read file content
      file_content <- readLines(file_path, warn = FALSE)
      
      # Store content in reactive value
      doc_content(paste(file_content, collapse = "\n"))
      
      # Update text editor with file content
      updateTextAreaInput(session, "doc_content", value = doc_content())
    } else {
      doc_content("File not found.")
    }
  })
  
  # Live-render Markdown content
  output$rendered_doc <- renderUI({
    ext <- tools::file_ext(input$selected_doc)
    
    if (ext %in% c("md", "Rmd")) {
      HTML(markdownToHTML(text = input$doc_content, options = "fragment_only"))
    } else {
      HTML("<p><i>Rendering is only available for Markdown files.</i></p>")
    }
  })
  
  # Save document changes
  observeEvent(input$save_doc, {
    req(input$selected_doc)  
    file_path <- file.path(docs_folder, input$selected_doc)
    
    writeLines(input$doc_content, file_path)  
    output$save_status <- renderText("Document saved successfully!")
  })
  
  # Export document as PDF
  output$export_pdf <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$selected_doc), ".pdf")
    },
    content = function(file) {
      temp_file <- tempfile(fileext = ".Rmd")
      writeLines(input$doc_content, temp_file)
      rmarkdown::render(temp_file, output_format = "pdf_document", output_file = file, quiet = TRUE)
    }
  )
  
  # Export document as HTML
  output$export_html <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$selected_doc), ".html")
    },
    content = function(file) {
      temp_file <- tempfile(fileext = ".Rmd")
      writeLines(input$doc_content, temp_file)
      rmarkdown::render(temp_file, output_format = "html_document", output_file = file, quiet = TRUE)
    }
  )
  
  # Export document as Word (docx)
  output$export_docx <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$selected_doc), ".docx")
    },
    content = function(file) {
      temp_file <- tempfile(fileext = ".Rmd")
      writeLines(input$doc_content, temp_file)
      rmarkdown::render(temp_file, output_format = "word_document", output_file = file, quiet = TRUE)
    }
  )
  
  # Print document (opens print dialog)
  observeEvent(input$print_doc, {
    showModal(modalDialog(
      title = "Print Document",
      HTML(markdownToHTML(text = input$doc_content, options = "fragment_only")),
      footer = modalButton("Close"),
      easyClose = TRUE
    ))
  })
  
  observe({
    theme <- input$theme
    bs_theme <- bs_theme(bootswatch = tolower(theme))
    session$setCurrentTheme(bs_theme)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
