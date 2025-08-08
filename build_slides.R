# 幻灯片生成脚本
# 安装必要包（如果尚未安装）
if(!requireNamespace("rmarkdown")) install.packages("rmarkdown")
if(!requireNamespace("xaringan")) install.packages("xaringan")

# 创建必要目录
dirs_to_create <- c("slides", "libs", "imgs")
lapply(dirs_to_create, function(dir) {
  if(!dir.exists(dir)) dir.create(dir)
})

# 表格分页处理函数
process_large_table <- function(table_lines) {
  header <- table_lines[1:2] # 表头和分隔线
  body <- table_lines[3:length(table_lines)]
  chunks <- split(body, ceiling(seq_along(body)/5))
  
  result <- c()
  for (i in seq_along(chunks)) {
    result <- c(result, header, chunks[[i]])
    if (i < length(chunks)) {
      result <- c(result, "\n> *表格继续...*\n\n---\n")
    }
  }
  return(result)
}

# RMD预处理函数
preprocess_rmd <- function(file) {
  content <- readLines(file)
  new_content <- c()
  in_code_block <- FALSE
  in_table <- FALSE
  table_lines <- c()
  lines_count <- 0
  heading_level <- 0  # 0=no heading, 1=#, 2=##, 3=###
  last_heading_level <- 0
  
  for (line in content) {
    # 处理图片
    if (grepl("!\\[.*\\]\\(.*\\)", line)) {
      line <- gsub("\\)", "){width=80%}", line)
    }
    
    # 处理表格开始
    if (grepl("^\\|", line) && !in_table) {
      in_table <- TRUE
      table_lines <- c(line)
      next
    }
    
    # 处理表格内容
    if (in_table) {
      table_lines <- c(table_lines, line)
      if (grepl("^\\s*$", line)) { # 表格结束
        in_table <- FALSE
        # 处理表格分页
        if (length(table_lines) > 7) { # 表头+5行数据+分隔线
          new_content <- c(new_content, 
                          process_large_table(table_lines))
        } else {
          new_content <- c(new_content, table_lines)
        }
      }
      next
    }
    
    # 处理代码块状态
    if (grepl("^```", line)) {
      in_code_block <- !in_code_block
      lines_count <- 0
    }
    
    # 处理标题级别检测
    if (!in_code_block && !in_table) {
      if (grepl("^# ", line)) {
        heading_level <- 1
        last_heading_level <- 1
      } else if (grepl("^## ", line)) {
        heading_level <- 2
        last_heading_level <- 2
      } else if (grepl("^### ", line)) {
        heading_level <- 3
        last_heading_level <- 3
      } else if (grepl("^\\s*$", line)) {
        heading_level <- 0
      }
    }

    # 处理二级标题分页和孤立文本检测
    if (!in_code_block && grepl("^## ", line)) {
      message("检测到二级标题: ", trimws(line))
      message("当前行数计数: ", lines_count)
      if (lines_count > 10) {
        message("触发分页，插入分页标记")
        new_content <- c(new_content, "\n\n<!-- 自动分页标记 -->\n> *继续...*\n\n---\n")
        lines_count <- 1
      } else {
        lines_count <- 0
      }
    } else if (!in_code_block && !in_table && 
               last_heading_level == 2 && heading_level == 0 &&
               !grepl("^\\s*$", line) && !grepl("^---", line) &&
               (grepl("^- ", line) || grepl("^\\* ", line))) {
      message("检测到二级标题下的项目符号列表，插入分页标记")
      new_content <- c(new_content, "\n\n---\n")
      lines_count <- 0
    } else if (!in_code_block && !in_table && 
               last_heading_level == 2 && heading_level == 0 &&
               !grepl("^\\s*$", line) && !grepl("^---", line)) {
      message("检测到二级标题下的孤立文本，插入分页标记")
      new_content <- c(new_content, "\n\n---\n")
      lines_count <- 0
    }
    
    new_content <- c(new_content, line)
    if (!in_code_block) lines_count <- lines_count + 1
  }
  
  writeLines(new_content, file)
}

# 幻灯片转换函数
convert_to_slides <- function(rmd_file) {
  tryCatch({
    message("正在处理: ", rmd_file)
    output_dir <- "slides"
    output_file <- file.path(output_dir,
                           paste0(tools::file_path_sans_ext(basename(rmd_file)),
                                 ".html"))
    
    rmarkdown::render(
      input = rmd_file,
      output_format = rmarkdown::ioslides_presentation(
        css = "extra.css",
        slide_level = 3,  # 更细粒度的分页控制
        incremental = FALSE,
        fig_width = 10,
        fig_height = 6,
        chunk_options = list(
          fig.height = 6,
          fig.width = 10,
          out.height = "80%",
          out.width = "80%"
        )
      ),
      output_file = output_file
    )
    message("成功生成: ", output_file)
  }, error = function(e) {
    warning("处理失败: ", rmd_file, "\n错误信息: ", e$message)
  })
}

# 批量转换所有Rmd文件
rmd_files <- list.files(pattern = "\\.Rmd$", full.names = TRUE)
if(length(rmd_files) > 0) {
  message("开始批量转换 ", length(rmd_files), " 个Rmd文件...")
  lapply(rmd_files, convert_to_slides)
  message("全部处理完成！生成的幻灯片在 slides/ 目录下")
} else {
  message("未找到任何Rmd文件")
}
