library(standardize)
library(tidyverse)

e2allsubs = tibble() 
outfilecontent = tibble()
indir = "e2_csvs"
for (infilename in list.files(indir, pattern=".csv$")) {
  infilecontent = read_csv(file.path(indir, infilename), col_types = cols())
  outfilecontent <-
    infilecontent %>%
    filter(bg_type != "practice") %>%
    transmute(
      exp                = 2,
      pid                = as.numeric(substr(participant, 2, 4)),
      V                  = tree_behaviour,
      R                  = resource_distribution,
      L                  = ifelse(flag==2, "fruit", "no_fruit"),
      trial_in_session   = as.numeric(substr(trial,3,4)), # ranges 1 to 40, is trial in session
      trial_in_block     = trial_number, # ranges 1 to 20 for each level of resources
      trial_identity     = bg_name,
      index              = sample,
      time               = secs_elapsed,
      x                  = as.integer(round(x)),
      y                  = as.integer(round(y)),
      tile               = (((row-1) * 16) + col),
      flag               = flag,
      basket             = fruits
    )
  outfilecontent <-
    outfilecontent %>%
    group_by(pid, R, V, trial_in_block) %>%
    arrange(index, .by_group=TRUE) %>%
    mutate(time = time-time[1]) %>%
    filter(flag %in% c(1, 2, 3)) %>%
    # require them to get 14 out of 15 fruit - remove otherwise
    filter(max(basket) >= 14) %>% 
    # remove the second (and any subsequent) *consecutive* duplicates
    filter(is.na(tile != lag(tile)) | tile != lag(tile)) %>%
    # identify as TRUE the second (and any subsequent) duplicates whether they are 
    # consecutive or not (i.e, memory errors, now called revisits)
    mutate(revisit      = as.numeric(duplicated(tile))) %>%
    mutate(revisits     = sum(revisit)) %>%
    mutate(numtrees     = n()) %>%
    mutate(trialdur     = round(max(time),2)) %>%
    mutate(itdistance   = round(sqrt((lead(x)-x)^2 + (lead(y)-y)^2), 2)) %>%  # inter-tree distance
    mutate(index        = seq_along(index)) %>%
    ungroup()
  # how many trees to get each fruit?
  outfilecontent$ntreesperfruit = NA
  j = 0
  for (k in seq_along(outfilecontent$index)) {
    j = j + 1
    if (outfilecontent[k, 'flag'] ==2) {
      outfilecontent[k, 'ntreesperfruit'] = j
      j = 0
    }
  }
  message(paste(substr(infilename, 1, 4), "done"))
  e2allsubs <- bind_rows(e2allsubs, outfilecontent)
}

e2allsubs <- 
  e2allsubs %>% 
  mutate(R = factor(R, levels=c("patchy","dispersed"), labels=c("clumped", "random")))
e2allsubs$exp <- as_factor(e2allsubs$exp)
e2allsubs$pid <- as_factor(e2allsubs$pid)
e2allsubs$V <- as_factor(e2allsubs$V)
e2allsubs$R <- as_factor(e2allsubs$R)
e2allsubs$L <- as_factor(e2allsubs$L)

e2allsubs <- 
  e2allsubs %>% 
  select(exp, pid, V, R, trial_in_session, trial_in_block, trial_identity, index, time, x, y, tile, flag, basket, L, ntreesperfruit, revisit, numtrees, trialdur, itdistance)

saveRDS(e2allsubs, "fgms_e2_allsubs.rds")