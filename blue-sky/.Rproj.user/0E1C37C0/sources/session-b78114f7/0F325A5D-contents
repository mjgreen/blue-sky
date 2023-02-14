read_pickles <- 
  function(
    lazily_load_from_existing_rds_file = FALSE,
    results_folder="per-subject-data/",
    nsubs=NULL
    )
    {
  
  if(lazily_load_from_existing_rds_file){
    return(readRDS("collated_pickles.rds"))
    }
  
  suppressPackageStartupMessages(require(tidyverse))
  suppressPackageStartupMessages(require(crayon))
  suppressPackageStartupMessages(require(reticulate))
  suppressPackageStartupMessages(require(progress))
  
  reticulate::source_python("function_dos2unix.py")
  
  subject.list <- list.files(results_folder, full.names = TRUE)
  
  if(is.null(nsubs)){nsubs=length(subject.list)}
  
  pb <- progress_bar$new(total = length(subject.list))
  
  collated_pickles <- tibble()
  for(subject in seq_along(subject.list[1:nsubs])){
    
    dos2unix(subject.list[subject], "tmp")
    pickle = py_load_object("tmp"); unlink("tmp")
    
    for(trial in seq_along(pickle)){
      for(raw_sample in pickle[[trial]][["samples"]]){
        sample <- as_tibble(raw_sample)
        sample <- bind_cols(subject=subject, sample)
        collated_pickles <- bind_rows(collated_pickles, sample)
      }
    }
    pb$tick()
  }
  saveRDS(collated_pickles, "collated_pickles.rds")
  return(collated_pickles)
}

