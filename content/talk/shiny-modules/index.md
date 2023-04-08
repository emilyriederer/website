---
title: "Taking Flight with Shiny: a Modules-First Approach"
event: Appsilon ShinyConf 2023
location: Appsilon ShinyConf 2023

summary: An argument for the individual and organization-wiide benefits of teaching new developers Shiny with a modules-first paradigm

# Talk start and end times.
#   End time can optionally be hidden by prefixing the line with `#`.
date: "2023-03-15T11:00:00Z"
all_day: false

# Schedule page publish date (NOT talk date).
publishDate: "2017-01-01T00:00:00Z"

authors: []
tags: []

# Is this a featured talk? (true/false)
featured: false

image:
  caption: 'A simple example of a module'
  focal_point: Right

links:
- icon: twitter
  icon_pack: fab
  name: Follow
  url: https://twitter.com/appsilon
url_video: "https://www.youtube.com/watch?v=F6I_jXPWFBk&list=PLexAKolMzPcriOdeLwoMxQOyHRnMguEv4"
url_slides: "slides.pdf"

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []
---

R users are increasingly trained to develop with good principles such as writing modular functions, testing their code, and decomposing long individual scripts into R projects. In recent years, such approaches have crept earlier into introductory R education with the realization that applying best practices is not an advanced skill but rather empowers beginners with a more robust structure. 

However, new Shiny developers are confronted with two challenges: they must simultaneously learn new packages and concepts (like reactivity) which introductory tutorials demonstrate how to write their apps as single scripts. This means small changes are harder to test and debug for the groups that need it the most. Although Shiny modules offer a solution to this exact problem, they are regarded as an advanced topic and often not encountered until much later in a developer’s journey.

In this talk, I will demonstrate a workflow to encourage the use of modules for newer Shiny users. I argue that a ‘module-first’ approach helps to decompose design into more tangible, bite-sized, and testable components and prevent the code sprawl that makes Shiny feel intimidating. Further, this approach can be even more powerful when developing Shiny applications in the enterprise setting and onboarding new team members to existing applications.


This talk is based on by related [blog post](content/post/shiny-modules). 

