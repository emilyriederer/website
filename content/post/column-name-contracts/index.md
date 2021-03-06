---
output: hugodown::md_document
title: "Column Names as Contracts"
subtitle: ""
summary: "Using controlled dictionaries for low-touch documentation, validation, and usability of tabular data"
authors: []
tags: [data, workflow, rstats]
categories: [data, workflow, rstats]
date: 2020-09-06
lastmod: 2020-09-06
featured: true
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
rmd_hash: b5784f42da5e4407
html_dependencies:
- <script src="htmlwidgets-1.5.1/htmlwidgets.js"></script>
- <script src="d3-4.10.2/d3.min.js"></script>
- <link href="collapsibleTree-0.1.6/collapsibleTree.css" rel="stylesheet" />
- <script src="collapsibleTree-binding-0.1.7/collapsibleTree.js"></script>

---

Software products use a range of strategies to make promises or contracts with their users. Mature code packages and APIs document expected inputs and outputs, check adherence with unit tests, and transparently report code coverage. Programs with graphical user interfaces form such contracts by labeling and illustrating interactive components to explain their intent (for example, the "Save" button typically does not bulk-delete files).

Published data tables, however, exist in an ambiguous gray area; static enough not to be considered a "service" or "software", yet too raw to earn the attention to user experience given to interfaces. This ambiguity can create a strange symbiosis between data producers and consumers. Producers may publish whatever data is accessible by the system or seems relevant, and consumers may be quick to assume tables or fields that "sound right" happen to be custom-fit for their top-of-mind question. Producers wonder why consumers aren't satisfied, and consumers wonder why the data is never "right".

Metadata management solutions aim to solve this problem, and there are many promising developments in this space including Lyft's [Amundsen](https://eng.lyft.com/amundsen-lyfts-data-discovery-metadata-engine-62d27254fbb9), LinkedIn's [DataHub](https://engineering.linkedin.com/blog/2019/data-hub), and Netflix's [Metacat](https://netflixtechblog.com/building-and-scaling-data-lineage-at-netflix-to-improve-data-infrastructure-reliability-and-1a52526a7977). However, metadata solutions generally require a great degree of cooperation: producers must vigilantly maintain the documentation and consumers must studiously check it -- despite such tools almost always living outside of either party's core toolkit and workflow.

Using [controlled vocabularies](https://en.wikipedia.org/wiki/Controlled_vocabulary) for column names is a low-tech, low-friction approach to building a shared understanding of how each field in a data set is intended to work. In this post, I'll introduce the concept with an example and demonstrate how controlled vocabularies can offer lightweight solutions to rote data validation, discoverability, and wrangling. I'll illustrate these usability benefits with R packages including `pointblank`, `collapsibleTree`, and `dplyr`, but we'll conclude by demonstrating how the same principles apply to other packages and languages.

Controlled Vocabulary
---------------------

The basic idea of controlled vocabularies is to define upfront a set of words, phrases, or stubs with well-defined meanings which can be used to index information. When these stubs are defined for different types of information and pieces together in a consistent order, the vocabulary becomes a descriptive grammar that we can use to describe more complex content and behavior.

In the context of a data set, this vocabulary can also serve as a latent contract between data producers and data consumers and carry promises regarding different aspects of the data lineage, valid values, and appropriate uses. When used consistently across all of an organization's tables, it can significantly scale data management and increase usability as knowledge from working with one dataset easily transfers to another.

For example, imagine we work at a ride-share company and are building a data table with one record per trip. What might a controlled vocabulary look like?[^1]

**Level 1: Measure Types**

For reasons that will be evident in the examples, I like the first level of the hierarchy to generally capture a semi-generic "type" of the variable. This is not quite the same as data types in a programming language (e.g. `bool`, `double`, `float`) although everything with the same prefix should ultimately be cast in the same type. Instead, these data types imply both a type of information and appropriate usage patterns:

-   `ID`: Unique identified for an entity.
    -   Numeric for more efficient storage and joins unless system of record generates IDs with characters
    -   Likely a primary key in some other table
-   `IND`: Binary 0 or 1 indicator or an event occurrence
    -   Because always 0 or 1, can be averaged to find proportion occurrence
    -   Can consider calling `IS` instead of `IND` for even less ambiguity which case is labeled 1
-   `N`: Count of quantity or event occurrence
    -   Always a non-negative integer
-   `AMT`: Sum-able real number amount. That is, any non-count amount that is "denominator-free"
-   `VAL`: Numeric variables that are not inherently sum-able
    -   For example, rates and ratios that cannot be combined or numeric values like latitude and longitude for which typical arithmetic operations don't make sense
-   `DT`: Date of some event
    -   Always cast as a `YYYY-MM-DD` date
-   `TM`: Time stamp of some event
    -   Always cast as a `YYYY-MM-DD HH:MM:SS` time stamp
    -   Distinguishing dates from time stamps will avoid faulty joins of two date fields arranged differently
-   `CAT`: Categorical variable as a character string (potentially encoded from an `ID` field)

While these are relatively generic, domain-specific categories can also be used. For example, since location is so important for ride-sharing, it might be worth having `ADDR` as a level 1 category.

**Level 2: Measure Subjects**

The best hierarchy varies widely by industry and the *overall contents of a database* -- not just one table. Here, we expect to be interested in trip-attributed about many different subjects: the rider, driver, trip, etc. so the measure subject might be the logical next tier. We can define:

-   `DRIVER`: Information about the driver
-   `RIDER`: Information about the rider, the passenger who called the ride-share
-   `TRIP`: Information about the trip itself
-   `ORIG`: Information about the trip start (time and geography)
-   `DEST`: Information about the trip destination (time and geography)
-   `COST`: Information about components of the total cost (could be a subset of `TRIP`, but pertains to all parties and has high cardinality at the next tier, so we'll break it out)

Of course, in a highly normalized database, measures of these different entities would exist in separate tables. However, this discipline in naming them would still be beneficial so quantities are unambiguous when an analyst combines them.

**Levels 3-n: Details**

The first few tiers of the hierarchy are critical to standardize to make our "performance promises" and to aid in data searchability. Later levels will be measure specific and may not be worth defining upfront. However, for concepts that are going to exist across many tables, it is worthwhile to pre-specify their names and precise formats. For example:

-   `CITY`: Should this be in all upper case? How should spaces in city name be treated?
-   `ZIP`: Should 6 digit or 10 digit zip codes be used?
-   `LAT`/`LON`: To how many decimals should latitude and longitude be geocoded? If the company only operate in certain geographic areas (e.g. the continental US), coarse cut-offs for these can be determined
-   `DIST`: Is distance measured in miles? Kilometers?
-   `TIME`: Are durations measured in seconds? Minutes?
-   `RATING`: What are valid ranges for other known quantities like star ratings?

Terminal "adjectives" could also be considered. For example, if the data-generating systems spit out analytically unideal quantities that should be preserved for data lineage purposes, suffixes such as `_RAW` and `_CLEAN` might denote version of the same variable in its original and manicured states, respectively.

**Putting it all together**

This structure now gives us a grammar to compactly name 35 variables in table:

-   `ID_{DRIVER | RIDER | TRIP}`: Unique identifier for party of the ride
-   `DT_{ORIG | DEST}`: Date at the trip's start and end, respectively
-   `TM_{ORIG | DEST}`: Timestamp at the trip's start and end, respectively
-   `N_TRIP_{PASSENGERS | ORIG | DEST}` Count of unique passengers, pick-up points, and drop-off points for the trip
-   `N_DRIVER_SEATS`: Count of passenger seats available in the driver's car
-   `AMT_TRIP_{DIST | TIME}`: Total trip distance in miles traveled and time taken
-   `AMT_COST_{TIME | DIST | BASE | FEES | SURGE | TIPS}`: Amount of each cost component
-   `IND_SURGE`: Indicator variable if ride caled during surge pricing
-   `CAT_TRIP_TYPE`: Trip type, such as 'Pool', 'Standard', 'Elite'
-   `CAT_RIDER_TYPE`: Rider status, such as 'Basic', 'Frequent', 'Subscription'
-   `VAL_{DRIVER | RIDER}_RATING`: Average star rating of rider and driver
-   `ADDR_{ORIG | DEST}_{STREET | CITY | STATE | ZIP}`: Address components of trip's start and end
-   `VAL_{ORIG | DEST}_{LAT | LON}`: Latitude and longitude of trip's start and end

The fact that we can describe 35 variables in roughly 1/3 the number of rows already speaks to the value of this structure in helping data consumers build a strong mental model to quickly manipulate the data. But now we can demonstrate far greater value.

To start, we create a small fake data set using our schema. For simplicity, I simulate 18 of the 35 variables listed above:

<div class="highlight">

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nv'>data_trips</span><span class='o'>)</span>

<span class='c'>#&gt;   ID_DRIVER ID_RIDER ID_TRIP    DT_ORIG    DT_DEST N_DRIVER_PASSENGERS</span>
<span class='c'>#&gt; 1      5698     1027    9714 2019-12-28 2019-12-28                   1</span>
<span class='c'>#&gt; 2      6458     7822    7405 2019-09-07 2019-09-07                   1</span>
<span class='c'>#&gt; 3      4838     5968    8554 2019-05-14 2019-05-14                   2</span>
<span class='c'>#&gt; 4      3785     2309    1241 2019-08-16 2019-08-16                   2</span>
<span class='c'>#&gt; 5      4539     9109    2017 2019-03-25 2019-03-25                   1</span>
<span class='c'>#&gt; 6      4007     6878    1698 2019-09-09 2019-09-09                   1</span>
<span class='c'>#&gt;   N_TRIP_ORIG N_TRIP_DEST AMT_TRIP_DIST IND_SURGE VAL_DRIVER_RATING</span>
<span class='c'>#&gt; 1           1           1      24.98156         0          2.228128</span>
<span class='c'>#&gt; 2           1           1      11.32751         1          3.678452</span>
<span class='c'>#&gt; 3           1           1      25.71858         1          1.531821</span>
<span class='c'>#&gt; 4           1           1      13.86827         0          1.982823</span>
<span class='c'>#&gt; 5           1           1      25.05063         1          2.371799</span>
<span class='c'>#&gt; 6           1           1      16.00619         0          1.585752</span>
<span class='c'>#&gt;   VAL_RIDER_RATING VAL_ORIG_LAT VAL_DEST_LAT VAL_ORIG_LON VAL_DEST_LON</span>
<span class='c'>#&gt; 1         3.253223     41.24602     40.48390    108.44754    102.87971</span>
<span class='c'>#&gt; 2         3.466021     40.26759     41.66849    108.23701     93.70541</span>
<span class='c'>#&gt; 3         3.316094     40.40432     40.94727     82.81049     90.85842</span>
<span class='c'>#&gt; 4         4.862184     40.52839     41.43372     71.78928    119.20213</span>
<span class='c'>#&gt; 5         4.436828     40.29525     41.86572    112.69544    118.53023</span>
<span class='c'>#&gt; 6         1.217744     41.29352     41.79860    117.98442    108.41519</span>
<span class='c'>#&gt;   CAT_TRIP_TYPE CAT_RIDER_TYPE</span>
<span class='c'>#&gt; 1         Elite       Frequent</span>
<span class='c'>#&gt; 2         Elite   Subscription</span>
<span class='c'>#&gt; 3          Pool          Basic</span>
<span class='c'>#&gt; 4          Pool          Basic</span>
<span class='c'>#&gt; 5         Elite       Frequent</span>
<span class='c'>#&gt; 6      Standard          Basic</span>
</code></pre>

</div>

Data Validation
---------------

The "promises" in variable names aren't just there for decoration. They can actually help producers publish higher quality data my helping to automate data validation checks. Data quality is context-specific and requires effort on the consumer side, but setting up safeguards in any data pipeline can help detect and eliminate commonplace errors like duplicated or corrupt data.

Of course, setting up data validation pipelines isn't the most exciting part of any data engineer's job. But that's where R's `pointblank` package comes to the rescue with an excellent domain-specific language for common assertive data checks. Combining this syntax with `dplyr`'s "select helpers" (such as [`starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html)), the same validation pipeline could ensure many of the data's promises are kept with no additional overhead. For example, `N_` columns should be strictly non-negative and `IND_` columns should always be either 0 or 1.

The following example demonstrate the R syntax to write such a pipeline in `pointblank`, but the package also allows rules to be specified in a standalone YAML file which could further increase portability between projects.

<div class="highlight">

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>agent</span> <span class='o'>&lt;-</span>
  <span class='nv'>data_trips</span> <span class='o'>%&gt;%</span>
  <span class='nf'>create_agent</span><span class='o'>(</span>actions <span class='o'>=</span> <span class='nf'>action_levels</span><span class='o'>(</span>stop_at <span class='o'>=</span> <span class='m'>0.001</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>col_vals_gte</span><span class='o'>(</span><span class='nf'>starts_with</span><span class='o'>(</span><span class='s'>"N"</span><span class='o'>)</span>, <span class='m'>0</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>col_vals_gte</span><span class='o'>(</span><span class='nf'>starts_with</span><span class='o'>(</span><span class='s'>"N"</span><span class='o'>)</span>, <span class='m'>0</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>col_vals_not_null</span><span class='o'>(</span><span class='nf'>starts_with</span><span class='o'>(</span><span class='s'>"IND"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>col_vals_in_set</span><span class='o'>(</span><span class='nf'>starts_with</span><span class='o'>(</span><span class='s'>"IND"</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0</span>,<span class='m'>1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>col_is_date</span><span class='o'>(</span><span class='nf'>starts_with</span><span class='o'>(</span><span class='s'>"DT"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>col_vals_between</span><span class='o'>(</span><span class='nf'>matches</span><span class='o'>(</span><span class='s'>"_LAT(_|$)"</span><span class='o'>)</span>, <span class='m'>19</span>, <span class='m'>65</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>col_vals_between</span><span class='o'>(</span><span class='nf'>matches</span><span class='o'>(</span><span class='s'>"_LON(_|$)"</span><span class='o'>)</span>, <span class='o'>-</span><span class='m'>162</span>, <span class='o'>-</span><span class='m'>68</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>interrogate</span><span class='o'>(</span><span class='o'>)</span>
</code></pre>

</div>

<div class="highlight">

</div>

![](featured.png) In the example above, just 7 lines of portable table-agnostic code end up creating 14 data validation checks. The results catch two errors. Upon investigation[^2], we find that our geocoder is incorrectly flipping the sign on longitude!

One could also imagine writing a linter or validator of the variables names themselves to check for typos, outliers that don't follow common stubs, etc.

Data Discoverability
--------------------

On the user side, a controlled vocabulary makes new data easier to explore. Although is is not and should not be a replacement for a true data dictionary, imagine how relatively easy it is to understand the following variables' intent and navigate either a searchable tab of visualization of the output.

To make some accessible outputs, we can first wrangle the column names into a table of their own.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>cols_trips</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>data_trips</span><span class='o'>)</span>
<span class='nv'>cols_trips_split</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/strsplit.html'>strsplit</a></span><span class='o'>(</span><span class='nv'>cols_trips</span>, split <span class='o'>=</span> <span class='s'>"_"</span><span class='o'>)</span>
<span class='nv'>cols_components</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  variable <span class='o'>=</span> <span class='nv'>cols_trips</span>,
  level1 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>vapply</a></span><span class='o'>(</span><span class='nv'>cols_trips_split</span>, FUN <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span><span class='o'>[</span><span class='m'>1</span><span class='o'>]</span>, FUN.VALUE <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>,
  level2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>vapply</a></span><span class='o'>(</span><span class='nv'>cols_trips_split</span>, FUN <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span><span class='o'>[</span><span class='m'>2</span><span class='o'>]</span>, FUN.VALUE <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>,
  level3 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>vapply</a></span><span class='o'>(</span><span class='nv'>cols_trips_split</span>, FUN <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nv'>x</span><span class='o'>[</span><span class='m'>3</span><span class='o'>]</span>, FUN.VALUE <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>character</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nv'>cols_components</span><span class='o'>)</span>

<span class='c'>#&gt;              variable level1 level2     level3</span>
<span class='c'>#&gt; 1           ID_DRIVER     ID DRIVER       &lt;NA&gt;</span>
<span class='c'>#&gt; 2            ID_RIDER     ID  RIDER       &lt;NA&gt;</span>
<span class='c'>#&gt; 3             ID_TRIP     ID   TRIP       &lt;NA&gt;</span>
<span class='c'>#&gt; 4             DT_ORIG     DT   ORIG       &lt;NA&gt;</span>
<span class='c'>#&gt; 5             DT_DEST     DT   DEST       &lt;NA&gt;</span>
<span class='c'>#&gt; 6 N_DRIVER_PASSENGERS      N DRIVER PASSENGERS</span>
</code></pre>

</div>

Part of the metadata, then, could make it particularly easy to search by various stubs -- whether that be the measure type (e.g. `N` or `AMT`) or the measure subject (e.g. `RIDER` or `DRIVER`).^\[DT output with searchable columns[^3]

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/rstudio/DT'>DT</a></span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/pkg/DT/man/datatable.html'>datatable</a></span><span class='o'>(</span><span class='nv'>cols_components</span>,  filter <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>position <span class='o'>=</span> <span class='s'>'top'</span>, clear <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>

</div>

![](datatable.png)

Similarly, we can use visualization to both validate and explore the available fields. Below, data fields are illustrated in a tree.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/AdeelK93/collapsibleTree'>collapsibleTree</a></span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/pkg/collapsibleTree/man/collapsibleTree.html'>collapsibleTree</a></span><span class='o'>(</span><span class='nv'>cols_components</span>, 
                hierarchy <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"level"</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>)</span>,
                nodeSize <span class='o'>=</span> <span class='s'>"leafCount"</span>
                <span class='o'>)</span>

<!--html_preserve--><div id="htmlwidget-f9800c11f94ae72cf3f7" style="width:700px;height:415.296px;" class="collapsibleTree html-widget"></div>
<script type="application/json" data-for="htmlwidget-f9800c11f94ae72cf3f7">{"x":{"data":{"name":"cols_components","SizeOfNode":29.8,"children":[{"name":"ID","SizeOfNode":12.17,"children":[{"name":"DRIVER","SizeOfNode":7.02},{"name":"RIDER","SizeOfNode":7.02},{"name":"TRIP","SizeOfNode":7.02}]},{"name":"DT","SizeOfNode":9.93,"children":[{"name":"ORIG","SizeOfNode":7.02},{"name":"DEST","SizeOfNode":7.02}]},{"name":"N","SizeOfNode":12.17,"children":[{"name":"DRIVER","SizeOfNode":7.02,"children":[{"name":"PASSENGERS","SizeOfNode":7.02}]},{"name":"TRIP","SizeOfNode":9.93,"children":[{"name":"ORIG","SizeOfNode":7.02},{"name":"DEST","SizeOfNode":7.02}]}]},{"name":"AMT","SizeOfNode":7.02,"children":[{"name":"TRIP","SizeOfNode":7.02,"children":[{"name":"DIST","SizeOfNode":7.02}]}]},{"name":"IND","SizeOfNode":7.02,"children":[{"name":"SURGE","SizeOfNode":7.02}]},{"name":"VAL","SizeOfNode":17.21,"children":[{"name":"DRIVER","SizeOfNode":7.02,"children":[{"name":"RATING","SizeOfNode":7.02}]},{"name":"RIDER","SizeOfNode":7.02,"children":[{"name":"RATING","SizeOfNode":7.02}]},{"name":"ORIG","SizeOfNode":9.93,"children":[{"name":"LAT","SizeOfNode":7.02},{"name":"LON","SizeOfNode":7.02}]},{"name":"DEST","SizeOfNode":9.93,"children":[{"name":"LAT","SizeOfNode":7.02},{"name":"LON","SizeOfNode":7.02}]}]},{"name":"CAT","SizeOfNode":9.93,"children":[{"name":"TRIP","SizeOfNode":7.02,"children":[{"name":"TYPE","SizeOfNode":7.02}]},{"name":"RIDER","SizeOfNode":7.02,"children":[{"name":"TYPE","SizeOfNode":7.02}]}]}]},"options":{"hierarchy":["level1","level2","level3"],"input":null,"attribute":"leafCount","linkLength":null,"fontSize":10,"tooltip":false,"collapsed":true,"zoomable":true,"margin":{"top":20,"bottom":20,"left":119.8,"right":75},"fill":"lightsteelblue"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve--></code></pre>

</div>

Depending on the type of exploraion being done, it might be more convenient to drilldown first by measure subject. `collapsibleTree` flexibly lets us control this by specifying the `hierarchy`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/collapsibleTree/man/collapsibleTree.html'>collapsibleTree</a></span><span class='o'>(</span><span class='nv'>cols_components</span>, 
                hierarchy <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"level"</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>2</span>,<span class='m'>1</span>,<span class='m'>3</span><span class='o'>)</span><span class='o'>)</span>,
                nodeSize <span class='o'>=</span> <span class='s'>"leafCount"</span>
                <span class='o'>)</span>

<!--html_preserve--><div id="htmlwidget-13420b62cf5b079fe4ed" style="width:700px;height:415.296px;" class="collapsibleTree html-widget"></div>
<script type="application/json" data-for="htmlwidget-13420b62cf5b079fe4ed">{"x":{"data":{"name":"cols_components","SizeOfNode":24.33,"children":[{"name":"DRIVER","SizeOfNode":9.93,"children":[{"name":"ID","SizeOfNode":5.74},{"name":"N","SizeOfNode":5.74,"children":[{"name":"PASSENGERS","SizeOfNode":5.74}]},{"name":"VAL","SizeOfNode":5.74,"children":[{"name":"RATING","SizeOfNode":5.74}]}]},{"name":"RIDER","SizeOfNode":9.93,"children":[{"name":"ID","SizeOfNode":5.74},{"name":"VAL","SizeOfNode":5.74,"children":[{"name":"RATING","SizeOfNode":5.74}]},{"name":"CAT","SizeOfNode":5.74,"children":[{"name":"TYPE","SizeOfNode":5.74}]}]},{"name":"TRIP","SizeOfNode":12.83,"children":[{"name":"ID","SizeOfNode":5.74},{"name":"N","SizeOfNode":8.11,"children":[{"name":"ORIG","SizeOfNode":5.74},{"name":"DEST","SizeOfNode":5.74}]},{"name":"AMT","SizeOfNode":5.74,"children":[{"name":"DIST","SizeOfNode":5.74}]},{"name":"CAT","SizeOfNode":5.74,"children":[{"name":"TYPE","SizeOfNode":5.74}]}]},{"name":"ORIG","SizeOfNode":9.93,"children":[{"name":"DT","SizeOfNode":5.74},{"name":"VAL","SizeOfNode":8.11,"children":[{"name":"LAT","SizeOfNode":5.74},{"name":"LON","SizeOfNode":5.74}]}]},{"name":"DEST","SizeOfNode":9.93,"children":[{"name":"DT","SizeOfNode":5.74},{"name":"VAL","SizeOfNode":8.11,"children":[{"name":"LAT","SizeOfNode":5.74},{"name":"LON","SizeOfNode":5.74}]}]},{"name":"SURGE","SizeOfNode":5.74,"children":[{"name":"IND","SizeOfNode":5.74}]}]},"options":{"hierarchy":["level2","level1","level3"],"input":null,"attribute":"leafCount","linkLength":null,"fontSize":10,"tooltip":false,"collapsed":true,"zoomable":true,"margin":{"top":20,"bottom":20,"left":114.33,"right":75},"fill":"lightsteelblue"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve--></code></pre>

</div>

These naming conventions are particularly friendly to a "passive search" via an IDE with autocomplete functionality. Simply typing "`N_`" and pausing or hitting tab might elicit a list of potential options of count variables in the data set.

More broadly, driving this standardization opens up interesting possibility for variable-first documentation. As our grammar for describing fields becomes richer and less ambiguous, it's increasingly possible for users to explore a variable-first web of quantities and work their way back to the appropriate tables which contain them.

Data Wrangling
--------------

Controlled, hierarchical vocabularies also make basic data wrangling pipelines a breeze. By programming on the column names, we can appropriately summarize multiple pieces of data in the most relevant way.

For example, the following code uses `dplyr`'s "select helpers" to sum up count variables where we might reasonably be interested in the total and find the arithmetic average of indicator variables to help us calculate the proportion of occurrences of an event (here, the incidence of surge pricing).

Note what our controlled vocabulary and the implied "contracts" have given us. We aren't summing up fields like latitude and longitude which would have no inherent meaning. Conversely, we can confidently calculate proportions which we couldn't do if there was a chance our indicator variable contained nulls or occasionally used other numbers (e.g. `2`) to denote something like the surge severity instead of pure incidence.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span>

<span class='nv'>data_trips</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>CAT_RIDER_TYPE</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"N_"</span><span class='o'>)</span>, <span class='nv'>sum</span><span class='o'>)</span>,
    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"IND_"</span><span class='o'>)</span>, <span class='nv'>mean</span><span class='o'>)</span>
  <span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 5</span></span>
<span class='c'>#&gt;   CAT_RIDER_TYPE N_DRIVER_PASSENGERS N_TRIP_ORIG N_TRIP_DEST IND_SURGE</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>                        </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>       </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>       </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> Basic                           51          31          31     0.548</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> Frequent                        53          33          33     0.485</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> Subscription                    54          36          36     0.5</span></span>
</code></pre>

</div>

Addendum on Other Languages
---------------------------

The above examples use a few specific R packages with helpers that specifically operate on column names. However, the value of this approach is language agnostic since most popular languages for data manipulation support character pattern matching and wrangling operations specified by lists of variable names. We will conclude with a few examples.

### Generating SQL

Although SQL is a hard language to "program on", many programming-friendly tools offer SQL generators. For example, using `dbplyr`, we can use R to generate SQL code that sums up all of our count variables by rider type without having to type them out manually.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbplyr.tidyverse.org/'>dbplyr</a></span><span class='o'>)</span>

<span class='nv'>df_mem</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbplyr.tidyverse.org/reference/memdb_frame.html'>memdb_frame</a></span><span class='o'>(</span><span class='nv'>data_trips</span>, .name <span class='o'>=</span> <span class='s'>"example_table"</span><span class='o'>)</span>

<span class='nv'>df_mem</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>CAT_RIDER_TYPE</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise_all.html'>summarize_at</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/vars.html'>vars</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>starts_with</a></span><span class='o'>(</span><span class='s'>"N_"</span><span class='o'>)</span><span class='o'>)</span>, <span class='nv'>sum</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; &lt;SQL&gt;</span>
<span class='c'>#&gt; SELECT `CAT_RIDER_TYPE`, SUM(`N_DRIVER_PASSENGERS`) AS `N_DRIVER_PASSENGERS`, SUM(`N_TRIP_ORIG`) AS `N_TRIP_ORIG`, SUM(`N_TRIP_DEST`) AS `N_TRIP_DEST`</span>
<span class='c'>#&gt; FROM `example_table`</span>
<span class='c'>#&gt; GROUP BY `CAT_RIDER_TYPE`</span>
</code></pre>

</div>

### R - `base` & `data.table`

However, we aren't of course limited just to `tidyverse` style coding. Similarly concise workflows exists in both `base` and `data.table` syntaxes. Suppose we wanted to summarize all numeric variables. First, we can use [`base::grep`](https://rdrr.io/r/base/grep.html) to find all column names that begin with `N_`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>cols_n</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/grep.html'>grep</a></span><span class='o'>(</span><span class='s'>"^N_"</span>, <span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nv'>data_trips</span><span class='o'>)</span>, value <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='nv'>cols_n</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "N_DRIVER_PASSENGERS" "N_TRIP_ORIG"         "N_TRIP_DEST"</span>
</code></pre>

</div>

We can define the variables we want to group by in another vector.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>cols_grp</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"CAT_RIDER_TYPE"</span><span class='o'>)</span>
</code></pre>

</div>

These vectors can be used in aggregation operations such as [`stats::aggregate`](https://rdrr.io/r/stats/aggregate.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/stats/aggregate.html'>aggregate</a></span><span class='o'>(</span><span class='nv'>data_trips</span><span class='o'>[</span><span class='nv'>cols_n</span><span class='o'>]</span>, by <span class='o'>=</span> <span class='nv'>data_trips</span><span class='o'>[</span><span class='nv'>cols_grp</span><span class='o'>]</span>, FUN <span class='o'>=</span> <span class='nv'>sum</span><span class='o'>)</span>

<span class='c'>#&gt;   CAT_RIDER_TYPE N_DRIVER_PASSENGERS N_TRIP_ORIG N_TRIP_DEST</span>
<span class='c'>#&gt; 1          Basic                  51          31          31</span>
<span class='c'>#&gt; 2       Frequent                  53          33          33</span>
<span class='c'>#&gt; 3   Subscription                  54          36          36</span>
</code></pre>

</div>

Or with `data.table` syntax:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://r-datatable.com'>data.table</a></span><span class='o'>)</span>
<span class='nv'>dt</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://Rdatatable.gitlab.io/data.table/reference/as.data.table.html'>as.data.table</a></span><span class='o'>(</span><span class='nv'>data_trips</span><span class='o'>)</span>
<span class='nv'>dt</span><span class='o'>[</span>, <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='o'>(</span><span class='nv'>.SD</span>, <span class='nv'>sum</span><span class='o'>)</span>, by <span class='o'>=</span> <span class='nv'>cols_grp</span>, .SDcols <span class='o'>=</span> <span class='nv'>cols_n</span><span class='o'>]</span>

<span class='c'>#&gt;    CAT_RIDER_TYPE N_DRIVER_PASSENGERS N_TRIP_ORIG N_TRIP_DEST</span>
<span class='c'>#&gt; 1:       Frequent                  53          33          33</span>
<span class='c'>#&gt; 2:   Subscription                  54          36          36</span>
<span class='c'>#&gt; 3:          Basic                  51          31          31</span>
</code></pre>

</div>

### python `pandas`

Similarly, we can use list comprehensions in python to create a list of columns names matching a specific pattern (`cols_n`). This list and a list to define grouping variables can be passed to `pandas`'s data manipulation methods.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>import pandas as pd
cols_n   = [vbl for vbl in data_trips.columns if vbl[0:2] == 'N_']
cols_grp = ["CAT_RIDER_TYPE"]
data_trips.groupby(cols_grp)[cols_n].sum()

#>                 N_DRIVER_PASSENGERS  N_TRIP_ORIG  N_TRIP_DEST
#> CAT_RIDER_TYPE                                               
#> Basic                            51         31.0         31.0
#> Frequent                         53         33.0         33.0
#> Subscription                     54         36.0         36.0
</code></pre>

</div>

Updates
-------

### Concept Map

Thanks to Greg Wilson for helping illustrate the concepts from this post in a concept map:

![](concept-map.png)

### New Package (Dec 2020)

Since writing this post, I have released the [convo](https://emilyriederer.github.io/convo/reference/index.html) R package to facilitate maintenance and application of controlled vocabularies. Please check it out and let me know what you think!

### New Package (April 2021)

I also released a dbt package called [dbtplyr](https://github.com/emilyriederer/dbtplyr) to port `dplyr`'s useful select-helper semantics to SQL via [dbt](http://getdbt.com/).

[^1]: Again, vocabularies should span a database -- not just an individual dataset, but for simplicity we just talk through a smaller example.

[^2]: the output of `pointblank` is actually an interactive table. For blog-specific reasons, I show only the `png` here.

[^3]: As with `pointblank`, `DT` output is interactive, but my blog unfortunately reacts poorly to the extra JavaScript so for now I'm only showing an image

