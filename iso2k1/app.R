library(shiny)
library(shinymanager)
library(shinythemes)
library(rmarkdown)
library(markdown)
library(bslib)
library(bsicons)
library(DBI)
library(RSQLite)

# Define the folder where ISMS documents are stored
docs_folder <- normalizePath("documents", mustWork = TRUE)
if (!dir.exists(docs_folder)) {
  dir.create(docs_folder)
}

# Load user credentials from the SQLite database
db_path <- "credentials.sqlite"
log_db_path <- "logs.sqlite"  # Logging database

# Function to log user actions
log_action <- function(user, action, details = "") {
  db <- dbConnect(SQLite(), log_db_path)
  dbExecute(db, "CREATE TABLE IF NOT EXISTS logs (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  timestamp TEXT,
                  user TEXT,
                  action TEXT,
                  details TEXT)")
  dbExecute(db, "INSERT INTO logs (timestamp, user, action, details) VALUES (datetime('now'), ?, ?, ?)",
            params = list(user, action, details))
  dbDisconnect(db)
}

# UI
ui <- secure_app(
  enable_admin = TRUE,
  page_navbar(
    theme = bs_theme(bootswatch = "flatly"),  # Default theme
    title = "ISMS Document Manager",
    window_title = "ISMS Document Manager",
    
    nav_panel(
      "Editor",
      h5("Document Editor"),
      textAreaInput("doc_content", "Edit the document:", value = "", rows = 10, width = "100%"),
      h5("Rendered Preview"),
      card(uiOutput("rendered_doc"))
    ),
    
    sidebar = sidebar(
      h4("Select a Document"),
      selectInput("selected_doc", "Choose a document:",
                  choices = list.files(docs_folder, pattern = "\\.(Rmd|md|txt)$", full.names = FALSE)),
      actionButton("load_doc", "Load Document"),
      hr(),
      actionButton("save_doc", "Save Changes", class = "btn-primary"),
      hr(),
      h4("Export / Print"),
      downloadButton("export_html", "Download HTML"),
      downloadButton("export_docx", "Download Word"),
      actionButton("print_doc", "Print Document", class = "btn-secondary"),
      # theme picker
      selectInput("theme", "Select Theme", 
                  choices = c("Flatly", "Minty", "Darkly", "Cyborg", "Journal", "Litera", "Lux", "Materia", "Pulse", "Sandstone", "Simplex", "Sketchy", "Slate", "Solar", "Spacelab", "Superhero", "United", "Yeti"),
                  selected = "Flatly"),
      
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Set up authentication system
  res_auth <- secure_server(
    check_credentials = check_credentials(db_path, passphrase = NULL)
  )
  
  user_info <- reactive({ res_auth$user })
  
  output$is_admin <- reactive({ res_auth$admin })
  outputOptions(output, "is_admin", suspendWhenHidden = FALSE)
  
  observe({
    req(user_info())
    log_action(user_info(), "Login", "User logged in")
  })
  
  # Reactive value to store document content
  doc_content <- reactiveVal("")  # Initialize with an empty string
  
  # Load selected document
  observeEvent(input$load_doc, {
    req(input$selected_doc)
    file_path <- file.path(docs_folder, input$selected_doc)
    
    if (file.exists(file_path)) {
      file_content <- readLines(file_path, warn = FALSE)
      doc_content(paste(file_content, collapse = "\n"))  # Update doc_content reactively
      
      # Update text area to reflect new document content
      updateTextAreaInput(session, "doc_content", value = doc_content())
      
      log_action(user_info(), "Load Document", paste("Opened:", input$selected_doc))
      showNotification(paste("Loaded:", input$selected_doc), type = "message")
    } else {
      showNotification("File not found!", type = "error")
    }
  })
  
  # Observe changes in the text area and update doc_content reactively
  observe({
    req(input$doc_content)  # Ensure input is not NULL
    doc_content(input$doc_content)  # Update reactive content
  })
  
  # Live-render Markdown content
  output$rendered_doc <- renderUI({
    req(input$selected_doc)
    ext <- tools::file_ext(input$selected_doc)
    
    if (ext %in% c("md", "Rmd")) {
      HTML(markdownToHTML(text = doc_content(), options = "fragment_only"))  # Reactively updates live
    } else {
      HTML("<p><i>Rendering is only available for Markdown files.</i></p>")
    }
  })
  
  # Save document changes
  observeEvent(input$save_doc, {
    req(input$selected_doc)
    file_path <- file.path(docs_folder, input$selected_doc)
    writeLines(input$doc_content, file_path)
    
    log_action(user_info(), "Save Document", paste("Edited:", input$selected_doc))
    showNotification("Document saved successfully!", type = "message")
  })
  
  # Export document as HTML
  output$export_html <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$selected_doc), ".html")
    },
    content = function(file) {
      temp_file <- tempfile(fileext = ".Rmd")
      writeLines(input$doc_content, temp_file)
      rmarkdown::render(temp_file, output_format = "html_document", output_file = file, quiet = TRUE)
      showNotification("Exported HTML successfully!", type = "message")
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
      showNotification("Exported Word document successfully!", type = "message")
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
    req(input$theme)  # Ensure theme input is not NULL
    selected_theme <- tolower(input$theme)  # Convert to lowercase
    
    # Apply the new theme
    session$setCurrentTheme(bs_theme(bootswatch = selected_theme))
  })
}

# Run the application
shinyApp(ui = ui, server = server)
