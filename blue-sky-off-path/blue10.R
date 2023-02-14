require(tidyverse)
require(reticulate)
require(tictoc)
require(crayon)
source_python("dos2unix.py")

# Reads each sample into a flat tibble
# - a raw sample is a list with a length-1 element per variable
# - we have to transform this into a row with 11 columns and then bind the rows
tic()
df.dir = "../per-subject-data/"
subject.list = dir(df.dir, full.names = TRUE)
dat <- tibble()
for(subject in seq_along(subject.list)){
  message(blue("starting subject",subject))
  dos2unix(subject.list[subject], "tmp")
  pickle = py_load_object("tmp"); unlink("tmp")
  for(trial in seq_along(pickle)){
    for(raw_sample in pickle[[trial]][["samples"]]){
      sample <- as_tibble(raw_sample)
      sample <- bind_cols(subject=subject, sample)
      dat <- bind_rows(dat, sample)
    }
  }
}
saveRDS(dat, "experiment_one_data_00_raw.rds")
toc() # 2 minutes

