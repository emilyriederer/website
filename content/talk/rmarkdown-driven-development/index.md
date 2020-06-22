---
title: RMarkdown Driven Development
event: rstudio::conf(2020)
event_url: https://rstudio.com/resources/rstudioconf-2020/

location: rstudio::conf(2020) | csv,conf,v5
address:
  city: San Francisco
  region: CA
  country: United States
  
summary: How and why to refactor one time analyses in RMarkdown into sustainable data products

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
date: "2020-01-30T11:00:00"
all_day: false

authors: []
tags: [rmarkdown]

# Is this a featured talk? (true/false)
featured: false

image:
  caption: 'A step in the RmdDD process'
  focal_point: Right

links:
- icon: twitter
  icon_pack: fab
  name: Follow
  url: https://twitter.com/rstudio
url_code: ""
url_pdf: ""
url_slides: "https://www.slideshare.net/EmilyRiederer/rmarkdown-driven-development-rstudioconf-2020"
url_video: "https://rstudio.com/resources/rstudioconf-2020/rmarkdown-driven-development/"
---

{{% alert note %}}
This talk was presented both at rstudio::conf(2020) and csv,conf,v5. The video embedded below is from the latter.
{{% /alert %}}

RMarkdown enables analysts to engage with code interactively, embrace literate programming, and rapidly produce a wide variety of high-quality data products such as documents, emails, dashboards, and websites. However, RMarkdown is less commonly explored and celebrated for the important role it can play in helping R users grow into developers. In this talk, I will provide an overview of RMarkdown Driven Development, a workflow for converting one-off analysis into a well-engineered and well-designed R package with deep empathy for user needs. We will explore how the methodical incorporation of good coding practices such as modularization and testing naturally evolves a single-file RMarkdown into an R project or package. Along the way, we will discuss big-picture questions like “optimal stopping” (why some data products are better left as single files or projects) and concrete details such as the {here} and {testthat} packages which can provide step-change improvements to project sustainability.

{{<youtube Z9qk5YnuBQM>}}


