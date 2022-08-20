---
title: "Operationalizing Column-Name Contracts with dbtplyr"
event: Coalesce 2021 by dbt Labs

location: Virtual

summary: An exploration of how data producers and consumers can use column names as interfaces, configuations, and code to improve data quality and discoverability. The second half of the talk demonstrates how to implement these ideas with my `dbtplyr` dbt package.

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
date: "2021-12-13T11:00:00Z"
all_day: false

# Schedule page publish date (NOT talk date).
publishDate: "2021-12-13T00:00:00Z"

authors: []
tags: []

# Is this a featured talk? (true/false)
featured: false

image:
  caption: 'A visualization of data fields named with a controlled vocabulary'
  focal_point: Right

links:
- icon: twitter
  icon_pack: fab
  name: Follow
  url: https://www.getdbt.com/coalesce-2021/operationalizing-columnname-contracts-with-dbtplyr/
url_video: "https://www.getdbt.com/coalesce-2021/operationalizing-columnname-contracts-with-dbtplyr/"
url_slides: "slides.pdf"

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects:
- dbtplyr
---

Complex software systems make performance guarantees through documentation and unit tests, and they communicate these to users with conscientious interface design.

However, published data tables exist in a gray area; they are static enough not to be considered a “service” or “software”, yet too raw to earn attentive user interface design. This ambiguity creates a disconnect between data producers and consumers and poses a risk for analytical correctness and reproducibility.

In this talk, I will explain how controlled vocabularies can be used to form contracts between data producers and data consumers. Explicitly embedding meaning in each component of variable names is a low-tech and low-friction approach which builds a shared understanding of how each field in the dataset is intended to work.

Doing so can offload the burden of data producers by facilitating automated data validation and metadata management. At the same time, data consumers benefit by a reduction in the cognitive load to remember names, a deeper understanding of variable encoding, and opportunities to more efficiently analyze the resulting dataset. After discussing the theory of controlled vocabulary column-naming and related workflows, I will illustrate these ideas with a demonstration of the {dbtplyr} dbt package which helps analytics engineers get the most value from controlled vocabularies by making it easier to effectively exploit column naming structures while coding.
