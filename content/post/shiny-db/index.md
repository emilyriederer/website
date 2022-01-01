---
output: hugodown::md_document
title: "Using databases with Shiny"
subtitle: ""
summary: "Key issues when adding persistent storage to a Shiny application, featuring {golem} app development and Digital Ocean serving"
authors: []
tags: [rstats, shiny, data]
categories: [rstats, shiny, data]
date: 2022-01-02
lastmod: 2022-01-02
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
rmd_hash: e26e93cb5d141a3e

---

Shiny apps are R's answer to building interface-driven applications that help expose important data, metrics, algorithms, and more with end-users. However, the more interesting work that your Shiny app allows users to do, the more likely users are to want to save, return to, and alter some of the ways that they interacted with your work.

This creates a need for **persistent storage** in your Shiny application, as opposed to the ephemeral in-memory of basic Shiny applications that "forget" the data that they generated as soon as the application is stopped.

Relational databases are a classic form of persistent storage for web applications. Many analysts may be familiar with *querying* relational databases to retrieve data, but *managing* a database for use with a web application is slightly more complex. You'll find yourself needing to define tables, secure data, and manage connections.

This post provides some tips, call-outs, and solutions for using a relational database for persistent storage with Shiny. In my case, I rely on a Shiny app built with the [`golem` framework](https://thinkr-open.github.io/golem/) and served on the Digital Ocean App platform.

Databases & Options for Storage
-------------------------------

Dean Attali's [blog post on persistent storage](https://deanattali.com/blog/shiny-persistent-data-storage/) compares a range of options for persistent storage including databases, S3 buckets, Google Drive, and more.

For my application, I anticipated the need to store and retrieve sizable amounts of structured data, so using a relational database seemed like a good option. Since I was hosting my application on [Digital Ocean App Platform](https://m.do.co/c/4a8a67985453), I could create a [managed Postgres database](https://www.digitalocean.com/products/managed-databases/) with just a few button clicks. As I share in the "Key Issues" section, this solution offers some significant benefits in terms of security.

For more information on different options for hosting Shiny apps and some insight into why I chose Digital Ocean, check out Peter Solymos' excellent blog on [Hosting Data Apps](https://hosting.analythium.io/).

Talking to your database through Shiny
--------------------------------------

General information on working with databases with R is included on RStudio's [excellent website](https://db.rstudio.com/). Below, I focus on a few topics specific to databases with Shiny, Shiny apps built in the `{golem}` framework, and Shiny apps served on Digital Ocean in particular.

### Creating a database

To create a database for my application, I simply went to:

`Settings > Add Component > Database`

At the time on writing, I was able to add a 1GB Dev Database for /\$7 / month. For a more mature product, one can add or switch to a production-ready Managed Database.

After a few minutes, the database has launched and its Connection Parameters are provided, which look something like this:

    host     : abc.b.db.ondigitalocean.com
    port     : 25060
    username : db
    password : abc123
    database : db
    sslmode  : require

By default, the Dev Database registers your application as a Trusted Source, meaning that only traffic from the application can attempt to access the database. As the [documentation](https://docs.digitalocean.com/products/databases/postgresql/how-to/secure/#firewalls) explains, this type of firewall improves security by preventing against brute-force password or denial-of-service attacks from the outside.

### Connecting to the database

We can use the connection parameters provided to connect to the database using R's `DBI` package.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RPostgres</span><span class='nf'>::</span><span class='nf'><a href='https://rpostgres.r-dbi.org/reference/Postgres.html'>Postgres</a></span><span class='o'>(</span><span class='o'>)</span>,
                      host   <span class='o'>=</span> <span class='s'>"aabc.b.db.ondigitalocean.com"</span>,
                      dbname <span class='o'>=</span> <span class='s'>"db"</span>,
                      user      <span class='o'>=</span> <span class='s'>"db"</span>,
                      password  <span class='o'>=</span> <span class='s'>"abc123"</span>,
                      port     <span class='o'>=</span> <span class='m'>25060</span><span class='o'>)</span>
</code></pre>

</div>

We will talk about ways to not hardcode one's password in the last section.

### Creating tables

Next, you can set up tables in your database that your application will require.

If you know SQL DDL, you can write a [CREATE TABLE statement](https://www.tutorialspoint.com/sql_certificate/using_ddl_statements.html) which defines a tables names, fields, and data types. However, this can feel verbose or uncomfortable to analysts who mostly use DML (e.g. `SELECT`, `FROM`, `WHERE`).

Fortunately, you can also define a table using R's `DBI` package. First, create a simple dataframe with a single record to help R infer the appropriate and expected data types. Then pass the first *zero* rows of the table (essentially, only the schema) to [`DBI::dbCreateTable()`](https://dbi.r-dbi.org/reference/dbCreateTable.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='s'>"a"</span>, z <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2022-01-01"</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbCreateTable.html'>dbCreateTable</a></span><span class='o'>(</span><span class='nv'>con</span>, name <span class='o'>=</span> <span class='s'>"my_data"</span>, fields <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span>
</code></pre>

</div>

To prove that this works, I show a "round trip" of the data using an in-memory SQLite database. Note that this is *not* an option for persistent storage because in-memory databases are not persistent. This is only to "prove" that this approach can create database tables.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>con_lite</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RSQLite</span><span class='nf'>::</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>":memory:"</span><span class='o'>)</span>
<span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='s'>"a"</span>, z <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2022-01-01"</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbCreateTable.html'>dbCreateTable</a></span><span class='o'>(</span><span class='nv'>con_lite</span>, name <span class='o'>=</span> <span class='s'>"my_data"</span>, fields <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='m'>0</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbListTables.html'>dbListTables</a></span><span class='o'>(</span><span class='nv'>con_lite</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "my_data"</span>

<span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbReadTable.html'>dbReadTable</a></span><span class='o'>(</span><span class='nv'>con_lite</span>, <span class='s'>"my_data"</span><span class='o'>)</span>

<span class='c'>#&gt; [1] x y z</span>
<span class='c'>#&gt; &lt;0 rows&gt; (or 0-length row.names)</span>
</code></pre>

</div>

But where should you run this script? You do *not* want to put this code in your app to run every time the app launches, but we just limited database traffic to the app so we cannot run it locally. Instead, you can run this code from the app's [console](https://docs.digitalocean.com/products/app-platform/concepts/console/). (Alternatively, if you upgrade to a Managed Database, I believe you can also whitelist your local IP as another trusted source.)

### Forming the connection within your app

Once your database is set-up and ready to go, you can begin to integrate it into your application.

I was using the [`golem` framework](https://thinkr-open.github.io/golem/) for my application, so I connected to the database and made the initial data pull by adding the following lines in my top-level `app_server.R` file.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'>db_con</span><span class='o'>(</span><span class='o'>)</span>
<span class='nv'>tbl_init</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbReadTable.html'>dbReadTable</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='s'>"my_data"</span><span class='o'>)</span>
</code></pre>

</div>

The custom `db_con()` function contains *roughly* the [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html) code we saw above, but I turned it into a function to incorporate some added complexity which I will describe shortly.

Most of the rest of my application uses Shiny modules, and this connection object and initial data pull can be seamless passed into either.

### CRUD operations

CRUD operations (Create, Read, Update, Delete) are at the heart of any interactive application with persistent data storage.

Interacting with your database within Shiny begins to look like more rote Shiny code. I do not describe this process in much detail since it is quite specific to what your app is trying to accomplish, but [this blog post](https://www.tychobra.com/posts/2020-01-29-shiny-crud-traditional/) provides some nice examples.

In short:

-   To add records to the table, you can use [`DBI::dbAppendTable()`](https://dbi.r-dbi.org/reference/dbAppendTable.html)
-   To remove records from the table, you can construct a `DELETE FROM my_data WHERE <conditions>` statement and run it with [`DBI::dbExecute()`](https://dbi.r-dbi.org/reference/dbExecute.html)

Some cautions on the second piece are included in the "Key Issues" section.

Key Issues
----------

Adding a permanent data store to your application can open up a lot of exciting new functionality. However, it may create some challenges that your typical data analyst or Shiny developer has not faced before. In this last section, I highlight a few key issues that you should be aware of and provide some recommendations.

### Securing data transfer

Already, we have one safeguard in place for data security since our application is the only Trusted Source able to interface with our database.

But, just like we secure our database credentials, it becomes important to think about securing the database itself. This is made easy with DigitalOcean because data is [end-to-end encrypted](https://docs.digitalocean.com/products/databases/), but depending on how or by whom your data is managed, this is something to bear in mind.

### Securing database credentials

No matter how safe the data itself is, it still may be at risk if anyone can obtain our database credentials.

Previously, I demonstrated how to connect to a database from R like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RPostgres</span><span class='nf'>::</span><span class='nf'><a href='https://rpostgres.r-dbi.org/reference/Postgres.html'>Postgres</a></span><span class='o'>(</span><span class='o'>)</span>,
                      host   <span class='o'>=</span> <span class='s'>"aabc.b.db.ondigitalocean.com"</span>,
                      dbname <span class='o'>=</span> <span class='s'>"db"</span>,
                      user      <span class='o'>=</span> <span class='s'>"db"</span>,
                      password  <span class='o'>=</span> <span class='s'>"abc123"</span>,
                      port     <span class='o'>=</span> <span class='m'>25060</span><span class='o'>)</span>
</code></pre>

</div>

However, you should never ever put your password in plaintext like this. Instead, you can use *environment variables* to store the value of sensitive credentials like a password or even a username like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RPostgres</span><span class='nf'>::</span><span class='nf'><a href='https://rpostgres.r-dbi.org/reference/Postgres.html'>Postgres</a></span><span class='o'>(</span><span class='o'>)</span>,
                      host   <span class='o'>=</span> <span class='s'>"aabc.b.db.ondigitalocean.com"</span>,
                      dbname <span class='o'>=</span> <span class='s'>"db"</span>,
                      user      <span class='o'>=</span> <span class='s'>"db"</span>,
                      password  <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Sys.getenv.html'>Sys.getenv</a></span><span class='o'>(</span><span class='s'>"DB_PASS"</span><span class='o'>)</span>,
                      port     <span class='o'>=</span> <span class='m'>25060</span><span class='o'>)</span>
</code></pre>

</div>

Then, you can define that same environment variable more securely in [within the App Platform](https://docs.digitalocean.com/products/app-platform/how-to/use-environment-variables/).

### Securing input integrity (SQL injection)

Finally, it's also important to be aware of [SQL injection](https://www.w3schools.com/sql/sql_injection.asp) to ensure that your database does not get corrupted.

SQL injection is usually discussed in the concept of malicious attacks. For example, W3 schools shows the following example where an application could be tricked into providing data on *all* users instead of a single user:

    txtUserId = getRequestString("UserId");
    txtSQL = "SELECT * FROM Users WHERE UserId = " + txtUserId;

If the entered `UserId` is `"UserId = 105 OR 1=1"`, then the full SQL string will be `"SELECT * FROM Users WHERE UserId = 105 OR 1=1;"`.

SQL injection is also at jokes you make have heard about "little Bobby Drop Tables" ([xkcd](https://xkcd.com/327/)).

![](https://imgs.xkcd.com/comics/exploits_of_a_mom.png)

That joke also, in some odd way, highlights that SQL injection need not be malicious. Rather, whenever we have software opened up to users beyond ourselves, they will likely use it in unexpected ways that push the system to its limit. For example, a user might try to enter or remove values from our database with double quotes, semicolons, or other features that mean something different to SQL than in human parlance and corrupt the code. Regardless of intent, we can protect against bad SQL that will break our application by using the [`DBI::sqlInterpolate()`](https://dbi.r-dbi.org/reference/sqlInterpolate.html) function.

A demonstration of this function and how it can protect against bad query generation is shown in [this post](https://shiny.rstudio.com/articles/sql-injections.html) by RStudio.

### Dev versus Prod

However, you may have realized a flaw in this approach. Our entire app now depends on forming a connection *that can only be made by the in-production app.* This meams you cannot test your application locally. However, even if our local traffic was not categorically blocked, we wouldn't *want* to test our app on the production database and recklessly add and remove entries.

Instead, we would ideally have *separate* databases: one for development and one for production. Ideally, these would be the same type of database (e.g. both Postgres) to catch nuances of different SQL syntax and database operations. However, to keep things simpler (and cheaper), I decided to use an in-memory SQLite database locally.

To accomplish this, I wrapped my database connection in a custom `db_con()` function that checks if the app is running in development or production (using [`golem::app_prod()`](https://rdrr.io/pkg/golem/man/prod.html) which in turn checks the `R_CONFIG_ACTIVE` environment variable) and connects to different databases in either case. In the development case, it creates an in-memory SQLite database and remakes the empty table.

(Another alternative to creating the database on-the-fly is to [pre-make a SQLite database](https://datacarpentry.org/R-ecology-lesson/05-r-and-databases.html#Creating_a_new_SQLite_database) saved to a `.sqlite` file and connect to that. But for this example, my sample table is so simple, creating it manually takes a negligible amount of time and keeps things quite readable, so I left it as-is.)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>db_con</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>prod</span> <span class='o'>=</span> <span class='nf'>golem</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/golem/man/prod.html'>app_prod</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>{</span>
  
  <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>prod</span><span class='o'>)</span> <span class='o'>{</span>
    
    <span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'>RPostgres</span><span class='nf'>::</span><span class='nf'><a href='https://rpostgres.r-dbi.org/reference/Postgres.html'>Postgres</a></span><span class='o'>(</span><span class='o'>)</span>,
                          host   <span class='o'>=</span> <span class='s'>"abc.b.db.ondigitalocean.com"</span>,
                          dbname <span class='o'>=</span> <span class='s'>"db"</span>,
                          user      <span class='o'>=</span> <span class='s'>"db"</span>,
                          password  <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/Sys.getenv.html'>Sys.getenv</a></span><span class='o'>(</span><span class='s'>"DB_PASS"</span><span class='o'>)</span>,
                          port     <span class='o'>=</span> <span class='m'>25060</span><span class='o'>)</span>
    
  <span class='o'>}</span> <span class='kr'>else</span> <span class='o'>{</span>
    
    <span class='nf'><a href='https://rdrr.io/r/base/stopifnot.html'>stopifnot</a></span><span class='o'>(</span> <span class='kr'><a href='https://rdrr.io/r/base/library.html'>require</a></span><span class='o'>(</span><span class='s'><a href='https://rsqlite.r-dbi.org'>"RSQLite"</a></span>, quietly <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span> <span class='o'>)</span>
    <span class='nv'>con</span> <span class='o'>&lt;-</span> <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbConnect.html'>dbConnect</a></span><span class='o'>(</span><span class='nf'><a href='https://rsqlite.r-dbi.org/reference/SQLite.html'>SQLite</a></span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>":memory:"</span><span class='o'>)</span>
    <span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='m'>1</span>, y <span class='o'>=</span> <span class='s'>"a"</span>, z <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2022-01-01"</span><span class='o'>)</span><span class='o'>)</span>
    <span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/dbWriteTable.html'>dbWriteTable</a></span><span class='o'>(</span><span class='nv'>con</span>, <span class='s'>"my_data"</span>, <span class='nv'>df</span><span class='o'>)</span>
    
  <span class='o'>}</span>
  
  <span class='kr'><a href='https://rdrr.io/r/base/function.html'>return</a></span><span class='o'>(</span><span class='nv'>con</span><span class='o'>)</span>
  
<span class='o'>}</span>
</code></pre>

</div>

### Managing connections

So, you've built a robust app that can run against a database locally or on your production server. Great! It's time to share your application with the world. But what if it is *so* popular that you have a lot of concurrent users and they are all trying to work with the database at once?

To maintain good application performance, you have to be careful about managing the database connection objects that you create (with [`DBI::dbConnect()`](https://dbi.r-dbi.org/reference/dbConnect.html)) and to close them when you are doing using them.

If this sounds manual and tedious, you're in luck! The [{pool}](https://rstudio.github.io/pool/) package adds a layer of abstraction to manage a *set* of connections and execute new queries to an available idle collection. Full examples are given on the package's website, but in short `{pool}` is quite easy to implement due to it's `DBI`-like syntax. You can replace `DBI::dbConenct()` with `pool::dbPool()` and proceed as usual!

