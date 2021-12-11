---
output: hugodown::md_document
title: "How to Make R Markdown Snow"
subtitle: ""
summary: "Much like ice sculpting, using powertools to do frivolous things"
authors: []
tags: [rstats]
categories: [rstarts]
date: 2021-12-11
lastmod: 2021-12-11
featured: false
draft: false
aliases:

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ""
  focal_point: ""
  preview_only: true

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: 82ba8ea427c598dd

---

Full project: <a href="https://github.com/emilyriederer/demo-rmd-snow" class="uri">https://github.com/emilyriederer/demo-rmd-snow</a>

![](featured.gif)

<blockquote class="twitter-tweet">
<p lang="en" dir="ltr">
No one:<br><br>Absolutely no one:<br><br>Me: SO, I know we can\'t have a holiday party this year, but we CAN make our <a href="https://twitter.com/hashtag/rstats?src=hash&amp;ref_src=twsrc%5Etfw">\#rstats</a> R Markdown reports snow before we send them to each other <a href="https://t.co/SSBzlgb3TV">https://t.co/SSBzlgb3TV</a><br>HT to <a href="https://t.co/c7c5c5csMK">https://t.co/c7c5c5csMK</a> for the heavy lifting <a href="https://t.co/hIu7z0knR4">pic.twitter.com/hIu7z0knR4</a>
</p>
--- Emily Riederer (@EmilyRiederer) <a href="https://twitter.com/EmilyRiederer/status/1337178684868980738?ref_src=twsrc%5Etfw">December 10, 2020</a>
</blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

-   **Using child documents...** to add snowflake
-   **Includig custom CSS style...** to animate them
-   **Evaluating chunks conditionally...** to keep things timely

We will see how to dress up this [very important business R Markdown](https://github.com/emilyriederer/demo-rmd-snow/blob/main/index.Rmd)

Much more useful applications of these same features are discussed in the linked sections of the [R Markdown Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/).

Child documents
---------------

[Child documents](https://bookdown.org/yihui/rmarkdown-cookbook/child-document.html)

Adding CSS style sheets
-----------------------

[Adding CSS to R Markdown](https://bookdown.org/yihui/rmarkdown-cookbook/html-css.html)

For more tips on writing CSS for R Markown, check out my [post]() on finding the right selectors.

Conditional chunk evaluation
----------------------------

[Chunk options](https://yihui.org/knitr/options/)

[Using variables in chunk options](https://bookdown.org/yihui/rmarkdown-cookbook/chunk-variable.html)

If we had chosen not to use child documents, we could also use chunks to achieve conditional evaluation using the [`asis` engine](https://bookdown.org/yihui/rmarkdown-cookbook/eng-asis.html).

