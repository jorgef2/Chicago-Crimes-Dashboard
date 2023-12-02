library(shiny)
library(shinydashboard)

data <- merged_data 
data3 <- incidents_per_crime

Crime.Variables = data3[[1]]


#----------------------------------------------
# DASHBOARD LAYOUT
#----------------------------------------------
ui <- dashboardPage(
  dashboardHeader(title = "Chicago Crimes Shinydashboard"),
  dashboardSidebar(), # Empty sidebar
  dashboardBody(
    fluidRow(
      column(6, align='center',
             
        selectInput("crime_variable", "Select Crime to Map:", choices = Crime.Variables, selected = Crime.Variables[1]),
        
        fluidRow(box(
          title = uiOutput("selector_title"),
          solidHeader = TRUE,
          status='primary',
          id = "select_crime_chart", 
          width = NULL,  
          style = "width: 12; height: 700px",
          plotlyOutput("variable_selector", height='680px')
        )),
        
        fluidRow(box(
          title = uiOutput('timeseries_title'),
          solidHeader = TRUE,
          status = "primary",
          id = "map_container2",
          style = "width: 12; height: 370px;",
          width = NULL,
          plotlyOutput("plot2", height = '350px')
        ))
        ),
      column(6, style='padding:25px;', align='center',
             
        fluidRow(box(
          title = uiOutput('map_title'),
          solidHeader = TRUE,
          status = "primary",
          id = "choropleth",
          width = NULL,
          style = "width: 12; height: 750px; overflow-y: scroll;",
          leafletOutput("map", height = "730px")
        )),
        fluidRow(box(
          title = uiOutput('bar_title'),
          solidHeader = TRUE,
          status = "primary",
          id = "map_container2", 
          width = NULL,  
          style = "width: 12; height: 350px; overflow-y: scroll;",
          plotlyOutput("plot", height = "1300px")
        ))
        )
    )
  ),
  uiOutput("hidden_selector")
)


#----------------------------------------------
# SERVER FUNCTIONS
#----------------------------------------------

server = function(input, output, session) {
  
  #----------------------------------------------
  # plotly_click crime select event
  #----------------------------------------------
  # Initialize reactive with the first value
  crime_variable <- reactiveVal(Crime.Variables[33]) 
  
  # render the hidden selectInput
  output$hidden_selector <- renderUI({
    selectInput("crime_variable", "Select Crime to Map:", choices = Crime.Variables, selected = Crime.Variables[1], selectize = FALSE, width = "0px")
  })
  
  # Initialize the input$crime_variable
  outputOptions(output, "hidden_selector", suspendWhenHidden = FALSE)
  updateSelectInput(session, "crime_variable", selected = Crime.Variables[33])
  
  observe({
    # Set the initial value of crime_variable when the app starts
    crime_variable(Crime.Variables[1])
  })
  
  observeEvent(event_data("plotly_click", source = "variable_selector"), {
    event <- event_data("plotly_click", source = "variable_selector")
    
    if (!is.null(event)) {
      # Get the clicked crime
      selected_crime <- event[["x"]]
      
      # Update the hidden selectInput which in turn will update all reactive chains
      updateSelectInput(session, "crime_variable", selected = selected_crime)
    }
  })
  
  #----------------------------------------------
  # Bar graph of Reports per crime
  #----------------------------------------------
  output$variable_selector = renderPlotly({
    p <- plot_ly(data3[-c(33),], x = ~primary_type, y = ~Incidents, type = 'bar', 
                 orientation = 'v', marker = list(color = 'rgb(227, 66, 52)'),
                 source = "variable_selector") %>%
      layout(xaxis = list(categoryorder = "total descending"),
             yaxis = list(side = "top", title = 'Reported Incidents'))
    p
  })
  
  #--------------
  #  BOX TITLES:
  #--------------
  
  # crime selector bar-chart title
  output$selector_title = renderPrint({ 
    HTML(cat("<font size=5>", "<font color='white'> Crime Types by Frequency: 1/1/2018 - 1/1/2023", "</font>"), 
         paste("<br>", "<font size=4>", "Click a Bar to Visualize a Specific Crime", "</font>"))
  }) 
  

  # Choropleth title
  output$map_title = renderPrint({ 
    HTML(cat("<font size=5>", "<font color='white'> Reported ", input$crime_variable, 
             " By Community Area", "</font>"), 
         paste("<br>", "<font size=4>", "1/1/2018 - 1/1/2023", "</font>"))
  }) 
  

  # Choropleth-paired bar-chart title
  output$bar_title = renderPrint({ 
    HTML(cat("<font size=4.7>", "<font color='white'>Reported ", input$crime_variable, 
             " By Community Area", "</font>"), 
         paste("<br>", "<font size=4>", "1/1/2018 - 1/1/2023", "</font>")) 
  })
  

  # Timeseries plot title
  output$timeseries_title = renderPrint({ 
    HTML(cat("<font size=4.7>", "<font color='white'> Weekly Reported Incidents: ", 
             input$crime_variable, "</font>"), 
         paste("<br>", "<font size=4>", "1/1/2018 - 1/1/2023", "</font>")) 
  }) 
  
  #-------------------------------------
  # REACTIVES
  #-------------------------------------
  crimes_reactive <- reactive({ 
    data %>%  
      as.data.frame() %>% 
      group_by(community, .data[[input$crime_variable]]) %>% 
      summarize(total = mean(.data[[input$crime_variable]], na.rm = TRUE)) %>% 
      arrange(desc(total)) 
  }) 
  
  
  timeseries_reactive <- reactive({ 
    time_data %>% 
      filter_at(vars(primary_type, total_crime), any_vars(.%in% input$crime_variable)) 
  }) 
  
  #----------------------------------------------
  # Bar graph of crime per community area
  #----------------------------------------------
  output$plot <- renderPlotly({
    df_local <- req(crimes_reactive()) 
    plot_ly(df_local, x = ~total, y=~community, type='bar', opacity=0.75, 
            marker=list(
              color=~total,
              colorscale = "Reds"
              )) %>%  
      layout(yaxis = list(categoryorder = "total ascending"), 
             xaxis = list(side ="top", title = 'Reported Incidents')) 
  }) 
  
  #----------------------------------------------
  # choropleth of crime per community area
  #----------------------------------------------
  output$map <- renderLeaflet({ 
    pal <- colorNumeric(palette = "Reds", domain = data[[input$crime_variable]]) 
    leaflet(data) %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addPolygons(fillColor = ~pal(data[[input$crime_variable]]), 
                  weight = 2, opacity = 1, color = "lightgrey", 
                  dashArray = "3", fillOpacity = 0.7, 
                  highlight = highlightOptions( 
                    weight = 5, color = "#666", dashArray = "", 
                    fillOpacity = 0.7, bringToFront = TRUE), 
                  label = sprintf("<strong>%s</strong><br/>%g Reports", 
                                  data$community, data[[input$crime_variable]]) %>%  
                    lapply(htmltools::HTML), 
                  group = "community") %>% 
      addLegend( 
        pal = pal,  
        values = data[[input$crime_variable]], 
        title = "Reported\nIncidents", 
        position = "topright") %>% 
      setView(-87.7, 41.837, zoom = 11) 
  }) 
  
  #----------------------------------------------
  # isotype of arrest rate per crime
  #----------------------------------------------
  # output$plot2 <- renderPlot({ 
  #   df_local2 <- req(arrests_reactive()) 
  #   ggplot(df_local2, aes(x, y, colour = color)) + 
  #     geom_text(aes(label=label), family='fontawesome-webfont', size=10) + 
  #     coord_equal() + 
  #     theme_waffle() + 
  #     labs(fill = NULL, 
  #          colour = NULL) + 
  #     theme(plot.title = element_text(size=15, face="bold"), 
  #           legend.text=element_text(size=13)) + 
  #     scale_color_manual(labels=c('Arrest', 'No Arrest'), values = c("brown4", "slategray3"), 
  #                        guide = guide_legend(keyheight = unit(2.5, "lines"), keywidth = unit(2.5, "lines"))) 
  # }) 
  # 
  output$plot2 <- renderPlotly({ 
    count_time <- req(timeseries_reactive()) %>% 
      group_by(Date = lubridate::floor_date(date, "week")) %>%
      summarize(`Reported Incidents` = n())
    
    n <- dim(count_time)[1]
    count_time<-count_time[1:(n-2),]
    
    plot_ly(count_time, type = 'scatter', mode = 'lines', line = list(color = 'rgb(227, 66, 52)', width = 4))%>%
      add_trace(x = ~Date, y = ~`Reported Incidents`) %>%
      layout(showlegend = F) %>%
      layout(
        xaxis = list(zerolinecolor = '#ffff',
                     zerolinewidth = 2,
                     gridcolor = 'ffff'),
        yaxis = list(zerolinecolor = '#ffff',
                     zerolinewidth = 2,
                     gridcolor = 'ffff'),
        plot_bgcolor='#e5ecf6')
  })
} 



shinyApp(ui, server)
