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


header <- dashboardHeader(
  title = "CRISPRepo"
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(text = "Genome-wide Screens", 
             tabName = "gwsSidebar",startExpanded=TRUE,
             menuSubItem(text = "Gene Search", tabName = "gwsSearchTab", selected = TRUE), 
             menuSubItem(text = "Guide Search", tabName = "gwsCompareTab")),
    menuItem(text = "Libraries", tabName = "libSidebar")
  )
)

body <- dashboardBody(

  tabItems(
    
    # Genome-wide Screens
    tabItem(tabName = "gwsSearchTab", width = NULL, 
            fluidRow(
              column(width = 9, 
                     box(width = NULL, solidHeader = TRUE, dataTableOutput("gwsGeneTable"))), 
              column(width = 3,
                     fluidRow(column(width = 6,
                                     box(width = NULL, solidHeader = TRUE,
                                   radioButtons("gwsSpeciesSelect", label = h3("Species:"),
                                                choices = list("Human" = "human", "Mouse" = "mouse"), 
                                                selected = "human")
                                  )),
                              column(width = 6,
                              box(width = NULL, solidHeader = TRUE, 
                                  radioButtons("gwsIndexRadio", label = h3("Index:"),
                                               choices = list("Log-fold change" = "lfc", "Effect" = "effect"), 
                                               selected = "lfc")
                              ))
                     ),
                     
                     box(width = NULL, solidHeader = TRUE, 
                         selectizeInput(inputId = "gwsGeneSelect",
                                         label = "Gene:",
                                         choices = NULL,
                                         multiple = TRUE,
                                         selected = NULL)
                         ),
                     box(width = NULL, solidHeader = TRUE, 
                         selectizeInput(inputId = "gwsContrastSelect",
                                        label = "Contrast:",
                                        choices = NULL,
                                        multiple = TRUE,
                                        selected = NULL)
                     ),
                     
                     box(width = NULL, solidHeader = TRUE, 
                         sliderInput(inputId = "gwsGeneSelectAUC", label = "AUC", 
                                     min = 0.75, max = 1, value = 0.9, step = 0.01), 
                         sliderInput(inputId = "gwsGeneSelectSSMD", label = "SSMD", 
                                     min = 0, max = 4, step = 0.1, value = 2)),
                     
                     box(width = NULL, solidHeader = TRUE, 
                         infoBoxOutput(width = NULL, "gwsGeneFCAverage")),
                     box(width = NULL, solidHeader = TRUE, 
                                infoBoxOutput(width = NULL, "gwsGeneEffectAverage")),
                     box(width = NULL, solidHeader = TRUE,
                           downloadButton(width = NULL, 
                                          outputId = "gwsGeneButtonDownload",
                                          label = "Download"))
              )
            )
    )
    )
  )
  
dashboardPage(
  header,
  sidebar, 
  body
)