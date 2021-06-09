---
title: Statamarkdown Test
author: Emmanuel Teitelbaum
date: '2021-06-09'
slug: statamarkdown-test
categories: []
tags: []
subtitle: ''
summary: ''
authors: []
lastmod: '2021-06-09T10:56:06-04:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---



## Stata

First code block:


```stata
sysuse auto
generate gpm = 1/mpg
summarize price gpm
```

```
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
       price |         74    6165.257    2949.496       3291      15906
         gpm |         74    .0501928    .0127986   .0243902   .0833333
```

Second code block:


```stata
regress price gpm
```

```
      Source |       SS           df       MS      Number of obs   =        74
-------------+----------------------------------   F(1, 72)        =     35.95
       Model |   211486574         1   211486574   Prob > F        =    0.0000
    Residual |   423578822        72  5883039.19   R-squared       =    0.3330
-------------+----------------------------------   Adj R-squared   =    0.3238
       Total |   635065396        73  8699525.97   Root MSE        =    2425.5

------------------------------------------------------------------------------
       price | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         gpm |     132990   22180.86     6.00   0.000     88773.24    177206.7
       _cons |  -509.8827   1148.469    -0.44   0.658    -2799.314    1779.548
------------------------------------------------------------------------------
```
