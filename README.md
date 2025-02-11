### **📌 README.md – ISMS Document Manager (Shiny App)**

# ISMS Document Manager 📄✨

## Overview
The **ISMS Document Manager** is a **secure, theme-customizable, and real-time updating** R Shiny application for managing **Information Security Management System (ISMS) documents**. It supports **Markdown (`.md`), R Markdown (`.Rmd`), and plain text (`.txt`)** files, allowing users to:
- **View, edit, and live-preview ISMS documents**
- **Export documents as PDF, HTML, and Word (`.docx`)**
- **Use authentication & role-based access (admins vs. users)**
- **Log all user activity (document edits, logins, exports)**
- **Enable live theme switching (Bootswatch themes)**
- **Get real-time notifications for actions**
- **Print documents directly from the app**

## Features 🚀
✅ **Live Editing & Preview** – Edit and preview Markdown documents in real time  
✅ **Export & Print Support** – Save documents as **PDF, HTML, or Word**  
✅ **Secure Authentication** – Uses `shinymanager` for **user login & role-based access**  
✅ **Admin Controls** – Admins can **add users** and manage **permissions**  
✅ **Activity Logging** – Tracks **logins, edits, exports**, and **admin actions**  
✅ **Customizable Themes** – Users can **switch themes live** with **Bootswatch**  
✅ **Real-time Notifications** – Uses `showNotification()` for **instant feedback**  

---

## **📥 Installation**

### **1️⃣ Prerequisites**
Ensure you have the following installed:
- **R** (≥ 4.0) – [Download here](https://cran.r-project.org/)
- **RStudio** (Recommended) – [Download here](https://posit.co/downloads/)
- **Pandoc** (for document rendering) – Included with RStudio or install from [here](https://pandoc.org/installing.html)

### **2️⃣ Install Required R Packages**
Open R or RStudio and run:
```r
install.packages(c("shiny", "shinythemes", "rmarkdown", "markdown", 
                   "bslib", "bsicons", "DBI", "RSQLite", "shinymanager"))
```

### **3️⃣ Clone the Repository**
If using Git:
```sh
git clone https://github.com/YOUR-GITHUB-USERNAME/ISMS-Document-Manager.git
cd ISMS-Document-Manager
```
Or manually **download the ZIP** and extract it.

---

## ▶️ Running the App
1. Open RStudio (or an R console)  
2. Set the working directory to the project folder:
   ```r
   setwd("path/to/ISMS-Document-Manager")
   ```
3. Launch the app using:
   ```r
   shiny::runApp()
   ```
4. The app will open in your **default web browser** 🚀  

---

## 🛠 Usage Guide
### **1️⃣ Selecting a Document**
- Choose a file from the **"Select a Document"** dropdown
- Click **"Load Document"** to populate the editor

### **2️⃣ Editing & Saving**
- Modify the text in the **editor**
- Click **"Save Changes"** to update the file

### **3️⃣ Exporting Documents**
- Click **"Download PDF"**, **"Download HTML"**, or **"Download Word"** to save the file

### **4️⃣ Printing**
- Click **"Print Document"** to open the print dialog

### **5️⃣ Changing Themes**
- Select a new **theme** from the **dropdown** to change the app’s appearance instantly  

---

## **🔐 Authentication & User Roles**
This app uses `shinymanager` for **secure authentication**.  
| Role | Permissions |
|------|------------|
| **Admin** | Can **add users, edit all documents, manage access** |
| **User** | Can **only edit & export documents** |

#### **🛠 Creating an Admin Account (First-Time Setup)**
If you're setting up the app for the first time, run:
```r
library(shinymanager)

# Define user credentials
credentials <- data.frame(
  user = c("admin", "user1"),
  password = sapply(c("admin123", "userpass"), password_store),  # Hash passwords
  admin = c(TRUE, FALSE),  # Admin role (TRUE/FALSE)
  stringsAsFactors = FALSE
)

# Save credentials in a secure database
create_db(
  credentials_data = credentials,
  sqlite_path = "credentials.sqlite"
)
```
Now log in with:
- **Admin:** `admin / admin123`
- **User:** `user1 / userpass`

---

## **🎨 Live Theme Customization**
Users can **switch themes instantly** using **Bootswatch**!  
Choose from: `Flatly`, `Minty`, `Darkly`, `Cyborg`, `Journal`, `Litera`, `Lux`, `Materia`, `Pulse`, `Sandstone`, `Simplex`, `Sketchy`, `Slate`, `Solar`, `Spacelab`, `Superhero`, `United`, `Yeti`.

---

## **📊 Activity Logging**
All user actions are logged in **`logs.sqlite`**:
- **Logins & Logouts**
- **Document Loads & Saves**
- **Exports & Prints**
- **Admin User Additions**

### **🛠 Viewing Logs**
Admins can **view logs** by running:
```r
db <- DBI::dbConnect(RSQLite::SQLite(), "logs.sqlite")
logs <- dbGetQuery(db, "SELECT * FROM logs ORDER BY timestamp DESC")
print(logs)
dbDisconnect(db)
```

---

## **🛠 Project Structure**
```
ISMS-Document-Manager/
│-- documents/           # Directory containing ISMS files (Markdown, R Markdown, TXT)
│-- app.R                # Main Shiny app script
│-- README.md            # Project documentation
│-- .gitignore           # Ignore unnecessary files (e.g., R history, temp files)
│-- credentials.sqlite   # User authentication database
│-- logs.sqlite          # Logs database (tracks activity)
│-- LICENSE              # License file (optional)
```

---

## 🤝 Contributing
We welcome contributions! Here's how you can help:
1. **Fork the repository** on GitHub
2. **Create a feature branch** (`git checkout -b feature-branch`)
3. **Commit your changes** (`git commit -m "Added new feature"`)
4. **Push to your branch** (`git push origin feature-branch`)
5. **Open a pull request** 🎉

For major changes, please open an **issue first** to discuss what you'd like to implement.

---

### 🚀 Happy Editing & Managing ISMS Policies! 🎯

---

### **💡 What’s New in This Update?**
✔ **Added Authentication & Roles Section** – Covers **admin/user permissions**  
✔ **Live Theme Customization Guide** – Explains **Bootswatch integration**  
✔ **Updated Logging Section** – Shows **how to view logs**  
✔ **Updated Installation & Setup** – Includes **database setup for first-time users**  
✔ **Clearer Project Structure** – Organized **files and folders**  

---

### **🚀 Next Steps**
1. **Add this `README.md` file to your GitHub repository**
2. **Update the repository link & email** in the README
3. **Commit & push the changes**
   ```sh
   git add README.md
   git commit -m "Updated README with authentication, logging, and theming details"
   git push origin main
   ```