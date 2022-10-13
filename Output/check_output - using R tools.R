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
#' 2022-09-30 SA v1 for exemplar
#####################################################################################################

## parameters -------------------------------------------------------------------------------------

# locations
ABSOLUTE_PATH_TO_TOOL <- "~/Network-Shares/DataLabNas/MAA/MAA20XX-YY/Exemplar project/Tools/Dataset Assembly Tool"
ABSOLUTE_PATH_TO_ANALYSIS <- "~/Network-Shares/DataLabNas/MAA/MAA20XX-YY/Exemplar project/Output"

# inputs
age_csv_file = "age confidentialised.csv"
income_csv_file = "income confidentialised.csv"

submission_file_w_raw = "summaries by region_RAW NOT FOR RELEASE.xlsx"
submission_file_for_release = "summaries by region.xlsx"

## setup ------------------------------------------------------------------------------------------

setwd(ABSOLUTE_PATH_TO_TOOL)
source("utility_functions.R")
source("summary_confidential.R")
source("check_confidentiality.R")
setwd(ABSOLUTE_PATH_TO_ANALYSIS)


## check output confidentialised correctly --------------------------------------------------------

#### load files
age_summary_conf = read.csv(age_csv_file)
income_summary_conf = read.csv(income_csv_file)

#### ensure correct data types
age_summary_conf = mutate(
  age_summary_conf,
  raw_count = as.numeric(raw_count),
  conf_count = as.numeric(conf_count)
)

income_summary_conf = mutate(
  income_summary_conf,
  raw_count = as.numeric(raw_count),
  raw_sum = as.numeric(raw_sum),
  conf_count = as.numeric(conf_count),
  conf_sum = as.numeric(conf_sum)
)

#### drop 'x' column from row numbers
# skip if data does not contain row numbers
age_summary_conf = select(age_summary_conf, -X)
income_summary_conf = select(income_summary_conf, -X)

#### rounding to base 3
check_rounding_to_base_df(age_summary_conf, "conf_count")
check_rounding_to_base_df(income_summary_conf, "conf_count")

#### rounding to base 3 and randomness of rounding
check_random_rounding(age_summary_conf, raw_col = "raw_count", conf_col = "conf_count")
check_random_rounding(income_summary_conf, raw_col = "raw_count", conf_col = "conf_count")

#### suppression of small counts
check_small_count_suppression(age_summary_conf, suppressed_col = "conf_count", threshold = 6, count_col = "raw_count")
check_small_count_suppression(income_summary_conf, suppressed_col = "conf_count", threshold = 6, count_col = "raw_count")
check_small_count_suppression(income_summary_conf, suppressed_col = "conf_sum", threshold = 20, count_col = "raw_count")

#### check zero counts handled consistent with 1-5 counts
# May not pass as we know every region does not have every type of urban/rural area
check_absence_of_zero_counts(age_summary_conf, "conf_count")
check_absence_of_zero_counts(income_summary_conf, "conf_count")

# View some of the missing rows
check_absence_of_zero_counts(age_summary_conf, "conf_count", print_on_fail = TRUE)
check_absence_of_zero_counts(income_summary_conf, "conf_count", print_on_fail = TRUE)
# Only some rows that cause failure are returned
# So just viewing these missing rows is not sufficient to be confident data is safe


## check prepared files are ready for submission --------------------------------------------------

#### load files
# skip = 1, as first row is not part of results table
income_w_raw = readxl::read_xlsx(submission_file_w_raw, sheet = "income", skip = 1)
income_safe = readxl::read_xlsx(submission_file_for_release, sheet = "income", skip = 1)

age_w_raw = readxl::read_xlsx(submission_file_w_raw, sheet = "age", skip = 1)
age_safe = readxl::read_xlsx(submission_file_for_release, sheet = "age", skip = 1)

#### ensure correct data types
income_w_raw = mutate(
  income_w_raw,
  `RAW num_w_income` = as.numeric(`RAW num_w_income`),
  `RAW total_income` = as.numeric(`RAW total_income`),
  num_w_income = as.numeric(num_w_income),
  total_income = as.numeric(total_income)
)

income_safe = mutate(
  income_safe,
  `RAW num_w_income` = as.numeric(`RAW num_w_income`),
  `RAW total_income` = as.numeric(`RAW total_income`),
  num_w_income = as.numeric(num_w_income),
  total_income = as.numeric(total_income)
)

age_w_raw = mutate(
  age_w_raw,
  `RAW num` = as.numeric(`RAW num`),
  num = as.numeric(num)
)

age_safe = mutate(
  age_safe,
  `RAW num` = as.numeric(`RAW num`),
  num = as.numeric(num)
)

#### confirm consistency of files
dplyr::all_equal(
  select(age_w_raw, -starts_with("RAW")),
  select(age_safe, -starts_with("RAW")),
  ignore_col_order = TRUE,
  ignore_row_order = TRUE,
  convert = TRUE
)

dplyr::all_equal(
  select(income_w_raw, -starts_with("RAW")),
  select(income_safe, -starts_with("RAW")),
  ignore_col_order = TRUE,
  ignore_row_order = TRUE,
  convert = TRUE
)

#### RR3
check_random_rounding(income_w_raw, raw_col = "RAW num_w_income", conf_col = "num_w_income")
check_random_rounding(age_w_raw, raw_col = "RAW num", conf_col = "num")

#### suppression
check_small_count_suppression(income_w_raw, suppressed_col = "num_w_income", threshold = 6, count_col = "RAW num_w_income")
check_small_count_suppression(income_w_raw, suppressed_col = "total_income", threshold = 20, count_col = "RAW num_w_income")
check_small_count_suppression(age_w_raw, suppressed_col = "num", threshold = 6, count_col = "RAW num")

#### zeros and small counts
# this example will error as we have changed output format
check_absence_of_zero_counts(income_safe, "counf_count")
check_absence_of_zero_counts(age_safe, "counf_count")
# proceed to manual check
