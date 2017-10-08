## ui.R ##
library(shinydashboard)

shinyUI(dashboardPage(
  skin = 'green',
  dashboardHeader(title='NFL 2015'),
  dashboardSidebar(
    sidebarUserPanel('David Kogan', 
                     image = 'http://s3.amazonaws.com/garysguide/78e4baf3e87b4934a8b0028fbca0a595original.jpg'),
    sidebarMenu(
      menuItem('Teams', tabName = 'teams',
               menuSubItem('Stats', tabName = 'teamstats'),
               menuSubItem('First Downs', tabName = 'firstdown'),
               menuSubItem('Pass vs Rush', tabName = 'teampr')),
      menuItem('Players', tabName = 'players',
               menuSubItem('Receivers', tabName = 'receiver'),
               menuSubItem('Running Backs', tabName = 'rusher')),
      selectInput(inputId = 'team',
                  label = 'Select Team:',
                  choices = teams)
      )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = 'teamstats',
              fluidRow(
                box(
                  title = 'Team Season Totals',
                  selectInput(inputId = 'offensedefense',
                              label = 'Select Side of Ball:',
                              choices = c('Offense', 'Defense')),
                  selectInput(inputId = 'teamstatselected',
                              label = 'Select Stat:',
                              choice = stats)
                )),
              fluidRow(
                box(
                  width = 12, 
                  plotOutput('teamstatsgraph', width = 1000, height = 450)
                  )
              )
      ),
      tabItem(tabName = 'firstdown',
              fluidRow(
                    plotlyOutput('eventual_first_down_probs', height = 575, width = 800)
              )
      ),
      tabItem(tabName = 'teampr',
              fluidRow(
                box(title = 'Median Passing Yards',
                    plotlyOutput('passyards')),
                box(title = 'Median Rushing Yards',
                    plotlyOutput('rushyards'))
              ),
              fluidRow(
                box(title = 'Pass/Rush Decisions vs Field Position',
                    plotlyOutput('playtype_decision_vs_fieldpos')),
                box(title = 'Pass/Rush Success vs Field Position',
                    plotlyOutput('playtype_success_vs_fieldpos'))
              )
              ), 
      tabItem(tabName = 'receiver', 
              fluidRow(
                box(
                  title = 'Receiver',
                  uiOutput("receiverselected"),
                  selectInput(inputId = 'receiverstatselected',
                              label = 'Breakdown of Touches By:',
                              choices = c('Down', 'YardsToFirst', 'YardLine'))
                )),
              fluidRow(
                box(
                  width = 6, plotOutput('receivergraph1')
                ),
                box(
                  width = 6, plotOutput('receivergraph2')
                )
              )),
      tabItem(tabName = 'rusher', 
              fluidRow(
                box(
                  title = 'Running Back',
                  uiOutput("rusherselected"),
                  selectInput(inputId = 'rusherstatselected',
                              label = 'Breakdown of Touches By:',
                              choices = c('Down', 'YardsToFirst', 'YardLine'))
                  )),
              fluidRow(
                box(
                  width = 6, plotOutput('rushergraph1')
                ),
                box(
                  width = 6, plotOutput('rushergraph2')
                )
              )
      )))))
