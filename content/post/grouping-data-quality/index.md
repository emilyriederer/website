---
output: hugodown::md_document
title: "Make grouping a first class citizen in data quality checks"
subtitle: ""
summary: "Advocating for a small tweak that could add a lot of value in emerging data quality tools"
authors: []
tags: [data]
categories: [data]
date: 2021-11-15
lastmod: 2021-11-15
featured: false
draft: false
aliases:

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "Photo credit to [Greyson Joralemon](https://unsplash.com/@greysonjoralemon) on Unsplash"
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: a6cd04b6e4c1993d

---

The past few years have seen an explosion in different solutions for monitoring in-production data quality. These tools, including software like `dbt` and `Great Expectations` as well as platforms like `Monte Carlo`, bring a more DevOps flavor to data production with important functionality like automated testing *within* pipelines (not just at the end), expressive and configurable semantics for common data checks, and more.

However, despite all these features, I notice a common gap across the landscape which may limit the ability of these tools to detect common classes of data failures. Earlier this year, I wrote about the importance of [validating data based on its data generating process](https://emilyriederer.netlify.app/post/data-error-gen/) -- both along the technical and conceptual dimensions. Following this logic, an important and lacking functionality[^1] across the data quality monitoring landscape, is the ability to readily apply checks separately to groups of data. On a quick survey, I count about 8/14 `dbt` tests (from the add-on [dbt-utils](https://github.com/dbt-labs/dbt-utils) package), 15/37 [Great Expectations](https://docs.greatexpectations.io/docs/reference/glossary_of_expectations) column tests, and most all of the [Monte Carlo](https://docs.getmontecarlo.com/docs/field-health-metrics) field health metrics that would be improved with first-class grouping functionality. (Lists at the bottom of the post.)

Group-based checks can be important for fully articulating good "business rules" against which to assess data quality. For example, groups could reflect either computationally-relevant dimensions of the ETL process (e.g. data loaded from different sources) or semantically-relevant dimensions of the real-world process that our data captures (e.g. repeated measures pertaining to many individual customers, patients, product lines, etc.)

In this post, I make a brief plea for why grouping should be a first-class citizen in data quality tooling.

Use Cases
---------

There are three main use-cases for enabling easy data quality checks by group: checks that can only be expressed by group, checks that can be more rigorous by group, and checks that are more semantically intuitive by group.

**Some checks can be more rigorous by group.** Consider a recency check (i.e. that the maximum date represented in the data is appropriately close to the present.) If the data loads from multiple sources (e.g. customer acquisitions from web and mobile perhaps logging to different source systems), the maximum value of the field could pass the check if any one source loaded, but unless the data is grouped in such a way that reflects different data sources and *each* group's maximum date is checked, stale data could go undetected.

**Some types of checks can only be expressed by group.** Consider a check for consecutive data values. If a table that measures some sort of user engagements, there might be fields for the `USER_ID` and `MONTHS_SINCE_ACQUISITION`. A month counter will most certainly *not* be strictly increasing across the entire dataset but absolutely should be monotonic within each user.

**Some checks are more semantically intuitive by group.** Consider a uniqueness check for the same example as above. The month counter is also not unique across the whole table but could be checked for uniqueness within each user. Group semantics would not be required to accomplish this; a simple `USER_ID x MONTHS_SINCE_ACQUISITION` composite variable could be produced and checked for uniqueness. However, it feels cumbersome and less semantically meaningful to derive additional fields just to fully check the properties of existing fields. (But for the other two categories, this alone would not justify adding such new features.)

These categories demonstrate the specific use cases for grouped data checks. However, there are also soft benefits. Most prevalently, having group-based checks be first class citizens opens up a new [pit of success.](https://english.stackexchange.com/questions/77535/what-does-falling-into-the-pit-of-success-mean)[^2] If you believe, as do I, that this is a often a fundamentally important aspect of confirming data quality and not getting "false promises" (as in the first case where non-grouped checks are less rigorous), configuring checks this way should be as close to zero-friction as possible.

Alternatives Considered
-----------------------

Given that this post is, to some extent, a feature request across all data quality tools ever, it's only polite to discuss downsides and alternative solutions that I considered. Clearly, finer-grained checks incur a greater computational cost and could, in some cases, be achieved via other means.

**Grouped checks are more computational expensive.** Partitioning and grouping can make data check operations more expensive by disabling certain computational shortcuts[^3] and requiring more total data to be retained. This is particularly true if the data is indexed or partitioned along different dimensions than the groups used for checks. The extra time required to run more fine-grained checks could become intractable or at least unappealing, particularly in an interactive or continuous integration context. However, in many cases it could be a better use of time to more rigorously test recently loaded data as opposed to (or in conjunction with) running higher-level checks across larger swaths of data.

**Some grouped checks can be achieved in other ways.** This is really the same argument as the third point discussed above. Some (but not all) of these checks can be mocked by creating composite variables or, in the case of `Great Expectation`'s python-based API, writing custom code to partition data before applying checks[^4]. However, there solutions seem to defy part of the benefits of these tools: semantically meaningful checks wrapped in readable syntax and ready for use out-of-the-box. This also implies that grouped operations are far less than first-class citizens. This also limits the ability to make use of some of the excellent functionality these tools offer for documenting data quality checks in metadata and reporting on their outcomes.

**Not doing grouped checks at all.** Perhaps grouped data checks seem excessive. After all, data quality checks do not, perhaps, aim to guarantee every field is 100% correct. Rather, they are higher-level metrics which aim to catch signals of deeper issues. My counterargument is largely based in the first use case listed above. Without testing data at the right level of granularity, checks could almost do more harm than good if they promote a false sense of data quality by masking issues.

**"But we monitor our data with machine learning."** There's a fair amount of work currently (not necessarily with the tools that I've named) with using machine learning and anomaly detection approaches to detect data quality issues. Some might argue that these advanced approaches lessen the need for heavily tailor, user-specified data checks. Personally, I struggle to agree with that. I believe domain context can go a long way to solving data issues and is often worth the investment.

I also considered the possibility that this is a niche, personal need moreso than a general one because I work with a *lot* of panel data. However, I generally believe *most* data is nested in something, somehow than is not. I substantiated this a bit with a peak at GitHub issue feature requests in different data quality tools. For example, three stale stale GitHub issues on the `Great Expectations` repo ([1](https://github.com/great-expectations/great_expectations/issues/351), [2](https://github.com/great-expectations/great_expectations/issues/402), [3](https://github.com/great-expectations/great_expectations/issues/373)) request similar functionality.

Downsides
---------

There's no such thing as a free lunch or a free feature enhancement. My point is in no way to criticize existing data quality tools that do not have this functionality. Designing any tool is a process of trade-offs, and it's only fair to discuss the downsides. These issues are exacerbated further when adding "just one more thing" to mature, heavily used tools as opposed to developing new ones.

**API bloat makes tools less navigable.** Any new feature has to be documented by developers and comprehended by users. Having too many "first-class citizen" features can lead to features being ignored, unknown, or misused. It's easy to point to any one feature in isolation and claim it is important; it's much harder to stare at a full backlog and decide where the benefits are worth the cost.

**Incremental functionality adds more overhead.** Every new feature demands careful programming and testing. Beyond that, there's a substantial mental tax in thinking through how that feature needs to interact with existing functionality while, at the same time, preserving backwards compatibility.

Survey of available tools
-------------------------

My goal is in no way to critique any of the amazing, feature-rich data quality tools available today. However, to further illustrate my point, I pulled down key data checks from a few prominent packages to assess how many of their tests would be potentially enhanced with the ability to provided grouping parameters. Below are lists for `dbt-utils`, `Great Expectations`, and `Monte Carlo` with relevant tests *in bold*.

### dbt-utils (8 / 14)

-   **equal\_rowcount**
-   equality
-   expression\_is\_true
-   **recency**  
-   **at\_least\_one**
-   **not\_constant**
-   **cardinality\_equality**
-   **unique\_where**
-   not\_null\_where  
-   **not\_null\_proportion**
-   relationships\_where
-   mutually\_exclusive\_ranges
-   **unique\_combination\_of\_columns** (*but less important - only for semantics*)
-   accepted\_range

### Great Expectations (15 / 37)

-   **expect\_column\_values\_to\_be\_unique** (*but less important - only for semantics*)
-   expect\_column\_values\_to\_not\_be\_null  
-   expect\_column\_values\_to\_be\_null  
-   expect\_column\_values\_to\_be\_of\_type  
-   expect\_column\_values\_to\_be\_in\_type\_list
-   expect\_column\_values\_to\_be\_in\_set
-   expect\_column\_values\_to\_not\_be\_in\_set
-   expect\_column\_values\_to\_be\_between  
-   **expect\_column\_values\_to\_be\_increasing**
-   **expect\_column\_values\_to\_be\_decreasing**
-   expect\_column\_value\_lengths\_to\_be\_between
-   expect\_column\_value\_lengths\_to\_equal
-   expect\_column\_values\_to\_match\_regex
-   expect\_column\_values\_to\_not\_match\_regex
-   expect\_column\_values\_to\_match\_regex\_list
-   expect\_column\_values\_to\_not\_match\_regex\_list
-   expect\_column\_values\_to\_match\_like\_pattern
-   expect\_column\_values\_to\_not\_match\_like\_pattern
-   expect\_column\_values\_to\_match\_like\_pattern\_list
-   expect\_column\_values\_to\_not\_match\_like\_pattern\_list
-   expect\_column\_values\_to\_match\_strftime\_format
-   expect\_column\_values\_to\_be\_dateutil\_parseable
-   expect\_column\_values\_to\_be\_json\_parseable
-   expect\_column\_values\_to\_match\_json\_schema
-   expect\_column\_distinct\_values\_to\_be\_in\_set
-   **expect\_column\_distinct\_values\_to\_contain\_set**
-   **expect\_column\_distinct\_values\_to\_equal\_set**
-   **expect\_column\_mean\_to\_be\_between**
-   **expect\_column\_median\_to\_be\_between**
-   **expect\_column\_quantile\_values\_to\_be\_between**
-   **expect\_column\_stdev\_to\_be\_between**
-   **expect\_column\_unique\_value\_count\_to\_be\_between**
-   **expect\_column\_proportion\_of\_unique\_values\_to\_be\_between**
-   **expect\_column\_most\_common\_value\_to\_be\_in\_set**
-   **expect\_column\_max\_to\_be\_between**
-   **expect\_column\_min\_to\_be\_between**
-   **expect\_column\_sum\_to\_be\_between**

### Monte Carlo (All)

Any of Monte Carlo's checks might be more sensitive to detecting changes with subgrouping. Since these "health metrics" tend to represent distributional properties, it can be useful to ensure that "good groups" aren't pulling down the average value and masking errors in "bad groups".

-   Pct NUll  
-   Pct Unique
-   Pct Zero  
-   Pct Negative  
-   Min
-   p20
-   p40
-   p60
-   p80
-   Mean
-   Std
-   Max
-   Pct Whitespace
-   Pct Integer
-   Pct "Null"/"None"
-   Pct Float
-   Pct UUID

[^1]: With the exception of `pointblank` which kindly entertained an issue I opened on this topic: <a href="https://github.com/rich-iannone/pointblank/issues/300" class="uri">https://github.com/rich-iannone/pointblank/issues/300</a>

[^2]: The "pit of success" is the idea that well-designed tools can help nudge people to do the "right" thing by default because its also the easiest. I first learned of it in a talk by Hadley Wickham, and it is originally attributed to Microsoft program manage Rico Mariani.

[^3]: For example, the maximum of a set of numbers is the maximum of the maximums of the subsets. Thus, if my data is distributed, I can find the max by comparing only summary statistics from the distributed subsets instead of pulling all of the raw data back together.

[^4]: This is less possible for tools like `dbt`/`dbt-utils` where tests are defined by SQL scripts. In this set-up, separate, similar testing macros would have to be defined.

