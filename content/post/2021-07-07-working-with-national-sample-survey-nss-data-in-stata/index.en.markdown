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

(file NSS_exercise.dta not found)
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

```
Sampling weights: pweight
             VCE: linearized
     Single unit: centered
        Strata 1: fs_strata
 Sampling unit 1: psu
           FPC 1: <zero>


Survey: Describing stage 1 sampling units

Sampling weights: pweight
             VCE: linearized
     Single unit: centered
        Strata 1: fs_strata
 Sampling unit 1: psu
           FPC 1: <zero>

                                    Number of obs per unit
 Stratum   # units     # obs       Min      Mean       Max
----------------------------------------------------------
 0110101         3       145        38      48.3        61
 0110102         4       175        39      43.8        50
 0110103         4       183        34      45.8        55
 0110104         4       165        29      41.3        50
 0110105         4       203        47      50.8        55
 0110106         3       142        37      47.3        54
 0110201         4       188        45      47.0        50
 0110202         4       162        37      40.5        45
 0110203         4       173        38      43.3        48
 0110204         4       148        31      37.0        43
 0110205         4       178        31      44.5        52
 0110206         4       209        45      52.3        62
 0110207         3       121        35      40.3        50
 0110208         4       176        33      44.0        58
 0110301         4       187        41      46.8        63
 0110302         4       201        44      50.3        56
 0110401         4       196        44      49.0        53
 0110402         4       193        43      48.3        62
 0110403         4       184        43      46.0        49
 0110404         4       223        45      55.8        71
 0110405         4       208        37      52.0        68
 0110501         3       141        43      47.0        49
 0110502         4       161        37      40.3        44
 0110503         4       189        38      47.3        54
 0110504         4       197        46      49.3        55
 0110505         4       156        30      39.0        47
 0110601         4       189        42      47.3        52
 0110602         4       187        39      46.8        55
 0110603         4       175        35      43.8        53
 0110604         4       184        44      46.0        48
 0110605         4       200        37      50.0        71
 0110606         4       191        43      47.8        56
 0110607         4       176        31      44.0        53
 0110608         3       134        40      44.7        47
 0110701         4       155        27      38.8        47
 0110801         4       180        36      45.0        63
 0110901         4       158        36      39.5        45
 0110902         4       194        43      48.5        60
 0110903         4       165        36      41.3        45
 0110904         4       163        37      40.8        48
 0110905         4       168        37      42.0        48
 0110906         4       162        35      40.5        44
 0111001         3       115        36      38.3        41
 0111002         4       172        39      43.0        48
 0111003         4       183        40      45.8        52
 0111004         4       139        30      34.8        43
 0111005         4       188        39      47.0        53
 0111006         4       153        35      38.3        42
 0111101         4       160        34      40.0        47
 0111102         4       171        35      42.8        55
 0111103         4       169        41      42.3        43
 0111201         4       166        35      41.5        53
 0111202         4       133        31      33.3        39
 0111203         4       179        36      44.8        56
 0111204         4       184        41      46.0        52
 0111301         4       156        34      39.0        44
 0111302         4       159        36      39.8        47
 0111303         4       154        33      38.5        48
 0111304         4       146        32      36.5        44
 0111305         4       170        39      42.5        51
 0111306         4       147        31      36.8        44
 0111401         4       141        31      35.3        43
 0111402         4       140        28      35.0        42
 0111403         4       154        33      38.5        48
 0111404         4       167        33      41.8        60
 0120101         4       139        12      34.8        50
 0120201         4       144        22      36.0        46
 0120202         4       167        38      41.8        50
 0120203         4       184        35      46.0        63
 0120204         4       166        33      41.5        46
 0120301         4       171        31      42.8        50
 0120302         4       184        37      46.0        56
 0120303         4       222        40      55.5        70
 0120304         4       195        41      48.8        54
 0120305         4       187        37      46.8        58
 0120306         4       166        31      41.5        51
 0120307         4       176        35      44.0        53
 0120308         4       194        37      48.5        58
 0120309         4       156        32      39.0        44
 0120310         4       141        31      35.3        43
 0120311         4       165        35      41.3        53
 0120312         4       155        34      38.8        43
 0120313         4       154        34      38.5        45
 0120401         4       174        40      43.5        49
 0120501         4       166        32      41.5        47
 0120601         4       175        36      43.8        57
 0120602         4       175        40      43.8        47
 0120603         4       197        37      49.3        70
 0120701         4       131        16      32.8        49
 0120801         4       129        21      32.3        38
 0120901         4       123        26      30.8        36
 0121001         4       129        10      32.3        47
 0121002         4       145        31      36.3        42
 0121101         4       136        29      34.0        38
 0121201         4       137        21      34.3        44
 0121301         4       130        30      32.5        37
 0121302         4       136        24      34.0        41
 0121303         4       152        34      38.0        46
 0121304         4       147        25      36.8        44
 0121305         4       130        28      32.5        42
 0121306         4       120        24      30.0        35
 0121307         4       160        28      40.0        57
 0121308         4        81         2      20.3        32
 0121309         4       131        27      32.8        39
 0121310         4       142        30      35.5        40
 0121311         4       145        25      36.3        53
 0121312         4       186        43      46.5        50
 0121401         3       117        29      39.0        47
 0210101         4       164        31      41.0        48
 0210102         4       166        38      41.5        44
 0210103         4       142        27      35.5        42
 0210104         4       131        21      32.8        44
 0210201         4       117        13      29.3        44
 0210202         4       135        29      33.8        40
 0210203         4       135        31      33.8        37
 0210204         4       135        29      33.8        39
 0210205         4       130        26      32.5        37
 0210206         4       134        28      33.5        40
 0210207         4       129        30      32.3        34
 0210208         4       138        26      34.5        40
 0210209         4       127        28      31.8        37
 0210210         4       128        30      32.0        36
 0210301         4       134        29      33.5        37
 0210302         4       125        20      31.3        43
 0210401         4       154        35      38.5        42
 0210402         4       148        28      37.0        44
 0210403         4       150        19      37.5        46
 0210501         4       135        24      33.8        40
 0210502         4       121        26      30.3        34
 0210503         4       125        27      31.3        41
 0210504         4       121        23      30.3        41
 0210505         4       137        28      34.3        44
 0210506         4       118        24      29.5        35
 0210507         4       160        34      40.0        46
 0210601         4       123        22      30.8        44
 0210602         4       115        25      28.8        33
 0210603         4       128        26      32.0        39
 0210604         4       124        25      31.0        36
 0210701         4       125        28      31.3        37
 0210702         4       144        26      36.0        43
 0210703         4       120        25      30.0        36
 0210704         4       140        31      35.0        38
 0210801         4       136        26      34.0        43
 0210802         4       130        28      32.5        43
 0210803         4       141        31      35.3        39
 0210901         4       148        26      37.0        48
 0210902         4       166        34      41.5        51
 0210903         4       138        24      34.5        47
 0210904         4       170        39      42.5        50
 0211001         4       149        32      37.3        43
 0211002         4       151        29      37.8        50
 0211003         4       228        32      57.0        73
 0211004         4       176        33      44.0        53
 0211101         4       160        35      40.0        47
 0211102         4       123        26      30.8        34
 0211103         4       145        34      36.3        40
 0211104         4       141        25      35.3        54
 0211105         4       152        26      38.0        63
 0211201         4       118        20      29.5        37
 0211202         4       115        17      28.8        39
 0220101         4       120        27      30.0        32
 0220201         4       125        23      31.3        46
 0220401         4        93        19      23.3        30
 0220501         4       103         8      25.8        39
 0220601         4       127        28      31.8        36
 0220701         4       160        35      40.0        52
 0220801         4       105        24      26.3        29
 0220901         4       124        19      31.0        45
 0220902         4       104        22      26.0        33
 0221001         4       124        29      31.0        32
 0221101         4        96        15      24.0        35
 0221102         4        86        16      21.5        30
 0310101         4       173        33      43.3        52
 0310102         4       165        37      41.3        45
 0310103         4       148        35      37.0        40
 0310104         4       163        36      40.8        44
 0310201         4       162        31      40.5        47
 0310202         4       173        31      43.3        61
 0310203         4       149        29      37.3        49
 0310301         4       148        30      37.0        44
 0310302         4       156        32      39.0        51
 0310401         4       150        34      37.5        44
 0310402         4       147        33      36.8        45
 0310403         4       142        28      35.5        50
 0310501         4       146        33      36.5        40
 0310502         4       159        29      39.8        49
 0310503         4       141        31      35.3        42
 0310504         4       154        34      38.5        43
 0310601         4       151        31      37.8        45
 0310602         4       135        25      33.8        41
 0310701         4       149        31      37.3        43
 0310702         4       119        23      29.8        38
 0310801         4       172        37      43.0        49
 0310901         4       169        33      42.3        47
 0310902         4       151        34      37.8        42
 0310903         4       129        30      32.3        35
 0310904         4       163        34      40.8        48
 0311001         4       166        39      41.5        45
 0311002         4       148        30      37.0        48
 0311101         4       165        37      41.3        46
 0311102         4       185        39      46.3        52
 0311103         4       157        36      39.3        46
 0311104         4       149        29      37.3        43
 0311201         4       143        27      35.8        44
 0311202         4       153        32      38.3        44
 0311301         4       165        34      41.3        51
 0311401         4       150        29      37.5        43
 0311402         4       173        39      43.3        46
 0311403         4       183        37      45.8        60
 0311501         4       142        33      35.5        38
 0311502         4       151        25      37.8        45
 0311601         3       119        32      39.7        46
 0311602         4       156        35      39.0        42
 0311603         4       175        35      43.8        52
 0311701         4       153        31      38.3        44
 0311702         4       179        39      44.8        53
 0311703         4       166        36      41.5        49
 0311801         3       116        31      38.7        50
 0311901         4       156        28      39.0        49
 0312001         4       158        31      39.5        48
 0312002         4       149        32      37.3        42
 0320101         4       121        23      30.3        35
 0320102         4       156        35      39.0        43
 0320103         4       142        30      35.5        39
 0320201         4       141        28      35.3        42
 0320202         4       165        28      41.3        50
 0320203         4       145        29      36.3        45
 0320204         4       141        32      35.3        40
 0320205         4       138        29      34.5        37
 0320206         4       117        23      29.3        40
 0320301         4       140        32      35.0        37
 0320302         4       145        25      36.3        46
 0320401         4       142        27      35.5        41
 0320402         4       115        17      28.8        37
 0320403         4       118        25      29.5        34
 0320404         4       117        25      29.3        36
 0320405         4       128        31      32.0        33
 0320501         4       150        34      37.5        42
 0320502         4       131        23      32.8        41
 0320601         4       150        30      37.5        42
 0320701         4       114        20      28.5        32
 0320801         4       118        24      29.5        33
 0320901         4       133        28      33.3        38
 0320902         4       127        29      31.8        34
 0321001         4       152        32      38.0        42
 0321101         4       158        32      39.5        48
 0321102         4       141        33      35.3        39
 0321103         4       146        29      36.5        49
 0321201         4       130        27      32.5        37
 0321301         4       165        36      41.3        47
 0321401         4       135        31      33.8        37
 0321402         4       153        30      38.3        47
 0321501         4       173        40      43.3        45
 0321601         4       141        34      35.3        39
 0321602         4       145        35      36.3        38
 0321603         4       163        32      40.8        46
 0321701         4       175        34      43.8        57
 0321702         4       137        20      34.3        43
 0321703         4       136        29      34.0        44
 0321704         4       122        24      30.5        35
 0321801         4       127        27      31.8        37
 0321802         4       129        23      32.3        38
 0321901         4       157        35      39.3        41
 0322001         4       155        26      38.8        48
 0322101         4       127        24      31.8        41
 0322102         4       117        14      29.3        38
 0322103         4       135        26      33.8        38
 0322104         4       148        33      37.0        42
 0322105         4       121        22      30.3        35
 0322106         4       127        25      31.8        37
 0410101         4       148        33      37.0        41
 0410102         4       147        33      36.8        41
 0420101         4       123        16      30.8        42
 0420102         4       105        17      26.3        33
 0420103         3        75        13      25.0        31
 0420104         4       105        17      26.3        35
 0420105         4       121        23      30.3        37
 0420106         4       139        26      34.8        44
 0420107         4       139        27      34.8        47
 0420108         4       116        18      29.0        42
 0510101         4       129        30      32.3        35
 0510102         4       119        28      29.8        31
 0510201         4       130        22      32.5        40
 0510202         4       154        34      38.5        47
 0510301         4       140        32      35.0        38
 0510302         4       126        25      31.5        38
 0510401         4       136        29      34.0        42
 0510402         4       135        28      33.8        37
 0510403         4       131        24      32.8        39
 0510501         4       150        29      37.5        51
 0510502         3       130        32      43.3        56
 0510503         4       145        31      36.3        40
 0510601         4       142        33      35.5        38
 0510602         4       124        24      31.0        44
 0510603         4       144        32      36.0        38
 0510701         4       133        27      33.3        42
 0510702         4       117        22      29.3        36
 0510801         4       145        32      36.3        40
 0510802         4       121        25      30.3        37
 0510901         4       119        25      29.8        35
 0510902         4       153        35      38.3        42
 0510903         4       159        35      39.8        47
 0511001         4       161        36      40.3        45
 0511101         4       142        34      35.5        38
 0511102         4       154        27      38.5        44
 0511201         4       160        34      40.0        47
 0511202         4       167        34      41.8        56
 0511203         4       154        33      38.5        44
 0511301         4       188        45      47.0        49
 0511302         4       192        41      48.0        53
 0511303         4       187        36      46.8        53
 0511401         4       171        37      42.8        55
 0511501         4       172        25      43.0        60
 0520101         4       117        26      29.3        35
 0520201         4       117        23      29.3        36
 0520301         4       106        22      26.5        31
 0520401         4       101        16      25.3        33
 0520501         4       155        35      38.8        45
 0520502         4       136        26      34.0        48
 0520503         4       124        24      31.0        36
 0520601         4       129        24      32.3        38
 0520602         4       123        29      30.8        33
 0520701         4       109        26      27.3        29
 0520801         4        98        20      24.5        30
 0520901         4       143        30      35.8        40
 0521001         4       132        28      33.0        38
 0521101         4       149        28      37.3        49
 0521102         4       158        34      39.5        47
 0521201         4       173        26      43.3        58
 0521202         4       174        38      43.5        48
 0521203         4       174        34      43.5        62
 0521301         4       160        30      40.0        50
 0521302         4       110        19      27.5        38
 0521303         4       138        26      34.5        40
 0521401         4       104        16      26.0        32
 0521501         4       124        24      31.0        39
 0610101         3       136        41      45.3        52
 0610201         4       170        36      42.5        46
 0610202         4       174        33      43.5        54
 0610301         4       192        41      48.0        56
 0610302         4       144        32      36.0        44
 0610401         4       156        35      39.0        43
 0610402         4       145        28      36.3        46
 0610501         4       179        36      44.8        53
 0610502         4       152        30      38.0        46
 0610601         4       189        38      47.3        54
 0610602         4       155        33      38.8        45
 0610603         4       158        36      39.5        42
 0610701         4       181        38      45.3        53
 0610702         4       167        32      41.8        57
 0610801         4       150        36      37.5        41
 0610802         4       170        35      42.5        54
 0610803         4       149        33      37.3        46
 0610901         4       179        39      44.8        51
 0610902         4       157        37      39.3        46
 0610903         4       199        45      49.8        55
 0611001         4       171        34      42.8        50
 0611002         4       159        35      39.8        44
 0611101         4       163        34      40.8        47
 0611102         4       164        32      41.0        45
 0611103         4       158        34      39.5        44
 0611201         4       173        32      43.3        59
 0611202         4       154        29      38.5        46
 0611203         4       165        38      41.3        45
 0611301         4       165        38      41.3        44
 0611302         4       172        39      43.0        49
 0611303         4       143        34      35.8        40
 0611401         4       164        36      41.0        48
 0611402         4       179        39      44.8        49
 0611501         4       154        33      38.5        43
 0611502         4       189        37      47.3        56
 0611601         4       150        33      37.5        42
 0611602         4       147        32      36.8        43
 0611701         4       153        30      38.3        44
 0611702         4       143        28      35.8        45
 0611801         4       161        33      40.3        44
 0611802         3       108        31      36.0        42
 0611901         4       240        47      60.0        73
 0611902         4       164        30      41.0        49
 0612001         4       221        38      55.3        62
 0612002         4       188        39      47.0        54
 0620101         4       103        15      25.8        32
 0620201         4       131        28      32.8        36
 0620202         4       130        29      32.5        38
 0620301         4       144        32      36.0        39
 0620302         4       154        33      38.5        44
 0620401         4       134        27      33.5        41
 0620501         4       156        30      39.0        51
 0620601         4       151        30      37.8        52
 0620602         4       158        33      39.5        48
 0620701         4       140        31      35.0        38
 0620702         4       161        36      40.3        44
 0620801         4       173        30      43.3        53
 0620802         4       130        28      32.5        37
 0620901         4       158        28      39.5        48
 0620902         4       137        28      34.3        43
 0621001         4       135        30      33.8        39
 0621101         4       160        37      40.0        49
 0621102         4       134        19      33.5        43
 0621201         4       139        33      34.8        37
 0621202         4       145        33      36.3        40
 0621301         4       147        34      36.8        44
 0621302         4       148        21      37.0        43
 0621401         4       147        23      36.8        57
 0621402         4       147        32      36.8        42
 0621501         4       133        31      33.3        36
 0621601         4       154        29      38.5        47
 0621701         4       149        31      37.3        44
 0621801         4       109        21      27.3        32
 0621802         4       110        23      27.5        36
 0621901         4       134        30      33.5        38
 0622001         4       161        31      40.3        47
 0622101         2        64        22      32.0        42
 0622102         4       137        32      34.3        38
 0622103         4       129        26      32.3        37
 0622104         4       155        33      38.8        51
 0622105         4       126        26      31.5        40
 0622106         4       150        30      37.5        41
 0719901         4       138        29      34.5        46
 0719902         4       146        27      36.5        48
 0721001         4       111        22      27.8        37
 0721002         4       138        30      34.5        45
 0721003         4       146        29      36.5        47
 0721004         4       135        22      33.8        41
 0721005         4       148        31      37.0        44
 0721006         4       138        31      34.5        41
 0721007         4       140        25      35.0        48
 0721008         4       142        31      35.5        40
 0721009         4       116        23      29.0        34
 0721010         4       119        18      29.8        41
 0721011         4       121        27      30.3        34
 0721012         4       120        25      30.0        38
 0721013         4       118        24      29.5        38
 0721014         4       102        18      25.5        34
 0721015         4       105         9      26.3        37
 0721016         4       106        13      26.5        38
 0721017         4       137        19      34.3        53
 0721018         4       144        34      36.0        41
 0721019         4       126        21      31.5        48
 0721020         4        95        18      23.8        31
 0721021         4       119        27      29.8        35
 0721022         4       102        13      25.5        32
 0721023         4        80        12      20.0        28
 0729901         4        94        17      23.5        30
 0729902         4       125        23      31.3        42
 0729903         4       138        26      34.5        48
 0729904         4       102        17      25.5        30
 0729905         4       154        28      38.5        46
 0729906         4       148        29      37.0        46
 0729907         4       128        30      32.0        37
 0810101         4       122        27      30.5        33
 0810102         4       148        34      37.0        44
 0810103         4       180        39      45.0        50
 0810201         4       151        31      37.8        48
 0810202         4       173        27      43.3        53
 0810301         4       138        26      34.5        44
 0810302         4       147        28      36.8        41
 0810401         4       176        37      44.0        60
 0810402         4       141        31      35.3        41
 0810403         4       181        36      45.3        53
 0810501         4       155        35      38.8        41
 0810502         4       173        35      43.3        52
 0810503         4       154        26      38.5        46
 0810601         4       193        45      48.3        54
 0810602         4       173        34      43.3        51
 0810603         4       172        39      43.0        46
 0810604         3       116        36      38.7        42
 0810701         4       176        30      44.0        58
 0810702         4       172        34      43.0        52
 0810703         4       172        36      43.0        46
 0810801         4       201        37      50.3        65
 0810802         4       154        31      38.5        46
 0810901         4       177        34      44.3        53
 0810902         4       156        29      39.0        52
 0811001         4       152        30      38.0        49
 0811002         4       141        33      35.3        38
 0811101         4       179        38      44.8        61
 0811102         4       177        36      44.3        56
 0811201         4       197        35      49.3        56
 0811202         4       196        35      49.0        72
 0811203         4       173        36      43.3        60
 0811204         4       162        31      40.5        50
 0811301         4       208        41      52.0        62
 0811302         4       174        35      43.5        56
 0811303         4       190        45      47.5        50
 0811401         4       166        29      41.5        57
 0811402         4       171        34      42.8        54
 0811403         4       175        40      43.8        50
 0811404         4       150        30      37.5        43
 0811501         4       160        35      40.0        48
 0811502         4       167        36      41.8        47
 0811503         4       136        27      34.0        38
 0811601         4       142        22      35.5        49
 0811701         4       156        35      39.0        45
 0811702         4       158        31      39.5        45
 0811703         4       163        34      40.8        51
 0811801         4       173        38      43.3        49
 0811802         4       173        40      43.3        49
 0811803         4       141        29      35.3        39
 0811901         4       174        36      43.5        53
 0812001         4       179        35      44.8        53
 0812002         4       149        30      37.3        48
 0812003         4       134        28      33.5        40
 0812101         4       153        24      38.3        51
 0812102         4       180        42      45.0        52
 0812103         4       197        42      49.3        65
 0812201         4       154        27      38.5        43
 0812202         4       147        32      36.8        40
 0812301         4       137        29      34.3        40
 0812302         4       177        33      44.3        51
 0812401         4       172        32      43.0        58
 0812402         4       139        33      34.8        37
 0812403         4       178        41      44.5        50
 0812501         4       155        29      38.8        56
 0812502         4       143        20      35.8        45
 0812601         4       151        34      37.8        44
 0812602         4       137        25      34.3        48
 0812603         4       146        30      36.5        46
 0812701         4       146        27      36.5        43
 0812702         4       144        34      36.0        38
 0812801         4       130        24      32.5        36
 0812802         4       128        28      32.0        39
 0812803         4       146        32      36.5        42
 0812901         4       158        34      39.5        47
 0812902         4       161        28      40.3        59
 0812903         4       135        23      33.8        48
 0813001         4       144        31      36.0        40
 0813101         4       153        35      38.3        43
 0813102         4       164        34      41.0        47
 0813201         4       152        35      38.0        41
 0813202         4       151        32      37.8        44
 0820101         4       155        31      38.8        48
 0820102         4       139        24      34.8        41
 0820201         4       162        32      40.5        52
 0820301         4       166        33      41.5        51
 0820302         4       155        34      38.8        43
 0820401         4       154        31      38.5        44
 0820402         4       151        29      37.8        47
 0820501         4       156        29      39.0        51
 0820601         4       135        28      33.8        45
 0820701         4       131        26      32.8        42
 0820801         4       145        29      36.3        41
 0820901         4       147        29      36.8        47
 0821001         4       141        23      35.3        43
 0821101         4       133        17      33.3        43
 0821201         4       125        20      31.3        38
 0821301         4       164        34      41.0        47
 0821302         4       161        35      40.3        50
 0821401         4       179        35      44.8        62
 0821402         4       188        31      47.0        65
 0821501         4       192        40      48.0        62
 0821502         4       157        36      39.3        41
 0821601         4       121        13      30.3        47
 0821701         4       154        27      38.5        46
 0821801         4       134        24      33.5        42
 0821901         3       117        33      39.0        45
 0822001         4       128        20      32.0        41
 0822101         4       144        27      36.0        51
 0822102         4       161        37      40.3        43
 0822201         4       124        27      31.0        34
 0822301         4       144        19      36.0        51
 0822401         4       126        23      31.5        42
 0822501         4       151        34      37.8        44
 0822601         4       130        23      32.5        36
 0822602         4       128        24      32.0        36
 0822701         4       142        34      35.5        36
 0822801         4       145        32      36.3        41
 0822901         4       147        28      36.8        45
 0823001         4       151        35      37.8        43
 0823002         4       148        31      37.0        41
 0823101         4       141        33      35.3        37
 0823201         4       121        24      30.3        37
 0823301         4       146        29      36.5        46
 0823302         4       139        27      34.8        40
 0823303         4       181        37      45.3        54
 0823304         4       165        27      41.3        55
 0823305         4       143        27      35.8        44
 0823306         4       137        25      34.3        42
 0823307         4       135        25      33.8        37
 0823308         4       138        26      34.5        51
 0910101         4       189        43      47.3        52
 0910102         4       199        40      49.8        66
 0910103         4       169        39      42.3        47
 0910201         4       186        39      46.5        50
 0910202         4       219        46      54.8        71
 0910203         4       208        43      52.0        63
 0910204         4       172        30      43.0        69
 0910301         4       182        32      45.5        62
 0910302         4       168        37      42.0        52
 0910303         4       207        45      51.8        60
 0910401         4       180        41      45.0        47
 0910402         4       196        37      49.0        56
 0910403         4       176        39      44.0        54
 0910404         4       216        51      54.0        60
 0910501         4       214        41      53.5        60
 0910502         4       193        40      48.3        55
 0910601         4       198        38      49.5        59
 0910602         4       167        39      41.8        44
 0910701         4       180        40      45.0        49
 0910702         4       174        37      43.5        52
 0910801         4       184        32      46.0        57
 0910901         4       209        45      52.3        57
 0910902         4       183        41      45.8        54
 0911001         4       171        26      42.8        52
 0911101         4       169        38      42.3        45
 0911102         4       171        38      42.8        47
 0911103         4       160        33      40.0        47
 0911201         4       184        40      46.0        51
 0911202         4       175        39      43.8        46
 0911203         4       177        37      44.3        48
 0911301         4       177        39      44.3        51
 0911302         4       171        40      42.8        47
 0911401         4       180        35      45.0        52
 0911402         4       232        56      58.0        60
 0911501         4       195        40      48.8        53
 0911502         4       201        41      50.3        57
 0911503         4       186        43      46.5        52
 0911601         4       172        39      43.0        49
 0911602         4       207        44      51.8        68
 0911701         4       158        32      39.5        49
 0911702         4       188        42      47.0        52
 0911801         4       179        41      44.8        51
 0911802         4       208        47      52.0        56
 0911901         4       178        33      44.5        54
 0911902         4       198        30      49.5        70
 0911903         4       163        28      40.8        54
 0912001         4       181        39      45.3        53
 0912002         4       170        33      42.5        56
 0912003         4       164        39      41.0        45
 0912101         4       169        31      42.3        54
 0912102         4       180        37      45.0        52
 0912201         4       166        35      41.5        53
 0912202         4       174        40      43.5        49
 0912203         4       201        45      50.3        64
 0912301         4       174        35      43.5        48
 0912302         4       177        37      44.3        52
 0912303         4       171        36      42.8        48
 0912304         4       164        35      41.0        49
 0912401         4       172        33      43.0        70
 0912402         4       164        34      41.0        53
 0912403         4       166        34      41.5        51
 0912404         4       199        34      49.8        72
 0912501         4       182        43      45.5        49
 0912502         4       197        43      49.3        52
 0912503         4       174        36      43.5        53
 0912504         4       174        29      43.5        52
 0912601         4       170        37      42.5        53
 0912602         4       168        30      42.0        51
 0912603         4       132        30      33.0        37
 0912701         4       177        35      44.3        53
 0912702         4       173        39      43.3        55
 0912801         4       150        27      37.5        49
 0912802         4       182        36      45.5        65
 0912803         4       169        37      42.3        46
 0912804         4       199        44      49.8        59
 0912901         4       218        44      54.5        68
 0912902         4       182        34      45.5        56
 0913001         4       181        42      45.3        51
 0913002         4       198        35      49.5        67
 0913101         4       168        35      42.0        47
 0913102         4       166        38      41.5        45
 0913201         4       179        35      44.8        51
 0913202         4       136        24      34.0        45
 0913301         4       137        33      34.3        35
 0913302         4       146        28      36.5        45
 0913401         4       149        31      37.3        47
 0913402         4       150        33      37.5        40
 0913501         4       161        30      40.3        49
 0913502         4       188        43      47.0        50
 0913601         4       139        32      34.8        36
 0913602         4       147        28      36.8        46
 0913701         4       134        28      33.5        39
 0913801         4       160        31      40.0        49
 0913901         4       145        33      36.3        39
 0914001         4       211        51      52.8        55
 0914002         4       179        26      44.8        63
 0914101         4       145        26      36.3        52
 0914201         4       114        27      28.5        31
 0914202         4       139        32      34.8        38
 0914203         4       192        36      48.0        60
 0914301         4       174        39      43.5        49
 0914302         4       199        38      49.8        58
 0914303         4       208        42      52.0        65
 0914304         4       184        29      46.0        54
 0914401         4       147        26      36.8        42
 0914402         4       161        30      40.3        49
 0914501         4       197        32      49.3        63
 0914502         4       170        31      42.5        59
 0914503         4       200        45      50.0        58
 0914504         4       178        37      44.5        58
 0914601         4       170        35      42.5        54
 0914602         4       225        45      56.3        67
 0914603         4       200        40      50.0        59
 0914701         4       187        38      46.8        58
 0914702         4       158        27      39.5        51
 0914801         4       173        31      43.3        64
 0914802         4       172        34      43.0        50
 0914803         4       201        43      50.3        58
 0914901         4       179        33      44.8        54
 0914902         4       194        41      48.5        58
 0914903         4       166        32      41.5        46
 0914904         4       169        38      42.3        46
 0915001         4       168        34      42.0        50
 0915002         4       153        24      38.3        47
 0915003         4       167        34      41.8        52
 0915101         4       144        26      36.0        41
 0915102         4       173        20      43.3        56
 0915201         4       134        24      33.5        41
 0915202         4       176        37      44.0        48
 0915301         4       141        29      35.3        41
 0915302         4       185        39      46.3        59
 0915303         4       171        37      42.8        46
 0915304         4       208        43      52.0        60
 0915401         4       173        34      43.3        55
 0915402         4       178        42      44.5        50
 0915403         4       190        30      47.5        65
 0915501         4       177        37      44.3        55
 0915502         4       179        37      44.8        48
 0915503         4       178        36      44.5        49
 0915601         4       191        39      47.8        63
 0915602         4       203        39      50.8        60
 0915701         4       179        40      44.8        55
 0915702         4       178        39      44.5        55
 0915703         4       192        37      48.0        60
 0915801         4       188        38      47.0        56
 0915802         4       183        41      45.8        49
 0915803         4       230        45      57.5        68
 0915804         4       176        41      44.0        50
 0915901         4       171        36      42.8        51
 0915902         4       181        36      45.3        60
 0915903         4       186        31      46.5        65
 0915904         4       189        43      47.3        52
 0916001         4       231        49      57.8        76
 0916002         4       177        37      44.3        49
 0916003         4       176        34      44.0        62
 0916101         4       230        48      57.5        78
 0916102         4       209        41      52.3        57
 0916103         4       204        37      51.0        58
 0916104         4       253        59      63.3        68
 0916201         4       198        35      49.5        64
 0916202         4       176        36      44.0        49
 0916301         4       238        47      59.5        74
 0916302         4       218        44      54.5        66
 0916303         4       174        41      43.5        46
 0916401         4       196        39      49.0        61
 0916402         4       195        33      48.8        74
 0916403         4       194        38      48.5        58
 0916404         4       211        48      52.8        56
 0916501         4       245        46      61.3        94
 0916502         4       191        40      47.8        54
 0916503         4       194        43      48.5        52
 0916504         4       186        38      46.5        51
 0916601         4       214        48      53.5        68
 0916602         4       181        41      45.3        51
 0916701         4       213        28      53.3        77
 0916702         4       228        47      57.0        63
 0916703         4       195        38      48.8        64
 0916801         4       244        42      61.0        80
 0916802         4       223        50      55.8        64
 0916901         4       191        42      47.8        60
 0916902         4       193        30      48.3        66
 0916903         4       182        37      45.5        55
 0917001         4       190        42      47.5        55
 0917002         4       157        38      39.3        40
 0917101         4       205        43      51.3        56
 0920101         4       156        27      39.0        53
 0920102         4       142        33      35.5        39
 0920201         4       166        32      41.5        48
 0920202         4       156        28      39.0        52
 0920301         4       186        36      46.5        57
 0920302         4       168        36      42.0        50
 0920401         4       161        33      40.3        45
 0920402         4       188        38      47.0        56
 0920501         4       171        33      42.8        53
 0920601         4       163        33      40.8        50
 0920701         4       169        39      42.3        47
 0920801         4       126        26      31.5        39
 0920901         4       147        30      36.8        41
 0920902         4       141        29      35.3        39
 0920903         4       114        16      28.5        44
 0921001         4       117        24      29.3        35
 0921101         4       157        35      39.3        47
 0921102         4       132        31      33.0        35
 0921201         4       168        28      42.0        50
 0921202         4       171        36      42.8        48
 0921301         4       194        43      48.5        57
 0921401         4       166        32      41.5        51
 0921402         4       170        33      42.5        52
 0921501         4       166        38      41.5        44
 0921601         4       189        40      47.3        57
 0921602         4       201        42      50.3        54
 0921701         4       159        32      39.8        47
 0921801         4       151        30      37.8        49
 0921901         4       194        38      48.5        65
 0922001         4       159        26      39.8        50
 0922002         4       156        36      39.0        46
 0922101         4       183        37      45.8        52
 0922201         4       170        31      42.5        52
 0922301         4       190        37      47.5        57
 0922401         4       160        33      40.0        47
 0922501         4       151        37      37.8        40
 0922601         4       158        28      39.5        48
 0922701         4       194        42      48.5        55
 0922801         4       152        31      38.0        46
 0922901         4       199        41      49.8        64
 0923001         4       191        40      47.8        62
 0923101         4       161        35      40.3        54
 0923201         4       148        27      37.0        49
 0923301         4       159        30      39.8        49
 0923401         4       116        22      29.0        35
 0923501         4       157        34      39.3        50
 0923601         4       123        25      30.8        39
 0923602         4       149        27      37.3        44
 0923701         4       163        36      40.8        46
 0923801         4       134        21      33.5        40
 0923901         4       143        32      35.8        43
 0924001         4       125        27      31.3        37
 0924101         4       153        32      38.3        42
 0924201         4       174        38      43.5        46
 0924301         4       187        41      46.8        56
 0924401         4       154        32      38.5        44
 0924501         4       149        19      37.3        55
 0924502         4       118        21      29.5        47
 0924601         4       154        34      38.5        42
 0924701         4       166        39      41.5        43
 0924801         4       201        43      50.3        59
 0924901         4       176        29      44.0        53
 0925001         4       161        38      40.3        46
 0925101         4       155        35      38.8        43
 0925201         4       168        36      42.0        46
 0925301         4       125        24      31.3        46
 0925401         4       152        22      38.0        50
 0925501         4       162        36      40.5        50
 0925601         4       158        35      39.5        48
 0925701         4       162        35      40.5        48
 0925801         4       172        35      43.0        54
 0925802         4       172        41      43.0        45
 0925901         4       179        38      44.8        50
 0926001         4       177        38      44.3        49
 0926101         4       202        42      50.5        56
 0926201         4       168        31      42.0        53
 0926301         4       192        41      48.0        58
 0926401         4       205        39      51.3        60
 0926501         4       192        36      48.0        60
 0926601         4       166        35      41.5        47
 0926701         4       187        36      46.8        52
 0926801         4       179        35      44.8        62
 0926901         4       157        38      39.3        40
 0927001         4       144        17      36.0        44
 0927101         4       186        43      46.5        50
 0927201         4       156        24      39.0        63
 0927202         4       145        28      36.3        44
 0927301         4       171        36      42.8        48
 0927302         4       172        37      43.0        51
 0927401         4       154        31      38.5        45
 0927402         4       156        31      39.0        48
 0927403         4       152        35      38.0        41
 0927501         4       168        32      42.0        56
 0927502         4       141        30      35.3        43
 0927503         4       123        24      30.8        37
 0927601         4       171        39      42.8        52
 0927602         4       183        40      45.8        49
 1010101         4       164        39      41.0        43
 1010102         4       178        31      44.5        53
 1010103         4       178        40      44.5        53
 1010201         4       161        37      40.3        48
 1010202         4       176        39      44.0        47
 1010203         4       176        40      44.0        47
 1010204         4       158        33      39.5        44
 1010301         4       162        38      40.5        45
 1010302         4       150        31      37.5        48
 1010401         4       164        30      41.0        48
 1010402         4       150        31      37.5        50
 1010403         4       156        37      39.0        43
 1010501         4       117        24      29.3        35
 1010502         4       155        37      38.8        41
 1010503         4       161        31      40.3        51
 1010504         4       154        30      38.5        46
 1010601         4       177        35      44.3        56
 1010602         4       172        38      43.0        50
 1010701         4       181        41      45.3        51
 1010702         4       178        39      44.5        54
 1010703         4       176        36      44.0        52
 1010801         4       153        33      38.3        45
 1010802         4       179        26      44.8        72
 1010901         3       117        33      39.0        43
 1010902         4       157        33      39.3        44
 1010903         4       163        35      40.8        44
 1011001         3       107        27      35.7        40
 1011002         4       173        32      43.3        50
 1011003         4       168        26      42.0        53
 1011101         4       156        34      39.0        45
 1011102         4       164        37      41.0        46
 1011201         4       141        28      35.3        41
 1011202         4       149        33      37.3        39
 1011301         4       157        31      39.3        44
 1011302         4       158        34      39.5        47
 1011303         4       145        32      36.3        40
 1011304         4       154        34      38.5        46
 1011401         4       149        27      37.3        51
 1011402         4       131        28      32.8        41
 1011403         4       187        36      46.8        57
 1011404         4       151        33      37.8        49
 1011501         4       174        36      43.5        51
 1011502         4       193        44      48.3        52
 1011503         4       150        29      37.5        44
 1011601         4       172        34      43.0        50
 1011602         4       154        29      38.5        44
 1011603         4       170        41      42.5        44
 1011701         4       185        31      46.3        56
 1011702         4       187        36      46.8        63
 1011703         4       211        39      52.8        72
 1011704         4       200        39      50.0        64
 1011801         4       161        28      40.3        50
 1011802         4       178        31      44.5        54
 1011803         4       159        30      39.8        44
 1011901         4       144        28      36.0        48
 1011902         4       151        32      37.8        42
 1011903         4       146        27      36.5        49
 1011904         4       135        24      33.8        41
 1012001         4       146        36      36.5        37
 1012002         4       148        33      37.0        42
 1012003         4       140        33      35.0        37
 1012101         4       143        32      35.8        40
 1012102         4       146        32      36.5        41
 1012201         4       182        36      45.5        59
 1012202         4       129        28      32.3        37
 1012203         4       147        32      36.8        46
 1012301         4       162        37      40.5        48
 1012302         4       154        31      38.5        52
 1012401         4       158        34      39.5        50
 1012402         4       191        42      47.8        54
 1012501         4       152        30      38.0        48
 1012502         4       176        38      44.0        54
 1012601         4       176        40      44.0        48
 1012602         4       193        31      48.3        63
 1012701         4       158        35      39.5        43
 1012702         4       152        27      38.0        46
 1012703         4       174        34      43.5        55
 1012801         4       177        30      44.3        68
 1012802         4       182        43      45.5        48
 1012803         4       164        32      41.0        47
 1012901         4       238        46      59.5        74
 1012902         4       195        33      48.8        66
 1012903         4       170        33      42.5        48
 1013001         4       164        35      41.0        45
 1013002         4       172        31      43.0        57
 1013101         4       188        39      47.0        54
 1013102         4       191        37      47.8        62
 1013201         4       185        36      46.3        58
 1013202         4       186        40      46.5        53
 1013203         4       169        35      42.3        47
 1013301         4       148        28      37.0        47
 1013302         4       168        40      42.0        43
 1013401         4       192        44      48.0        55
 1013402         4       194        43      48.5        59
 1013501         4       195        46      48.8        52
 1013502         4       179        34      44.8        52
 1013503         4       168        36      42.0        46
 1013504         4       198        40      49.5        56
 1013601         4       193        47      48.3        49
 1013602         4       217        48      54.3        66
 1013701         4       151        31      37.8        49
 1013702         4       191        36      47.8        60
 1013801         4       189        37      47.3        54
 1013802         4       199        39      49.8        59
 1020101         4       155        31      38.8        44
 1020201         4       128        24      32.0        43
 1020301         4       123        11      30.8        43
 1020401         4       155        31      38.8        50
 1020501         4       139        33      34.8        37
 1020601         4       157        32      39.3        48
 1020701         4       156        37      39.0        42
 1020801         4       157        35      39.3        42
 1020901         4       123        12      30.8        37
 1021001         4       158        32      39.5        52
 1021101         4       121        23      30.3        35
 1021201         4       150        32      37.5        49
 1021301         4       131        24      32.8        37
 1021401         4       151        35      37.8        41
 1021501         4       166        39      41.5        45
 1021601         4       157        33      39.3        51
 1021701         4       183        42      45.8        52
 1021801         4       148        30      37.0        42
 1021901         4       148        31      37.0        43
 1022001         4       152        30      38.0        45
 1022101         4       145        32      36.3        42
 1022201         4       165        36      41.3        46
 1022301         4       132        27      33.0        47
 1022401         4       142        27      35.5        41
 1022501         4       180        37      45.0        52
 1022601         4       133        27      33.3        39
 1022701         4       159        29      39.8        45
 1022801         4       179        31      44.8        59
 1022901         4       199        45      49.8        55
 1023001         4       171        36      42.8        50
 1023101         4       124        23      31.0        39
 1023201         3       120        31      40.0        46
 1023301         4       175        30      43.8        54
 1023401         4       146        31      36.5        41
 1023501         4       163        37      40.8        47
 1023601         4       179        31      44.8        67
 1023701         4       168        28      42.0        52
 1023901         4       173        38      43.3        54
 1023902         4       172        31      43.0        59
 1023903         4       162        27      40.5        46
 1110101         4       114        22      28.5        31
 1110102         4       110        25      27.5        32
 1110201         4       135        27      33.8        38
 1110202         4       147        25      36.8        44
 1110203         4       140        31      35.0        38
 1110204         4       119        27      29.8        34
 1110205         4       135        31      33.8        37
 1110301         4       152        26      38.0        47
 1110302         4       135        29      33.8        38
 1110303         4       131        24      32.8        41
 1110304         4       132        28      33.0        40
 1110305         4       133        24      33.3        38
 1110401        28       848        17      30.3        47
 1120101         4       124        25      31.0        37
 1120201         4        95        15      23.8        30
 1120301         4        93        17      23.3        26
 1120401         4       117        28      29.3        31
 1120402         4       107        22      26.8        29
 1210101         4       114        19      28.5        40
 1210201         4       105        13      26.3        35
 1210202         4       116        23      29.0        36
 1210203         4       138        28      34.5        38
 1210301         4       152        25      38.0        45
 1210302         4       166        38      41.5        45
 1210401         4       186        31      46.5        77
 1210402         4       142        26      35.5        45
 1210403         4       129        24      32.3        48
 1210501         4       158        24      39.5        59
 1210502         4       144        28      36.0        48
 1210601         4       174        32      43.5        57
 1210602         4       155        31      38.8        48
 1210701         4       173        39      43.3        45
 1210702         4       160        29      40.0        56
 1210703         4       158        30      39.5        53
 1210801         4       173        34      43.3        54
 1210802         4       125        25      31.3        35
 1210803         4       163        34      40.8        46
 1210901         4       174        38      43.5        49
 1211001         2        68        29      34.0        39
 1211101         4       124        19      31.0        40
 1211102         4       153        28      38.3        45
 1211103         4       144        31      36.0        42
 1211201         3       146        47      48.7        51
 1211202         4       165        26      41.3        50
 1211203         4       158        36      39.5        42
 1211301         4       147        26      36.8        41
 1211302         4       158        37      39.5        43
 1211303         4       220        38      55.0        76
 1211401         3        99        29      33.0        41
 1211501         4       145        29      36.3        46
 1211502         4       155        27      38.8        53
 1211601         4       136        23      34.0        49
 1211602         4       132        21      33.0        47
 1220101         4       107        21      26.8        32
 1220201         4       111        22      27.8        34
 1220301         4       172        40      43.0        45
 1220401         4       152        26      38.0        48
 1220402         4       114        19      28.5        36
 1220403         4       118        24      29.5        36
 1220404         4       145        23      36.3        43
 1220405         4       159        27      39.8        51
 1220501         4       108        24      27.0        30
 1220601         4       166        34      41.5        50
 1220701         4       116        20      29.0        36
 1220702         4       107        18      26.8        34
 1220801         4       131        27      32.8        36
 1220802         4       140        28      35.0        42
 1221101         4       133        26      33.3        41
 1221102         4       111        19      27.8        33
 1221201         4       115        21      28.8        39
 1221301         4       125        22      31.3        38
 1221601         4       115        25      28.8        34
 1310101         4       162        36      40.5        44
 1310102         4       168        38      42.0        44
 1310201         4       143        30      35.8        44
 1310202         4       146        31      36.5        47
 1310301         4       160        35      40.0        47
 1310302         8       322        37      40.3        48
 1310401         4       149        35      37.3        39
 1310402         4       167        35      41.8        50
 1310501         4       131        27      32.8        38
 1310601         4       160        35      40.0        45
 1310602         4       171        37      42.8        50
 1310701         4       151        31      37.8        43
 1310702         8       301        30      37.6        42
 1310801         4       163        36      40.8        48
 1310802         4       158        38      39.5        41
 1310901         4       147        32      36.8        41
 1311001         8       324        31      40.5        56
 1311101         4       150        31      37.5        43
 1320101         4       146        33      36.5        39
 1320201         4       149        33      37.3        40
 1320301         4       128        22      32.0        42
 1320401         4       132        24      33.0        38
 1320501         4       145        32      36.3        38
 1320601         4       153        31      38.3        44
 1320701         4       126        20      31.5        39
 1320801         4       160        36      40.0        44
 1320901         4       161        39      40.3        42
 1321001         4       150        32      37.5        44
 1321101         4       156        33      39.0        42
 1410101         4       154        34      38.5        43
 1410102         4       172        37      43.0        49
 1410103         4       160        34      40.0        45
 1410104         4       183        35      45.8        56
 1410201         4       190        41      47.5        53
 1410202         4       205        37      51.3        59
 1410203         4       213        45      53.3        59
 1410301         4       198        35      49.5        70
 1410302         4       156        35      39.0        43
 1410303         4       178        36      44.5        60
 1410304         4       155        33      38.8        47
 1410305         4       172        40      43.0        47
 1410306         4       189        38      47.3        54
 1410401        16       637        31      39.8        49
 1410501        24       954        31      39.8        53
 1410601         4       149        34      37.3        41
 1410602         4       176        36      44.0        52
 1410603         4       171        38      42.8        46
 1410604         4       140        32      35.0        39
 1410605         4       152        31      38.0        47
 1410701        32     1,140        24      35.6        48
 1410801        16       678        34      42.4        62
 1410901         4       155        30      38.8        47
 1410902         4       172        36      43.0        52
 1410903         4       191        43      47.8        52
 1420401         4       174        33      43.5        50
 1420402         4       142        33      35.5        39
 1420403         4       151        29      37.8        43
 1420404         4       177        36      44.3        54
 1420405         4       138        30      34.5        36
 1420501         4       149        35      37.3        41
 1420502         4       164        30      41.0        47
 1420503         4       155        33      38.8        50
 1420504         4       136        31      34.0        37
 1420505         4       170        37      42.5        49
 1420506         4       169        36      42.3        52
 1420507         4       187        43      46.8        51
 1420508         4       159        36      39.8        43
 1420509         4       175        38      43.8        50
 1420601         4       148        35      37.0        42
 1420602         4       136        31      34.0        37
 1420603         4       172        37      43.0        46
 1420604         4       170        36      42.5        47
 1420605         4       153        35      38.3        43
 1420606         4       134        31      33.5        37
 1420607         4       153        31      38.3        45
 1420608         4       154        26      38.5        48
 1420609         4       137        24      34.3        41
 1420610         4       120        23      30.0        37
 1420611         4       132        28      33.0        39
 1420612         4       146        33      36.5        39
 1420613         4       136        28      34.0        37
 1420614         4       151        29      37.8        48
 1420615         4       136        29      34.0        40
 1420616         4       140        28      35.0        42
 1420617         4       140        31      35.0        38
 1420618         4       132        31      33.0        37
 1420619         4       134        31      33.5        38
 1420620         4       132        27      33.0        38
 1420701         4       136        20      34.0        49
 1420702         4       139        29      34.8        42
 1420901         4       150        33      37.5        40
 1510101         4       139        26      34.8        40
 1510102         4       155        36      38.8        42
 1510201         4       129        28      32.3        36
 1510301         4       156        29      39.0        44
 1510302         4       164        32      41.0        48
 1510303         8       304        28      38.0        48
 1510401         4       147        26      36.8        47
 1510402         4       144        29      36.0        42
 1510403         4       172        40      43.0        49
 1510501         4       143        32      35.8        41
 1510601         4       104        24      26.0        27
 1510602         4       130        27      32.5        40
 1510603         4       128        21      32.0        38
 1510604         4       129        27      32.3        38
 1510701         4       143        30      35.8        44
 1510702         4       135        27      33.8        39
 1510703         4       130        28      32.5        38
 1510801         4       129        27      32.3        37
 1510802         4       143        25      35.8        43
 1520101         4       138        30      34.5        39
 1520201         4       161        34      40.3        46
 1520202         4       165        32      41.3        45
 1520301         4       147        33      36.8        40
 1520302         4       146        32      36.5        41
 1520303         4       151        35      37.8        42
 1520304         4       153        33      38.3        45
 1520305         4       133        29      33.3        38
 1520306         4       141        28      35.3        44
 1520307         4       165        36      41.3        46
 1520308         4       135        25      33.8        43
 1520309         4       137        32      34.3        37
 1520310         4       155        35      38.8        40
 1520311         4       154        26      38.5        50
 1520312         4       160        37      40.0        44
 1520313         4       145        28      36.3        43
 1520314         4       136        31      34.0        37
 1520315         4       163        38      40.8        44
 1520401         4       146        28      36.5        41
 1520402         4       162        38      40.5        43
 1520403         4       164        35      41.0        51
 1520501         4       153        29      38.3        44
 1520502         4       169        41      42.3        46
 1520601         4       131        26      32.8        37
 1520602         4       135        30      33.8        41
 1520603         4       146        33      36.5        41
 1520604         4       122        24      30.5        40
 1520801         4       165        31      41.3        51
 1610101        68     2,148        23      31.6        43
 1610201         4       126        22      31.5        39
 1610202         4       134        26      33.5        39
 1610203         4       115        23      28.8        37
 1610204         4       146        31      36.5        43
 1610205         4       121        27      30.3        34
 1610206         4       117        24      29.3        32
 1610207         4       118        23      29.5        34
 1610208         4       126        28      31.5        35
 1610209         4       119        26      29.8        35
 1610210         4       140        31      35.0        39
 1610211         4       124        27      31.0        37
 1610301         4       117        24      29.3        32
 1610302         4       129        26      32.3        41
 1610303         4       119        24      29.8        34
 1610304         4       114        22      28.5        33
 1610305         4       132        33      33.0        33
 1610401        32     1,132        28      35.4        44
 1620101         4       109        25      27.3        30
 1620102         4       113        21      28.3        38
 1620103         4       109        25      27.3        29
 1620104         4       121        25      30.3        37
 1620105         4       111        22      27.8        33
 1620106         4       130        25      32.5        36
 1620107         4        98        18      24.5        31
 1620108         4       104        23      26.0        28
 1620109         4       113        22      28.3        31
 1620110         4       105        19      26.3        30
 1620111         4       107        25      26.8        29
 1620201         4       116        25      29.0        35
 1620202         4       107        21      26.8        32
 1620301         4       110        26      27.5        31
 1620302         4       103        24      25.8        29
 1620401         4       136        22      34.0        42
 1620402         4       128        29      32.0        35
 1710101         4       141        32      35.3        43
 1710102         4       182        31      45.5        56
 1710103         4       177        39      44.3        49
 1710104         4       157        37      39.3        44
 1710105         4       142        32      35.5        39
 1710106         4       142        28      35.5        53
 1710201         4       150        33      37.5        48
 1710202         4       148        32      37.0        42
 1710203         4       158        32      39.5        47
 1710301         4       176        39      44.0        50
 1710302         4       140        32      35.0        38
 1710401         4       165        39      41.3        45
 1710402         4       179        39      44.8        55
 1710403         4       135        26      33.8        39
 1710404         4       167        28      41.8        51
 1710501         4       180        37      45.0        61
 1710502         4       150        29      37.5        50
 1710503         4       168        38      42.0        46
 1710601         4       161        30      40.3        49
 1710602         4       134        29      33.5        38
 1710603         4       179        42      44.8        49
 1710604         4       147        36      36.8        39
 1710605         4       181        43      45.3        49
 1710701         4       165        35      41.3        46
 1710702         4       154        30      38.5        48
 1710703         4       206        45      51.5        60
 1710704         3       122        37      40.7        43
 1720101         4       167        35      41.8        51
 1720102         4       132        18      33.0        54
 1720201         4       177        40      44.3        49
 1720301         4       145        30      36.3        45
 1720401         4       186        38      46.5        55
 1720501         4       153        26      38.3        49
 1720601         4       163        35      40.8        49
 1720602         4       147        30      36.8        44
 1720603         4       134        24      33.5        41
 1720604         4       153        36      38.3        40
 1720605         4       107        18      26.8        35
 1720606         4       137        30      34.3        39
 1720701         4       139        27      34.8        45
 1810101         4       142        31      35.5        47
 1810102         4       142        26      35.5        41
 1810103         4       147        31      36.8        43
 1810201         4       158        32      39.5        47
 1810202         4       141        29      35.3        41
 1810203         4       150        30      37.5        51
 1810204         4       175        33      43.8        54
 1810301         4       141        26      35.3        39
 1810302         4       175        35      43.8        51
 1810303         4       164        31      41.0        45
 1810401         4       124        23      31.0        34
 1810402         4       142        33      35.5        39
 1810501         4       152        35      38.0        41
 1810502         4       180        30      45.0        58
 1810503         4       181        40      45.3        50
 1810504         4       176        39      44.0        49
 1810505         4       145        32      36.3        40
 1810601         4       146        34      36.5        41
 1810602         4       149        32      37.3        40
 1810603         4       157        33      39.3        49
 1810604         4       171        36      42.8        52
 1810701         4       158        34      39.5        49
 1810702         4       149        24      37.3        43
 1810801         3       100        32      33.3        35
 1810802         4       157        34      39.3        43
 1810803         4       172        32      43.0        47
 1810901         4       168        28      42.0        54
 1810902         4       168        37      42.0        48
 1810903         4       179        37      44.8        49
 1811001         4       163        38      40.8        44
 1811002         4       176        36      44.0        55
 1811003         4       126        29      31.5        35
 1811004         4       167        35      41.8        49
 1811005         4       185        28      46.3        63
 1811101         4       161        37      40.3        46
 1811102         4       153        34      38.3        44
 1811103         3       133        40      44.3        47
 1811104         4       160        32      40.0        44
 1811105         4       154        34      38.5        47
 1811201         4       157        35      39.3        45
 1811202         4       145        29      36.3        42
 1811203         4       150        33      37.5        44
 1811301         4       150        33      37.5        41
 1811302         4       150        33      37.5        44
 1811401         4       136        31      34.0        37
 1811402         4       165        32      41.3        63
 1811403         4       142        33      35.5        39
 1811501         4       114        19      28.5        40
 1811502         4       173        37      43.3        50
 1811503         4       152        32      38.0        41
 1811601         4       121        24      30.3        34
 1811602         4       154        33      38.5        49
 1811603         4       138        29      34.5        37
 1811701         4       157        32      39.3        59
 1811702         4       144        27      36.0        49
 1811703         4       154        35      38.5        41
 1811801         4       138        31      34.5        37
 1811802         4       158        37      39.5        43
 1811803         4       157        33      39.3        47
 1811901         4       140        32      35.0        37
 1811902         4       155        37      38.8        41
 1811903         4       135        31      33.8        40
 1812001         4       139        33      34.8        37
 1812002         4       145        26      36.3        44
 1812101         4       142        34      35.5        38
 1812102         4       151        25      37.8        44
 1812103         4       172        40      43.0        45
 1812104         4       119        28      29.8        33
 1812201         4       151        33      37.8        43
 1812202         4       164        33      41.0        47
 1812203         4       139        33      34.8        36
 1812301         4       144        30      36.0        43
 1812302         4       171        37      42.8        49
 1812401         4       155        36      38.8        41
 1812402         4       169        35      42.3        54
 1812501         4       144        30      36.0        43
 1812502         4       147        32      36.8        43
 1812601         4       140        32      35.0        38
 1812602         4       139        27      34.8        42
 1812701         4       162        35      40.5        46
 1812702         4       150        34      37.5        40
 1812703         4       140        28      35.0        44
 1820101         4       137        20      34.3        46
 1820201         4       141        31      35.3        43
 1820301         4       109        19      27.3        33
 1820401         4       136        29      34.0        38
 1820501         4       139        30      34.8        41
 1820601         4       126        26      31.5        37
 1820701         4       126        28      31.5        40
 1820801         4       140        32      35.0        41
 1820901         4       144        25      36.0        48
 1821001         4       112         8      28.0        38
 1821101         4       126        28      31.5        38
 1821201         4       132        21      33.0        39
 1821301         4       140        30      35.0        42
 1821401         4       133        29      33.3        41
 1821501         4       113        23      28.3        31
 1821601         4       121        24      30.3        34
 1821701         4       110        21      27.5        36
 1821801         4        97        14      24.3        30
 1821901         4       164        39      41.0        43
 1822001         4       121        26      30.3        36
 1822101         4       140        32      35.0        41
 1822201         4       147        28      36.8        41
 1822301         4       142        30      35.5        43
 1822401         4       119        16      29.8        35
 1822601         4       116        25      29.0        33
 1822701         4       117        24      29.3        33
 1910101         4       135        30      33.8        37
 1910102         4       137        26      34.3        46
 1910201         4       140        29      35.0        44
 1910202         4       132        30      33.0        41
 1910203         4       137        29      34.3        39
 1910204         4       129        26      32.3        42
 1910205         4       149        28      37.3        47
 1910206         4       134        29      33.5        39
 1910301         4       131        29      32.8        38
 1910302         4       143        32      35.8        40
 1910303         4       134        26      33.5        38
 1910304         4       122        26      30.5        36
 1910401         4       154        34      38.5        48
 1910402         4       147        35      36.8        38
 1910403         4       153        33      38.3        45
 1910404         4       169        35      42.3        52
 1910501         4       137        32      34.3        37
 1910502         4       112        25      28.0        35
 1910503         4       134        30      33.5        40
 1910601         4       143        29      35.8        41
 1910602         4       131        29      32.8        41
 1910603         4       145        35      36.3        39
 1910604         4       144        31      36.0        42
 1910605         4       142        30      35.5        47
 1910606         3       136        39      45.3        52
 1910701         3        95        27      31.7        38
 1910702         4       153        30      38.3        50
 1910703         4       134        29      33.5        38
 1910704         4       154        25      38.5        53
 1910705         4       157        29      39.3        51
 1910706         4       139        29      34.8        45
 1910707         4       129        27      32.3        40
 1910708         4       130        30      32.5        36
 1910709         4       174        37      43.5        54
 1910801         4       138        24      34.5        42
 1910802         4       135        29      33.8        40
 1910803         4       126        29      31.5        36
 1910804         4       141        33      35.3        39
 1910805         4       148        28      37.0        46
 1910901         4       153        34      38.3        48
 1910902         4       117        21      29.3        35
 1910903         4       119        20      29.8        34
 1910904         4       147        28      36.8        49
 1910905         4       139        25      34.8        39
 1910906         4       169        25      42.3        51
 1910907         4       137        29      34.3        39
 1910908         4       119        28      29.8        31
 1910909         4       132        25      33.0        43
 1911001         4       126        30      31.5        34
 1911002         4       135        31      33.8        35
 1911003         4       128        26      32.0        42
 1911004         4       109        21      27.3        37
 1911005         4       125        22      31.3        40
 1911006         4       134        30      33.5        37
 1911007         4       124        29      31.0        33
 1911101         4       126        29      31.5        34
 1911102         4       159        35      39.8        45
 1911103         4       130        31      32.5        34
 1911104         4       134        30      33.5        41
 1911105         4       119        27      29.8        38
 1911106         4       125        28      31.3        36
 1911107         4       130        27      32.5        40
 1911108         4       140        31      35.0        40
 1911201         4       139        32      34.8        39
 1911202         4       136        32      34.0        38
 1911203         4       108        21      27.0        34
 1911204         4       131        28      32.8        38
 1911205         4       122        19      30.5        38
 1911206         4       146        30      36.5        43
 1911207         4       142        33      35.5        38
 1911301         4        95        15      23.8        33
 1911302         4       160        35      40.0        48
 1911303         4       133        26      33.3        40
 1911304         4       113        22      28.3        39
 1911305         4       129        27      32.3        35
 1911306         4       115        20      28.8        36
 1911401         4       138        27      34.5        43
 1911402         4       128        27      32.0        39
 1911403         4       141        21      35.3        54
 1911404         4       126        23      31.5        39
 1911405         4       118        22      29.5        47
 1911501         4       153        35      38.3        44
 1911502         4       131        27      32.8        38
 1911503         4       140        27      35.0        46
 1911504         4       134        31      33.5        37
 1911505         4       132        27      33.0        38
 1911506         4       163        30      40.8        59
 1911507         4       124        28      31.0        33
 1911508         4       154        36      38.5        46
 1911509         4       130        27      32.5        36
 1911601         4       125        27      31.3        35
 1911602         4       134        29      33.5        36
 1911603         4       136        31      34.0        39
 1911604         4       125        25      31.3        41
 1911801         4       140        27      35.0        45
 1911802         4       150        30      37.5        46
 1911803         4       139        30      34.8        39
 1911804         4       151        29      37.8        47
 1911805         4       150        28      37.5        47
 1911806         4       166        34      41.5        56
 1911807         4       126        29      31.5        34
 1911808         4       153        33      38.3        43
 1911809         4       131        29      32.8        43
 1911810         4       135        31      33.8        35
 1911901         4       135        30      33.8        36
 1911902         4       135        27      33.8        42
 1911903         4       140        32      35.0        38
 1911904         4       162        37      40.5        46
 1911905         4       121        24      30.3        34
 1911906         4       136        27      34.0        44
 1911907         4       134        30      33.5        39
 1911908         4       164        39      41.0        45
 1920101         4        97         8      24.3        34
 1920102         4       125        24      31.3        42
 1920103         4       123        24      30.8        39
 1920201         4       126        27      31.5        35
 1920202         4       126        28      31.5        39
 1920301         4       116        24      29.0        41
 1920302         4       107        22      26.8        29
 1920401         4       117        24      29.3        33
 1920402         4       144        24      36.0        48
 1920501         4       102        21      25.5        28
 1920502         4       129        25      32.3        38
 1920601         4       136        31      34.0        40
 1920602         4       147        32      36.8        42
 1920701         4       135        27      33.8        41
 1920702         4       151        33      37.8        43
 1920703         4       106        18      26.5        32
 1920801         4       134        32      33.5        35
 1920802         4       117        20      29.3        40
 1920901         4       137        30      34.3        37
 1920902         4       139        33      34.8        36
 1920903         4       127        25      31.8        37
 1920904         4       136        30      34.0        41
 1920905         4       106        17      26.5        39
 1920906         4       163        32      40.8        49
 1920907         4       148        25      37.0        48
 1920908         4       129        24      32.3        36
 1921001         4       114        25      28.5        32
 1921002         4       133        27      33.3        42
 1921003         4        99        21      24.8        28
 1921004         4       112        27      28.0        29
 1921101         4       117        23      29.3        36
 1921102         4       124        30      31.0        34
 1921103         4       115        25      28.8        32
 1921104         4       116        19      29.0        39
 1921105         4       121        27      30.3        36
 1921106         4       100        21      25.0        28
 1921107         4       116        19      29.0        35
 1921108         4       121        26      30.3        36
 1921109         4       110        23      27.5        31
 1921110         4       104        24      26.0        28
 1921111         4       122        28      30.5        36
 1921112         4       111        21      27.8        37
 1921113         4       126        26      31.5        41
 1921114         4       100        16      25.0        39
 1921115         4       108        22      27.0        36
 1921201         4       136        30      34.0        38
 1921202         4       128        25      32.0        43
 1921203         4       106        19      26.5        33
 1921204         4       108        27      27.0        27
 1921205         4       128        28      32.0        37
 1921206         4       137        31      34.3        39
 1921301         4        99        11      24.8        32
 1921302         4       115        25      28.8        32
 1921401         4       113        21      28.3        35
 1921402         4       112        20      28.0        39
 1921501         4       123        25      30.8        36
 1921502         4       124        22      31.0        40
 1921601         4       118        23      29.5        34
 1921602         4       136        29      34.0        38
 1921603         4       116        23      29.0        36
 1921604         4       116        19      29.0        37
 1921801         4       128        25      32.0        41
 1921802         4       117        26      29.3        32
 1921803         4       126        26      31.5        37
 1921804         4       113        23      28.3        32
 1921901         4       115        26      28.8        32
 1921902         4       103        17      25.8        37
 1922001         4       126        25      31.5        40
 1922002         4       121        23      30.3        35
 1922003         4       142        26      35.5        49
 1922004         4       101        18      25.3        29
 1922101         4        94        16      23.5        36
 1922102         4       118        26      29.5        32
 1922103         4        78         9      19.5        25
 1922104         4       115        18      28.8        34
 1922105         4       105         8      26.3        38
 1922106         4       114        22      28.5        36
 1922107         4       150        25      37.5        45
 1922108         4       136        23      34.0        45
 1922109         4        86        10      21.5        29
 1922110         4        79        15      19.8        22
 1922111         4       106        21      26.5        37
 1922112         4       106        19      26.5        31
 1922113         4       107        20      26.8        32
 1922114         4       110        22      27.5        33
 1922115         4       150        32      37.5        43
 2010101         4       176        37      44.0        52
 2010102         4       139        26      34.8        48
 2010103         4       175        39      43.8        54
 2010201         4       150        32      37.5        42
 2010202         4       178        35      44.5        51
 2010203         4       151        30      37.8        49
 2010301         4       159        34      39.8        45
 2010302         4       169        38      42.3        51
 2010401         4       177        40      44.3        52
 2010402         4       172        34      43.0        57
 2010403         4       199        47      49.8        53
 2010501         4       182        41      45.5        53
 2010502         4       174        35      43.5        54
 2010601         4       168        29      42.0        56
 2010602         4       178        33      44.5        54
 2010603         4       168        31      42.0        53
 2010701         4       178        37      44.5        58
 2010702         4       170        31      42.5        59
 2010703         4       172        37      43.0        48
 2010801         4       165        30      41.3        52
 2010802         4       152        28      38.0        48
 2010803         4       142        23      35.5        44
 2010901         4       140        26      35.0        44
 2010902         4       121        21      30.3        41
 2011001         4       161        30      40.3        55
 2011002         4       133        29      33.3        36
 2011101         4       162        33      40.5        56
 2011102         4       143        28      35.8        42
 2011103         4       127        29      31.8        36
 2011201         4       168        36      42.0        49
 2011202         4       159        24      39.8        52
 2011203         4       156        33      39.0        49
 2011301         4       150        32      37.5        41
 2011302         4       163        35      40.8        52
 2011303         4       171        36      42.8        46
 2011401         4       168        33      42.0        48
 2011402         4       144        25      36.0        48
 2011403         4       158        34      39.5        45
 2011501         4       174        35      43.5        51
 2011502         4       163        33      40.8        51
 2011601         4       156        30      39.0        49
 2011602         4       182        34      45.5        73
 2011701         4       157        37      39.3        44
 2011702         4       125        25      31.3        39
 2011703         4       123        25      30.8        37
 2011801         4       150        30      37.5        44
 2011802         4       151        30      37.8        48
 2011901         4       173        37      43.3        50
 2011902         4       147        26      36.8        43
 2012001         4       141        20      35.3        42
 2012002         4       163        31      40.8        58
 2012101         4       150        28      37.5        46
 2012102         4       146        29      36.5        47
 2012201         4       146        30      36.5        40
 2012202         4       117        28      29.3        31
 2020101         4       139        30      34.8        44
 2020201         4       133        22      33.3        38
 2020301         4       139        15      34.8        45
 2020401         4       130        28      32.5        41
 2020402         4       115        22      28.8        33
 2020501         4       155        29      38.8        48
 2020601         4       134        11      33.5        44
 2020701         4       101        16      25.3        35
 2020801         4       160        36      40.0        44
 2020901         4       129        26      32.3        39
 2021001         4       157        33      39.3        46
 2021101         4       141        27      35.3        43
 2021201         4       152        32      38.0        43
 2021202         4       153        33      38.3        44
 2021203         4       164        37      41.0        45
 2021301         4       158        33      39.5        49
 2021302         4       171        40      42.8        48
 2021303         3       109        29      36.3        44
 2021401         4       150        25      37.5        52
 2021402         4       124        28      31.0        35
 2021403         4       164        33      41.0        51
 2021501         4       127        26      31.8        38
 2021601         4       139        25      34.8        41
 2021701         4       133        30      33.3        35
 2021801         4       138        33      34.5        36
 2021802         4       161        25      40.3        67
 2021803         4       138        26      34.5        44
 2021901         4       119        26      29.8        33
 2022001         4       118         8      29.5        49
 2022101         4       128        20      32.0        43
 2022201         4       131        24      32.8        42
 2110101         4       141        28      35.3        40
 2110102         4       141        27      35.3        42
 2110103         4       152        31      38.0        47
 2110104         4       164        32      41.0        51
 2110201         4       120        27      30.0        33
 2110202         4       132        32      33.0        35
 2110301         4       134        31      33.5        37
 2110302         4       127        27      31.8        34
 2110401         4       130        22      32.5        39
 2110402         4       139        31      34.8        42
 2110501         4       128        31      32.0        34
 2110502         4       144        34      36.0        40
 2110503         4       159        31      39.8        46
 2110504         4       119        21      29.8        38
 2110601         4       138        27      34.5        40
 2110602         4       155        33      38.8        44
 2110603         4       140        27      35.0        43
 2110604         4       154        28      38.5        50
 2110701         4       144        30      36.0        41
 2110702         4       145        25      36.3        47
 2110703         4       127        26      31.8        40
 2110704         4       162        32      40.5        50
 2110801         4       134        32      33.5        36
 2110802         4       156        32      39.0        44
 2110803         4       131        26      32.8        37
 2110804         4       162        37      40.5        50
 2110901         4       182        41      45.5        52
 2110902         4       179        39      44.8        50
 2110903         4       171        32      42.8        58
 2110904         4       133        31      33.3        36
 2111001         4       148        31      37.0        43
 2111002         4       129        23      32.3        37
 2111003         4       129        29      32.3        35
 2111004         4       121        27      30.3        34
 2111101         4       122        23      30.5        36
 2111102         4       137        30      34.3        40
 2111103         4       188        40      47.0        64
 2111201         4       139        29      34.8        39
 2111202         4       149        29      37.3        47
 2111203         4       148        32      37.0        44
 2111204         4       149        33      37.3        42
 2111301         4       168        38      42.0        50
 2111302         4       163        38      40.8        43
 2111303         4       167        33      41.8        47
 2111304         4       142        32      35.5        40
 2111401         4       160        33      40.0        55
 2111402         4       155        33      38.8        50
 2111403         4       142        30      35.5        38
 2111501         4       148        29      37.0        41
 2111502         4       140        26      35.0        40
 2111503         4       135        23      33.8        47
 2111601         4       138        27      34.5        38
 2111602         4       134        28      33.5        40
 2111603         4       136        28      34.0        38
 2111701         4       161        35      40.3        43
 2111702         4       167        38      41.8        48
 2111703         4       150        36      37.5        41
 2111801         4       168        36      42.0        47
 2111802         4       142        30      35.5        44
 2111803         4       153        35      38.3        42
 2111804         4       144        30      36.0        40
 2111901         4       135        30      33.8        38
 2111902         4       139        30      34.8        41
 2111903         4       157        34      39.3        46
 2111904         4       142        22      35.5        56
 2111905         4       153        32      38.3        49
 2112001         4       154        33      38.5        44
 2112002         4       126        29      31.5        36
 2112101         4       132        27      33.0        46
 2112102         4       121        20      30.3        36
 2112201         4       138        29      34.5        45
 2112202         4       126        29      31.5        35
 2112301         4       132        29      33.0        36
 2112302         4       126        28      31.5        35
 2112401         4       126        25      31.5        40
 2112402         4       135        27      33.8        39
 2112403         4       137        29      34.3        39
 2112501         4       130        23      32.5        47
 2112502         4       124        23      31.0        40
 2112601         4       123        26      30.8        33
 2112602         4       121        24      30.3        41
 2112603         4       127        30      31.8        35
 2112604         4       135        28      33.8        37
 2112701         4       108        22      27.0        32
 2112702         4       112        21      28.0        34
 2112801         4       132        32      33.0        34
 2112802         4       120        28      30.0        34
 2112803         4       142        27      35.5        42
 2112901         4       105        20      26.3        32
 2112902         4        95        18      23.8        27
 2112903         4       123        25      30.8        36
 2113001         4       101        23      25.3        28
 2113002         4       139        29      34.8        38
 2120101         4       143        33      35.8        39
 2120201         4       112        20      28.0        33
 2120301         4       143        29      35.8        39
 2120401         4       126        24      31.5        38
 2120501         4       115        26      28.8        32
 2120502         4       127        25      31.8        39
 2120601         4       102        17      25.5        33
 2120701         4       118        28      29.5        31
 2120801         4       114        16      28.5        37
 2120901         4       161        34      40.3        53
 2121001         4       127        28      31.8        39
 2121101         4        94         8      23.5        36
 2121201         4       131        30      32.8        38
 2121202         4        84        16      21.0        27
 2121301         4       152        28      38.0        47
 2121401         4       136        22      34.0        46
 2121501         4       112        21      28.0        32
 2121601         4       140        32      35.0        38
 2121701         4       122        20      30.5        45
 2121702         4       126        25      31.5        40
 2121801         4       153        32      38.3        46
 2121901         4       129        28      32.3        39
 2122001         4       133        25      33.3        41
 2122101         4       111        24      27.8        32
 2122201         4       133        29      33.3        38
 2122301         4       125        22      31.3        39
 2122401         4       115        21      28.8        36
 2122501         4       112        21      28.0        34
 2122601         4       151        35      37.8        42
 2122701         4       133        24      33.3        39
 2122801         4       129        23      32.3        40
 2122901         4        92         8      23.0        31
 2123001         4       117        25      29.3        32
 2210101         4       166        36      41.5        48
 2210201         4       137        29      34.3        37
 2210202         4       185        31      46.3        57
 2210203         4       144        27      36.0        54
 2210204         4       146        28      36.5        42
 2210205         4       165        32      41.3        51
 2210301         4       179        43      44.8        46
 2210302         4       139        30      34.8        38
 2210401         4       167        36      41.8        51
 2210402         4       140        33      35.0        38
 2210403         3       122        35      40.7        48
 2210501         4       170        35      42.5        56
 2210502         4       139        30      34.8        41
 2210601         4       132        27      33.0        40
 2210602         4       155        27      38.8        57
 2210603         4       148        27      37.0        42
 2210701         4       145        28      36.3        40
 2210702         4       148        31      37.0        45
 2210703         3       107        32      35.7        41
 2210704         4       134        28      33.5        36
 2210801         4       174        37      43.5        53
 2210802         4       212        38      53.0        85
 2210901         4       170        38      42.5        46
 2210902         4       199        34      49.8        67
 2210903         4       149        26      37.3        47
 2211001         4       167        35      41.8        56
 2211002         4       156        35      39.0        44
 2211003         4       173        26      43.3        56
 2211004         4       147        30      36.8        51
 2211005         4       183        32      45.8        69
 2211101         4       145        31      36.3        42
 2211102         4       146        33      36.5        41
 2211103         4       149        28      37.3        44
 2211104         4       132        28      33.0        39
 2211105         4       143        29      35.8        41
 2211201         4       161        36      40.3        43
 2211202         4       152        35      38.0        43
 2211301         4       163        35      40.8        47
 2211302         3       151        39      50.3        56
 2211401         4       162        30      40.5        54
 2211402         4       146        29      36.5        44
 2211501         4       158        28      39.5        45
 2211502         4       128        27      32.0        37
 2211503         4       193        38      48.3        62
 2211601         4       126        26      31.5        39
 2211701         2        70        32      35.0        38
 2211801         1*       14        14      14.0        14
 2220101         4       142        24      35.5        43
 2220201         4       168        24      42.0        58
 2220301         4       134        15      33.5        42
 2220401         4       140        31      35.0        43
 2220501         4       121        26      30.3        41
 2220601         4       120        26      30.0        34
 2220701         4       145        31      36.3        45
 2220702         4       117        19      29.3        37
 2220801         4       126        28      31.5        34
 2220901         4       139        32      34.8        39
 2221001         4       128        26      32.0        36
 2221002         4       124        22      31.0        36
 2221003         4       148        27      37.0        49
 2221101         4       140        26      35.0        42
 2221102         4       139        24      34.8        41
 2221103         4       121        24      30.3        34
 2221201         4       125        23      31.3        35
 2221301         4       159        33      39.8        52
 2221401         4        92        20      23.0        25
 2221501         4       129        29      32.3        39
 2221601         4       109        19      27.3        37
 2221701         4       152        30      38.0        49
 2221801         4       120        18      30.0        37
 2310101         4       159        35      39.8        44
 2310201         4       161        35      40.3        49
 2310202         4       172        26      43.0        51
 2310301         4       171        36      42.8        47
 2310302         4       183        36      45.8        61
 2310401         4       188        38      47.0        57
 2310501         4       122        23      30.5        35
 2310601         4       167        37      41.8        44
 2310602         4       145        33      36.3        41
 2310701         4       163        32      40.8        51
 2310801         4       132        27      33.0        40
 2310802         4       146        28      36.5        45
 2310901         4       162        37      40.5        44
 2310902         4       161        26      40.3        52
 2311001         4       148        30      37.0        43
 2311101         4       144        27      36.0        57
 2311102         4       145        32      36.3        39
 2311103         4       131        28      32.8        37
 2311201         4       163        29      40.8        59
 2311202         4       124        30      31.0        32
 2311301         4       160        37      40.0        43
 2311302         4       143        33      35.8        39
 2311303         4       149        30      37.3        48
 2311401         4       135        31      33.8        36
 2311402         4       142        32      35.5        42
 2311403         4       138        27      34.5        43
 2311501         4       134        32      33.5        36
 2311601         4       122        27      30.5        35
 2311701         4       134        30      33.5        38
 2311702         4       129        23      32.3        38
 2311801         4       129        26      32.3        38
 2311901         4       136        24      34.0        43
 2311902         3       120        39      40.0        41
 2312001         4       162        37      40.5        45
 2312002         4       145        31      36.3        45
 2312101         4       152        26      38.0        54
 2312102         4       186        36      46.5        55
 2312201         4       145        32      36.3        41
 2312202         4       176        35      44.0        51
 2312301         4       141        31      35.3        39
 2312302         4       171        38      42.8        49
 2312401         4       156        32      39.0        44
 2312501         4       183        33      45.8        61
 2312502         4       175        36      43.8        51
 2312503         4       151        25      37.8        48
 2312601         4       161        29      40.3        50
 2312701         4       170        36      42.5        53
 2312702         4       173        37      43.3        59
 2312801         4       197        42      49.3        53
 2312802         4       176        39      44.0        48
 2312901         3       116        31      38.7        48
 2312902         4       143        26      35.8        48
 2313001         4       146        32      36.5        46
 2313002         4       137        30      34.3        41
 2313101         4       154        33      38.5        47
 2313102         4       138        25      34.5        41
 2313201         4       163        34      40.8        56
 2313301         4       158        23      39.5        58
 2313302         4       157        24      39.3        46
 2313401         4       144        29      36.0        49
 2313402         4       145        32      36.3        41
 2313501         4       175        39      43.8        52
 2313502         4       167        40      41.8        45
 2313601         4       161        29      40.3        55
 2313701         4       170        34      42.5        59
 2313801         4       117        26      29.3        31
 2313802         4       137        30      34.3        40
 2313901         4       142        30      35.5        38
 2313902         4       126        27      31.5        35
 2314001         4       133        26      33.3        37
 2314002         4       137        27      34.3        42
 2314101         4       136        29      34.0        40
 2314201         4       120        27      30.0        35
 2314202         4       124        18      31.0        42
 2314301         4       154        32      38.5        53
 2314302         4       165        33      41.3        54
 2314303         4       147        32      36.8        43
 2314401         4       151        31      37.8        44
 2314402         4       139        28      34.8        40
 2314501         4       157        30      39.3        47
 2314502         4       142        33      35.5        38
 2314601         4       164        33      41.0        46
 2314701         4       128        28      32.0        35
 2314801         4       153        28      38.3        47
 2314901         4       175        36      43.8        57
 2315001         4       153        34      38.3        44
 2320101         4       143        30      35.8        42
 2320201         4       177        33      44.3        50
 2320301         4       170        34      42.5        49
 2320401         4       130        23      32.5        39
 2320402         4       139        28      34.8        47
 2320501         4       161        29      40.3        53
 2320601         4       155        31      38.8        46
 2320701         4       172        38      43.0        55
 2320801         4       140        26      35.0        41
 2320901         4       124        24      31.0        37
 2321001         4       142        25      35.5        48
 2321101         4       159        38      39.8        41
 2321102         4       152        32      38.0        43
 2321201         4       151        27      37.8        47
 2321301         4       131        26      32.8        38
 2321302         4       152        25      38.0        49
 2321401         4       143        22      35.8        43
 2321501         4       168        38      42.0        50
 2321601         4       141        30      35.3        41
 2321701         4       157        30      39.3        45
 2321801         4       131        24      32.8        38
 2321901         4       150        27      37.5        44
 2322001         4       144        30      36.0        39
 2322101         4       141        32      35.3        40
 2322102         4       138        31      34.5        38
 2322201         4       165        34      41.3        53
 2322301         4       147        29      36.8        54
 2322401         4       103        20      25.8        32
 2322501         4       128        28      32.0        40
 2322601         4       140        31      35.0        42
 2322701         4       149        32      37.3        43
 2322801         4       150        27      37.5        46
 2322901         4       146        30      36.5        48
 2323001         4       144        27      36.0        46
 2323101         4       150        32      37.5        43
 2323201         4       130        27      32.5        37
 2323301         4       146        34      36.5        41
 2323401         4       130        27      32.5        40
 2323501         4       138        28      34.5        49
 2323601         4       153        31      38.3        43
 2323701         4       147        29      36.8        48
 2323801         4       139        30      34.8        38
 2323901         4       128        27      32.0        37
 2323902         4       143        29      35.8        43
 2324001         4       135        28      33.8        37
 2324101         4       139        30      34.8        42
 2324201         4       122        27      30.5        34
 2324301         4       111        22      27.8        31
 2324302         4       174        26      43.5        68
 2324401         4       142        24      35.5        48
 2324501         4       154        36      38.5        43
 2324601         4       162        33      40.5        46
 2324701         4       126        28      31.5        39
 2324801         4       164        34      41.0        48
 2324901         4       136        21      34.0        42
 2325001         4       140        29      35.0        40
 2325101         4       128        25      32.0        36
 2325102         4       159        31      39.8        54
 2325103         4       128        26      32.0        38
 2325201         4       124        25      31.0        35
 2325202         4       152        32      38.0        44
 2325203         4       134        29      33.5        40
 2410101         4       154        31      38.5        44
 2410102         4       141        31      35.3        41
 2410201         4       180        36      45.0        58
 2410202         4       183        40      45.8        52
 2410203         4       150        31      37.5        43
 2410301         4       165        34      41.3        46
 2410302         4       169        36      42.3        51
 2410401         4       148        31      37.0        42
 2410402         4       149        28      37.3        46
 2410501         4       130        23      32.5        39
 2410502         4       150        30      37.5        46
 2410503         4       137        21      34.3        40
 2410601         4       152        32      38.0        43
 2410602         4       141        29      35.3        43
 2410701         4       185        41      46.3        55
 2410702         4       152        33      38.0        45
 2410801         4       174        33      43.5        50
 2410802         4       167        37      41.8        47
 2410901         3       113        34      37.7        42
 2410902         4       139        28      34.8        41
 2411001         4       158        33      39.5        44
 2411002         4       139        32      34.8        39
 2411101         4       159        37      39.8        44
 2411201         4       180        32      45.0        67
 2411202         4       151        33      37.8        44
 2411203         4       169        34      42.3        54
 2411301         4       158        27      39.5        47
 2411302         4       167        36      41.8        50
 2411401         4       156        29      39.0        44
 2411402         4       165        33      41.3        46
 2411501         4       142        29      35.5        46
 2411502         4       156        34      39.0        43
 2411601         4       190        41      47.5        62
 2411602         4       141        21      35.3        46
 2411701         4       188        33      47.0        61
 2411702         4       163        30      40.8        48
 2411703         4       170        38      42.5        48
 2411801         4       186        35      46.5        55
 2411802         4       196        41      49.0        53
 2411901         4       191        43      47.8        57
 2411902         4       157        34      39.3        43
 2411903         4       172        33      43.0        51
 2412001         4       163        30      40.8        47
 2412002         4       148        31      37.0        40
 2412101         4       148        34      37.0        39
 2412102         4       161        37      40.3        44
 2412201         4       153        21      38.3        51
 2412202         4       150        33      37.5        42
 2412203         3       120        35      40.0        46
 2412301         4       149        31      37.3        46
 2412401         4       129        23      32.3        36
 2412402         4       149        24      37.3        48
 2412501         4       126        27      31.5        34
 2412502         4       169        33      42.3        67
 2420101         4       156        33      39.0        46
 2420201         4       157        31      39.3        49
 2420301         4       127        31      31.8        33
 2420401         4       131        30      32.8        38
 2420501         4       129        29      32.3        37
 2420601         4       151        34      37.8        45
 2420701         4       143        28      35.8        48
 2420702         4       136        31      34.0        37
 2420703         4       128        24      32.0        36
 2420801         4       170        33      42.5        54
 2420901         4       132        30      33.0        39
 2420902         4       138        32      34.5        37
 2420903         4       169        32      42.3        52
 2420904         4       118        21      29.5        39
 2420905         4       133        29      33.3        37
 2421001         4       120        22      30.0        41
 2421002         4       132        28      33.0        35
 2421101         4       133        24      33.3        40
 2421201         4       128        26      32.0        38
 2421202         4       140        30      35.0        38
 2421301         4       145        25      36.3        44
 2421401         4       131        19      32.8        48
 2421402         4       146        32      36.5        41
 2421403         4       147        32      36.8        47
 2421501         4       100        19      25.0        29
 2421502         4       128        26      32.0        37
 2421601         4       136        28      34.0        43
 2421701         4       120        25      30.0        34
 2421801         4       138        12      34.5        48
 2421901         4       141        30      35.3        44
 2422001         4       108        23      27.0        37
 2422101         4       124        24      31.0        39
 2422201         4       126        26      31.5        38
 2422401         4       141        26      35.3        43
 2422501         4       100        11      25.0        32
 2422601         4       140        31      35.0        43
 2422602         4       112        16      28.0        33
 2422603         4       128        30      32.0        35
 2422604         4       121        26      30.3        36
 2422605         4       159        37      39.8        44
 2422606         4       139        27      34.8        54
 2422607         4       151        30      37.8        45
 2422608         4       171        31      42.8        63
 2422701         4       147        32      36.8        43
 2422702         4       127        27      31.8        36
 2422703         4       128        28      32.0        36
 2422704         3       111        29      37.0        49
 2422801         4       123        25      30.8        36
 2422802         4       122        24      30.5        36
 2422803         4       150        32      37.5        41
 2422804         4       131        17      32.8        47
 2422805         4       107        22      26.8        33
 2422806         4       101        15      25.3        37
 2422807         4       142        28      35.5        45
 2519901         8       258        19      32.3        43
 2529901         4       127        25      31.8        41
 2529902         4       190        34      47.5        65
 2610101         4       163        34      40.8        43
 2610102         4       143        26      35.8        54
 2610103         4       164        37      41.0        46
 2620101         4       126        27      31.5        36
 2620102         4       124        24      31.0        36
 2620103         4       131        22      32.8        40
 2710101         4       152        33      38.0        44
 2710102         4       151        35      37.8        42
 2710103         4       167        32      41.8        48
 2710201         4       155        24      38.8        46
 2710202         4       151        29      37.8        43
 2710203         4       167        37      41.8        45
 2710301         4       152        31      38.0        44
 2710302         4       121        25      30.3        33
 2710303         4       170        40      42.5        45
 2710304         4       134        25      33.5        37
 2710305         4       147        35      36.8        41
 2710306         4       150        28      37.5        48
 2710401         4       134        32      33.5        36
 2710402         4       141        29      35.3        40
 2710403         4       157        34      39.3        46
 2710404         4       167        38      41.8        45
 2710501         4       149        32      37.3        48
 2710502         4       153        33      38.3        45
 2710601         4       155        35      38.8        41
 2710602         4       177        36      44.3        55
 2710701         4       133        24      33.3        41
 2710702         4       144        33      36.0        38
 2710703         4       142        31      35.5        45
 2710704         4       125        28      31.3        34
 2710801         4       133        32      33.3        34
 2710802         4       136        31      34.0        37
 2710901         4       127        30      31.8        33
 2710902         4       135        28      33.8        40
 2710903         4       148        32      37.0        41
 2711001         4       127        29      31.8        35
 2711002         4       151        37      37.8        39
 2711101         4       154        34      38.5        51
 2711102         4       156        32      39.0        43
 2711103         4       125        25      31.3        36
 2711201         4       116        22      29.0        36
 2711202         4       128        22      32.0        45
 2711301         4       118        24      29.5        34
 2711302         4       132        26      33.0        39
 2711303         4       122        28      30.5        36
 2711401         4       141        28      35.3        41
 2711402         4       140        28      35.0        41
 2711403         4       124        29      31.0        33
 2711404         4       152        33      38.0        44
 2711405         4       137        27      34.3        38
 2711501         4       176        40      44.0        49
 2711502         4       156        32      39.0        46
 2711503         4       152        28      38.0        51
 2711504         4       149        34      37.3        41
 2711505         4       139        28      34.8        41
 2711601         4       155        31      38.8        47
 2711602         4       157        34      39.3        43
 2711701         4       146        29      36.5        41
 2711702         4       171        36      42.8        51
 2711801         4       116        22      29.0        33
 2711802         4       152        33      38.0        46
 2711803         4       157        25      39.3        45
 2711901         4       144        26      36.0        45
 2711902         4       153        34      38.3        45
 2711903         4       169        33      42.3        48
 2711904         4       154        30      38.5        42
 2712001         4       144        29      36.0        47
 2712002         4       156        33      39.0        53
 2712003         4       166        32      41.5        57
 2712004         4       163        36      40.8        54
 2712005         4       148        31      37.0        40
 2712006         4       166        33      41.5        50
 2712101         4       145        34      36.3        41
 2712102         4       167        37      41.8        45
 2712103         4       146        31      36.5        40
 2712104         4       147        30      36.8        45
 2712105         4       151        24      37.8        50
 2712401         4       126        27      31.5        39
 2712402         4       134        27      33.5        39
 2712403         4       136        17      34.0        49
 2712404         4       145        31      36.3        46
 2712501         4       180        35      45.0        51
 2712502         4       146        29      36.5        50
 2712503         4       172        35      43.0        50
 2712504         4       150        34      37.5        42
 2712505         4       132        27      33.0        36
 2712506         4       144        24      36.0        45
 2712601         4       146        29      36.5        44
 2712602         4       159        31      39.8        46
 2712603         4       146        27      36.5        47
 2712604         4       146        33      36.5        41
 2712605         4       158        28      39.5        51
 2712606         4       158        34      39.5        52
 2712701         4       152        35      38.0        42
 2712702         4       165        31      41.3        56
 2712703         4       145        33      36.3        39
 2712704         4       170        37      42.5        47
 2712801         4       152        31      38.0        46
 2712802         4       148        30      37.0        41
 2712803         4       173        34      43.3        54
 2712804         4       155        27      38.8        50
 2712901         4       173        38      43.3        47
 2712902         4       155        28      38.8        50
 2712903         4       141        31      35.3        42
 2713001         4       166        37      41.5        45
 2713002         4       159        33      39.8        50
 2713003         4       140        23      35.0        45
 2713004         4       171        34      42.8        54
 2713005         4       151        31      37.8        46
 2713006         4       153        35      38.3        42
 2713101         4       106        24      26.5        31
 2713102         4       140        29      35.0        42
 2713103         4       146        29      36.5        43
 2713104         4       140        29      35.0        44
 2713105         4       159        33      39.8        43
 2713201         4       101        22      25.3        31
 2713202         4       137        30      34.3        38
 2713203         4       126        23      31.5        41
 2713204         4       128        25      32.0        41
 2713301         4       141        33      35.3        39
 2713302         4       116        26      29.0        33
 2713401         4       145        30      36.3        42
 2713402         4       113        21      28.3        36
 2713403         4       151        31      37.8        51
 2713404         4       131        28      32.8        41
 2713405         4       145        29      36.3        43
 2713406         4       148        33      37.0        44
 2713501         4       128        29      32.0        37
 2713502         4       138        28      34.5        42
 2713503         4       130        24      32.5        36
 2713504         4       155        33      38.8        43
 2713505         4       148        34      37.0        40
 2720101         4       198        40      49.5        61
 2720201         4       161        32      40.3        50
 2720202         4       137        30      34.3        38
 2720301         4       124        13      31.0        38
 2720302         4       124        15      31.0        43
 2720303         4       154        31      38.5        50
 2720401         4       152        34      38.0        43
 2720402         4       138        28      34.5        40
 2720501         4       149        30      37.3        42
 2720502         4       113        22      28.3        33
 2720601         4       204        34      51.0        83
 2720701         4       129        25      32.3        38
 2720702         4       139        25      34.8        42
 2720703         4       161        32      40.3        59
 2720801         4       123        28      30.8        36
 2720802         4       135        27      33.8        42
 2720901         4       132        28      33.0        36
 2720902         4       137        30      34.3        42
 2721001         4       132        29      33.0        37
 2721101         4       150        34      37.5        39
 2721201         4       112        18      28.0        35
 2721301         4       137        27      34.3        42
 2721302         4       129        29      32.3        34
 2721401         4       121        28      30.3        35
 2721402         4       141        32      35.3        40
 2721501         4       144        29      36.0        42
 2721502         4       161        28      40.3        46
 2721601         4       147        28      36.8        47
 2721701         4       156        33      39.0        49
 2721702         4       159        26      39.8        55
 2721801         4       142        33      35.5        38
 2721802         4       157        38      39.3        41
 2721901         4       170        36      42.5        50
 2721902         4       143        31      35.8        42
 2721903         4       134        25      33.5        40
 2722001         4       142        30      35.5        38
 2722002         4       161        33      40.3        47
 2722003         4       200        40      50.0        67
 2722101         4       113        23      28.3        33
 2722102         4       127        24      31.8        42
 2722103         4       135        31      33.8        38
 2722104         4       117        23      29.3        40
 2722105         4       178        39      44.5        50
 2722106         4       178        34      44.5        52
 2722107         4       130        25      32.5        37
 2722108         4       133        28      33.3        39
 2722109         4       110        23      27.5        31
 2722110         4       119        29      29.8        31
 2722401         4       125        27      31.3        37
 2722402         4        97        15      24.3        28
 2722501         4       101        20      25.3        29
 2722502         4       108        16      27.0        37
 2722601         4       139        23      34.8        42
 2722602         4       142        20      35.5        48
 2722603         4       132        29      33.0        39
 2722701         4       115        19      28.8        42
 2722702         4       149        27      37.3        46
 2722801         4       169        34      42.3        50
 2722802         4       139        27      34.8        41
 2722901         4       159        32      39.8        52
 2723001         4       145        25      36.3        52
 2723002         4       138        26      34.5        44
 2723003         4       124        27      31.0        36
 2723004         4       155        34      38.8        44
 2723101         4       120        21      30.0        34
 2723102         4       132        28      33.0        39
 2723201         4       147        30      36.8        44
 2723301         4       129        31      32.3        34
 2723401         4       118        25      29.5        37
 2723402         4       136        28      34.0        42
 2723403         4       124        28      31.0        37
 2723501         4       136        30      34.0        38
 2723502         4       137        31      34.3        38
 2723601         4       138        29      34.5        41
 2723602         4       131        27      32.8        39
 2723603         4       113        25      28.3        31
 2723604         4       137        30      34.3        38
 2723605         4       121        25      30.3        35
 2723606         4       158        33      39.5        52
 2723701         4       146        31      36.5        43
 2723702         4       123        23      30.8        35
 2723703         4       136        24      34.0        45
 2723801         4       134        29      33.5        40
 2723802         4       130        28      32.5        40
 2723803         4       121        25      30.3        41
 2723804         4       118        23      29.5        38
 2723901         4       131        26      32.8        39
 2723902         4       133        31      33.3        36
 2723903         4       142        29      35.5        51
 2723904         4       125        25      31.3        40
 2724001         4       108        15      27.0        34
 2724002         4       122        18      30.5        48
 2724003         4       125        22      31.3        47
 2724004         4       121        25      30.3        37
 2724005         4       136        33      34.0        36
 2724006         4       128        26      32.0        41
 2724007         4       116        26      29.0        33
 2724008         4       149        30      37.3        42
 2724009         4        97        19      24.3        28
 2724010         4       131        26      32.8        36
 2724011         4       118        16      29.5        40
 2724012         4       125        27      31.3        35
 2724013         4       137        24      34.3        46
 2724014         4       114        24      28.5        31
 2724015         4       135        24      33.8        46
 2724016         4       157        35      39.3        48
 2724017         4       135        28      33.8        40
 2724018         4       110        25      27.5        35
 2724019         4       151        32      37.8        41
 2724020         4       147        23      36.8        47
 2724021         4       133        23      33.3        42
 2724022         4       120        29      30.0        31
 2724023         4       110        12      27.5        36
 2724024         4       130        30      32.5        40
 2724025         4       126        22      31.5        38
 2724101         4       133        28      33.3        39
 2724102         4       113        17      28.3        37
 2724103         4       113        26      28.3        29
 2724201         4       102        18      25.5        32
 2724202         4       148        25      37.0        44
 2724203         4       107        22      26.8        36
 2724204         4       118        21      29.5        40
 2724205         4       119        23      29.8        33
 2724206         4        97        15      24.3        32
 2724207         4       115        26      28.8        35
 2724208         4       117        24      29.3        34
 2810101         4       115        25      28.8        33
 2810102         4       132        29      33.0        37
 2810103         4       118        27      29.5        32
 2810104         4       114        22      28.5        36
 2810201         4       114        24      28.5        33
 2810202         4       104        20      26.0        33
 2810203         4       138        28      34.5        43
 2810204         4       116        26      29.0        34
 2810301         4       127        25      31.8        40
 2810302         4       118        26      29.5        33
 2810303         4       118        23      29.5        37
 2810304         4       119        24      29.8        34
 2810305         4       123        28      30.8        35
 2810306         4       134        30      33.5        38
 2810401         4       148        26      37.0        44
 2810402         4       151        34      37.8        43
 2810403         4       163        27      40.8        47
 2810404         4       144        24      36.0        43
 2810405         4       132        27      33.0        40
 2810601         4       140        30      35.0        45
 2810602         4       128        27      32.0        40
 2810603         4       140        32      35.0        37
 2810604         4       144        27      36.0        47
 2810701         4       145        15      36.3        64
 2810702         4       129        28      32.3        34
 2810703         4       147        29      36.8        45
 2810704         4       131        31      32.8        37
 2810705         4       127        28      31.8        36
 2810706         4       119        24      29.8        33
 2810707         4       121        21      30.3        34
 2810801         4       104        19      26.0        31
 2810802         4       130        27      32.5        36
 2810803         4       125        27      31.3        35
 2810804         4       113        25      28.3        31
 2810805         4       121        26      30.3        33
 2810806         4       123        22      30.8        35
 2810901         4       102        25      25.5        26
 2810902         4       106        20      26.5        29
 2810903         4       109        23      27.3        35
 2810904         4       110        24      27.5        31
 2810905         4       119        25      29.8        37
 2810906         4       108        26      27.0        28
 2811001         4       103        20      25.8        34
 2811002         4       117        27      29.3        32
 2811003         4       120        24      30.0        38
 2811004         4       115        27      28.8        30
 2811005         4       110        25      27.5        32
 2811101         4       107        20      26.8        32
 2811102         4       126        25      31.5        39
 2811103         4       121        28      30.3        34
 2811104         4       134        27      33.5        43
 2811105         4       145        23      36.3        43
 2811201         4       125        25      31.3        38
 2811202         4       108        23      27.0        33
 2811203         4       127        27      31.8        38
 2811204         4       109        25      27.3        28
 2811301         4       110        23      27.5        31
 2811302         4       121        19      30.3        38
 2811303         4       124        22      31.0        41
 2811304         4       118        24      29.5        35
 2811305         3        94        27      31.3        34
 2811401         4       109        21      27.3        33
 2811402         4       118        23      29.5        39
 2811403         4       120        27      30.0        32
 2811404         4       112        25      28.0        31
 2811405         4       117        26      29.3        31
 2811406         4       109        23      27.3        30
 2811407         4       130        27      32.5        45
 2811501         4       105        22      26.3        31
 2811502         4       112        25      28.0        32
 2811503         4       116        25      29.0        32
 2811504         4       105        19      26.3        36
 2811505         4       114        23      28.5        31
 2811506         4        91        17      22.8        26
 2811507         4       108        22      27.0        35
 2811601         4       114        26      28.5        32
 2811602         4       121        22      30.3        34
 2811603         4       111        22      27.8        33
 2811604         4       108        23      27.0        33
 2811605         4       100        23      25.0        28
 2811606         4       112        25      28.0        33
 2811701         4       115        22      28.8        35
 2811702         4       127        29      31.8        37
 2811703         4       109        26      27.3        30
 2811704         4       114        25      28.5        31
 2811705         4       125        25      31.3        40
 2811706         4       111        24      27.8        30
 2811707         4       106        24      26.5        31
 2811801         4       139        30      34.8        41
 2811802         4       139        29      34.8        39
 2811803         4       133        25      33.3        42
 2811804         4       117        22      29.3        34
 2811805         4       128        26      32.0        42
 2811806         4       122        29      30.5        33
 2811901         4       137        28      34.3        39
 2811902         4       130        29      32.5        36
 2811903         4       112        24      28.0        35
 2811904         4       125        31      31.3        32
 2811905         4       123        21      30.8        40
 2812001         4       127        29      31.8        35
 2812002         4       106        25      26.5        28
 2812003         4       122        27      30.5        36
 2812004         4       121        25      30.3        37
 2812005         4       127        22      31.8        39
 2812101         4       166        31      41.5        52
 2812102         4       152        29      38.0        47
 2812103         4       117        24      29.3        37
 2812104         4       153        34      38.3        46
 2812105         4       116        20      29.0        33
 2812106         4       135        31      33.8        39
 2812201         4       138        31      34.5        41
 2812202         4       114        23      28.5        32
 2812203         4       109        26      27.3        29
 2812204         4       133        23      33.3        39
 2812205         4       132        20      33.0        47
 2812206         4       122        23      30.5        35
 2812301         4       105        18      26.3        35
 2812302         4       131        30      32.8        37
 2812303         4       122        26      30.5        33
 2812304         4       133        27      33.3        42
 2812305         4       130        31      32.5        34
 2812306         4       117        25      29.3        33
 2812307         4       116        27      29.0        31
 2820101         4       107        24      26.8        29
 2820102         4       109        21      27.3        33
 2820103         4       133        26      33.3        41
 2820201         4       126        26      31.5        36
 2820202         4       115        13      28.8        41
 2820301         4       132        28      33.0        41
 2820302         4       122        24      30.5        41
 2820303         4       105        19      26.3        31
 2820401         4       127        24      31.8        43
 2820402         4       123        27      30.8        35
 2820501         4       128        23      32.0        41
 2820502         4       115        22      28.8        37
 2820601         4       120        25      30.0        33
 2820602         4       112        22      28.0        32
 2820603         4       140        31      35.0        40
 2820604         4       126        25      31.5        39
 2820605         4       123        17      30.8        40
 2820606         4       151        33      37.8        44
 2820607         4       146        31      36.5        42
 2820608         4       122        26      30.5        36
 2820609         4       143        30      35.8        40
 2820701         4       116        21      29.0        38
 2820702         4       127        28      31.8        35
 2820801         4       106        23      26.5        30
 2820802         4       114        15      28.5        43
 2820901         4       122        24      30.5        35
 2820902         4       121        26      30.3        38
 2820903         4       125        25      31.3        34
 2821001         4       109        23      27.3        31
 2821002         4       119        25      29.8        33
 2821101         4        98        20      24.5        30
 2821102         4        95        17      23.8        30
 2821201         4       105        24      26.3        29
 2821202         4       114        23      28.5        34
 2821301         4        94         8      23.5        31
 2821302         4       123        28      30.8        35
 2821303         4       129        23      32.3        43
 2821304         4       116        24      29.0        34
 2821305         4        95        14      23.8        32
 2821306         4       112        23      28.0        32
 2821307         4       118        26      29.5        31
 2821401         4       112        21      28.0        31
 2821402         4       112        24      28.0        31
 2821403         4       124        27      31.0        34
 2821404         4       119        27      29.8        34
 2821405         4       102        15      25.5        33
 2821501         4       109        23      27.3        35
 2821502         4        98        19      24.5        34
 2821503         4        99        22      24.8        29
 2821601         4       108        24      27.0        29
 2821602         4        98        22      24.5        29
 2821603         4       106        24      26.5        29
 2821604         4       104        19      26.0        30
 2821605         4        83        13      20.8        26
 2821701         4       105        22      26.3        34
 2821702         4       111        23      27.8        31
 2821703         4       104        18      26.0        31
 2821704         4       109        24      27.3        31
 2821705         4       100        23      25.0        28
 2821801         4        92         8      23.0        31
 2821802         4       116        23      29.0        34
 2821901         4        79        15      19.8        25
 2821902         4       116        24      29.0        31
 2821903         4        94        19      23.5        27
 2822001         4        88        13      22.0        29
 2822002         4       133        26      33.3        44
 2822003         4       111        24      27.8        33
 2822101         4       108        21      27.0        30
 2822102         4       101        11      25.3        36
 2822103         4       127        19      31.8        40
 2822104         4       105        18      26.3        34
 2822201         4       113        25      28.3        31
 2822202         4       124        27      31.0        34
 2822203         4       124        24      31.0        44
 2822204         4       106        24      26.5        29
 2822301         4       114        24      28.5        30
 2822302         4       101        19      25.3        30
 2822303         4       107        22      26.8        32
 2822304         4       103        18      25.8        29
 2822401         4       115        27      28.8        31
 2822402         4       123        22      30.8        36
 2822403         4       108        23      27.0        30
 2822404         4       119        26      29.8        37
 2822405         4       126        25      31.5        35
 2822406         4       122        25      30.5        36
 2822407         4       127        26      31.8        41
 2822408         4       126        28      31.5        36
 2822409         4       120        22      30.0        37
 2822410         4        92        17      23.0        29
 2822411         4       115        21      28.8        33
 2822412         4       107        19      26.8        36
 2822413         4       166        33      41.5        52
 2822414         4       153        28      38.3        54
 2910101         4       162        33      40.5        50
 2910102         4       180        37      45.0        53
 2910103         4       164        32      41.0        47
 2910104         4       127        24      31.8        37
 2910201         4       185        36      46.3        54
 2910202         4       137        29      34.3        43
 2910301         4       161        36      40.3        48
 2910302         4       181        34      45.3        58
 2910303         4       236        48      59.0        68
 2910401         4       171        38      42.8        51
 2910402         4       184        40      46.0        52
 2910403         4       164        37      41.0        47
 2910404         4       149        30      37.3        47
 2910501         4       162        33      40.5        49
 2910502         4       169        36      42.3        49
 2910601         4       175        32      43.8        54
 2910602         4       169        31      42.3        51
 2910701         4       168        30      42.0        48
 2910702         4       165        39      41.3        43
 2910801         4       154        31      38.5        47
 2910901         4       189        39      47.3        53
 2911001         4       127        27      31.8        34
 2911002         4       127        30      31.8        34
 2911101         4       170        34      42.5        49
 2911102         4       146        34      36.5        42
 2911201         4       166        36      41.5        46
 2911202         4       148        27      37.0        51
 2911203         4       157        35      39.3        44
 2911301         4       146        31      36.5        41
 2911302         4       123        27      30.8        35
 2911401         4       138        31      34.5        43
 2911402         4       144        28      36.0        41
 2911501         4       133        28      33.3        41
 2911502         4       158        29      39.5        49
 2911601         4       152        31      38.0        47
 2911602         4       158        29      39.5        52
 2911701         4       152        31      38.0        44
 2911702         4       126        30      31.5        34
 2911801         4       135        27      33.8        37
 2911802         4       142        28      35.5        41
 2911803         4       136        27      34.0        43
 2911804         4       135        32      33.8        39
 2911901         4       146        32      36.5        46
 2911902         4       156        35      39.0        43
 2912001         4       151        30      37.8        44
 2912101         4       144        29      36.0        40
 2912201         4       136        31      34.0        36
 2912202         4       125        27      31.3        36
 2912203         4       133        32      33.3        37
 2912301         4       140        30      35.0        39
 2912302         4       150        35      37.5        45
 2912303         4       132        29      33.0        36
 2912401         4       134        28      33.5        37
 2912402         4       124        20      31.0        48
 2912501         4       116        24      29.0        32
 2912601         4       156        37      39.0        43
 2912602         4       140        25      35.0        41
 2912603         4       125        23      31.3        38
 2912701         4       133        30      33.3        41
 2912702         4       120        24      30.0        41
 2912801         4       129        27      32.3        39
 2912802         4       127        28      31.8        37
 2912901         4       131        28      32.8        38
 2912902         4       142        27      35.5        46
 2920101         4       136        31      34.0        36
 2920102         4       142        27      35.5        45
 2920103         4       132        27      33.0        38
 2920104         4       138        29      34.5        39
 2920201         4       118        21      29.5        42
 2920202         4       165        32      41.3        57
 2920301         4       145        26      36.3        45
 2920302         4       147        32      36.8        40
 2920401         4       162        32      40.5        52
 2920402         4       140        32      35.0        41
 2920403         4       179        31      44.8        53
 2920501         4       170        32      42.5        53
 2920601         4       150        26      37.5        52
 2920602         4       150        34      37.5        41
 2920701         4       139        30      34.8        39
 2920801         4       151        23      37.8        49
 2920901         4       142        34      35.5        37
 2920902         4       108        15      27.0        34
 2920903         4       132        25      33.0        41
 2921001         4       120        25      30.0        34
 2921002         4       120        25      30.0        41
 2921101         4       143        26      35.8        43
 2921201         4       162        31      40.5        51
 2921202         4       148        32      37.0        46
 2921203         4       137        29      34.3        38
 2921301         4       117        13      29.3        43
 2921401         4       126        24      31.5        41
 2921402         4       160        29      40.0        51
 2921501         4       132        23      33.0        44
 2921502         4       137        29      34.3        44
 2921601         4       165        31      41.3        54
 2921701         4       138        29      34.5        44
 2921801         4       119        27      29.8        36
 2921802         4       100        11      25.0        37
 2921901         4       128        24      32.0        43
 2921902         4       134        24      33.5        38
 2922001         4       126        29      31.5        37
 2922002         4       121        25      30.3        38
 2922003         4       119        23      29.8        43
 2922004         4       130        25      32.5        37
 2922005         4       147        30      36.8        41
 2922101         4       121        24      30.3        43
 2922201         4       132        24      33.0        40
 2922301         4       119        21      29.8        39
 2922401         4       132        27      33.0        38
 2922402         4       140        26      35.0        44
 2922403         4       124        23      31.0        38
 2922501         4       115        20      28.8        37
 2922601         4       103        23      25.8        32
 2922602         4       139        25      34.8        43
 2922603         4       127        23      31.8        35
 2922604         4       136        33      34.0        36
 2922701         4       134        23      33.5        48
 2922801         4       113        25      28.3        32
 2922901         4       121        26      30.3        39
 2923001         4       134        28      33.5        46
 2923002         4       117        25      29.3        34
 2923003         4       104        17      26.0        32
 2923004         4       134        28      33.5        45
 2923005         4       112        26      28.0        33
 2923006         4       124        28      31.0        36
 2923007         4       125        22      31.3        44
 2923008         4       114        23      28.5        33
 2923009         4       136        23      34.0        45
 3010101         4       150        31      37.5        41
 3010102         4       135        29      33.8        41
 3010103         4       135        31      33.8        36
 3010201         4       136        29      34.0        37
 3010202         4       127        29      31.8        34
 3020101         4       144        27      36.0        50
 3020102         4       114        21      28.5        33
 3020103         4       124        22      31.0        41
 3020104         4        86        13      21.5        27
 3020201         4       108        24      27.0        33
 3020202         4       125        25      31.3        38
 3020203         4       156        35      39.0        49
 3020204         4       140        28      35.0        46
 3020205         4       133        28      33.3        39
 3110101         8       325        26      40.6        71
 3120101         4       175        33      43.8        53
 3120102         4       188        27      47.0        58
 3120103         4       136        18      34.0        51
 3120104         4       143        26      35.8        51
 3210101         4       159        29      39.8        53
 3210102         4       144        28      36.0        49
 3210103         4       154        27      38.5        63
 3210104         4       134        29      33.5        39
 3210201         4       123        22      30.8        36
 3210202         4       142        26      35.5        51
 3210203         4       133        31      33.3        36
 3210204         4       140        29      35.0        42
 3210301         4       118        28      29.5        32
 3210302         4       137        25      34.3        39
 3210303         4       124        25      31.0        40
 3210401         4       136        27      34.0        41
 3210402         4       129        30      32.3        35
 3210403         4       144        32      36.0        44
 3210404         4       141        28      35.3        41
 3210405         4       142        32      35.5        38
 3210406         3       125        36      41.7        49
 3210501         4       154        32      38.5        48
 3210502         4       151        35      37.8        43
 3210503         4       152        33      38.0        45
 3210504         4       158        32      39.5        55
 3210505         4       156        31      39.0        44
 3210506         4       154        32      38.5        44
 3210507         4       157        33      39.3        45
 3210508         4       167        36      41.8        50
 3210509         4       172        33      43.0        54
 3210601         4       122        20      30.5        40
 3210602         4       117        28      29.3        32
 3210603         4       117        28      29.3        32
 3210604         4       136        29      34.0        40
 3210605         4       150        32      37.5        42
 3210606         4       122        26      30.5        37
 3210607         4       142        26      35.5        42
 3210608         4       152        31      38.0        46
 3210701         4       114        22      28.5        35
 3210702         4       111        19      27.8        38
 3210703         4       106        25      26.5        28
 3210704         4       117        27      29.3        34
 3210705         4       132        29      33.0        37
 3210706         4       125        23      31.3        37
 3210707         4       119        24      29.8        35
 3210708         4       132        23      33.0        39
 3210801         4       132        29      33.0        40
 3210802         4       125        26      31.3        36
 3210803         4       135        29      33.8        40
 3210804         4       122        24      30.5        36
 3210805         4       114        26      28.5        33
 3210806         3        95        24      31.7        40
 3210901         4       115        25      28.8        34
 3210902         4       112        20      28.0        34
 3210903         4       138        25      34.5        43
 3210904         4       116        24      29.0        32
 3211001         4       135        27      33.8        42
 3211002         4       138        27      34.5        46
 3211003         4       117        26      29.3        32
 3211004         4       130        29      32.5        36
 3211005         4       126        27      31.5        33
 3211006         4       129        28      32.3        38
 3211101         4       129        26      32.3        40
 3211102         4       113        23      28.3        35
 3211103         4       132        28      33.0        38
 3211104         4       101        23      25.3        29
 3211105         4       121        29      30.3        32
 3211201         4       105        21      26.3        36
 3211202         4       120        25      30.0        34
 3211203         4       118        24      29.5        35
 3211204         4       128        28      32.0        35
 3211301         4       107        23      26.8        31
 3211302         4       118        25      29.5        36
 3211303         4       122        25      30.5        37
 3211304         4       102        22      25.5        30
 3211305         4       128        27      32.0        37
 3211306         4       131        23      32.8        45
 3211307         4       124        28      31.0        33
 3211401         4       132        26      33.0        37
 3211402         4       129        27      32.3        36
 3211403         4       123        28      30.8        34
 3211404         4       143        32      35.8        40
 3211405         4       124        28      31.0        33
 3211406         4       119        27      29.8        32
 3211407         4       115        24      28.8        33
 3211408         4       136        26      34.0        42
 3220101         4       136        24      34.0        48
 3220102         4       142        22      35.5        49
 3220201         4       115        22      28.8        36
 3220202         4       147        27      36.8        57
 3220203         4       124        20      31.0        43
 3220204         4       151        34      37.8        47
 3220205         4       137        23      34.3        43
 3220206         4       153        22      38.3        55
 3220207         4       119        20      29.8        50
 3220208         4       153        31      38.3        46
 3220301         4       139        29      34.8        43
 3220401         4       147        30      36.8        45
 3220402         4       142        30      35.5        43
 3220403         4       126        28      31.5        39
 3220404         4       134        28      33.5        39
 3220405         4       133        26      33.3        41
 3220406         4       178        28      44.5        73
 3220407         4       108        17      27.0        33
 3220408         4       157        33      39.3        47
 3220501         4       158        27      39.5        48
 3220502         4       187        30      46.8        71
 3220503         4       160        33      40.0        51
 3220601         4       130        29      32.5        36
 3220602         4        97        23      24.3        25
 3220603         4       135        24      33.8        46
 3220701         4       118        24      29.5        34
 3220702         4       125        21      31.3        36
 3220703         4       109        27      27.3        28
 3220704         4       117        24      29.3        32
 3220705         4       118        24      29.5        33
 3220706         4       128        26      32.0        41
 3220801         4       113        24      28.3        32
 3220802         4       119        28      29.8        32
 3220803         4        89        15      22.3        32
 3220804         4       114        22      28.5        33
 3220805         4       107        23      26.8        35
 3220806         4       122        23      30.5        34
 3220807         4       129        21      32.3        38
 3220808         4       105        22      26.3        28
 3220901         4       120        27      30.0        32
 3221001         4       117        21      29.3        35
 3221002         4       110        26      27.5        30
 3221101         4       124        25      31.0        37
 3221102         4       118        24      29.5        34
 3221103         4       114        26      28.5        31
 3221104         4       115        23      28.8        33
 3221201         4       103        19      25.8        33
 3221202         4       104        22      26.0        31
 3221301         4       121        28      30.3        35
 3221302         4       145        31      36.3        41
 3221303         4       134        26      33.5        39
 3221401         4       111        23      27.8        31
 3221402         4       109        22      27.3        31
 3221403         4       118        27      29.5        31
 3221404         4        87        13      21.8        32
 3221405         4       125        25      31.3        37
 3221406         4        91        18      22.8        33
 3221407         4       111        21      27.8        37
 3310101         4       102        22      25.5        27
 3310102         4       126        27      31.5        37
 3310103         4       134        27      33.5        42
 3310104         4       130        25      32.5        43
 3310301         4       106        15      26.5        40
 3310302         4       118        24      29.5        36
 3310303         4       123        28      30.8        36
 3310304         4       110        20      27.5        33
 3310401         4       127        29      31.8        37
 3310402         4       118        24      29.5        38
 3310403         4       137        33      34.3        36
 3310404         4       134        27      33.5        39
 3310405         4       135        31      33.8        36
 3310501         4       132        29      33.0        37
 3310502         4       124        27      31.0        36
 3310503         4       122        20      30.5        35
 3310601         4       131        30      32.8        39
 3310602         4       131        31      32.8        37
 3310603         4       138        30      34.5        39
 3310604         4       135        31      33.8        37
 3310605         4       126        26      31.5        36
 3310701         4       122        25      30.5        35
 3310702         4       130        28      32.5        36
 3310703         4       120        21      30.0        38
 3310704         4       120        26      30.0        36
 3310705         4       133        26      33.3        40
 3310801         4       111        23      27.8        36
 3310802         4       117        24      29.3        33
 3310803         4       128        30      32.0        35
 3310804         4       106        25      26.5        28
 3310805         4       118        27      29.5        32
 3310901         4       106        22      26.5        29
 3310902         4       109        24      27.3        31
 3310903         4       122        23      30.5        40
 3311001         4       105        15      26.3        37
 3311002         4       109        19      27.3        36
 3311003         4        94        20      23.5        27
 3311004         4       100        22      25.0        28
 3311101         4       114        27      28.5        29
 3311102         4       119        28      29.8        34
 3311201         4       106        22      26.5        30
 3311202         4       121        24      30.3        34
 3311203         4       108        24      27.0        32
 3311204         4       112        25      28.0        31
 3311301         4       126        27      31.5        39
 3311302         4       115        23      28.8        35
 3311303         4       117        25      29.3        37
 3311304         4       127        29      31.8        34
 3311401         4       105        25      26.3        30
 3311402         4       112        22      28.0        34
 3311501         4       137        30      34.3        40
 3311502         4       113        23      28.3        33
 3311503         4       154        30      38.5        52
 3311504         4       131        32      32.8        34
 3311601         4       130        29      32.5        36
 3311602         4       134        27      33.5        40
 3311701         4       133        28      33.3        41
 3311702         4       145        31      36.3        44
 3311801         4       106        24      26.5        29
 3311802         4       114        26      28.5        35
 3311803         4       124        24      31.0        37
 3311804         4       136        30      34.0        38
 3311805         4       120        21      30.0        36
 3311901         4       120        28      30.0        33
 3311902         4       111        24      27.8        30
 3311903         4       133        29      33.3        38
 3312001         4       126        25      31.5        37
 3312002         4       127        26      31.8        35
 3312003         4       133        28      33.3        36
 3312101         4       108        23      27.0        33
 3312102         4       146        30      36.5        42
 3312103         4       126        27      31.5        35
 3312104         4       124        25      31.0        36
 3312201         4       146        29      36.5        49
 3312202         4       145        33      36.3        40
 3312203         4       145        24      36.3        46
 3312204         4       144        27      36.0        45
 3312301         4        98        19      24.5        28
 3312302         4       116        23      29.0        34
 3312303         4       120        20      30.0        35
 3312401         4       127        25      31.8        36
 3312402         4       122        30      30.5        32
 3312403         4       111        24      27.8        31
 3312501         4       121        29      30.3        34
 3312502         4       116        26      29.0        35
 3312601         4       107        25      26.8        29
 3312602         4       111        19      27.8        34
 3312603         4       115        26      28.8        35
 3312701         4       119        27      29.8        32
 3312702         4       116        21      29.0        41
 3312703         4       116        26      29.0        34
 3312801         4       127        27      31.8        37
 3312802         4       144        28      36.0        44
 3312803         4       115        24      28.8        34
 3312901         4       115        21      28.8        37
 3312902         4        95        18      23.8        27
 3312903         4       119        26      29.8        34
 3312904         4       120        20      30.0        37
 3313001         4       118        27      29.5        31
 3313002         4       128        28      32.0        39
 3313101         4       123        10      30.8        55
 3313102         4       132        31      33.0        38
 3313103         4       131        28      32.8        39
 3313104         4       105        23      26.3        31
 3320101         4       107        18      26.8        32
 3320102         4       122        26      30.5        33
 3320103         4       108        26      27.0        28
 3320104         4       117        19      29.3        47
 3320105         4       100        19      25.0        29
 3320301         4       119        21      29.8        35
 3320302         4       103        23      25.8        29
 3320303         4       105        24      26.3        30
 3320304         4       111        20      27.8        33
 3320305         4       112        26      28.0        29
 3320306         4       113        21      28.3        36
 3320401         4       123        29      30.8        35
 3320402         4       110        25      27.5        32
 3320403         4       110        20      27.5        35
 3320404         4       128        27      32.0        37
 3320405         4       143        28      35.8        42
 3320501         4       124        27      31.0        33
 3320601         4        95        13      23.8        31
 3320602         4       129        26      32.3        39
 3320701         4       107        20      26.8        35
 3320702         4       111        25      27.8        31
 3320801         4       108        23      27.0        33
 3320802         4       113        23      28.3        36
 3320803         4       115        23      28.8        38
 3320804         4       100        16      25.0        30
 3320805         4       110        26      27.5        30
 3320901         4        98        20      24.5        29
 3320902         4       116        25      29.0        33
 3321001         4       115        24      28.8        31
 3321002         4       103        24      25.8        28
 3321003         4       113        24      28.3        31
 3321004         4        94        22      23.5        25
 3321005         4        94        19      23.5        27
 3321101         4       108        23      27.0        32
 3321102         4       115        26      28.8        33
 3321201         4        98        20      24.5        30
 3321202         4        82        18      20.5        25
 3321203         4        90        18      22.5        27
 3321204         4       107        21      26.8        32
 3321205         4       108        20      27.0        37
 3321206         4       109        20      27.3        35
 3321207         4       105        22      26.3        30
 3321208         4       116        23      29.0        35
 3321209         4       120        23      30.0        40
 3321210         4       104        22      26.0        29
 3321301         4       132        27      33.0        36
 3321302         4        79        15      19.8        25
 3321303         4        96        16      24.0        31
 3321401         4       107        24      26.8        33
 3321402         4        98        22      24.5        27
 3321501         4       106        21      26.5        29
 3321502         4       122        21      30.5        41
 3321503         4       105        23      26.3        28
 3321504         4       112        20      28.0        32
 3321601         4       114        25      28.5        35
 3321701         4       119        26      29.8        35
 3321801         4        97        22      24.3        26
 3321802         4       125        28      31.3        34
 3321803         4        96        17      24.0        32
 3321901         4       111        26      27.8        30
 3321902         4       125        26      31.3        36
 3322001         4       107        23      26.8        29
 3322101         4       112        23      28.0        36
 3322102         4       159        28      39.8        53
 3322103         4       105         8      26.3        37
 3322201         4       118        21      29.5        38
 3322301         4       106        23      26.5        33
 3322302         4       121        27      30.3        32
 3322401         4       100        13      25.0        36
 3322402         4       133        30      33.3        35
 3322403         4       120        26      30.0        34
 3322404         4       120        28      30.0        33
 3322405         4       129        31      32.3        34
 3322501         4       110        22      27.5        39
 3322502         4       118        26      29.5        32
 3322601         4       111        25      27.8        30
 3322602         4       101        19      25.3        30
 3322603         4        94        16      23.5        31
 3322701         4       123        28      30.8        33
 3322702         4       115        21      28.8        38
 3322801         4       128        28      32.0        35
 3322802         4       105        20      26.3        29
 3322803         4        88        17      22.0        29
 3322901         4       122        26      30.5        34
 3322902         4       109        24      27.3        34
 3322903         4       118        27      29.5        31
 3322904         4       116        21      29.0        38
 3322905         4       134        24      33.5        47
 3323001         4       111        25      27.8        30
 3323002         4       129        28      32.3        38
 3323003         4       102        21      25.5        33
 3323004         4       121        27      30.3        32
 3323101         4       105        19      26.3        35
 3323201         4       109        18      27.3        31
 3323202         4       107        21      26.8        34
 3323203         4       103        18      25.8        32
 3323204         4       106        23      26.5        34
 3323205         4       117        24      29.3        35
 3323206         4       111        21      27.8        39
 3323207         4       102        22      25.5        29
 3323208         4       135        29      33.8        41
 3323209         4       116        23      29.0        35
 3323210         4       116        19      29.0        42
 3323211         4       118        23      29.5        33
 3410201         4       125        28      31.3        36
 3410202         4       135        30      33.8        38
 3410203         4       116        26      29.0        32
 3410401         4       133        23      33.3        41
 3420101         4       127        31      31.8        32
 3420201         4       117        28      29.3        31
 3420202         4       118        25      29.5        36
 3420203         4       112        25      28.0        33
 3420204         4       111        23      27.8        32
 3420205         4       112        21      28.0        36
 3420206         4        88        18      22.0        24
 3420207         4       112        24      28.0        35
 3420208         4       109        23      27.3        32
 3420209         4       111        23      27.8        31
 3420210         4       126        26      31.5        40
 3420301         4       166        24      41.5        54
 3420401         4       113        24      28.3        34
 3420402         4       104        20      26.0        32
 3510101         4       133        26      33.3        46
 3510102         4       132        26      33.0        40
 3510103         4       139        27      34.8        39
 3510201         4       153        26      38.3        58
 3510202         3       141        23      47.0        72
 3510301         4       111        25      27.8        33
 3510302         4       114        27      28.5        31
 3510303         4       119        19      29.8        34
 3510304         4       105        18      26.3        33
 3520101         4       107        20      26.8        36
 3520102         4       129        26      32.3        38
 3520103         4       111        23      27.8        32
 3520104         4       112        25      28.0        33
 3520105         4       116        26      29.0        32
 3520106         4       107        21      26.8        32
 3520107         4        97        23      24.3        26
 3520108         4       112        23      28.0        36
 3520109         4       109        23      27.3        32
----------------------------------------------------------
   3,143    12,737   456,999         2      35.9        94
```

One thing we notice is that the output from `svydescribe` is very similar but not identical to what is listed in the documentation.  We see here 3,143 total (sub)strata, 12,737 PSUs and a total of 456,999 individuals.

In the overview section, the documentation says that 12,654 PSUs out of an allotted 12,808 were surveyed while the file titled "Estimation Procedure_68.doc" says that 12,784 PSUs were allotted. The overview section also states that 100,957 households and 459,784 individuals were surveyed. All of these figures differ slightly from what we find in the files. (Doing a similar exercise for the `Block_3_Household characteristics`, I find that the number of households surveyed is 101,724.)

Browsing through the `svydescribe` output some more, we see some strata in which the output from `svydescribe` lists three units where the "Estimation Procedure_68.doc" file lists four allotted PSUs.

I am not entirely sure how to reconcile the differences between the documentation and what we see in the files. Perhaps in some cases the NSSO could not survey an allotted PSU due to difficult field conditions. Perhaps the discrepancies are due to human error in writing up the documentation. Or perhaps some additional cleaning of the data was done after the documentation was written. Maybe others will have some insights for me here.

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
