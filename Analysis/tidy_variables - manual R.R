#####################################################################################################
#' Description: Tidy assembled data
#'
#' Input: Rectangular table produced by run_assembly
#'
#' Output: Tidied table
#' 
#' Author: Simon Anastasiadis
#' 
#' Dependencies: dbplyr_helper_functions.R, utility_functions.R, table_consistency_checks.R,
#' overview_dataset.R, summary_confidential.R
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
ASSEMBLED_TABLE = "[exemplar_rectangular]"
# outputs
TIDY_TABLE = "[exemplar_tidy]"

# controls
DEVELOPMENT_MODE = FALSE
VERBOSE = "details" # {"all", "details", "heading", "none"}

## setup ------------------------------------------------------------------------------------------

setwd(ABSOLUTE_PATH_TO_TOOL)
source("utility_functions.R")
source("dbplyr_helper_functions.R")
source("table_consistency_checks.R")
source("overview_dataset.R")
source("summary_confidential.R")
setwd(ABSOLUTE_PATH_TO_ANALYSIS)

## access dataset ---------------------------------------------------------------------------------

run_time_inform_user("GRAND START", context = "heading", print_level = VERBOSE)

db_con = create_database_connection(database = "IDI_Sandpit")

working_table = create_access_point(db_con, SANDPIT, OUR_SCHEMA, ASSEMBLED_TABLE)

if(DEVELOPMENT_MODE)
  working_table = working_table %>% filter(identity_column %% 100 == 0)

## error checking ---------------------------------------------------------------------------------

run_time_inform_user("error checks begun", context = "heading", print_level = VERBOSE)

# one person per period
assert_all_unique(working_table, c('identity_column', 'label_summary_period'))
# at least 1000 rows
assert_size(working_table, ">", 1000)

run_time_inform_user("error checks complete", context = "details", print_level = VERBOSE)

## check dataset variables ------------------------------------------------------------------------

run_time_inform_user("summary report on input data", context = "heading", print_level = VERBOSE)
explore_report(working_table, id_column = "identity_column", output_file = "raw_table_report")
run_time_inform_user("summary report complete", context = "details", print_level = VERBOSE)

## prep / cleaning in SQL -------------------------------------------------------------------------

working_table = working_table %>%
  # require people have a region
  filter(!is.na(region)) %>%
  
  # combine some histogram'ed variables
  collapse_indicator_columns(prefix = "sex_code=", yes_values = 1, label = "sex_code") %>%
  collapse_indicator_columns(prefix = "urban_rural=", yes_values = 1, label = "urban_rural") %>%
  
  # clean income
  mutate(
    # income with zeros (missing income --> 0 income)
    income_w_zeros = ifelse(is.na(total_taxable_income), 0, total_taxable_income),
    # positive income only negative income
    income_positive = ifelse(total_taxable_income > 1, total_taxable_income, NA),
    # earns income indicator
    income_any = ifelse(total_taxable_income > 1, 1, 0)
  ) %>%

    # age at end of 2020
  mutate(age = 2020 - birth_year) %>%
  # age categories
  mutate(age_cat = case_when(
    00 <= age & age < 10 ~ "00_to_09",
    10 <= age & age < 20 ~ "10_to_19",
    20 <= age & age < 30 ~ "20_to_29",
    30 <= age & age < 40 ~ "30_to_39",
    40 <= age & age < 50 ~ "40_to_49",
    50 <= age & age < 60 ~ "50_to_59",
    60 <= age & age < 70 ~ "60_to_69",
    70 <= age & age < 80 ~ "70_to_79",
    80 <= age ~ "80_up"
  )) %>%
  
  # drop unrequired columns
  select(-label_identity, -summary_period_start_date, -summary_period_end_date, -label_summary_period)

## write for output -------------------------------------------------------------------------------

run_time_inform_user("saving output table", context = "heading", print_level = VERBOSE)
written_tbl = write_to_database(working_table, db_con, SANDPIT, OUR_SCHEMA, TIDY_TABLE, OVERWRITE = TRUE)
# index
run_time_inform_user("indexing", context = "details", print_level = VERBOSE)
create_nonclustered_index(db_con, SANDPIT, OUR_SCHEMA, TIDY_TABLE, "identity_column")
# compressd
run_time_inform_user("compressing", context = "details", print_level = VERBOSE)
compress_table(db_con, SANDPIT, OUR_SCHEMA, TIDY_TABLE)

## review tidied dataset --------------------------------------------------------------------------

run_time_inform_user("summary report on tidied data", context = "heading", print_level = VERBOSE)
explore_report(working_table, id_column = "identity_column", output_file = "clean_table_report")
run_time_inform_user("summary report complete", context = "details", print_level = VERBOSE)

## conclude ---------------------------------------------------------------------------------------

# close connection
close_database_connection(db_con)
run_time_inform_user("grand completion", context = "heading", print_level = VERBOSE)
