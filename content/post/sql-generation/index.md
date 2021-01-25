---
output: hugodown::md_document
title: "Generating SQL with {dbplyr} and sqlfluff"
subtitle: ""
summary: "Using the tidyverse's expressive data wrangling vocabulary as a preprocessor for elegant SQL scripts"
authors: []
tags: [rstats, data, sql]
categories: [rstats, data, sql]
date: 2021-01-16
lastmod: 2021-01-16
featured: false
draft: false
aliases:

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "Photo by [Markus Spiske](https://unsplash.com/@markusspiske) on Unsplash"
  focal_point: ""
  preview_only: true

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: ba75ba8490cc88f7

---

[Declarative programming languages](https://en.wikipedia.org/wiki/Declarative_programming) such as HTML, CSS, and SQL are popular because they allow users to focus more on the desired *outcome* than the exact computational steps required to achieve that outcome. This can increase efficiency and code readability since programmers describe what they *want* -- whether that be how their website is laid out (without worrying about how the browser computes this layout) or how a dataset is structured (regardless of how the database goes about obtaining and aggregating this data).

However, sometimes this additional layer of abstraction can introduce problems of its own. Most notably, the lack of common [control flow](https://en.wikipedia.org/wiki/Control_flow) can introduce a lot of redundancy. This is part of the motivation for *pre-processing* tools which use more imperative programming concepts such as local variables and for-loops to automatically generate declarative code. Common examples in the world of web development are [Sass](https://sass-lang.com/) for CSS and [Haml](https://haml.info/docs/yardoc/file.REFERENCE.html) for HTML. Of course, such tools naturally come at a cost of their own by requiring developers to learn yet another tool.[^1]

For R (or, specifically `tidyverse`) users who need to generate SQL code, recent advances in [`dplyr v1.0.0`](https://dplyr.tidyverse.org/) and [`dbplyr v2.0.0`](https://dbplyr.tidyverse.org/) pose an interesting alternative. By using efficient, readable, and most important *familiar* syntax, users can generate accurate SQL queries that could otherwise be error-prone to write. For example, computing sums and means for a large number of variables. Coupled with the power of [`sqlfluff`](https://www.sqlfluff.com/), an innovative SQL styler which was announced at DBT's recent [coalesce conference](https://www.getdbt.com/coalesce/agenda/presenting-sqlfluff), these queries can be made not only accurate but also imminently readable.

The basic approach
------------------

In the following example, I'll briefly walk through the process of generating readable, well-styled SQL using `dbplyr` and `sqlfluff`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbplyr.tidyverse.org/'>dbplyr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://r-dbi.github.io/DBI'>DBI</a></span><span class='o'>)</span>
</code></pre>

</div>

First, we would connect to our database using the `DBI` package. For the sake of example, I simply connect to an "in-memory" database, but [a wide range of database connectors](https://db.rstudio.com/) are available depending on where your data lives.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RSQLite</span><span class='nf'>::</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, dbname <span class='o'>=</span> <span class='s'>":memory:"</span><span class='o'>)</span>
</code></pre>

</div>

Again, *for the sake of this tutorial only*, I will write the [`palmerpenguins::penguins`](https://allisonhorst.github.io/palmerpenguins/reference/penguins.html) data to our database. Typically, data would already exist in the database of interest.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://dplyr.tidyverse.org/reference/copy_to.html'>copy_to</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='nf'>palmerpenguins</span><span class='nf'>::</span><span class='nv'><a href='https://allisonhorst.github.io/palmerpenguins/reference/penguins.html'>penguins</a></span>, <span class='s'>"penguins"</span><span class='o'>)</span>
</code></pre>

</div>

For reference, the data looks like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nf'>palmerpenguins</span><span class='nf'>::</span><span class='nv'><a href='https://allisonhorst.github.io/palmerpenguins/reference/penguins.html'>penguins</a></span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 6 x 8</span></span>
<span class='c'>#&gt;   species island bill_length_mm bill_depth_mm flipper_length_㠼㸵 body_mass_g sex  </span> 
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;fct&gt;</span><span>   </span><span style='color: #555555;font-style: italic;'>&lt;fct&gt;</span><span>           </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>         </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>       </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;fct&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> Adelie  Torge㠼㸵           39.1          18.7              181        </span><span style='text-decoration: underline;'>3</span><span>750 male </span></span> 
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> Adelie  Torge㠼㸵           39.5          17.4              186        </span><span style='text-decoration: underline;'>3</span><span>800 fema㠼㸵</span></span>a…
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> Adelie  Torge㠼㸵           40.3          18                195        </span><span style='text-decoration: underline;'>3</span><span>250 fema㠼㸵</span></span>a…
<span class='c'>#&gt; <span style='color: #555555;'>4</span><span> Adelie  Torge㠼㸵           </span><span style='color: #BB0000;'>NA</span><span>            </span><span style='color: #BB0000;'>NA</span><span>                 </span><span style='color: #BB0000;'>NA</span><span>          </span><span style='color: #BB0000;'>NA</span><span> </span><span style='color: #BB0000;'>NA</span><span>   </span></span> 
<span class='c'>#&gt; <span style='color: #555555;'>5</span><span> Adelie  Torge㠼㸵           36.7          19.3              193        </span><span style='text-decoration: underline;'>3</span><span>450 fema㠼㸵</span></span>a…
<span class='c'>#&gt; <span style='color: #555555;'>6</span><span> Adelie  Torge㠼㸵           39.3          20.6              190        </span><span style='text-decoration: underline;'>3</span><span>650 male </span></span> 
<span class='c'>#&gt; <span style='color: #555555;'># 㠼㸵 with 1 more variable: year </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>m
</code></pre>

</div>

Now, we're done with set-up. Suppose we want to write a SQL query to calculate the sum, mean, and variance for all of the measures in our dataset measured in milimeters (and ending in "mm"). We can accomplish this by using the [`tbl()`](https://dplyr.tidyverse.org/reference/tbl.html) function to connect to our database's data and describing the results we want with `dplyr`'s elegant syntax. This is now made especially concise with select helpers (e.g. [`ends_with()`](https://tidyselect.r-lib.org/reference/starts_with.html)) and the [`across()`](https://dplyr.tidyverse.org/reference/across.html) function.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>penguins</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/tbl.html'>tbl</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='s'>"penguins"</span><span class='o'>)</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>penguins_aggr</span> <span class='o'>&lt;-</span>
  <span class='nv'>penguins</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>species</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span>
    N <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span>,
    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>ends_with</a></span><span class='o'>(</span><span class='s'>"mm"</span><span class='o'>)</span>, <span class='nv'>sum</span>, .names <span class='o'>=</span> <span class='s'>"TOT_{.col}"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>ends_with</a></span><span class='o'>(</span><span class='s'>"mm"</span><span class='o'>)</span>, <span class='nv'>var</span>, .names <span class='o'>=</span> <span class='s'>"VAR_{.col}"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>ends_with</a></span><span class='o'>(</span><span class='s'>"mm"</span><span class='o'>)</span>, <span class='nv'>mean</span>, .names <span class='o'>=</span> <span class='s'>"AVG_{.col}"</span><span class='o'>)</span>,
  <span class='o'>)</span>
<span class='nv'>penguins_aggr</span>

<span class='c'>#&gt; <span style='color: #555555;'># Source:   lazy query [?? x 11]</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># Database: sqlite 3.33.0 [:memory:]</span></span>
<span class='c'>#&gt;   species     N TOT_bill_length㠼㸵 TOT_bill_depth_㠼㸵 TOT_flipper_len㠼㸵</span>en…
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>   </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> Adelie    152            </span><span style='text-decoration: underline;'>5</span><span>858.            </span><span style='text-decoration: underline;'>2</span><span>770.            </span><span style='text-decoration: underline;'>28</span><span>683</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> Chinst㠼㸵    68            </span><span style='text-decoration: underline;'>3</span><span>321.            </span><span style='text-decoration: underline;'>1</span><span>253.            </span><span style='text-decoration: underline;'>13</span><span>316</span></span>6
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> Gentoo    124            </span><span style='text-decoration: underline;'>5</span><span>843.            </span><span style='text-decoration: underline;'>1</span><span>843.            </span><span style='text-decoration: underline;'>26</span><span>714</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># 㠼㸵 with 6 more variables: VAR_bill_length_mm </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, VAR_bill_depth_mm </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,</span></span>m
<span class='c'>#&gt; <span style='color: #555555;'>#   VAR_flipper_length_mm </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, AVG_bill_length_mm </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   AVG_bill_depth_mm </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, AVG_flipper_length_mm </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
</code></pre>

</div>

However, since we are using a remote backend, the `penguins_aggr` object does not contain the resulting data that we see when it is printed (forcing its execution). Instead, it contains a reference to the database's table and an accumulation of commands than need to be run on the table in the future. We can access this underlying SQL translation with the `dbplyr::show_query()` and use [`capture.output()`](https://rdrr.io/r/utils/capture.output.html) to convert that query (otherwise printed to the R console) to a character vector.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>penguins_query</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/utils/capture.output.html'>capture.output</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='nv'>penguins_aggr</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>penguins_query</span>

<span class='c'>#&gt; [1] "&lt;SQL&gt;"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              </span>
<span class='c'>#&gt; [2] "SELECT `species`, COUNT(*) AS `N`, SUM(`bill_length_mm`) AS `TOT_bill_length_mm`, SUM(`bill_depth_mm`) AS `TOT_bill_depth_mm`, SUM(`flipper_length_mm`) AS `TOT_flipper_length_mm`, VARIANCE(`bill_length_mm`) AS `VAR_bill_length_mm`, VARIANCE(`bill_depth_mm`) AS `VAR_bill_depth_mm`, VARIANCE(`flipper_length_mm`) AS `VAR_flipper_length_mm`, AVG(`bill_length_mm`) AS `AVG_bill_length_mm`, AVG(`bill_depth_mm`) AS `AVG_bill_depth_mm`, AVG(`flipper_length_mm`) AS `AVG_flipper_length_mm`"</span>
<span class='c'>#&gt; [3] "FROM `penguins`"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    </span>
<span class='c'>#&gt; [4] "GROUP BY `species`"</span>
</code></pre>

</div>

At this point, we already have a function SQL query and have saved ourselves the hassle of writing nine typo-free aggregation functions. However, since `dbplyr` was not written to generate "pretty" queries, this is not the most readable or well-formatted code. To clean it up, we can apply the `sqlfluff` linter and styler.

As a prerequisite, we slightly reformat the query to remove anything that isn't native to common SQL and will confuse the linter, such as the first line of the query vector: `<SQL>`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>penguins_query</span> <span class='o'>&lt;-</span> <span class='nv'>penguins_query</span><span class='o'>[</span><span class='m'>2</span><span class='o'>:</span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>penguins_query</span><span class='o'>)</span><span class='o'>]</span>
<span class='nv'>penguins_query</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/grep.html'>gsub</a></span><span class='o'>(</span><span class='s'>"`"</span>, <span class='s'>""</span>, <span class='nv'>penguins_query</span><span class='o'>)</span>
<span class='nv'>penguins_query</span>

<span class='c'>#&gt; [1] "SELECT species, COUNT(*) AS N, SUM(bill_length_mm) AS TOT_bill_length_mm, SUM(bill_depth_mm) AS TOT_bill_depth_mm, SUM(flipper_length_mm) AS TOT_flipper_length_mm, VARIANCE(bill_length_mm) AS VAR_bill_length_mm, VARIANCE(bill_depth_mm) AS VAR_bill_depth_mm, VARIANCE(flipper_length_mm) AS VAR_flipper_length_mm, AVG(bill_length_mm) AS AVG_bill_length_mm, AVG(bill_depth_mm) AS AVG_bill_depth_mm, AVG(flipper_length_mm) AS AVG_flipper_length_mm"</span>
<span class='c'>#&gt; [2] "FROM penguins"                                                                                                                                                                                                                                                                                                                                                                                                                                              </span>
<span class='c'>#&gt; [3] "GROUP BY species"</span>
</code></pre>

</div>

After cleaning, we can write the results to a temp file.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>tmp</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='nv'>penguins_query</span>, <span class='nv'>tmp</span><span class='o'>)</span>
</code></pre>

</div>

The current state of our file looks like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>SELECT species, COUNT(*) AS N, SUM(bill_length_mm) AS TOT_bill_length_mm, SUM(bill_depth_mm) AS TOT_bill_depth_mm, SUM(flipper_length_mm) AS TOT_flipper_length_mm, VARIANCE(bill_length_mm) AS VAR_bill_length_mm, VARIANCE(bill_depth_mm) AS VAR_bill_depth_mm, VARIANCE(flipper_length_mm) AS VAR_flipper_length_mm, AVG(bill_length_mm) AS AVG_bill_length_mm, AVG(bill_depth_mm) AS AVG_bill_depth_mm, AVG(flipper_length_mm) AS AVG_flipper_length_mm
FROM penguins
GROUP BY species
</code></pre>

</div>

Finally, we are ready to use `sqlfluff`. The `lint` command highlights errors in our script, and the `fix` command automatically fixes them (with flags `--no-safety` and `-f` requesting that it apply all rules and does not ask for permission to overwrite the file, respectively). However, note that if your stylistic preferences differ from the defaults, `sqlfluff` is imminently [customizable](https://docs.sqlfluff.com/en/stable/rules.html) via YAML.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/system.html'>system</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"sqlfluff lint"</span>, <span class='nv'>tmp</span><span class='o'>)</span>, intern <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> 

<span class='c'>#&gt; Warning in system(paste("sqlfluff lint", tmp), intern = TRUE): running command 'sqlfluff lint C:\Users\emily\AppData\Local\Temp\RtmpgfTyT7\file3e206aaa6365' had status 65</span>

<span class='c'>#&gt;  [1] "== [C:\\Users\\emily\\AppData\\Local\\Temp\\RtmpgfTyT7\\file3e206aaa6365] FAIL"</span>
<span class='c'>#&gt;  [2] "L:   1 | P:  29 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt;  [3] "L:   1 | P:  55 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt;  [4] "L:   1 | P:  97 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt;  [5] "L:   1 | P: 142 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt;  [6] "L:   1 | P: 193 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt;  [7] "L:   1 | P: 240 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt;  [8] "L:   1 | P: 290 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt;  [9] "L:   1 | P: 336 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt; [10] "L:   1 | P: 378 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt; [11] "L:   1 | P: 423 | L014 | Inconsistent capitalisation of unquoted identifiers." </span>
<span class='c'>#&gt; [12] "L:   1 | P: 444 | L016 | Line is too long."                                    </span>
<span class='c'>#&gt; attr(,"status")</span>
<span class='c'>#&gt; [1] 65</span>

<span class='c'># intern = TRUE is only useful for the sake of showing linter results for this blog post</span>
<span class='c'># it is not needed for interactive use</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/system.html'>system</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"sqlfluff fix --no-safety -f"</span>, <span class='nv'>tmp</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0</span>
</code></pre>

</div>

The results of these commands are a well-formatted and readable query.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>SELECT
    species,
    COUNT(*) AS n,
    SUM(bill_length_mm) AS tot_bill_length_mm,
    SUM(bill_depth_mm) AS tot_bill_depth_mm,
    SUM(flipper_length_mm) AS tot_flipper_length_mm,
    VARIANCE(bill_length_mm) AS var_bill_length_mm,
    VARIANCE(bill_depth_mm) AS var_bill_depth_mm,
    VARIANCE(flipper_length_mm) AS var_flipper_length_mm,
    AVG(bill_length_mm) AS avg_bill_length_mm,
    AVG(bill_depth_mm) AS avg_bill_depth_mm,
    AVG(flipper_length_mm) AS avg_flipper_length_mm
FROM penguins
GROUP BY species
</code></pre>

</div>

A (slightly) more realistic example
-----------------------------------

One situation in which this approach is useful is when engineering features that might include many subgroups or lags. Some flavors of SQL have `PIVOT` functions which help to aggregate and reshape data by group; however, this can vary by engine and even those that do (such as [Snowflake](https://docs.snowflake.com/en/sql-reference/constructs/pivot.html)) require manually specifying the names of each field. Instead, our `dbplyr` and `sqlfluff` can help generate an accurate query to accomplsh this more concisely.

Now assume we want to find the mean for each measurement separately for years 2007 through 2009. Ultimately, we want these measures organized in a table with one row per species. We can concisely describe this goal with `dplyr` instead of writing out the definition of each of 9 variables (three metrics for three years) separately.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>penguins_pivot</span> <span class='o'>&lt;-</span>
  <span class='nv'>penguins</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>species</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise_all.html'>summarize_at</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/vars.html'>vars</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>ends_with</a></span><span class='o'>(</span><span class='s'>"mm"</span><span class='o'>)</span><span class='o'>)</span>, 
               <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>in09 <span class='o'>=</span> <span class='o'>~</span><span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/if_else.html'>if_else</a></span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>==</span> <span class='m'>2009L</span>, <span class='nv'>.</span>, <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span>,
                    in08 <span class='o'>=</span> <span class='o'>~</span><span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/if_else.html'>if_else</a></span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>==</span> <span class='m'>2008L</span>, <span class='nv'>.</span>, <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span>,
                    in07 <span class='o'>=</span> <span class='o'>~</span><span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/if_else.html'>if_else</a></span><span class='o'>(</span><span class='nv'>year</span> <span class='o'>==</span> <span class='m'>2007L</span>, <span class='nv'>.</span>, <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span>
               <span class='o'>)</span> 
<span class='nv'>penguins_pivot</span>

<span class='c'>#&gt; <span style='color: #555555;'># Source:   lazy query [?? x 10]</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># Database: sqlite 3.33.0 [:memory:]</span></span>
<span class='c'>#&gt;   species bill_length_mm_㠼㸵 bill_depth_mm_i㠼㸵 flipper_length_㠼㸵 bill_length_mm_㠼㸵</span>mm_…
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>              </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> Adelie              13.3             6.19             65.7             12.7</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> Chinst㠼㸵             17.3             6.47             69.9             12.9</span></span>9
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> Gentoo              17.0             5.34             76.4             17.4</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># 㠼㸵 with 5 more variables: bill_depth_mm_in08 </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,</span></span>m
<span class='c'>#&gt; <span style='color: #555555;'>#   flipper_length_mm_in08 </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, bill_length_mm_in07 </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>,</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>#   bill_depth_mm_in07 </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span style='color: #555555;'>, flipper_length_mm_in07 </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
</code></pre>

</div>

Following the same process as before, we can convert this to a SQL query.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/utils/capture.output.html'>capture.output</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='nv'>penguins_pivot</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nv'>query</span><span class='o'>[</span><span class='m'>2</span><span class='o'>:</span><span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>query</span><span class='o'>)</span><span class='o'>]</span>
<span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/grep.html'>gsub</a></span><span class='o'>(</span><span class='s'>"`"</span>, <span class='s'>""</span>, <span class='nv'>query</span><span class='o'>)</span>
<span class='nv'>tmp</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/tempfile.html'>tempfile</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='nv'>query</span>, <span class='nv'>tmp</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/system.html'>system</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"sqlfluff fix --no-safety -f"</span>, <span class='nv'>tmp</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0</span>
</code></pre>

</div>

The following query shows the basic results. In this case, the `sqlfluff` default is significantly more aggressive with identations for the `CASE WHEN` statements than I personally prefer. If I were to use this in practice, I could refer back to the customizable [`sqlfluff` rules](https://docs.sqlfluff.com/en/stable/rules.html#) and either change their configuration or restrict rules I perceived as unaesthetic or overzealous from running.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>SELECT
    species,
    AVG(
        CASE
            WHEN
                (year = 2009) THEN (bill_length_mm)
            WHEN NOT(year = 2009) THEN (0.0)
        END
    ) AS bill_length_mm_in09,
    AVG(
        CASE
            WHEN
                (year = 2009) THEN (bill_depth_mm)
            WHEN NOT(year = 2009) THEN (0.0)
        END
    ) AS bill_depth_mm_in09,
    AVG(
        CASE
            WHEN
                (year = 2009) THEN (flipper_length_mm)
            WHEN NOT(year = 2009) THEN (0.0)
        END
    ) AS flipper_length_mm_in09,
    AVG(
        CASE
            WHEN
                (year = 2008) THEN (bill_length_mm)
            WHEN NOT(year = 2008) THEN (0.0)
        END
    ) AS bill_length_mm_in08,
    AVG(
        CASE
            WHEN
                (year = 2008) THEN (bill_depth_mm)
            WHEN NOT(year = 2008) THEN (0.0)
        END
    ) AS bill_depth_mm_in08,
    AVG(
        CASE
            WHEN
                (year = 2008) THEN (flipper_length_mm)
            WHEN NOT(year = 2008) THEN (0.0)
        END
    ) AS flipper_length_mm_in08,
    AVG(
        CASE
            WHEN
                (year = 2007) THEN (bill_length_mm)
            WHEN NOT(year = 2007) THEN (0.0)
        END
    ) AS bill_length_mm_in07,
    AVG(
        CASE
            WHEN
                (year = 2007) THEN (bill_depth_mm)
            WHEN NOT(year = 2007) THEN (0.0)
        END
    ) AS bill_depth_mm_in07,
    AVG(
        CASE
            WHEN
                (year = 2007) THEN (flipper_length_mm)
            WHEN NOT(year = 2007) THEN (0.0)
        END
    ) AS flipper_length_mm_in07
FROM penguins
GROUP BY species
</code></pre>

</div>

When you can't connect to you data
----------------------------------

Even if, for some reason, you cannot connect to R with your specific dataset, you may still use this approach.

For example, suppose we cannot connect to the `penguins` dataset directly, but with the help of a data dictionary we can obtain a list of all of the fields in the dataset.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>penguins_cols</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/names.html'>names</a></span><span class='o'>(</span><span class='nf'>palmerpenguins</span><span class='nf'>::</span><span class='nv'><a href='https://allisonhorst.github.io/palmerpenguins/reference/penguins.html'>penguins</a></span><span class='o'>)</span>
</code></pre>

</div>

In this case, we can simple mock a fake dataset using the column names, write it to an in-memory database, generate SQL, and style the output as before.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># make fake dataset ----</span>
<span class='nv'>penguins_mat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/matrix.html'>matrix</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='nf'><a href='https://rdrr.io/r/base/length.html'>length</a></span><span class='o'>(</span><span class='nv'>penguins_cols</span><span class='o'>)</span><span class='o'>)</span>, nrow <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span>
<span class='nv'>penguins_dat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/setNames.html'>setNames</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span><span class='nv'>penguins_mat</span><span class='o'>)</span>, <span class='nv'>penguins_cols</span><span class='o'>)</span>
<span class='nv'>penguins_dat</span>

<span class='c'>#&gt;   species island bill_length_mm bill_depth_mm flipper_length_mm body_mass_g sex</span>
<span class='c'>#&gt; 1       1      1              1             1                 1           1   1</span>
<span class='c'>#&gt;   year</span>
<span class='c'>#&gt; 1    1</span>


<span class='c'># copy to database ----</span>
<span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RSQLite</span><span class='nf'>::</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, dbname <span class='o'>=</span> <span class='s'>":memory:"</span><span class='o'>)</span>
<span class='nf'><a href='https://dplyr.tidyverse.org/reference/copy_to.html'>copy_to</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='nv'>penguins_dat</span>, <span class='s'>"penguins_mock"</span><span class='o'>)</span>
<span class='nv'>penguins_mock</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/tbl.html'>tbl</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='s'>"penguins_mock"</span><span class='o'>)</span>

<span class='c'># generate sql ----</span>
<span class='nv'>penguins_aggr</span> <span class='o'>&lt;-</span>
  <span class='nv'>penguins_mock</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>species</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span>
    N <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span>,
    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>ends_with</a></span><span class='o'>(</span><span class='s'>"mm"</span><span class='o'>)</span>, <span class='nv'>sum</span>, .names <span class='o'>=</span> <span class='s'>"TOT_{.col}"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>ends_with</a></span><span class='o'>(</span><span class='s'>"mm"</span><span class='o'>)</span>, <span class='nv'>var</span>, .names <span class='o'>=</span> <span class='s'>"VAR_{.col}"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>across</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>ends_with</a></span><span class='o'>(</span><span class='s'>"mm"</span><span class='o'>)</span>, <span class='nv'>mean</span>, .names <span class='o'>=</span> <span class='s'>"AVG_{.col}"</span><span class='o'>)</span>,
  <span class='o'>)</span>

<span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='nv'>penguins_aggr</span><span class='o'>)</span>

<span class='c'>#&gt; &lt;SQL&gt;</span>
<span class='c'>#&gt; SELECT `species`, COUNT(*) AS `N`, SUM(`bill_length_mm`) AS `TOT_bill_length_mm`, SUM(`bill_depth_mm`) AS `TOT_bill_depth_mm`, SUM(`flipper_length_mm`) AS `TOT_flipper_length_mm`, VARIANCE(`bill_length_mm`) AS `VAR_bill_length_mm`, VARIANCE(`bill_depth_mm`) AS `VAR_bill_depth_mm`, VARIANCE(`flipper_length_mm`) AS `VAR_flipper_length_mm`, AVG(`bill_length_mm`) AS `AVG_bill_length_mm`, AVG(`bill_depth_mm`) AS `AVG_bill_depth_mm`, AVG(`flipper_length_mm`) AS `AVG_flipper_length_mm`</span>
<span class='c'>#&gt; FROM `penguins_mock`</span>
<span class='c'>#&gt; GROUP BY `species`</span>
</code></pre>

</div>

The only caution with this approach is that one should not use *type-driven* select helpers such [`summarize_if(is.numeric, ...)`](https://dplyr.tidyverse.org/reference/summarise_all.html) because our mock data has some erroneous types (e.g. `species`, `island`, and `sex` are erroneously numeric). Thus, we could generate SQL that would throw errors when applied to actual data. For example, the following SQL code attempts to sum up islands. This is perfectly reasonably given our dummy dataset but would be illogical and problematic when applied in production.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>penguins_mock</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>species</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise_all.html'>summarize_if</a></span><span class='o'>(</span><span class='nv'>is.numeric</span>, <span class='nv'>sum</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/explain.html'>show_query</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; &lt;SQL&gt;</span>
<span class='c'>#&gt; SELECT `species`, SUM(`island`) AS `island`, SUM(`bill_length_mm`) AS `bill_length_mm`, SUM(`bill_depth_mm`) AS `bill_depth_mm`, SUM(`flipper_length_mm`) AS `flipper_length_mm`, SUM(`body_mass_g`) AS `body_mass_g`, SUM(`sex`) AS `sex`, SUM(`year`) AS `year`</span>
<span class='c'>#&gt; FROM `penguins_mock`</span>
<span class='c'>#&gt; GROUP BY `species`</span>
</code></pre>

</div>

Caveats
-------

I have found this combination of tools to be useful for generating readable, typo-free queries when doing a large number of queries. However, I will end by highlighting when this may not be the best approach.

**`dbplyr` is not intended to generate SQL.** There's always a risk when using tools for something other than their primary intent. `dbplyr` is no exception. Overall, it does an excellent job translating SQL and being aware of the unique flavor of various SQL backends. However, translating between languages is a challenging problem, and sometimes the SQL translation may not be the most computationally efficient (e.g. requiring more subqueries) or semantic approach. For multistep or multitable problems, you may wish to use this approach simple for generating a few painful SQL chunks instead of your whole script.

**`dbplyr` *is* intended for you to *not* look at the SQL.** One major benefit of `dbplyr` for R users is distinctly to *not* change languages and to benefit from a database's compute power while staying in R. Not only is this use case not the intended purpose, you could go as far as to argue it is almost antithetical. Nevertheless, I do think there are many cases where one should preserve SQL independently; for example, you might need to do data tranformations in a production pipeline that does not run R, not wish to take on additional code dependencies, not be able to connect to your database with R, or be collaborating with non-R users.

**`sqlfluff` is still experimental.** As the developers emphasized in their DBT talk, `sqlfluff` is still in its early changes and subject to change. While I'm optimistic that this only means this tool will only keep getting better, it's possible the exact rules, configuration, flags, syntax, etc. may change. Check out the docs for the latest documentation there.

[^1]: That being said, for SQL [`dbt` with Jinja templating support](https://docs.getdbt.com/tutorial/using-jinja) is an intriguing option

