---
title: "tidycf: Turning analysis on its head by turning cashflows on their side"
event: rstudio::conf(2018)
event_url: https://rstudio.com/resources/rstudioconf-2018/

location: rstudio::conf(2018) | EARL Boston | RLadies Chicago
address:
  city: San Diego
  region: CA
  country: United States

summary: An overview of how the tidycf R package led to process and cultural change at Capital One

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
date: "2018-01-31T11:00:00Z"
all_day: false

# Schedule page publish date (NOT talk date).
publishDate: "2017-01-01T00:00:00Z"

authors: []
tags: []

# Is this a featured talk? (true/false)
featured: false

image:
  caption: 'Image credit: [**Unsplash**](https://unsplash.com/photos/bzdhc5b3Bxs)'
  focal_point: Right

links:
- icon: twitter
  icon_pack: fab
  name: Follow
  url: https://twitter.com/rstudio
url_slides: "https://www.slideshare.net/EmilyRiederer/tidycf-turning-cashflows-on-their-sides-to-turn-analysis-on-its-head"
url_video: "https://rstudio.com/resources/rstudioconf-2018/tidycf-turning-analysis-on-its-head-by-turning-cashflows-on-their-sides/"
---

Statistical computing has revolutionized predictive modeling, but financial modeling lags in innovation. At Capital One, valuations analysis required legacy SAS platforms, obscure data lineage, and cumbersome Excel cashflow statements. This talk describes development of the tidycf R package to reinvent this process as a seamless, end-to-end workflow.

Reimagining cashflow statements as tidy data facilitates a simple, efficient, and transparent workflow while incorporating more statistically rigorous methods. tidycf leverage the full power of R and RStudio – building on top of the tidyverse; reducing complex crunching, wrangling, and visualization to pipeable functions; guiding analysis and documentation with RMarkdown templates; and incorporating features of the latest development version IDE. Altogether, this delivers a good user experience without the overheard of maintaining a custom GUI.

The resulting package goes beyond “getting stuff done”. tidycf also increases quality, reproducibility, and creativity of analysis; ensures consistency and knowledge transfer; reduces the burdens of documentation and regulation; and speeds innovation and time-to-market – all while guiding less-technical analysts through an immersive crash course to R and the tidyverse.
