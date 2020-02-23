# RePEc scraper

## What is this?

[RePEc IDEAS](https://ideas.repec.org/) is one of the largest bibliographic databases for economics research. The database can be searched for free, and it's possible to export individual references, but there is no way to batch export references for a large number of search results (as you could in, say, Ovid or Web of Science). This makes it impractical to use in systematic reviews (for example), where you might need to download hundreds or thousands of references.

This is an R script that searches RePEc, downloads each result in RIS format (supported by most reference managers, e.g. EndNote, Zotero and Mendeley), and saves them as a single RIS file.

## How do I use it?

Briefly:

1. Clone this repo, or download the `scrape.R` file.
2. Edit the variables at the top of the file according to the search you want to make. (See the comments for more details.)
3. Run the entire file (or "source" it in RStudio).
4. An RIS file will appear in the working directory.

This script was written to facilitate [a specific systematic review](https://www.crd.york.ac.uk/prospero/display_record.php?RecordID=168379), and a more streamlined user experience than this wasn't needed at the time. There is a [work-in-progress PR](https://github.com/igelstorm/repec-scraper/pull/1) to turn this into an R package that will be significantly nicer to use. If you'd like to use this tool, and are willing to wait while I finish this, feel free to comment on the PR to let me know, and I might be able to hurry it up.
