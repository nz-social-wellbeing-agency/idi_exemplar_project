#####################################################################################################
#' Description: Output summarised results
#'
#' Input: Tidied table
#'
#' Output: Excel summary files
#' 
#' Author: Simon Anastasiadis
#' 
#' Dependencies: dbplyr_helper_functions.R, utility_functions.R
#' 
#' Notes: 
#' 
#' Issues:
#' 
#' History (reverse order):
#' 2021-10-27 SA v1 for exemplar
#####################################################################################################

## parameters -------------------------------------------------------------------------------------

# locations
ABSOLUTE_PATH_TO_TOOL <- "~/Network-Shares/DataLabNas/MAA/MAA20XX-YY/Exemplar project/Tools/Dataset Assembly Tool"
ABSOLUTE_PATH_TO_ANALYSIS <- "~/Network-Shares/DataLabNas/MAA/MAA20XX-YY/Exemplar project/Analysis"
SANDPIT = "[IDI_Sandpit]"
USERCODE = "[IDI_UserCode]"
OUR_SCHEMA = "[DL-MAA20XX-YY]"

# inputs
TIDY_TABLE = "[exemplar_tidy]"
# outputs
OUTPUT_FOLDER = "../Output/"

# controls
DEVELOPMENT_MODE = FALSE
VERBOSE = "details" # {"all", "details", "heading", "none"}

## setup ------------------------------------------------------------------------------------------

setwd(ABSOLUTE_PATH_TO_TOOL)
source("utility_functions.R")
source("dbplyr_helper_functions.R")
setwd(ABSOLUTE_PATH_TO_ANALYSIS)

## access dataset ---------------------------------------------------------------------------------

run_time_inform_user("GRAND START", context = "heading", print_level = VERBOSE)

db_con = create_database_connection(database = "IDI_Sandpit")
working_table = create_access_point(db_con, SANDPIT, OUR_SCHEMA, TIDY_TABLE)

if(DEVELOPMENT_MODE)
  working_table = working_table %>% filter(identity_column %% 100 == 0)

## summarise dataset ------------------------------------------------------------------------------

run_time_inform_user("summarising datasets", context = "heading", print_level = VERBOSE)

age_summary = working_table %>%
  group_by(region, urban_rural, age_cat) %>%
  summarise(num = n()) %>%
  collect()

income_summary = working_table %>%
  group_by(region, urban_rural) %>%
  summarise(num_w_income = sum(ifelse(!is.na(income_positive), 1, 0), na.rm = TRUE),
            total_income = sum(income_positive, na.rm = TRUE)) %>%
  collect()

run_time_inform_user("complete", context = "details", print_level = VERBOSE)

## write for output -------------------------------------------------------------------------------

run_time_inform_user("writing excel output", context = "heading", print_level = VERBOSE)

run_time_inform_user("age summary", context = "details", print_level = VERBOSE)
write.csv(age_summary, file = paste0(OUTPUT_FOLDER, "age summary.csv"))

run_time_inform_user("income summary", context = "details", print_level = VERBOSE)
write.csv(income_summary, file = paste0(OUTPUT_FOLDER, "income summary.csv"))

run_time_inform_user("complete", context = "details", print_level = VERBOSE)

## conclude ---------------------------------------------------------------------------------------

# close connection
close_database_connection(db_con)
run_time_inform_user("grand completion", context = "heading", print_level = VERBOSE)
