# This script produces all the files required to deploy an SNSF data story. 
# 
# Data story template: https://github.com/snsf-data/datastory_template
# 
# By running this file, the following components of a data story are generated
# and stored in the output directory: 
# 
# 1) a HTML file (self-contained), which contains all visualizations and 
#   images in encoded form, one for every specified language.
# 2) one file "metadata.json", which contains the metadata essential for 
#   the story (including all language versions in one file).
# 
# The files are stored in output/xxx, where xxx stands for the title of the
# data story in English, how it can also be used for the vanity URL to the 
# story, that means: no special characters, only lowercase.

# Unique name of this data story in English (all lowercase, underscore as 
# white-space, no special characters etc.)
datastory_name <- "new-figures-oa-monitoring-2020"

# Language-specific names, do adapt! (used for vanity URL! Format: all 
# lowercase, minus as white-space (!) and no special characters, no special 
# characters etc.)
datastory_name_de <- "open-access-2020-steigerung-um-8-prozentpunkte"
datastory_name_en <- "open-access-in-2020-up-by-8-percentage-points"
datastory_name_fr <- "publications-en-libre-acces-augmentation-de-8-points-2020"

# English title and lead of the story (Mandatory, even if no EN version)
title_en <- "Open Access in 2020: up by 8 percentage points" 
lead_en <- "SNSF-funded research produced a total of 13,938 publications in 2020, 63% of which are freely accessible. Upgrades in monitoring capabilities make the positive trend towards more Open Access (OA) more readily visible." 
# German title and lead of the story (Mandatory, even if no DE version)
title_de <- "Open Access im Jahr 2020: Steigerung um 8 Prozentpunkte" 
lead_de <- "13’938 Publikationen sind 2020 aus SNF-geförderter Forschung hervorgegangen. Davon sind 63% frei zugänglich. Anpassungen im Monitoring machen die positive Entwicklung hin zu mehr Open Access (OA) jetzt schneller sichtbar." 
# French title and lead of the story (Mandatory, even if no FR version)
title_fr <- "Publications en libre accès : augmentation de 8 points en 2020"
lead_fr <- "En 2020, sur les 13 938 publications issues de recherches financées par le FNS, 63 % étaient en libre accès (Open Access, OA). Des adaptations dans le monitoring rendent désormais plus rapidement visible l’évolution positive vers plus d’OA." 
# Contact persons, always (first name + last name)
contact_person <- c("Tobias Philipp", "Julius Mattern")
# Mail address to be displayed as contact persons, put "datastories@snf.ch" for 
# every name of a contact person listed above.
contact_person_mail <- c("datastories@snf.ch", "datastories@snf.ch")
# One of the following categories:  "standard", "briefing", "techreport", 
# "policybrief", "flagship", "figure". Category descriptions are 
datastory_category <- "standard"
# Date, after which the story should be published. Stories not displayed if the 
# date lies in the future. 
publication_date <- "2022-04-27 02:00:00"
# Available language versions in lowercase, possible: "en", "de", "fr".
languages <- c("en", "de", "fr") 
# Whether this story should be a "Feature Story" story
feature_story <- FALSE
# DOI of the story (optional)
doi <- "https://doi.org/10.46446/datastory.new-figures-oa-monitoring-2020" 
# URL to Github page (optional)
github_url <- "https://github.com/snsf-data/datastory_new_figures_oa_monitoring_2020" 
# Put Tag IDs here. Only choose already existing tags. 
tags_ids <- c(10, 40, 220)

# IMPORTANT: Put a title image (as .jpg) into the output directory. 
# example: "output/datastory-template.jpg"

# Install pacman package if needed
if (!require("pacman")) {
  install.packages("pacman")
  library(pacman)
}

# Install snf.datastory package if not available, otherwise load it
if (!require("snf.datastory")) {
  if (!require("devtools")) {
    install.packages("devtools")
    library(devtools)
  }
  install_github("snsf-data/snf.datastory")
  library(snf.datastory)
}

# Load packages
p_load(tidyverse,
       scales, 
       conflicted, 
       jsonlite, 
       here)

# Conflict preferences
conflict_prefer("filter", "dplyr")

# Function to validate a mandatory parameter value
is_valid <- function(param_value) {
  if (is.null(param_value))
    return(FALSE)
  if (is.na(param_value))
    return(FALSE)
  if (str_trim(param_value) == "")
    return(FALSE)
  return(TRUE)
}

# Validate parameters and throw error message when not correctly filled
if (any(!is_valid(datastory_name), 
        !is_valid(title_en),
        !is_valid(title_de),
        !is_valid(title_fr), 
        !is_valid(datastory_category),
        !is_valid(publication_date), 
        length(languages) < 1,
        !is_valid(lead_en), 
        !is_valid(lead_de), 
        !is_valid(lead_fr)))
stop("Incorrect value for at least one of the mandatory metadata values.")

# Create output directory in main directory
if (!dir.exists(here("output")))
  dir.create(here("output"))

# Create story directory in output directory
if (!dir.exists(here("output", datastory_name)))
  dir.create(here("output", datastory_name))

# Create a JSON file with the metadata and save it in the output directory
tibble(
  title_en = title_en, 
  title_de = title_de, 
  title_fr = title_fr, 
  author = paste(contact_person, collapse = ";"), 
  datastory_category = datastory_category, 
  publication_date = publication_date, 
  languages = paste(languages, collapse = ";"),
  short_desc_en = lead_en, 
  short_desc_de = lead_de, 
  short_desc_fr = lead_fr, 
  tags = paste(paste0("T", tags_ids, "T"), collapse = ","), 
  author_url = paste(contact_person_mail, collapse = ";"), 
  top_story = feature_story, 
  github_url = github_url, 
  doi = doi
) %>%  
  toJSON() %>%  
  write_lines(here("output", datastory_name, "metadata.json"))

# Knit HTML output for each language version
for (idx in seq_len(length(languages))) {
  current_lang <- languages[idx]
  output_file <- here("output", datastory_name, 
                      paste0(str_replace_all(
                        get(paste0("datastory_name_", current_lang)), "_", "-"),
                        "-", current_lang, ".html"))
  print(paste0("Generating output for ", current_lang, " version..."))
  rmarkdown::render(
    input = here(paste0(current_lang, ".Rmd")),
    output_file = output_file, 
    params = list(
      title = get(paste0("title_", current_lang)),
      publication_date = publication_date,
      doi = doi
    ),
    envir = new.env()
  )
  
  # # Generate raw text version of each story for the search feature
  # readLines(output_file)

  # # inputFile <- "
  # con  <- file(output_file, open = "r")
  # while (length(oneLine <- readLines(con, n = 1)) > 0) {
  #   myLine <- unlist((strsplit(oneLine, ",")))
  #   print(myLine)
  # }
  # close(con)
}