#####################################################################################################
#' Description: Output summarised results
#'
#' Input: CSV summary files
#'
#' Output: Confidence files are safe for release
#' 
#' Author: Simon Anastasiadis
#' 
#' Dependencies: utility_functions.R, summary_confidential.R, check_confidentiality.R
#' 
#' Notes: 
#' 
#' Issues:
#' 
#' History (reverse order):
#' 2022-09-06 SA v1 for exemplar
#####################################################################################################

## parameters -------------------------------------------------------------------------------------

# locations
ABSOLUTE_PATH_TO_TOOL <- "~/Network-Shares/DataLabNas/MAA/MAA20XX-YY/Exemplar project/Tools/Dataset Assembly Tool"
ABSOLUTE_PATH_TO_ANALYSIS <- "~/Network-Shares/DataLabNas/MAA/MAA20XX-YY/Exemplar project/Output"

# inputs
AGE_CSV_FILE = "age confidentialised.csv"
INCOME_CSV_FILE = "income confidentialised.csv"

## setup ------------------------------------------------------------------------------------------

setwd(ABSOLUTE_PATH_TO_TOOL)
source("utility_functions.R")
source("summary_confidential.R")
source("check_confidentiality.R")
setwd(ABSOLUTE_PATH_TO_ANALYSIS)

## access files -----------------------------------------------------------------------------------

age_summary_conf = read.csv(AGE_CSV_FILE)
income_summary_conf = read.csv(INCOME_CSV_FILE)

## check confidentiality in a single step ---------------------------------------------------------

check_confidentialised_results(age_summary_conf)
check_confidentialised_results(income_summary_conf)

## check confidentiality focused step by step -----------------------------------------------------

# rounding to base 3
#
# Returns TRUE if the column only contains values rounded to base 3.
check_rounding_to_base_df(age_summary_conf, "conf_count")
check_rounding_to_base_df(income_summary_conf, "conf_count")

# rounding to base 3 and randomness of rounding
#
# Returns TRUE if the column only contains values rounded to base 3,
# and warns if the rounding does not appear random.
check_random_rounding(age_summary_conf, raw_col = "raw_count", conf_col = "conf_count")
check_random_rounding(income_summary_conf, raw_col = "raw_count", conf_col = "conf_count")

# suppression of small counts
#
# Returns TRUE if the column contains no values beneath the threshold
check_small_count_suppression(age_summary_conf, suppressed_col = "conf_count", threshold = 6, count_col = "raw_count")
check_small_count_suppression(income_summary_conf, suppressed_col = "conf_count", threshold = 6, count_col = "raw_count")
check_small_count_suppression(income_summary_conf, suppressed_col = "conf_sum", threshold = 20, count_col = "raw_count")

# check zero counts handled consistent with 1-5 counts
#
# Not testable in this application as we do not expect every region to have every type of urban/rural area
#
# check_absence_of_zero_counts(age_summary_conf, "counf_count", print_on_fail = FALSE)
# check_absence_of_zero_counts(income_summary_conf, "counf_count", print_on_fail = FALSE)
