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
rmd_hash: 022d752ca9922208

---

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

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>,<span class='m'>2</span>,<span class='kc'>NA</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] NA</span></span>
<span></span><span><span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>x</span><span class='o'>)</span></span>
<span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarize</a></span><span class='o'>(</span><span class='nv'>df</span>, x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sum.html'>sum</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;    x</span></span>
<span><span class='c'>#&gt; 1 NA</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select sum(x)
from tbl


#> [90m# A tibble: 1 × 1[39m
#>   `sum(x)`
#>      [3m[90m<dbl>[39m[23m
#> [90m1[39m        3
</code></pre>

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

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span><span class='nv'>df</span>, z <span class='o'>=</span> <span class='nv'>x</span><span class='o'>-</span><span class='nv'>y</span><span class='o'>)</span></span>
<span><span class='c'>#&gt;    x  z</span></span>
<span><span class='c'>#&gt; 1  1  0</span></span>
<span><span class='c'>#&gt; 2  2  0</span></span>
<span><span class='c'>#&gt; 3 NA NA</span></span>
<span></span><span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>z</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/with.html'>with</a></span><span class='o'>(</span><span class='nv'>df</span>, <span class='nv'>x</span><span class='o'>-</span><span class='nv'>y</span><span class='o'>)</span></span>
<span><span class='nv'>df</span></span>
<span><span class='c'>#&gt;    x  z</span></span>
<span><span class='c'>#&gt; 1  1  0</span></span>
<span><span class='c'>#&gt; 2  2  0</span></span>
<span><span class='c'>#&gt; 3 NA NA</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>select *, x-y as z
from tbl


#> [90m# A tibble: 3 × 3[39m
#>       x     y     z
#>   [3m[90m<dbl>[39m[23m [3m[90m<int>[39m[23m [3m[90m<dbl>[39m[23m
#> [90m1[39m     1     3    -[31m2[39m
#> [90m2[39m     2     4    -[31m2[39m
#> [90m3[39m    [31mNA[39m     5    [31mNA[39m
</code></pre>

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


#> [90m# A tibble: 0 × 4[39m
#> [90m# … with 4 variables: A <dbl>, B <lgl>, X <lgl>, y <lgl>[39m
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/merge.html'>merge</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nv'>df2</span>, by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>inner_join</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nv'>df2</span>, by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"A"</span>, <span class='s'>"B"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'># merge(df1, df2, by = c("A","B"), incomparables = NA)</span></span>
<span><span class='c'># dplyr::inner_join(df1, df2, by = c("A", "B"), na_matches = "never")</span></span>
<span><span class='c'>#&gt;   A  B    X     Y</span></span>
<span><span class='c'>#&gt; 1 1 NA TRUE FALSE</span></span>
<span><span class='c'>#&gt;   A  B    X     Y</span></span>
<span><span class='c'>#&gt; 1 1 NA TRUE FALSE</span></span>
<span></span></code></pre>

</div>

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


#> [90m# A tibble: 0 × 3[39m
#> [90m# … with 3 variables: a <dbl>, b <lgl>, x <lgl>[39m
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>df1</span><span class='o'>[</span><span class='nv'>df1</span><span class='o'>$</span><span class='nv'>B</span> <span class='o'>!=</span> <span class='m'>1</span>,<span class='o'>]</span></span>
<span><span class='c'>#&gt;     A  B  X</span></span>
<span><span class='c'>#&gt; NA NA NA NA</span></span>
<span></span><span><span class='nf'>dplyr</span><span class='nf'>::</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nv'>B</span> <span class='o'>!=</span> <span class='m'>1</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] A B X</span></span>
<span><span class='c'>#&gt; &lt;0 rows&gt; (or 0-length row.names)</span></span>
<span></span></code></pre>

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


#> [90m# A tibble: 3 × 4[39m
#>   store_id `avg(amt_spend)` `sum(amt_spend) / count(amt_spend)` `sum(amt_spend)…
#>      [3m[90m<dbl>[39m[23m            [3m[90m<dbl>[39m[23m                               [3m[90m<dbl>[39m[23m            [3m[90m<dbl>[39m[23m
#> [90m1[39m       [31mNA[39m            100.                                100.              66.7
#> [90m2[39m        1             99.2                                99.2             99.2
#> [90m3[39m        2             99.2                                99.2             99.2
</code></pre>

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


#> [90m# A tibble: 6 × 4[39m
#>   STORE_ID MONTH AMT_SPEND amt_return
#>      [3m[90m<dbl>[39m[23m [3m[90m<dbl>[39m[23m     [3m[90m<dbl>[39m[23m      [3m[90m<dbl>[39m[23m
#> [90m1[39m        1     1     100.       [31mNA[39m   
#> [90m2[39m        2     1      99.3       9.97
#> [90m3[39m        1     2      98.7      10.1 
#> [90m4[39m        2     2      98.2       9.88
#> [90m5[39m        1     3      98.7      10.1 
#> [90m6[39m        2     3     100.       10.1
</code></pre>

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


#> [90m# A tibble: 9 × 4[39m
#>   STORE_ID MONTH AMT_SPEND amt_return
#>      [3m[90m<dbl>[39m[23m [3m[90m<dbl>[39m[23m     [3m[90m<dbl>[39m[23m      [3m[90m<dbl>[39m[23m
#> [90m1[39m        1     1     100.       [31mNA[39m   
#> [90m2[39m        2     1      99.3       9.97
#> [90m3[39m       [31mNA[39m     1     100.        9.88
#> [90m4[39m        1     2      98.7      10.1 
#> [90m5[39m        2     2      98.2       9.88
#> [90m6[39m       [31mNA[39m     2      99.9      10.1 
#> [90m7[39m        1     3      98.7      10.1 
#> [90m8[39m        2     3     100.       10.1 
#> [90m9[39m       [31mNA[39m     3      [31mNA[39m         9.89
</code></pre>

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


#> [90m# A tibble: 3 × 2[39m
#>   month net_spend
#>   [3m[90m<dbl>[39m[23m     [3m[90m<dbl>[39m[23m
#> [90m1[39m     1      180.
#> [90m2[39m     2      267.
#> [90m3[39m     3      179.
</code></pre>

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


#> [90m# A tibble: 9 × 4[39m
#>   month amt_spend amt_return net_spend
#>   [3m[90m<dbl>[39m[23m     [3m[90m<dbl>[39m[23m      [3m[90m<dbl>[39m[23m     [3m[90m<dbl>[39m[23m
#> [90m1[39m     1     100.       [31mNA[39m         [31mNA[39m  
#> [90m2[39m     1      99.3       9.97      89.3
#> [90m3[39m     1     100.        9.88      90.4
#> [90m4[39m     2      98.7      10.1       88.6
#> [90m5[39m     2      98.2       9.88      88.3
#> [90m6[39m     2      99.9      10.1       89.8
#> [90m7[39m     3      98.7      10.1       88.5
#> [90m8[39m     3     100.       10.1       90.1
#> [90m9[39m     3      [31mNA[39m         9.89      [31mNA[39m
</code></pre>

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


#> [90m# A tibble: 3 × 2[39m
#>   month net_spend
#>   [3m[90m<dbl>[39m[23m     [3m[90m<dbl>[39m[23m
#> [90m1[39m     1      280.
#> [90m2[39m     2      267.
#> [90m3[39m     3      169.
</code></pre>

</div>

## Logistic Regression (R vs python)

## Feature Importance (R vs Spark)

## Conclusion

