---
title: "projmgr: Managing the human dependencies of your project"
event: UseR!2020
event_url: https://user2020.r-project.org/

location: UseR!2020
address:
  city:  Virtual - Formerly St. Louis
  region: MO
  country: United States

summary: A lightning talk on key features of the projmgr package

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
date: "2020-07-06T11:00:00Z"
all_day: false

# Schedule page publish date (NOT talk date).
publishDate: "2017-01-01T00:00:00Z"

authors: []
tags: []

# Is this a featured talk? (true/false)
featured: false

image:
  caption: 'A taskboard made with projmgr'
  focal_point: Right

links:
- icon: twitter
  icon_pack: fab
  name: Follow
  url: https://twitter.com/useR2020stl
url_video: ""

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects:
- projmgr
---

Many tools (e.g. git, make, Docker) and R packages (e.g. packrat, renv) aim to eliminate pain and uncertainty from technical project management, resulting in well-engineered software and reproducible research. However, there is no analogous gold standard tool for managing the most time-consuming and unpredictable dependencies in our work: our fellow humans. 

Communication with our collaborators and customers is often spread across email, Slack, GitHub, and sometimes third-party project management tools like Jira or Trello. Switching between these different software tools and frames of mind knocks analysts out of their flow and detracts from getting work done. 

The projmgr R package offers a solution: an opinionated interface for conducting end-to-end project management through GitHub.Key features of this package include bulk generation of GitHub issues and milestones from a YAML project plan and automated creation of status updates with user-friendly text summaries and plots. 

In this lightning talk, I demonstrate the key features of projmgr motivated by a range of use cases including updating stakeholders, monitoring KPIs, managing an analytics team, and organizing a hackathon.
