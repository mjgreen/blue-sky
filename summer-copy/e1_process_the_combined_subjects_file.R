# The aim here is to go from 
# row-per-eyetracker-sample
# to
# row-per-discrete-tree-visit-event
#
# Things that need to happen are:
# 1. Make sure that cases where they got a fruit on the first tree they looked at 
# are handled appropriately to avoid structural missings
# 2. Annotate trials that didn't get the requisite ten fruit instead of removing them, 
# to avoid structural missings
#
# [x] inertia - Collapse consecutive samples in the same place down to a single row instead of multiple rows
# [x] Get rid of rows (after collapsing down to single rows) that weren't in a tree - 
#     unless the row is the first sample and basket is 0
# [x] identify revisits
# [ ] How many trees to get each fruit?

# [x] inter-tree distance - after getting to row-per-tree-visit
# [x] remove failed trials (less than 10 fruit)


e1dat <- readRDS("fgms_e1_allsubs_stage_1.rds")

# get trial duration before removing any rows
a0 <- e1dat %>% 
  group_by(pid, R, trial) %>% 
  mutate(dur=max(time))

# Identify inertia - where this row's sample is in the same tile 
# as the previous row's sample
a1 <- a0 %>% 
  group_by(pid, R, trial) %>% 
  mutate(inertia = tile == lag(tile, default=FALSE)) 

# Remove rows with inertia
# aka "collapse same-place samples"
a2 <- a1 %>% 
  ungroup() %>% 
  filter(inertia == FALSE)

# Identify each revisit - where an initial visit is followed 
# by any other visits in the same trial
# * what about revisits where youre revisting somewehere 
# while you;re oon the same fruit - this one doesnlt make much sense
b1 <- a2 %>%
  group_by(pid, R, trial) %>% 
  mutate(revisit = duplicated(tile))   

# Remove samples that werent't in a tree UNLESS ITS THE FIRST SAMPLE
# i.e., AVOID STRUCTURAL MISSINGs
# Step 1 make column with 'deleteme' status of TRUE/FALSE
# Step 2 filter to retain only deleteme of FALSE
c1 <- b1 %>% 
  ungroup() %>% 
  # set deleteme TRUE if the sample is not in a tree
  mutate(deleteme = flag==0) %>% 
  # but overwrite deleteme with FALSE if it's the first sample and basket is 0
  mutate(deleteme = ifelse(index==1 & basket==0, FALSE, deleteme)) 
c2 <- c1 %>%
  ungroup() %>% 
  filter(deleteme == FALSE)

# Compute distance between successive trees
d1 <- c2 %>% 
  group_by(pid, R, trial) %>% 
  mutate(distance = round(sqrt((lead(x)-x)^2 + (lead(y)-y)^2), 2))

# how many trees to get each fruit?
# this is neat and it needs to be done after reducing the data to row-per-valid-tree-visit
e1 <- d1 %>% 
  mutate(ntreesperfruit = NA)
j = 0
for (k in seq_along(e1$index)) {
 j = j + 1
 if (e1[k, 'flag']==2) {
   e1[k, 'ntreesperfruit'] = j
   j = 0
 }
}

# Do last
# Mark up and remove failed trials (failed is max basket less than 10)
f1 <- e1 %>% 
  group_by(pid, R, trial) %>% 
  mutate(score=max(basket))
f2 <- f1 %>% 
  filter(score==10)


# Save out
saveRDS(f2, "fgms_e1_allsubs.rds")
