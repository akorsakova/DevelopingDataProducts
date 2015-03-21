library(shiny)

# Define UI for application 
shinyUI(fluidPage(
  
  # Application title
  titlePanel(img(src="Logo.jpg"), windowTitle="Choose a Bank"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("See all complaints filed with the Consumer
               Financial Protection Bureau by selecting the bank
               name below."),
      br(),
      br(),
      #drop-down box
      uiOutput("choose_bank"),
      br(),
      #go button to refresh second graph
      actionButton("goButton", "Submit"),
      br(),
      br(),
      helpText("Download the data specific to your bank."),
      br(),
      #download button
      downloadButton('downloadData', 'Download'),
      br(), 
      br(),
      h4("Additional Information:"),
      br(),
      p("This data has been obtained from the Consumer Financial
              Protection Bureau (CFPB), more information about the data and data dictionary 
              can be obtained",
        a("here.", 
          href = "http://www.consumerfinance.gov/complaintdatabase/technical-documentation/",target="_blank")),
      p("The stacked bar chart shows the 10 banks with the most complaints for 2014 broken down by issue type."),
      p("The line graph shows the total number of complaints for the 10 banks 
              with the most complaints for 2014."),
      p("When you select a bank from the drop down and click Submit, the line graph will call out the 
              bank you selected."),
      p("If you don't select a bank, the Download button will export all 2014 CFPB data.
              Once you have selected a bank and click Submit, the Download button will export all 2014 CFPB data 
              for your selected bank.")
      ),
    
    mainPanel(
      #output frequency barplot
      plotOutput("freqPlot",width="750px",height="300px"), 
      br(),
      #output line graph
      plotOutput("linePlot")
    )
  )
))