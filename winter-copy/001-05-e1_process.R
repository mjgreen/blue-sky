

# make time be relative to the first sample of the session
outf <- outf %>% mutate(time = time-time[1])

# remove samples that didn't gaze at a tree
#outf <- outf %>% filter(flag %in% c(1, 2, 3)) 

# remove trial if they didn't get 10 fruit or more
#outf <- outf %>% filter(max(basket) >= 10)

# remove the second (and any subsequent) *consecutive* duplicates
#outf <- outf %>% filter(is.na(tile != lag(tile)) | tile != lag(tile))

# identify as TRUE the second (and any subsequent) duplicates whether 
# they are consecutive or not (i.e, memory errors)
#outf <- outf %>% mutate(revisit = as.numeric(duplicated(tile)))        

# compute number of trees - this is the same as the number of rows 
# if you do the three removals above first but you should compute this outside
#outf <- outf %>% mutate(numtrees = n())

# compute trial duration - should do this outside
#outf <- outf %>% mutate(trialdur = round(max(time),2))

# compute inter-tree distance - do this outside
# bear in mind that it needs to be done after reducing the data to valid tree-visits
#outf <- outf %>% mutate(itdistance = round(sqrt((lead(x)-x)^2 + (lead(y)-y)^2), 2))

# re-roll-out index after doing removal of rows - do this outside
#outf <- outf %>% mutate(index = seq_along(index)) 

# ungroup
outf <- outf %>% ungroup()

# how many trees to get each fruit?
# this is neat and it needs to be done after reducing the data to row-per-valid-tree-visit
#outf$ntreesperfruit = NA
#j = 0
#for (k in seq_along(outf$index)) {
#  j = j + 1
#  if (outf[k, 'flag']==2) {
#    outf[k, 'ntreesperfruit'] = j
#    j = 0
#  }
#}


# set types
e1allsubs <- e1allsubs %>% 
  mutate(
    exp=as_factor(exp),
    pid=as_factor(pp),
    R=as_factor(R),
    L=as_factor(L),
    trial=as_factor(trial),
    stage=as_factor(stage)
  )

# choose and sort columns of the output for saving to RDS file
e1allsubs <-
  e1allsubs %>% 
  select(exp, pid, R, L, trial, stage, index, time, x, y, tile, flag, basket)


# end of loop message
message("all results pickles have been read in")
number_of_pickles_that_made_it = length(unique(e1allsubs$pid))
message(paste("number of results files processed was:", number_of_pickles_that_made_it))

toc()

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


e1dat <- e1allsubs

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


View(f2)
