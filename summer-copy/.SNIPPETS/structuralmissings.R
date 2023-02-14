

e1_revisits_df_agg1 <-
  e1_revisits_df_agg1 %>% 
  ungroup() %>% 
  bind_rows(tibble(pp=factor(17),resources=factor("clumped"),stage=factor("early"),basket=factor(1),sum_of_revisits=0)) %>% 
  bind_rows(tibble(pp=factor(37),resources=factor("random"),stage=factor("early"),basket=factor(1),sum_of_revisits=0)) %>% 
  bind_rows(tibble(pp=factor(20),resources=factor("random"),stage=factor("early"),basket=factor(1),sum_of_revisits=0)) %>% 
  bind_rows(tibble(pp=factor(12),resources=factor("random"),stage=factor("early"),basket=factor(1),sum_of_revisits=0)) %>% 
  bind_rows(tibble(pp=factor(6),resources=factor("random"),stage=factor("early"),basket=factor(1),sum_of_revisits=0)) %>% 
  group_by(pp, trial, resources, stage, fruit) %>% 
  arrange(.by_group=TRUE)



