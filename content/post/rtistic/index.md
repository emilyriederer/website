---
output: hugodown::md_document
title: 'Rtistic: A package-by-numbers repo'
subtitle: ""
summary: "A walkthrough of a GitHub template for making your own RMarkdown and ggplot2 theme package"
authors: []
tags: [rstats, pkgdev]
categories: []
date: 2019-05-25
lastmod: 2020-05-25
featured: false
draft: false

aliases:
  - post/rtistic-a-package-by-numbers-repo/

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "{Rtistic} project logo"
  focal_point: ""
  preview_only: true

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: ["rtistic"]
rmd_hash: ff76495d7d4df01d

---

Last winter, I attended a holiday party at a "paint-and-sip" venue. For those unfamiliar, "paint-and-sip" is a semi-trendy cottage industry offering evenings of music, wine, and a guided painting activity. For example, my group painted sasquatch on a snowy winter's eve:

![A very bad painting of a sasquatch in a forest](sasquatch.jpg)

As often happens, this completely unrelated thing set me thinking about R. What made painting fun when we lacked the talent and experience to excel, when it almost surely wouldn't turn out very well, and when "failure" would be very visibly and undeniably on display? Many of these same dimensions (novelty, risk, and visibility) often intimidate new coders, yet somehow they were core to the paint-and-sip business model.

(Admittedly, the "sipping" part may be a major confounder here, but this isn't a post on causal inference!)

Of course, this was nothing more than a tongue-in-cheek thought experiment, but it did bring a few observations to the front of my mind.

-   **The evening was highly structured**. It would be miserable (at least, for me) to be given any sort of picture and to simply be told to paint it.[^1]. Instead, the instructor told us and showed us step-by-step which order to tackle the painting in.
-   **The objective wasn't too serious**. Complete and utter failure was low stakes. No balls would be dropped. No important meetings would have to be postponed. No deadlines would be missed. There was no dire consequence of trying, and possibly failing, to paint a sasquatch.
-   **The ability to succeed wasn't correlated with anything important**. Hopefully, no one is going to measure their self-worth by sasquatch painting. In contrast, sometimes people unfortunately seem to associate their current technical abilities with a more foundational measure or worth or intelligence. This dramatically increases the cost of "failure" and dissuades exploration.
-   **The playing field was mostly level**. As far as I know, there are no experts in acrylic sasquatch painting.

It did pique my curiosity if these principles could help introduce concepts like GitHub or package development in a friendlier and more engaging way. Over the next few months, life carried on and took me in a variety of directions, including to the Chicago R unconf where I marvelled at the passion and productivity of teams coming together for a two day hackathon. Somewhere in there, a project idea began to form.

Introducing `Rtistic`
---------------------

Now that you've indulged my musings, let me introduce my [`Rtistic`](https://github.com/emilyriederer/Rtistic) repo on GitHub.

![Rtistic hex logo](featured.png)

Structurally, `Rtistic` is a package in the sense that you could install it with [`devtools::install_github()`](https://rdrr.io/pkg/devtools/man/remote-reexports.html). However, it is not an R package in the sense that you would be sorely disappointed if you did that. `Rtistic` is incomplete, by intent, and always will be. It is a skeleton of an R package and intended to be used as a "hackathon-in-a-box" or an "R package cookbook". Small groups at a meetup, office, or classroom can come together and collectively build out a package containing palettes and themes for `ggplot2` and RMarkdown. Much like the paint-and-sip, it strives to be highly structured and low stakes.

> **Caveat lector!:** `Rtistic` continues to evolve. For example, since first writing the below, I have added support for `xaringan`, utilized the new [GitHub template repository](https://github.blog/2019-06-06-generate-new-repositories-with-repository-templates/) functionality, and further standardized file names. The description below remains accurate *in spirit*, but the repo `README` is the best resource for the most up-to-date information for actual use.

### Structure

Much of the boilerplate code already exists, so partipants are less likely to get caught up on some cryptic error message. Off-the-shelf, the project's file structure looks similar to what's shown below (additional files may be added after I post this). Files prefixed with `my-` are open to edits by each team.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>-- DESCRIPTION
-- footer-helpers
   |__generate-footer-logo.R
   |__my-footer-template.html
   |__my-logo.png
-- inst
   |__rmarkdown
      |__resources
         |__my-footer.html
         |__my-styles.css
-- LICENSE.md
-- man
   |__figures
      |__logo.png
   |__my_html_format.Rd
   |__my_theme.Rd
   |__scale_custom.Rd
   |__test_pal.Rd
-- NAMESPACE
-- R
   |__my-gg-palette.R
   |__my-gg-theme.R
   |__my-html-format.R
   |__palette-infrastructure.R
-- README.md
-- Rtistic.Rproj
-- scratchpad
   |__gg-theme-demo.Rmd
   |__rmd-theme-demo.Rmd
-- vignettes
   |__my-gg-theme-vignette.Rmd
</code></pre>

</div>

### Whimsical...

With this much structure, participants can focus on the fun task of picking colors, fonts, and other theme components. Truly, a team contribution could be as minimal as defining four palettes in a file similar to the provided [`my-gg-palette.R` file](https://github.com/emilyriederer/Rtistic/blob/master/R/my-gg-palette.R):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>test_pal</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span>(<span class='s'>"green"</span>, <span class='s'>"yellow"</span>, <span class='s'>"orange"</span>, <span class='s'>"red"</span>) <span class='c'># discrete colors</span>
<span class='k'>test_pal_op</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span>(<span class='s'>"green"</span>, <span class='s'>"grey50"</span>, <span class='s'>"red"</span>)        <span class='c'># discrete colors mapping to good/neutral/bad</span>
<span class='k'>test_pal_cont</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span>(<span class='s'>"green"</span>, <span class='s'>"yellow"</span>)             <span class='c'># endpoints for a continous scale</span>
<span class='k'>test_pal_div</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span>(<span class='s'>"green"</span>, <span class='s'>"yellow"</span>, <span class='s'>"red"</span>)       <span class='c'># reference points for diverging scale</span></code></pre>

</div>

<details>

<summary> Full example file below the fold </summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'>#&gt; #' Test palette</span>
<span class='c'>#&gt; #'</span>
<span class='c'>#&gt; #' This is a test palette inspired by stop-light colors</span>
<span class='c'>#&gt; #'</span>
<span class='c'>#&gt; #' @references https://en.wikipedia.org/wiki/Traffic_light</span>
<span class='c'>#&gt; #' @name test_pal</span>
<span class='c'>#&gt; NULL</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; #' @name test_pal</span>
<span class='c'>#&gt; #' @export</span>
<span class='c'>#&gt; # Define disrete palette</span>
<span class='c'>#&gt; test_pal &lt;- c(</span>
<span class='c'>#&gt;   "#00A850", # green</span>
<span class='c'>#&gt;   "#FEEF01", # yellow</span>
<span class='c'>#&gt;   "#F58222", # orange</span>
<span class='c'>#&gt;   "#E13C29"  # red</span>
<span class='c'>#&gt; )</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; #' @name test_pal</span>
<span class='c'>#&gt; #' @export</span>
<span class='c'>#&gt; # Define opinionated discrete palette (good, neutral, bad)</span>
<span class='c'>#&gt; test_pal_op &lt;- c(test_pal[1], "grey50", test_pal[4])</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; #' @name test_pal</span>
<span class='c'>#&gt; #' @export</span>
<span class='c'>#&gt; # Define two colors for endpoints of continuous palette</span>
<span class='c'>#&gt; test_pal_cont &lt;- c(test_pal[1], test_pal[2])</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; #' @name test_pal</span>
<span class='c'>#&gt; #' @export</span>
<span class='c'>#&gt; # Define three colors for endpoints of diverging continuous pallete (high, middle, low)</span>
<span class='c'>#&gt; test_pal_div  &lt;- c(test_pal[1], test_pal[2], test_pal[4])</span></code></pre>

</div>

</details>

These palettes can then be used in a number of functions (thanks to the [`R/palette-infrastructure.R` file](https://github.com/emilyriederer/Rtistic/blob/master/R/palette-infrastructure.R)):

-   `scale_(color/colour/fill)_discrete_rtistic(palette = "test")`: Discrete palette with optional `extend` parameter to interpolate more values
-   `scale_(color/colour/fill)_opinionated_rtistic(palette = "test")`: Discrete palette to map to subjectively coded "good"/"bad"/"neutral" column[^2]
-   `scale_(color/colour/fill)_continuous_rtistic(palette = "test")`: Standard continous palette
-   `scale_(color/colour/fill)_diverging_rtistic(palette = "test")`: Diverging continuous palette

For example, that contribution leads to the following styles:

<div class="highlight">

<img src="figs/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

</div>

To "level up", participants can also use `roxygen2` syntax to add documentation about their theme and showcase it by editing the [`my-gg-theme-vignette.Rmd` template](https://github.com/emilyriederer/Rtistic/blob/master/scratchpad/gg-theme-demo.Rmd).

The `get_rtistic_palettes()` function scans the package's namespace for anything ending in `_pal` to help users learn about all the available options[^3]:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='k'>Rtistic</span>::<span class='nf'><a href='https://rdrr.io/pkg/Rtistic/man/get_rtistic_palettes.html'>get_rtistic_palettes</a></span>()
<span class='c'>#&gt; [1] "test_pal"</span></code></pre>

</div>

Adding actual `ggplot2` and RMarkdown themes is slightly more advanced, but the core design of participants altering templates still holds. Helper functions and instructions are also provided for some of the most esoteric tasks, like encoding a logo image as a URI to be included as a custom footer of a self-contained RMarkdown.

### ...but Valuable

Despite the low barriers to entry, my hope is that there is a lot to learn with `Rtistic`. For example, participants might get exposure to:

-   **Package structure**: By filling in the missing pieces of an existing package, teams will navigate through an R package file structure. Whether or not teams have package building aspirations, being able to read package source code is a useful skill.[^4] It's also a chance to practice good documentation with commenting and vignette writing.[^5]
-   **Collaboration on GitHub**: I'm convinced no one will ever understand git or GitHub by *reading*. The easiest way to learn forks, branches, and pull requests is to use them. `Rtistic` attempts to make this as easy as possible. Multiple teams should never need to edit the same file, so the likelihood of a big merge conflict problem is low.[^6]
-   **ggplot2 styling**: `ggplot2` is intuitive; however, compared to most of the `tidyverse`, it is intuitive in the sense of having a rich philosophical basis - not in the sense of "barely needed to read the docs because I can infer it all". Unfortunately, this difference can make it feel *unintuitive* to new users. Exposure to `ggplot2` theme options pays dividends in getting the most from the package.
-   **HTML / CSS**: R users more typically come from math and stats backgrounds (versus tech), knowledge of front-end web development can be limited. However, users of any of the `*down` packages[^7] can benefit a lot by having even a cursory understanding of these tools to take advantage of RMarkdown's customization capabilities.

If this seems like too much at once, the modular nature of the project makes it easy to strip down. If GitHub is out of scope, participants can locally change a small number of files and share them with an organizer for compilation. If `ggplot2` and HTML/CSS are too much to tackle at once, either the plot or RMarkdown theme pieces can be ignored.

### A Level Playing Field

For the more complex tasks of `ggplot2` and RMarkdown themes, the `scratchpad/` directory provides additional context. This directory contains two RMarkdown files with working examples of:

-   [**RMarkdown styling with CSS**](https://github.com/emilyriederer/Rtistic/blob/master/scratchpad/rmd-theme-demo.Rmd) for participants to edit and re-knit. This can help build intuition over how RMarkdown is translated into different HTML tags and how those respond to CSS
-   As many [**ggplot2 theme options**](https://github.com/emilyriederer/Rtistic/blob/master/scratchpad/gg-theme-demo.Rmd) as I could possibly fit in one plot with the goal of exposing participants to all of the possible options

The plot, in particular, is hopefully illuminating since the theme is in no way intended to be coherent. Each design choice uses wildly different fonts, colors, and alignments to make it very clear what line of code corresponds to each element:

<div class="highlight">

<img src="figs/unnamed-chunk-6-1.png" width="700px" style="display: block; margin: auto;" />

</div>

<details>

<summary> Code here </summary>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='http://ggplot2.tidyverse.org'>ggplot2</a></span>)
<span class='c'># sample data for plot ----</span>
<span class='k'>points</span> <span class='o'>&lt;-</span> 
  <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span>(
    x = <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span>(<span class='m'>1</span><span class='o'>:</span><span class='m'>10</span>,<span class='m'>3</span>), 
    y = <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span>(<span class='m'>1</span><span class='o'>:</span><span class='m'>10</span>,<span class='m'>3</span>), 
    z = <span class='nf'><a href='https://rdrr.io/r/base/sort.html'>sort</a></span>(<span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span>(<span class='k'>letters</span>[<span class='m'>1</span><span class='o'>:</span><span class='m'>2</span>], <span class='m'>15</span>)),
    w = <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span>(<span class='k'>letters</span>[<span class='m'>3</span><span class='o'>:</span><span class='m'>4</span>], <span class='m'>15</span>)
    )
<span class='c'># ggplot using many theme options ----</span>
<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span>(data = <span class='k'>points</span>, 
       mapping = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span>(x = <span class='k'>x</span>, y = <span class='k'>y</span>, col = <span class='nf'><a href='https://rdrr.io/r/base/factor.html'>factor</a></span>(<span class='k'>x</span>))) <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span>(size = <span class='m'>5</span>) <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/facet_grid.html'>facet_grid</a></span>(<span class='k'>w</span> <span class='o'>~</span> <span class='k'>z</span>, switch = <span class='s'>"y"</span>) <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/theme.html'>theme</a></span>(
    
    plot.background = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span>(fill = <span class='s'>"lightyellow"</span>),
    plot.title = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(size = <span class='m'>30</span>, hjust = <span class='m'>0.25</span>),
    plot.subtitle = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(size = <span class='m'>20</span>, hjust = <span class='m'>0.75</span>, color = <span class='s'>"mediumvioletred"</span>, family = <span class='s'>"serif"</span>),
    plot.caption = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(size = <span class='m'>10</span>, face = <span class='s'>"italic"</span>, angle = <span class='m'>25</span>),
    
    panel.background = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span>(fill = <span class='s'>'lightblue'</span>, colour = <span class='s'>'darkred'</span>, size = <span class='m'>4</span>),
    panel.border = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span>(fill = <span class='m'>NA</span>, color = <span class='s'>"green"</span>, size = <span class='m'>2</span>),
    panel.grid.major.x = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span>(color = <span class='s'>"purple"</span>, linetype = <span class='m'>2</span>),
    panel.grid.minor.x = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_line</a></span>(color = <span class='s'>"orange"</span>, linetype = <span class='m'>3</span>),
    panel.grid.minor.y = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_blank</a></span>(),
    
    axis.title.x = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(face = <span class='s'>"bold.italic"</span>, color = <span class='s'>"blue"</span>),
    axis.title.y = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(family = <span class='s'>"mono"</span>, face = <span class='s'>"bold"</span>, size = <span class='m'>20</span>, hjust = <span class='m'>0.25</span>),
    axis.text = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(face = <span class='s'>"italic"</span>, size = <span class='m'>15</span>),
    axis.text.x.bottom = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(angle = <span class='m'>180</span>), <span class='c'># note that axis.text options from above are inherited</span>
    
    strip.background = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span>(fill = <span class='s'>"magenta"</span>),
    strip.text.y = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(color = <span class='s'>"white"</span>),
    strip.placement = <span class='s'>"outside"</span>,
    
    legend.background = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span>(fill = <span class='s'>"orangered4"</span>), <span class='c'># generally will want to match w plot background</span>
    legend.key = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_rect</a></span>(fill = <span class='s'>"orange"</span>),
    legend.direction = <span class='s'>"horizontal"</span>,
    legend.position = <span class='s'>"bottom"</span>,
    legend.justification = <span class='s'>"left"</span>,
    legend.title = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(family = <span class='s'>"serif"</span>, color = <span class='s'>"white"</span>),
    legend.text = <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/element.html'>element_text</a></span>(family = <span class='s'>"mono"</span>, face = <span class='s'>"italic"</span>, color = <span class='s'>"limegreen"</span>)
    
  ) <span class='o'>+</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/labs.html'>labs</a></span>(title = <span class='s'>"test title"</span>,
       subtitle = <span class='s'>"test subtitle"</span>,
       x = <span class='s'>"my x axis"</span>,
       y = <span class='s'>"my y axis"</span>,
       caption = <span class='s'>"this is a caption"</span>,
       col = <span class='s'>"Renamed Legend"</span>) </code></pre>

</div>

</details>

### Take it for a Spin!

Complete information and more tactical step-by-step instructions for both organizers and participants can be found on the [`Rtistic` GitHub repo](https://github.com/emilyriederer/Rtistic). Please let me know if you check it out. I welcome any and all feedback!

[^1]: As in the ever popular "draw an owl" [meme](https://knowyourmeme.com/memes/how-to-draw-an-owl)

[^2]: I will admit that the `opinionated` scale likely is not useful or relevant in many cases. However, since corporate color palettes are one place I can imagine `Rtistic` being useful, I decided to include it since having a predefined mapping of "good" and "bad" colors (e.g. for profits and losses). I also think it's a nice discrete parallel to the more typical `diverging` scale for continuous-valued variables.

[^3]: This allows discoverability without having to maintain any centralized list of palettes since, for logistical reasons, `Rtistic` is designed to be completely modular.

[^4]: For example, I recently started using a package with very little documentation but an excellent test suite. Once I figured this out, I was able to use it a lot more efficiently by learning from the test examples.

[^5]: Another conviction of mine is that these skills should be used for most R projects -- not just packages. R's strong conventions and culture for documentation are one of its hallmarks.

[^6]: Obviously, merge conflicts are an important concept to understand, but as a day-one intro, "how this ideally works" is easier to grasp.

[^7]: Or Shiny, flexdashboard, etc.

