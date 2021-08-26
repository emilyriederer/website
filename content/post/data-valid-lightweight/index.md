---
output: hugodown::md_document
title: "A lightweight data validation ecosystem with R, GitHub, and Slack"
subtitle: ""
summary: "A right-sized solution to automated data monitoring, alerting, and reporting using R (`pointblank`, `projmgr`), GitHub (Actions, Pages, issues), and Slack"
authors: []
tags: [rstats, data]
categories: [rstats, data]
date: 2021-08-26
lastmod: 2021-08-26
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
rmd_hash: af52dc689124d2ac

---

Data quality monitoring is an essential part of any data analysis or business intelligence workflow. As such, an increasing number of promising tools[^1] have emerged as part of the [Modern Data Stack](https://moderndatastack.xyz/) to offer better orchestration, testing, and reporting.

Although I'm very excited about the developments in this space, I realize that emerging products may not be the best fit for every organization. Enterprise tools can be financial costly, and, more broadly, even free and open-source offerings bring costs in the time and risks associated with vetting tools for security, training associates, and committing to potential lock-in of building workflows around these tools. Additionally, data end-users may not always have the ability to get far enough "upstream" in the production process of their data to make these tools make sense.

"Right-sizing" technology to the problem at hand is a critical task. A "best" solution with the most polished, professional, exciting product isn't always the best *fit* for your needs. Trade-offs must be made between feature completeness and fit-for-purpose. In other words, sometimes its more important for technology to be *"good enough"*.[^2]

With that in mind, in this post I explore a lightweight approach to a data quality workflow using a minimal set of tools that are likely already part of many team's data stacks: R, GitHub, and Slack. This approach may be far from perfect, but I believe it provides a lot of "bang for the buck" by enabling scheduling data quality monitoring, instantaneous alerting, and workflow management at little-to-no incremental overhead.

The full code for this demo is available in my [emilyriederer/data-validation-demo](https://github.com/emilyriederer/data-validation-demo) repo on GitHub.

Overall Workflow
----------------

To think about right-sizing, it's first useful to think about what features from some of the "hot" data quality monitoring products make them so appealing. Some

The basic idea of this workflow is to recreate as many of these strengths as possibly by maximally leveraging the strengths of existing tools:

-   **R**:
    -   Handles data validation with the excellent [`pointblank` package](https://rich-iannone.github.io/pointblank/). Validation steps can either be done directly or "outsourced" upstream to run in-place in a database (if that is where your data lives)
    -   Posts error detected in validation to GitHub issues via the [`projmgr` package](https://emilyriederer.github.io/projmgr/)
-   **GitHub**: Serves as the central nervous system for execution, project management, and reporting
    -   **Actions**: Reruns the `pointblank` checks on a regular basis and updates an RMarkdown-based website
    -   **Pages**: Hosts the resultings RMarkdown-generated HTML for accessible data quality reporting
    -   **Issues**: Record data quality errors caught by `pointblank`. This provides an easy platform to assign owners, discuss issues, and track progress. With detailed labels, closed issues can also serve as a way to catalog past errors and identify trends or needed areas of improvement (where repeat failures occur)
-   **Slack**: Integrates with GitHub to provide alerts on new issues on a Slack channel. Individual teams or team members can use Slack's controls to determine how they receive notifications (e.g. email, mobile notification, etc.) for time-sensitive issues

Intrigued? Next we'll step through the technical details.

Detailed Implementation
-----------------------

[^1]: Just to name a few: dbt, datafold, Soda, Great Expectations, and Monte Carlo

[^2]: With love and admiration, I borrow this phrase from the excellent paper "Good Enough Practices in Scientific Computing": <a href="https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005510" class="uri">https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005510</a>

