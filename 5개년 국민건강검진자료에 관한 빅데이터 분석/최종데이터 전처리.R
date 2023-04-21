library(tidyverse)
## -- Attaching packages -------------------------- tidyverse 1.2.1 --
## √ ggplot2 3.2.1     √ purrr   0.3.3
## √ tibble  2.1.3     √ dplyr   0.8.3
## √ tidyr   1.0.0     √ stringr 1.4.0
## √ readr   1.3.1     √ forcats 0.4.0
## -- Conflicts ----------------------------- tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
library(GGally)
## Registered S3 method overwritten by 'GGally':
##   method from   
##   +.gg   ggplot2
## 
## Attaching package: 'GGally'
## The following object is masked from 'package:dplyr':
## 
##     nasa
data1<-read_csv("NHIS_TOTAL.csv")[,-c(1,2)]%>%rename(GAMMA_GTP=GAMMA_GDP)
## Warning: Missing column names filled in: 'X1' [1]
## Parsed with column specification:
## cols(
##   .default = col_double()
## )
## See spec(...) for full column specifications.
#1. 이상 변수 변환
##1) 시도코드 변환
data1%>%filter(SIDO>49)%>%group_by(HCHK_YEAR)%>%summarise(count=n())
## # A tibble: 1 x 2
##   HCHK_YEAR count
##       <dbl> <int>
## 1      2017   221
#코드가 49까지 존재해야 하는데 코드가 50이 존재하는 것을 확인하였고 해당 연도가 2017임을 확인하였다. 
data1%>%filter(HCHK_YEAR==2017)%>%group_by(SIDO)%>%summarise(count=n())
## # A tibble: 17 x 2
##     SIDO count
##    <dbl> <int>
##  1    11  3547
##  2    26  1373
##  3    27   950
##  4    28  1174
##  5    29   570
##  6    30   605
##  7    31   507
##  8    36    94
##  9    41  4877
## 10    42   614
## 11    43   681
## 12    44   856
## 13    45   734
## 14    46   759
## 15    47  1083
## 16    48  1355
## 17    50   221
#2017년도에 제주도인 49 변수가 보이지 않고 50이라는 변수가 추가되었으므로 변수가 변형되었음을 확인할 수 있다. 
data2<-data1%>%filter(HCHK_YEAR==2017,SIDO==50)%>%mutate(SIDO=SIDO-1)
data11<-data1%>%filter(SIDO!=50)
data1<-full_join(data2,data11)
## Joining, by = c("HCHK_YEAR", "IDV_ID", "SEX", "AGE_GROUP", "HEIGHT", "WEIGHT", "WAIST", "SIGHT_LEFT", "SIGHT_RIGHT", "HEAR_LEFT", "HEAR_RIGHT", "BP_HIGH", "BP_LWST", "BLDS", "TOT_CHOLE", "TRIGLYCERIDE", "HDL_CHOLE", "LDL_CHOLE", "HMG", "OLIG_PROTE_CD", "CREATININE", "SGOT_AST", "SGPT_ALT", "GAMMA_GTP", "SMK_STAT_TYPE_CD", "DRK_YN", "SIDO")
#따라서 2017년의 시도 변수가 50인 것을 49로 변형시켰다. 
##2) 나이 변수 변환
data1%>%ggplot(aes(AGE_GROUP,color=as.factor(HCHK_YEAR)))+geom_freqpoly(binwidth=1)

#2013년을 제외한 변수의 경우 5부터 18로 분포하고 4칸씩 밀린 것을 확인 할 수 있다. 
data2<-data1%>%filter(HCHK_YEAR!=2013)%>%mutate(AGE_GROUP=AGE_GROUP-4)
data11<-data1%>%filter(HCHK_YEAR==2013)
data1<-full_join(data2,data11)
## Joining, by = c("HCHK_YEAR", "IDV_ID", "SEX", "AGE_GROUP", "HEIGHT", "WEIGHT", "WAIST", "SIGHT_LEFT", "SIGHT_RIGHT", "HEAR_LEFT", "HEAR_RIGHT", "BP_HIGH", "BP_LWST", "BLDS", "TOT_CHOLE", "TRIGLYCERIDE", "HDL_CHOLE", "LDL_CHOLE", "HMG", "OLIG_PROTE_CD", "CREATININE", "SGOT_AST", "SGPT_ALT", "GAMMA_GTP", "SMK_STAT_TYPE_CD", "DRK_YN", "SIDO")
#따라서 2013년 데이터를 제외한 나이 변수에서 4를 빼서 동일한 데이터로 만들었다.
data1%>%ggplot(aes(AGE_GROUP,color=as.factor(HCHK_YEAR)))+geom_freqpoly(binwidth=1)

#데이터 변경 시에 동일한 1과 14 사이에서 동일한 패턴의 freqploy를 보임을 알 수 있다.
#2. 이상치 처리
##1) HEIGHT 변수에서의 이상점
data1%>%ggplot(aes(HEIGHT))+geom_freqpoly()
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 22 rows containing non-finite values (stat_bin).

#왼쪽 꼬리가 유난히 긴 것을 통해 이상점이 있음을 알 수 있다. 따라서 관측 수가 0에서 5사이의 이상점을 찾으려고 한다. 
data1%>%ggplot(aes(HEIGHT))+geom_freqpoly()+ylim(0,5)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 22 rows containing non-finite values (stat_bin).

#125 이하에서의 그래프에서 수가 2보다 작은 관측인 이상점이 발견되므로 HEIGHT에 관한 관측을 할 경우 filter(HEIGHT>120)을 추가로 적용하는 것이 이상적이다. 
##2) WAIST 변수의 이상점
data1%>%ggplot(aes(WAIST))+geom_freqpoly()
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 12 rows containing non-finite values (stat_bin).

#오른쪽 꼬리가 유난히 긴 것을 확인할 수 있다. 
data1%>%ggplot(aes(WAIST))+geom_freqpoly()+xlim(150,1000)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 99993 rows containing non-finite values (stat_bin).
## Warning: Removed 3 rows containing missing values (geom_path).

#999값이 관측치가 아닌 NA값임을 알 수가 있다. 따라서 FILTER(WAIST<150)를 하여 분석하는 것이 정확하다. 
##3) TOT_CHOLE 변수의 이상점
data1%>%ggplot(aes(TOT_CHOLE))+geom_freqpoly()+ylim(0,5)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 4 rows containing non-finite values (stat_bin).

#관측치가 5개 미만인 FILTER(TOT_CHOLE<500)를 하여 분석하는 것이 이상적이다. 
##4) TRIGLYCERIDE 변수의 이상점
data1%>%ggplot(aes(TRIGLYCERIDE))+geom_freqpoly()+ylim(0,10)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 4 rows containing non-finite values (stat_bin).

#관측치가 10개 미만인 FILTER(TRIGLYCERIDE<1200)를 하여 분석하는 것이 이상적이다. 
##5) CHOLE 변수의 이상점
data1%>%ggplot(aes(HDL_CHOLE))+geom_freqpoly()+ylim(0,10)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 4 rows containing non-finite values (stat_bin).

data1%>%ggplot(aes(LDL_CHOLE))+geom_freqpoly()+ylim(0,10)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 374 rows containing non-finite values (stat_bin).

#관측치가 10개 미만인 FILTER(HDL_CHOLE<200),FILTER(LDL_CHOLE<500),를 하여 분석하는 것이 이상적이다. 
##6) CREATINTNE 변수의 이상점
data1%>%ggplot(aes(CREATININE))+geom_freqpoly()+ylim(0,10)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 4 rows containing non-finite values (stat_bin).

#관측치가 10개 미만인 FILTER(CREATINTNE<=10)를 하여 분석하는 것이 이상적이다.
##7) SGPT_ALT 변수의 이상점
data1%>%ggplot(aes(SGPT_ALT))+geom_freqpoly()+ylim(0,10)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 4 rows containing non-finite values (stat_bin).

#관측치가 10개 미만인 FILTER(SGPT_ALT<=500)를 하여 분석하는 것이 이상적이다. 
##8) GAMMA_GTP 변수의 이상점 
data1%>%ggplot(aes(GAMMA_GTP))+geom_freqpoly()+ylim(0,10)
## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
## Warning: Removed 4 rows containing non-finite values (stat_bin).

#관측치가 50개 미만인 FILTER(GAMMA_GTP<=500)를 하여 분석하는 것이 이상적이다. 
##9) 음주 변수의 NA값
data1%>%group_by(HCHK_YEAR,DRK_YN)%>%summarise(count=n())
## # A tibble: 13 x 3
## # Groups:   HCHK_YEAR [5]
##    HCHK_YEAR DRK_YN count
##        <dbl>  <dbl> <int>
##  1      2013      0 10165
##  2      2013      1  9832
##  3      2013     NA     3
##  4      2014      0  9936
##  5      2014      1 10035
##  6      2014     NA    29
##  7      2015      0 10087
##  8      2015      1  9888
##  9      2015     NA    26
## 10      2016     NA 19999
## 11      2017      0 10069
## 12      2017      1  9921
## 13      2017     NA    10
#음주 변수의 경우 2016년에는 측정하지 않았으므로 FILTER(HCHK_YEAR!=500)를 적용하여 분석하는 것이 이상적이다. 
write.csv(data1,"final_data.csv")