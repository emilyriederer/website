---
output: hugodown::md_document
title: "Launching the Data Disasters project"
subtitle: ""
summary: "From academic training to real world data analysis"
authors: []
tags: [data, rstats]
categories: [data, rstats]
date: 2021-08-06
lastmod: 2021-08-06
featured: false
draft: false

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "A [Simpson's Paradox](https://en.wikipedia.org/wiki/Simpson%27s_paradox)-esque data disaster"
  focal_point: ""
  preview_only: true

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
projects: []
rmd_hash: 41d5f67c84c0c0b2

---

Every summer, I'm always excited to think about the slew of fresh college graduates beginning their careers as data professionals. This influx of new talent and energy is always an interesting opportunity to reflect on the beginning of my own career and, more specifically, the experience of moving between data analysis as its taught as an academic discipline and data analysis in the real world.

As I mentioned in my [Toronto Data Workshop](https://www.youtube.com/watch?v=VP3BBZ7poc0) interview back in February, my personal academic background skewed towards the theoretical. I spent much more time in college proving theorems than working applied problems. Overall, I'm grateful for this background and think it gave me a much firmer foundation to keep learning on my own. I *don't* advocate theory being replace with application, which I suspect is also hard to teach with "toy" problems.

That being said, it always bothers me somewhat how much

## Data

Understanding data management and data wrangling is an undeniable prerequisite to analytics. You can be the most brilliant methodologist ever but achieve nonsensical results if you misunderstand what the data you are working with actually represents or manage to distort it in the wrangling process.

-   **Data Dalliances**: Misinterpreting or mis-uing data based on how it was collected or what it represents

> El Paso city and public health officials on Thursday admitted to a major blunder, saying that the more than 3,100 new cases reported a day earlier was incorrect.

> The number was the result of a two-day upload of cases in one day after the public health department went from imputing data manually to an automatic data upload that was intended to increase efficiency, Public Health Director Angela Mora said at news conference.

\- [El Paso Officials Admit Massive COVID-19 Spike of 3,100 New Cases Was Error](https://www.elpasotimes.com/story/news/health/2020/11/05/coronavirus-update-el-paso-covid-19-restrictions-shutdowns-curfew/6174493002/), El Paso Times

> While 238 deaths is the most reported in Illinois since the start of the pandemic, the IDPH noted in its release that some data was, "delayed from the weekends, including this past holiday weekend."

\- [Illinois sees biggest spike in reported COVID-19 deaths to date after holidays delay some data, officials say](https://wgntv.com/news/coronavirus/illinois-sees-biggest-spike-in-reported-covid-19-deaths-to-date-after-officials-say-holidays-delayed-some-data/), WGN9

> A man in his 30s with no underlying health conditions was offered a Covid vaccine after an NHS error mistakenly listed him as just 6.2cm in height. Liam Thorp was told he qualified for the jab because his measurements gave him a body mass index of 28,000.

\- [Covid: Man Offered Vaccine After Error Lists Him as 6.2cm Tall](https://data-disasters.netlify.app/references.html#ref-bbc_north_west_2021), BBC

-   **Computational Quandaries**: Letting computers do what you said and not what you meant

> The data error, which led to 15,841 positive tests being left off the official daily figures, means than 50,000 potentially infectious people may have been missed by contact tracers and not told to self-isolate.

\- [Covid: how Excel may have caused loss of 16,000 test results in England](https://www.theguardian.com/politics/2020/oct/05/how-excel-may-have-caused-loss-of-16000-covid-tests-in-england), The Guardian

## Analysis

With a solid foundation in data and tools,

-   **Egregious Aggregations**: Losing critical information when information is condensed

> The changes could result in real-world differences for Hoosiers, because the state uses a county's positivity rate as one of the numbers to determine which restrictions that county will face. Those restrictions determine how many people may gather, among other items.

> Some Hoosiers may see loosened restrictions because of the changes. While Box said the county-level impact will be mixed, she predicted some smaller counties will see a decline in positivity rate after the changes.

\- [How an error in the calculation of Indiana's positivity rate may affect you](https://www.indystar.com/story/news/health/2020/12/23/covid-indiana-positivity-rate-error-corrected-dec-30/4013741001/), Indianapolis Star

-   **Vexing Visualization**: Confusing ourselves or others with plotting choices

> \[W\]e find that the group who read the information on a logarithmic scale has a much lower level of comprehension of the graph: only 40.66% of them could respond correctly to a basic question about the graph (whether there were more deaths in one week or another), contrasted to 83.79% of respondents on the linear scale.

\- [The public do not understand logarithmic graphs used to portray COVID-19](https://blogs.lse.ac.uk/covid19/2020/05/19/the-public-doesnt-understand-logarithmic-graphs-often-used-to-portray-covid-19/), LSE

-   **Incredible Inferences**: Drawing incorrect conclusions for analytical results

{{&lt; tweet 1422910479140376576 &gt;}}

-   **Cavalier Causality**: Falling prey to spurious correlations masquerading as causality

\- [](https://journals.lww.com/jhypertension/Fulltext/2021/04000/Evaluating_sources_of_bias_in_observational.28.aspx),

-   **Mindless Modeling**: Failing to get the most value out of models by not tailoring the features, targets, and performance metrics

> "Some AIs were found to be picking up on the text font that certain hospitals used to label the scans. As a result, fonts from hospitals with more serious caseloads became predictors of covid risk"

\- ["Hundreds of AI tools have been used to catch COVID. None of them helped."](https://www.technologyreview.com/2021/07/30/1030329/machine-learning-ai-failed-covid-hospital-diagnosis-pandemic/), MIT Technology Review

-   **Alternative Algorithms**: Lacking an understanding of alternative methods which may be better suited for the problem at hand

> "Reported deaths vary by the day, particularly on weekends. To smooth out the volatility, Mr. Hassett said he had employed 'just a canned function in Excel, a cubic polynomial.'"

-   [No Virus Deaths by Mid-May? White House Economists Say They Didn't Forecast Early End to Fatalities](https://www.nytimes.com/2020/05/06/business/coronavirus-white-house-economists.html), New York Times

## Workflow

So you did a great analysis, does it matter? Embracing a good workflow in the "moment before" and "moment after" a data anaylsis is critical to get the most bang for your buck. This can cover everything from carefully deciding what questions are worth answering to begin with and then answering them in the most credible, sustainable way possible.

-   **Futile Findings**: Asking questions that aren't useful or communicating findings ineffectively
-   **Complexifying Code**: Making projects unwieldy or more difficult to understand than necessary
-   **Rejecting Reproducibility**: Working inefficiently instead of an efficient, reproducible, and sharable workflow with tools such as version control and environment management

Of course, we don't have as many examples of these data disasters from recent events. Why? Well, one reason is perhaps suggested in Annie Collins and Rohan Alexander's recent [preprint](https://arxiv.org/abs/2107.10724) which finds:

> For the pre-prints that are in our sample, we are unable to find markers of either open data or open code for 75 per cent of those on arXiv, 67 per cent of those on bioRxiv, 79 per cent of those on medRxiv, and 85 per cent of those on SocArXiv

