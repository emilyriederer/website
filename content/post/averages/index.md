---
output: hugodown::md_document
title: "Draft"
subtitle: ""
summary: ""
authors: []
tags: []
categories: [data]
date: 2021-09-27
lastmod: 2021-09-27
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
rmd_hash: fbbf5e0b56c8ae58

---

Last month, I dusted off a training course that I first developed in 2018 to teach to a class of new hires at work. The content focuses on many types of *data disasters*[^1] that are often encountered when working with data -- from misunderstanding how data is structured and tools work to errors in causal inference and model building -- yet rarely taught in stats training.

This year, however, the material felt a bit different, and it was not simply because (for now the second year) I was sitting alone in a room all afternoon rambling to myself and a Zoom screen about all the ways everything can go wrong.

{{&lt; tweet 1305666403824021507 &gt;}}

This year, the material took on a whole new level of gravity. In a nutshell, as I walked through my taxonomy and examples of data disasters, one of my underlying message had always been that stats education focuses on the "complex" things (e.g. proving asymptotic convergence) but simple things can also be hard and important. However, as the pandemic has evolved over the last year and a half, more highly important data analysis has been done in the open than ever before, and much of it has unsurprisingly hit many of the snags one would when working with messy, inconsistent, ever-changing, observational data.

As I walked through the course, I found myself thinking about many pandemic-related examples for every "disasters" which all felt more urgent and timely than the industry-specific examples that I had concocted. In this post, I walk through just one such example of simple things that are hard. This is the story of a [simple average informing public health policy in Indiana](https://www.indystar.com/story/news/health/2020/12/23/covid-indiana-positivity-rate-error-corrected-dec-30/4013741001/) and what it illustrates about imprecise estimands, (possibly BI tools), independence assumptions, de Moivre's equation, and sampling bias.

What happened?
--------------

> "The change to the methodology is how we calculate the seven-day positivity rate for counties. In the past, similar to many states, we've added each day's positivity rate for seven days and divided by seven to obtain the week's positivity rate. Now we will add all of the positive tests for the week and divide by the total tests done that week to determine the week's positivity rate. This will help to minimize the effect that a high variability in the number of tests done each day can have on the week's overall positivity, especially for our smaller counties."

What went wrong?
----------------

### What is the target?

The first step to tracking a metric is defining the metric to track. This sounds obvious, but too often it is not. Metric design requires a lot of thought[^2] yet often glossed over even in important contexts such as medical research[^3]. In more complex problems, this will affect the research design and statistical methods we use to derive results, but in simpler cases like this, it can simply alter basic arithmetic.

So, the problem here starts with the very definition of what we are trying to track:

> average proportion of positive test results over the past seven days

Now, that seems pretty specific. An average of a proportion with a clear numerator and denominator over a defined time horizon. Easy, right? Not so fast. There's more nuance than meets the eye in how we calculate *averages* and what technically "happened" in the *last seven days*.

### Average over what?

At some point in elementary school, we were probably all taught that you calculate an average by adding up a bunch of numbers and dividing the total by the number of numbers we started with. That's not *wrong*, but it's actually more of a special case than a general rule.

Later on, we might have learned about the *weighted average* as a separate concept. There, instead of `sum(x) / count(x)`, we might have learned another formula like `sum( x * weight(x) ) / sum(weight(x))`. Of course, this isn't so much an extension as an abstraction (where normal arithmetic averages are recreated when the weight is set to 1 for all values of the number in question.)

So, ultimately, all averages are weighted averages whether we acknowledge it or not. That, in turn, suggests that whenever we define a metric as an *average*, the obligatory next question is "the average over what?"

What I suspect happened in the case from Indiana, is that they were taking unweighted arithmetic average of the test positivity proportions for the last seven days. That is, they were using the *average of days* instead of the *average over tests*.

To see the difference, suppose there are 50 tests on day 1 with 20% positive and 100 tests on day 2 with 10% positivity. Averaging over days gives up a value of 15% and over tests a value of 13.3%

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='o'>(</span><span class='nv'>avg_of_days</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>10</span><span class='o'>/</span><span class='m'>50</span> <span class='o'>+</span> <span class='m'>10</span><span class='o'>/</span><span class='m'>100</span><span class='o'>)</span> <span class='o'>/</span> <span class='m'>2</span><span class='o'>)</span>
<span class='o'>(</span><span class='nv'>avg_of_test</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>10</span> <span class='o'>+</span> <span class='m'>10</span><span class='o'>)</span> <span class='o'>/</span> <span class='o'>(</span><span class='m'>50</span> <span class='o'>+</span> <span class='m'>100</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0.15</span>
<span class='c'>#&gt; [1] 0.1333333</span>
</code></pre>

</div>

It's worth nothing that what's happening here is also mathematically equivallent to comparing the average of the proportions instead of the proportions of sums.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='o'>(</span><span class='nv'>avg_of_props</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>10</span><span class='o'>/</span><span class='m'>50</span> <span class='o'>+</span> <span class='m'>10</span><span class='o'>/</span><span class='m'>100</span><span class='o'>)</span> <span class='o'>/</span> <span class='m'>2</span><span class='o'>)</span>
<span class='o'>(</span><span class='nv'>props_of_sums</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>10</span> <span class='o'>+</span> <span class='m'>10</span><span class='o'>)</span> <span class='o'>/</span> <span class='o'>(</span><span class='m'>50</span> <span class='o'>+</span> <span class='m'>100</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0.15</span>
<span class='c'>#&gt; [1] 0.1333333</span>
</code></pre>

</div>

And, alternatively, none of this matters if the number of tests are the same on both days because then our weights are constant and we are back to the flat arithmetic average over observations (days).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='o'>(</span><span class='nv'>avg_of_props</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>20</span><span class='o'>/</span><span class='m'>100</span> <span class='o'>+</span> <span class='m'>10</span><span class='o'>/</span><span class='m'>100</span><span class='o'>)</span> <span class='o'>/</span> <span class='m'>2</span><span class='o'>)</span>
<span class='o'>(</span><span class='nv'>props_of_sums</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>20</span> <span class='o'>+</span> <span class='m'>10</span><span class='o'>)</span> <span class='o'>/</span> <span class='o'>(</span><span class='m'>100</span> <span class='o'>+</span> <span class='m'>100</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0.15</span>
<span class='c'>#&gt; [1] 0.15</span>
</code></pre>

</div>

### Does sample size cause problems?

So, we probably used the wrong type of average for the question at hand, but we probably could have gotten away with it if the sample sizes across days were not substantially different. We say how the sample size affects the weighting, but can it cause other statistical problems?

Suppose for a minute, that this is a binomial setup where each test has an equal probability of coming back positive (it does not). We can simulate a number of draws from binomial distributions of different sample sizes, compute the sample proportion of successes, and inspect the mean and variance. Below, we confirm what we would expect that small samples produce unbiased but high variance estimates[^4].

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='m'>0.5</span>
<span class='nv'>n</span> <span class='o'>&lt;-</span> <span class='m'>1000</span>
<span class='nv'>size</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>100</span>, <span class='m'>500</span><span class='o'>)</span>
<span class='nv'>samples</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='o'>(</span><span class='nv'>size</span>, FUN <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/stats/Binomial.html'>rbinom</a></span><span class='o'>(</span><span class='nv'>n</span>, <span class='nv'>x</span>, <span class='nv'>p</span><span class='o'>)</span> <span class='o'>/</span> <span class='nv'>x</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>vapply</a></span><span class='o'>(</span><span class='nv'>samples</span>, FUN <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/Round.html'>round</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>, <span class='m'>3</span><span class='o'>)</span>, FUN.VALUE <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>numeric</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>vapply</a></span><span class='o'>(</span><span class='nv'>samples</span>, FUN <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/Round.html'>round</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/sd.html'>sd</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>, <span class='m'>3</span><span class='o'>)</span>, FUN.VALUE <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>numeric</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0.489 0.500 0.499</span>
<span class='c'>#&gt; [1] 0.158 0.051 0.022</span>
</code></pre>

</div>

If staring at summary statistics is uninspiring, we can wrap our minds around the extend of the difference with a plot.

<div class="highlight">

<img src="figs/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />

</div>

So, days with smaller samples are most likely to take the most extreme values which could yank an average in one direction *or the other* ephemerally[^5]. This alone is a bad situation for a metric of interest; however, it can't be the full story. The initial article implies that the positivity rate was being *consistently overestimated*, that is, biased.

### Is sample size suggestive of a problem?

The vagaries of sample size may not independently be causing this problem, but they do raise a few broader issues. First, unweighted arithmetic averages make the most sense when we can make statistics' favorite assumptions of "independent and identically distributed". If, in fact, we see large variances in sample size, that would suggest this is not the case.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>avg_of_ratios</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>10</span><span class='o'>/</span><span class='m'>100</span> <span class='o'>+</span> <span class='m'>90</span><span class='o'>/</span><span class='m'>100</span><span class='o'>)</span> <span class='o'>/</span> <span class='m'>2</span>

<span class='nv'>ratio_of_sums</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>10</span> <span class='o'>+</span> <span class='m'>90</span><span class='o'>)</span> <span class='o'>/</span> <span class='o'>(</span><span class='m'>100</span> <span class='o'>+</span> <span class='m'>100</span><span class='o'>)</span>

<span class='nv'>avg_of_ratios</span> <span class='o'>==</span> <span class='nv'>ratio_of_sums</span>

<span class='nv'>avg_of_ratios_uneq</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>10</span><span class='o'>/</span><span class='m'>100</span> <span class='o'>+</span> <span class='m'>180</span> <span class='o'>/</span> <span class='m'>200</span><span class='o'>)</span> <span class='o'>/</span> <span class='m'>2</span>

<span class='nv'>ratio_of_sums_uneq</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>10</span> <span class='o'>+</span> <span class='m'>180</span><span class='o'>)</span> <span class='o'>/</span> <span class='o'>(</span><span class='m'>100</span> <span class='o'>+</span> <span class='m'>200</span><span class='o'>)</span>

<span class='nv'>avg_of_ratios_uneq</span> <span class='o'>==</span> <span class='nv'>ratio_of_sums_uneq</span>

<span class='nv'>weightavg_of_ratios_uneq</span> <span class='o'>&lt;-</span> <span class='o'>(</span><span class='m'>100</span><span class='o'>/</span><span class='m'>300</span><span class='o'>)</span><span class='o'>*</span><span class='o'>(</span><span class='m'>10</span><span class='o'>/</span><span class='m'>100</span><span class='o'>)</span> <span class='o'>+</span> <span class='o'>(</span><span class='m'>200</span><span class='o'>/</span><span class='m'>300</span><span class='o'>)</span><span class='o'>*</span><span class='o'>(</span><span class='m'>180</span><span class='o'>/</span><span class='m'>200</span><span class='o'>)</span>

<span class='nv'>ratio_of_sums_uneq</span> <span class='o'>==</span> <span class='nv'>weightavg_of_ratios_uneq</span>

<span class='c'>#&gt; [1] TRUE</span>
<span class='c'>#&gt; [1] FALSE</span>
<span class='c'>#&gt; [1] TRUE</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  numer <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span> <span class='m'>10</span>,  <span class='m'>90</span><span class='o'>)</span>,
  denom <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>100</span>, <span class='m'>100</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/base/with.html'>with</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>numer</span><span class='o'>)</span><span class='o'>/</span><span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>denom</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/with.html'>with</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>numer</span> <span class='o'>/</span> <span class='nv'>denom</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0.5</span>
<span class='c'>#&gt; [1] 0.5</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  numer <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span> <span class='m'>10</span>,  <span class='m'>90</span><span class='o'>*</span><span class='m'>2</span><span class='o'>)</span>,
  denom <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>100</span>, <span class='m'>100</span><span class='o'>*</span><span class='m'>2</span><span class='o'>)</span>
<span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/base/with.html'>with</a></span><span class='o'>(</span><span class='nv'>df2</span>, <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>numer</span><span class='o'>)</span><span class='o'>/</span><span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>denom</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/with.html'>with</a></span><span class='o'>(</span><span class='nv'>df2</span>, <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>numer</span> <span class='o'>/</span> <span class='nv'>denom</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0.6333333</span>
<span class='c'>#&gt; [1] 0.5</span>
</code></pre>

</div>

A sidenote on BI tools
----------------------

Independence assumptions
------------------------

defining estimand forces us to think about what are we even doing here?

average can be for denoising or smoothing

implicit assumption of iid if using for denoising; otherwise it's not just noise you're canceling out

other time, you may not care if you are just going to treat everything the same anyway

Sample Size
-----------

if data is from same distribution, this could increase variance but shouldn't effect mean

Recall that the standard deviation of sample proportion is $\sqrt(p*(1-p)/n)$

link to discussions of sample size and different types of averages

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/Random.html'>set.seed</a></span><span class='o'>(</span><span class='m'>123</span><span class='o'>)</span>

<span class='c'># define simulation parameters ----</span>
<span class='c'>## n: total draws from binomial distribution</span>
<span class='c'>## p: proportion of successes</span>
<span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='m'>0.5</span>
<span class='nv'>n</span> <span class='o'>&lt;-</span> <span class='m'>1000</span>

<span class='c'># sample from binomials of different size ----</span>
<span class='nv'>s010</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/Binomial.html'>rbinom</a></span><span class='o'>(</span><span class='nv'>n</span>,  <span class='m'>10</span>, <span class='nv'>p</span><span class='o'>)</span> <span class='o'>/</span>  <span class='m'>10</span>
<span class='nv'>s100</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/Binomial.html'>rbinom</a></span><span class='o'>(</span><span class='nv'>n</span>, <span class='m'>100</span>, <span class='nv'>p</span><span class='o'>)</span> <span class='o'>/</span> <span class='m'>100</span>
<span class='nv'>s500</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/Binomial.html'>rbinom</a></span><span class='o'>(</span><span class='nv'>n</span>, <span class='m'>500</span>, <span class='nv'>p</span><span class='o'>)</span> <span class='o'>/</span> <span class='m'>500</span>

<span class='c'># set results as dataframe for inspection ----</span>
<span class='nv'>df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>
  s <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>100</span>, <span class='m'>500</span><span class='o'>)</span>, each <span class='o'>=</span> <span class='nv'>n</span><span class='o'>)</span>,
  x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>s010</span>, <span class='nv'>s100</span>, <span class='nv'>s500</span><span class='o'>)</span>
<span class='o'>)</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='m'>0.5</span>
<span class='nv'>n</span> <span class='o'>&lt;-</span> <span class='m'>1000</span>
<span class='nv'>size</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>10</span>, <span class='m'>100</span>, <span class='m'>500</span><span class='o'>)</span>
<span class='nv'>samples</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='o'>(</span><span class='nv'>size</span>, FUN <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/stats/Binomial.html'>rbinom</a></span><span class='o'>(</span><span class='nv'>n</span>, <span class='nv'>x</span>, <span class='nv'>p</span><span class='o'>)</span> <span class='o'>/</span> <span class='nv'>x</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>vapply</a></span><span class='o'>(</span><span class='nv'>samples</span>, <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/Round.html'>round</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>, <span class='m'>3</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>numeric</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0.501 0.499 0.499</span>

<span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>vapply</a></span><span class='o'>(</span><span class='nv'>samples</span>, <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/Round.html'>round</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/sd.html'>sd</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>, <span class='m'>3</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>numeric</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'>#&gt; [1] 0.156 0.048 0.022</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/stats/aggregate.html'>aggregate</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>x</span>, by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>s</span><span class='o'>)</span>, FUN <span class='o'>=</span> <span class='nv'>mean</span><span class='o'>)</span>

<span class='c'>#&gt;   Group.1        x</span>
<span class='c'>#&gt; 1      10 0.497500</span>
<span class='c'>#&gt; 2     100 0.499520</span>
<span class='c'>#&gt; 3     500 0.500632</span>

<span class='nf'><a href='https://rdrr.io/r/stats/aggregate.html'>aggregate</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>x</span>, by <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nv'>df</span><span class='o'>$</span><span class='nv'>s</span><span class='o'>)</span>, FUN <span class='o'>=</span> <span class='nv'>sd</span><span class='o'>)</span>

<span class='c'>#&gt;   Group.1          x</span>
<span class='c'>#&gt; 1      10 0.15990409</span>
<span class='c'>#&gt; 2     100 0.05064518</span>
<span class='c'>#&gt; 3     500 0.02126021</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>

<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span>data <span class='o'>=</span> <span class='nv'>df</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>x</span>, col <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span><span class='o'>(</span><span class='nv'>s</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_density.html'>geom_density</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_abline.html'>geom_vline</a></span><span class='o'>(</span>xintercept <span class='o'>=</span> <span class='nv'>p</span>, col <span class='o'>=</span> <span class='s'>'darkgrey'</span>, linetype <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span><span class='o'>(</span>
    title <span class='o'>=</span> <span class='s'>"Sampling Distribution for p = 0.5"</span>,
    col <span class='o'>=</span> <span class='s'>"Sample Size"</span>
  <span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/scale_continuous.html'>scale_x_continuous</a></span><span class='o'>(</span>breaks <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>1</span>, <span class='m'>0.1</span><span class='o'>)</span>, labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/seq.html'>seq</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>1</span>, <span class='m'>0.1</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span><span class='o'>(</span>
    plot.title <span class='o'>=</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span><span class='o'>(</span>hjust <span class='o'>=</span> <span class='m'>0.5</span><span class='o'>)</span>,
    legend.position <span class='o'>=</span> <span class='s'>"bottom"</span>
  <span class='o'>)</span>

</code></pre>
<img src="figs/unnamed-chunk-12-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='m'>0.5</span>
<span class='nv'>n</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>100</span>, <span class='m'>2</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='m'>1000</span>, <span class='m'>7</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>est</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/lapply.html'>lapply</a></span><span class='o'>(</span><span class='nv'>n</span>, FUN <span class='o'>=</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/stats/Binomial.html'>rbinom</a></span><span class='o'>(</span><span class='m'>100</span>, size <span class='o'>=</span> <span class='nv'>x</span>, prob <span class='o'>=</span> <span class='nv'>p</span><span class='o'>)</span> <span class='o'>/</span> <span class='nv'>x</span><span class='o'>)</span>
</code></pre>

</div>

Bias
----

Conclusion
----------

then back to the data for why it matters.

but low sample days based on real world are probably also a sign of a different distribution (only very urgent cases get tested?)

[^1]: Similar to the long-form writing project I'm working in the open over [here](https://data-disasters.netlify.app/)

[^2]: One framework for approaching metric design is eloquently explored by Sean Taylor in this essay: <a href="https://medium.com/@seanjtaylor/designing-and-evaluating-metrics-5902ad6873bf" class="uri">https://medium.com/@seanjtaylor/designing-and-evaluating-metrics-5902ad6873bf</a>

[^3]: This new study cites many examples of poorly defined estimands (think metrics) from the BMJ: <a href="https://trialsjournal.biomedcentral.com/articles/10.1186/s13063-021-05644-4" class="uri">https://trialsjournal.biomedcentral.com/articles/10.1186/s13063-021-05644-4</a>

[^4]: We also know this with standard statistical results and formulas, but it's more fun to see it.

[^5]: As discussed at length in this Scientific American article: <a href="https://www.americanscientist.org/article/the-most-dangerous-equation" class="uri">https://www.americanscientist.org/article/the-most-dangerous-equation</a>

