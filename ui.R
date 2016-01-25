library(shiny)
library(shinydashboard)
library(lubridate)
library(dygraphs)

dashboardPage(skin = "blue",
    dashboardHeader(title = "Programming Assignment", 
                    titleWidth = 300),
    dashboardSidebar(width = 300,
        sidebarMenu(
            menuItem(h4("Instructions"), tabName = "instructions"),
#             conditionalPanel("input.menu == 'instructions'",
#                              h4("instructions")                 
#             ),
            menuItem(h4("Exchange Rates"), tabName = "exchange_rates"),
            conditionalPanel("input.menu != 'instructions'",
                dateRangeInput("date_range", "Period:", 
                           start = Sys.Date() - years(1), end = Sys.Date() - 1,
                           language = "en", weekstart = 1, 
                           format = "dd.mm.yyyy", separator = " to ")
            ),
            conditionalPanel("input.cond_panels == 'googleVis' && input.menu != 'instructions'",
                checkboxInput("zoom_buttons", "Show zoom buttons",
                              value = TRUE),
                checkboxInput("range_selector", "Show range selector",
                              value = TRUE),
                sliderInput("fill", "Alpha level of the fill", 
                            min = 0, max = 100, value = 10, step = 5),
                sliderInput("thickness", "Thickness of the lines",
                            min = 0, max = 10, value = 0, step = 1)
            ),
            conditionalPanel("input.cond_panels == 'dygraphs' && input.menu != 'instructions'",
                checkboxInput("step_plot", "Step Plot", value = FALSE),
                checkboxInput("fill_graph", "Fill Graph", value = FALSE),
                checkboxInput("draw_grid", "Draw Grid", value = FALSE),
                checkboxInput("log_scale", "Log Scale", value = FALSE)
            ),
        id = "menu")
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "instructions",
                HTML(paste(readLines("instructions.txt"), collapse = "<br>"))
            ),
            tabItem(tabName = "exchange_rates",
                fluidRow(
                    valueBoxOutput("usd_change_box", width = 4),
                    valueBoxOutput("eur_change_box", width = 4),
                    valueBoxOutput("gbp_change_box", width = 4)
                ),
                fluidRow(
                    tabBox(width = 12,
                        tabPanel("googleVis",
                            div(style="width:900px; height:350px; margin:0 auto;",
                                htmlOutput("view1")
                            )
                        ),
                        tabPanel("dygraphs",
                            div(style="width:900px; height:350px; margin:0 auto;",
                                dygraphOutput("view2", width = 900, height = 350)
                            )
                        ),
                    id = "cond_panels")
                )
            )
        )
    )
)