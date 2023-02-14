library(tidyverse)
library(crayon)
options(dplyr.summarise.inform=F)

e1 <- readRDS("001-00-e1-data.RDS")

# check dimensions
message(blue("Testing for correct dimensions ..."))
message(blue(dim(e1)[1], "rows with", dim(e1)[2], "columns"))
message(blue("58603 rows are expected"))
if(dim(e1)[1] == 58603){message(green $ bold("PASS\n"))}
if(dim(e1)[1] != 58603){message(red $ bold("FAIL\n"))}

# test for duplicated rows
message(blue("Testing for duplicate rows ..."))
message(blue("number of duplicated rows is", sum(duplicated(e1))))
if(sum(duplicated(e1) == 0)){message(green $ bold("PASS\n"))}
if(sum(duplicated(e1) != 0)){message(red $ bold("FAIL\n"))}

# test for strictly increasing time (tm)
message(blue("Testing for row order correctness ..."))
test_row_sanity <- 
  e1 %>% 
  group_by(ex,pp,te,rr,tb) %>% 
  mutate(validrow = tm > lag(tm, default=TRUE)) %>% 
  group_by(ex,pp,te,rr,tb) %>% 
  summarise(nfails=sum(validrow==FALSE)) %>% 
  group_by(ex,pp,te,rr,tb) %>% 
  summarise(failed_trial = as.logical(sum(nfails>0))) %>% 
  ungroup()
n_bad_row_order_trials <- test_row_sanity %>% 
  summarise(n_bad_row_order_trials=sum(failed_trial)) %>% 
  pull()
message(blue("Number of trials that don't obey row order on time stamp is", n_bad_row_order_trials))
if(n_bad_row_order_trials == 0){message(green $ bold("PASS\n"))}
if(n_bad_row_order_trials != 0){message(red $ bold("FAIL\n"))}

# test for strictly increasing ix
message(blue("Testing whether the index skips ..."))
test_row_ix <-
  e1 %>% 
  group_by(pp,te) %>% 
  mutate(ok = ix==lag(ix)+1) %>% 
  summarise(badix=sum(ok==FALSE,na.rm=TRUE)) %>% 
  group_by(pp,te) %>%
  summarise(badix_trial=badix>0) %>% 
  ungroup()
n_bad_index_trials <- test_row_ix %>% 
  summarise(n_bad_ix_trials=sum(badix_trial)) %>% 
  pull()
message(blue("Number of trials that have skips in index is", n_bad_index_trials))
if(n_bad_index_trials == 0){message(green $ bold("PASS\n"))}
if(n_bad_index_trials != 0){message(red $ bold("FAIL\n"))}

