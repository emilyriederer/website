---
output: hugodown::md_document
title: "Causal design patterns for data analysts"
subtitle: ""
summary: "An informal primer to causal analysis designs and data structures"
authors: []
tags: [causal, analysis, data]
categories: [causal, analysis, data]
date: 2021-02-06
lastmod: 2021-02-06
featured: true
draft: true
aliases:

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "Mnemonic illustrations of CI methods, made with Excalidraw"
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: 7ea7d791ba96d307

---

Software engineers study design patterns[^1] to help them recognize archetypes in the specific problems they are facing, to discuss such challenges with a shared vocabulary, and to reuse tried-and-true paradigms to address these problems.

Statistics also has plenty of examples of prototypical analyses; however, sometimes these frameworks become siloed within a specific field of study (e.g. epidemiology, economics, biostatistics) and clouded in domain-specific language that masks their general applicability[^2]. This can make it hard for practitioners outside of these fields to easily survey, learn, and apply these methods.

Observational causal inference is most definitely one such field. Countless fields have the need to answer causal questions ("Does smoking cause cancer?", "Does protest cause political change?") when a randomized experiment is impossible -- either ethically, financially, temporally, or practically. In such cases, researchers look for alternative ways to construct control groups or a measure of the counterfactual outcome if the treatment had not been put into effect.

In this post, I briefly summarize common cross-disciplinary design patterns for measuring causal effects from observational data. For each, I offer an illustration, summary of the method, explanation of the required data structure and assumptions, and an industry-focused example. Causal inference is very hard and nuanced; doing it well requires a large amount of both statistical and domain expertise. For brevity, I will not attempt to explain all of the technical details in this piece, but I hope that it can be useful to raise awareness so analysts can more readily recognize and further research designs conducive to their data.

Why CI in Industry?
-------------------

Experimentation has become a mainstay of industry, so you might ask why does observational causal inference matter?

-   Some situations you cannot test or even when you can, thinking about observational causal inference methods can help you better identify biases and design your experiments
-   Testing is expensive. There are direct costs (e.g. testing a marketing promotion) of instituting a policy that might not be effective, implementation costs (e.g. having a tech team implement a new display), and opportunity costs (e.g. holding out a control group and not applying what you hope to be a profitable strategy as broadly as possible)
-   Data collection can take time. Sometimes we may want to read long-term endpoints like customer retention or attrition after many year. Working with historical observational data can help get a preliminary answer sooner
-   There are so many questions that you can answer! As we'll see, most all of these methods rely on exploiting some arbitrary amount of randomness in the real world to create quasi-experiments. Industry (and life in general) is full of well-defined yet somewhat arbitrary policies which make it fertile ground for observational causal inference

Stratification
--------------

![](excalidraw-strat.png)

**Approach:**

-   Bin (stratify) the population by subgroups based on values of each observation's covariates
-   Calculate the average treatment effect in each subgroup
-   Take the weighted average of the subgroup effects, weighted for the population of interest (e.g. treatment distribution, control distribution, population distribution)

**Key Assumptions:**

-   All common causes of the treatment and the outcome can be captured through the covariates (more mathematically, the outcome and the treatment and independent conditional on the covariates)
-   All observations had some positive probability of being treated. Heuristically, you can think of this as meaning in the image above there are no areas where there are no major regions where there are only green control observations and no treatment observations
-   Only a small number of variables require adjustment (because they impact both the treatment likelihood and the outcome) Otherwise, we are plagued by the [curse of dimensionality](https://en.wikipedia.org/wiki/Curse_of_dimensionality)

**Example:**

-   Suppose we attempt to A/B test a "One-Click Instant Checkout" option on our website before Black Friday and want to measure the effect on total purchase amount (one on hand, we might think this would reduce abandoned baskets; on the other hand, it might decrease browsing.) However, due to a glitch the code, there is a 50/50 split between treatment groups for web users but 30/70 for mobile users. Additionally, we know that mobile users tend to buy less in an order.
-   Although we could run another A/B test, we only had one shot at Black Friday and need to decide whether or not to include this button next year. We can calculate separate treatment effects within web orders versus mobile orders and then weight average these effects based on the overall channel distribution across all orders.
-   (Technically with modern web design, we could make separate decisions for mobile and web users, so we might not actually care about the overall treatment effect. This is just an example.)

**Related Methods:**

-   Propensity score weighting (covered next) can be seen as a more advanced form of stratification. Both methods share the goal of making the distribution of treatment and control groups more similar.

**Tools:**

-   This method is computationally simple, so it can essentially be done with `SQL` or any R package like `dplyr` which can handle grouped aggregations

Propensity Score Weighting
--------------------------

![](excalidraw-psw.png)

**Approach:**

-   Model the probability of receiving the treatment based each observation's covariates
-   Use predicted probabilities (propensity scores) to reweight the treatment group to fit the same distribution as the control group
-   Weights can be constructed in different ways depending on the quantity of interest (average treatment effect of treated, average treatment effect of population, average treatment effect on control, etc.)
-   Apply weights when calculating the average outcome in each of the treated and control groups and subtract to find the treatment effect

**Key Assumptions:**

-   All common causes of the treatment and the outcome can be captured through the covariates (more mathematically, the outcome and the treatment and independent conditional on the covariates)
-   All observations had some positive probability of being treated. Heuristically, you can think of this as meaning in the image above there are no areas where there are no major regions where there are only green control observations and no treatment observations

**Example:**

-   We sent a marketing promotion text message to all of our customers for whom we have a valid cell phone number and want to know the causal effect on the likelihood of making a purchase in the next month. Because we sent this text to all customers with a valid phone number, we only have customers for whom we do *not* have a phone number for a control. This is an optional field when making a purchase, so there is some randomness between the population; however, we know that those who do not provide a phone number tend to be older and less frequent shoppers. We could build a propensity score model based on demographics and historical purchase behavior and use this to reweight our population when measuring the target outcome.

**Related Methods:**

-   Stratification is conceptually similar to propensity score weighting since it implicitly calculates the treatment effect on a reweighted sample. There, the reweighting comes after computing localized effects instead of before
-   Propensity scores are sometimes also used in matching, but there are [some arguments](https://www.youtube.com/watch?v=rBv39pK1iEs&list=PL0n492lUg2sjYNAtpfatEm-AuGkAmCz4G) against this approach

**Tools:**

-   [`WeightIt`](https://cran.r-project.org/web/packages/WeightIt/index.html) R package for IPW
-   Easy to implement with simple [`stats::glm()`](https://rdrr.io/r/stats/glm.html) as shown in Lucy D'Agostino McGowan's [blog post](https://livefreeordichotomize.com/2019/01/17/understanding-propensity-score-weighting/)

Regression Discontinuity
------------------------

![](excalidraw-rdd.png)

**Approach:**

-   A set of individuals either do or do not receive a treatment based on an arbitrary cut-off.
-   Model the relationship between the "decisioning" variable and the outcome on both sides of the cut-off. Then, the *local* treatment effect at the point of the cut-off can be determined by the difference in modeled outcome at this value of the "decisioning" variable.
-   Note that we can only measure the *local* treatment effect *at the cut-off* -- not the global average treatment effect, as we did with stratification and propensity score weighting

**Key Assumptions:**

-   The assignment rule is unknown to the individuals being observed so it cannot be gamed
-   The outcome of interest can be modeled as a continuous function with respect to the decisioning variable
-   We can fit a reasonably well-specified and simple model between the outcome of interest and the decisioning variable. Since RDD necessarily requires us to use estimates from the very "tails" of our model, overly complex models (e.g. high degree polynomials) can reach bizarre conclusions

**Example:**

-   Customers who have not made a purchase in 90 days are sent a "\$10 Off Your Next Purchase" coupon. We can use the sharp cut-off in "days since last purchase" to measure the effect of a coupon on spend in the next year. While it's implausible to think that customers who haven't purchased in 10 days are similar to those who have not in 150 days, customers who haven't purchased in 88 days are likely not substantively different than those who have not purchased in 92 days except for the different treatment
-   A *counter-example* that violates the assumption would be advertising "Free Shipping and Returns over \$50" and attempting to measure the effect of offering free shipping on future customer loyalty. Why? This cut-off is *known* to individuals ahead of time and can be gamed. For example, perhaps less loyal are more skeptical of a company's products and more likely to return, so they might intentionally spend more than \$50 to change their classification and gain entrance to the treatment group

**Related Methods:**

-   Fuzzy regression discontinuity allows for cut-off points to be probabilistic instead of absolute
-   [Instrumental variable methods](https://en.wikipedia.org/wiki/Instrumental_variables_estimation) and two-stage least squares can be thought of as a broader family in which regression discontinuity is a simple example. More broadly, these methods address confounding between a treatment and an outcome by modeling the relationship between a treatment and an instrument which is only related to the outcome through the treatment

**Tools:**

-   [`rdd`](https://cran.r-project.org/web/packages/rdd/index.html) R package for regression discontinuity
-   [`AER`](https://cran.r-project.org/web/packages/AER/index.html) R package for instrumental variable methods

Difference in Differences
-------------------------

![](excalidraw-did.png)

**Approach:**

-   In two separate populations, one receives the treatment and one does not. We believe but-for the treatment the two populations would have similar trends in outcome
-   We can estimate the treatment effect by taking the *difference* between the post-treatment *difference* between populations and the pre-treatment *difference* between populations
-   In effect, this is the same as extrapolating the counterfactual for the treated population in the post-treatment period if it had not received treatment (the dashed line in the image above)
-   Technically, this is implemented as a fixed-effects regression model

**Key Assumptions:**

-   The decision to treat the treatment group was not influenced by the outcome
-   If not for the treatment, the two groups being compared would have parallel trends in the outcome. Note that groups are allowed to have different *levels* but must have similar trends over time
-   There is no spill-over effect such that treating the treatment group has an effect on the control group

**Example:**

-   We could estimate the effect of a store remodel on visits by comparing store traffic before and after the remodel with traffic at a store that did not remodel. This only works if our assumptions hold; if the remodel is an expansion and caused by a foreseen increase in traffic, our first assumption is violated.
-   A *counter-example* that violates the assumption would be measuring the effect of placing a certain product brand near a store's check-out on sales and using sales of a different brand of the same product as the control. Why? Since these products are substitutes, the product placement of the treatment group could "spillover" to negatiely effect sales of the control

**Related Methods:**

-   Synthetic control methods can be thought of as an extension of difference-in-differences where the control is a weighted average of a number of different possible controls
-   Bayesian structural time-series methods relax the "parallel trends" asummptions of difference-in-differences by modeling the relationship between time series (including trend and seasonal components)

**Tools:**

-   [`did`](https://bcallaway11.github.io/did/) R package for difference-in-differences
-   [`Synth`](https://www.jstatsoft.org/article/view/v042i13) R package for synthetic controls
-   [`CausalImpact`](http://google.github.io/CausalImpact/CausalImpact.html) R package for Bayesian structural time-series

A Note on Personalized Effects
------------------------------

You may have noticed that, so far, we've only discussed methods that tell us the *average* treatment effect (or, in the case of RDD, the even narrower *local* average treatment effect.) Of course, in an ideal world, individual treatment effects would be significantly more useful to us. There's currently a lot of interesting work in the area of heterogeneous treatment effects to help better understand how causal effects vary by subgroup for better segmentation and targetting. As a few examples, check out:

-   Causal forests developed by Susan Athey and Stefan Wagner discussed in [this lecture](https://www.youtube.com/watch?v=oZoizsX3bts&list=PLoazKTcS0RzZ1SUgeOgc6SWt51gfT80N0&index=7)/[this paper](https://arxiv.org/abs/1902.07409) and implemented in the [`grf` R package](https://grf-labs.github.io/grf/index.html)
-   Tree-based subgroup analysis by Heidi Seibold discussed in [this talk](https://www.youtube.com/watch?v=NRzObclZVT8)/[this paper](https://journals.sagepub.com/doi/10.1177/0962280217693034) and implemented in the [`model4you` R package](https://cran.r-project.org/web/packages/model4you/index.html)

Learn More
----------

The point of this post is not to teach any one method of causal inference but to help raise awareness for the different tools and methods that arise given certain naturally occurring experiments and inference-friendly data structures. There's a plethora of fantastic resources available to learn more about the specific implementation of these or other methods. Below, I've linked a few favorites.

### Free Books

-   [Causal Inference: What If](https://www.hsph.harvard.edu/miguel-hernan/causal-inference-book/) by Miguel Hernan and Jamie Robins
    -   Epidemiology perspective
    -   Code supplement in R, python, SAS, Stata
-   [Introduction to Causal Inference](https://www.bradyneal.com/causal-inference-course) by Brady Neal
    -   ML perspective including Bayesian networks, causal discovery
    -   Book complemented by video lectures
-   [Causal Inference: the Mixtape](https://mixtape.scunning.com/) by Scott Cunningham
    -   Economics perspective
    -   Includes interactive R code chunks to run as you read
-   [The Effect: An Introduction to Research Design and Causality](https://nickchk.com/causalitybook.html) by Nick Huntington-Kline
    -   Economics perspective
    -   Holistic focus on research design with rich examples from literature
-   [Impact Evaluation in Practice](https://openknowledge.worldbank.org/handle/10986/25030) by Gertler, Martinez, Premand, Rawlings, Vermeersch

### Course Material

-   [Introduction to Causal Inference](https://www.bradyneal.com/causal-inference-course) by Brady Neal
    -   ML perspective including Bayesian networks, causal discovery
    -   Slides and video lectures to go along with book linked above
-   [Program Evaluation](https://evalf19.classes.andrewheiss.com/) by Andrew Heiss
    -   Public policy perspective
    -   Slides and assignments
-   [Causal Inference (Propensity Score) Tutorial from UseR!2020](https://github.com/LucyMcGowan/user2020-causal-inference) by Lucy D'Agostino McGowan and Malcolm Barrett
    -   Epidemiology perspective focused on propensity-score methods
    -   Video tutorial with R code on GitHub

### Blogs and Talks

**Overviews**

-   [Using Causal Inference to Improve the Uber User Experience](https://eng.uber.com/causal-inference-at-uber/) on the Uber Engineering blog

**Propensity Score Methods**

-   [Understanding propensity score weighting](https://livefreeordichotomize.com/2019/01/17/understanding-propensity-score-weighting/) by Lucy D'Agostino McGowan
-   [To Balance or Not To Balance](https://www.unofficialgoogledatascience.com/2016/06/to-balance-or-not-to-balance.html) by Ivan Diaz and Joseph Kelly (Unofficial Google Data Science Blog)

**Advanced Methods** (not discussed in this post)

-   [Causal Science 2020 Meeting talks](https://causalscience.org/programme/about/)
-   [Synthetic Control lecture](https://www.youtube.com/watch?v=nKzNp-qpE-I&list=PLoazKTcS0RzZ1SUgeOgc6SWt51gfT80N0&index=11) by Alberto Abadie
-   [Heterogenous Treatment Effects lecture](https://www.youtube.com/watch?v=oZoizsX3bts&list=PLoazKTcS0RzZ1SUgeOgc6SWt51gfT80N0&index=7) by Susan Athey
-   [Personalized Treatment Effect Estimation](https://www.youtube.com/watch?v=NRzObclZVT8) by Heidi Seibold
-   [Handbook of Field Experiments](https://www.povertyactionlab.org/page/handbook-field-experiments) by Ahbijit Banerjee and Esther Duflo

### Podcasts

-   [Casual Inference](https://casualinfer.libsyn.com/)
-   [SERious EPI](https://seriousepi.blubrry.net/)

### Other Introductory Books

-   [Mastering Metrics](https://www.amazon.com/gp/product/0691152845/ref=ox_sc_act_title_3?smid=ATVPDKIKX0DER&psc=1) and [Mostly Harmless Econometrics](https://www.amazon.com/Mostly-Harmless-Econometrics-Empiricists-Companion/dp/0691120358/ref=pd_sbs_14_1/134-6784964-9794862?_encoding=UTF8&pd_rd_i=0691120358&pd_rd_r=ebba5491-d197-4e79-be24-ec7e1c2bda17&pd_rd_w=xvRCC&pd_rd_wg=dpUZo&pf_rd_p=bc074051-81d1-4874-a3fd-fd0c867ce3b4&pf_rd_r=69D56CVPRFHAWNKFARBY&psc=1&refRID=69D56CVPRFHAWNKFARBY) by Joshua Angrist and Jorn-Steffen Pischke
-   [The Book of Why](https://www.amazon.com/Book-Why-Science-Cause-Effect/dp/046509760X/ref=sr_1_1?dchild=1&keywords=book+of+why&qid=1596111613&s=books&sr=1-1) by Judea Pearl

[^1]: A concept popularized by the 1994 book *Design Patterns: Elements of Reusable Object-Oriented Software*. See more on [Wikipedia](https://en.wikipedia.org/wiki/Design_Patterns).

[^2]: Two other examples of this are categorical data analysis methods associated only with text mining and time-to-event analyses covered predominately in survival analysis

