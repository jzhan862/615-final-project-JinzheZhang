library(shiny)
library(DT)
library(wordcloud2)
library(colourpicker)
library(shinythemes)

shinyUI(navbarPage(theme = shinytheme("cerulean"),
    "Data Analysis for Job Positions",
    tabPanel("Introduction",
             h4("The aim of this project is to explore jobs and try to find the common vocabulary used in the job description.
Job type, company, title, location and description were analyzed below. For descriptions, texting manipulation was used to clean and dig the insight.
The data set is from Github Job, specifically jobs for software developers. Link is https://jobs.github.com/api. "),
             h3("Contents"),
             h4("1. Data View"),
             h4("2. EDA"),
             h5("2.1 Summary for Type, Company, Title and Location"),
             h5("2.2 Discription")),
    tabPanel("Data View",
                numericInput("numberRow", label = h3("Number of Rows"), value = 1),
                dataTableOutput("dataView")
             ),
    navbarMenu("EDA",
        tabPanel("Summary for Type, Company, Title, and Location",
                 column(width=4,
                        radioButtons("cat", label = h3("Select Category:"), 
                                           choices = list("Type"="type", "Company"="company", "Title"="title", "Location"="location"),
                                           selected = "type"),
                        
                        sliderInput("topRow", label = h3("Top N"), min = 1, 
                                    max = 25, value = 5)
                        ),
                 column(width=8,
                        plotOutput("catPlot")
                        )),
        tabPanel("Analysis of Description",
                 sidebarLayout(
                     sidebarPanel(
                         numericInput("num", "Maxinum number of words", value = 100, min = 5),
                         hr(),
                         colourInput("col", "Background color", value = "white")
                     ),
                     mainPanel(
                         wordcloud2Output("cloud")
                     )
                 ))  
    )
    
    
))
