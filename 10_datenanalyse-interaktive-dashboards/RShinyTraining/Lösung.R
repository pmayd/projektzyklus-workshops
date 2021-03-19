# INTERAKTIVE VISUALISIERUNGEN MIT (R) SHINY

### Dieses Codescript hilft Euch Eure erste Shiny Web-Applikation zu bauen. 
### Ihr könnt den Code ausführen, indem Ihr oben rechts "Run App" anklickt.
### Mehr Informationen findet Ihr unter: http://shiny.rstudio.com/
### Hilfe zu Funktionen findet Ihr über help(Funktion) oder ?Funktion

############################################

# 1) RELEVANTE PACKAGES INSTALLIEREN
### Sog. Packages (zu dt. Pakete) enthalten alle wichtigen Funktionalitäten, die Ihr braucht.
### So müsst Ihr beispielsweise die Formel des Mittelwerts nicht selbst definieren.
### Ihr könnte einfach die Funktion mean() nutzen.
### Packages werden über den Befehl "install.packages("Package-Name") installiert.
### Los geht es: Löscht die Anführungszeichen vor und hinter den Codesegment, das mit "install.packages..." anfängt.
### Markiert das Codesegment und führt es mit CTRL + Enter aus.
### Hinweis: Folgt unten in der Console der Ausführung des Codes und bestätigt die Installation von Abhängigkeiten ggf. mit "Yes".

##### Übung 1: Lösche die Anführungszeichen vor und hinter diesem Codesegment und führe es aus. 
##### Tipp: Code kann wie in Word markiert und dann mit CTRL + ENTER ausgeführt werden.

"
install.packages(c(
  'shiny', 
  'ggplot2', 
  'tidyr',
  'dplyr',
  'plotly',
  'DT',
  'here',
  'ShinyFiles'
))
"

############################################

# 2) RELEVANTE PACKAGES LADEN
### Die installierten Packages müsst Ihr laden. Erst so werden die Funktionalitäten zugänglich.
### Dazu nutzt Ihr den Befehl "library(Package-Name)" - ohne Anführungszeichen!
### Hinweis: Ihr könnt auch ohne library arbeiten. Mit der Notation package::funktion() greift Ihr direkt auf die Funktionen zu.

library(shiny) # Das RShiny Package.
library(dplyr) # Das dplyr Package, mit dem wir tolle Datenbereinigungen vornehmen können.
library(ggplot2) # Das ggplot Package, mit dem wir die Daten visualisieren können.
library(knitr)

##### Übung 2: Lade nun auch das Package "tidyr".
library(tidyr)

############################################

# 3) DATEN LADEN
### Euer Script sucht - genau wie Ihr es tun würdet - die genutzten Daten.
### Sogenannte "Paths" (zu dt. Wege) geben an, wo lokale Dokumente abliegen. 
### Dabei werden die verschiedenen Ordner mit "/" getrennt und der gesamte Path in Anführungszeichen gesetzt.
### Als absolute Paths bezeichnet man die Option, den gesamten Path vorzugeben, also eine Reise von Berlin nach München mit allen Zwischenstationen zu definieren.
### Relative Paths starten bei einem gesetzten Startpunkt, wo z.B. Euer Script liegt. Damit können Scripte leichter geteilt werden.
### Die Idee ist: Wenn Ihr erst in Dresden losfahrt, dann braucht Ihr auch erst ab die Fahrstrecke. 
### So müssen Eure Kolleg:innen nicht erstmal den Path anpassen, wenn sie Euer Script auf ihrem PC ausführen möchten.
### Hinweis: In R gibts dafür für neue Projekte einen tollen Trick - Nutzt RProjects und schiebt alle Eure Dokumente in den entsprechenden Ordner (https://rstats.wtf/project-oriented-workflow.html) 
### Alle Pfade beginnen dann in Eurem RProject-Ordner. 
### Übrigens: Mit sogenannten APIs könnt Ihr digital erhobene Daten ebenfalls in R laden. Schaut mal, ob das auch für Eure Umfragetools funktioniert!

### Hier laden wir die Datensätze, die Ihr am Besten immer in einem Ordner namens "Daten" speichert.
mitglieder <- readxl::read_xlsx(here::here("Daten", "Mitgliederdaten.xlsx"))

##### Übung 3: Ladet nun hier auch den Feedback-Datensatz.
feedback <- readxl::read_xlsx(here::here("Daten", "Feedbackumfrage.xlsx"))

##### Übung 4: Schaut nun beide Datensätze an. Dazu gibt es einige nütztliche Funktionen: view(), colnames() und summary().
View(mitglieder)
colnames(mitglieder)
summary(mitglieder)

View(feedback)
colnames(feedback)
summary(feedback)

############################################

# 5) USER INTERFACE
### Hier definieren wir, was die Nutzer:innen (und wir) sehen.
### Hinweis: Nach jedem Element (textInput, textOutput, etc.) müsst Ihr ein Komma setzen.
ui <- fluidPage(
    
    # Übung 5: Ersetzt den Beispieltitel mit einem von Euch gewählten Titel. Lasst die Anführungszeichen stehen!
    titlePanel("Mitgliederdaten und Feedbackumfrage - Fantasie e.V."),
    
    # Hiermit legen wir unser Layout fest - wir haben uns für das SidebarLayout entschieden, damit wir links Filter einfügen können.
    sidebarLayout(
        
      # Hier definieren wir die Filter. Die verschiedenen Filterarten findet Ihr auf dem RShiny-Schummelblatt. Die Filter folgen dem Format filter('Euer Variablenname', 'Anweisung an den User', 'Auswahlmöglichkeiten', 'Standardwert').
      sidebarPanel(
        # Dieser Filter ist ein Dropdown-Filter zu den individuellen Bundesländern, die wir hier noch sortiert haben.
        selectInput('ort', 'Wähle den Ort aus:', choices = sort(unique(mitglieder$Wohnort)), selected = 'Berlin'),
        
        ##### Übung 6a: Fügt der UI einen Radiobutton für das Beitrittsjahr hinzu. Ändert das auch im Server!
        # Tipp: Das Jahr könnt Ihr aus dem Beitrittsdatum mit dem folgenden Codesnippet extrahieren: format(mitglieder$Beitrittsdatum, "%Y"). Damit ersetzt Ihr nun das Argument choices.
        radioButtons('beitrittsjahr', 'Wähle das Beitrittsjahr aus:', choices = sort(unique(format(mitglieder$Beitrittsdatum, "%Y"))), selected = "2012"),
        
        # Einfügen eines Download-Buttons
        downloadButton('downladbutton', label = "Download")
      ),
        
        # Hier kreiieren wir den Hauptteil der Applikation. 
        mainPanel(
            # Wir haben uns für das Layout mit Tabs (zu dt. Reitern) entschieden.
            tabsetPanel(
                # Tab mit Visualisierung einfügen. Das Package plotly sorgt für die Interaktivität der Visualisierung.
                tabPanel('Visualisierung', plotly::plotlyOutput('Visualisierung')), # Setzt hier ein Komma!
                
                ##### Übung 7: Fügt hier einen Tab mit den Rohdaten als Tabelle ein.
                # Tipp: Der Code hat folgendes Format: tabPanel('Name des Tabs', gewünschtes Outputformat('Name des Outputs')). Nutzt das Outputformat DT::DTOutput().
                tabPanel('Tabelle', DT::DTOutput('Tabelle'))
            ),
        )
    )
)

############################################

# 6) SERVER
### Hier im Server berechnen wir Werte, filtern und hinterlegen ganz allgemein Anweisungen, was angezeigt werden soll - besonders wenn der Nutzer:innen Filter auswählt.
server <- function(input, output, session){
    
    # Einfügen der Visualisierung in die Applikation - hier mit der Option "Alle Orte"
    output$Visualisierung <- plotly::renderPlotly({
        mitglieder %>%
        
            ##### Übung 6b: Hier müsst Ihr den Filter für das Beitrittsjahr hinzufügen. Tipp: filter(Bedingung1, Bedingung2)
            filter(Wohnort == input$ort, format(mitglieder$Beitrittsdatum, "%Y") == input$beitrittsjahr) %>% # hiermit ermöglichen wir das filtern auf den Wohnort
        
            # Mit ggplot können wir schöne Visualisierungen bauen - mehr dazu hier: https://rstudio.com/wp-content/uploads/2015/06/ggplot2-german.pdf
            ##### Übung 8:Visualisiert statt des Geschlechts den Beschäftigungsstatus. Denkt an die Achsenbeschriftung.
            ggplot(aes(Beschäftigungsstatus, fill = Beschäftigungsstatus)) + # Hier legen wir fest, was auf der x-Achse angezeigt und wie die Graphik eingefärbt werden soll
              theme_classic() + # legt das Design "Classic" fest
              scale_fill_brewer(palette = "Greens", "Legende") + # bestimmt die Farbe und den Legendentitel
              xlab("Beschäftigungsstatus") + # beschriftet die x-Achse
              ylab("Anzahl") + # beschriftet die y-Achse
              geom_bar() # bestimmt die Art des Plots
    })

    ##### Übung 9: Fügt hier den Output für die Datentabelle der Mitglieder ein. Tipp: das Format lautet output$OutputnameAusDerUI <- DT::renderDT({Datensatz})
    output$Tabelle <- DT::renderDT({
      mitglieder
    })
    
    # Download-Report
    output$downloadReport <- downloadHandler(
      filename = paste(format(Sys.Date(), '%d.%m.%Y'), 'Mitgliederzahlen'),
      
      content = function(file) {
        src <- normalizePath('report.Rmd')
        
        # temporarily switch to the temp dir, in case you do not have write
        # permission to the current working directory
        owd <- setwd(tempdir())
        on.exit(setwd(owd))
        file.copy(src, 'report.Rmd', overwrite = TRUE)
        
        library(rmarkdown)
        out <- render('report.Rmd', switch(
          input$format,
          PDF = pdf_document(), HTML = html_document(), Word = word_document()
        ))
        file.rename(out, file)
      }
    )
    
    
}

############################################

# 7) ZUSAMMENFÜHRUNG
### Hinweis: Diese Code-Zeile bleibt immer gleich.
shinyApp(ui = ui, server = server)

### Übung 10 - Optional: Entwickelt Eure eigenen Visualisierungen. Achtet dabei darauf, dasss Ihr stehts in der UI Panels designen müsst, deren Inhalt Ihr im Server als output$Name definiert.
