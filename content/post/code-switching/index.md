---
output: hugodown::md_document
title: "Code Switching"
subtitle: ""
summary: "How different languages reflect the context of their creation"
authors: []
tags: [rstats]
categories: []
date: 2022-09-03
lastmod: 2022-09-03
featured: false
draft: false
aliases:

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "Art by the inimitable [Allison Horst](https://twitter.com/allison_horst?lang=en), as first seen in JD Long's [rstudio::conf(2019)](https://cerebralmastication.com/2019/01/18/slides-from-rstudio-conf-2019/) talk"
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: 74c644410267d069

---

<div class="highlight">

</div>

Interoperability work: + Posit + dbt python models + arrow

Big picture really powerful; however not just a technical problem but a cultural one

Reasonable defaults change by language

## Object Representation (R vs Python)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='m'>3</span></span>
<span><span class='nv'>y</span> <span class='o'>=</span> <span class='nv'>x</span></span>
<span><span class='nv'>x</span><span class='o'>[</span><span class='m'>4</span><span class='o'>]</span> <span class='o'>=</span> <span class='m'>4</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='nv'>y</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] 1 2 3 4</span></span>
<span><span class='c'>#&gt; [1] 1 2 3</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>x = [1,2,3]
y = x 
x.append(4)
print(x)
print(y)

#> [1, 2, 3, 4]
#> [1, 2, 3, 4]
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>import numpy as np
x = np.array([1,2,3])
y = x
x = x * 5
print(x)
print(y)

#> [ 5 10 15]
#> [1 2 3]
</code></pre>

</div>

## Null Handling (R vs SQL)

<div class="highlight">

</div>

### Aggregation

R defaults to NA for column SQL allows Python: numpy disallows, but works in pandas agg

<div class='highlight'>
<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>,<span class='m'>2</span>,<span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] NA</span></span>
<span></span><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span><span class='nv'>df</span>, x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span></span>
</code></pre>

|   x |
|----:|
|  NA |

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select sum(x)
from tbl


</code></pre>

| sum(x) |
|-------:|
|      3 |

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>import pandas as pd
import numpy as np
x = [1,2,np.nan]
y = [3,4,5]
df = pd.DataFrame({'x':x,'y':y})
sum(x)

#> nan

np.sum(x)

#> nan

df.agg({'x': ['sum']})

#>        x
#> sum  3.0
</code></pre>

</div>

### Transformation

No one allows its

<div class='highlight'>
<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span><span class='nv'>df</span>, z <span class='o'>=</span> <span class='nv'>x</span><span class='o'>-</span><span class='nv'>y</span><span class='o'>)</span></span>
</code></pre>

|   x |   z |
|----:|----:|
|   1 |   0 |
|   2 |   0 |
|  NA |  NA |

<span class="nv">df</span> </code>
</pre>

|   x |   z |
|----:|----:|
|   1 |   0 |
|   2 |   0 |
|  NA |  NA |

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select *, x-y as z
from tbl


</code></pre>

|   x |   y |   z |
|----:|----:|----:|
|   1 |   3 |  -2 |
|   2 |   4 |  -2 |
|  NA |   5 |  NA |

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>np.array(x) - np.array(y)

#> array([-2., -2., nan])

df.assign(z = lambda d: d.x - d.y)

#>      x  y    z
#> 0  1.0  3 -2.0
#> 1  2.0  4 -2.0
#> 2  NaN  5  NaN
</code></pre>

</div>

### Joining

SQL doesn't recognize, by default R and python do

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select tbl1.*, tbl2.Y 
from 
  tbl1 inner join tbl2 
  on 
  tbl1.A = tbl2.A and 
  tbl1.B = tbl2.B


</code></pre>

|   A | B   | X   | y   |
|----:|:----|:----|:----|

</div>

<div class='highlight'>
<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/merge.html'>merge</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nv'>df2</span>, by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nv'>df2</span>, by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'># merge(df1, df2, by = c("A","B"), incomparables = NA)</span></span>
<span><span class='c'># dplyr::inner_join(df1, df2, by = c("A", "B"), na_matches = "never")</span></span>
</code></pre>

|   A | B   | X    | Y     |
|----:|:----|:-----|:------|
|   1 | NA  | TRUE | FALSE |

|   A | B   | X    | Y     |
|----:|:----|:-----|:------|
|   1 | NA  | TRUE | FALSE |

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>import numpy as np
import pandas as pd
df1 = pd.DataFrame([[1, np.nan, True]], columns = ['A','B','X'])
df2 = pd.DataFrame([[1, np.nan, False]], columns = ['A','B','Y'])
pd.merge(df1, df2)

#>    A   B     X      Y
#> 0  1 NaN  True  False
</code></pre>

</div>

### Filtering

SQL doesn't recognize

Neither R nor dplyr give data back, but do so in different ways

pandas does recognize

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select A, B, X 
from tbl1 
where B != 1


</code></pre>

|   a | b   | x   |
|----:|:----|:----|

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df1</span><span class='o'>[</span><span class='nv'>df1</span><span class='o'>$</span><span class='nv'>B</span> <span class='o'>!=</span> <span class='m'>1</span>,<span class='o'>]</span></span>
</code></pre>

|     |   A | B   | X   |
|:----|----:|:----|:----|
| NA  |  NA | NA  | NA  |

</code>
</pre>

 A\|B \|X \|

\|--:\|:--\|:--\|

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>df1[df1.B != 1]

#>    A   B     X
#> 0  1 NaN  True

df1.query('B != 1')

#>    A   B     X
#> 0  1 NaN  True
</code></pre>

</div>

## Example

<div class="highlight">

</div>

Average spend per month?

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select 
  store_id, 
  avg(amt_spend), 
  sum(amt_spend) / count(amt_spend), 
  sum(amt_spend) / count(1)
from spend
group by 1
order by 1


</code></pre>

| store\_id | avg(amt\_spend) | sum(amt\_spend) / count(amt\_spend) | sum(amt\_spend) / count(1) |
|--------:|------------:|----------------------------:|---------------------:|
|        NA |       100.01360 |                           100.01360 |                   66.67573 |
|         1 |        99.54544 |                            99.54544 |                   99.54544 |
|         2 |       100.43765 |                           100.43765 |                  100.43765 |

</div>

Net sales?

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select 
  spend.*,
  returns.amt_return
from 
  spend
  inner join
  returns 
  on
  spend.store_id = returns.store_id and
  spend.month = returns.month


</code></pre>

| STORE\_ID | MONTH | AMT\_SPEND | amt\_return |
|----------:|------:|-----------:|------------:|
|         1 |     1 |  100.42447 |          NA |
|         2 |     1 |  100.40317 |    9.951985 |
|         1 |     2 |   98.80412 |   10.052713 |
|         2 |     2 |  100.14649 |   10.130757 |
|         1 |     3 |   99.40774 |    9.842270 |
|         2 |     3 |  100.76328 |    9.878809 |

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select
  spend.*,
  returns.amt_return
from 
  spend
  inner join
  returns 
  on
  coalesce(spend.store_id, 999) = coalesce(returns.store_id, 999) and
  spend.month = returns.month


</code></pre>

| STORE\_ID | MONTH | AMT\_SPEND | amt\_return |
|----------:|------:|-----------:|------------:|
|         1 |     1 |  100.42447 |          NA |
|         2 |     1 |  100.40317 |    9.951985 |
|        NA |     1 |   99.04718 |   10.030175 |
|         1 |     2 |   98.80412 |   10.052713 |
|         2 |     2 |  100.14649 |   10.130757 |
|        NA |     2 |  100.98002 |   10.024178 |
|         1 |     3 |   99.40774 |    9.842270 |
|         2 |     3 |  100.76328 |    9.878809 |
|        NA |     3 |         NA |    9.806780 |

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select
  spend.month, 
  sum(amt_spend - amt_return) as net_spend
from 
  spend
  inner join
  returns 
  on
  coalesce(spend.store_id, 999) = coalesce(returns.store_id, 999) and
  spend.month = returns.month
group by 1
order by 1


</code></pre>

| month | net\_spend |
|------:|-----------:|
|     1 |   179.4682 |
|     2 |   269.7230 |
|     3 |   180.4499 |

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select
  spend.month, 
  amt_spend,
  amt_return,
  amt_spend - amt_return as net_spend
from 
  spend
  inner join
  returns 
  on
  coalesce(spend.store_id, 999) = coalesce(returns.store_id, 999) and
  spend.month = returns.month


</code></pre>

| month | amt\_spend | amt\_return | net\_spend |
|------:|-----------:|------------:|-----------:|
|     1 |  100.42447 |          NA |         NA |
|     1 |  100.40317 |    9.951985 |   90.45119 |
|     1 |   99.04718 |   10.030175 |   89.01700 |
|     2 |   98.80412 |   10.052713 |   88.75140 |
|     2 |  100.14649 |   10.130757 |   90.01573 |
|     2 |  100.98002 |   10.024178 |   90.95584 |
|     3 |   99.40774 |    9.842270 |   89.56547 |
|     3 |  100.76328 |    9.878809 |   90.88447 |
|     3 |         NA |    9.806780 |         NA |

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select
  spend.month, 
  sum(coalesce(amt_spend,0) - coalesce(amt_return,0)) as net_spend
from 
  spend
  inner join
  returns 
  on
  coalesce(spend.store_id, 999) = coalesce(returns.store_id, 999) and
  spend.month = returns.month
group by 1
order by 1


</code></pre>

| month | net\_spend |
|------:|-----------:|
|     1 |   279.8927 |
|     2 |   269.7230 |
|     3 |   170.6432 |

</div>

## Logistic Regression (R vs python)

## Feature Importance (R vs Spark)

## Conclusion

