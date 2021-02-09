---
title: dbt_dplyr
summary: dbt package bringing `dplyr` semantics to SQL
tags:
- package
date: "2021-02-06"

# Optional external URL for project (replaces project detail page).
# external_link: https://emilyriederer.github.io/projmgr/index.html

links:
- icon: github
  icon_pack: fab
  name: Repo
  url: https://github.com/emilyriederer/dbt_dplyr
- icon: book
  icon_pack: fas
  name: Docs
  url: https://github.com/emilyriederer/dbt_dplyr
- icon: file
  icon-pack: far
  name: Post
  url: /post/dbt-convo/

image:
  caption: dbt example code
  focal_point: Smart
---

`dbt_dplyr` is an dbt add-on package bringing `dplyr` semantics to SQL. In particular, it mimics `dplyr`'s [`across()` function](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-colwise/) 
and the [`select helpers`](https://tidyselect.r-lib.org/reference/select_helpers.html) to easily apply operations to a set of columns programmatically determined by their names. 

`dplyr` (>= 1.0.0) has helpful semantics for selecting and applying transformations to variables based on their names.
For example, if one wishes to take the *sum* of all variables with name prefixes of `N` and the mean of all variables with
name prefixes of `IND` in the dataset `mydata`, they may write:

```
summarize(
  mydata, 
  across( starts_with('N'), sum),
  across( starts_with('IND', mean)
)
```

This package enables us to similarly write `dbt` data models with commands like:

```
{% cols_n = starts_with( ref('mydata'), 'N') %}
{% cols_ind = starts_with( ref('mydata'), 'IND') %}

select

  {{ across(cols_n, "sum({{var}}) as {{var}}_tot") }},
  {{ across(cols_ind, "mean({{var}}) as {{var}}_avg") }}

from {{ ref('mydata') }}
```

which `dbt` then compiles to standard SQL.
