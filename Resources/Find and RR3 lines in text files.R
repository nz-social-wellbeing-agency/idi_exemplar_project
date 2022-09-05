###############################################################################
#' Find and RR3 specific lines in text files
#' Simon Anastasiadis
#' 2022-08-28
#' 
#' Purpose:
#' 
#' Some analytic outputs are written to text files. These outputs can include
#' counts of records or people that should be subject to RR3. However, text
#' files are not a convenient format to apply random rounding to directly.
#' This file searches through a text file for numbers that may require rounding
#' and asked the user for each number whether to apply RR3.
#' 
#' 
#' Instructions:
#' 
#' 1) Enter the path to where the file you want to process is located.
#' 2) Enter the name of the input file, including its extension.
#' 3) Give a name for the output file, including its extension.
#'    (if this file exists, it will be overwritten)
#' 4) Give a name for the log file.
#'    A summary of the process will be written to this file.
#'    (if this file exists, it will be overwritten)
#' 5) Enter text that will be found on the lines that you want to check.
#'    For example, suppose the input includes "number obs = 12345",
#'    then we would give "obs" or "number" to make the code check this line.
#' 6) Click "Source" (top right corner) or press Ctrl+Shift+S to run.
#' 7) For each number found, a popup box will ask whether you want to apply
#'    random rounding.
#'    Click "yes" or "no" to decide for each number.
#'    Clicking "cancel" or crossing off the popup box will abort the process.
#' 8) Review the outfile and log files to confirm random rounding has been
#'    applied as intended.
#' 
#' Tips:
#' 
#' - If you hold, Alt you can use the "y" and "n" keys as shortcuts for
#'   "yes" and "no".
#' - Include the log file in your output submission to make things easier
#'   for the checkers to review.
#' 
###############################################################################

## USER INPUTS ----------------------------------------------------------------

# inputs
file_path_to_input = "~/Network-Shares/DataLabNas/MAA/MAA20XX-YY/folder/path/here"
name_of_input_file = "file name here.txt"
# Note, R uses / slashes for file paths, not \ slashes.

# output
name_of_output_file = "test_output.txt"
name_of_log_file = "test_log.txt"

# text to search for
lines_must_contain_this_text = c(
  "obs",
  "Obs",
  "num",
  "Num",
  "n =",
  "N ="
)
# Lines that do not contain any of these patterns will be skipped over.
# Use "" (a blank string) to check every line.
# Avoid special characters []().+^$ unless familiar with regular expressions.

# ignore numbers with decimal places (e.g. 1,234.56)
ignore_numbers_w_decimals = TRUE
# If TRUE, numbers with decimals will not be considered for random rounding.
# If FALSE, numbers with decimals will be presented to the researcher for RR3.

## END OF USER INPUTS ---------------------------------------------------------

## Prepare Function -----------------------------------------------------------

find_and_rr3_specific_lines = function(
    file_path_to_input,
    name_of_input_file,
    name_of_output_file,
    name_of_log_file,
    lines_must_contain_this_text,
    ignore_numbers_w_decimals
){
  ## setup ----------------------------------------------------------
  wd = getwd()
  setwd(file_path_to_input)
  
  # file access
  in_con = file(name_of_input_file, "rt")
  out_con = file(name_of_output_file, "wt")
  log_con = file(name_of_log_file, "wt")
  # ensure files close (even on error)
  on.exit(close(in_con))
  on.exit(close(out_con), add = TRUE)
  on.exit(close(log_con), add = TRUE)
  
  ## subfunctions ---------------------------------------------------
  
  # random rounding
  apply_rr3 = function(input_vector, base = 3){
    probs = runif(length(input_vector))
    
    remainder_vector = input_vector %% base
    prob_round_down = (base - remainder_vector) / base
    ind_round_down = probs < prob_round_down
    
    return(input_vector + base - remainder_vector - base * ind_round_down)
  }
  
  # pad string to specified length with spaces on the front
  pad_spaces = function(text, required_length){
    if(nchar(text) >= required_length)
      return(text)
    
    head = paste0(rep(" ", required_length - nchar(text)), collapse = "")
    return(paste0(head, text))
  }
  
  ## search ---------------------------------------------------------
  line_number = 0
  breaker = FALSE
  
  while( TRUE ){
    # read next line, stop if end of file
    in_line = readLines(in_con, n = 1)
    out_line = in_line
    
    # exit at file end or on breaker
    if(breaker || length(in_line) == 0){
      break
    }
    
    line_number = line_number + 1
    
    # if line contains any text of interest
    if(any(sapply(lines_must_contain_this_text, grepl, x = in_line))){
      # indicator for any edit
      any_edit = FALSE
      # break line apart
      matches = gregexpr("[0-9,.]*[0-9]", in_line)[[1]]
      start_positions = as.numeric(matches)
      end_positions = start_positions + attributes(matches)$match.length
      all_positions = sort(c(1, start_positions, end_positions, nchar(in_line) + 1))
      
      split_text = sapply(
        1:(length(all_positions) - 1),
        function(ii){ 
          substr(in_line, all_positions[ii], all_positions[ii + 1] - 1)
        }
      )
      
      # is each split text component numeric
      is_number_as_text = grepl("[0-9,.]*[0-9]", split_text)
      
      # loop through each component of the text line
      for(ss in 1:length(split_text)){
        if(!is_number_as_text[ss])
          next
        
        text_as_number = as.numeric(gsub(",", "", split_text[ss]))
        
        # optional skip if decimal
        if(ignore_numbers_w_decimals && text_as_number %% 1 != 0)
          next
        
        # ask user for decision
        msg = glue::glue(
          "On line {line_number} found text:\n",
          "{in_line}\n",
          "Apply RR3 to {text_as_number}?"
        )
        decision = tcltk::tk_messageBox("yesnocancel", msg)
        
        if(decision == "yes"){
          # set indicator that an edit has been made
          any_edit = TRUE
          # apply RR3
          new_number = apply_rr3(text_as_number)
          split_text[ss] = pad_spaces(new_number, nchar(split_text[ss]))
        }
        
        # exit if cancelled
        if(decision == "cancel"){ breaker = TRUE; break }
      }
      
      out_line = paste0(split_text, collapse = "")
      
      # write log if any changes on this line
      if(any_edit){
        writeLines(paste0("input line ",line_number, " processed:"), log_con)
        writeLines(in_line, log_con)
        writeLines("replaced with RR3 version:", log_con)
        writeLines(out_line, log_con)
        writeLines("------------------------------------", log_con)
      }
    }
    # output line
    writeLines(out_line, out_con)
  }
  
  ## conclude -------------------------------------------------------
  setwd(wd)
}

## Execution ------------------------------------------------------------------

find_and_rr3_specific_lines(
  file_path_to_input = file_path_to_input,
  name_of_input_file = name_of_input_file,
  name_of_output_file = name_of_output_file,
  name_of_log_file = name_of_log_file,
  lines_must_contain_this_text = lines_must_contain_this_text,
  ignore_numbers_w_decimals = ignore_numbers_w_decimals
)
