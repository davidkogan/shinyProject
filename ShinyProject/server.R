## server.R ##

shinyServer(function(input, output, session){
  
  output$teamstatsgraph <- renderPlot({
    g = nfl %>%
      filter(., !is.na(Offense), !is.na(Defense)) %>%
      mutate_(., Team = input$offensedefense) %>%
      group_by(., Team) %>%
      summarise_(., Total = interp(~sum(var), 
                                   var = as.name(input$teamstatselected)))
    g = droplevels(g)
    g$Team= reorder(g$Team, g$Total)
    g %>% 
      ggplot(., aes(x=Team,
                        y=Total, 
                        fill = Team)) +
      geom_col() +
      coord_flip() + 
      geom_text(aes(y = 1.01 * Total, label=paste(Team, Total)), fontface = 'bold') +
      xlab('Team') + ylab(input$teamstatselected)
  })
  
  output$playtype_decision_vs_fieldpos <- renderPlotly({
    nfl %>% 
      filter(., Offense == input$team, 
             PlayType %in% c('Run', 'Pass')) %>%
      group_by(., YardLine) %>%
      summarise(., PassRatio = sum(PlayType == 'Pass') / n()) %>%
      ggplot(., aes(x = YardLine, y = PassRatio)) + geom_smooth()
  })
  
  output$playtype_success_vs_fieldpos <- renderPlotly({
    nfl %>%
      filter(., Offense == input$team, 
             PlayType %in% c('Run', 'Pass')) %>%
      group_by(., YardLine, PlayType) %>%
      summarise(., AvgYards = median(Yards.Gained)) %>%
      ggplot(., aes(x=YardLine, y=AvgYards)) + geom_smooth() + facet_grid(.~PlayType)
  })
  
  output$eventual_first_down_probs <- renderPlotly({
    #Probabilities on fourth down
    fourthprobs = nfl %>%
      filter(., Offense == input$team, Down == 4, YardsToFirst <= 20) %>%
      group_by(., YardsToFirst) %>%
      summarise(., prob4 = sum(Yards.Gained >= YardsToFirst) / n())
    fourthprobs = rbind(c(0, 1), fourthprobs)
    for(i in 1:20) {
      if(!(i %in% fourthprobs[[1]])){
        fourthprobs = insertRow(fourthprobs, c(i, fourthprobs[i-1,2]), i+1)
      }
    }
    fourthprobs = fourthprobs[!is.na(fourthprobs$YardsToFirst),]
    #Probabilities on third down
    thirdprobs = nfl %>%
      filter(., Offense == input$team, PlayType %in% c('Run', 'Pass'), 
             Down == 3, YardsToFirst <= 20) %>%
      mutate(., ydsshort = ifelse(Yards.Gained <= YardsToFirst, YardsToFirst - Yards.Gained, 0)) %>%
      group_by(., YardsToFirst, ydsshort) %>%
      summarise(., n = n()) %>%
      mutate(., prob = n / sum(n)) %>%
      filter(., ydsshort <= 20) %>%
      select(., YardsToFirst, ydsshort, prob)
    thirdprobs$probnext =
      fourthprobs$prob4[match(thirdprobs$ydsshort, fourthprobs$YardsToFirst)]
    thirdprobs = thirdprobs %>%
      group_by(., YardsToFirst) %>%
      summarise(., prob3 = sum(prob*probnext))
    thirdprobs = rbind(c(0, 1), thirdprobs)
    for(i in 1:20) {
      if(!(i %in% thirdprobs[[1]])){
        thirdprobs = insertRow(thirdprobs, c(i, thirdprobs[i-1,2]), i+1)
      }
    }
    thirdprobs = thirdprobs[!is.na(thirdprobs$YardsToFirst),]
    #Probabilities on second down
    secondprobs = nfl %>%
      filter(., Offense == input$team, PlayType %in% c('Run', 'Pass'), 
             Down == 2, YardsToFirst <= 20) %>%
      mutate(., ydsshort = ifelse(Yards.Gained <= YardsToFirst, YardsToFirst - Yards.Gained, 0)) %>%
      group_by(., YardsToFirst, ydsshort) %>%
      summarise(., n = n()) %>%
      mutate(., prob = n / sum(n)) %>%
      filter(., ydsshort <= 20) %>%
      select(., YardsToFirst, ydsshort, prob)
    secondprobs$probnext =
      thirdprobs$prob3[match(secondprobs$ydsshort, thirdprobs$YardsToFirst)]
    secondprobs = secondprobs %>%
      group_by(., YardsToFirst) %>%
      summarise(., prob2 = sum(prob*probnext))
    secondprobs = rbind(c(0, 1), secondprobs)
    for(i in 1:20) {
      if(!(i %in% secondprobs[[1]])){
        secondprobs = insertRow(secondprobs, c(i, secondprobs[i-1,2]), i+1)
      }
    }
    secondprobs = secondprobs[!is.na(secondprobs$YardsToFirst),]
    #Probabilities on first down
    firstprobs = nfl %>%
      filter(., Offense == input$team, PlayType %in% c('Run', 'Pass'), 
             Down == 1, YardsToFirst <= 20) %>%
      mutate(., ydsshort = ifelse(Yards.Gained <= YardsToFirst, YardsToFirst - Yards.Gained, 0)) %>%
      group_by(., YardsToFirst, ydsshort) %>%
      summarise(., n = n()) %>%
      mutate(., prob = n / sum(n)) %>%
      filter(., ydsshort <= 20) %>%
      select(., YardsToFirst, ydsshort, prob)
    firstprobs$probnext =
      secondprobs$prob2[match(firstprobs$ydsshort, secondprobs$YardsToFirst)]
    firstprobs = firstprobs %>%
      group_by(., YardsToFirst) %>%
      summarise(., prob1 = sum(prob*probnext))
    firstprobs = rbind(c(0, 1), firstprobs)
    for(i in 1:20) {
      if(!(i %in% firstprobs[[1]])){
        firstprobs = insertRow(firstprobs, c(i, firstprobs[i-1,2]), i+1)
      }
    }
    firstprobs = firstprobs[!is.na(firstprobs$YardsToFirst),]
    
    probfirstDown =
      cbind(firstprobs, secondprobs[2], thirdprobs[2], fourthprobs[2]) %>%
      rename(., YardsToGo = YardsToFirst, 
             '1' = prob1, 
             '2' = prob2, 
             '3' = prob3,
             '4' = prob4) %>%
      gather(., key='Down', value='ProbFirst', 2:5)
    probfirstDown %>%
      ggplot(., aes(x=Down, y=YardsToGo, z=ProbFirst)) +
      geom_tile(aes(fill= ProbFirst)) +
      scale_fill_gradient(low = 'red', high = 'green')
  })
  
  output$passyards <- renderPlotly({
    nfl %>%
      filter(., Offense == input$team, PlayType == 'Pass', YardsToFirst <=20) %>%
      group_by(., Down, YardsToFirst) %>%
      summarise(., AvgYards = median(Yards.Gained)) %>%
      ggplot(., aes(x=Down, y=YardsToFirst, z=AvgYards)) +
      geom_tile(aes(fill=AvgYards)) +
      scale_fill_gradient(low='red', high='green')
  })
  
  output$rushyards <- renderPlotly({
    nfl %>%
      filter(., Offense == input$team, PlayType == 'Run', YardsToFirst <=20) %>%
      group_by(., Down, YardsToFirst) %>%
      summarise(., AvgYards = median(Yards.Gained)) %>%
      ggplot(., aes(x=Down, y=YardsToFirst, z=AvgYards)) +
      geom_tile(aes(fill=AvgYards)) +
      scale_fill_gradient(low='red', high='green')
  })
  
  output$receiverselected <- renderUI({
    selectInput(inputId = 'receiverselected',
                label = 'Select Receiver:',
                choices = receivers[receivers$Team 
                                    == input$team, 'Receiver'])
  })
  
  output$rusherselected <- renderUI({
    selectInput(inputId = 'rusherselected',
                label = 'Select Running Back:',
                choices = rushers[rushers$Team
                                  == input$team, 'Rusher'])
  })
  
  output$receivergraph1 <- renderPlot({
    
    nfl %>%
      filter(., Receiver ==
               input$receiverselected, !is.na(Down), YardsToFirst <= 10) %>%
      group_by_(., 'Receiver', input$receiverstatselected) %>%
      summarize(., touches = n()) %>%
      ungroup(.) %>%
      mutate(., RatioOfTouches = touches / sum(touches)) %>%
      ggplot(., aes_string(x=input$receiverstatselected,
                           y='RatioOfTouches')) +
      geom_col(fill='blue')
    })
  
  output$receivergraph2 <- renderPlot({
    
    nfl %>%
      filter(., Receiver == 
               input$receiverselected, !is.na(Down), YardsToFirst <= 10) %>%
      group_by_(., input$receiverstatselected) %>%
      summarise(., AvgYards = median(Yards.Gained)) %>%
      ggplot(., aes_string(x=input$receiverstatselected,y='AvgYards')) +
      geom_col(fill='blue')
  })
    
  output$rushergraph1 <- renderPlot({
    nfl %>%
      filter(., Rusher ==
               input$rusherselected, !is.na(Down), YardsToFirst <= 10) %>%
      group_by_(., 'Rusher', input$rusherstatselected) %>%
      summarize(., touches = n()) %>%
      ungroup(.) %>%
      mutate(., RatioOfTouches = touches / sum(touches)) %>%
      ggplot(., aes_string(x=input$rusherstatselected,y='RatioOfTouches')) +
      geom_col(fill='blue')
    })
  
  output$rushergraph2 <- renderPlot({
    
    nfl %>%
      filter(., Rusher ==
               input$rusherselected, !is.na(Down), YardsToFirst <= 10) %>%
      group_by_(., input$rusherstatselected) %>%
      summarise(., AvgYards = median(Yards.Gained)) %>%
      ggplot(., aes_string(x=input$rusherstatselected,y='AvgYards')) +
      geom_col(fill='blue')
  })
})