library(shiny)
library(quantmod)
library(reshape2)
library(googleVis)
library(lubridate)
library(dplyr)

currencies <- c("EUR", "USD", "GBP")
base_curr <- "RUB"

start_date <- Sys.Date() - years(5)
end_date <- Sys.Date() - 1

curr_df <- list()
for (curr in currencies) {
    curr_df[curr] <- data.frame(getFX(paste0(curr, "/", base_curr), 
                                      auto.assign = FALSE, 
                                      from = start_date, 
                                      to = end_date))
}

curr_df <- data.frame(curr_df)
dt <- data.frame(date = seq.Date(start_date, length = nrow(curr_df), by = "days"))
curr_df <- data.frame(date = dt, curr_df)

shinyServer(function(input, output) {
    df_period <- reactive({
        curr_df %>% filter(date >= input$date_range[1] & 
                          date < input$date_range[2] + 1)
    })
        
    output$view1 <- renderGvis({
        df <- melt(df_period(), id.vars = c("date"), 
                        measure.vars = currencies, 
                        variable.name = "currency", value.name = "rate")
        df$currency <- sapply(df$currency, function(x) paste0(x, "/RUB"))
        gvisAnnotationChart(df, 
                            datevar="date",
                            numvar="rate", 
                            idvar="currency",
                            titlevar="", 
                            annotationvar="",
                            options=list(
                                width=900, height=350, 
                                fill=input$fill, displayExactValues=TRUE,
                                colors="['#0000ff','#000000','#ff0000']",
                                date.format="%d.%m.%Y", legendPosition = "newRow",
                                displayRangeSelector = input$range_selector,
                                displayZoomButtons = input$zoom_buttons,
                                thickness = input$thickness)
        )
    }) 
    
    xts_data <- reactive({
        df <- df_period()
        xts(df[, -1], df[, 1])
    })
    
    output$view2 <- renderDygraph({
        dygraph(xts_data()) %>% 
            dySeries("EUR", label = "EUR/RUB") %>%
            dySeries("USD", "USD/RUB") %>% 
            dySeries("GBP", "GBP/RUB") %>%
            dyRangeSelector(height = 40) %>%
            dyOptions(stepPlot = input$step_plot, fillGraph = input$fill_graph,
                      drawGrid = input$draw_grid, logscale = input$log_scale)
    })
    
    df_change <- reactive({
        date_range <- df_period() %>% 
            summarise(min_date = min(date), max_date = max(date))
        df <- curr_df %>% 
            filter(date == date_range$min_date | date == date_range$max_date) %>%
            arrange(date)
        df <- sapply(df[2:4], function(x) round(100 * (x[2] - x[1]) / x[1], 2))
        data.frame(t(df))
    })
    
    output$usd_change_box <- renderValueBox({
        valueBox(    
            df_change()$USD,
            "USD/RUB Change, %",
            icon = icon("dollar"),
            color = "purple"
        )
    })
    
    output$eur_change_box <- renderValueBox({
        valueBox(    
            df_change()$EUR,
            "EUR/RUB Change, %",
            icon = icon("euro"),
            color = "teal"
        )
    })
    
    output$gbp_change_box <- renderValueBox({
        valueBox(    
            df_change()$GBP,
            "GBP/RUB Change, %",
            icon = icon("gbp"),
            color = "yellow"
        )
    })
})