library(shiny)
url <- 'https://github.com/akorsakova/DevelopingDataProducts/blob/master/Data/Bank_accounts_and_services_complaints.csv'
cfpb <- read.csv(url(url))

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should re-execute automatically
  #     when inputs change
  #  2) Its output type is a plot
  
  output$text1 <- renderText({ 
    dim(cfpb)
  })
  output$plot1 <- renderPlot({
    hist(mtcars$mpg)
  })
})