#!/usr/bin/env Rscript
# Word Count Statistics for Markdown Files in docs directory
# This script counts the total word count of all .md files in the docs directory

library(stringr)

# Function to count words in a file (excluding code blocks and YAML headers)
# include_code: if TRUE, count words in R code blocks without echo=FALSE
count_words_in_file <- function(file_path, include_code = FALSE) {
  # Read the file content
  content <- readLines(file_path, warn = FALSE, encoding = "UTF-8")

  # Remove YAML header (lines between ---)
  yaml_start <- which(content == "---")[1]
  if (!is.na(yaml_start)) {
    yaml_end <- which(content == "---")[2]
    if (!is.na(yaml_end)) {
      content <- content[-(yaml_start:yaml_end)]
    }
  }

  # Handle code blocks
  code_block_start <- grep("^```", content)
  code_content_to_count <- character(0)

  if (length(code_block_start) > 0 && length(code_block_start) %% 2 == 0) {
    remove_indices <- c()

    for (i in seq(1, length(code_block_start), by = 2)) {
      start_line <- code_block_start[i]
      end_line <- code_block_start[i+1]

      # Check if this is an R code block without echo=FALSE
      if (include_code) {
        # Check the code block header line
        header_line <- content[start_line]

        # Check if it's an R code block and doesn't have echo=FALSE
        # Support both ```r and ```{r} syntax
        if ((grepl("^```\\s*\\{\\s*r", header_line) || grepl("^```\\s*r\\s*$", header_line)) &&
            !grepl("echo\\s*=\\s*FALSE", header_line)) {
          # Extract code content (excluding the ``` lines)
          code_lines <- content[(start_line+1):(end_line-1)]
          code_content_to_count <- c(code_content_to_count, code_lines)
        }
      }

      # Mark this code block for removal
      remove_indices <- c(remove_indices, start_line:end_line)
    }

    # Remove all code blocks
    content <- content[-remove_indices]
  }

  # If including code, add the extracted code content
  if (include_code && length(code_content_to_count) > 0) {
    content <- c(content, code_content_to_count)
  }

  # Remove inline code (content between `)
  content <- gsub("`[^`]*`", "", content)

  # Remove HTML tags
  content <- gsub("<[^>]*>", "", content)

  # Remove markdown formatting (headers, bold, italic, links, images)
  content <- gsub("^#+", "", content)  # Remove headers
  content <- gsub("\\*\\*[^*]*\\*\\*", "", content)  # Remove bold
  content <- gsub("\\*[^*]*\\*", "", content)  # Remove italic
  content <- gsub("!?\\[[^\\]]*\\]\\([^)]*\\)", "", content)  # Remove links and images

  # Remove special characters but keep Chinese characters, letters, numbers, and spaces
  # Use a simpler approach for Chinese text - just remove punctuation and extra spaces
  content <- gsub("[[:punct:]]", "", content)
  content <- gsub("\\s+", " ", content)
  content <- trimws(content)

  # Count words: Chinese characters individually, English words as units
  # Use a simpler approach - count all non-space characters for Chinese,
  # but for segments that look like English words, count them as units

  # Split by whitespace
  segments <- unlist(strsplit(content, "\\s+"))
  segments <- segments[segments != ""]

  total_count <- 0
  for (segment in segments) {
    # If segment contains only English letters and numbers, count as one word
    if (grepl("^[A-Za-z0-9]+$", segment)) {
      total_count <- total_count + 1
    } else {
      # Otherwise, count each character individually (for Chinese text)
      total_count <- total_count + nchar(segment)
    }
  }

  return(total_count)
}

# Main function
main <- function() {
  # Parse command line arguments
  args <- commandArgs(trailingOnly = TRUE)
  include_code <- FALSE

  if ("--include-code" %in% args) {
    include_code <- TRUE
    cat("Word Count Statistics for Markdown Files in docs directory (including R code without echo=FALSE)\n")
  } else {
    cat("Word Count Statistics for Markdown Files in docs directory\n")
  }

  cat("==========================================================\n\n")

  # Get all .md files in docs directory
  md_files <- list.files("docs", pattern = "\\.md$", full.names = TRUE, recursive = TRUE)

  if (length(md_files) == 0) {
    cat("No .md files found in docs directory\n")
    return()
  }

  cat("Found", length(md_files), "markdown files:\n")

  # Initialize counters
  total_words <- 0
  file_stats <- data.frame(
    File = character(),
    Words = integer(),
    stringsAsFactors = FALSE
  )

  # Count words for each file
  for (file in md_files) {
    word_count <- count_words_in_file(file, include_code)
    total_words <- total_words + word_count

    file_name <- basename(file)
    file_stats <- rbind(file_stats, data.frame(File = file_name, Words = word_count))

    cat(sprintf("%-35s: %6d words\n", file_name, word_count))
  }

  cat("\n")
  cat("==========================================================\n")
  cat(sprintf("Total words across all files: %d words\n", total_words))
  cat("==========================================================\n\n")

  # Sort by word count (descending)
  file_stats <- file_stats[order(-file_stats$Words), ]

  cat("Files sorted by word count (descending):\n")
  for (i in 1:nrow(file_stats)) {
    cat(sprintf("%-35s: %6d words\n", file_stats$File[i], file_stats$Words[i]))
  }

  # Save results to CSV
  if (include_code) {
    output_file <- "docs_word_count_with_code.csv"
  } else {
    output_file <- "docs_word_count.csv"
  }
  write.csv(file_stats, output_file, row.names = FALSE)
  cat(sprintf("\nDetailed results saved to: %s\n", output_file))
}

# Run the script
if (sys.nframe() == 0) {
  main()
}