library(tidyverse)
infiles <- dir(path="e2_csvs", pattern = "*.csv$", full.names=TRUE)
n_infiles = length(infiles)
subjects = list()
for (i in seq_along(infiles)){
  subject <- read_csv(infiles[i], col_types = cols()) %>% filter(bg_type!="practice")
  subjects[[i]] = list(
    pid=subject$participant,
    trl=subject$trial_number,
    cnd=subject$resource_distribution %>% 
      str_replace(pattern="patchy", replacement="clumped") %>% 
      str_replace(pattern="dispersed", replacement="random"),
    smp=subject$sample,
    frt=subject$fruits
  )
}
subjs <- tibble(subj=subjects)
subjs %>% unnest_wider(subj)



users <- tibble(user=gh_users)
users %>% unnest_wider(user)



users %>% hoist(user, 
                fooooollowers = "followers", 
                login = "login", 
                url = "html_url"
                )

subjs %>% hoist(subj,
                pidtastic="pid",
                trltastic="trl",
                cntasticd="cnd"
                ) %>% View()
