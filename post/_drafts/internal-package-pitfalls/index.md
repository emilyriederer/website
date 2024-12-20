---
output: hugodown::md_document
title: "Internal Tools Pitfalls"
subtitle: ""
summary: "What they (me) never told you about building interal tools"
authors: []
tags: [rstats, pkgdev, workflow]
categories: [rstats, pkgdev, workflow]
date: 2022-08-14
lastmod: 2022-08-14
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
rmd_hash: 9c000a16b85b846a

---

Since releasing my first R package at Capital One in 2017, it's been no secret that I have been a proponent of internal tooling. I've espoused the benefits in numerous talks on [specific packages](/talk/tidycf/), [tactics](/talk/ent-pkg-design/), and [guiding principles](/talk/organization/).

I'm still a firm believe in the value of custom-built tools shaped for the enterprise. However, my perspective has become more nuanced and sometimes skeptical. In this post, I offer the rebuttal to my own many odes to the value of internal tools -- not to discourage their creation but to help developers better navigate pitfalls and anticipate pitfalls.

## The idealistic model

In theory, the best internal tools can create value in many different ways.

## It's not actually like open source

Unfortunately, innersource rarely delivers on this vision of open-source. In particular, there are unique challenge to driving user adoption and providing support.

-   **The users are different:**
    -   Open-source users self-select into using tools that meet their use cases and preferences. Enterprise users may be compelled to use tools for which they lack passion or related skills (e.g. a toolkit not written in their favorite language or framework)
    -   Some users may also reasonably resist using homegrown tools that leave them with less knowledge rather than learning the underlying open-source rails that will be most attractive on a resume
-   **The community is different:** Open-source communities form around popular tools and leave valuable "breadcrumbs" in GitHub issues, StackOverflow questions, blogpost, and derivative work. These resources provide both marketing and use-case specific documentation for projects.
-   **The incentives are different:**
    -   Credit is the currency of open-source. Contributors may come for a personal desire to make tools better or to elevate their profile within a community. However, currency is the currency of organizations, and many in those that are likely to be renumerated by delivering on short-term, project-based wins for their teams rather than investing in harder-to-quantify long-haul investments
    -   Alternatively, when tool-building *is* seen as high-value work for driving scale, those incentives also distort the internal "market" and incentive multiple teams to create their own competing stacks, thus diminishing much of the benefits

### It's actually too much like open source

Almost more problematic than the ways innersource fails to act like open-source are the ways that it succeeds As open-source *users*, we have more exposure to the most popular projects and a biased view of the "typical case". We then look to innersource to deliver the *fantasy* of open-source than the reality.

Nadia Eghbal's excellent book [Working in Public](https://www.amazon.com/Working-Public-Making-Maintenance-Software/dp/0578675862) details the different modes that open source projects can take based on relative growth of users and contributors. She breaks these down as:

-   **Federations** (High Contributor Growth, High User Growth)
-   **Clubs** (High Contributor Growth, Low User Growth)
-   **Stadiums** (Low Contributor Growth, High User Growth)
-   **Toys** (Low Contributor Growth, Low User Growth)

We might dream of being the next Federation or Club when grassroots innersource efforts are much more likely (as are the overwhelming majority of open-source projects) to be Stadiums or Toys. With this comes many typical problems that are accentuated but not created by the enterprise setting:

-   **Maintainer burnout is real:** Engaged users make a lot of requests while few contributors raise their hands to help. This is exacerbated by the fact that innersource users may claim that the issue they raise is a blocker to some critical business value.
-   **The "bus factor" is accentuated:** A paucity of contributors means innersource projects have a low ["bus factor"](https://en.wikipedia.org/wiki/Bus_factor), or a high level of dependence on few people. This is exacerbated by the fact that the proverbial "bus" for innersource is not just a maintainer's disengagement (or demise) but their leaving the organization or moving under management with different priorities
-   **Dependencies are high risk:** Taking on open-source dependencies requires trust and introduces risk, should those dependencies be deprecated or subjected to breaking changes. Within an organization, frequent priority changes can make either of these scenarios more common with less likelihood that some "hero" from the community steps in to fill the gap

### By definition, the results are not open source

## Organizational challenges

## Making it work

Innersource is inherently appealing because it *feels* like we should be able to seek out all the benefits of open-source while dodging its costs. Just imagine: individuals aligned on an organization's shared goals coming together to develop shared and reusable software.

While I'm still a firm believe in the value of internal tooling, my perspective has become increasingly less pollyannaish over time.

what I used to think

think you get all of the benefits and none of the challenges + community, efficiency + funding!

you're probably have wrong view of open source + survivor bias + diff models (book)

it still won't be like open-source (culturally) + funding means different incentives + no positive selection + priotization (aeon) + bus problem exacerbated for long-term ownership

by definition, it's also *not* open source + no docs, stack overflow, etc. + bigger learning curve + less value additive skills

how to make it work + be ruthless about what does and doesn't make sense (drob tweet) + avoid design antipatterns + be critical + bravely do the boring stuff

all of the problems of open source (maintainer burnout, lone wolfs, etc)

all of the problems of organizations (centralized coordination, buy-in, adoptions)

