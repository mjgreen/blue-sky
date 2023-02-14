require(tidyverse)
rm(list=ls())

d <- readRDS("experiment_one_data_01_clean.rds")

# Merge the actual data onto the design

d <- d %>% 
  group_by(subject, condition, trial) 

design <- expand_grid(
  subject = as_factor(sort(seq_along(unique(d$subject)))),
  condition = as_factor(levels(d$condition)),
  trial = as_factor(levels(d$trial)),
  fruit = as_factor(0:10))

#42 * 2 * 10 * 11
# 42 subjects
# 2 conditions
# 10 trials
# 11 fruit
#    - is 9240 cells / rows

# actually merge
d <- full_join(x=design, y=d) %>% 
  group_by(subject, condition, trial) %>% 
  arrange(subject, condition, trial, fruit)

# Take a clean file of samples and parse it into a file of events
# - calculate trial duration using raw samples
# - remove trials that didn't land in a tree
# - collapse consecutive samples in the same tree down to the first one in a run
# - Memory errors -- Identify and annotate revisits
# - Inter-tree distance --Compute distance between successive trees
# - Retrieval Rate -- Count how many trees they looked at to get each fruit
# - Identify failed trials (failed is they didn't get all 10 fruit on this trial)

# - calculate trial duration before removing any samples
d <- d %>% 
  group_by(subject, condition, trial) %>% 
  mutate(dur = max(time, na.rm=TRUE) - min(time, na.rm=TRUE)) %>% 
  select(subject, condition, trial, dur, everything())

# - collapse consecutive samples in the same tree
# This is problematic because it labels as NA cases where tree is NA on the current row: which are cases where :
#    - (a) the first tree they looked at was a fruit; because that row has NA for tree, and
#    - (b) the subsequent row, because comparison with NA yields NA
# This can be corrected by replacing NA with FALSE in the inertia column after doing the mutate
d <- d %>% 
  group_by(subject, condition, trial) %>%
  # label (but don't remove yet) cases where the current tree is the same as the previous one
  mutate(inertia = tree == lag(tree, default=FALSE)) %>% 
  # if the comparison yeilds NA then mark it up as 'the current tree is different'
  replace_na(list(inertia = FALSE)) %>% 
  # inertia rows get removed: the effect is that we only keep the first landing in a set of landings in the same tree
  filter(inertia == FALSE) %>% 
  # remove the intermediate column
  select(-c(inertia))

# - remove trials that didn't land in a tree
# This is problematic because it can result in some trials losing fruit of zero
# re-merge with the design after removal
d <- d %>% 
  filter(flag %in% c(NA, 1, 2, 3)) %>% 
  full_join(design) %>% 
  # annotate fruit is zero rows that just got re-added with unique(dur)
  mutate(dur = mean(dur, na.rm=TRUE)) %>% 
  arrange(subject, condition, trial, fruit, .by_group = TRUE)

# Identify and annotate revisits
d <- d %>% 
  group_by(subject, condition, trial) %>%
  mutate(isa_revisit = duplicated(tree))

# Inter-tree distance --Compute distance between successive trees
d <- d %>% 
  group_by(subject, condition, trial) %>%
  mutate(dist = sqrt( (lead(x)-x)^2 + (lead(y)-y)^2) )

# Retrieval Rate -- Count how many trees they looked at to get each fruit:
# The tree that has the fruit counts too
d <- d %>% 
  group_by(subject, condition, trial) %>%
  mutate(retrieval = NA)
j = 0
for (k in seq_along(d$time)) {
  j = j + 1
  this_flag = d[k, 'flag']
  if (!is.na(this_flag) && this_flag==2) {
    d[k, 'retrieval'] = j
    j = 0
  }
}
  
# - Identify failed trials (failed is they didn't get all 10 fruit on this trial)
d <- d %>% 
  group_by(subject, condition, trial) %>%
  mutate(failed = max(as.numeric(fruit), na.rm=TRUE) < 10)
