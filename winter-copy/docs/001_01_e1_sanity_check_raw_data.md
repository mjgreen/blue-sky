---
title: "Sanity Check Raw Data"
author: "Matt"
date: "2023-01-28"
output: html_document
---




```r
library(tidyverse)
```


```r
e1 <- readRDS("001-00-e1-data.RDS")
```

## Sanity check raw data

### Basic structural properties, dimensions


```r
str(e1)
#> tibble [58,603 × 14] (S3: tbl_df/tbl/data.frame)
#>  $ ex: num [1:58603] 1 1 1 1 1 1 1 1 1 1 ...
#>  $ pp: int [1:58603] 1 1 1 1 1 1 1 1 1 1 ...
#>  $ rr: chr [1:58603] "patchy" "patchy" "patchy" "patchy" ...
#>  $ tb: int [1:58603] 1 1 1 1 1 1 1 1 1 1 ...
#>  $ te: chr [1:58603] "p:01" "p:01" "p:01" "p:01" ...
#>  $ st: chr [1:58603] "early" "early" "early" "early" ...
#>  $ ix: int [1:58603] 1 2 3 4 5 6 7 8 9 10 ...
#>  $ tm: num [1:58603] 153 153 153 153 153 ...
#>  $ xx: int [1:58603] -1 3 191 196 198 205 -288 -290 -29 -342 ...
#>  $ yy: int [1:58603] -2 -4 -11 -11 -3 3 184 179 240 148 ...
#>  $ ll: chr [1:58603] "not" "not" "not" "not" ...
#>  $ tl: num [1:58603] 72 73 74 74 74 74 38 54 40 54 ...
#>  $ fl: int [1:58603] 0 0 1 1 1 1 0 2 2 3 ...
#>  $ fr: int [1:58603] 0 0 0 0 0 0 0 1 2 2 ...
```


```r
summary(e1)
#>        ex          pp          rr           
#>  Min.   :1   Min.   : 1   Length:58603      
#>  1st Qu.:1   1st Qu.:11   Class :character  
#>  Median :1   Median :22   Mode  :character  
#>  Mean   :1   Mean   :23                     
#>  3rd Qu.:1   3rd Qu.:35                     
#>  Max.   :1   Max.   :46                     
#>        tb              te                 st           
#>  Min.   : 1.000   Length:58603       Length:58603      
#>  1st Qu.: 2.000   Class :character   Class :character  
#>  Median : 5.000   Mode  :character   Mode  :character  
#>  Mean   : 5.078                                        
#>  3rd Qu.: 8.000                                        
#>  Max.   :10.000                                        
#>        ix               tm                xx         
#>  Min.   :  1.00   Min.   :  81.61   Min.   :-960.00  
#>  1st Qu.: 19.00   1st Qu.: 219.69   1st Qu.:-499.00  
#>  Median : 41.00   Median : 311.44   Median : -55.00  
#>  Mean   : 74.03   Mean   : 334.99   Mean   : -26.15  
#>  3rd Qu.: 81.00   3rd Qu.: 418.88   3rd Qu.: 441.00  
#>  Max.   :992.00   Max.   :1180.19   Max.   : 960.00  
#>        yy               ll                  tl       
#>  Min.   :-540.00   Length:58603       Min.   :  1.0  
#>  1st Qu.:-231.00   Class :character   1st Qu.: 36.0  
#>  Median :   9.00   Mode  :character   Median : 71.0  
#>  Mean   :  19.73                      Mean   : 69.7  
#>  3rd Qu.: 265.00                      3rd Qu.:104.0  
#>  Max.   : 540.00                      Max.   :144.0  
#>        fl              fr        
#>  Min.   :0.000   Min.   : 0.000  
#>  1st Qu.:0.000   1st Qu.: 1.000  
#>  Median :1.000   Median : 4.000  
#>  Mean   :1.106   Mean   : 4.109  
#>  3rd Qu.:2.000   3rd Qu.: 7.000  
#>  Max.   :3.000   Max.   :10.000
```

### Test for duplicated rows

Returns TRUE if the test succeeds with no duplicated rows.


```r
sum(duplicated(e1))==0
#> [1] TRUE
```

### Check samples are in strict time-order

We need this check because python pickle files don't strictly obey row order.

Returns the number of trials in which row order was violated at some point in the trial.


```r
# test for strictly increasing time (tm)
test_row_sanity <- 
  e1 %>% 
  group_by(ex,pp,te,rr,tb) %>% 
  mutate(validrow = tm > lag(tm, default=TRUE)) %>% 
  group_by(ex,pp,te,rr,tb) %>% 
  summarise(nfails=sum(validrow==FALSE)) %>% 
  group_by(ex,pp,te,rr,tb) %>% 
  summarise(failed_trial = as.logical(sum(nfails>0))) %>% 
  ungroup()
#> `summarise()` has grouped output by 'ex', 'pp', 'te', 'rr'.
#> You can override using the `.groups` argument.
#> `summarise()` has grouped output by 'ex', 'pp', 'te', 'rr'.
#> You can override using the `.groups` argument.

(n_failed_trials <- test_row_sanity %>% 
  summarise(n_failed_trials=sum(failed_trial)))
#> # A tibble: 1 × 1
#>   n_failed_trials
#>             <int>
#> 1              79
```

