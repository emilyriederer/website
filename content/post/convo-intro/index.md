---
output: hugodown::md_document
title: "Introducing the {convo} package"
subtitle: ""
summary: "Using controlled vocabularies to encode contracts between data producers and consumers"
authors: []
tags: [rstats, package, data]
categories: [rstats, package, data]
date: 2020-12-30
lastmod: 2020-12-30
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
projects: ["convo"]
rmd_hash: 699e28c34e777111

---

Back in September, I wrote about how [controlled vocabularies](/post/column-name-contracts) can help form contracts between data producers and consumers. In short, I argued that aligning on an ontology of stub names for use naming variables in a dataset can improve data documentation, validation, and wrangling with minimal overhead.

However, all of these benefits assume *absolute consistency* in the use of the controlled vocabulary. As soon as typos creep into variable names or fields violate the supposed data validation checks that their stubs promise, these vocabularies become more of a liability than an asset by luring data consumers into complacency.

I'm pleased to announced the experimental [`convo`](https://emilyriederer.github.io/convo/index.html) package to enable the definition and application of controlled vocabularies. In this post, I briefly describe the key features. Please see the package website for full documentation.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/emilyriederer/convo'>convo</a></span><span class='o'>)</span>
</code></pre>

</div>

Defining your vocabulary
------------------------

`convo` uses a YAML specification to define controlled vocabularies. Stubs are defined at each level which can optionally take on additional fields such as `desc` (a human-readable description), `valid` (which specifies `pointblank`-style data validation checks), and `rename` (which specifies how variable names should change under certain computations).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>filepath</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/system.file.html'>system.file</a></span><span class='o'>(</span><span class='s'>""</span>, <span class='s'>"ex-convo.yml"</span>, package <span class='o'>=</span> <span class='s'>"convo"</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='nv'>filepath</span><span class='o'>)</span>, sep <span class='o'>=</span> <span class='s'>"\n"</span><span class='o'>)</span>

<span class='c'>#&gt; level1:</span>
<span class='c'>#&gt;   ID:</span>
<span class='c'>#&gt;     desc: Unique identifier</span>
<span class='c'>#&gt;     valid:</span>
<span class='c'>#&gt;       - col_vals_not_null()</span>
<span class='c'>#&gt;       - col_is_numeric()</span>
<span class='c'>#&gt;       - col_vals_between(1000, 99999)</span>
<span class='c'>#&gt;   IND:</span>
<span class='c'>#&gt;     desc: Binary indicator</span>
<span class='c'>#&gt;     valid:</span>
<span class='c'>#&gt;       - col_is_numeric()</span>
<span class='c'>#&gt;       - col_vals_in_set(c(0,1))</span>
<span class='c'>#&gt;     rename:</span>
<span class='c'>#&gt;       - when: SUM</span>
<span class='c'>#&gt;         then: 'N'</span>
<span class='c'>#&gt;       - when: AVG</span>
<span class='c'>#&gt;         then: P</span>
<span class='c'>#&gt;   AMT:</span>
<span class='c'>#&gt;     desc: Non-negative, summable quantity</span>
<span class='c'>#&gt;     valid:</span>
<span class='c'>#&gt;       - col_is_numeric()</span>
<span class='c'>#&gt;       - col_vals_gte(0)</span>
<span class='c'>#&gt;   VAL:</span>
<span class='c'>#&gt;     desc: Value</span>
<span class='c'>#&gt;     valid:</span>
<span class='c'>#&gt;       - col_is_numeric()</span>
<span class='c'>#&gt;     rename:</span>
<span class='c'>#&gt;       - when: AVG</span>
<span class='c'>#&gt;         then: VALAV</span>
<span class='c'>#&gt;   CAT:</span>
<span class='c'>#&gt;     desc: Category</span>
<span class='c'>#&gt;     valid:</span>
<span class='c'>#&gt;       - col_is_character()</span>
<span class='c'>#&gt;   CD:</span>
<span class='c'>#&gt;     desc: System-generated code</span>
<span class='c'>#&gt;     valid:</span>
<span class='c'>#&gt;       - col_is_character()</span>
<span class='c'>#&gt;   DT:</span>
<span class='c'>#&gt;     desc: Calendar date in YYYY-MM-DD format</span>
<span class='c'>#&gt;     valid:</span>
<span class='c'>#&gt;       - col_is_date()</span>
<span class='c'>#&gt; level2:</span>
<span class='c'>#&gt;   A:</span>
<span class='c'>#&gt;     desc: Type A</span>
<span class='c'>#&gt;   C:</span>
<span class='c'>#&gt;     desc: Type C</span>
<span class='c'>#&gt;   D:</span>
<span class='c'>#&gt;     desc: Type D</span>
<span class='c'>#&gt; level3:</span>
<span class='c'>#&gt;   "\\d{4}": []</span>
</code></pre>

</div>

We can read this into R and retrieve a brief summary. Note that in this case the third-level stub allows for a regular expression to be used.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>convo</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/convo/man/read_convo.html'>read_convo</a></span><span class='o'>(</span><span class='nv'>filepath</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/print.html'>print</a></span><span class='o'>(</span><span class='nv'>convo</span><span class='o'>)</span>

<span class='c'>#&gt; Level 1</span>
<span class='c'>#&gt; - ID</span>
<span class='c'>#&gt; - IND</span>
<span class='c'>#&gt; - AMT</span>
<span class='c'>#&gt; - VAL</span>
<span class='c'>#&gt; - CAT</span>
<span class='c'>#&gt; - CD</span>
<span class='c'>#&gt; - DT</span>
<span class='c'>#&gt; Level 2</span>
<span class='c'>#&gt; - A</span>
<span class='c'>#&gt; - C</span>
<span class='c'>#&gt; - D</span>
<span class='c'>#&gt; Level 3</span>
<span class='c'>#&gt; - \d{4}</span>
</code></pre>

</div>

Alternatively, you may define a `convo` as a simple R list object (as shown when `bad_convo` is defined in the following two examples.)

Assessing vocabulary quality
----------------------------

Good features of a vocabulary stubs include *monosemy* (having only one meaning) and *unique* (being the only thing to mean that thing). Functions [`pivot_convo()`](https://rdrr.io/pkg/convo/man/pivot_convo.html) and [`cluster_convo()`](https://rdrr.io/pkg/convo/man/cluster_convo.html) help us spot deviations from these two properties. To illustrate these functions, I'll use a different `convo` than above since that one exhibits both monosemy and uniqueness already.

[`pivot_convo()`](https://rdrr.io/pkg/convo/man/pivot_convo.html) allows us to obtain all of the level indices at which each stub appears. When the `repeats_only` argument is set to the default value `TRUE`, this function only returns stubs that exist at multiple levels, thus violating monsemy. For example, this function could help us realize that we had used the stub "CAT" to refer both to a categorical variable and an animal.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>bad_convo</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"IND"</span>, <span class='s'>"AMT"</span>, <span class='s'>"CAT"</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"DOG"</span>, <span class='s'>"CAT"</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/pkg/convo/man/pivot_convo.html'>pivot_convo</a></span><span class='o'>(</span><span class='nv'>bad_convo</span><span class='o'>)</span>

<span class='c'>#&gt; $CAT</span>
<span class='c'>#&gt; [1] 1 2</span>
</code></pre>

</div>

Similarly, [`cluster_convo()`](https://rdrr.io/pkg/convo/man/cluster_convo.html) attempts to catch errors in uniqueness by clustering stubs based on string similarity. This can highlight similar but distinct stubs, which might arise when a common word or concept is abbreviated in different ways. In the following example, "ACCOUNT", "ACCT", and "ACCNT" are closely clustered in the second level, which might help us realize that all three are intended to represent a customer's account.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>bad_convo</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"IND"</span>, <span class='s'>"IS"</span>, <span class='s'>"AMT"</span>, <span class='s'>"AMOUNT"</span>, <span class='s'>"CAT"</span>, <span class='s'>"CD"</span><span class='o'>)</span>,
              <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"ACCOUNT"</span>, <span class='s'>"ACCT"</span>, <span class='s'>"ACCNT"</span>, <span class='s'>"PROSPECT"</span>, <span class='s'>"CUSTOMER"</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>clusts</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/convo/man/cluster_convo.html'>cluster_convo</a></span><span class='o'>(</span><span class='nv'>bad_convo</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/graphics/plot.default.html'>plot</a></span><span class='o'>(</span><span class='nv'>clusts</span><span class='o'>[[</span><span class='m'>2</span><span class='o'>]</span><span class='o'>]</span><span class='o'>)</span>

</code></pre>
<img src="figs/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />

</div>

Evaluating variable names
-------------------------

Having defined a `convo`, we can next use it to evaluate variable names. The [`evaluate_convo()`](https://rdrr.io/pkg/convo/man/evaluate_convo.html) function accepts a `convo` object and a set of names in a vector. It returns any variable names that violate the controlled vocabulary, listed at the specific level in which the violation occurs.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>col_names</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"ID_A"</span>, <span class='s'>"IND_A"</span>, <span class='s'>"XYZ_D"</span>, <span class='s'>"AMT_B"</span>, <span class='s'>"AMT_Q"</span>, <span class='s'>"ID_A_1234"</span>, <span class='s'>"ID_A_12"</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/pkg/convo/man/evaluate_convo.html'>evaluate_convo</a></span><span class='o'>(</span><span class='nv'>convo</span>, <span class='nv'>col_names</span>, sep <span class='o'>=</span> <span class='s'>"_"</span><span class='o'>)</span>

<span class='c'>#&gt; Level 1</span>
<span class='c'>#&gt; - XYZ_D</span>
<span class='c'>#&gt; Level 2</span>
<span class='c'>#&gt; - AMT_B</span>
<span class='c'>#&gt; - AMT_Q</span>
<span class='c'>#&gt; Level 3</span>
<span class='c'>#&gt; - ID_A_12</span>
</code></pre>

</div>

If a large number of violations occur, it might be more useful to directly retrieve all of the stubs existing in variable names that are not part of the `convo`. To do this, we can use set operators available in the [`compare_convo()`](https://rdrr.io/pkg/convo/man/compare_convo.html) function to examing the unions, intersections, and set differences between our controlled vocabulary and our variable names. Doing so might inspire new candidate stubs that ought to be included in our controlled vocabulary.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>convo_colnames</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/convo/man/parse_stubs.html'>parse_stubs</a></span><span class='o'>(</span><span class='nv'>col_names</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/pkg/convo/man/compare_convo.html'>compare_convo</a></span><span class='o'>(</span><span class='nv'>convo_colnames</span>, <span class='nv'>convo</span>, fx <span class='o'>=</span> <span class='s'>"setdiff"</span><span class='o'>)</span>

<span class='c'>#&gt; Level 1</span>
<span class='c'>#&gt; - XYZ</span>
<span class='c'>#&gt; Level 2</span>
<span class='c'>#&gt; - B</span>
<span class='c'>#&gt; - Q</span>
<span class='c'>#&gt; Level 3</span>
<span class='c'>#&gt; - 12</span>
</code></pre>

</div>

If desired, newly uncovered stubs can be added to the `convo` object in R with the [`add_convo_stub()`](https://rdrr.io/pkg/convo/man/add_convo_stub.html) function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>convo2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/convo/man/add_convo_stub.html'>add_convo_stub</a></span><span class='o'>(</span><span class='nv'>convo</span>, level <span class='o'>=</span> <span class='m'>2</span>, stub <span class='o'>=</span> <span class='s'>"B"</span>, desc <span class='o'>=</span> <span class='s'>"Type B"</span><span class='o'>)</span>
<span class='nv'>convo2</span> 

<span class='c'>#&gt; Level 1</span>
<span class='c'>#&gt; - ID</span>
<span class='c'>#&gt; - IND</span>
<span class='c'>#&gt; - AMT</span>
<span class='c'>#&gt; - VAL</span>
<span class='c'>#&gt; - CAT</span>
<span class='c'>#&gt; - CD</span>
<span class='c'>#&gt; - DT</span>
<span class='c'>#&gt; Level 2</span>
<span class='c'>#&gt; - A</span>
<span class='c'>#&gt; - C</span>
<span class='c'>#&gt; - D</span>
<span class='c'>#&gt; - B</span>
<span class='c'>#&gt; Level 3</span>
<span class='c'>#&gt; - \d{4}</span>
</code></pre>

</div>

Currently, there is not support for editing the YAML specification via R function. New stubs would need to be added manually. However, a completely new YAML file can be created with the [`write_convo()`](https://rdrr.io/pkg/convo/man/write_convo.html) function. This is particularly useful if you are creating a controlled vocabulary for the first time based on an existing set of variables names. First, you may parse them with [`parse_stubs()`](https://rdrr.io/pkg/convo/man/parse_stubs.html) to create a minimal controlled vocabulary (stubs without descriptions, validation checks, etc.) and then you may write this to a draft YAML file for further customization.

Validating data fields fields
-----------------------------

The validation checks specified with `pointblank` verbs in your YAML file can be used to create either a `pointblank` agent or a `pointblank` [YAML file](https://rich-iannone.github.io/pointblank/reference/yaml_read_agent.html) which can be used to consistently apply all of the promised data checks.

The `pointblank` YAML file may be created with the [`write_pb()`](https://rdrr.io/pkg/convo/man/write_pb.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/pkg/convo/man/write_pb.html'>write_pb</a></span><span class='o'>(</span><span class='nv'>convo</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"IND_A"</span>, <span class='s'>"AMT_B"</span><span class='o'>)</span>, filename <span class='o'>=</span> <span class='s'>"convo-validation.yml"</span><span class='o'>)</span>
</code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/cat.html'>cat</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='s'>"convo-validation.yml"</span><span class='o'>)</span>, sep <span class='o'>=</span> <span class='s'>"\n"</span><span class='o'>)</span>

<span class='c'>#&gt; read_fn: ~setNames(as.data.frame(matrix(1, ncol = 2)), c("IND_A", "AMT_B"))</span>
<span class='c'>#&gt; tbl_name: .na.character</span>
<span class='c'>#&gt; label: '[2021-01-17|12:45:17]'</span>
<span class='c'>#&gt; locale: en</span>
<span class='c'>#&gt; steps:</span>
<span class='c'>#&gt; - col_is_numeric:</span>
<span class='c'>#&gt;     columns: vars(IND_A)</span>
<span class='c'>#&gt; - col_vals_in_set:</span>
<span class='c'>#&gt;     columns: vars(IND_A)</span>
<span class='c'>#&gt;     set:</span>
<span class='c'>#&gt;     - 0.0</span>
<span class='c'>#&gt;     - 1.0</span>
<span class='c'>#&gt; - col_is_numeric:</span>
<span class='c'>#&gt;     columns: vars(AMT_B)</span>
<span class='c'>#&gt; - col_vals_gte:</span>
<span class='c'>#&gt;     columns: vars(AMT_B)</span>
<span class='c'>#&gt;     value: 0.0</span>
</code></pre>

</div>

Alternatively, a validation agent can be created directly with [`create_pb_agent()`](https://rdrr.io/pkg/convo/man/create_pb_agent.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>data_to_validate</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>IND_A <span class='o'>=</span> <span class='m'>1</span>, IND_B <span class='o'>=</span> <span class='m'>5</span>, DT_B <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='s'>"2020-01-01"</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>agent</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/convo/man/create_pb_agent.html'>create_pb_agent</a></span><span class='o'>(</span><span class='nv'>convo</span>, <span class='nv'>data_to_validate</span><span class='o'>)</span>
<span class='nf'>pointblank</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/pointblank/man/interrogate.html'>interrogate</a></span><span class='o'>(</span><span class='nv'>agent</span><span class='o'>)</span>
</code></pre>

</div>

Document fiels and vocabularies
-------------------------------

`convo` also offers preliminary support for documentation.

Basic data dictionaries may be created with [`describe_names()`](https://rdrr.io/pkg/convo/man/describe_names.html) which attempts to create definitions for fields based on a user-provided glue string and YAML-specified stub definitions.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>vars</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"AMT_A_2019"</span>, <span class='s'>"IND_C_2020"</span><span class='o'>)</span>
<span class='nv'>desc_df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/convo/man/describe_names.html'>describe_names</a></span><span class='o'>(</span><span class='nv'>vars</span>, <span class='nv'>convo</span>, desc_str <span class='o'>=</span> <span class='s'>"{level1} of {level2} in given year"</span><span class='o'>)</span>
<span class='nf'>DT</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/DT/man/datatable.html'>datatable</a></span><span class='o'>(</span><span class='nv'>desc_df</span><span class='o'>)</span>
</code></pre>

</div>

![](data-docs.PNG)

Alternatively, the entire controlled vocabulary may be put into a dictionary.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>desc_df</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/convo/man/describe_convo.html'>describe_convo</a></span><span class='o'>(</span><span class='nv'>convo</span>, include_valid <span class='o'>=</span> <span class='kc'>TRUE</span>, for_DT <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
<span class='nf'>DT</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/pkg/DT/man/datatable.html'>datatable</a></span><span class='o'>(</span><span class='nv'>desc_df</span>, escape <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span>
</code></pre>

</div>

![](convo-docs.PNG)

(The tables actually look much nicer when displayed with the full power of `DT`, which also allows for interactive filtering and sorting. Unfortunately, the Javascript behind DT causes a weird conflict with my static site generator weird interactions with my blog theme, so I just show screenshots here.)

Open issues
-----------

`convo` is still very experimental and there are many open questions. Currently, I'm debating many aspects of `convo` specification including:

-   What other formats should be allowed for defining a controlled vocabulary? Should there be a spreadsheet/CSV-based format? More support for constructing the object in R directly?
-   Currently, the separators between levels are specified in the function calls.
    -   Should this be part of the `convo` object instead?
    -   Should there be support for varying selectors at different levels (e.g. this would generalize better to using `convo` to validate file names with [`/`](https://rdrr.io/r/base/Arithmetic.html) delimiting directories and subdirectories and `_` or [`-`](https://rdrr.io/r/base/Arithmetic.html) used in parts of file names)
-   `convo` assumes prefix-based schemes with names start and "grow" from the beginning. Should suffix-based scheme be supported?
    -   One on hand, this provides significantly more flexibility
    -   On the other hand, I do strongly believe there are advantages to prefixed-based names (e.g. autocomplete, related concepts clustering when sorted) and any additional flexibility will make the initial specification increasingly gnarly for users
-   Should specification allow truly hierarchical naming structures where allowed stubs at level `n+1` vary by the stub at level `n`?
-   Should it be possible to mark some levels are required? Currently, no levels may be "skipped" but if five levels are specified, the software permits derived names of lengths fewer or greater than 5 (so long as any existing levels 1-5 follow the format)
-   Would it be useful to be able to programmatically edit the YAML file specification within R? What is the use case for this?
-   Currently, the `describe` function family is rather primitive. I hope to make this more aesthetic or integrate more deeply with `pointblank`

If you are interested, please take the package for a spin and do not hesitate to get in touch about these issues or any other ideas you have! Seeing more use cases beyond my own helps me understand which of these ideas add value versus unneccesary bloat and confusion.

