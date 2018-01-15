# pathfinder

The goal of pathfinder is to help track file dependencies in research projects created in RStudio. Perhaps other things later.

## Installation instructions:

``` r
devtools::install_github("brad-cannell/pathfinder", build_vignettes = TRUE)
```

# Overview:

Need to come up with a better method for notes/documentation/file dependencies for analysis projects. 

## What this isn't for:

* This isn't really intended to be useful for R package development (although, maybe it ultimately will be). It is intended for _research projects_

* General notes that are only intended for me to read (e.g., "left off at line 157" or "Think about using a tree model instead")

## What I've already tried:

* Using a text file is very convenient, but not very dynamic. It likes features like tables and charts. And, it is not ideal for sharing/collaborating. 

* Google docs has a lot of features and makes sharing/collaborating easy, but isn’t very convenient. I have to find it, open it (can't open directly in RStudio), and go back and forth between RStudio and Web browser. Additionally, they aren't dynamic in the sense that changes I make to R files and data aren't automatically pushed to the Google doc. They just don't feel like a very native solution.

* Github projects has some really nice features; however, it isn’t available offline. Is this a big deal? How often am I really doing work without an internet connection? Another issue is that many of the people I work with are not accustomed to, or comfortable with, using Github.

## Specifics:

* Automate the notes pages I currently make for research projects
* Add all files and data sets in an R project to a hierarchy
* Can manually add notes
* Maybe send out to Google Docs
* Scan r scripts for text (“read” and “write”)
* Add comments to the YAML header that will later be added to the report that this function generates
    - This doesn't work for R Notebooks. Preview doesn't knit.
    - If you use discussion element in YAML header, assume that others won't necessarily see.
* Markdown check boxes embedded in a tasks section of the report

## Packages that may be involved:

- RStudio API
- Pandoc
- Rmarkdown
- Knitter
- DiagrammR (see below)
- Plotty (see below)
- Shiny (see below)
- Github API (see below)

## Interactivity

Maybe it works using (partly) a network diagram where the root node is the project root, the other nodes are files (color coded by type, I.e., data manipulation or analysis or presentation) and the edges are data (files, but maybe other data too). 

Hovering over the nodes and edges shows ploty-style metadata.

Shiny app would be viewable offline, but still hide the code from the user and allow for arbitrary notes. But, it isn’t viewable on a GitHub repo. However, as long as it’s just metadata, I can probably link the the shiny app hosted on shiny apps.io from Github

Use Github API to reflect project issues

What do I do about automatically tracking changes to data if I run a makefile? 

For example, data frame x has 63 obs and 20 variables. I currently save that as a comment. Then, if I make a change I can see if data frame x still has 63 obs or not and if that's desirable or not.



