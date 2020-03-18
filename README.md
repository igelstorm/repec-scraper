# RePEc scraper

## What is this?

This is an R package that can be used to automate searching the [RePEc IDEAS](https://ideas.repec.org/) database, and saving the search results as an RIS file (supported by most reference managers, e.g. EndNote, Zotero and Mendeley).

[RePEc IDEAS](https://ideas.repec.org/) is one of the largest bibliographic databases for economics research. The database can be searched for free, and it's possible to export individual references, but there is no way to batch export references for a large number of search results (as you could in, say, Ovid or Web of Science). This makes it impractical to use in systematic reviews (for example), where you might need to download hundreds or thousands of references.

Under the hood, this package uses the [rvest](https://rvest.tidyverse.org/) package to search the RePEc IDEAS website, visit the pages for each result, and save the references. As a consequence, it's very reliant on this website continuing to work in roughly the same way -- if it changes, it's to be expected that this code will break in some way. If this happens, feel free to [open an issue](https://github.com/igelstorm/repecscraper/issues). You're also more than welcome to clone the package, make any changes you need, and submit a pull request.

## How do I use it?

Install the package:

```r
install.packages("devtools")
devtools::install_github("igelstorm/repecscraper")
```

Use `repec_search` to perform a search:

```r
library(repecscraper)

results <- repec_search(
  query = 'recession and "mental health"',
  publication_type = "articles",
  search_in = "abstract"
)
```

Use `get_references` to download the RIS reference data for each result (this might take a while):

```r
results <- get_references(results)
```

Then use `write_references` to save them all as a single RIS file:

```r
write_references(results, "export.ris")
```

See the documentation (`?repec_search`, `?get_references`, `write_references`) for more details on how to use each function.

If you are so inclined, these functions are also very amenable to combining with [the pipe operator](https://magrittr.tidyverse.org/):

```r
library(repecscraper)
library(magrittr)

repec_search(query = 'recession and "mental health"') %>%
  get_references() %>%
  write_references("export.ris")
```

However, it's probably often a good idea to perform each step separately, and store the intermediate results, since each step can take a while, and errors or unexpected results are possible.
