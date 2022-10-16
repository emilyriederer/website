---
title: "Data (error) Generating Process""
event: Airbyte move(data) | CANSII | DataFold Meetup

location: Airbyte move(data) | CANSII | DataFold Meetup

summary: Interrogating the data generating process to devise better data quality tests.

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
date: "2022-11-10T11:00:00Z"
all_day: false

# Schedule page publish date (NOT talk date).
publishDate: "2017-01-01T00:00:00Z"

authors: []
tags: []

# Is this a featured talk? (true/false)
featured: false

image:
  caption: 'Different forms of missingness'
  focal_point: Right

links:
url_video: ""
url_slides: "slides.pdf"

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
---

Statisticians often approach probabilistic modeling by first understanding the conceptual data generating process. However, when validating messy real-world data, the technical aspects of the data generating process is largely ignored.

In this talk, I will argue the case for developing more semantically meaningful and well-curated data tests by incorporating both conceptual and technical aspects of "how the data gets made".

To illustrate these concepts, we will explore the NYC subway rides open dataset to see how the simple act of reasoning about real-world events their collection through ETL processes can help craft far more sensitive and expressive data quality checks. I will also illustrate instrumenting such checks based on new features in the dbt-utils package (pending approval of a PR that I recently authored).

Audience members should leave this talk with a clear framework in mind for ideating better tests for their own pipelines.
