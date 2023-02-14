a <-
  e1_revisits_df %>% 
  group_by(pp,trial,stage,resources,basket) %>% 
  summarise(sum_of_revisits = sum(is_a_revisit))

b <-
  expand.grid(
    basket=1:10,
    trial=c(1:10,1:10),
    pp=unique(e1_revisits_df_agg1$pp)
    ) %>%
  mutate(
    basket=as_factor(basket),
    trial=as_factor(trial)
  ) %>% 
  as_tibble()

test = anti_join(b,a)







  mutate(
    stage=ifelse(trial<=5,"early","late") 
    ) %>% 
  #bind_cols(
  #  resources=as_factor(rep(c("clumped","random"),each=10,times=420))
  #  ) %>% 
  select(
    pp,trial,stage,basket
    ) %>% 
  mutate(
    trial=as_factor(trial),
    stage=as_factor(stage),
    #resources=as_factor(resources),
    basket=as_factor(basket)
    ) %>% 
  as_tibble() %>% 
  left_join(
    y = e1_revisits_df_agg1,
    by = c("pp", "trial", "stage", "basket")
    ) 

e1_revisits_df_agg3<-
e1_revisits_df_agg2 %>% 
  group_by(pp,trial,stage,resources) %>% 
  mutate(drop_me_if=sum(is.na(sum_of_revisits)))

View(e1_revisits_df_agg3)


# e1_revisits_df_agg2 <-
#   e1_revisits_df_agg2 %>% 
#   replace_na(
#     list(sum_of_revisits=0)
#     )
# 
# 
# 
