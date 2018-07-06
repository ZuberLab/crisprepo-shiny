# crisprepo-shiny

# Copyright (c) 2018 Tobias Neumann, Jesse Lipp.
# 
# crisprepo-shiny is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# crisprepo-shiny is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

function(input, output, session) {
  
  ### Genome-wide Screens
  
  # Gene Search
  
  output$gwsGeneTable <- renderDataTable({
    
    if (nrow(gwsGeneTableReactive()) > 0) {
      print(gwsGeneTableReactive())
      gwsGeneTableReactive() %>% 
        select(contrast_id, gene_id, hgnc_symbol, input$gwsIndexRadio) %>%
        spread(contrast_id, input$gwsIndexRadio) %>% 
        arrange(gene_id)
    }

  }, 
  filter = "bottom", 
  options = list(pageLength = 50,
                 lengthMenu = c(50, 100, 200)))
  
  gwsGeneList <- reactive({
    features %>%
      filter(library_id %in% (
        pheno %>% filter(species == input$gwsSpeciesSelect) %>%
          select(library_id) %>% 
          distinct() %>%
          .$library_id)
      ) %>% select(hgnc_symbol) %>%
      distinct() %>%
      .$hgnc_symbol
  })
  
  gwsContrastList <- reactive({
    contrasts %>%
      filter(species ==  input$gwsSpeciesSelect) %>%
      select(contrast_id) %>%
      distinct() %>%
      .$contrast_id
  })
  
  observeEvent(input$gwsSpeciesSelect, {
    updateSelectizeInput(session, 'gwsGeneSelect', choices = gwsGeneList(), server = TRUE) 
    updateSelectizeInput(session, 'gwsContrastSelect', choices = gwsContrastList(), server = TRUE) 
  })
  
  gwsGeneTableReactive <- reactive({
    
    presel = features %>%
      filter(hgnc_symbol %in% input$gwsGeneSelect) %>%
      select(gene_id) %>% distinct %>% .$gene_id

     con %>%
       tbl("gene_stats") %>% 
       filter(gene_id %in% presel, contrast_id %in% input$gwsContrastSelect) %>%
       left_join(con %>% tbl("contrasts"), by = "contrast_id") %>%
       filter(auc >= input$gwsGeneSelectAUC) %>%
       filter(abs(ssmd) >= input$gwsGeneSelectSSMD) %>%
       left_join(con %>% tbl("features"), by = "gene_id") %>%
       select(contrast_id, gene_id, lfc, effect, hgnc_symbol) %>%
       distinct() %>%
       collect()

  })
  
  output$gwsGeneFCAverage <- renderInfoBox({
    infoBox(title = "Average Fold-change", 
            value = gwsGeneTableReactive() %>% 
              summarize(value = round(mean(lfc, na.rm = TRUE), 3)) %>% 
              .$value)
  })
  
  output$gwsGeneEffectAverage <- renderInfoBox({
    infoBox(title = "Average Effect", 
            value = gwsGeneTableReactive() %>% 
              summarize(value = round(mean(effect, na.rm = TRUE), 3)) %>% 
              .$value)
  })
  
  output$gwsGeneButtonDownload <- downloadHandler(
    filename = function() {
      paste0(paste(input$gwsGeneSelect,collapse="_"), ".txt")
    },
    content = function(file) {
      gwsGeneTableReactive() %>% write_tsv(file)
    }
  )
}