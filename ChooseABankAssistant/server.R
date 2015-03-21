#define libraries
library(shiny)
library(ggplot2)
library(plyr)

  #load data to be used throughout the bank and clean it up
  cfpb <- read.csv("data/Bank_accounts_and_services_complaints.csv",stringsAsFactors=FALSE) 
  #get rid of the spaces in the column names
  names(cfpb) <- sub(" ", "", names(cfpb))
  #change date received to a date type and add a month year variable for graphing
  cfpb$Date.received <- as.Date(cfpb$Date.received, "%m/%d/%Y")
  cfpb$monthYr = format(cfpb$Date.received,format="%Y-%m")


shinyServer(function(input, output) {
  #create drop down box with dynamic values from the data
  output$choose_bank <- renderUI({
    selectInput("bank", "Choose a Bank", as.list(sort(unique(cfpb$Company))))
  })
  
  #print selection at the top and monthly average
  output$selectedBank <- renderText({
    input$goButton
    isolate({
      if (input$goButton == 0) {  
        paste("Showing 10 banks with the highest number of complaints for 2014") 
      }
      else {
        topBank1 <- cfpb[,(names(cfpb) %in% c("Company", "monthYr"))]
        topBank1 <- data.frame(subset(topBank1, Company %in% input$bank))        
        #get frequency counts
        totals1 <- ddply(topBank1, .(Company, monthYr), summarise, freq=length(Company))
        
        paste("You have selected ",input$bank, ", average number of complaints monthly: ", round(mean(totals1$freq),0))
      }
    })
  })
  
  #create first graph
  output$freqPlot <- renderPlot({
    #get frequency counts
    counts <- data.frame(table(cfpb$Company))
    names(counts) <- c("bank","count")

    #get top 10 banks
    largeNum <- head(counts[order(-counts$count), ],10)
    topBank <- cfpb[,(names(cfpb) %in% c("Company", "Issue"))]
    topBank <- subset(topBank, Company %in% largeNum$bank)
    #get rid of rows without issue values
    topBank[topBank == ""] <- NA
    topBank<- topBank[complete.cases(topBank),]
    
    #get frequency counts for the total labels
    totals <- ddply(topBank, .(Company), summarise, freq=length(Company))
    
    #build plot
    p <- qplot(Company, data=topBank, geom="bar", fill=Issue) + 
      xlab("Bank Name") + ylab("Total Number of Complants") +
      ggtitle("Top 10 Banks with Highest Number of Complaints for 2014") +
      theme(axis.text.x = element_text(angle = 25, hjust = 1))+
      geom_text(data=totals,aes(label=freq,x=Company,y=freq),inherit.aes=FALSE)
    
    print(p)
  })
  
  #create second graph
  output$linePlot <- renderPlot({
    #get frequency counts
    counts1 <- data.frame(table(cfpb$Company))
    names(counts1) <- c("bank","count")
    
    #get top 10 banks
    largeNum1 <- head(counts1[order(-counts1$count), ],10)
    topBank1 <- cfpb[,(names(cfpb) %in% c("Company", "monthYr"))]
    topBank1 <- subset(topBank1, Company %in% largeNum1$bank)

    #get frequency counts for the total labels
    totals1 <- ddply(topBank1, .(Company, monthYr), summarise, freq=length(Company))

    #build plot
    input$goButton
    isolate({
      #if submit button was not clicked, show only data for top 10 banks
      if (input$goButton == 0) {  
        p <- ggplot(data=totals1, aes(x=monthYr, y=freq, group = Company, colour = Company)) + 
          geom_line(size=1) +  
          geom_point( size=2, shape=21, fill="white") +
          labs(title = expression("Total Number of Complaints, All Issue Types")) +
          labs(x = "Date Received") + 
          labs(y = "Total Numbers of Complaints") +
          guides(color=guide_legend(title="Bank"))
        
        print(p)
      }
      #else if submit button was pressed, add the selected bank to the graph
      else {
        #build subset of data with top 10 banks + the selected bank
        topBank1 <- cfpb[,(names(cfpb) %in% c("Company", "monthYr"))]
        topBank1 <- data.frame(subset(topBank1, Company %in% input$bank | Company %in% largeNum1$bank))
        
        #get frequency counts
        totals1 <- ddply(topBank1, .(Company, monthYr), summarise, freq=length(Company))
        
        #create a dynamic graph title
        graphTitle <- paste("Number of Complaints for", input$bank , "Compared to Top Banks for 2014")
        
        #get the last point on the selected bank's line for annotation
        selectedBank <- input$bank
        selectedBankData <-data.frame(subset(totals1, Company %in% input$bank))
        maxMonthYr <- max(selectedBankData$monthYr)
        maxFreq <- max(subset(selectedBankData, monthYr %in% maxMonthYr)$freq)
        
        #build plot
        p <- ggplot(data=totals1, aes(x=monthYr, y=freq, group = Company, colour = Company)) + 
          geom_line(size=1) +  
          geom_point( size=2, shape=21, fill="white") +
          labs(title =  graphTitle) +
          labs(x = "Date Received") + 
          labs(y = "Total Numbers of Complaints") +
          annotate("text",  group = selectedBank, y=maxFreq, x=maxMonthYr, label = input$bank,colour = "red", size = 3.5)

        print(p)
      }
    })
  })
  
  #download data button
  output$downloadData <- downloadHandler(
      filename = function() { paste('CFPBData_2014', '.csv', sep='') },
      content = function(file) {
        write.csv(datasetInput(), file)
      }  
  )
  
  #download data table creation
  datasetInput <- reactive({
    #if button is clicked, export only selected bank data
    input$goButton
    isolate({
    if (input$goButton == 0) {
      cfpb
    }
    else {
      subset(cfpb, Company %in% input$bank)
    }
    })
  })
  
})