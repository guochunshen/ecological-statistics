# 将 docs 目录下所有 HTML 文件中的 cdn.jsdelivr.net 替换为 fastly.jsdelivr.net
convert_cdn_links <- function() {
  # 确保 docs 目录存在
  if (!dir.exists("docs")) {
    stop("错误：docs 目录不存在")
  }
  
  # 获取 docs 目录下所有 HTML 文件（递归搜索）
  html_files <- list.files(
    path = "docs", 
    pattern = "\\.html$", 
    recursive = TRUE, 
    full.names = TRUE
  )
  
  if (length(html_files) == 0) {
    message("警告：未找到任何 HTML 文件")
    return(invisible())
  }
  
  # 遍历每个文件并执行替换
  for (file_path in html_files) {
    tryCatch({
      if (!file.exists(file_path)) {
        message(sprintf("文件不存在: %s", file_path))
        next
      }
      
      # 读取文件内容
      content <- readLines(file_path, warn = FALSE, encoding = "UTF-8")
      
      # 执行替换操作
      new_content <- gsub(
        "cdn\\.jsdelivr\\.net", 
        "fastly.jsdelivr.net", 
        content
      )
      
      # 写回修改后的内容
      writeLines(new_content, file_path, useBytes = TRUE)
      
      # 打印处理进度
      message(sprintf("已处理: %s", file_path))
    }, error = function(e) {
      message(sprintf("处理 %s 时出错: %s", file_path, e$message))
    })
  }
  
  message("所有文件处理完成!")
}

# 使用示例: 
# source("helper/convert_cdn.R")
convert_cdn_links()
