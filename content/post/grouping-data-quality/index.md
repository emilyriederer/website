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
rmd_hash: 0d8b73b68cf42de5

---

Which of these numbers doesn't belong? -1, 0, 1, NA.

It may be hard to tell. If the data in question should be non-negative, -1 is clearly wrong; if it should be complete, the NA is problematic; if it represents the signs to be used in summation, 0 is questionable. In short, there is no data quality without data context.

The past few years have seen an explosion in different solutions for monitoring in-production data quality. These tools, including software like `dbt` and `Great Expectations` as well as platforms like `Monte Carlo`, bring a more DevOps flavor to data production with important functionality like automated testing *within* pipelines (not just at the end), expressive and configurable semantics for common data checks, and more.

However, despite all these features, I notice a common gap across the landscape which may limit the ability of these tools to encode richer domain context and detect common classes of data failures. I previously wrote about the importance of [validating data based on its data generating process](https://emilyriederer.netlify.app/post/data-error-gen/) -- both along the technical and conceptual dimensions. Following this logic, an important and lacking functionality[^1] across the data quality monitoring landscape, is the ability to readily apply checks separately to groups of data. On a quick survey, I count about 8/14 `dbt` tests (from the add-on [dbt-utils](https://github.com/dbt-labs/dbt-utils) package), 15/37 [Great Expectations](https://docs.greatexpectations.io/docs/reference/glossary_of_expectations) column tests, and most all of the [Monte Carlo](https://docs.getmontecarlo.com/docs/field-health-metrics) field health metrics that would be improved with first-class grouping functionality. (Lists at the bottom of the post.)

Group-based checks can be important for fully articulating good "business rules" against which to assess data quality. For example, groups could reflect either computationally-relevant dimensions of the ETL process (e.g. data loaded from different sources) or semantically-relevant dimensions of the real-world process that our data captures (e.g. repeated measures pertaining to many individual customers, patients, product lines, etc.)

In this post, I make a brief plea for why grouping should be a first-class citizen in data quality tooling.

Use Cases
---------

There are three main use-cases for enabling easy data quality checks by group: checks that can only be expressed by group, checks that can be more rigorous by group, and checks that are more semantically intuitive by group.

**Some checks can be more rigorous by group.** Consider a recency check (i.e. that the maximum date represented in the data is appropriately close to the present.) If the data loads from multiple sources (e.g. customer acquisitions from web and mobile perhaps logging to different source systems), the maximum value of the field could pass the check if any one source loaded, but unless the data is grouped in such a way that reflects different data sources and *each* group's maximum date is checked, stale data could go undetected.

**Some types of checks can only be expressed by group.** Consider a check for consecutive data values. If a table that measures some sort of user engagements, there might be fields for the `USER_ID` and `MONTHS_SINCE_ACQUISITION`. A month counter will most certainly *not* be strictly increasing across the entire dataset but absolutely should be monotonic within each user.

**Some checks are more semantically intuitive by group.** Consider a uniqueness check for the same example as above. The month counter is also not unique across the whole table but could be checked for uniqueness within each user. Group semantics would not be required to accomplish this; a simple `USER_ID x MONTHS_SINCE_ACQUISITION` composite variable could be produced and checked for uniqueness. However, it feels cumbersome and less semantically meaningful to derive additional fields just to fully check the properties of existing fields. (But for the other two categories, this alone would not justify adding such new features.)

These categories demonstrate the specific use cases for grouped data checks. However, there are also soft benefits.

Most prevalent, having group-based checks be first class citizens opens up a new [**pit of success**](https://english.stackexchange.com/questions/77535/what-does-falling-into-the-pit-of-success-mean)[^2]. If you believe, as do I, that this is a often a fundamentally important aspect of confirming data quality and not getting "false promises" (as in the first case where non-grouped checks are less rigorous), configuring checks this way should be as close to zero-friction as possible.

Demo: NYC turnstile data
------------------------

### Context

To better motivate this need, we will look at a real-world example. For this, I turn to New York City's [subway turnstile data](http://web.mta.info/developers/turnstile.html) which I can always count on to have plenty of data quality quirks (which, to be clear, I do not say as a criticism. There's nothing unexpected about this in real-world "data as residue" data.)

Specifically, we'll pull down data extracts for roughly the first quarter of 2020 (published on Jan 11 - April 11, corresponding to weeks ending Jan 10 - April 10.)[^3]

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># data source: http://web.mta.info/developers/turnstile.html</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://readr.tidyverse.org'>readr</a></span><span class='o'>)</span>

<span class='c'># define read function with schema ----</span>
<span class='nv'>read_data</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>url</span><span class='o'>)</span> <span class='o'>{</span>
  
  <span class='nf'>readr</span><span class='nf'>::</span><span class='nf'><a href='https://readr.tidyverse.org/reference/read_delim.html'>read_csv</a></span><span class='o'>(</span><span class='nv'>url</span>,
                  col_names <span class='o'>=</span> <span class='kc'>TRUE</span>,
                  col_types <span class='o'>=</span>
                    <span class='nf'><a href='https://readr.tidyverse.org/reference/cols.html'>cols</a></span><span class='o'>(</span>
                      `C/A` <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      UNIT <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      SCP <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      STATION <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      LINENAME <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      DIVISION <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      DATE <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_datetime.html'>col_date</a></span><span class='o'>(</span>format <span class='o'>=</span> <span class='s'>"%m/%d/%Y"</span><span class='o'>)</span>,
                      TIME <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_datetime.html'>col_time</a></span><span class='o'>(</span>format <span class='o'>=</span> <span class='s'>""</span><span class='o'>)</span>,
                      DESC <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      ENTRIES <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_integer</a></span><span class='o'>(</span><span class='o'>)</span>,
                      EXITS <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_integer</a></span><span class='o'>(</span><span class='o'>)</span>
                    <span class='o'>)</span><span class='o'>)</span>
  
<span class='o'>}</span>

<span class='c'># ridership data ----</span>
<span class='nv'>dates</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.Date.html'>seq.Date</a></span><span class='o'>(</span>from <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>'2020-01-11'</span><span class='o'>)</span>, to <span class='o'>=</span>, <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>'2020-04-11'</span><span class='o'>)</span>, by <span class='o'>=</span> <span class='s'>'7 days'</span><span class='o'>)</span>
<span class='nv'>dates_str</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/format.html'>format</a></span><span class='o'>(</span><span class='nv'>dates</span>, format <span class='o'>=</span> <span class='s'>'%y%m%d'</span><span class='o'>)</span>
<span class='nv'>dates_url</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/sprintf.html'>sprintf</a></span><span class='o'>(</span><span class='s'>'http://web.mta.info/developers/data/nyct/turnstile/turnstile_%s.txt'</span>, <span class='nv'>dates_str</span><span class='o'>)</span>
<span class='nv'>datasets</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='o'>(</span><span class='nv'>dates_url</span>, FUN <span class='o'>=</span> <span class='nv'>read_data</span><span class='o'>)</span>
<span class='nv'>full_data</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/do.call.html'>do.call</a></span><span class='o'>(</span><span class='nv'>rbind</span>, <span class='nv'>datasets</span><span class='o'>)</span>
<span class='nv'>full_data</span> <span class='o'>&lt;-</span> <span class='nv'>full_data</span><span class='o'>[</span><span class='nv'>full_data</span><span class='o'>$</span><span class='nv'>DESC</span> <span class='o'>==</span> <span class='s'>"REGULAR"</span>,<span class='o'>]</span>
<span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>full_data</span><span class='o'>)</span><span class='o'>[</span><span class='m'>1</span><span class='o'>]</span> <span class='o'>&lt;-</span> <span class='s'>"CA"</span>
</code></pre>

</div>

<div class="highlight">

</div>

<div class="highlight">

</div>

This data contains 2869965 records, corresponding to one unique record per unique control area (`CA`), turnstile unit (`UNIT`), and individual turnstile device (`SCP`) at internals of four hours of the day.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nv'>full_data</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 2869965</span>

<span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/distinct.html'>distinct</a></span><span class='o'>(</span><span class='nv'>full_data</span>, <span class='nv'>CA</span>, <span class='nv'>UNIT</span>, <span class='nv'>SCP</span>, <span class='nv'>DATE</span>, <span class='nv'>TIME</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 2869965</span>
</code></pre>

</div>

Because this is raw turnstile data, the values for `ENTRIES` and `EXITS` may not be what one first expects. These fields contain the *cumulative number of turns of the turnstile* since it was last zeroed-out. Thus, to get the actual number of *incremental* entries during a given time period, one must take the difference between the current and previous number of entries *at the turnstile level*. Thus, missing or corrupted values[^4] could cascade in unpredictable ways throughout the transformation process.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>full_data</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>CA</span> <span class='o'>==</span> <span class='s'>"A002"</span>, 
         <span class='nv'>UNIT</span> <span class='o'>==</span> <span class='s'>"R051"</span>, 
         <span class='nv'>SCP</span> <span class='o'>==</span> <span class='s'>"02-00-00"</span>, 
         <span class='nv'>DATE</span> <span class='o'>==</span> <span class='s'>"2020-01-04"</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>TIME</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>TIME</span>, <span class='nv'>ENTRIES</span>, <span class='nv'>EXITS</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 6 搼㸷 3</span></span>
<span class='c'>#&gt;   TIME       ENTRIES   EXITS</span>
<span class='c'>#&gt;   <span style='color: #949494;font-style: italic;'>&lt;drtn&gt;</span><span>       </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>   </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span><span> 10800 secs 7</span><span style='text-decoration: underline;'>331</span><span>213 2</span><span style='text-decoration: underline;'>484</span><span>849</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>2</span><span> 25200 secs 7</span><span style='text-decoration: underline;'>331</span><span>224 2</span><span style='text-decoration: underline;'>484</span><span>861</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>3</span><span> 39600 secs 7</span><span style='text-decoration: underline;'>331</span><span>281 2</span><span style='text-decoration: underline;'>484</span><span>936</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>4</span><span> 54000 secs 7</span><span style='text-decoration: underline;'>331</span><span>454 2</span><span style='text-decoration: underline;'>485</span><span>014</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>5</span><span> 68400 secs 7</span><span style='text-decoration: underline;'>331</span><span>759 2</span><span style='text-decoration: underline;'>485</span><span>106</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>6</span><span> 82800 secs 7</span><span style='text-decoration: underline;'>331</span><span>951 2</span><span style='text-decoration: underline;'>485</span><span>166</span></span>
</code></pre>

</div>

### Quality checks

So how does this map to the use cases above?

First, lets consider checks that are **more rigorous by group**. One example of this is checking for completeness of the range of data.

Looking at the aggregate level, the data appears complete. The minimum data is the correct start date for the week ending Jan 10 and the maximum date is the correct end date for the week ending April 10.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span><span class='nv'>full_data</span>,
          <span class='nf'><a href='https://rdrr.io/r/base/Extremes.html'>min</a></span><span class='o'>(</span><span class='nv'>DATE</span><span class='o'>)</span>,
          <span class='nf'><a href='https://rdrr.io/r/base/Extremes.html'>max</a></span><span class='o'>(</span><span class='nv'>DATE</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 1 搼㸷 2</span></span>
<span class='c'>#&gt;   `min(DATE)` `max(DATE)`</span>
<span class='c'>#&gt;   <span style='color: #949494;font-style: italic;'>&lt;date&gt;</span><span>      </span><span style='color: #949494;font-style: italic;'>&lt;date&gt;</span><span>     </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>1</span><span> 2020-01-04  2020-04-10</span></span>
</code></pre>

</div>

This check might provide a false sense of security.

However, what happens if we repeat this check at the actual grain of records which we *need* to be complete and subsequent calculations probably assume[^5] are complete? We find many individual units whose data does not appear appropriately recent.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>full_data</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>CA</span>, <span class='nv'>UNIT</span>, <span class='nv'>SCP</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span>MAX <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Extremes.html'>max</a></span><span class='o'>(</span><span class='nv'>DATE</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>MAX</span> <span class='o'>!=</span> <span class='s'>"2020-04-10"</span><span class='o'>)</span>

<span class='c'>#&gt; `summarise()` has grouped output by 'CA', 'UNIT'. You can override using the `.groups` argument.</span>

<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 54 搼㸷 4</span></span>
<span class='c'>#&gt; <span style='color: #949494;'># Groups:   CA, UNIT [24]</span></span>
<span class='c'>#&gt;    CA    UNIT  SCP      MAX       </span>
<span class='c'>#&gt;    <span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;date&gt;</span><span>    </span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 1</span><span> C021  R212  00-00-00 2020-01-06</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 2</span><span> C021  R212  00-00-01 2020-01-06</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 3</span><span> C021  R212  00-00-02 2020-01-06</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 4</span><span> C021  R212  00-00-03 2020-01-06</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 5</span><span> H007  R248  00-00-00 2020-03-07</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 6</span><span> H007  R248  00-00-01 2020-02-15</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 7</span><span> H007  R248  00-03-00 2020-02-15</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 8</span><span> H007  R248  00-03-01 2020-02-15</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 9</span><span> H007  R248  00-03-02 2020-02-15</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>10</span><span> H009  R235  00-03-04 2020-03-20</span></span>
<span class='c'>#&gt; <span style='color: #949494;'># 㠼㸵 with 44 more rows</span></span>m
</code></pre>

</div>

Next, consider checks that are **only expressible by group**. One example of this is a monotonicity (value always increasing) check.

For example, `ENTRIES` is certainly *not* monotonically increasing at the row level. Each individual turnstile device is counting up according to its own usage. However, in an ideal world, these fields should be monotonic over time at the level of individual devices. (Spoiler alert: due to the maintenance, malfunction, and maxing-out scenarios mentioned above, it's not.) Thus, this type of check is only possible at the grouped level.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>full_data</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>CA</span>, <span class='nv'>UNIT</span>, <span class='nv'>SCP</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>DATE</span>, <span class='nv'>TIME</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>LAG_ENTRIES <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/lead-lag.html'>lag</a></span><span class='o'>(</span><span class='nv'>ENTRIES</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>ENTRIES</span> <span class='o'>&lt;</span> <span class='nv'>LAG_ENTRIES</span>, <span class='nv'>DATE</span> <span class='o'>&gt;</span> <span class='s'>'2020-01-25'</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>CA</span>, <span class='nv'>UNIT</span>, <span class='nv'>SCP</span>, <span class='nv'>DATE</span>, <span class='nv'>TIME</span>, <span class='nv'>ENTRIES</span>, <span class='nv'>LAG_ENTRIES</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/arrange.html'>arrange</a></span><span class='o'>(</span><span class='nv'>ENTRIES</span> <span class='o'>-</span> <span class='nv'>LAG_ENTRIES</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #949494;'># A tibble: 19,281 搼㸷 7</span></span>
<span class='c'>#&gt; <span style='color: #949494;'># Groups:   CA, UNIT, SCP [262]</span></span>
<span class='c'>#&gt;    CA    UNIT  SCP      DATE       TIME        ENTRIES LAG_ENTRIES</span>
<span class='c'>#&gt;    <span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #949494;font-style: italic;'>&lt;chr&gt;</span><span>    </span><span style='color: #949494;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #949494;font-style: italic;'>&lt;drtn&gt;</span><span>        </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span><span>       </span><span style='color: #949494;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 1</span><span> R231  R176  00-00-05 2020-03-09 75600 secs       99  </span><span style='text-decoration: underline;'>1</span><span>054</span><span style='text-decoration: underline;'>865</span><span>694</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 2</span><span> R412  R146  00-03-03 2020-02-04 43200 secs 51</span><span style='text-decoration: underline;'>627</span><span>403   318</span><span style='text-decoration: underline;'>991</span><span>420</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 3</span><span> N029  R333  01-00-00 2020-03-15 75600 secs       18   168</span><span style='text-decoration: underline;'>628</span><span>048</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 4</span><span> R327  R361  01-06-00 2020-03-03 72000 secs   </span><span style='text-decoration: underline;'>524</span><span>397   135</span><span style='text-decoration: underline;'>382</span><span>887</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 5</span><span> R312  R405  00-05-00 2020-02-16 57600 secs   </span><span style='text-decoration: underline;'>131</span><span>089   118</span><span style='text-decoration: underline;'>174</span><span>528</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 6</span><span> N091  R029  02-05-00 2020-02-01 54000 secs   </span><span style='text-decoration: underline;'>524</span><span>368   118</span><span style='text-decoration: underline;'>146</span><span>213</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 7</span><span> A025  R023  01-06-00 2020-03-04 82800 secs 11</span><span style='text-decoration: underline;'>525</span><span>743    67</span><span style='text-decoration: underline;'>822</span><span>764</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 8</span><span> A025  R023  01-00-00 2020-03-04 82800 secs  5</span><span style='text-decoration: underline;'>276</span><span>291    28</span><span style='text-decoration: underline;'>448</span><span>967</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'> 9</span><span> R238  R046  00-03-00 2020-02-15 82800 secs        5    16</span><span style='text-decoration: underline;'>336</span><span>060</span></span>
<span class='c'>#&gt; <span style='color: #BCBCBC;'>10</span><span> R533  R055  00-03-04 2020-03-14 43200 secs      104    15</span><span style='text-decoration: underline;'>209</span><span>650</span></span>
<span class='c'>#&gt; <span style='color: #949494;'># 㠼㸵 with 19,271 more rows</span></span>m
</code></pre>

</div>

Alternatives Considered
-----------------------

Given that this post is, to some extent, a feature request across all data quality tools ever, it's only polite to discuss downsides and alternative solutions that I considered. Clearly, finer-grained checks incur a greater computational cost and could, in some cases, be achieved via other means.

**Grouped checks are more computational expensive.** Partitioning and grouping can make data check operations more expensive by disabling certain computational shortcuts[^6] and requiring more total data to be retained. This is particularly true if the data is indexed or partitioned along different dimensions than the groups used for checks. The extra time required to run more fine-grained checks could become intractable or at least unappealing, particularly in an interactive or continuous integration context. However, in many cases it could be a better use of time to more rigorously test recently loaded data as opposed to (or in conjunction with) running higher-level checks across larger swaths of data.

**Some grouped checks can be achieved in other ways.** This is really the same argument as the third point discussed above. Some (but not all) of these checks can be mocked by creating composite variables, using other built-in features[^7], or, in the case of `Great Expectation`'s python-based API, writing custom code to partition data before applying checks[^8]. However, there solutions seem to defy part of the benefits of these tools: semantically meaningful checks wrapped in readable syntax and ready for use out-of-the-box. This also implies that grouped operations are far less than first-class citizens. This also limits the ability to make use of some of the excellent functionality these tools offer for documenting data quality checks in metadata and reporting on their outcomes.

**Grouped data check might seem excessive.** After all, data quality checks do not, perhaps, aim to guarantee every field is 100% correct. Rather, they are higher-level metrics which aim to catch signals of deeper issues. My counterargument is largely based in the first use case listed above. Without testing data at the right level of granularity, checks could almost do more harm than good if they promote a false sense of data quality by masking issues.

**"But we monitor our data with machine learning."** There's a fair amount of work currently (not necessarily with the tools that I've named) with using machine learning and anomaly detection approaches to detect data quality issues. Some might argue that these advanced approaches lessen the need for heavily tailor, user-specified data checks. Personally, I struggle to agree with that. I believe domain context can go a long way to solving data issues and is often worth the investment.

I also considered the possibility that this is a niche, personal need moreso than a general one because I work with a *lot* of panel data. However, I generally believe *most* data is nested in something, somehow than is not. I substantiated this a bit with a peak at GitHub issue feature requests in different data quality tools. For example, three stale stale GitHub issues on the `Great Expectations` repo ([1](https://github.com/great-expectations/great_expectations/issues/351), [2](https://github.com/great-expectations/great_expectations/issues/402), [3](https://github.com/great-expectations/great_expectations/issues/373)) request similar functionality.

Downsides
---------

There's no such thing as a free lunch or a free feature enhancement. My point is in no way to criticize existing data quality tools that do not have this functionality. Designing any tool is a process of trade-offs, and it's only fair to discuss the downsides. These issues are exacerbated further when adding "just one more thing" to mature, heavily used tools as opposed to developing new ones.

**API bloat makes tools less navigable.** Any new feature has to be documented by developers and comprehended by users. Having too many "first-class citizen" features can lead to features being ignored, unknown, or misused. It's easy to point to any one feature in isolation and claim it is important; it's much harder to stare at a full backlog and decide where the benefits are worth the cost.

**Incremental functionality adds more overhead.** Every new feature demands careful programming and testing. Beyond that, there's a substantial mental tax in thinking through how that feature needs to interact with existing functionality while, at the same time, preserving backwards compatibility.

**Every feature built means a different one isn't.** As a software user, it's easy to have a great idea for a feature that should absolutely be added. That's a far different challenge than that faced by the developers and maintainers who must prioritize a rich backlog full of competing priorities.

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

Code Appendix
-------------

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># data source: http://web.mta.info/developers/turnstile.html</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://readr.tidyverse.org'>readr</a></span><span class='o'>)</span>

<span class='c'># define read function with schema ----</span>
<span class='nv'>read_data</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>url</span><span class='o'>)</span> <span class='o'>{</span>
  
  <span class='nf'>readr</span><span class='nf'>::</span><span class='nf'><a href='https://readr.tidyverse.org/reference/read_delim.html'>read_csv</a></span><span class='o'>(</span><span class='nv'>url</span>,
                  col_names <span class='o'>=</span> <span class='kc'>TRUE</span>,
                  col_types <span class='o'>=</span>
                    <span class='nf'><a href='https://readr.tidyverse.org/reference/cols.html'>cols</a></span><span class='o'>(</span>
                      `C/A` <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      UNIT <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      SCP <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      STATION <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      LINENAME <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      DIVISION <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      DATE <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_datetime.html'>col_date</a></span><span class='o'>(</span>format <span class='o'>=</span> <span class='s'>"%m/%d/%Y"</span><span class='o'>)</span>,
                      TIME <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_datetime.html'>col_time</a></span><span class='o'>(</span>format <span class='o'>=</span> <span class='s'>""</span><span class='o'>)</span>,
                      DESC <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_character</a></span><span class='o'>(</span><span class='o'>)</span>,
                      ENTRIES <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_integer</a></span><span class='o'>(</span><span class='o'>)</span>,
                      EXITS <span class='o'>=</span> <span class='nf'><a href='https://readr.tidyverse.org/reference/parse_atomic.html'>col_integer</a></span><span class='o'>(</span><span class='o'>)</span>
                    <span class='o'>)</span><span class='o'>)</span>
  
<span class='o'>}</span>

<span class='c'># ridership data ----</span>
<span class='nv'>dates</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.Date.html'>seq.Date</a></span><span class='o'>(</span>from <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>'2020-01-11'</span><span class='o'>)</span>, to <span class='o'>=</span>, <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>'2020-04-11'</span><span class='o'>)</span>, by <span class='o'>=</span> <span class='s'>'7 days'</span><span class='o'>)</span>
<span class='nv'>dates_str</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/format.html'>format</a></span><span class='o'>(</span><span class='nv'>dates</span>, format <span class='o'>=</span> <span class='s'>'%y%m%d'</span><span class='o'>)</span>
<span class='nv'>dates_url</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/sprintf.html'>sprintf</a></span><span class='o'>(</span><span class='s'>'http://web.mta.info/developers/data/nyct/turnstile/turnstile_%s.txt'</span>, <span class='nv'>dates_str</span><span class='o'>)</span>
<span class='nv'>datasets</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='o'>(</span><span class='nv'>dates_url</span>, FUN <span class='o'>=</span> <span class='nv'>read_data</span><span class='o'>)</span>
<span class='nv'>full_data</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/do.call.html'>do.call</a></span><span class='o'>(</span><span class='nv'>rbind</span>, <span class='nv'>datasets</span><span class='o'>)</span>
<span class='nv'>full_data</span> <span class='o'>&lt;-</span> <span class='nv'>full_data</span><span class='o'>[</span><span class='nv'>full_data</span><span class='o'>$</span><span class='nv'>DESC</span> <span class='o'>==</span> <span class='s'>"REGULAR"</span>,<span class='o'>]</span>
<span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>full_data</span><span class='o'>)</span><span class='o'>[</span><span class='m'>1</span><span class='o'>]</span> <span class='o'>&lt;-</span> <span class='s'>"CA"</span>
</code></pre>

</div>

[^1]: With the exception of `pointblank` which kindly entertained an issue I opened on this topic: <a href="https://github.com/rich-iannone/pointblank/issues/300" class="uri">https://github.com/rich-iannone/pointblank/issues/300</a>

[^2]: The "pit of success" is the idea that well-designed tools can help nudge people to do the "right" thing by default because its also the easiest. I first learned of it in a talk by Hadley Wickham, and it is originally attributed to Microsoft program manage Rico Mariani.

[^3]: Code for this pull is at the bottom of the post.

[^4]: This can happen for many reasons including turnstile maintenance or replacement. My goal in this post is not to go into all of the nuances of this particular dataset, of which much has already been written, so I'm simplifying somewhat to keep it as a tractable motivating example.

[^5]: Transformations should probably never assume this. Any real ETL process using this data would like have to account for incompleteness in an automated fashion because it really is not a rare event. Again, we are simplifying here for the sake of example

[^6]: For example, the maximum of a set of numbers is the maximum of the maximums of the subsets. Thus, if my data is distributed, I can find the max by comparing only summary statistics from the distributed subsets instead of pulling all of the raw data back together.

[^7]: For example, Great Expectations does offer conditional expectations which can be executed on manually-specified subsets of data. This could be a tractable solution for applying data checks to a small number of categorical variables, but less so for large or ill-defined categories like user IDs. More here: <a href="https://legacy.docs.greatexpectations.io/en/latest/reference/core_concepts/conditional_expectations.html" class="uri">https://legacy.docs.greatexpectations.io/en/latest/reference/core_concepts/conditional_expectations.html</a>

[^8]: This is less possible for tools like `dbt`/`dbt-utils` where tests are defined by SQL scripts. In this set-up, separate, similar testing macros would have to be defined.

