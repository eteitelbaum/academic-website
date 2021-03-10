---
title: Managing publications on your Hugo Academic website
author: Emmanuel Teitelbaum
date: '2021-01-29'
slug: managing-pubs-Academic-website
categories: [hugo academic, blogdown]
tags:
  - hugo academic
  - blogdown
  - publications
subtitle: ''
summary: ''
authors: []
lastmod: '2021-03-09' 
featured: no
image: 
  caption: 'Photo by <a href="https://unsplash.com/@gabiontheroad?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Gabriella Clare Marino</a> on <a href="https://unsplash.com/s/photos/publications?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span>'
  focal_point: 'center'
  preview_only: no
projects: []
draft: FALSE
---

For my first blog post, I thought I would say a little bit about how I set up the publications section of my website. There are a good many tutorials out there on how to set up a website using blogdown and the Hugo Academic theme (my favorite guide is [this one](https://alison.rbind.io/post/new-year-new-blogdown/)  by Alison Hill). But I found less information on how to manage academic content, so I thought it might be helpful to share what I learned. 

**Note**: Everything I am about to review was done using Hugo version 0.80.0 and blogdown version 0.21.80.   

## Step 1: Import your publications

The first step is to import your publications from your reference manager to your `content\publication` folder. Currently, there is no tool in blogdown to help with this, so I used the Python-based [Academic CLI](https://github.com/wowchemy/hugo-academic-cli) tool described in the [Wowchemy documentation](https://wowchemy.com/docs/content/publications/). Conveniently, you can opt to install an earlier version of the tool if you don't want to run it through Hugo in Python.  

## Step 2: Dress up your publications

Now you can go to the `publication` folder and edit the individual publications. You can edit the basic info in the `index.md` file such as the title, author or publication type and add links to relevant external or local content such as a .pdf, appendix or replication materials. Hugo offers some standard links such as `url_pdf` and `url_code`, but you can also include custom links. Here is an example: 

```
---
title: "Fast Fashion or Clean Clothes? Estimating the Value of Labor Standards"
date: 2021-01-28
publishDate: 2021-01-05T20:13:52.623034Z
authors: ["Emmanuel Teitelbaum", "Aparna Ravi"]
publication_types: ["3"]
abstract: "We test the relative strength of consumer preferences for internationally recognized labor rights with a series of conjoint experiments embedded in a survey of more than 2,000 U.S. consumers. We employ a Bayesian approach to estimate consumer demand for ethically-made garments and to simulate how that demand translates into increased profits for apparel firms. We find that reported labor rights violations reduce expected profits while advertising respect for various labor standards through ethical labels and certifications tends to boost them. But the profits flowing from simple labeling initiatives are limited by the ability of other firms to adopt similar advertising campaigns. Since respect for labor rights cannot be patented, corporate social responsibility initiatives may only prove valuable for a handful of first-movers that can incorporate worker protections as a core element of their brand strategy. Our findings have important implications for debates regarding the effectiveness of private governance initiatives."
featured: true
publication: "Working Paper"
url_pdf: "pdf/teitelbaum_ravi.pdf"
links: 
- name: Online Appendix
  url: pdf/supplemental_information.pdf
---
```

Another nice touch is to add a `featured.jpg` by including it in the publication's folder. This can be a picture of your book cover, the cover of the journal where you published your article or some other related image. You can also set it up so that the image only appears in the preview on the homepage, and not after you click on the publication, like this: 

```
image: 
  preview only: true  
```

## Step 3: Use "featured" widgets to set up separate sections

You can make creative use of the "featured" widgets to set up separate sections for your publications. In my case I wanted a section for books, one for journal articles and one for working papers. 

In the `content\home` folder, I made a copy of `featured.md` and named it `working-papers.md`. I then renamed the original `featured.md` to `books.md`.  

From there, I opened `books.md`, set `weight:` to `20`, changed the `title:` to `Book` and set `filters: publication_type:` to `"5"`. 

Next, I opened the new `working-papers.md` file, set `weight:` to `30`, changed `title:` to `Working Papers` and set `filters: publication_type:` to  `"3"`.

Then I renamed `publications.md` to `articles.md`, opened the file, set `weight:` to `25`, `title:` to  `Journal Articles` and set `exclude_featured:` to `true`. This ensures that the books and working papers that I want to include in the "featured" widgets do not also appear in my "Journal Articles" section. 

Finally, I set `featured:` to `true` in the `index.md` files for my book and working papers in `content\publication` to populate the new "Book" and "Working Papers" featured widgets. 

This gives me three consecutive sections listing my book, journal articles and working papers. 

## Step 4: Add more publications

The easiest way to add new publications is to use the Academic CLI tool discussed in step one and a new `.bib` file.

Theoretically, there should also be a way to generate a new publication directly in R Markdown using the `blogdown::hugo::new_content` wrapper, but I have not figured out how to make it work. I have posted [a query](https://stackoverflow.com/questions/66057149/how-to-add-a-new-publication-to-a-blogdown-academic-themed-website) about this on stack overflow in case anyone has a clue.  

<script src="https://utteranc.es/client.js"
        repo="eteitelbaum/academic-website"
        issue-term="pathname"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>
