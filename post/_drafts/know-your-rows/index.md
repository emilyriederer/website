---
output: hugodown::md_document
title: "Know, know, know your rows"
subtitle: ""
summary: "Understanding data models - plaguing junior analysts since forever, saving data jobs from automation since 2023"
authors: []
tags: [sql, data]
categories: [sql, data]
date: 2023-06-05
lastmod: 2023-06-05
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
rmd_hash: c10611e2e7035904

---

Data practitioners -- from engineers, scientists, and analysts -- tend to focus on the *columns* or variables in a table. The column-centric mindset permeates everything from columnar databases and file formats (e.g. Parquet), columnar focus in data documentation (e.g. defining fields, showing column lineage), and applications (e.g. enhancing metric definitions and feature engineering). The extent of column supremacy is perhaps best illustrated in the many modern data documentation and discovery tools which allow for rich column metadata but have done relatively little to structure one's understanding of the upstream real-world systems generating rows.

However, often many misconceptions lurk in understanding the grain of a table. That is: do you really know your rows? It's not uncommon for junior analysts will blindly start querying a table without fully realizing that:

1.  You don't know the intent of a record
2.  You don't know what triggers a record
3.  You don't know what changes a record
4.  You don't know row-based performance optimization

This has been on my mind lately in the wake of ChatGPT and related LLM tools promising to automate SQL query generation. Analysis can so easily go wrong when the base population obtained is not appropriately "fit for purpose" to the core analytical question. While misunderstanding rows may be the bane of junior analysts, this illustrates one of many sources of nuances and higher-level reasoning in crafting accurate data queries which I suspect will leave it a task for humans not machines for a long time to come.

In this post, we'll examine a few case studies of what we often neglect to interrogate about our rows and how it can affect our analysis results.

## You don't know the intent

Row definitions can seem superficially obvious since "what makes a row", in theory, corresponds to the very definition of the table in which the row lives in the relational model. In theory, each record represents a well-defined "entity" so table naming and the overall data model *imply* the definition of a row. In practice, it's not the simple.

Suppose that you're an analyst looking to analyze website login data to check for friction in the UX. You may find a promising table in your database called `login`s - huzzah! But what does that really mean?

![](login-log.png)

A data engineering might have defined (or, rather *instrumented*) a "login" to be any of a wide-ranging number of events throughout the login process. Are "logins" login *attempts*? *Successes*? Further, what actually is an attempt? Did you have to pass a Captcha that you weren't a robot? Could you even attempt to login if you forgot your username or couldn't find the submit button?

Which of these events gets collected and recorded has a significant impact on subsequent data processing. In a technical sense, no inclusion/exclusion decision here is *incorrect*, per se, but if the producers' choices don't match the consumers' understandings, we will end up with misleading results.

Consider calculating the rate of successful website logins. Reasonably enough, an analyst might compute this rate as the sum of successful events over the total. Now, suppose two users attempt to login to their account, and ultimately, one succeeds in accessing their private information and the other doesn't. The analyst would probably hope to compute and report a 50% success rate. However, depending on how the data is represented, they could quite easily compute nearly any value from 0% to 100%.

As a thought experiment, we can consider what types of events might be logged:

-   **Per Attempt**: If data is logged once per overall login attempt, successful attempts only trigger one event, but a user who forgot their password may try (and fail) to login multiple times. In the case illustrated above, that deflates the successful login rate to **25%**.
-   **Per Event**: If the logins table contains a row for every login-related event, each 'success' will trigger a large number of positive events and each 'failure' will trigger a negative event preceded by zero or more positive events. In the case illustrated below, this inflates our successful login rate to **86%**.
-   **Per Conditional**: If the collector decided to only look at downstream events, perhaps to circumvent record duplication, they might decide to create a record only to denote the success or failure of the final step in the login process (MFA). However, login attempts that failed an upstream step would not generate any record for this stage because they've already fallen out of the funnel. In this case, the computed rate could reach **100%**
-   **Per Intermediate**: Similarly, if the login was defined specifically as successful password verification, the computed rate could his **100%** even if some users subsequently fail MFA

These different situations are further illustrated below.

![](login-rate.png)

<div class="highlight">

|          | Session | Attempt | Event | Outcome | Intermediate |
|:---------|--------:|--------:|------:|--------:|-------------:|
| Success  |       1 |       1 |     6 |       1 |            2 |
| Total    |       2 |       4 |     7 |       1 |            2 |
| Rate (%) |      50 |      25 |    86 |     100 |          100 |

Success rate naively computed under different data collection schemes

</div>

## 2. You don't know what triggers events

Even if you know the intent of a row is supposed to mean, without understanding the real-world process that generates that row, we cannot reason about *when* that row will be logged which introduces risks of incomplete and potentially biased data.

Suppose an e-commerce analyst is trying to analyze total revenues based on an `orders` table. An order might be fairly well-defined and widely agreed upon: a customer completed a checkout flow and paid for a specific set of items to be provided by the company. However, depending what upstream *system* this data is sourced from, the data might have different biases.

If the data is sourced from the order collection system, it should contain all orders for a given date fairly rapidly. However, if order data is sourced from a payment processing system that only bills customers once items are shipped, not all orders *placed* on a given data would populate in the table at the same time. (The third case illustrated below is discussed in the next section.) The source system for our records, then, sets our expectations on data latency and changes our definition of data completeness. It might be a fool's errand to report "sales from the last four hours" from an order fulfillment table.

Further, data sourced from more slowly updating systems (e.g. the shipping stage) might cause biased discrepancies and missing not-at-random data. For example, consider that many e-commerce companies offer "fast/free shipping if you spend more than \$X dollars", the same mechanism that would cause some orders to ship faster than others are confounded with the order's value. Thus, even the calculation of average spend metrics could be compromised when, for a given order date, records for higher value orders appear more expediently than low value orders.

![](order-date.png)

## 3. You don't know what can change

It's also possible to know what causes a row to enter into a table but misunderstand what can cause an existing record to *change*. Consider if the `orders` table above is intended to track orders throughout their fulfillment process. Then the table might be organized in a few different ways:

-   An event log: 1 record for each order x processing-step (e.g. separate records for order-placed, order-shipped, etc.)
-   An single event type: 1 record when the order is placed *or* shipped, depending on how that event was defined
-   An updating record: 1 record per order with a changing `order_status` field

![](featured.jpg)

Naturally, the different grains of this table have different implications for computing something as simple as a count of orders in a given period (to avoid double-counting) and understanding if historical records are able to change in a subsequent analysis.

## 4. You don't know the storage optimizations

Beyond analytical issues, there are also performance considerations. For large tables, different databases offer different ways to optimize query performance by savy storage and organization of rows including sortkeys, distkeys, clustering keys, and partitioning keys. If anaylsts know how such keys were set, they can savily use these in query filters, aggregations, etc. to achieve better performance on retrieval. However, if analysts don't know what keys the data producers set, the efforts of the data producer are in vein and, in fact, may sometimes hurt performance over the base case. (Some new features in emerging file formats like Apache Iceberg are working on workarounds here, but that is the minority case.)

