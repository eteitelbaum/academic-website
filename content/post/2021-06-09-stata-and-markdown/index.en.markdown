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
draft: FALSE
---



Frequently when I am working in Stata, I find myself really missing the key features of R Markdown, like the ability to intersperse code with text and share my notes with other people in an attractive dynamic HTML or PDF document. I also find it really helpful from a workflow standpoint to be able to run code snippets in the text editor and to preview the document that I am writing in real time like you can in an R Notebook. 

At one point, I thought my solution would just abandon Stata entirely for R. But I find that I still need Stata for certain kinds of analysis, and for some projects there is enough inertia that it makes sense to just keep doing them in Stata.  

A little while back, though, I found I just couldn't stand working in Stata's .do file editor anymore. So I started a quest to figure out how I could best integrate Stata with Markdown in other environments. Here are some of the options I came across. 

## Hydrogen in Atom 

I really love this setup. Atom is such a cool text editor. You can edit almost any language or document type, the color schemes are attractive and the keyboard shortcuts really help with efficiency. 

The best thing about Atom is that you can use the [Hydrogen package](https://atom.io/packages/hydrogen) to run code interactively. You can even run code for multiple kernels/languages in the [same document](https://blog.nteract.io/hydrogen-introducing-rich-multi-language-documents-b5057ff34efc).    

To create an interactive document with Stata, you need to install Kyle Barron's [stata_kernel](https://kylebarron.dev/stata_kernel/), the [Language Stata](https://atom.io/packages/language-stata) package and the [Language Markdown](https://atom.io/packages/language-markdown) package. `stata_kernel` is the Jupyter kernel for Stata that allows the code to run interactively, Language Stata provides Stata lanugage support, and Language Markdown provides support for Markdown (including R Markdown). I also installed [Markdown Preview Plus (MPP)](https://atom.io/packages/markdown-preview-plus), which provides a live updated preview of your document.       

In case you are not familiar with Atom, each Jupyter kernel that you use is going to be installed in a slightly different way. For the `stata_kernel`, follow the instructions that Kyle Barron provides. You install Atom packages in Atom by hitting `ctrl` + `shift` + `p` in Windows/Linux or `cmd` + `shift` + `p` in macOS and typing `install packages` in the search field.      

Once you have everything set up, you will be able to intersperse your code with text, run the code interactively, and preview the resulting document like this:    

![](/media/stata-markdown.gif)

The only shortcoming here is that you cannot easily export the code along with the text to a shareable HTML or PDF document. For this, you can open your Markdown document in R and use the Statamarkdown package.   

## Statamarkdown in R

With Doug Hemken's [Statamarkdown](https://github.com/Hemken/Statamarkdown), you can knit your .Rmd or .RMarkdown file in the usual way to create a document like an .html or .pdf or a blog post. There is a nice tutorial on how to use it [here](https://www.ssc.wisc.edu/~hemken/Stataworkshops/Stata%20and%20R%20Markdown/StataMarkdown.html). 

At the time I am writing this post, Statamarkdown is good for producing documents but [does not work](https://github.com/Hemken/Statamarkdown/issues/12) for running code interactively in a notebook. Also, Statamarkdown does not automatically remember what code you ran from one chunk to the next. In order to run a code chunk sequentially that builds on the previous chunk, you have to enable the `collectcode = TRUE` option. Here is what the output looks like: 


```stata
  sysuse auto, clear
  summarize mpg weight
  regress mpg weight
```

```
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
         mpg |         74     21.2973    5.785503         12         41
      weight |         74    3019.459    777.1936       1760       4840

      Source |       SS           df       MS      Number of obs   =        74
-------------+----------------------------------   F(1, 72)        =    134.62
       Model |   1591.9902         1   1591.9902   Prob > F        =    0.0000
    Residual |  851.469256        72  11.8259619   R-squared       =    0.6515
-------------+----------------------------------   Adj R-squared   =    0.6467
       Total |  2443.45946        73  33.4720474   Root MSE        =    3.4389

------------------------------------------------------------------------------
         mpg | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
      weight |  -.0060087   .0005179   -11.60   0.000    -.0070411   -.0049763
       _cons |   39.44028   1.614003    24.44   0.000     36.22283    42.65774
------------------------------------------------------------------------------
```

Statamarkdown creates a bunch of .do and .log files that you have to back and clean up afterwards. Despite these limitations and minor hassles, Statamarkdown does achieve the desired objective of allowing you to produce Stata ouput in an HTML or PDF document. 

## Markstat in Stata

Germán Rodriguez's [markstat](https://data.princeton.edu/stata/markdown) is probably the best option if you want to produce a dynamic document but stay completely in the realm of Stata. With `markstat` you intersperse Markdown annotations with Stata code like this: 

````markdown
# Stata and Markdown

Write some Markdown-formatted text and see what happens.

## Run Stata Code

Now try running some Stata code:

  sysuse auto, clear
  summarize mpg weight
  regress mpg weight

## To Do List 

That was a great analysis. Next we will do the following:

1. One thing
2. Two thing
3. Red thing
4. Blue thing

Etc....

````

The code gets identified with indentations rather than back ticks. You then need to save it as a script (.stmd) file and then process the file by running the `markstat` command in Stata. You also need to have Pandoc installed. 

`markstat` definitely produces attractive documents and slides and is a better solution than Statamarkdown in R if that is all you need to do. 

## Other Solutions

There are a few other solutions I looked at but did not end up not using. 

Stata is promoting its [pystata](https://www.stata.com/python/pystata/install.html) Python package, which allows you to run Stata in an IPython environment like Jupyter notebooks. There is also Stata's [`dyndoc`](https://www.stata.com/manuals/rptdyndoc.pdf) command, which converts a text file into an HTML file or Word document. 

I also tried using pystata in conjunction with the reticulate package in R, which I definitely do not recommend! 
 
I hope you find a Stata/Markdown solution that works for you. Let me know what you choose! 

<script src="https://utteranc.es/client.js"
        repo="eteitelbaum/academic-website"
        issue-term="pathname"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>

