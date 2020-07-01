library(shiny)
library(ggplot2)
data(mtcars)

# Define UI for application that draws a histogram
ui <- fluidPage(
  # Application title
  titlePanel("MTCars Linear Model Creation Kit"),
  
  # Sidebar with a slider input for number to predict
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "target",
                  label = "Select a Feature to Predict:",
                  choices = colnames(mtcars),
                  selected = 'mpg'),
      sliderInput("nFeatures", "Select number of features to fit linear model", 
                  1,dim(mtcars)[2] - 1, value=c(1,dim(mtcars)[2] - 1)),
      checkboxInput("show_hist", "Toggle Residuals Histogram", value=TRUE),
      checkboxInput("show_MSE", "Toggle MSE Line Plot", value=TRUE),
      checkboxInput("show_table", "Toggle Formula Table", value=TRUE)
    ), 
    
    mainPanel(
      plotOutput("hist_plot"),
      plotOutput("MSE_plot"),
      dataTableOutput('formulae_table')
    )
  )
)

server <- function(input, output) {
  modelList <- reactive({
    tgt = input$target
    featureList = colnames(mtcars)
    featureList = featureList[featureList != tgt]
    lmFormula = paste0(tgt, "~") 
    
    modelList = list(NULL)
    formulaList = list(NULL)
    mseList = list(NULL)
    
    while (length(featureList != 0)) {
      bestResid = -1
      bestFeat = ""
      bestModel = NULL
      for (f in featureList) {
        model = lm(paste0(lmFormula, "+", f), data=mtcars)
        currResid = sum(residuals(model)^2)
        
        if (currResid < bestResid || bestResid == -1) {
          bestResid = currResid
          bestFeat = f
          bestModel = model
        }
      }
      
      if (lmFormula != paste0(tgt, "~")) {
        lmFormula = paste0(lmFormula, "+", bestFeat)
      } else {
        lmFormula = paste0(lmFormula, bestFeat)
      }
      
      modelList = c(modelList, list(bestModel))
      formulaList = c(formulaList, lmFormula)
      mseList = c(mseList, bestResid)
      
      featureList = featureList[featureList != bestFeat]
    }
    cbind(modelList[2:(length(modelList))], 
          formulaList[2:(length(modelList))],
          mseList[2:(length(modelList))])
  })
  
  output$hist_plot <- renderPlot({
    if (input$show_hist){
      x1=input$nFeatures[1]
      x2=input$nFeatures[2]
      subset<-(x1):(x2)
      selectModels <- modelList()[,1][subset]
      
      resId = NULL
      
      for (i in c(1:length(selectModels))) {
        tempResid = data.frame(residuals(selectModels[[i]]))
        tempResid$deg = toString(i)
        colnames(tempResid) = c("residuals", "degree")
        if (is.null(resId)) {
          resId = tempResid
        } else {
          resId = rbind(resId, tempResid)
        }
      }
      
      ggplot(resId, aes(residuals, fill = degree)) + 
        geom_density(alpha=0.2, color=NA) +
        ggtitle("Density Plot of Fitted Residuals by Number of Features")
    }
  })
  
  output$MSE_plot <- renderPlot({
    if (input$show_MSE){
      x1=input$nFeatures[1]
      x2=input$nFeatures[2]
      subset<-(x1):(x2)
      
      selectMSE <- modelList()[,3][subset]
      
      mseDf <- data.frame(degree=x1:x2, MSE=unlist(selectMSE))
      
      ggplot() + 
        geom_line(data = mseDf, aes(degree, MSE, color="MSE per Number of Features", linetype="Actual Values")) + 
        geom_point(data = mseDf, aes(degree, MSE, color="MSE per Number of Features")) + 
        geom_hline(aes(yintercept=mean(mseDf$MSE), color = "Mean MSE", linetype="Aggregates")) + 
        geom_hline(aes(yintercept=min(mseDf$MSE), color = "Min MSE", linetype="Aggregates")) + 
        scale_colour_manual(values = c("red", "purple", "blue")) +
        scale_linetype_manual(values = c("solid", "twodash")) +
        ggtitle("Means Squared Error by Number of Features Fitted")

      }
  })
  
  output$formulae_table <- renderDataTable({
    if (input$show_table){
      x1=input$nFeatures[1]
      x2=input$nFeatures[2]
      formula_table = modelList()[x1:x2,2:3]
      colnames(formula_table) = c("formulae", "mse")
      rownames(formula_table) = x1:x2
      formula_table
    }
  })
}

shinyApp(ui = ui, server = server)

