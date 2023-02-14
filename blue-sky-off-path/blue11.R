require(tidyverse)

# Take a file of raw samples and tidy it

dat <- 
  readRDS("experiment_one_data_00_raw.rds") %>% 
  rename(
    tree = hit_tile,
    trial = trial_index, # 1 to 20
    fruit = fruit_tally,
    time = sample_timestamp,
    flag = hit_flag,
    x = psychopy_x,
    y = psychopy_y,
    sample = sample_index) %>% 
  mutate(
    condition = ifelse(str_detect(trial_name, "cluster"), "patchy", "dispersed"),
    tree = tree + 1, # so that it starts at 1 instead of 0
    # convert trial ranging 1 to 20 into trial ranging 1 to 10
    trial = trial%%10, 
    trial = ifelse(trial == 0, 10, trial)) %>% 
  select(
    subject, condition, trial, time, fruit, tree, flag, x, y, time
    )

# ensure strictly increasing time per trial
# because pickles can be in bad row order
dat <- dat %>% 
  group_by(subject, condition, trial) %>% 
  arrange(time, .by_group = TRUE) %>% 
  ungroup()

# factors & grouping
dat <- dat %>% 
  mutate(
    subject = as_factor(subject),
    condition = factor(condition, levels=c("dispersed", "patchy")),
    trial = as_factor(trial),
    fruit = as_factor(fruit)
  ) %>% 
  group_by(
    subject, condition, trial
    ) #  left-most factor varies slowest

saveRDS(dat, "experiment_one_data_01_clean.rds")
