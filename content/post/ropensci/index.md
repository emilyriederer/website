---
output: hugodown::md_document
title: "Notes on leadership lessons from rOpenSci"
subtitle: ""
summary: "Building structures for success, defining clear roles, and knowing your priorities"
authors: []
tags: [rstats, notes]
categories: [rstats, notes]
date: 2021-12-08
lastmod: 2021-12-08
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
rmd_hash: 8be45679093cfcda

---

In October, I was delighted to join the [rOpenSci editorial board](https://ropensci.org/blog/2021/10/12/editors2021/). [rOpenSci](https://ropensci.org/about/) provides infrastructure, processes, and community to support the development and maintenance of open source scientific software (R packages). The centerpiece of their efforts is the robust [Software Peer Review](https://ropensci.org/software-review/) program which provides a "transparent, constructive, non adversarial and open review process" with the help of volunteer reviewers (as documented in the excellent book [rOpenSci Packages: Development, Maintenance, and Peer Review](https://devguide.ropensci.org/)).

Beyond my belief in its mission, the sheer success of rOpenSci fascinated me from the moment I first learned of it. The prevalence of volunteer work in open source and open science poses unique constraints. First, incentives need to be created by building a shared sense of purpose instead of traditional compensation. Next, operations must be lean and reliable so participants trust that their time-bounded contributions will make a difference. Motivation and efficiency are undeniable goods, but industry can sometimes suffer from an embarrassment of riches which pulls these out of the spotlight. rOpenSci's ability to lead and mobilize without formal power and to deploy volunteers so effectively was intriguing.

Upon joining the editorial team, I wrote a few words for the rOpenSci blog attempting to describe what the organization meant to me:

> I had the great fortune of stumbling upon rOpenSci relatively early in my career as an R programmer, and it's not an exaggeration to say that this organization has had one of the single largest impacts on my career. rOpenSci's meticulous documentation helped me to embrace best practices in my development work. Perhaps even more impactful is how watching rOpenSci work shaped my perspective on community building, leadership, and teamwork. I have always admired the well-oiled machine that rOpenSci has created -- sustaining massive value with limited individual overhead by clearly defining expectations, providing opinionated infrastructure, and cultivating a phenomenal community. I'm thrilled to be taking a formal role in an organization that has had such an impact on me.

In this post, I want to expand three observations about watching rOpenSci work which have influenced my own philosophy of what constitutes good management and leadership[^1]:

-   building structures for people to succeed
-   defining clear roles and responsibilities
-   knowing your value stack to avoid micromanaging

The exact way these principles are instrumented will vary, but rOpenSci serves as a potent case study of what can be achieved when you get them right.

Building structures for success
-------------------------------

Human language is ambiguous. Too many projects go off couse when collaborators understand the same words differently. We can talk about relatively foundational concepts like "code quality" or "file structure" or "good documentation" all day long, but the physical manifestations of those things could look very different to you and I. This ambiguity can create chaos when you try to coordinate contributions from many individuals' definitions to form a coherent result.

Put more simply **standards drive innovation** and have good standards and the right layer of abstraction is critical to success. R package development already benefits by the extent to which standards are already built-in. R packages are defined by a highly prescriptive file structure that eliminate uncertainty around how to save artifacts, and automated package checks provide a lower bound for package quality. However, rOpenSci goes much further. Every step of the review process includes extremely thoughtful and well-defined processes and expectations.

Processes, however, are only as effective as their adoption. For this, **adherence is made easy through the savvy usage of checklists, templates, and automation** to operationalize these processes. These tools serve two purposes: they disambiguate the desired outcomes and eliminate unnecessary effort in delivering those outcomes.

Wherever possible, templates help participants effectively communicate and share information effectively, such as the [GitHub issue templates](https://github.com/ropensci/software-review/issues/new/choose) to initiative a software review or pre-submission inquiry. Similarly, the amazing [review bot](https://ropensci.org/commcalls/dec2021-automation/) "automates the busywork" of running automated checks (but, unlike a traditional CI tool, deferring the review of subjective test results to the author, editor, and reviewer to interpret) and manages rote processes like tagging reviewers, updating the review database, and changing GitHub issue labels that denote progress of a software review.

Beyond rOpenSci, a good organization can create structures for success with dependable ceremonies and well-defined processes supported by good templates and tools. For example, Caitlin Hudon wrote about how her data team uses a standard [data intake form](https://caitlinhudon.com/2020/09/16/data-intake-form/) to collect and prioritize requests from the business. In turn, this has driven a lot of my person interest in [enterprise analytical tooling](https://emilyriederer.netlify.app/post/team-of-packages/) as a vehicle for delivering a lot of this standardization and automation inside an organization.

Defining clear roles and responsibilities
-----------------------------------------

These clearly defined expectations are especially critical since rOpenSci marshals such a vast number of people. 18 new packages have been approved so far in 2021, and each requires interaction from at least five people[^2] Altogether, that's easily over 100 people in the course of a year contributing discrete bursts of energy and attention in our incredibly noisy and distracting world.

In some settings, this could be the recipe for utter chaos. However, rOpenSci makes it **easy to commit** with clear, time-boxed opportunities and **easy to deliver** with clear guides for authors, editors, and reviewers in their [book](https://devguide.ropensci.org/index.html).

These chapters help each party understand very clearly what is expected of them by providing guidelines, resources (e.g. relevant tolls and packages), and tip and examples from past experiences (thanks to the transparency of the open review process). Together they help first-timers **onboard easily** to perform any of the roles with minimal manual training and intervention (but, I cannot emphasize enough, supported by an excellent and welcoming community if they have questions), **keep up with changes** by serving as a single-source-of-truth and living documentation for evolving best practices, and **continually raise the bar** by capturing tribal knowledge and passing best practices to future performers.

Such definitions also help ensure that you **find the right opportunities for the right people**. rOpenSci organizes volunteer reviewers in an AirTable database which is searchable by different domains and areas of expertise. Its easier to trust people to succeed when you know precisely what's asked of them, and similarly its easier for volunteers to *believe* that they can succeed when they understand how their skills map to the problem at hand. When I first applied to be a reviewer, I was not even sure if I was qualified since I lack scientific domain expertise. However, my first package review request (from Maëlle) gave me confidence by explaining what in my profile made me well-suited for the job at hand.

Similarly, I would argue that the clarity of thought in terms of what is required also has helped enable the "structures for success" that I discuss above. The better that tasks are understood, it is easier to build decision-support tools with the right level of abstraction that facilitate instead of impeding human judgment.

Finally, a less obvious benefit of these definitions is also the way that they **avoid conflict**. By explicitly defining what each role *is*, it is implicitly defined what each role *is not*. As an editor, I know I should be focusing on different things than when I was a reviewer, which puts both my and reviewers time to best use and **avoids duplicate effort or conflicting feedback** to authors.

Beyond rOpenSci, clear role definitions similarly help ensure that the right work gets done (exactly once -- not zero times, not three times), to empower people to step up to a new challenge, and to take more ownership of their own lane by understanding the bounds of their "sandbox" to play in.

Knowing your value stack
------------------------

Finally, rOpenSci helps editors, reviewers, and authors weigh priorities correctly in order to **balance quality and practicality**.

There is no *requirement* to submit to rOpenSci, so the organization leads with influence and a shared sense of purpose as opposed to any formal type of power. However, this also suggests that there is some theoretical balance or tipping point wherein if the requirements of rOpenSci became too great (in terms of time, effort, or creative constraints), package developers would not submit to the review process and the whole effort would fall apart.

This highlight a contrast with my previous praise of standards: adding too many standards or requirements can scare people away. rOpenSci gracefully balances this line as well by helping editors and reviewers understand their place, priortize advocating for changes or updates that *really* matter, but not forcing authors to defer to some third party's internal definition of what's "good". (And providing them an excellent, secure forum to discuss on its Slack channel). Ultimately, this helps **give individuals autonomy and creative control** while still ensuring the collecting success of the credibility of rOpenSci's corpus of packages.

For example, in my first review with rOpenSci, I differed in perspective from the author on the need for certain package dependencies. I was able to share my suggestions, allow him to take or discard what he saw fit, and then confirm with other more experiences reviewers that the package met the bar. Just because the way the author implemented his functionality was not the same way I might have (out of an infinite number of possible options) did not mean it was good or bad or a "make or break" moment for the tool.

Beyond rOpenSci, this skill is incredibly important for leading any sort of a team. Knowing what's nonnegotiable helps you form clearer requests, and acknowledging what is subjective helps avoid micromanagement.

[^1]: Much has been written about the difference between management and leadership. I conflate them a bit here since the lessons I discuss reflect element of both.

[^2]: The editor-in-chief, editor, at least one author, and two reviewers -- not to mention potential discussions among the editors or between editors and other potential reviewers.

