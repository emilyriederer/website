---
output: hugodown::md_document
title: "Why machine learning thinks I should stop eating vegetables"
subtitle: ""
summary: "A personal experience with data products gone wrong"
authors: []
tags: []
categories: [data-disasters]
date: 2021-11-10
lastmod: 2021-11-10
featured: false
draft: false
aliases:

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "Application screenshot"
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: 3c4f33228b7194bc

---

The collapse of [Zillow Offers](https://www.nytimes.com/2021/11/02/business/zillow-q3-earnings-home-flipping-ibuying.html) last week reignited the dialogue about good and bad uses of machine learning in industry. Low-value or counterproductive applications are all too common, and they can pose a range of risks from financial loss (in the case of Zillow) to consumer harm. This discourse inspired me to brush off a half-written draft I've had for a while about a pandemic-era personal experience with bad and potentially harmful (but not to me specifically) machine learning.

In this post, I will briefly overview some unexpected "automated advice" that a fitness app began to give me and my best guess as the underlying cause. This serves as just one more data point in the ever-growing corpus of cautionary tales of machine learning use cases.

Background
----------

personal data collection during the pandemic

did it with increasing laziness and disinterest

two key findings: - never trust self report data

What happened?
--------------

I started putting some of the same stuff all the time because I'm lazy

My app started telling me to not each vegetables

![](bean.JPG)

![](cauli.JPG)

What caused it?
---------------

First, I really don't know

Couldn't be "correlation" because of ZERO VARIANCE

Pattern mining?

### A digression on metrics

That checks out if use a very naive interestingness metric

support: frequency(X) / total observations

confidence: support(X and Y) / support(X)

lift: support(x and y) / support(x) \* support(y)

### A demo

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/mhahsler/arules'>arules</a></span><span class='o'>)</span>

<span class='c'>#&gt; Warning: package 'arules' was built under R version 4.0.5</span>

<span class='c'>#&gt; Loading required package: Matrix</span>

<span class='c'>#&gt; </span>
<span class='c'>#&gt; Attaching package: 'arules'</span>

<span class='c'>#&gt; The following objects are masked from 'package:base':</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;     abbreviate, write</span>

<span class='c'># support: frequency(X) / n</span>
<span class='c'># confidence: support(x and y) / support(x)</span>
<span class='c'># lift: support(x and y) / (support(x) * support(y))</span>

<span class='nv'>basket</span> <span class='o'>&lt;-</span>
  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"lo"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"lo"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"lo"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"lo"</span><span class='o'>)</span>,
    <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"beans"</span>, <span class='s'>"lo"</span><span class='o'>)</span>
  <span class='o'>)</span>

<span class='c'># correlation? ----</span>
<span class='nv'>trans_df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  beans <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>5</span><span class='o'>)</span>,
  total <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='m'>1.1</span>, <span class='m'>1.5</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='m'>0.7</span>, <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
<span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/with.html'>with</a></span><span class='o'>(</span><span class='nv'>trans_df</span>, <span class='nf'><a href='https://rdrr.io/r/stats/cor.html'>cor</a></span><span class='o'>(</span><span class='nv'>beans</span>, <span class='nv'>total</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; Warning in cor(beans, total): the standard deviation is zero</span>

<span class='c'>#&gt; [1] NA</span>

<span class='c'># association rules ----</span>
<span class='nv'>trans</span> <span class='o'>&lt;-</span> <span class='nf'>as</span><span class='o'>(</span><span class='nv'>basket</span>, <span class='s'>"transactions"</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/dim.html'>dim</a></span><span class='o'>(</span><span class='nv'>trans</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 10  3</span>

<span class='nf'><a href='https://rdrr.io/pkg/arules/man/itemMatrix-class.html'>itemLabels</a></span><span class='o'>(</span><span class='nv'>trans</span><span class='o'>)</span>

<span class='c'>#&gt; [1] "beans" "hi"    "lo"</span>

<span class='nf'><a href='https://rdrr.io/r/base/summary.html'>summary</a></span><span class='o'>(</span><span class='nv'>trans</span><span class='o'>)</span>

<span class='c'>#&gt; transactions as itemMatrix in sparse format with</span>
<span class='c'>#&gt;  10 rows (elements/itemsets/transactions) and</span>
<span class='c'>#&gt;  3 columns (items) and a density of 0.6666667 </span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; most frequent items:</span>
<span class='c'>#&gt;   beans      hi      lo (Other) </span>
<span class='c'>#&gt;      10       5       5       0 </span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; element (itemset/transaction) length distribution:</span>
<span class='c'>#&gt; sizes</span>
<span class='c'>#&gt;  2 </span>
<span class='c'>#&gt; 10 </span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. </span>
<span class='c'>#&gt;       2       2       2       2       2       2 </span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; includes extended item information - examples:</span>
<span class='c'>#&gt;   labels</span>
<span class='c'>#&gt; 1  beans</span>
<span class='c'>#&gt; 2     hi</span>
<span class='c'>#&gt; 3     lo</span>

<span class='nf'><a href='https://rdrr.io/pkg/arules/man/image.html'>image</a></span><span class='o'>(</span><span class='nv'>trans</span><span class='o'>)</span>

</code></pre>
<img src="figs/unnamed-chunk-1-1.png" width="700px" style="display: block; margin: auto;" />
<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>rules</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/arules/man/apriori.html'>apriori</a></span><span class='o'>(</span><span class='nv'>trans</span>,
                 parameter <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>support <span class='o'>=</span> <span class='m'>0.5</span>, confidence <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span>,
                 appearance <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>rhs <span class='o'>=</span> <span class='s'>"hi"</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; Apriori</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Parameter specification:</span>
<span class='c'>#&gt;  confidence minval smax arem  aval originalSupport maxtime support minlen</span>
<span class='c'>#&gt;         0.5    0.1    1 none FALSE            TRUE       5     0.5      1</span>
<span class='c'>#&gt;  maxlen target  ext</span>
<span class='c'>#&gt;      10  rules TRUE</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Algorithmic control:</span>
<span class='c'>#&gt;  filter tree heap memopt load sort verbose</span>
<span class='c'>#&gt;     0.1 TRUE TRUE  FALSE TRUE    2    TRUE</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Absolute minimum support count: 5 </span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; set item appearances ...[1 item(s)] done [0.00s].</span>
<span class='c'>#&gt; set transactions ...[3 item(s), 10 transaction(s)] done [0.00s].</span>
<span class='c'>#&gt; sorting and recoding items ... [3 item(s)] done [0.00s].</span>
<span class='c'>#&gt; creating transaction tree ... done [0.00s].</span>
<span class='c'>#&gt; checking subsets of size 1 2 done [0.00s].</span>
<span class='c'>#&gt; writing ... [2 rule(s)] done [0.00s].</span>
<span class='c'>#&gt; creating S4 object  ... done [0.00s].</span>

<span class='nf'><a href='https://rdrr.io/pkg/arules/man/inspect.html'>inspect</a></span><span class='o'>(</span><span class='nv'>rules</span><span class='o'>)</span>

<span class='c'>#&gt;     lhs        rhs  support confidence coverage lift count</span>
<span class='c'>#&gt; [1] {}      =&gt; {hi} 0.5     0.5        1        1    5    </span>
<span class='c'>#&gt; [2] {beans} =&gt; {hi} 0.5     0.5        1        1    5</span>
</code></pre>

</div>

Key Takeaways
-------------

Do out-of-the-box algorithms work? Maybe kind of but probably not? Need to think about what you are doing!

Optimization is a fallacy Optimizing for whom? For what outcome? Same with metrics -- what value judgements are doing into those?

Would system work better if I wasn't a lazy and disengaged user? Probably, but don't assume data quality you don't have

Should ML be giving automated health and diet advice at all? Similar concerns with diet websites/content served to ED patients

