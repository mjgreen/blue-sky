merge_with_design <-
  function(
    design, data
  ){
    data = full_join(x=design, y=data) %>% 
      group_by(subject, condition, trial) %>% 
      arrange(subject, condition, trial, fruit)
  }