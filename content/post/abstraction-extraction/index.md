---
output: hugodown::md_document
title: "The Art of Abstraction in ETL: Dodging Data Extraction Errors"
subtitle: ""
summary: "Cross-post from guest post on Airbyte's developer blog"
authors: []
tags: [data, workflow]
categories: [data, workflow]
date: 2023-03-22
lastmod: 2023-03-22
featured: false
draft: false
aliases:

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: ""
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: d46421c378c21396

---

Whenever I think about data developer tooling, I always like to take the perspectives of:

1.  Understanding what higher-level abstractions that it provides that help eliminate rote work or reduce mental overhead for data teams. In the spirit of [my post on the jobs-to-be-done of innersource analysis tools](/post/team-of-packages/), this can be framed as what 'jobs' that tool can be hired to do (and with what level of responsibility and autonomy)
2.  Interrogating the likely failure modes in the data stack based on the mechanics of the system, in the spirit of my [call for hypothesis-driven data quality testing](/post/grouping-data-quality/)

These two themes motivated my recent guest post for Airbyte's developer blog on [The Art of Abstraction in ETL: Dodging Data Extraction Errors](https://airbyte.com/blog/dodging-data-extraction-errors). In this post, I argue:

> Cooking a meal versus grocery shopping. Interior decorating versus loading the moving van. Transformation versus Extract-Load. It's human nature to get excited by flashy outcomes and, consequently, the most proximate processes that evidently created them.

> This pattern repeats in the data world. Conferences, blog posts, corporate roadmaps, and even budgets focus on data transformation and the allure of "business insights" that might follow. The steps to extract and load data are sometimes discounted as a trivial exercise of scripting and scheduling a few API calls.

> However, the elegance of Extract-Load is not just the outcome but the execution -- the art of things not going wrong. Just as interior decorating cannot salvage a painting damaged in transit or a carefully planned menu cannot be prepared if half of the ingredients are out-of-stock, the Extract-Load steps of data processing have countless pitfalls which can sideline data teams from their ambitious agendas and aspirations.

I then go on to explore common challenges in successfully extracting data from an API and the abstractions that can aid in this process.

Please check out the full post on Airbyte's site! I hope it resonates.
