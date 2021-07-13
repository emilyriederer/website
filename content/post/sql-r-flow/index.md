---
output: hugodown::md_document
title: "Workflows for querying databases via R"
subtitle: "Tricks for modularizing and refactoring your projects SQL/R interface"
summary: ""
authors: []
tags: [rstats, workflow, sql]
categories: [rstats, workflow, sql]
date: 2021-07-17
lastmod: 2021-07-17
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
rmd_hash: 14316b849bcea254

---

Simple, self-contained, reproducible examples are a common part of good software documentation. However, in the spirit of brevity, these examples often do not demonstrate the most sustainable or flexible *workflows* for integrating software tools into large projects. In this post, I document a few mundane but useful patterns for querying databases in R using the `DBI` package.

A prototypical example of forming and using a database connection with `DBI` might look something like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://r-dbi.github.io/DBI'>DBI</a></span><span class='o'>)</span>

<span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RSQLite</span><span class='nf'>::</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>":memory:"</span><span class='o'>)</span>
<span class='nf'><a href='https://dbi.r-dbi.org/reference/dbWriteTable.html'>dbWriteTable</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='s'>"diamonds"</span>, <span class='nf'>ggplot2</span><span class='nf'>::</span><span class='nv'><a href='https://ggplot2.tidyverse.org/reference/diamonds.html'>diamonds</a></span><span class='o'>)</span>
<span class='nv'>dat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbGetQuery.html'>dbGetQuery</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='s'>"select cut, count(*) as n from diamonds group by 1"</span><span class='o'>)</span>
<span class='nv'>dat</span>

<span class='c'>#&gt;         cut     n</span>
<span class='c'>#&gt; 1      Fair  1610</span>
<span class='c'>#&gt; 2      Good  4906</span>
<span class='c'>#&gt; 3     Ideal 21551</span>
<span class='c'>#&gt; 4   Premium 13791</span>
<span class='c'>#&gt; 5 Very Good 12082</span>
</code></pre>

</div>

A connection is formed (in this case to a fake database that lives only in my computer's RAM), the `diamonds` dataset from the `ggplot2` package is written to the database (once again, this is for example purposes only; a real database would, of course, have data), and [`dbGetQuery()`](https://dbi.r-dbi.org/reference/dbGetQuery.html) executes a querying on the resulting table.

However, as queries get longer and more complex, this succinct solution becomes less attractive. Writing the query directly inside [`dbGetQuery()`](https://dbi.r-dbi.org/reference/dbGetQuery.html) blurs the line between "glue code" (rote connection and execution) and our more nuanced, problem-specific logic. This makes the latter harder to extract, share, and version.

Below, I demonstrate a few alternatives that I find helpful in different circumstances such as reading queries that are saved separately (in different files or at web URLs) and forming increasingly complex query templates.

Read query from separate file
-----------------------------

A first enhancement is to isolate your SQL script in a separate file than the "glue code" that executes it. This improves readability and makes scripts more portable between projects. If a coworker who uses python or runs SQL through some other tool wishes to use your script, it's more obvious which parts are relevant. Additionally, its easier to version control: we likely care far more about changes to the actual query than the boilerplate code that executes it so it feels more transparent to track them separately.

To do this, we can save our query in a separate file. We'll call it `query-cut.sql`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select
  cut,
  count(*) as n
from diamonds
group by 1
</code></pre>

</div>

Then, in our script that pulls the data, we can read that other file with [`readLines()`](https://rdrr.io/r/base/readLines.html) and give the results of that to the [`dbGetQuery()`](https://dbi.r-dbi.org/reference/dbGetQuery.html) function.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://r-dbi.github.io/DBI'>DBI</a></span><span class='o'>)</span>

<span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RSQLite</span><span class='nf'>::</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>":memory:"</span><span class='o'>)</span>
<span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='s'>"query-cut.sql"</span><span class='o'>)</span>, collapse <span class='o'>=</span> <span class='s'>"\n"</span><span class='o'>)</span>
<span class='nv'>dat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbGetQuery.html'>dbGetQuery</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='nv'>query</span><span class='o'>)</span>
<span class='nv'>dat</span>

<span class='c'>#&gt;         cut     n</span>
<span class='c'>#&gt; 1      Fair  1610</span>
<span class='c'>#&gt; 2      Good  4906</span>
<span class='c'>#&gt; 3     Ideal 21551</span>
<span class='c'>#&gt; 4   Premium 13791</span>
<span class='c'>#&gt; 5 Very Good 12082</span>
</code></pre>

</div>

Of course, if you wish you could define a helper function for the bulky [`paste(readLines(...))`](https://rdrr.io/r/base/paste.html) bit.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>read_source</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>path</span><span class='o'>)</span> <span class='o'>{</span><span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='nv'>path</span><span class='o'>)</span>, collapse <span class='o'>=</span> <span class='s'>"\n"</span><span class='o'>)</span><span class='o'>}</span>
</code></pre>

</div>

Read query from URL (like GitHub)
---------------------------------

Sometimes, you might prefer that your query not live in your project at all. For example, if a query is used across multiple projects or if it changes frequently or is maintained by multiple people, it might live in a separate repository. In this case, the exact same workflow may be used if the path is replaced by a URL to a plain-text version of the query. (On GitHub, you may find such a link by clicking the "Raw" button when a file is pulled up.)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://r-dbi.github.io/DBI'>DBI</a></span><span class='o'>)</span>

<span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RSQLite</span><span class='nf'>::</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>":memory:"</span><span class='o'>)</span>
<span class='nv'>url</span> <span class='o'>&lt;-</span> <span class='s'>"https://raw.githubusercontent.com/emilyriederer/dbtplyr/main/macros/across.sql"</span>
<span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='nv'>url</span><span class='o'>)</span>, collapse <span class='o'>=</span> <span class='s'>"\n"</span><span class='o'>)</span>
<span class='c'>#dat &lt;- dbGetQuery(con, query)</span>
<span class='nv'>dat</span>

<span class='c'>#&gt;         cut     n</span>
<span class='c'>#&gt; 1      Fair  1610</span>
<span class='c'>#&gt; 2      Good  4906</span>
<span class='c'>#&gt; 3     Ideal 21551</span>
<span class='c'>#&gt; 4   Premium 13791</span>
<span class='c'>#&gt; 5 Very Good 12082</span>
</code></pre>

</div>

This works because the `query` variable simply contains our complete text file read from the internet:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='nv'>query</span><span class='o'>)</span>

<span class='c'>#&gt; {% macro across(var_list, script_string, final_comma) %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;   {% for v in var_list %}</span>
<span class='c'>#&gt;   {{ script_string | replace('{{var}}', v) }}</span>
<span class='c'>#&gt;   {%- if not loop.last %},{% endif %}</span>
<span class='c'>#&gt;   {%- if loop.last and final_comma|default(false) %},{% endif %}</span>
<span class='c'>#&gt;   {% endfor %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; {% endmacro %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; {% macro c_across(var_list, script_string) %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;   {% if script_string | length &lt; 2 %}</span>
<span class='c'>#&gt;     {{ var_list | join(script_string) }}</span>
<span class='c'>#&gt;   {% else %}</span>
<span class='c'>#&gt;   {% set vars = var_list | join(",") %}</span>
<span class='c'>#&gt;   {{ script_string | replace('{{var}}', vars) }}</span>
<span class='c'>#&gt;   {% endif %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; {% endmacro %}</span>
</code></pre>

</div>

Alternatively, in an institutional setting you may find that you need some sort of authentication or proxy to access GitHub from R. In that case, you may retrieve the same query with an HTTP request instead using the `httr` package.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://httr.r-lib.org/'>httr</a></span><span class='o'>)</span>

<span class='nv'>url</span> <span class='o'>&lt;-</span> <span class='s'>"https://raw.githubusercontent.com/emilyriederer/dbtplyr/main/macros/across.sql"</span>
<span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://httr.r-lib.org/reference/content.html'>content</a></span><span class='o'>(</span><span class='nf'><a href='https://httr.r-lib.org/reference/GET.html'>GET</a></span><span class='o'>(</span><span class='nv'>url</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='nv'>query</span><span class='o'>)</span>

<span class='c'>#&gt; {% macro across(var_list, script_string, final_comma) %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;   {% for v in var_list %}</span>
<span class='c'>#&gt;   {{ script_string | replace('{{var}}', v) }}</span>
<span class='c'>#&gt;   {%- if not loop.last %},{% endif %}</span>
<span class='c'>#&gt;   {%- if loop.last and final_comma|default(false) %},{% endif %}</span>
<span class='c'>#&gt;   {% endfor %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; {% endmacro %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; {% macro c_across(var_list, script_string) %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;   {% if script_string | length &lt; 2 %}</span>
<span class='c'>#&gt;     {{ var_list | join(script_string) }}</span>
<span class='c'>#&gt;   {% else %}</span>
<span class='c'>#&gt;   {% set vars = var_list | join(",") %}</span>
<span class='c'>#&gt;   {{ script_string | replace('{{var}}', vars) }}</span>
<span class='c'>#&gt;   {% endif %}</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; {% endmacro %}</span>
</code></pre>

</div>

Use query template
------------------

Separating the query from its actual execution also allows us to do query pre-processing. For example, instead of a normal query, we could write a query template with a wildcard variable. Consider the file `template-cut.sql`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select
  cut,
  count(*) as n
from diamonds
where price < {max_price}
group by 1
</code></pre>

</div>

This query continues to count the number of diamonds in our dataset by their cut classification, but now is has parameterized the `max_price` variable. Then, we may use the `glue` package to populate this template with a value of interest before executing the script.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://r-dbi.github.io/DBI'>DBI</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/tidyverse/glue'>glue</a></span><span class='o'>)</span>

<span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RSQLite</span><span class='nf'>::</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>":memory:"</span><span class='o'>)</span>
<span class='nv'>template</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='s'>"template-cut.sql"</span><span class='o'>)</span>, collapse <span class='o'>=</span> <span class='s'>"\n"</span><span class='o'>)</span>
<span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://glue.tidyverse.org/reference/glue.html'>glue</a></span><span class='o'>(</span><span class='nv'>template</span>, max_price <span class='o'>=</span> <span class='m'>500</span><span class='o'>)</span>
<span class='c'>#dat &lt;- dbGetQuery(con, query)</span>
<span class='nv'>dat</span>

<span class='c'>#&gt;         cut     n</span>
<span class='c'>#&gt; 1      Fair  1610</span>
<span class='c'>#&gt; 2      Good  4906</span>
<span class='c'>#&gt; 3     Ideal 21551</span>
<span class='c'>#&gt; 4   Premium 13791</span>
<span class='c'>#&gt; 5 Very Good 12082</span>
</code></pre>

</div>

This is a useful alternative to databases that do not allow for local variables.

Compose more complex queries
----------------------------

The idea of templating opens up far more interesting possibilities. For example, consider a case where you wish to frequently create the same data structure for a different population of observations (e.g. a standard set of KPIs for different A/B test experiments, reporting for different business units, etc.)

A boilerplate part of the query could be defined as a template ready to accept a CTE or a subquery for a specific population of interest. For example, we could write a file `template-multi.sql`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>with
sample as ({query_sample}),
prices as (select id, cut, price from diamonds)
select prices.*
from
  prices
  inner join
  sample
  on
  prices.id = diamonds.id
</code></pre>

</div>

Then our "glue code" can combine the static and dynamic parts of the query at runtime before executing.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>template</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='s'>"template-multi.sql"</span><span class='o'>)</span>, collapse <span class='o'>=</span> <span class='s'>"\n"</span><span class='o'>)</span>
<span class='nv'>query_sample</span> <span class='o'>&lt;-</span> <span class='s'>"select * from diamonds where cut = 'Very Good' and carat &lt; 0.25"</span>
<span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://glue.tidyverse.org/reference/glue.html'>glue</a></span><span class='o'>(</span><span class='nv'>template</span>, query_sample <span class='o'>=</span> <span class='nv'>query_sample</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='nv'>query</span><span class='o'>)</span>

<span class='c'>#&gt; with</span>
<span class='c'>#&gt; sample as (select * from diamonds where cut = 'Very Good' and carat &lt; 0.25),</span>
<span class='c'>#&gt; prices as (select id, cut, price from diamonds)</span>
<span class='c'>#&gt; select prices.*</span>
<span class='c'>#&gt; from</span>
<span class='c'>#&gt;   prices</span>
<span class='c'>#&gt;   inner join</span>
<span class='c'>#&gt;   sample</span>
<span class='c'>#&gt;   on</span>
<span class='c'>#&gt;   prices.id = diamonds.id</span>
</code></pre>

</div>

(Of course, this may seem like overkill and an unnecessarily inefficent query for the example above where a few more `where` conditions could have sufficed. But one can imagine more useful applications in a traditional setting where multiple tables are being joined.)

Query package
-------------

Finally, these queries and query templates could even be shipped as part of an R package. Additional text files may be placed in the `inst/` directory and their paths discovered by [`system.file()`](https://rdrr.io/r/base/system.file.html). So, if your package `myPkg` were to contain the `template-multi.sql` file we saw above, you could provide a function to access it like so:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>construct_query</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>stub</span>, <span class='nv'>...</span><span class='o'>)</span> <span class='o'>{</span>
  
  <span class='nv'>path</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/system.file.html'>system.file</a></span><span class='o'>(</span><span class='nv'>stub</span>, package <span class='o'>=</span> <span class='s'>'myPkg'</span><span class='o'>)</span>
  <span class='nv'>template</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='nv'>path</span><span class='o'>)</span>, collapse <span class='o'>=</span> <span class='s'>'\n'</span><span class='o'>)</span>
  <span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nf'>glue</span><span class='nf'>::</span><span class='nf'><a href='https://glue.tidyverse.org/reference/glue.html'>glue</a></span><span class='o'>(</span><span class='nv'>template</span>, <span class='nv'>...</span><span class='o'>)</span>
  <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='nv'>query</span><span class='o'>)</span>
  
<span class='o'>}</span>
</code></pre>

</div>

Then, that function could be called like so:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>sample</span> <span class='o'>&lt;-</span> <span class='s'>"select * from diamonds where cut = 'Very Good' and carat &lt; 0.25"</span>
<span class='nv'>query</span> <span class='o'>&lt;-</span> <span class='nf'>construct_query</span><span class='o'>(</span><span class='s'>"multi"</span>, query_sample <span class='o'>=</span> <span class='nv'>sample</span><span class='o'>)</span>
</code></pre>

</div>

This approach has some benefits such as making it easier to share queries across users and benefit from package versioning and environment management standards. However, there are of course other risks; only dynamically generating queries could limit reproducibility or documentation about the actual query run to generate data. Thus, it might be a good idea to save the resulting query along with the resulting data:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbGetQuery.html'>dbGetQuery</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='nv'>query</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/readRDS.html'>saveRDS</a></span><span class='o'>(</span><span class='nv'>dat</span>, <span class='s'>"data.rds"</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='nv'>query</span>, <span class='s'>"query-data.rds"</span><span class='o'>)</span>
</code></pre>

</div>

