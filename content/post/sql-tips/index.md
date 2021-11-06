---
output: hugodown::md_document
title: "What they forgot to tell you about SQL"
subtitle: ""
summary: "SELECT top 10 tips FROM sql_syntax"
authors: []
tags: []
categories: [data]
date: 2020-09-19
lastmod: 2020-09-19
featured: false
draft: true
aliases:

image:
  caption: "Photo by [Max Duzij](https://unsplash.com/@max_duz) on Unsplash"
  focal_point: ""
  preview_only: true

projects: [""]
rmd_hash: 1d844fcee40a102c

---

I've always considered SQL to be "bad manager" syntax:

<div class="highlight">

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='https://yihui.org/knitr'>knitr</a></span>)
<span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='http://r-dbi.github.io/DBI'>DBI</a></span>)

<span class='k'>knitr</span>::<span class='k'><a href='https://rdrr.io/pkg/knitr/man/opts_chunk.html'>opts_chunk</a></span><span class='o'>$</span><span class='nf'>set</span>(echo = <span class='kc'>TRUE</span>)
<span class='k'>knitr</span>::<span class='k'><a href='https://rdrr.io/pkg/knitr/man/opts_chunk.html'>opts_chunk</a></span><span class='o'>$</span><span class='nf'>set</span>(connection = <span class='s'>"con"</span>)
<span class='k'>con</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span>(<span class='k'>RSQLite</span>::<span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span>(), <span class='s'>":memory:"</span>)

<span class='k'>con2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span>(
  <span class='k'>RPostgres</span>::<span class='nf'><a href='https://rpostgres.r-dbi.org/reference/Postgres.html'>Postgres</a></span>(),
  user = <span class='nf'><a href='https://rdrr.io/r/base/Sys.getenv.html'>Sys.getenv</a></span>(<span class='s'>"FLIGHTS_DB_USER"</span>),
  password = <span class='nf'><a href='https://rdrr.io/r/base/Sys.getenv.html'>Sys.getenv</a></span>(<span class='s'>"FLIGHTS_DB_PASS"</span>),
  dbname = <span class='s'>"nycflights13"</span>,
  host = <span class='s'>"db-edu.pacha.dev"</span>
)</code></pre>

</div>

Thanks to Mauricio Vargas for the [test database](https://db-edu.pacha.dev/) used in this post.

Quick Start
-----------

<div class='highlight'>

-   [Live Testing](#live-testing)
    -   [Create a sample table](#create-a-sample-table)
    -   [No `FROM` clause](#no-%60from%60-clause)
-   [Defensive Programming](#defensive-programming)
    -   [Coalesce](#coalesce)
    -   [Case When Defaults](#case-when-defaults)
-   [Programming](#programming)
    -   [Local Variables](#local-variables)
    -   [User-Defined Functions](#user-defined-functions)
-   [Underutilized Functions](#underutilized-functions)
    -   [Greatest / Least](#greatest-/-least)
    -   [IFF](#iff)
    -   [Faster Binning](#faster-binning)
-   [More Advanced Calculations](#more-advanced-calculations)
    -   [Window Functions](#window-functions)
    -   [Aggregate Filters](#aggregate-filters)
        </div>

Thanks to Garrick Aden-Buie for the [table of contents code](https://gist.github.com/gadenbuie/c83e078bf8c81b035e32c3fc0cf04ee8)

Live Testing
------------

### Create a sample table

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>CREATE TEMPORARY TABLE IF NOT EXISTS Order_Detail (
    invoice_id INTEGER NOT NULL,
    invoice_line INTEGER NOT NULL,
    store_id INTEGER NOT NULL,
    time_stamp DATE NOT NULL,
    product VARCHAR(8) NOT NULL,
    units INTEGER NOT NULL,
    sales NUMERIC(7 , 2 ) NOT NULL,
    cogs NUMERIC(5 , 2 ) NOT NULL
);

</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>INSERT INTO Order_Detail(invoice_id,invoice_line,store_id,time_stamp,product,units,sales,cogs) VALUES (1000,312,3,'2018/12/23','30',1,199.99,28.00);
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select * from Order_Detail limit 1;


#> [90m# A tibble: 1 x 8[39m
#>   invoice_id invoice_line store_id time_stamp product units sales  cogs
#>        [3m[90m<int>[39m[23m        [3m[90m<int>[39m[23m    [3m[90m<int>[39m[23m [3m[90m<chr>[39m[23m      [3m[90m<chr>[39m[23m   [3m[90m<int>[39m[23m [3m[90m<dbl>[39m[23m [3m[90m<int>[39m[23m
#> [90m1[39m       [4m1[24m000          312        3 2018/12/23 30          1  200.    28
</code></pre>

</div>

### No `FROM` clause

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select 10*5 as product;


#> [90m# A tibble: 1 x 1[39m
#>   product
#>     [3m[90m<int>[39m[23m
#> [90m1[39m      50
</code></pre>

</div>

Defensive Programming
---------------------

### Coalesce

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>WITH const AS (SELECT 10 AS more)
SELECT sales + NULL
FROM order_detail as o, const


#> [90m# A tibble: 1 x 1[39m
#>   `sales + NULL`
#>   [3m[90m<lgl>[39m[23m         
#> [90m1[39m [31mNA[39m
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>WITH const AS (SELECT 10 AS more)
SELECT sales + coalesce(NULL, 0)
FROM order_detail as o, const


#> [90m# A tibble: 1 x 1[39m
#>   `sales + coalesce(NULL, 0)`
#>                         [3m[90m<dbl>[39m[23m
#> [90m1[39m                        200.
</code></pre>

</div>

### Case When Defaults

Programming
-----------

### Local Variables

With SQLite

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>WITH const AS (SELECT 10 AS more)
SELECT sales * const.more
FROM order_detail as o, const


#> [90m# A tibble: 1 x 1[39m
#>   `sales * const.more`
#>                  [3m[90m<dbl>[39m[23m
#> [90m1[39m                [4m2[24m000.
</code></pre>

</div>

Or with Postgres

### User-Defined Functions

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>CREATE OR REPLACE FUNCTION iif_sql(boolean, anyelement, anyelement) returns anyelement as
$body$ select case $1 when true then $2 else $3 end $body$
LANGUAGE sql IMMUTABLE;
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select year, iif_sql(year > 2011, 1, 0)
from flights
limit 10
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'>#&gt;    year iif_sql</span>
<span class='c'>#&gt; 1  2013       1</span>
<span class='c'>#&gt; 2  2013       1</span>
<span class='c'>#&gt; 3  2013       1</span>
<span class='c'>#&gt; 4  2013       1</span>
<span class='c'>#&gt; 5  2013       1</span>
<span class='c'>#&gt; 6  2013       1</span>
<span class='c'>#&gt; 7  2013       1</span>
<span class='c'>#&gt; 8  2013       1</span>
<span class='c'>#&gt; 9  2013       1</span>
<span class='c'>#&gt; 10 2013       1</span></code></pre>

</div>

Underutilized Functions
-----------------------

### Greatest / Least

### IFF

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select iif(1 < 2, 1, 2)
</code></pre>

</div>

### Faster Binning

compare to `case when`

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select floor(sales / 50) * 50 as bin_sales
from order_detail



#> [90m# A tibble: 1 x 1[39m
#>   bin_sales
#>       [3m[90m<int>[39m[23m
#> [90m1[39m       150
</code></pre>

</div>

More Advanced Calculations
--------------------------

### Window Functions

### Aggregate Filters

`having`

`qualify`

