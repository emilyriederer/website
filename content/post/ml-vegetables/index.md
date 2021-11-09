---
output: hugodown::md_document
title: "Why machine learning thinks I should stop eating vegetables"
subtitle: ""
summary: "A personal encounter with data products gone wrong"
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
  caption: ""
  focal_point: ""
  preview_only: true

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: [""]
rmd_hash: 9ed4c2803b686382

---

The collapse of [Zillow Offers](https://www.nytimes.com/2021/11/02/business/zillow-q3-earnings-home-flipping-ibuying.html) last week reignited the dialogue about good and bad uses of machine learning in industry. Low-value or counterproductive applications are all too common, and they can pose a range of risks from financial loss (in the case of Zillow) to consumer harm. This discourse inspired me to brush off a half-written draft I've had for a while about a pandemic-era personal experience with bad and potentially harmful (but not to me specifically) machine learning.

In this post, I will briefly overview some unexpected "automated advice" that a fitness app began to give me and my best guess as the underlying cause. This serves as just one more data point in the ever-growing corpus of cautionary tales of machine learning use cases.

Background
----------

Early on in the pandemic, I started to engage in some personal data collection, including using a running app, a nutrition app, and a time-tracking app. This was motivated in equal if not greater part by giving my fingers something to do tapping away at different applications rather than envisioning any specific project or usage for said data. However, there were two unexpected benefits.

First, it gave me an entirely new level of appreciation for what unreliable narrators individuals (like me!) are with self-reported data. Personal manual data entry is exceedingly uninteresting. I had zero incentive to lie -- no one would ever see this data but me! -- but nevertheless my reporting quality quickly devolved. Specifically, working with the nutrition app was incredibly boring so I started taking easy "shortcuts" which eroded any semblance of data quality. As an example that will become quite relevant shortly, it was far easier to copy the same thing from day-to-day than look up different foods. As a result, foods became metonyms for one another; any vegetable I ate was "encoded" as green beans and cauliflower because those had ended up on this list one day and I just kept copying them. Specifically, the important thing to know is that I had a few items logged *every single day in the same quantities*.

Second, and related to the first, I came to learn that the app I was using was attempting to apply some sort of "intelligence" (by which, we cannot emphasize enough, means only automation) to make recommendations based on my sketchy inputs. Most curiously, on many occasions, the app seemed convinced that I should stop eating vegetables and warned of a "Negative pattern detected":

![](bean.JPG)

![](cauli.JPG)

Upon tapping these curious warnings and venturing down the rabbit hole, it explained "We've noticed that on days you incorporate {food}, your total calories tend to be higher".

![](featured.JPG)

Uhh... okay?

What caused it?
---------------

Naturally, I became intrigued was sort of algorithm-gone-wrong was convinced my life would be better off without vegetables. Of course, I cannot ever know the exact technology underlying this feature, but there were some intriguing clues.

I first thought about the most naive way possible that one might seek to identify such relationships. My first thought was somehow correlating the amount of different foods with total daily calories. This seemed like a reasonable culprit since correlation comes up by or before Chapter 3 in introductory statistics and is perhaps best known for masquerading as causation. However, my sloppy, lazy data collection helped rule out this quickly because I knew that there was **zero variance** in the amounts or incidences of these vegetables.

This fact of zero variance made me suspect that the actual quantities of the targetted items were not a factor in the method used. That is, it seemed likely that the approach being used was the result of some type of categorical data analysis. My next guess was that the suggestions were the result of [association rules](https://en.wikipedia.org/wiki/Association_rule_learning). ARs are notoriously sensitive to their evaluation metrics (which guides what type of patterns are considered "interesting") so this seemed like a likely culprit.

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

<span class='c'># create fake observations -----</span>
<span class='nv'>log</span> <span class='o'>&lt;-</span>
  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"a"</span>, <span class='s'>"z"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"b"</span>, <span class='s'>"z"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"c"</span>, <span class='s'>"z"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"d"</span>, <span class='s'>"z"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"e"</span>, <span class='s'>"z"</span>, <span class='s'>"hi"</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"f"</span>, <span class='s'>"w"</span>, <span class='s'>"lo"</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"g"</span>, <span class='s'>"w"</span>, <span class='s'>"lo"</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"h"</span>, <span class='s'>"w"</span>, <span class='s'>"lo"</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"i"</span>, <span class='s'>"w"</span>, <span class='s'>"lo"</span><span class='o'>)</span>,
  <span class='nf'><a href='https://rdrr.io/pkg/arules/man/combine.html'>c</a></span><span class='o'>(</span><span class='s'>"x"</span>, <span class='s'>"j"</span>, <span class='s'>"w"</span>, <span class='s'>"lo"</span><span class='o'>)</span>
  <span class='o'>)</span>

<span class='c'># convert to arules-specific transaction class ----</span>
<span class='nv'>log_trans</span> <span class='o'>&lt;-</span> <span class='nf'>as</span><span class='o'>(</span><span class='nv'>log</span>, <span class='s'>"transactions"</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/dim.html'>dim</a></span><span class='o'>(</span><span class='nv'>log_trans</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 10 15</span>

<span class='c'># learn association rules ----</span>
<span class='nv'>rules</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/arules/man/apriori.html'>apriori</a></span><span class='o'>(</span><span class='nv'>log_trans</span>,
                 parameter  <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>support <span class='o'>=</span> <span class='m'>0.5</span>, confidence <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span>,
                 appearance <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>rhs <span class='o'>=</span> <span class='s'>"hi"</span><span class='o'>)</span>,
                 control    <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>verbose <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span>
                 <span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/pkg/arules/man/inspect.html'>inspect</a></span><span class='o'>(</span><span class='nv'>rules</span><span class='o'>)</span>

<span class='c'>#&gt;     lhs      rhs  support confidence coverage lift count</span>
<span class='c'>#&gt; [1] {}    =&gt; {hi} 0.5     0.5        1.0      1    5    </span>
<span class='c'>#&gt; [2] {z}   =&gt; {hi} 0.5     1.0        0.5      2    5    </span>
<span class='c'>#&gt; [3] {x}   =&gt; {hi} 0.5     0.5        1.0      1    5    </span>
<span class='c'>#&gt; [4] {x,z} =&gt; {hi} 0.5     1.0        0.5      2    5</span>
</code></pre>

</div>

Key Takeaways
-------------

Do out-of-the-box algorithms work? Maybe kind of but probably not? Need to think about what you are doing!

Optimization is a fallacy Optimizing for whom? For what outcome? Same with metrics -- what value judgements are doing into those?

Would system work better if I wasn't a lazy and disengaged user? Probably, but don't assume data quality you don't have

Does the problem even make sense? Higher days would tend to be more anomalous (birthdays, Superbowls) Is this even a useful metric if it could be done? (Not causal so how would you act on it?)

Should ML be giving automated health and diet advice at all? Similar concerns with diet websites/content served to ED patients
