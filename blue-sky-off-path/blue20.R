require(tidyverse)
dat <- readRDS("experiment_one_data_01_clean.rds")

dat <- dat %>% 
  group_by(subject, condition, trial) 




# Take a clean file of samples and parse it into a file of events
# - calculate trial duration using raw samples
# - remove trials that didn't land in a tree
# - collapse consecutive samples in the same tree

# - calculate trial duration using raw samples
dat <- dat %>% 
  mutate(dur = max(time) - min(time))

# - remove samples that didn't land in a tree
dat <- dat %>% 
  filter(flag != 0)

# - collapse consecutive samples in the same tree
dat <- dat %>% 
  filter(tree != lag(tree, default=FALSE))

# number off the remaining samples
dat <- dat %>% 
  mutate(index = seq_along(time)) %>% 
  select(subject, condition, trial, dur, index, everything())

# Some trials have an entry for fruit of zero and others don't
# - This is because if they land in a tree that contains fruit before
#   they land in a tree that doesn't, they rack up a sample or samples
#   while `fruit` is zero. `Fruit` tells us how many fruit they had collected 
#   at the *start* of the sample.
# - Some trials having 11 levels of fruit and others having ten causes imbalance
#   when we come to do ANOVAs using fruit as an independent variable. 
#   There are a few alternative options here that all make sense. 
#     1. We could remove all cases of fruit is zero.
#     2. We could merge the raw data with a representation of the full design
#        and introduce explicit missings for fruit of zero in the event
#        that the first tree they looked at was fruit-bearing

# We tabulate for each participant how  many trials contained fruit of zero

# - first step is to merge with the design
#    - make the design
design <- expand_grid(
  subject = as_factor(sort(seq_along(unique(dat$subject)))),
  condition = as_factor(levels(dat$condition)),
  trial = as_factor(levels(dat$trial)),
  fruit = as_factor(0))
#    - merge
datdat <- left_join(design, dat) %>% 
#    - sort
#dat <- dat %>% 
  #group_by(subject, condition, trial) %>% 
  arrange(c(subject, condition, trial, time), .by_group = TRUE)


#    - copy the data into a separate df for the merge
dat.tab <- dat
# %>% 
#   filter(fruit == 0)

#    merge: n says how many tree-visits in that trial happened before they got 
#  their first fruit (i.e., while the were on fruit of zero)
merged <- left_join(design, dat.tab) %>% 
  group_by(subject, condition, trial) %>% 
  summarise(n=max(index), .groups = 'keep') 

# At the moment we have NA if they didn't rack up any trees before the first fruit - we want this to be 0
merged <- merged %>% 
  replace_na(list(n=0)) %>% 
  mutate(subject=as.numeric(subject), trial=as.numeric(trial))

# Raster
ggplot(merged, aes(y=trial,x=subject,fill=n)) +
  geom_raster()+
  coord_fixed()+
  facet_wrap(~condition, nrow=2)+
  scale_fill_gradientn(colours=c("ivory","red"))+
  labs(title="People have to look at more trees to get the first fruit in the patchy condition than in the dispersed condition:", 
       fill="Number of tree visits before getting the first fruit in a trial\n",
       subtitle = "Until they realise they are not in a patch, they won't find fruit in the trees")+
  theme(legend.position = "top")
  


# Let's try doing the merge on the main data sat so that we have zero for fruit of zero if they didn't rack up any trees while fruit was zero, instead of having structural missings in that case.

dat2 <- left_join(design, dat) %>% 
  group_by(subject, condition, trial) %>% 
  summarise(n=max(index), .groups = 'keep') 

