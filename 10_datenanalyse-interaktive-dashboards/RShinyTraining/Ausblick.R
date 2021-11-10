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

"
install.packages(c(
  'shiny', 
  'ggplot2', 
  'tidyr',
  'dplyr',
  'plotly',
  'DT',
  'here',
  'ShinyFiles',
  'tinytex',
  'gridExtra',
  'leaflet'
))

tinytex::install_tinytex()

"

############################################

# 2) RELEVANTE PACKAGES LADEN
### Die installierten Packages müsst Ihr laden. Erst so werden die Funktionalitäten zugänglich.
### Dazu nutzt Ihr den Befehl "library(Package-Name)" - ohne Anführungszeichen!
### Hinweis: Ihr könnt auch ohne library arbeiten. Mit der Notation package::funktion() greift Ihr direkt auf die Funktionen zu.

library(shiny) # Das RShiny Package.
library(ggplot2) # Hiermit können wir schöne Plots generieren.
library(tidyr) # Hiermit kann man Daten bereinigen.
library(dplyr) # Hiermit kann man Daten sehr gut filtern, gruppieren und modifizieren.
library(knitr) # Hiermit knitten wir unseren Report.
library(tinytex) # Dieses Latex-Package gibt uns die Option, den Report als PDF zu exportieren.
library(gridExtra) # Das ermöglicht uns mehrere Plots auf einer Seite zu integrieren.
library(leaflet) # Das ermöglicht das Erstellen von Karten

############################################

# 3) DATEN LADEN
### Euer Script sucht - genau wie Ihr es tun würdet - die genutzten Daten.
### Sogenannte "Paths" (zu dt. Wege) geben an, wo lokale Dokumente abliegen. 
### Dabei werden die verschiedenen Ordner mit "/" getrennt und der gesamte Path in Anführungszeichen gesetzt.
### Als absolute Paths bezeichnet man die Option, eine Reise von Berlin nach München mit allen Zwischenstationen zu definieren.
### Relative Paths starten bei einem gesetzten Startpunkt, wo z.B. Euer Script liegt. Damit können Scripte leichter geteilt werden.
### Die Idee ist: Wenn Ihr erst in Dresden losfahrt, dann braucht Ihr auch erst ab die Fahrstrecke. 
### So müssen Eure Kolleg:innen nicht erstmal den Path anpassen, wenn sie Euer Script auf ihrem PC ausführen möchten.
### Hinweis: In R gibts dafür für neue Projekte einen tollen Trick - Nutzt RProjects und schiebt alle Eure Dokumente in den entsprechenden Ordner (https://rstats.wtf/project-oriented-workflow.html) 
### Alle Pfade beginnen dann in Eurem RProject-Ordner. 
### Übrigens: Mit sogenannten APIs könnt Ihr digital erhobene Daten ebenfalls in R laden. Schaut mal, ob das auch für Eure Umfragetools funktioniert!

### Hier laden wir die Datensätze, die Ihr am Besten immer in einem Ordner namens "Daten" speichert.
mitglieder <- readxl::read_xlsx(here::here("Daten", "Mitgliederdaten.xlsx"))
feedback <- readxl::read_xlsx(here::here("Daten", "Feedbackumfrage.xlsx"))
geocoordinaten <- readxl::read_xlsx(here::here("Daten", "Geocodierung.xlsx"))

### Hier fügen wir die Daten über die Mitglieder-ID zusammen.
### Mehr Informationen, wie das funktioniert, gibt es hier: https://dplyr.tidyverse.org/reference/join.html
alle_daten_short <- dplyr::full_join(left_join(mitglieder, geocoordinaten, by = 'Wohnort'), feedback, by = "Mitglieds-ID")

### Die Variablennamen sind nicht noch nicht so schön oder zu lang? Mit dem Snippet colnames(datensatz) <- c("Name1", "Name2", ...) lässt sich das ändern.
colnames(alle_daten_short) <- c("Mitglieds-ID", "Name", "Geschlecht", "Geburtsdatum", "Wohnort", "Bundesland", 
                                "Beitrittsdatum", "Austrittsdatum", "Beschäftigungsstatus", "Spende (p.a. in EUR)", "Lat", "Long", 
                                "Kursangebot insgesamt", "An welchem Kursniveau nimmst Du teil?", "Mentor:in", 
                                "Materialien", "Anmeldung", "Beratungsstelle", "Räumlichkeiten", "Erhebungsjahr")

############################################

# 4) DATEN BEREINIGEN
### Hiermit konvertieren wir das "kurze" Datenformat, in dem pro Zeile eine Beobachtung und pro Spalte eine Variable festgesetzt ist.
### Im "langen" Format lassen sich dann die Fragen auch als Filter verwenden - das ist später für die Visualisierung praktisch.
### Diese Technik ist besonders bei Umfragen relevant!
alle_daten_long <- tidyr::pivot_longer(alle_daten_short, # Datenquelle
                    cols = c("Kursangebot insgesamt", # Spalten, die zusammengefügt werden sollen.
                        "Mentor:in",
                        "Materialien",
                        "Anmeldung",
                        "Beratungsstelle",
                        "Räumlichkeiten"
                        ),
                    names_to = "Frage", # Benennung der neuen Frage-Spalte
                    values_to = "Antwort" # Benennung der neuen Antwort-Spalte
                    )

### Hier hinterlegen wir die Option "Alle Ort" für den Wohnort-Filter
orte <- c("Alle Orte", sort(unique(alle_daten_long$Wohnort)))

### Funktion zur Berechnung des Alters - einfach bei Bedarf kopieren
calc_age <- function(birthDate, refDate = Sys.Date(), unit = "year") {
  
  require(lubridate)
  
  if(grepl(x = unit, pattern = "year")) {
    as.period(interval(birthDate, refDate), unit = 'year')$year
  } else if(grepl(x = unit, pattern = "month")) {
    as.period(interval(birthDate, refDate), unit = 'month')$month
  } else if(grepl(x = unit, pattern = "week")) {
    floor(as.period(interval(birthDate, refDate), unit = 'day')$day / 7)
  } else if(grepl(x = unit, pattern = "day")) {
    as.period(interval(birthDate, refDate), unit = 'day')$day
  } else {
    print("Argument 'unit' must be one of 'year', 'month', 'week', or 'day'")
    NA
  }
}

############################################

# 5) USER INTERFACE
### Hier definieren wir, was die Nutzer:innen (und wir) sehen.
### Hinweis: Nach jedem Element (textInput, textOutput, etc.) müsst Ihr ein Komma setzen.
ui <- fluidPage(
  
  # Titel einfügen
  titlePanel(fluidRow(
    column(10, tags$h2("Mitglieder und Feedbackumfrage - Fantasie e.V."), HTML('<h5><em>Eine Übung zum Erlernen von Shiny Web Apps mit fiktiven Daten von und für die Zivilgesellschaft mit CorrelAid e.V. Lizenziert nach CC-BY</h5></em>')),
    column(1, HTML('<center><img src="https://betterplace-assets.betterplace.org/uploads/organisation/profile_picture/000/033/251/crop_original_bp1613490681_Logo.jpg" width="75"></center>'))
  )),
  
  # HTML-Code für erweitertes Layout (für Fortgeschrittene)
  tags$head(
    tags$link(rel = "icon", type = "image/png", sizes = "32x32", href = "https://correlaid.org/favicons/favicon-32x32.png"),
    tags$style(
      HTML("
            <script>
          var socket_timeout_interval
          var n = 0
          $(document).on('shiny:connected', function(event) {
          socket_timeout_interval = setInterval(function(){
          Shiny.onInputChange('count', n++)
          }, 15000)
          });
          $(document).on('shiny:disconnected', function(event) {
          clearInterval(socket_timeout_interval)
          });
          </script>
          
         .well {
            background-color: #8FAFC1;
        }
             
        .selectize-input.full {
            background-color: #FFFFFF;
        }
        .selectize-dropdown {
            background-color: #FFFFFF;
        }
        #name {
            background-color: #FFFFFF;
        }
        
        #ergebnisse {
            background-color: #FFFFFF;
        }
        
        #hilfe {
            background-color: #FFFFFF;
        }"))),
  
  # Hiermit legen wir unser Layout fest - wir haben uns für das SidebarLayout entschieden, damit wir links Filter einfügen können.
  sidebarLayout(
    
    # Hier definieren wir die Filter: Auswahlfilter für Wohnort und Kursniveau und ein Eingabefeld für Text
    sidebarPanel(
      # Drop-Down-Filter für den Ort
      selectInput('ort', 'Wähle den Ort aus:', choices = orte, selected = 'Alle Orte'),
      # Drop-Down-Filter für die Frage
      selectInput('frage', 'Wähle das Bewertungskriterium der Feedbackumfrage aus:', choices = unique(alle_daten_long$Frage), selected = 'Kursangebot insgesamt'),
      # Radio-Button-Filter für das Erhebungsjahr (FB)
      radioButtons('erhebungsjahr', 'Wähle das Erhebungsjahr der Feedbackumfrage aus:', choices = sort(unique(alle_daten_long$Erhebungsjahr)), selected = "2020"),
      # Textinput für Autor:in
      textInput('name', 'Gib hier deinen Namen an:', value = 'unbekannte:r Autor:in'), 
      # Textoutput für Autor:in
      textOutput('autor'), 
      
      # Einfügen eines Download-Buttons
      downloadButton('downloadbutton', label = "Download"),
    
    # Einfügen eines Hilfefensters
      actionButton("hilfe", "Hilfe")
    ),
    
    # Hier kreiieren wir den Hauptteil der Applikation. 
    mainPanel(
      # Wir haben uns für das Layout mit Tabs (zu dt. Reitern) entschieden.
      tabsetPanel(
        # Tab mit Karte einfügen. Wir nutzen das Package Leaflet.
        tabPanel('Standorte', leafletOutput('Karte')),
        # # Tab mit Mitglieder-Visualisierung einfügen. 
        tabPanel('Mitglieder', plotOutput('Mitglieder')),
        # Tab mit Tabelle und allen Mitgliedsdaten einfügen. Das Package DT macht die Datentabelle durchsuch- und navigierbar.
        tabPanel('Mitgliedsdaten', DT::DTOutput('Mitgliedsdaten')),
        # Tab mit Feedback-Visualisierung einfügen. Das Package plotly sorgt für die Interaktivität der Visualisierung.
        tabPanel('Feedback', plotly::plotlyOutput('Feedback'))
      ),
    )
  )
)

############################################

# 6) SERVER
### Hier im Server berechnen wir Werte, filtern und hinterlegen ganz allgemein Anweisungen, was angezeigt werden soll - besonders wenn der Nutzer:innen Filter auswählt.
### Um den Code nicht zu wiederholen, definieren wir hier das Layout unseres Barplots.
barplot <- function(daten, xvariable, farbvariable, farbpalette, titel) {
  ggplot(daten, aes(x = xvariable, fill = factor(farbvariable))) +
    scale_fill_brewer(palette = farbpalette) + # Farbpalette
    theme_classic() + # Layout
    theme(legend.position = "none", axis.text.x = element_text(angle = 45, vjust = 0.5)) + # Legende ausblenden, da hier nicht notwendig
    ggtitle(paste(titel)) + # fügt einen Titel hinzu
    xlab('') + # x-Achsenbeschriftung
    ylab('Prozent der Antworten') + #y-Achsenbeschriftung
    scale_y_continuous(labels = scales::percent) +
    geom_text(aes(label = scales::percent(..prop..), y = ..prop.., group = 1), stat= "count", vjust = 0.011, size = 3) + # Beschriftung
    geom_bar(aes(y = ..prop.., fill = factor(..x..), group = 1), stat="count") # Graphtyp und y-Achse in Prozent
  }

### Tabs gestalten
server <- function(input, output, session){
  
  # Einfügen des/der Autor(s):in in die Applikation
  output$autor <- renderText({
    paste('Auszug erstellt von ', input$name, ' am ', format(Sys.time(), " %d.%m.%Y"), '.', sep ='')
  })
  
  # Bedienungshilfe
  hilfe_text <- "Über die Auswahl der Orte könnt Ihr die Reiter Mitglieder, Feedback, Standorte und die Datentabelle erforschen.
      Die Filter Bewertungskriterium und Erhebungsjahr sind nur für den zweiten Tab (Feedback) relevant.
      Die Ortskreise auf der Karte werden mit der Anzahl der Mitglieder größer. 
      Wenn Ihr auf sie klickt, findet Ihr mehr Informationen zu dem Ort.
      Wenn Ihr auf Download klickt, speichert Ihr Eure derzeitige Auswahl als PDF.
      Bei Anmerkungen oder Fragen wendet Euch an: nina.h@correlaid.org"
  observeEvent(input$hilfe, {
    showModal(modalDialog(hilfe_text, title = "Bedienungshilfe", footer = modalButton("Verstanden!")))
  })
  
  # Download-Report
  output$downloadbutton <- downloadHandler(
    filename = paste0(format(Sys.Date(), '%d.%m.%Y'), '_MitgliederzahlenUndFeedback', '.pdf'),
    
    content = function(file) {
      src <- normalizePath('report_ausblick.Rmd')
      
      # Wechselt in ein temporäres Directory und definiert Zugangsberechtigungen
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, 'report_ausblick.Rmd', overwrite = TRUE)
      
      library(rmarkdown)
      out <- render('report_ausblick.Rmd', quiet = TRUE, params = list(autor = input$name, erhebungsjahr = input$erhebungsjahr, frage = input$frage, ort = input$ort))
      file.rename(out, file)
  })
  
  # Standort-Karte visualisieren 
  output$Karte <- renderLeaflet({
    if (input$ort != "Alle Orte"){ # Erster Fall: Ein Ort wird ausgewählt.
      daten <- alle_daten_long %>% filter(Wohnort == input$ort)
    } else { # Zweiter Fall: Der/die Nutzer:in möchte alle Orte ansehen.
      daten <- alle_daten_long
    }
    
    # Daten vorbereiten
    karten_daten <- daten %>%
      select(`Mitglieds-ID`, Wohnort, Beitrittsdatum, Austrittsdatum, Lat, Long) %>% # Spalten auswählen
      mutate('Eintritt' = 1, 'Austritt' = ifelse(is.na(Austrittsdatum), 0,1)) %>% #  Eintritt, Austritt und Aktivitätsstatus codieren
      mutate('Aktives Mitglied' = Eintritt - Austritt) %>%
      group_by(`Mitglieds-ID`, Wohnort, Lat, Long) %>% # Individuelle Mitglieder heraussuchen
      summarise('Eintritte' = sum(unique(Eintritt)), 'Austritte' = sum(unique(Austritt)), 'Aktive Mitglieder' = sum(unique(`Aktives Mitglied`))) %>% # Anzahl berechnen
      group_by(Wohnort, Lat, Long) %>% # Pro Ort gruppieren
      summarise(Eintritte = sum(Eintritte), Austritte = sum(Austritte), 'Aktive Mitglieder' = sum(`Aktive Mitglieder`)) %>% # Zusammenfassung berechnen
      mutate(Lat = as.numeric(Lat), Long = as.numeric(Long))
    
    # Karte erstellen
    karte <- karten_daten %>%
      leaflet() %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% # Layout wählen - wir empfehlen die Layouts von CartoDB (auch verfügbar ohne Labels und in schwarz)
      setView(10.4541194, 51.1642292, zoom = 5.25) %>% # Standard-Zoom festsetzen
      addCircleMarkers(~Long, ~Lat, radius = karten_daten$`Aktive Mitglieder`, color="#027F88", # Radius nach Anzahl der aktiven Mitglieder
                       popup= paste(karten_daten$Wohnort, '-', karten_daten$`Aktive Mitglieder`, "Aktive Mitglieder", sep =' ')) # Popup mit Stadtnamen und Anzahl
  })
  
  # Einfügen der Mitglieder-Tabelle in in die Applikation
  output$Mitgliedsdaten <- DT::renderDT({
    if (input$ort != "Alle Orte"){ # Erster Fall: Ein Ort wird ausgewählt.
      daten <- mitglieder %>% filter(Wohnort == input$ort) %>%
        mutate(Geburtsdatum = format(Geburtsdatum, "%d.%m.%Y")) %>% # Formatieren des Datums
        mutate(Beitrittsdatum = format(Beitrittsdatum, "%d.%m.%Y")) %>%
        mutate(Austrittsdatum = format(Austrittsdatum, "%d.%m.%Y"))
    } else { # Zweiter Fall: Der/die Nutzer:in möchte alle Orte ansehen.
      daten <- mitglieder %>%
        mutate(Geburtsdatum = format(Geburtsdatum, "%d.%m.%Y")) %>% # Formatieren des Datums
        mutate(Beitrittsdatum = format(Beitrittsdatum, "%d.%m.%Y")) %>%
        mutate(Austrittsdatum = format(Austrittsdatum, "%d.%m.%Y"))
    }
  })
  
  # Mitglieder-Visualisierung gestalten
  mitglieder_plot_ergebnisse <- reactive({ # Hier können wir unseren Output reaktiv gestalten.
    if (input$ort != "Alle Orte"){ # Erster Fall: Ein Ort wird ausgewählt.
      daten <- alle_daten_long %>% filter(Wohnort == input$ort)
    } else { # Zweiter Fall: Der/die Nutzer:in möchte alle Orte ansehen.
      daten <- alle_daten_long
    }
    # Tabelle kreiieren
    liste <- daten %>%
      select(`Mitglieds-ID`, Wohnort, Beitrittsdatum, Austrittsdatum) %>% # Spalten auswählen
      mutate('Eintritt' = 1, 'Austritt' = ifelse(is.na(Austrittsdatum), 0,1)) %>% #  Eintritt, Austritt und Aktivitätsstatus codieren
      mutate('Aktives Mitglied' = Eintritt - Austritt) %>%
      group_by(`Mitglieds-ID`, Wohnort) %>% # Individuelle Mitglieder heraussuchen
      summarise('Eintritte' = sum(unique(Eintritt)), 'Austritte' = sum(unique(Austritt)), 'Aktive Mitglieder' = sum(unique(`Aktives Mitglied`))) %>% # Anzahl berechnen
      group_by(Wohnort) %>% # Pro Ort gruppieren
      summarise(Eintritte = sum(Eintritte), Austritte = sum(Austritte), 'Aktive Mitglieder' = sum(`Aktive Mitglieder`)) # Zusammenfassung berechnen
    
    df <- data.frame(matrix(unlist(liste), nrow=length(unique(daten$Wohnort)), byrow=FALSE)) # in DataFrame konvertieren (notwendige für den Grid)
    colnames(df) <- c('Ort', 'Beitritte', 'Austritte', 'Aktive Mitglieder') # Spaltennamen anpassen
    tabelle <- tableGrob(df, rows = NULL, theme = ttheme_minimal()) # Layout gestalten und speichern
    
    # Kreisdiagramm kreiieren
    plot_geschlecht <- daten %>%
      select(Geschlecht) %>% # Spalte Geschlecht auswählen
      group_by(Geschlecht) %>% # Pro Geschlecht gruppieren
      summarise('Anzahl' = n(), 'Prozent' = n()/nrow(daten)) %>% # Bei Gruppierung Anzahlung und Prozent bestimmen
      ggplot(aes(x='', y=Prozent, fill=Geschlecht)) +
        geom_bar(stat="identity", width=1) + # Basislayout definieren (Hinweis: Das ist ein Barchart)
        coord_polar("y", start=0) + # Kuchendiagramm ausrichten
        theme_void() + # Grid entfernen
        ggtitle('Geschlecht') + # Titel hinzügen
        scale_fill_brewer(palette='PuBuGn') + # Farbe festlegen
        geom_text(aes(label = paste0(round(Prozent*100), "%")), position = position_stack(vjust = 0.5)) # Beschriftungen kreiieren
    
    # Barplot zur Beschäftigung kreiieren
    plot_status <- barplot(daten, daten$Beschäftigungsstatus, daten$Beschäftigungsstatus, 'PuBuGn', 'Beschäftigung')
    
    # Verteilungsplot für Alter
    plot_alter <- daten %>% 
      mutate('Alter' = calc_age(Geburtsdatum)) %>% # Alter berechnen (Funktion unter Daten bereinigen)
      ggplot(aes(x=Alter)) + # Plot initialisieren
        geom_density(fill='#027F88', color = '#027F88') + # Verteilungsplot erstellen
        geom_vline(aes(xintercept=mean(Alter))) + # Mittelwert hinzufügen
        theme_classic() + # Layout auswählen
        ylab('Verteilung') +  # y-Achse beschriften
        ggtitle('Alter') # Titel hinzufügen
    
    # Verteilungsplot für Spenden
    plot_spenden <- daten %>% 
      ggplot(aes(x=`Spende (p.a. in EUR)`)) + # Plot initialisieren
        geom_density(fill='#027F88', color = '#027F88') + # Verteilungsplot erstellen
        geom_vline(aes(xintercept=mean(`Spende (p.a. in EUR)`))) + # Mittelwert hinzufügen
        theme_classic() + # Layout auswählen
        xlab('Spendenhöhe p.a. in EUR') + # x-Achse beschriften
        ylab('Verteilung') +  # y-Achse beschriften
        ggtitle('Spendenhöhe') # Titel hinzufügen
    
    # Plots arrangieren
    lay <- rbind(c(1,1,5,5,5,5), # Layout festlegen: Eine Zahl steht für eine Graphik (1 für die erste Graphik in grid.arrange)
                 c(1,1,5,5,5,5),
                 c(2,2,3,3,4,4),
                 c(2,2,3,3,4,4))
    
    p = grid.arrange(plot_status, plot_geschlecht, plot_alter, plot_spenden, tabelle, layout_matrix = lay) # Layout speichern
    print(p) # Layout drucken
  })
  
  # Einfügen der Mitglieder-Visualisierung in die Applikation
  output$Mitglieder <- renderPlot({
    mitglieder_plot_ergebnisse()
  })
  
  # Feedback-Visualisierung gestalten
  fb_plot_ergebnisse <- reactive({ # Hier können wir unseren Output reaktiv gestalten.
    if (input$ort != "Alle Orte"){ # Erster Fall: Ein Ort wird ausgewählt.
      daten <- alle_daten_long %>% filter(Frage == input$frage, Erhebungsjahr == input$erhebungsjahr, Wohnort == input$ort) 
    } else { # Zweiter Fall: Der/die Nutzer:in möchte alle Orte ansehen.
      daten <- alle_daten_long %>% filter(Frage == input$frage, Erhebungsjahr == input$erhebungsjahr)
    } 
    barplot(daten, daten$Antwort, daten$Antwort, 'PiYG', '')
  })
  
  # Einfügen der Feedback-Visualisierung in die Applikation
  output$Feedback <- plotly::renderPlotly({
    fb_plot_ergebnisse()
  })
}

############################################

# 7) ZUSAMMENFÜHRUNG
### Hinweis: Diese Code-Zeile bleibt immer gleich.
shinyApp(ui = ui, server = server)