---
output: hugodown::md_document
title: "Make grouping a first class citizen in data quality checks"
subtitle: ""
summary: "Advocating for a small tweak that could add a lot of value in emerging data quality tools"
authors: []
tags: [data]
categories: [data]
date: 2021-11-13
lastmod: 2021-11-13
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
rmd_hash: 8a5d3c47328b8259

---

There comes a point in every data persons life

Cases for and against
---------------------

**Case for:**

-   *Some checks can be more rigorous by group.* Consider a recency check (i.e. that the maximum date represented in the data is appropriately close to the present.) If the data loads from multiple sources (e.g. customer acquisitons from web and mobile perhaps logging to different source systems), the maximum value of the field could pass the check if any one source loaded, but unless the data is grouped in such a way that reflects different data sources and *each* group's maximum date is checked, stale data could go undetected.
-   *Some types of checks can only be expressed by group.* Consider a check for consecutive data values. If a table that measures some sort of user engagements, there might be fields for the `USER_ID` and `MONTHS_SINCE_ACQUISITION`. A month counter will most certainly *not* be strictly increasing across the entire dataset but absolutely should be monotonic within each user.
-   *Some checks are more semantically intuitive by group.* Consider a uniqueness check for the same example as above. The month counter is also not unique across the whole table but could be checked for uniqueness within each user. Group semantics would not be required to accomplish this; a simple `USER_ID x MONTHS_SINCE_ACQUISITION` composite variable could be produced and checked for uniqueness. However, it feels cumbersome and less semantically meaningful to derive additional fields just to fully check the properties of existing fields.

**Case against:**

-   *Grouped checks are more computational expensive.* Partitioning and grouping can make data check operations more expensive by disabling certain computational shortcuts[^1] and requiring more total data to be retained. This is particularly true if the data is indexed or partitioned along different dimensions than the groups used for checks. However, in many cases it could be a better use of time to more rigorously test recently loaded data as opposed to (or in conjunction with) running higher-level checks across larger swaths of data.
-   *Some grouped checks can be achieved in other ways.* This is really the same as the third bullet point above. We can make composite variables or use split-apply-combine approaches, but this implies grouped operations are far lesser than first-class citizens.

Survey
------

[dbtutils](https://github.com/dbt-labs/dbt-utils)

8 out of 14

-   equal\_rowcount **BY GROUP**
-   equality
-   expression\_is\_true
-   recency **BY GROUP**
-   at\_least\_one **BY GROUP**
-   not\_constant **BY GROUP**
-   cardinality\_equality **BY GROUP**
-   unique\_where **BY GROUP**
-   not\_null\_where  
-   not\_null\_proportion **BY GROUP**
-   relationships\_where
-   mutually\_exclusive\_ranges
-   unique\_combination\_of\_columns **BY GROUP** (maybe - more for semantics than an actual coding difference)
-   accepted\_range

[Great Expectations](https://docs.greatexpectations.io/docs/reference/glossary_of_expectations)

15 out of 37

-   expect\_column\_values\_to\_be\_unique **BY GROUP** (for semantics)
-   expect\_column\_values\_to\_not\_be\_null  
-   expect\_column\_values\_to\_be\_null  
-   expect\_column\_values\_to\_be\_of\_type  
-   expect\_column\_values\_to\_be\_in\_type\_list
-   expect\_column\_values\_to\_be\_in\_set
-   expect\_column\_values\_to\_not\_be\_in\_set
-   expect\_column\_values\_to\_be\_between  
-   expect\_column\_values\_to\_be\_increasing **BY GROUP**
-   expect\_column\_values\_to\_be\_decreasing **BY GROUP**
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
-   expect\_column\_distinct\_values\_to\_contain\_set **BY GROUP**
-   expect\_column\_distinct\_values\_to\_equal\_set **BY GROUP**
-   expect\_column\_mean\_to\_be\_between **BY GROUP**
-   expect\_column\_median\_to\_be\_between **BY GROUP**
-   expect\_column\_quantile\_values\_to\_be\_between **BY GROUP**
-   expect\_column\_stdev\_to\_be\_between **BY GROUP**
-   expect\_column\_unique\_value\_count\_to\_be\_between **BY GROUP**
-   expect\_column\_proportion\_of\_unique\_values\_to\_be\_between **BY GROUP**
-   expect\_column\_most\_common\_value\_to\_be\_in\_set **BY GROUP**
-   expect\_column\_max\_to\_be\_between **BY GROUP**
-   expect\_column\_min\_to\_be\_between **BY GROUP**
-   expect\_column\_sum\_to\_be\_between **BY GROUP**

[Monte Carlo](https://docs.getmontecarlo.com/docs/field-health-metrics)

15 out of 17

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

[^1]: For example, the maximum of a set of numbers is the maximum of the maximums of the subsets. Thus, if my data is distributed, I can find the max by comparing only summary statistics from the distributed subsets instead of pulling all of the raw data back together.

