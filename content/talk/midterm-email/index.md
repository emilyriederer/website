---
title: "Scaling Personalized Volunteer Emails"
event: Data for Progress Data Engineering Open Mic
location: Data for Progress Data Engineering Open Mic

summary: An overview of the data stack used to automate over 50,000 personalized emails to voter turnout volunteers using BigQuery, dbt, Census, and MailChimp

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
date: "2023-06-21T11:00:00Z"
all_day: false

# Schedule page publish date (NOT talk date).
publishDate: "2017-01-01T00:00:00Z"

authors: []
tags: []

# Is this a featured talk? (true/false)
featured: false

image:
  caption: 'Data pipeline'
  focal_point: Right

links:
- icon: twitter
  icon_pack: fab
  name: Follow
url_video: ""
url_slides: "slides.pdf"

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []
---

In this four-minute lightning talk, I explain how Two Million Texans used components of our existing data stack to provide personalized success metrics and action recommendations to over 5,000 volunteers in the lead up to the 2022 midterm elections. I briefly describe our pipeline and how we frontloaded key computational steps in BigQuery to circumvent limitations of downstream tools.
