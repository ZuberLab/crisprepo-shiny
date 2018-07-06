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

library(shinydashboard)
library(tidyverse)
library(stringr)
library(DT)
#library(screentools)
library(rlang)
library(viridis)
library(forcats)

con <- DBI::dbConnect(drv = RSQLite::SQLite(), dbname = "../../../../GROUPS/Bioinfo/CRISPRepo/screen-db/screen.db")

pheno <- con %>%
  tbl("pheno") %>%
  collect()

libraries <- pheno %>%
  select(library_id) %>%
  distinct %>%
  .$library_id

species <- pheno %>%
  select(species) %>%
  distinct %>%
  .$species

features <- con %>%
  tbl("features") %>%
  select(gene_id, hgnc_symbol, library_id) %>%
  distinct %>% collect()

contrasts <- con %>%
  tbl("contrasts") %>%
  collect()
