library(reticulate)
library(tidyverse)
library(tictoc)

tic()

if (Sys.info()[['sysname']]=="Windows"){
  source_python("dos2unix.py")
}
e1allsubs = tibble()
outf = tibble()
indir = "e1_pickles"
numberoftrials = 20
for (infilename in list.files(indir, pattern=".pickle$")) {
  i = 0
  if (Sys.info()[['sysname']]=="Windows"){
    dos2unix(
      file.path(indir, infilename),
      file.path("temporary.pickle")
    )
    infilecontent <- py_load_object(file.path("temporary.pickle"))
    unlink("temporary.pickle")
  } else {
    infilecontent <- py_load_object(file.path(indir, infilename))
  }
  for (trialnumber in 1:numberoftrials) {
    trialnumber <- as.character(trialnumber)
    samples <- names(infilecontent[[trialnumber]][['samples']])
    content <- infilecontent[[trialnumber]] # a list
    for (samplenumber in samples) {
      i <- i + 1
      outf[i, "exp"] = 1
      outf[i, 'pid'] = content[['participant_number']]
      outf[i, 'trial'] = content[['trial_num_in_block']]
      outf[i, "stage"] = ifelse(content[['trial_num_in_block']] <=5, "early", "late")
      outf[i, 'R'] = ifelse(grepl("cluster", content[['trial_name']]), "clumped", "random")
      outf[i, 'L'] = ifelse(content[['samples']][[samplenumber]]$hit_flag==2, "fruit", "not_fruit")
      outf[i, 'index'] = content[['samples']][[samplenumber]]$sample_index
      outf[i, 'time'] = content[['samples']][[samplenumber]]$sample_timestamp
      outf[i, 'x'] = content[['samples']][[samplenumber]]$psychopy_x
      outf[i, 'y'] = content[['samples']][[samplenumber]]$psychopy_y
      # +1 to turn zero-indexed into human indexed
      outf[i, 'tile'] = content[['samples']][[samplenumber]]$hit_tile + 1
      outf[i, 'flag'] = content[['samples']][[samplenumber]]$hit_flag
      outf[i, 'basket'] = content[['samples']][[samplenumber]]$fruit_tally
    }
  }
  if (infilename == "P009.pickle") {
    outf$pid = 9; 
    message(paste0("... P009 correcting the error vlada made ",
                   "when she called p9 p10 and corrected it in the csv but ",
                   "obviously couldn't do that in the pickle"))
  }
  
  # files saved by pickle are in arbitrary (though often deceptively sane) row order
  # so we need to sort on row order after grouping to identify each trial
  outf <-
    outf %>%
    group_by(exp, pid, R, trial) %>%
    arrange(index, .by_group=TRUE) 
  
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
  
  # add this participant to the allsubs tibble
  e1allsubs <- bind_rows(e1allsubs, outf)
  
  # this participant is finished - go back for the next one after adding to allsubs
  message(paste(substr(infilename, 1, 4), "done"))
}

# set types
e1allsubs <- e1allsubs %>% 
  mutate(
    exp=as_factor(exp),
    pid=as_factor(pid),
    R=as_factor(R),
    L=as_factor(L),
    trial=as_factor(trial),
    stage=as_factor(stage)
  )

# choose and sort columns of the output for saving to RDS file
e1allsubs <-
  e1allsubs %>% 
  select(exp, pid, R, L, trial, stage, index, time, x, y, tile, flag, basket)

saveRDS(e1allsubs, "fgms_e1_allsubs_stage_1.rds")

# end of loop message
message("all results pickles have been read in")
number_of_pickles_that_made_it = length(unique(e1allsubs$pid))
message(paste("number of results files processed was:", number_of_pickles_that_made_it))

toc()



