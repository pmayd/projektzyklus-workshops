### Änderungen:
### Übernahme Layout von ggplot
### Alle Orte raus? Zu kompliziert?
### Umbenennung Fragen raus? Zu viel?
### Nur ein Datenset? Einfacher?



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
  "shiny", 
  "ggplot2", 
  "tidyr",
  "dplyr",
  "plotly",
  "DT",
  "here"
))
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

### Hier fügen wir die Daten über die Mitglieder-ID zusammen.
### Mehr Informationen, wie das funktioniert, gibt es hier: https://dplyr.tidyverse.org/reference/join.html
alle_daten_short <- dplyr::full_join(mitglieder, feedback, by = "Mitglieds-ID")

### Die Variablennamen sind nicht noch nicht so schön oder zu lang? Mit dem Snippet colnames(datensatz) <- c("Name1", "Name2", ...) lässt sich das ändern.
colnames(alle_daten_short) <- c("Mitglieds-ID", "Geschlecht", "Geburtsdatum", "Wohnort",
                               "Bundesland", "Beitrittsdatum", "Austrittsdatum", "Beschäftigungsstatus",                 
                               "Mitgliedsbeitrag (in EUR)", "Mitgliedsbeitrag (Kategorie)", 
                               "Kursangebot insgesamt", "An welchem Kursniveau nimmst Du teil?", "Mentor:in", "Materialien", "Anmeldung", "Beratungsstelle", "Räumlichkeiten")
                               
############################################

# 4) DATEN BEREINIGEN
### Hiermit konvertieren wir das "kurze" Datenformat, in dem pro Zeile eine Beobachtung und pro Spalte eine Variable festgesetzt ist.
### Im "langen" Format lassen sich dann die Fragen auch als Filter verwenden - das ist später für die Visualisierung praktisch.
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

############################################

# 5) USER INTERFACE
### Hier definieren wir, was die Nutzer:innen (und wir) sehen.
### Hinweis: Nach jedem Element (textInput, textOutput, etc.) müsst Ihr ein Komma setzen.
ui <- fluidPage(
  
  # Titel einfügen
  titlePanel("Ergebnisse der Feedbackumfrage 2021 - Fantasie e.V."),
  
  # Hiermit legen wir unser Layout fest - wir haben uns für das SidebarLayout entschieden, damit wir links Filter einfügen können.
  sidebarLayout(
    
    # Hier definieren wir die Filter: Auswahlfilter für Wohnort und Kursniveau und ein Eingabefeld für Text
    sidebarPanel(
      selectInput('frage', 'Wähle das Bewertungskriterium aus:', choices = unique(alle_daten_long$Frage), selected = 'Kursangebot insgesamt'),
      selectInput('ort', 'Wähle den Ort aus:', choices = orte, selected = 'Alle Orte'),
      textInput('name', 'Gib hier deinen Namen an:', value = 'unbekannte:r Autor:in'), 
      textOutput("autor")
    ),
    
    # Hier kreiieren wir den Hauptteil der Applikation. 
    mainPanel(
      # Wir haben uns für das Layout mit Tabs (zu dt. Reitern) entschieden.
      tabsetPanel(
        # Tab mit Visualisierung einfügen. Das Package plotly sorgt für die Interaktivität der Visualisierung.
        tabPanel('Visualisierung', plotly::plotlyOutput('Visualisierung')),
        # Tab mit Tabelle und allen Daten einfügen. Das Package DT macht die Datentabelle durchsuch- und navigierbar.
        tabPanel('Daten', DT::DTOutput('Daten'))
      ),
    )
  )
)

############################################

# 6) SERVER
### Hier im Server berechnen wir Werte, filtern und hinterlegen ganz allgemein Anweisungen, was angezeigt werden soll - besonders wenn der Nutzer:innen Filter auswählt.
### Um den Code nicht zu wiederholen, definieren wir hier das Layout unseres Barplots.
barplot <- function(daten, xvariable, farbvariable, labelliste) {
  ggplot(daten, aes(x = xvariable, fill = factor(farbvariable))) +
    scale_fill_brewer(palette = 'RdYlGn', name = "Legende", labels = labelliste) +
    theme_classic() + 
    xlab('Antwort') + 
    ylab('Anzahl der Antworten') + 
    guides(fill = guide_legend(reverse=TRUE)) + 
    geom_bar()
}

### 
server <- function(input, output, session){
  plot_ergebnisse <- reactive({ # Hier können wir unseren Output reaktiv gestalten.
    if (input$ort != "Alle Orte"){ # Erster Fall: Ein Ort wird ausgewählt.
      daten <- alle_daten_long %>% filter(Frage == input$frage, Wohnort == input$ort) 
    } else { # Zweiter Fall: Der/die Nutzer:in möchte alle Orte ansehen.
      daten <- alle_daten_long %>% filter(Frage == input$frage)
    } 
    barplot(daten, daten$Antwort, daten$Antwort, rating)
  })
  
  # Einfügen der Visualisierung in die Applikation
  output$Visualisierung <- plotly::renderPlotly({
    plot_ergebnisse()
  })
  
  # Einfügen des/der Autor(s):in in die Applikation
  output$autor <- renderText({
    paste("Auszug erstellt von", input$name, "am", format(Sys.time(), "%d.%m.%Y"), ".")
  })
  
  # Einfügen der Tabelle in in die Applikation
  output$Daten <- DT::renderDT({
    alle_daten_short %>%
      mutate(Geburtsdatum = format(Geburtsdatum, "%d.%m.%Y")) %>% # Formatieren des Datums
      mutate(Beitrittsdatum = format(Beitrittsdatum, "%d.%m.%Y")) %>%
      mutate(Austrittsdatum = format(Austrittsdatum, "%d.%m.%Y"))
  })
}

############################################

# 7) ZUSAMMENFÜHRUNG
### Hinweis: Diese Code-Zeile bleibt immer gleich.
shinyApp(ui = ui, server = server)