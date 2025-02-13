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
    title = "Markdown Document Manager",
    window_title = "Markdown Document Manager",
    
    nav_panel(
      "Editor",
      textAreaInput("doc_content", "Edit the document:", value = "", rows = 10, width = "100%"),
      h6("Rendered Preview"),
      card(
        full_screen = TRUE,
        uiOutput("rendered_doc")
        )
    ),
    
    sidebar = sidebar(
      accordion(
        accordion_panel(
          title = "Select a Document",
          selectInput("selected_doc", "Choose a document:",
                      choices = list.files(docs_folder, pattern = "\\.(Rmd|md|txt)$", full.names = FALSE)),
          actionButton("load_doc", "Load Document")
          ),
        accordion_panel(
          title = "Create a New Document",
          textInput("new_file_name", "File Name (without extension):"),
          selectInput("new_file_type", "File Type:", choices = c("Markdown (.md)" = "md", "R Markdown (.Rmd)" = "Rmd", "Text File (.txt)" = "txt")),
          actionButton("create_file", "Create File", class = "btn-success")
        ),
        accordion_panel(
          title="Upload a New Document",
          fileInput("upload_file", "Choose a .Rmd file:", accept = c(".Rmd")),
          actionButton("upload_btn", "Upload", class = "btn-success"),
        )
      ),
      actionButton("save_doc", "Save Changes", class = "btn-primary"),
      hr(),
      actionButton("delete_doc", "Delete File", class = "btn-danger"),
      hr(),
      
      h4("Export / Print"),
      downloadButton("export_html", "Download HTML"),
      downloadButton("export_docx", "Download Word"),
      actionButton("print_doc", "Print Document", class = "btn-secondary"),
      
      # Theme picker
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
  
  # Handle file uploads
  observeEvent(input$upload_btn, {
    req(input$upload_file)  # Ensure a file is selected
    
    # Get file details
    temp_path <- input$upload_file$datapath
    file_name <- input$upload_file$name
    dest_path <- file.path(docs_folder, file_name)
    
    # Check if file already exists
    if (file.exists(dest_path)) {
      showNotification("File already exists! Choose a different name.", type = "error")
    } else {
      # Move uploaded file to documents folder
      file.copy(temp_path, dest_path)
      
      # Update file selector choices
      updateSelectInput(session, "selected_doc", choices = list.files(docs_folder, pattern = "\\.(Rmd|md|txt)$", full.names = FALSE))
      
      # Log action and notify user
      log_action(user_info(), "Upload File", paste("Uploaded:", file_name))
      showNotification("File uploaded successfully!", type = "message")
    }
  })
  
  # Live-render Markdown content
  output$rendered_doc <- renderUI({
    req(input$selected_doc)
    ext <- tools::file_ext(input$selected_doc)
    
    if (ext == "Rmd") {
      temp_file <- tempfile(fileext = ".Rmd")
      
      # Write the R Markdown document to a temp file
      writeLines(doc_content(), temp_file)
      
      # Render the R Markdown document to an HTML file
      rendered_html <- tempfile(fileext = ".html")
      
      rmarkdown::render(temp_file, 
                        output_format = "html_document", 
                        output_file = rendered_html, 
                        quiet = TRUE, 
                        envir = new.env(parent = globalenv()))  # Execute in a clean environment
      
      # Read rendered HTML content
      html_content <- readLines(rendered_html, warn = FALSE)
      
      # Extract TOC & Body Content (Avoid Full Page Styling)
      start_body <- grep("<body>", html_content)
      end_body <- grep("</body>", html_content)
      
      if (length(start_body) > 0 && length(end_body) > 0) {
        body_content <- html_content[(start_body+1):(end_body-1)]
        
        # Ensure TOC links work properly
        body_content <- gsub("id=\"(.*)\"", "id=\"\\1\" name=\"\\1\"", body_content)
        
        # Wrap in a div for layout consistency
        clean_html <- paste(c(
          "<div style='max-width: 1200px; margin: auto;'>",
          body_content,  
          "<script src='https://cdn.plot.ly/plotly-latest.min.js'></script>",  # Ensure Plotly works
          "</div>"
        ), collapse = "\n")
      } else {
        clean_html <- paste(html_content, collapse = "\n")  # Fallback if extraction fails
      }
      
      return(HTML(clean_html))
      
    } else if (ext == "md") {
      # Handle standard Markdown files
      return(shiny::includeMarkdown(file.path(docs_folder, input$selected_doc)))
      
    } else {
      return(HTML("<p><i>Rendering is only available for Markdown (.md) and R Markdown (.Rmd) files.</i></p>"))
    }
  })
  
  # Create a new file
  observeEvent(input$create_file, {
    req(input$new_file_name)  # Ensure file name is provided
    
    # Construct full file name with extension
    new_file_path <- file.path(docs_folder, paste0(input$new_file_name, ".", input$new_file_type))
    
    # Check if file already exists
    if (file.exists(new_file_path)) {
      showNotification("File already exists!", type = "error")
    } else {
      # Create the new file with placeholder text
      default_content <- switch(input$new_file_type,
                                "md" = "# New Markdown Document\n\nStart writing...",
                                "Rmd" = "---\ntitle: \"New R Markdown Document\"\noutput: html_document\n---\n\n# Introduction\n\nStart writing...",
                                "txt" = "New Text File\n\nStart writing...")
      
      writeLines(default_content, new_file_path)
      
      # Update file selector choices
      updateSelectInput(session, "selected_doc", choices = list.files(docs_folder, pattern = "\\.(Rmd|md|txt)$", full.names = FALSE))
      
      # Automatically select and load the new file
      updateSelectInput(session, "selected_doc", selected = basename(new_file_path))
      doc_content(default_content)
      updateTextAreaInput(session, "doc_content", value = doc_content())
      
      # Log action and notify user
      log_action(user_info(), "Create File", paste("Created:", basename(new_file_path)))
      showNotification("New file created successfully!", type = "message")
    }
  })
  
  # Show delete confirmation modal
  observeEvent(input$delete_doc, {
    req(input$selected_doc)  # Ensure a file is selected
    
    showModal(modalDialog(
      title = "Confirm File Deletion",
      p("Enter the file name to confirm deletion:"),
      textInput("confirm_delete_name", "File Name (without extension):"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_delete", "Delete", class = "btn-danger")
      ),
      easyClose = FALSE
    ))
  })
  
  # Handle file deletion
  observeEvent(input$confirm_delete, {
    req(input$selected_doc, input$confirm_delete_name)
    
    # Extract filename without extension
    selected_file <- input$selected_doc
    expected_name <- tools::file_path_sans_ext(selected_file)
    
    if (input$confirm_delete_name == expected_name) {
      file_path <- file.path(docs_folder, selected_file)
      
      if (file.exists(file_path)) {
        file.remove(file_path)
        
        # Update file selector choices
        updateSelectInput(session, "selected_doc", choices = list.files(docs_folder, pattern = "\\.(Rmd|md|txt)$", full.names = FALSE), selected = NULL)
        
        # Clear the editor
        doc_content("")
        updateTextAreaInput(session, "doc_content", value = "")
        
        # Log action and notify user
        log_action(user_info(), "Delete File", paste("Deleted:", selected_file))
        showNotification("File deleted successfully!", type = "message")
      } else {
        showNotification("File not found!", type = "error")
      }
    } else {
      showNotification("File name does not match! Deletion canceled.", type = "error")
    }
    
    removeModal()  # Close the modal
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
