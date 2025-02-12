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
  fab_position = "top-right",
  page_navbar(
    theme = bs_theme(bootswatch = "flatly"),  # Default theme
    title = "ISMS Document Manager",
    window_title = "ISMS Document Manager",
    
    nav_panel(
      "Editor",
      h5("Document Editor"),
      textAreaInput("doc_content", "Edit the document:", value = "", rows = 10, width = "100%"),
      h5("Rendered Preview"),
      card(
        full_screen = TRUE,
        uiOutput("rendered_doc")
        )
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
                  selected = "Flatly")
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
  # output$rendered_doc <- renderUI({
  #   req(input$selected_doc)
  #   ext <- tools::file_ext(input$selected_doc)
  #   
  #   if (ext %in% c("md", "Rmd")) {
  #     temp_file <- tempfile(fileext = paste0(".", ext))
  #     
  #     # Add YAML Metadata (Enable Floating TOC)
  #     yaml_metadata <- paste0(
  #       "---\n",
  #       "title: \"", input$selected_doc, "\"\n",  # Set a valid title dynamically
  #       "output:\n",
  #       "  html_document:\n",
  #       "    toc: true\n",
  #       "    toc_float: false\n",
  #       "    toc_depth: 3\n",
  #       "    number_sections: false\n",
  #       "---\n"
  #     )
  #     
  #     # Write Metadata + Document Content to Temp File
  #     writeLines(c(yaml_metadata, doc_content()), temp_file)
  #     
  #     # Render Markdown to a Temporary HTML File
  #     rendered_html <- tempfile(fileext = ".html")
  #     rmarkdown::render(temp_file, output_format = "html_document", output_file = rendered_html, quiet = TRUE)
  #     
  #     # Read the entire HTML content
  #     html_content <- readLines(rendered_html, warn = FALSE)
  #     
  #     # Find relevant parts of the HTML
  #     start_html <- grep("<html", html_content)
  #     end_html <- grep("</html>", html_content)
  #     
  #     # Extract the entire document (to keep JavaScript & TOC styles)
  #     if (length(start_html) > 0 && length(end_html) > 0) {
  #       clean_html <- paste(html_content[start_html:end_html], collapse = "\n")
  #     } else {
  #       clean_html <- paste(html_content, collapse = "\n")  # Fallback if extraction fails
  #     }
  #     
  #     HTML(clean_html)  # Render full HTML to ensure floating TOC works
  #   } else {
  #     HTML("<p><i>Rendering is only available for Markdown files.</i></p>")
  #   }
  # })
  output$rendered_doc <- renderUI({
    req(input$selected_doc)
    ext <- tools::file_ext(input$selected_doc)
    
    if (ext %in% c("md", "Rmd")) {
      temp_file <- tempfile(fileext = paste0(".", ext))
      
      # YAML Metadata (Enable TOC)
      yaml_metadata <- "---\ntitle: 't'\noutput:\n  html_document:\n    toc: true\n    toc_depth: 3\n    number_sections: false\n---\n"
      
      # Write Metadata + Document Content to Temp File
      writeLines(c(yaml_metadata, doc_content()), temp_file)
      
      # Render Markdown to a Temporary HTML File
      rendered_html <- tempfile(fileext = ".html")
      rmarkdown::render(temp_file, output_format = "html_document", output_file = rendered_html, quiet = TRUE)
      
      # Read rendered HTML content
      html_content <- readLines(rendered_html, warn = FALSE)
      
      # Extract TOC & Document Content (Avoid Full Page Styling)
      start_body <- grep("<body>", html_content)
      end_body <- grep("</body>", html_content)
      
      if (length(start_body) > 0 && length(end_body) > 0) {
        body_content <- html_content[(start_body+1):(end_body-1)]
        
        # ✅ Ensure TOC links correctly reference section IDs
        # This preserves the default IDs and prevents breaking navigation
        body_content <- gsub("id=\"(.*)\"", "id=\"\\1\" name=\"\\1\"", body_content)
        
        # Remove the auto-generated title
        body_content <- gsub("<h1[^>]*>.*?</h1>", "", body_content)
        
        # Wrap in a div to ensure proper layout
        clean_html <- paste(c(
          "<div style='max-width: 1200px; margin: auto;'>",  # Keep layout neat
          body_content,  # Includes TOC + document content
          "<script>document.addEventListener('DOMContentLoaded', function() {document.querySelectorAll('a[href^=\"#\"]').forEach(anchor => {anchor.addEventListener('click', function(e) {e.preventDefault();document.querySelector(this.getAttribute('href')).scrollIntoView({ behavior: 'smooth' }); });});});</script>",  # Fix scrolling
          "</div>"
        ), collapse = "\n")
      } else {
        clean_html <- paste(html_content, collapse = "\n")  # Fallback if extraction fails
      }
      
      HTML(clean_html)  # Render only TOC + Content, no title
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
      easyClose = TRUE,
      size = "xl"
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
