---
output: hugodown::md_document
title: "Industry information management for causal inference"
subtitle: ""
summary: "Proactive collection of data to comply or confront assumptions"
authors: []
tags: [causal, data]
categories: [causal, data]
date: 2023-05-30
lastmod: 2023-05-30
featured: false
draft: false
aliases:

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "Data strategy motivated by causal methods"
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: ef233b054b038932

---

*This post summarizes the final third of my talk at Data Science Salon NYC in June 2023. Please see the [talk details](/talk/causal-design-patterns) for more content.*

## Why industry needs causal inference

![](why-not-experiment.png)

Industry data science tends to highly value the role of A/B testing and experimentation. However, there are many situations where experimentation is not an optimal approach to learning. Experiments can be infeasible if we worry about the ethics or reputational risk of offering disparate customer treatments; they may be impractical in situations that are hard to randomize or avoid spillover effects; they can be costly to run and configure either in direct or opportunity costs; and, finally, they can just be *slow* if we wish to measure complex and long-term impacts on customer behaviors (e.g. retention, lifetime value).

## What causal methods require

![](patterns-and-variation.png)

These limitations are one of the reasons why observational causal inference is gaining increasing popularity in industry. Methods of observational causal inference allows us to estimate treatment effects without randomized controlled experimentation by using existing historical data. At the highest level, these methods work by replacing *randomization* with strategies to exploit other forms of *semi-random variation* in historical exposures of a population to a treatment. Since this semi-random *variation* could be susceptible to confounding, observational methods supplement variation with *additional data* to control for other observable sources of bias in our estimates and *contextual assumptions* about the data generating process.

My previous post on [causal design patterns](/post/causal-design-patterns) outlines a number of foundational causal methods, but I'll briefly recap to emphasize the different ways that sources of variation, data, and context are used:

-   **Stratification and Inverse Propensity Score Weighting**:
    -   Exploits "similar" populations of treated and untreated individuals
    -   Assumes we can observe and control for common causes of the treatment and the outcome
-   **Regression Discontinuity**:
    -   Exploits a sharp, semi-arbitrary cut-off between treated and untreated individuals
    -   Assumes that the outcome is continuous with respect to the assigment variable and the assignment mechanism is unknown to individuals (to avoid self-selection)
-   **Difference in Differences**:
    -   Exploits variation between *behavior over time* of treated and untreated *groups*
    -   Assumes that the treatment assignment is unrelated to expected future outcomes and that the treatment is well-isolated to the treatment group

## Industry's unique advantages deploying causal inference

![](industry-advantages.png)

## Data management for causal inference

![](featured.png)

