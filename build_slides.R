# 幻灯片生成脚本
# ======================
# 主脚本功能：将Rmd文件转换为HTML幻灯片
# 主要使用rmarkdown和xaringan包

# 1. 安装必要包（如果尚未安装）
# ------------------------------
# 检查并安装rmarkdown和xaringan包
# 这两个包是生成幻灯片的核心依赖
if(!requireNamespace("rmarkdown")) install.packages("rmarkdown")  # 安装rmarkdown包（如果未安装）
if(!requireNamespace("xaringan")) install.packages("xaringan")    # 安装xaringan包（如果未安装）

# 2. 创建必要目录
# ------------------------------
# 创建slides(幻灯片输出)、libs(库文件)和imgs(图片)目录
# 如果目录已存在则不会重复创建
dirs_to_create <- c("slides", "libs", "imgs")  # 需要创建的目录列表
lapply(dirs_to_create, function(dir) {         # 遍历目录列表
  if(!dir.exists(dir)) dir.create(dir)         # 如果目录不存在则创建
})

# 3. 表格分页处理函数
# ------------------------------
# 功能：处理过长的表格，自动分页显示
# 参数：table_lines - 表格的行内容
# 返回：分页后的表格内容
process_large_table <- function(table_lines) {
  header <- table_lines[1:2] # 提取表头(前两行)
  body <- table_lines[3:length(table_lines)] # 表格主体内容
  chunks <- split(body, ceiling(seq_along(body)/5)) # 每5行分为一组
  
  result <- c() # 初始化结果向量
  for (i in seq_along(chunks)) {  # 遍历每个分块
    result <- c(result, header, chunks[[i]]) # 添加表头和当前分块
    if (i < length(chunks)) {  # 如果不是最后一个分块
      result <- c(result, "\n> *表格继续...*\n\n---\n") # 添加分页标记
    }
  }
  return(result) # 返回处理后的表格内容
}

# 4. RMD预处理函数
# ------------------------------
# 功能：预处理Rmd文件内容，包括：
# - 处理标题级别
# - 自动分页
# - 图片大小调整
# - 表格处理
# - 代码块识别
# 参数：input_file - 输入Rmd文件路径
# 返回：处理后的内容
# 5. RMD文件预处理函数
# ------------------------------
# 功能：对Rmd文件内容进行预处理，包括：
# - 标题级别处理
# - 自动分页
# - 图片大小调整
# - 表格处理
# - 代码块识别
# 参数：
#   input_file - 输入Rmd文件路径
# 返回：处理后的内容向量
preprocess_rmd <- function(input_file) {
  content <- readLines(input_file)  # 读取原始文件内容
  new_content <- c()  # 初始化处理后的内容向量
  # 状态标志变量
  in_code_block <- FALSE  # 标记是否在代码块中
  in_table <- FALSE      # 标记是否在表格中
  table_lines <- c()     # 存储当前表格的行内容
  # 标题和分页相关变量
  current_section_lines <- 0  # 当前三级标题下的行数计数器
  heading_level <- 0          # 当前标题级别: 0=无标题, 1=#, 2=##, 3=###
  last_heading_level <- 0     # 上一个标题级别
  last_h3_heading <- ""       # 存储最后一个三级标题文本(用于分页时生成继续标题)
  
  # 逐行处理内容
  for (line in content) {
    #if(grepl("环境设置和配置", line)) browser()
    # 1. 标题级别处理
    # ------------------
    # 检测并处理标题行，更新标题相关状态变量
    # 代码中的注释会影响markdown标题的判断，因此，当进入代码块时，不要判断标题
    if(!in_code_block){
      if (grepl("^### ", line)) {
        # 遇到三级标题，重置计数器
        current_section_lines <- 0
        heading_level <- 3
        last_heading_level <- 3
        last_h3_heading <- sub("^###\\s+", "", line)  # 存储三级标题文本
      } else if (grepl("^## ", line)) {
        heading_level <- 2
        last_heading_level <- 2
      } else if (grepl("^# ", line)) {
        heading_level <- 1
        last_heading_level <- 1
      }
    }
    
    
    # 处理图片
    # 2. 图片处理
    # ------------------
    # 检测图片标记并统一设置宽度为80%
    if (grepl("!\\[.*\\]\\(.*\\)", line)) {
      line <- gsub("\\)", "){width=80%}", line)  # 修改图片标记添加宽度设置
    }
    
    # 3. 表格处理
    # ------------------
    # 检测表格开始(以|开头的行)
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
        # 添加表格内容
        new_content <- c(new_content, table_lines)
        # 更新行数
        current_section_lines <- current_section_lines + length(table_lines)
      }
      next
    }
    
    # 4. 代码块处理
    # ------------------
    # 检测代码块开始/结束(```标记)
    if (grepl("^```", line)) {
      in_code_block <- !in_code_block
    }
    
    # 添加内容
    new_content <- c(new_content, line)
    
    # 更新行数计数器（所有内容都计数）
    if (last_heading_level == 3) {
      current_section_lines <- current_section_lines + 1
    }
    #browser()
    # 5. 自动分页处理
    # ------------------
    # 在三级标题下，当内容超过20行时自动分页
    # 使用前一个三级标题+"(继续)"作为新标题
    #browser()
    if (last_heading_level == 3 && current_section_lines >= 20) {
      #browser()
      if (nzchar(last_h3_heading)) {
        new_content <- c(new_content, paste0("\n### ", last_h3_heading, " (继续)\n"))
      } else {
        new_content <- c(new_content, "\n### 继续\n")
      }
      current_section_lines <- 0  # 重置计数器
    }
  }
  
  return(new_content)  # 返回处理后的内容，不写入文件
}

# 6. 幻灯片转换函数
# ------------------------------
# 功能：将单个Rmd文件转换为HTML幻灯片
# 处理流程：
# 1. 文件验证
# 2. 内容预处理
# 3. 创建临时文件
# 4. 渲染幻灯片
# 5. 资源清理
# 参数：rmd_file - 要转换的Rmd文件路径
convert_to_slides <- function(rmd_file) {
  tryCatch({
    # 1. 文件验证
    # ------------------
    # 检查文件是否存在且可读
    if(!file.exists(rmd_file)) {
      stop("文件不存在: ", rmd_file)
    }
    if(file.access(rmd_file, 4) == -1) {
      stop("文件不可读: ", rmd_file)
    }
    
    message("正在预处理: ", rmd_file)
    # 2. 内容预处理
    # ------------------
    # 调用预处理函数获取处理后的内容
    processed_content <- preprocess_rmd(rmd_file)
    
    # 3. 创建临时文件
    # ------------------
    # 使用tempfile创建临时Rmd文件，避免修改原文件
    temp_file <- tempfile(fileext = ".Rmd")
    writeLines(processed_content, temp_file, useBytes = TRUE)  # 处理编码问题
    
    message("正在转换: ", rmd_file)
    # 4. 渲染幻灯片
    # ------------------
    # 确保输出目录存在
    output_dir <- "slides"
    if(!dir.exists(output_dir)) {
      dir.create(output_dir, showWarnings = FALSE)
    }
    
    # 构造输出文件路径
    output_file <- normalizePath(file.path(output_dir,
                           paste0(tools::file_path_sans_ext(basename(rmd_file)),
                                 ".html")), mustWork = FALSE)
    
    # 设置资源路径并复制book.bib到临时目录
    resource_path <- getwd()
    if(file.exists("book.bib")) {
      file.copy("book.bib", tempdir())  # 复制参考文献文件到临时目录
    }
    
    # 使用rmarkdown渲染幻灯片
    # 关键配置：
    # - 使用ioslides格式
    # - 设置三级标题为幻灯片级别
    # - 配置图片大小等参数
    result <- rmarkdown::render(
      input = temp_file,
      output_format = rmarkdown::ioslides_presentation(
        css = "extra.css",
        slide_level = 3,
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
      output_file = output_file,
      encoding = "UTF-8",  # 明确指定编码
      output_options = list(
        pandoc_args = c(
          "--resource-path", 
          paste0(resource_path, ":", 
                file.path(resource_path, "slides"), ":", 
                tempdir())
        )
      )
    )
    
    # 5. 资源清理
    # ------------------
    # 删除临时bib文件
    if(file.exists(file.path(tempdir(), "book.bib"))) {
      unlink(file.path(tempdir(), "book.bib"))
    }
    # 删除临时Rmd文件
    unlink(temp_file)
    message("成功生成: ", normalizePath(output_file))
  }, error = function(e) {
    warning("处理失败: ", rmd_file, "\n错误类型: ", class(e)[1], 
            "\n错误信息: ", e$message)
    # 确保临时文件被删除
    if (exists("temp_file") && file.exists(temp_file)) {
      unlink(temp_file)
    }
  })
}

# 7. 批量转换函数
# ------------------------------
# 功能：批量转换当前目录下所有Rmd文件为幻灯片
# 流程：
# 1. 查找所有Rmd文件
# 2. 逐个调用convert_to_slides转换
# 3. 输出处理结果统计

# 查找当前目录下所有Rmd文件
rmd_files <- list.files(pattern = "\\.Rmd$", full.names = TRUE)
if(length(rmd_files) > 0) {
  message("开始批量转换 ", length(rmd_files), " 个Rmd文件...")
  lapply(rmd_files, convert_to_slides)
  message("全部处理完成！生成的幻灯片在 slides/ 目录下")
} else {
  message("未找到任何Rmd文件")
}
