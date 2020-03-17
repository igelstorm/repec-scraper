library(repecscraper)

results <- repec_search(
  query = '("mental health"| depression| anxiety| well-being| wellbeing| "quality of life"| "life satisfaction"| "psychological distress") + (income*| "social security"| earning*| salar*| wage*| money| financ*| loan*| debt*| lottery| poverty| "cash transfer"| welfare) + (change*| alter*| shock*| w?n)',
  to_page = 0,
  publication_type = "articles",
  search_in = "abstract"
)
  
results <- get_references(results)

write_references(results, "export.ris")

print("Done.")

failures <- results[is.na(results$ris_data),]

if (length(failures$url) != 0) {
  paste(length(failures$url), "references couldn't be retrieved:") %>% print()
  print(failures)
}
