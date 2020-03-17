# RePEc scraper

## What is this?

[RePEc IDEAS](https://ideas.repec.org/) is one of the largest bibliographic databases for economics research. The database can be searched for free, and it's possible to export individual references, but there is no way to batch export references for a large number of search results (as you could in, say, Ovid or Web of Science). This makes it impractical to use in systematic reviews (for example), where you might need to download hundreds or thousands of references.

This is an R script that searches RePEc, downloads each result in RIS format (supported by most reference managers, e.g. EndNote, Zotero and Mendeley), and saves them as a single RIS file.

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

If you are so inclined, these functions are also very amenable to combining with [pipe operators](https://magrittr.tidyverse.org/). This code does the same thing as the examples above:

```r
library(repecscraper)
library(magrittr)

results <- repec_search(
  query = 'recession and "mental health"',
  publication_type = "articles",
  search_in = "abstract"
) %>%
  get_references() %>%
  write_references("export.ris")
```
