---
title: Using Stata with Markdown
subtitle: What are your options? 
author: Emmanuel Teitelbaum
date: '2021-06-09'
slug: stata-and-markdown
categories: []
tags: 
  - Atom
  - Hydrogen
  - Stata kernel
  - language-markdown
  - Statamarkdown
  - Markstat
  - Jupyter
  - PyStata
summary: ''
authors: []
lastmod: '2021-06-09T10:56:06-04:00'
featured: no
image:
  caption: 'Original collage by Emmanuel Teitelbaum'
  focal_point: ''
  preview_only: no
projects: []
draft: TRUE
---



Frequently when I am working in Stata, I find myself wanting to avail myself of the capabilities inherent in R Markdown. I like to be able to intersperse code with text and share my notes with other people in an attractive dynamic HTML or PDF document. It is also really helpful from a workflow standpoint to be able to run code snippets in the text editor and to preview the document that I am writing. 

At one point, I thought my solution would just abandon Stata entirely for R. But I found that I kept having to go back to Stata for certain types of analysis and, because some of my earlier projects were done in Stata, it just makes sense to keep doing them in Stata. 

A few weeks ago, I felt I just couldn't stand working in Stata's .do file editor anymore, so I began a quest to figure out how I could best integrate Stata with Markdown in other environments. 

Below is are the options I came across. I start with the ones I like best and proceed in descending order from there.  

## Hydrogen in Atom 

I really love this setup. Atom is such a cool text editor. You can edit almost any language or document type, the color schemes are attractive and the keyboard shortcuts really help with efficiency. 

The best thing about Atom is that you can use the [Hydrogen package](https://atom.io/packages/hydrogen) to run code interactively. You can even run code for multiple kernels/languages in the [same document](https://blog.nteract.io/hydrogen-introducing-rich-multi-language-documents-b5057ff34efc).    

To create an interactive document with Stata, you need to install Kyle Barron's [stata_kernel](https://kylebarron.dev/stata_kernel/) and the [language-markdown](https://atom.io/packages/language-markdown)package. `stata_kernel` is the Jupyter kernel for Stata that allows the code to run interactively while Language Markdown is an Atom package that provides support for Markdown (including R Markdown). I also installed [Markdown Preview Plus (MPP)](https://atom.io/packages/markdown-preview-plus), which provides a live updated preview of your document.  

In case you are not familiar with Atom, each Jupyter kernel that you use is going to be installed in a slightly different way. For the `stata_kernel`, follow the instructions that Kyle Barron provides. You install Atom packages in Atom by hitting `ctrl` + `shift` + `p` in Windows/Linux or `cmd` + `shift` + `p` in macOS.      

Once you get everything set up, you should be able to intersperse your code with text and preview the resulting document like this:    

![](images/stata-markdown.gif)

The only shortcoming here is that you cannot easily export the code along with the text to a shareable HTML or PDF document. For this, you can open your Markdown document in R and use the Statamarkdown package.   

## Statamarkdown in R

With Doub Hemken's [Statamarkdown](https://github.com/Hemken/Statamarkdown), you can knit your .Rmd or .RMarkdown file in the usual way to create a document like an .html or .pdf or a blog post. There is a nice tutorial on how to use it [here](https://www.ssc.wisc.edu/~hemken/Stataworkshops/Stata%20and%20R%20Markdown/StataMarkdown.html). 

At the time I am writing this post, Statamarkdown is good for producing documents but [does not work](https://github.com/Hemken/Statamarkdown/issues/12) for running code interactively in a notebook. Also, Statamarkdown does not automatically remember what code you ran from one chunk to the next. In order to run a code chunk sequentially that builds on the previous chunk, you have to enable the `collectcode = TRUE` option, like this:   

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

The process creates a bunch of .do and .log files that you have to back and clean up afterwards. Despite these limitations and minor hassles, Statamarkdown does achieve the desired objective of allowing you to use Stata in an R Markdown framework. 

## Markstat in Stata

Germán Rodriguez's [`markstat` command](https://data.princeton.edu/stata/markdown) is probably the best option if you want to produce a dynamic document but stay completely in the realm of Stata. With `markstat` you intersperse Markdown annotations with Stata code like this: 

```
# Stata and Markdown

Let's write some markdown-formatted text and see what happens.

## Run Stata Code

Now let's try running some Stata code:

  sysuse auto, clear
  summarize mpg weight
  regress mpg weight

## To Do List 

Let's follow up on it by doing the following:

1. One thing
2. Two thing
3. Red thing
4. Blue thing

Etc.... 
```

The code gets identified with indentations rather than back ticks. You then need to save it as a script (.stmd) file and then process the file by running the `markstat` command in Stata. You also need to have Pandoc installed. 

Markstat definitely produces attractive documents and slides and is a better solution than Statamarkdown in R if that is all you want to do. In my case, I really wanted to be able to include Stata code and results in .RMarkdown files so that I could produce posts like this one. 

## Other Solutions

There are a few other solutions I looked at but did not end up not using. 

Stata is promoting its [**pystata**](https://www.stata.com/python/pystata/install.html) Python package, which allows you to run Stata in an IPython environment like Jupyter notebooks. There is also Stata's [`dyndoc`](https://www.stata.com/manuals/rptdyndoc.pdf) command, which converts a text file into an HTML file or Word document. 

I also tried using **pystata** in conjunction with the **reticulate** package in R, which I definitely do not recommend! 
 
I hope you find a Stata/Markdown solution that works for you. Let me know what you choose and if there is something I missed here. 