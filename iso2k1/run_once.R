library(shinymanager)

# Define user credentials
credentials <- data.frame(
  user = c("isomanager", "isouser"), # mandatory
  password = c("27001", "12345"), # mandatory
  start = c("2025-02-09", "2025-02-09"),
  expire = c(NA, NA),
  admin = c(TRUE, FALSE),
  comment = "",
  stringsAsFactors = FALSE
)

# Save credentials in a secure database
create_db(
  credentials_data = credentials,
  sqlite_path = "credentials.sqlite"
)


library(DBI)
library(RSQLite)

# Connect to SQLite logs database (create if it doesn't exist)
db <- dbConnect(SQLite(), "iso2k1/logs.sqlite")

# Create logs table if not exists
dbExecute(db, "CREATE TABLE IF NOT EXISTS logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                user TEXT,
                action TEXT,
                details TEXT)")

dbDisconnect(db)

db <- dbConnect(SQLite(), "iso2k1/logs.sqlite")
logs <- dbGetQuery(db, "SELECT * FROM logs ORDER BY timestamp DESC")
print(logs)
dbDisconnect(db)
