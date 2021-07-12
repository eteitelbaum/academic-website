---
title: Working with National Sample Survey (NSS) data in Stata
author: Emmanuel Teitelbaum
date: '2021-07-07'
slug: working-with-nss-data-in-stata
categories: []
tags: []
subtitle: ''
summary: ''
authors: []
lastmod: '2021-07-07T10:50:25-04:00'
featured: no
image:
  caption: 'Utpal Baruah/Reuters'
  focal_point: ''
  preview_only: no
projects: []
draft: FALSE
---



In recent years, India's Ministry of Statistics & Programme Implementation (MOSPI) has been [releasing micro-data](http://microdata.gov.in/nada43/index.php/catalog/central/about) for some of the large-scale sample surveys conducted by the [National Sample Survey Organization (NSSO)](http://mospi.nic.in/NSSOa). This is kind of cool because, in the past, if you wanted to work with NSS unit-level data you had to purchase it. This could be an arduous process and the data was not cheap, especially for "foreign" researchers.

There is a lot of documentation that comes with these data, but not very much practical information for how to use it. After I noticed that others were struggling with [similar questions](https://www.researchgate.net/post/How-to-construct-employment-indicators-using-NSSO-dataset-India), I decided to transform my notes into a blog post that I hope will save others some time.

The examples given here are based on the *NSS 68th Round: Employment and Unemployment* that was conducted in 2011-2012. For convenience, I am just going to refer to it as the "Employment and Unemployment Survey" or "EUS".

After 2011-2012 the EUS was replaced by the Periodic Labor Force Survey (PLFS). It is too bad that the NSS abandoned the EUS, because there were some interesting questions there about land ownership and union membership that the PLFS does not include. Nevertheless, the EUS remains a useful resource for historical analysis, and since the EUS is similar in design to other NSSO surveys, the concepts and examples provided here should be useful for analyzing a lot of the other unit-level data released by MOSPI.

## Accessing the Data

The data that I am going to be working with in this post are located [here](http://microdata.gov.in/nada43/index.php/catalog/127). You can download the relevant files by clicking on the "GET MICRODATA" tab and filling out the necessary paperwork.

Next, read the instructions on how to access the data in the `README_FIRST` file. To access the unit-level data and documentation, you will need the Nesstar Explorer installed, which you can find in the `software` folder. Once you have that installed, you need to find and run the **AutorunPro.exe**.

{{% callout note %}}
The Nesstar format that the NSSO uses may not be easily accessible for Mac users. However, I did see [this post](https://anthonylouisdagostino.com/on-working-with-indias-nss-data-in-an-osx-environment/) on how to access the data in an OS/X environment.
{{% /callout %}}

From there, navigate to `Data set\Data Files` folder and click on the folder that you want to download. For this example, we will be using `Block_5_1_Usual principal activity particulars of household members` and `Block_4_Demographic particulars of household members`.

Next you need to click on the link that reads "Click here to access/export data files from Nesstar format." Now you can download and save the file. I find it helpful to rename the file to something shorter, more intuitive and with fewer spaces. For example, I renamed these two files `block_5_1_principal_activity` and `block_4_demographic_particulars`.

## Sampling Design

Before working with the NSS data, it is good to be familiar with the basic design of the survey. I will review some of the more important elements here. For more detailed information, you can access the survey documentation. The files titled "Introduction Concepts, Definitions and Procedures", "Instructions to Field Staff" and "Procedures for Obtaining Estimates of Aggregates, Ratios and their RSEs" in the `Other Materials` folder should tell you everything you want to know about the survey and how it was conducted.

{{% callout note %}}
The design described here pertains to surveys starting with NSS 61 in 2004-05 when the NSSO began stratifying by rural and urban areas within each district. Prior to that, NSS surveys were stratified by population at the state and regional level.
{{% /callout %}}

Here are the key features of the sampling design for the 2011-2012 EUS:

***PSU***: The primary sampling units (PSUs) are census villages in the rural sector and Urban Frame Survey (UFS) blocks in the urban sector. In the NSS documentation, PSUs are referred to as "First Stage Units (FSUs)."

***Sampling Frame***: For the rural sector, the sampling frame is all of the census villages. For the urban sector, the sampling frame is a list of UFS blocks.

***USU***: The ultimate sampling units (USU) are households in the rural and urban sectors. In the NSS documentation, the USU is referred to as the "Ultimate Stage Unit."

***Strata***: The sample is first stratified by rural and urban areas within each district. Then all towns with a population over one million constitute their own separate stratum. So say you have a district with two towns with more than one million inhabitants. In that case, you would have four strata in the district: one rural; one for each of the towns; and a third for the remaining towns with fewer than one million inhabitants. The data taken from each strata are referred to as "subsamples" in the NSS documentation.

***Sub-strata***: There are four substrata within each rural and urban stratum. These are created by listing the villages/towns in ascending order of population (for rural areas) or households (for urban areas) and then demarcating the four strata so that each stratum has roughly equal population.

***Selection of PSUs***: In rural areas, villages are selected by probability proportional to size with replacement, where size is the population of the village as per the census. For urban areas, blocks are selected by simple random sampling without replacement.

***Hamlet Groups and Sub-blocks***: If the population of the PSU is more than 1,200, it is divided into a smaller number of relatively equal-size hamlet groups or sub-blocks. The number of hamlet groups or sub-blocks increases with the size of the population of the PSU. Once the population has been divided up into hamlet groups or sub-blocks, two of them are selected. The hamlet group or sub-block with the biggest share of the population is always selected. The second is selected by simple random sampling.

***Rounds***: Most NSS surveys are carried out in multiple rounds (usually four) over an extended period of time (usually one year).

***Weights***: The NSS data include a number of weights. The file titled "sampling.html" in the "technical information" folder has some information on the weights. From Nesstar Explorer, you can access this file through the "Sampling" icon under "Study Description."

The weights (mulptilers) are subsample weights and have to be manipulated to get overall population weights. In the data, we see:

- `MLT`--Sub-sample multiplier
- `MLT_SR`--Sub-round multiplier
- `Multiplier_comb`--Combined multiplier

`Multiplier_comb` is the weight for "generating subsample-wise estimates based on data of all subrounds taken together." It is calculated by taking `MLT` and dividing by 100 if `NSS` = `NSC` or dividing `MLT` by 200 otherwise. This is the main weight that you want to work with if you are using the whole database (as opposed to data from a particular subround).

- `NSS`--the count of sub-sample wise values falling within a stratum
- `NSC`--sub-sample combined values falling within a stratum

Whenever a sample value is repeated in both the sub-samples (rural and urban), the multiplier value is (`MLT`/100), whereas if the sample value is present in only one sub-sample, the multipler value is (`MLT`/200).

***Second Stage Strata***: There are three strata for the selection of households within each FSU, hamlet group or sub-block.

- Rural sector
  - SSS1: Relatively affluent households
  - SSS2: Of the remaining households, those with principal income from non-agricultural activity
  - SSS3: Other households
- Urban sector
  - SSS1: HH with MPCE in top 10% of urban population
  - SSS2: HH with MPCE in middle 60% of urban population
  - SSS3: HH with MPCE in bottom 30% of urban population

***Selection of Households***: For FSUs without hamlet groups or sub-blocks, the distribution of households among the second stage strata is as follows:

- SSS1: 2 households if there are no hamlet groups/sub-blocks; 1 otherwise
- SSS2: 4 households if there are no hamlet groups/sub-blocks; 2 otherwise
- SSS3: 2 households if there are no hamlet groups/sub-blocks; 1 otherwise

## Organizing the Data

The NSS data are released in separate "blocks." Oftentimes you want to merge the blocks so that you can see how variables stored in one block relate to those stored in another block. For our analysis, we are mostly going to be using data from Block 5 but we will also need to grab data on the respondent's sex from Block 4.

Let's go ahead and open `block_5_1_principal_activity`.  The variable names are a little long and unconventional and most of them are not labeled. For clarity's sake, we can rename, label and keep the variables that will be useful for this exercise.


```stata
use block_5_1_principal_activity, clear

ren State state
lab var state "state code"

ren District_code dist_code
lab var dist_code "district code"

ren Sector sector
lab var sector "rural or urban"

ren Stratum stratum
lab var stratum "stratum"

ren Sub_Stratum_No substratum
lab var substratum "substratum"

ren FSU_Serial_No psu
lab var psu "primary survey unit (village/block)"

ren Hamlet_Group_Sub_Block_No hamlet_subblock
lab var hamlet_subblock "hamlet group or sub-block number"

ren Second_Stage_Stratum_No ss_strata_no
lab var ss_strata_no "second stage stratum number"

ren Sample_Hhld_No household
lab var household "represents the nth household within each of the second stage stratum"

ren Person_Serial_No person
lab var person "identifier for individual respondent"

ren Age age
lab var age "age of respondent"

ren Usual_Principal_Activity_Status upas_code
lab var upas_code "Usual principal activity status code"

ren HHID hhid
lab var hhid "household identifier"

ren Multiplier_comb pweight
lab var pweight "probability weight (combined multiplier)"

keep state dist_code sector stratum substratum psu pweight hamlet_subblock ss_strata_no household hhid person age upas_code
```

```

```

We need to `destring` the variable `upas_code` because it has to be an integer in order to use it with Stata's `svy` commands as we will do below.


```stata
destring upas_code, replace
```

```
upas_code: all characters numeric; replaced as byte
```

We also need to generate an identifier for the first stage strata since the dataset does not actually include one.


```stata
gen fs_strata = state + sector + stratum + substratum
lab var fs_strata "first stage strata"
```

```

```

Now we need to create a unique identifier for each observation that we can use for merging block 5 with other files in the dataset:


```stata
gen id = hhid + person
lab var id "observation identifier"
```

```

```

Let's reorder the data in a more intuitive way and save all of the changes that we made in a new file:


```stata
order id state dist_code sector stratum substratum psu fs_strata hamlet_subblock ss_strata household hhid person pweight age upas_code

save block_5_1_exercise, replace
```

```
(file block_5_1_exercise.dta not found)
file block_5_1_exercise.dta saved
```

For this exercise, we are going to need to get the sex of the respondent from Block 4 on "demographic particulars." Let's open the Block 4 file and save a new file with just the sex of the respondent and the observation identifier.


```stata
use block_4_demographic_particulars, clear

destring Sex, replace
recode Sex (2=1) (1=0), gen(sex)
lab var sex "1 = female; 0 = male"

ren Person_Serial_No person
lab var person "identifier for individual respondent"

ren HHID hhid
lab var hhid "household identifier"

gen id = hhid + person
lab var id "observation identifier"

keep sex id
save block_4_exercise, replace
```

```
Sex: all characters numeric; replaced as byte

(456999 differences between Sex and sex)









(file block_4_exercise.dta not found)
file block_4_exercise.dta saved
```

Now we can merge the block 4 and 5 files and save the resulting file as a new file titled `NSS_exercise`.


```stata
use block_5_1_exercise, clear
merge 1:1 id using block_4_exercise
save NSS_exercise, replace
```

```
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                           456,999  (_merge==3)
    -----------------------------------------

file NSS_exercise.dta saved
```

## Svyset the NSS Data

The next step is going to be to `svyset` the data so that Stata is aware of the key  elements of the survey design. Without these, Stata will not produce accurate point estimates or standard errors

If you are not familiar with `svyset`, Stata has a [video](https://www.youtube.com/watch?v=XYjWCL7IEKU) that provides a basic introduction. I also highly recommend this [UCLA tutorial](https://stats.idre.ucla.edu/stata/seminars/survey-data-analysis-in-stata-17/), which provides a more detailed walkthrough as well as a great introduction to survey design.

The three basic elements of the survey that we want Stata to be aware of are the primary survey unit, the probability weight and the first stage strata. We should also tell Stata how to deal with possible single units in a stratum by setting the `singleunit` option. After we `svyset` these elements, we can use `svydescribe` to view detailed information about the design elements.


```stata
use NSS_exercise, clear
svyset psu [pw = pweight], strata(fs_strata) singleunit(centered)

svydescribe
```

I am omitting the `svydescribe` output here because it is quite long. But if you run it on your machine, you will notice that the output from `svydescribe` is very similar but not identical to what is listed in the documentation. 

In the `svydescribe` output, we see 3,143 total (sub)strata, 12,737 PSUs and a total of 456,999 individuals. The overview section of the documentation says that 12,654 PSUs out of an allotted 12,808 were surveyed while the file titled "Estimation Procedure_68.doc" says that 12,784 PSUs were allotted. The overview section also states that 100,957 households and 459,784 individuals were surveyed. All of these figures differ slightly from what we find in the files. And doing a similar exercise for the `Block_3_Household characteristics`, I find that the number of households surveyed is 101,724. 

I am not entirely sure how to reconcile the differences between the documentation and what we see in the files. Perhaps in some cases the NSSO could not survey an allotted PSU due to difficult field conditions. Browsing through the `svydescribe` output, we see some strata in which the output from `svydescribe` lists three units where the "Estimation Procedure_68.doc" file lists four allotted PSUs, which seems like evidence in favor of this hypothesis. The discrepancies could also be due to human error in writing up the documentation. Or perhaps some additional cleaning of the data was done after the documentation was written. Maybe others will have some insights that I can incorporate into the post.

## Reproduce Some NSS Results

Let's try to replicate some of the household characteristics estimates from the report entitled "Key Indicators of Employment and Unemployment in India, 2011-12."

We will focus on Table 1 in section 3.3 on Labor Force Participation and Unemployment.

![](/media/table_3.3.2.png)

Next, we will generate indicator variables for "in the labor force" and "unemployed" based on "usual principal activity status". Here are the relevant codes:

- 11-51: Employed (we won't use these; but good to know)
- 81: Unemployed
- 91-99: Not in labor force


```stata
gen inlf = (upas_code < 90)
lab var inlf "in the labor force"

gen unemployed = (upas_code == 81)
lab var unemployed "unemployed"
```

```

```

We also need an indicator variables for working age, rural and urban:


```stata
gen working_age = (age >14 & age <60)
gen rural = (sector == "1")
gen urban = (sector == "2")
```

```

```

Now, with the help of the `subpop()` and `over()` options, we can reproduce some of the statistics in the table. Let's do labor force participation rates with a breakdown for sector (rural versus urban) and sex that we see in column (2):


```stata
svy, subpop(rural): mean inlf, over(sex)
svy, subpop(rural): mean inlf
svy, subpop(urban): mean inlf, over(sex)
svy, subpop(urban): mean inlf
svy: mean inlf
```

```
(running mean on estimation sample)

Survey: Mean estimation

Number of strata = 1,824         Number of obs   =     280,763
Number of PSUs   = 7,469         Population size = 774,430,086
                                 Subpop. no. obs =     280,763
                                 Subpop. size    = 774,430,086
                                 Design df       =       5,645

--------------------------------------------------------------
             |             Linearized
             |       Mean   std. err.     [95% conf. interval]
-------------+------------------------------------------------
  c.inlf@sex |
          0  |   .5465586   .0022148      .5422167    .5509005
          1  |    .181117    .002068       .177063     .185171
--------------------------------------------------------------
Note: 1319 strata omitted because they contain no
      subpopulation members.
Note: Strata with single sampling unit centered at overall
      mean.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata = 1,824         Number of obs   =     280,763
Number of PSUs   = 7,469         Population size = 774,430,086
                                 Subpop. no. obs =     280,763
                                 Subpop. size    = 774,430,086
                                 Design df       =       5,645

--------------------------------------------------------------
             |             Linearized
             |       Mean   std. err.     [95% conf. interval]
-------------+------------------------------------------------
        inlf |   .3678965    .001517      .3649225    .3708704
--------------------------------------------------------------
Note: 1319 strata omitted because they contain no
      subpopulation members.
Note: Strata with single sampling unit centered at overall
      mean.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata = 1,319         Number of obs   =     176,236
Number of PSUs   = 5,268         Population size = 313,825,569
                                 Subpop. no. obs =     176,236
                                 Subpop. size    = 313,825,569
                                 Design df       =       3,949

--------------------------------------------------------------
             |             Linearized
             |       Mean   std. err.     [95% conf. interval]
-------------+------------------------------------------------
  c.inlf@sex |
          0  |   .5597634    .002912      .5540542    .5654726
          1  |   .1340984   .0024558      .1292836    .1389132
--------------------------------------------------------------
Note: 1824 strata omitted because they contain no
      subpopulation members.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata = 1,319         Number of obs   =     176,236
Number of PSUs   = 5,268         Population size = 313,825,569
                                 Subpop. no. obs =     176,236
                                 Subpop. size    = 313,825,569
                                 Design df       =       3,949

--------------------------------------------------------------
             |             Linearized
             |       Mean   std. err.     [95% conf. interval]
-------------+------------------------------------------------
        inlf |   .3555847   .0020774      .3515118    .3596576
--------------------------------------------------------------
Note: 1824 strata omitted because they contain no
      subpopulation members.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata =  3,143      Number of obs   =       456,999
Number of PSUs   = 12,737      Population size = 1,088,255,655
                               Design df       =         9,594

--------------------------------------------------------------
             |             Linearized
             |       Mean   std. err.     [95% conf. interval]
-------------+------------------------------------------------
        inlf |   .3643461    .001232      .3619311     .366761
--------------------------------------------------------------
Note: Strata with single sampling unit centered at overall
      mean.
```

Notice that in addition to the correct estimate of labor force participation rates, `svy` also gives us a standard error and confidence intervals for each estimate.

Now let's reproduce the labor force participation rates for the working age population that we see in column (6):


```stata
svy, subpop(working_age): mean inlf, over(rural sex)
svy, subpop(working_age): mean inlf, over(rural)
svy, subpop(working_age): mean inlf, over(sex)
svy, subpop(working_age): mean inlf
```

```
(running mean on estimation sample)

Survey: Mean estimation

Number of strata =  3,143         Number of obs   =        456,999
Number of PSUs   = 12,737         Population size =  1,088,255,655
                                  Subpop. no. obs =        288,782
                                  Subpop. size    = 674,200,360.03
                                  Design df       =          9,594

------------------------------------------------------------------
                 |             Linearized
                 |       Mean   std. err.     [95% conf. interval]
-----------------+------------------------------------------------
c.inlf@rural#sex |
            0 0  |     .80556   .0031986      .7992902    .8118299
            0 1  |   .1927081   .0035107      .1858264    .1995897
            1 0  |   .8271007    .002589      .8220256    .8321757
            1 1  |   .2706094   .0031026      .2645276    .2766911
------------------------------------------------------------------
Note: Strata with single sampling unit centered at overall mean.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata =  3,143     Number of obs   =        456,999
Number of PSUs   = 12,737     Population size =  1,088,255,655
                              Subpop. no. obs =        288,782
                              Subpop. size    = 674,200,360.03
                              Design df       =          9,594

--------------------------------------------------------------
             |             Linearized
             |       Mean   std. err.     [95% conf. interval]
-------------+------------------------------------------------
c.inlf@rural |
          0  |    .510282    .002636      .5051149    .5154491
          1  |   .5512227   .0019802      .5473411    .5551042
--------------------------------------------------------------
Note: Strata with single sampling unit centered at overall
      mean.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata =  3,143     Number of obs   =        456,999
Number of PSUs   = 12,737     Population size =  1,088,255,655
                              Subpop. no. obs =        288,782
                              Subpop. size    = 674,200,360.03
                              Design df       =          9,594

--------------------------------------------------------------
             |             Linearized
             |       Mean   std. err.     [95% conf. interval]
-------------+------------------------------------------------
  c.inlf@sex |
          0  |   .8203601   .0020346      .8163717    .8243484
          1  |   .2471564    .002415      .2424225    .2518903
--------------------------------------------------------------
Note: Strata with single sampling unit centered at overall
      mean.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata =  3,143     Number of obs   =        456,999
Number of PSUs   = 12,737     Population size =  1,088,255,655
                              Subpop. no. obs =        288,782
                              Subpop. size    = 674,200,360.03
                              Design df       =          9,594

--------------------------------------------------------------
             |             Linearized
             |       Mean   std. err.     [95% conf. interval]
-------------+------------------------------------------------
        inlf |     .53865   .0015887      .5355358    .5417643
--------------------------------------------------------------
Note: Strata with single sampling unit centered at overall
      mean.
```

Finally, let's scroll down to Table 3 in section 3.5 and reproduce some of the unemployment figures in the report.

![](/media/table_3_unemployment.png)

For this one, we will just stick to reproducing the estimates for the working age population in column (6):


```stata
svy, subpop(inlf): mean unemployed, over(working_age rural sex)
svy, subpop(inlf): mean unemployed, over(working_age rural)
svy, subpop(inlf): mean unemployed, over(working_age sex)
svy, subpop(inlf): mean unemployed, over(working_age)
```

```
(running mean on estimation sample)

Survey: Mean estimation

Number of strata =  3,143                  Number of obs   =        456,999
Number of PSUs   = 12,737                  Population size =  1,088,255,655
                                           Subpop. no. obs =        164,620
                                           Subpop. size    = 396,501,682.08
                                           Design df       =          9,594

---------------------------------------------------------------------------
                          |             Linearized
                          |       Mean   std. err.     [95% conf. interval]
--------------------------+------------------------------------------------
 c.unemployed@working_age#|
                rural#sex |
                   0 0 0  |   .0100205   .0022948      .0055223    .0145187
                   0 0 1  |   .0046984    .003349     -.0018663     .011263
                   0 1 0  |   .0080207   .0017522       .004586    .0114554
                   0 1 1  |   .0189719   .0083139      .0026749     .035269
                   1 0 0  |   .0337286   .0021231       .029567    .0378903
                   1 0 1  |   .0686814   .0043917      .0600726    .0772901
                   1 1 0  |   .0225626   .0010541      .0204962    .0246289
                   1 1 1  |   .0301504   .0019821      .0262651    .0340357
---------------------------------------------------------------------------
Note: Strata with single sampling unit centered at overall mean.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata =  3,143                  Number of obs   =        456,999
Number of PSUs   = 12,737                  Population size =  1,088,255,655
                                           Subpop. no. obs =        164,620
                                           Subpop. size    = 396,501,682.08
                                           Design df       =          9,594

---------------------------------------------------------------------------
                          |             Linearized
                          |       Mean   std. err.     [95% conf. interval]
--------------------------+------------------------------------------------
 c.unemployed@working_age#|
                    rural |
                     0 0  |   .0091583   .0021191      .0050043    .0133122
                     0 1  |   .0103797   .0022743      .0059216    .0148378
                     1 0  |   .0400885   .0019124      .0363398    .0438371
                     1 1  |   .0244093   .0009591      .0225292    .0262893
---------------------------------------------------------------------------
Note: Strata with single sampling unit centered at overall mean.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata =  3,143                     Number of obs   =        456,999
Number of PSUs   = 12,737                     Population size =  1,088,255,655
                                              Subpop. no. obs =        164,620
                                              Subpop. size    = 396,501,682.08
                                              Design df       =          9,594

------------------------------------------------------------------------------
                             |             Linearized
                             |       Mean   std. err.     [95% conf. interval]
-----------------------------+------------------------------------------------
c.unemployed@working_age#sex |
                        0 0  |   .0083967   .0014861      .0054836    .0113099
                        0 1  |   .0169707   .0071731      .0029098    .0310315
                        1 0  |   .0259937   .0009807      .0240713    .0279161
                        1 1  |   .0391951   .0018342      .0355996    .0427905
------------------------------------------------------------------------------
Note: Strata with single sampling unit centered at overall mean.

(running mean on estimation sample)

Survey: Mean estimation

Number of strata =  3,143                 Number of obs   =        456,999
Number of PSUs   = 12,737                 Population size =  1,088,255,655
                                          Subpop. no. obs =        164,620
                                          Subpop. size    = 396,501,682.08
                                          Design df       =          9,594

--------------------------------------------------------------------------
                         |             Linearized
                         |       Mean   std. err.     [95% conf. interval]
-------------------------+------------------------------------------------
c.unemployed@working_age |
                      0  |   .0101621   .0019071      .0064237    .0139004
                      1  |   .0289707   .0008804       .027245    .0306964
--------------------------------------------------------------------------
Note: Strata with single sampling unit centered at overall mean.
```

Here we are able to reproduce the report's result that based on "usual status", the unemployment rate is roughly 2.4% in the rural sector, about 4% in the urban sector and 2.3% overall as well as the breakdown for males and females.

## What About the Second Stage Strata?

You might be thinking, "What about the second stage strata? Should we also include those when we `svset` the data to make our estimates even more precise?"" Let's try this and see what happens.

First, let's produce a second stage strata identifier:


```stata
gen ss_strata = hamlet_subblock + ss_strata_no
lab var ss_strata "second stage strata"
```

```

```

Now, let's try using `svyset`:


```stata
svyset psu [pw = pweight], strata(fs_strata) ///
|| household, strata(ss_strata) singleunit(centered)
```

```
note: stage 1 is sampled with replacement; further stages will be ignored for
      variance estimation.

Sampling weights: pweight
             VCE: linearized
     Single unit: centered
        Strata 1: fs_strata
 Sampling unit 1: psu
           FPC 1: <zero>
```

Stata gives a note that it is not considering the second stage strata. According to [this thread](https://www.stata.com/statalist/archive/2006-06/msg00074.html), this has to do the with the fact that a finite population correction (FPC) has not been specified in the `svyset` syntax.

For NSS data, FPC cannot be included for the rural sector because PSUs are indeed selected with replacement as per the survey design. While FPC could theoretically be included for the urban sector, the data needed for calculating the FPC (strata sampling rates or units of population belonging to strata) are not publicly available.

However, there is also an argument to be made that second stage strata may not be all that important for calculations based on NSS data due to the size of India's population. If the population is so big relative to the sample then you can treat it as infinite, then the second stage strata are immaterial.

## Conclusion

In this post, I reviewed the basic survey design for the NSS Employment & Unemployment Survey and then gave a couple of examples of how to reproduce the results from the survey's main report. Of course, the real fun in being able to access the unit-level NSS data is going to be in producing your own original estimates. Let me know what you come up with!

<script src="https://utteranc.es/client.js"
        repo="eteitelbaum/academic-website"
        issue-term="pathname"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>
