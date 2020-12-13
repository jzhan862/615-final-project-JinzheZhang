library(devtools)
library(DT)
library(tidyverse)
library(stringr) 
library(plotly)
library(httr)
library(jsonlite)
library(wordcloud2)
library(RColorBrewer)
library(tm)
library(tokenizers)
library(tidytext)
library(plotly)
library(htmlwidgets)
library(naniar)
library(tibble) 
library(shiny)
library(colourpicker)




p1 = GET("https://jobs.github.com/positions.json?page=1")
p2 = GET("https://jobs.github.com/positions.json?page=2")
p3 = GET("https://jobs.github.com/positions.json?page=3")
p1 <- fromJSON(rawToChar(p1$content))
p2 <- fromJSON(rawToChar(p2$content))
p3 <- fromJSON(rawToChar(p3$content))

data <- rbind(p1, p2, p3)
names(data)
glimpse(data)
df <- data %>% select(id, type, company, location, title, description)

stopwords_regex = paste(stopwords('en'), collapse = '\\b|\\b')
stopwords_regex = paste0('\\b', stopwords_regex, '\\b')
df$description<- str_replace_all(df$description, stopwords_regex, '')
df$description <- str_replace_all(df$description, regex('[:punct:]'), "")
df$description <- str_replace_all(df$description, regex('[:digit:]'), "")
df$description <- str_replace_all(df$description, regex('<p>'), " ")
df$description <- str_replace_all(df$description, regex('und'), " ")
df$description <- str_replace_all(df$description, regex('</p>'), " ")
df$description <- str_replace_all(df$description, regex('will'), " ")
df$description <- str_replace_all(df$description, regex('you'), "")
df$description <- str_replace_all(df$description, regex('the'), "")
df$description <- str_to_lower(df$description, locale = 'en')
description <- Corpus(VectorSource(df %>% select(description)))
desp <- description %>% 
    tm_map(removeNumbers) %>%
    tm_map(removePunctuation) %>%
    tm_map(removeWords, stopwords("english")) %>% 
    tm_map(stripWhitespace)
desp <- tm_map(desp, content_transformer(tolower))

desp <- TermDocumentMatrix(desp) 
matrix <- as.matrix(desp) 
words <- sort(rowSums(matrix),decreasing=TRUE) 
pre_words <- data.frame(word = names(words),freq=words)

shinyServer(function(input, output) {

    # Data View
    data_view <- reactive({
        df %>% head(input$numberRow)
    })
    output$dataView <- renderDataTable({

        data_view()

    })
    
   
    
    cat_data <- reactive({
        df %>% group_by_at(input$cat) %>% summarise(n=n()) %>% arrange(desc(n)) %>% head(input$topRow)
        
    })
    output$catPlot <- renderPlot({
        if(input$cat=="type"){
            ggplot(df, aes(x=type)) +
                geom_bar(fill="green") +     
                theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
                      legend.position = "none", plot.title = element_text(hjust = 0.5, size=25), text = element_text(size=20)) + ggtitle("Type")
        }else{
            ggplot(cat_data(), aes(x=reorder(!!as.symbol(input$cat), n), y=n)) +
                geom_bar(stat="identity", fill="darkred") +coord_flip()+
                theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
                      legend.position = "none", plot.title = element_text(hjust = 0.5, size=25), text = element_text(size=20)) + ggtitle(input$cat)
        }
    })
    
    
    create_wordcloud <- function(num_words=100, background="white"){

        
        if(!is.numeric(num_words)||num_words<3){
            num_words <- 3
        }
        
        data <- head(pre_words, n=num_words)
        if(nrow(data) == 0){
            return(NULL)
        }
        wordcloud2(data, backgroundColor = background)
        
    }
    output$cloud <- renderWordcloud2({
        create_wordcloud(num_words = input$num, background = input$col)
    })
    

})














