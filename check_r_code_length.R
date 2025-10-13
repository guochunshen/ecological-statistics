#!/usr/bin/env Rscript

# 脚本用于检查Rmd文件中的R代码行长度
# 忽略echo=FALSE的代码块

library(stringr)

# 读取文件
file_path <- "02-probability_and_distribution.Rmd"
content <- readLines(file_path, encoding = "UTF-8")

# 查找所有R代码块
r_blocks <- list()
current_block <- NULL
in_r_block <- FALSE
block_start <- 0
block_name <- ""

for (i in seq_along(content)) {
  line <- content[i]

  # 检查是否是R代码块开始
  if (str_detect(line, "^```\\{r")) {
    in_r_block <- TRUE
    block_start <- i
    block_name <- line
    current_block <- c()
  }
  # 检查是否是R代码块结束
  else if (in_r_block && str_detect(line, "^```")) {
    in_r_block <- FALSE

    # 检查是否不是echo=FALSE的代码块
    if (!str_detect(block_name, "echo=FALSE")) {
      r_blocks[[length(r_blocks) + 1]] <- list(
        start = block_start,
        end = i,
        name = block_name,
        content = current_block
      )
    }
  }
  # 在R代码块中
  else if (in_r_block) {
    current_block <- c(current_block, line)
  }
}

# 分析每个代码块的行长度
cat("检查文件:", file_path, "\n")
cat("==================================================\n")

long_lines_found <- FALSE

for (block in r_blocks) {
  cat("代码块:", block$name, "\n")
  cat("位置: 第", block$start, "行到第", block$end, "行\n")

  long_lines_in_block <- c()

  for (i in seq_along(block$content)) {
    line <- block$content[i]
    line_length <- nchar(line)

    if (line_length > 75 && !str_trim(line) == "") {
      long_lines_in_block <- c(long_lines_in_block,
                               paste("第", i, "行 (长度:", line_length, "):", str_trunc(line, 50)))
      long_lines_found <- TRUE
    }
  }

  if (length(long_lines_in_block) > 0) {
    cat("⚠️ 发现超过75个字符的行:\n")
    for (line_info in long_lines_in_block) {
      cat("  ", line_info, "\n")
    }
  } else {
    cat("✅ 所有行长度都符合要求 (<75字符)\n")
  }

  cat("------------------------------\n")
}

if (!long_lines_found) {
  cat("🎉 所有R代码块的行长度都符合要求!\n")
} else {
  cat("⚠️ 发现需要调整的行长度问题\n")
}