---
output: hugodown::md_document
title: "Goin' to Carolina in my mind (or on my hard drive)"
subtitle: ""
summary: "Out-of-memory processing of North Carolina's voter file with DuckDb and Apache Arrow"
authors: []
tags: [data, sql]
categories: [data, sql]
date: 2022-09-24
lastmod: 2022-09-24
featured: false
draft: false
aliases:

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "Photo Credit to [Element5 Digital](https://unsplash.com/@element5digital) on Unsplash"
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: 86597e43a57a80e6

---

There comes a time in every analysts life when data becomes too big for their laptop's RAM. While open-source tools like R, SQL, and python have made "team of one" data analysts ever more powerful, analysts abilities to derive value from their skillsets are highly interdependent with the tools at their disposal.

For R and python, the sheer size of datasets becomes a limiting factor; for a SQL-focused analyst, the mere (non)existence of a database is prerequisite. While an increasing number of managed cloud services (from data warehouses, containers, hosted IDEs and notebooks) offer a trendy and effective solution, budget constraints, technical know-how, security concerns, or tight-timelines can all be headwinds to adoption.

So what's an analyst to do when they have the knowledge and tools but not the infrastructure to tackle their problem?

[`DuckDB`](https://duckdb.org/) is quickly gaining popularity as a solution to some of these problems. DuckDB is a no-dependency, serverless database management system that can help parse massive amounts of data out-of-memory. Key features include:

-   **Easy set-up**: Easily installed as an executable or embedded within R or python packages
-   **Columnar storage**: For efficient retrieval and vectorized computation in analytics settings
-   **No installation or infrastructure required**: Runs seamlessly on a local machine launched from an executable
-   **No loading required**: Can read external CSV and Parquet files *and* can smartly exploit Hive-partitioned Parquet datasets in optimization
-   **Expressive SQL**: Provides semantic sugar for analytical SQL uses with clauses like `except` and `group by all` (see blog [here](https://duckdb.org/2022/05/04/friendlier-sql.html))

In this post, I'll walk through a scrappy, minimum-viable setup for analysts using `DuckDB`, motivated by the [North Carolina State Board of Election](https://www.ncsbe.gov/results-data)'s rich voter data. Those interested can follow along in [this repo](https://github.com/emilyriederer/nc-votes-duckdb) and put it to the test by launching a free 8GB RAM GitHub Codespaces.

This is very much *not* a demonstration of best practices of anything. It's also not a technical benchmarking of the speed and capabilities of `duckdb` versus alternatives. (That ground is well-trod. If interested, see [a head-to-head to pandas](https://duckdb.org/2021/05/14/sql-on-pandas.html) or [a matrix of comparisons across database alternatives](https://benchmark.clickhouse.com/).) If anything, it is perhaps a "user experience benchmark", or a description of a minimum-viable set-up to help analysts use what they know to do what they need to do.

## Motivation: North Carolina midterm data

North Carolina (which began accepting ballots in early September for the upcoming November midterms) offers a rich collection of voter data, including daily-updating information on the current election, full voter registration data, and ten years of voting history.

-   NC 2022 midterm early vote data from [NCSBE](https://www.ncsbe.gov/results-data) (\~6K records as-of 9/23 and growing fast!)
-   NC voter registration file from [NCSBE](https://www.ncsbe.gov/results-data) (\~9M records, will be static for this cycle once registration closes in October)
-   NC 10-year voter history file from [NCSBE](https://www.ncsbe.gov/results-data) (\~22M records, static)

One can imagine that this data is of great interest to campaign staff, political scientists, pollsters, and run-of-the-mill political junkies and prognosticators.

Beyond these files, analysis using this data could surely be enriched by additional third-party sources such as:

-   Current Population Survey 2022 November voting supplement from [US Census Bureau](https://www.census.gov/data/datasets/time-series/demo/cps/cps-supp_cps-repwgt/cps-voting.html)
-   County-level past election results from [MIT Election Lab via Harvard Dataverse](https://dataverse.harvard.edu/file.xhtml?fileId=6104822&version=10.0)
-   Countless other data sources either from the US Census, public or internal campaign polls, organization-specific mobilizaton efforts, etc.

Your mileage may vary based on your system RAM, but many run-of-the-mill consumer laptops might struggle to let R or python load all of this data into memory. Or, a SQL-focused analyst might yearn for a database to handle all these complex joins. So how can `DuckDb` assist?

## DuckDB key features

To explain, we'll first look at a brief demo of some of the most relevant features of `DuckDB`.

Suppose we have flat files of data, like a `sample.csv` (just many orders of magnitude larger!)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>import pandas as pd
df = pd.DataFrame({'a':[1,2,3], 'b':[4,5,6], 'c':[7,8,9]})
df.head()

#>    a  b  c
#> 0  1  4  7
#> 1  2  5  8
#> 2  3  6  9

df.to_csv('sample.csv', index = False)
</code></pre>

</div>

`DuckDB` can directly infer it's schema and read it in a SQL-like interface by using functions like `read_csv_auto()` in the `FROM` clause.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>import duckdb
con = duckdb.connect()
df = con.execute("select * from read_csv_auto('sample.csv')").fetchdf()
df.head()

#>    a  b  c
#> 0  1  4  7
#> 1  2  5  8
#> 2  3  6  9

con.close()
</code></pre>

</div>

While very useful, this is of course bulky to type. We may also set-up a persistent DuckDB database as a `.duckdb` file as save tables with CTAS statements, as with any normal relational database. Below, we create the `sample-db.duckdb` database and add one table and one view with our data.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>#> <duckdb.DuckDBPyConnection object at 0x00000000310F96B0>

#> <duckdb.DuckDBPyConnection object at 0x00000000310F96B0>
</code></pre>

</div>

Now, suppose the data in `sample.csv` changes (now with 4 rows versus 3).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>import pandas as pd
df = pd.DataFrame({'a':[1,2,3,4], 'b':[4,5,6,7], 'c':[7,8,9,10]})
df.head()

#>    a  b   c
#> 0  1  4   7
#> 1  2  5   8
#> 2  3  6   9
#> 3  4  7  10

df.to_csv('sample.csv', index = False)
</code></pre>

</div>

Our table stored the data directly within the database ("disconnected" from the file) so it remains the same as before whereas our view changed.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>import duckdb
con = duckdb.connect('sample-db.duckdb')
df1 = con.execute("select count(1) from sample").fetchdf()
df2 = con.execute("select count(1) from sample_vw").fetchdf()
con.close()
df1.head()

#>    count(1)
#> 0         3

df2.head()

#>    count(1)
#> 0         4
</code></pre>

</div>

## Query patterns

## Refresh

