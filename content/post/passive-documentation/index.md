---
output: hugodown::md_document
# Documentation: https://sourcethemes.com/academic/docs/managing-content/

title: "Resource Round-Up: Latent and Lasting Documentation"
subtitle: ""
summary: "Readings and assorted ideas about creating and maintaining low-overhead documentation"
authors: []
tags: [resources, rstats]
categories: [resources, rstats]
date: 2020-07-03
lastmod: 2020-07-03
featured: false
draft: true

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder.
# Focal points: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight.
image:
  caption: "Photo by [Sharon McCutcheon](https://unsplash.com/@sharonmccutcheon?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText) on Unsplash"
  focal_point: ""
  preview_only: false

# Projects (optional).
#   Associate this post with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects = ["internal-project"]` references `content/project/deep-learning/index.md`.
#   Otherwise, set `projects = []`.
rmd_hash: 753eac90ee085a22

---

The importance of documentation is uncontroversial. For many data and analytical products, documentation is the user interface and key to promoting user success and future reuse. However, when project timelines get tight, too many data products are considered complete without appropriate documentation. Even when these resources initially exist, they too quickly grow stale as they are not maintained along with their projects.

Ideally, documentation should be latent (proactively captured from artifacts of the development and maintenance process) and lasting (easy to maintain). This can be accomplished by treating documentation more like code itself and incorporating principles of reuse and modularity.

Lately, I've encountered a number of related concepts which aim to address these issues. In this post, I will share a few good reads and key take-aways on how to craft documentation that is both latent and lasting.

Latent Documentation
--------------------

We create *latent* documentation simply by doing existing aspects of our work more conscientiously. Throughout the design, development, and evangelization of any data product, developers necessarily think about and communicate what a tool is intended to do and how it works. Latent documentation, then, can be harvested by more conscientiously saving the mental artifacts we created while building and growing a new product. This can include documenting our project requirements when planning, adhering to strict naming conventions when building, and answering questions in public forums while maintaining.

The following articles provide compelling examples of each of those strategies in more detail.

[**Data Dictionary: A How To and Best Practices**](https://medium.com/@leapingllamas/data-dictionary-a-how-to-and-best-practices-a09a685dcd61) by Carl Anderson

In this article, Carl Anderson explains that proactively capturing the intent and requirements for a new data product can easily lead to high quality documentation. In particular, he demonstrates how data dictionaries can be used as a way to collect requirements and seek consensus from customers before a data product is built.

Thinking of documentation as an active part of product discovery makes it an uncontroversial task to invest in and leads to a better outcome by ensuring user needs are truly being met. This also makes documentation a collaborative exercise; engaging users in the process may offload developer from bearing the task of documentation alone and may even lead to documentation written more in the voice and from the perspective of the ultimate consumer.

This concept applies broadly beyond data dictionaries. For example, before building a custom R package, one can imagine writing a vignette with a detailed explanation of the problem that the package intends to solve and a conceptual approach to doing so. Customers could review this document to make sure they are aligned before any development begins, and ultimately this document could ship with the final package as part of the "why" documentation (as we will discuss in the Etsy article below.)

[**Naming Things**](https://speakerdeck.com/jennybc/how-to-name-files) by Jenny Bryan

During the development process, documentation can also be achieved by conscientious naming of folders and files in one's project. Instead of having a lengthy `README` explaining what different files do and where to find them, defining a taxonomy of highly intentional naming standard makes the purpose of each file at least somewhat self-evident.

This approach makes projects more navigable to developers, maintainers, and users alike. Beyond reducing the burden of documentation, there are many additional benefits to conscientious naming conventions. To name a few, standardized naming eliminates mental overhead (you can *understand* instead of *remember* how files relate) and helps your code "play nice" with the auto-complete features in many modern IDEs.

While the linked presentation focuses on files within a single project, standardized naming taxonomies are a powerful structure for organizing many different products -- from naming variables in a data set to naming projects in a GitHub organization. The specific conventions imposed may vary, but the idea stays the same: define and document a taxonomy in one place and use the resulting "grammar" to flexibly describe each individual entity of that type (variable, file, folder, etc.)

[**Understanding the InnerSource Checklist**](http://innersourcecommons.org/checklist/)  
Silona Bonewald

I've previously praised this book about PayPal's innersource journey in my post on [reproducible research resources](post/resource-roundup-reproducible-research/). More specifically to this conversation, the book introduces *passive documentation* as an antidote to the burden of maintainership and user support for innersource developers. Passive documentation is the practice of pushing all user support to public and openly accessible forums (e.g. GitHub issues versus Slack DMs) so that future users can self-service from the conversations of past users with project maintainers (just as StackOverflow and GitHub issues are used in open source). This relationship can be formalized in many ways, such as labeling issues with a special tag (such as "faq") or asking users to instead as questions by editing a wiki and sending a PR to a markdown file.

Lasting Documentation
---------------------

*Lasting* documentation is documentation that requires minimal effort to maintain. Key strategies here are decoupling documentation of intent with specific implementation. Intent documentation is relatively stable over time and can help users learn about the process your product solves. Implementation documentation is more likely to change, but it can be further enhanced by being made dynamic and linked more directly to the core workflow. For example, this documentation can recycle material from unit tests or validation pipelines.

The following real-world examples demonstrate strategies for lasting documentation.

[**Etsy's Experiment with Immutable Documentation**](https://codeascraft.com/2018/10/10/etsys-experiment-with-immutable-documentation/)  
Paul-Jean Letourneau

This post from Etsy uses the example of API documentation to demonstrate that documentation can be largely broken into two categories: the *how* and the *why*. "How" documentation explains specific chunks of code whereas "why" documentation describes the motivations and intended effect of a process.

Conscious decoupling of these categories allows the "why" documents to exist stand-alone and require relatively little maintenance over time. Simultaneously, the "how" documents are more isolated and easily updated. The post goes on to demonstrate that leaner "how" documents have additional benefits. For example, it is easy to compare changes over time which are in themselves useful documentation.

[**`roxytest` R package**](https://cloud.r-project.org/web/packages/roxytest/index.html)  
Mikkel Meyer Anderson

`roxytest` allows R package developers to build more lasting function documentation by recycling unit test cases as user-facing usage examples. Tests are critical to the maintenance of any substantial project; they ensure computational correctness and stability over time. Tests also are run regularly when changes are made to a package and are often automated in a CI pipeline. Since they ensure the validity of the code, they are neccesarily in-sync and up-to-date with said code (or there are bigger problems to worry about!) In contrast, usage examples are often written during initial package development and pose a higher risk of going stale or being neglected during updates.

Despite their differences, both ultimately work by demonstrating that simple minimal-dependency function calls produce the expected results. `roxytest` exploits this shared aim by enabling developers to write unit tests within the main function documentation and then automatically reformatting these as required for human-readability in the documentation and for machine execution (across a variety of testing frameworks) as tests.

[**`pointblank` R package**](https://rich-iannone.github.io/pointblank/)  
Rich Iannone

`pointblank` is a promising new R package[^1] for data validation which offers a clever and automated approach to better data quality documentation. Key features include a flexible and friendly API for describing data validation checks, operation on local or remote data sets (e.g. in database or Spark), and workflows for either human-readable data quality reporting or pipeline automation.

These dual workflows are particularly relevant for documentation. Many data validation checks can be done as part of an automated pipeline to detect baseline quality issues (e.g. are there duplicate rows?); however, it is important that end-users understand what checks have been done in order to understand what additional validation is needed to ensure that the data is fit-for-purpose. Thus, automatically generating aesthetic and interactive reports on a data quality pipeline is an excellent compliment to other forms of data set documentation.

[^1]: Initially, it strikes me as the best answer in the R ecosystem to the highly successful [Great Expectations](https://docs.greatexpectations.io/en/latest/) project.

