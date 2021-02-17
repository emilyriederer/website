---
title: "Column Names as Contracts"
event: Data Workshop on Reproducibility (Univ Toronto) | Good Tech Fest (Chicago)

location: University of Toronto | Chicago

summary: Exploring the benefits of using controlled vocabularies to organize data and introducing the `convo` R package

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
date: "2021-02-25T11:00:00Z"
all_day: false

# Schedule page publish date (NOT talk date).
publishDate: "2017-01-01T00:00:00Z"

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
  url: https://twitter.com/RohanAlexander
url_video: ""

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects:
- convo
---

Complex software systems make performance guarantees through documentation and unit tests, and they communicate these to users with conscientious interface design. However, published data tables exist in a gray area; they are static enough not to be considered a “service” or “software”, yet too raw to earn attentive user interface design. This ambiguity creates a disconnect between data producers and consumers and poses a risk for analytical correctness and reproducibility. 

In this talk, I will explain how controlled vocabularies can be used to form contracts between data producers and data consumers. Explicitly embedding meaning in each component of variable names is a low-tech and low-friction approach which builds a shared understanding of how each field in the dataset is intended to work. 

Doing so can offload the burden of data producers by facilitating automated data validation and metadata management. At the same time, data consumers benefit by a reduction in the cognitive load to remember names, a deeper understanding of variable encoding, and opportunities to more efficiently analyze the resulting dataset. 

After discussing the theory of controlled vocabulary column-naming and related workflows, I will illustrate these ideas with a demonstration of the `convo` R package, which aids in the creation, upkeep, and application of controlled vocabularies.

This talk is based on by related [blog post](content/post/column-name-contracts) and [R package](content/project/convo). 

