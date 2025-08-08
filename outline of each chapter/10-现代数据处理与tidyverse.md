
## 第10课：现代数据处理与tidyverse

### 生态学背景
现代生态学研究产生的数据日益复杂，传统的基础R语法在处理复杂数据操作时略显繁琐。tidyverse是R语言的现代数据处理工具包，提供了更直观、更高效的数据处理方法，特别适合处理多变量、多时间点的生态学数据。

### 演示数据
```r
# 模拟某森林样地多年监测数据
library(tidyverse)

# 创建模拟数据
forest_monitoring <- data.frame(
  plot_id = rep(paste0("Plot_", 1:5), each = 12),
  year = rep(2018:2021, times = 15),
  season = rep(c("春", "夏", "秋"), times = 20),
  temperature = rnorm(60, mean = 15, sd = 5),
  humidity = rnorm(60, mean = 70, sd = 10),
  species_richness = rpois(60, lambda = 25),
  tree_height = rnorm(60, mean = 12, sd = 3),
  soil_ph = rnorm(60, mean = 6.5, sd = 0.5)
)
```

### 课堂演示过程

#### 1. tidyverse包的加载和数据查看
```r
# 安装和加载tidyverse
# install.packages("tidyverse")
library(tidyverse)

# 创建示例数据（简化版）
forest_data <- tibble(
  plot_id = rep(c("A", "B", "C", "D"), each = 6),
  year = rep(2020:2022, times = 8),
  season = rep(c("春", "夏"), times = 12),
  temperature = c(12, 18, 15, 22, 10, 16, 14, 20, 13, 19, 11, 17, 
                  16, 21, 14, 20, 12, 18, 15, 23, 13, 21, 11, 19),
  species_count = c(22, 28, 25, 32, 20, 24, 26, 30, 24, 28, 21, 25,
                   28, 34, 26, 32, 23, 27, 30, 36, 27, 31, 24, 28)
)

# 查看数据结构
glimpse(forest_data)
head(forest_data)
```

#### 2. 数据筛选与选择
```r
# 使用filter()筛选行
summer_data <- forest_data %>%
  filter(season == "夏")

high_diversity <- forest_data %>%
  filter(species_count > 30)

recent_summer <- forest_data %>%
  filter(year >= 2021 & season == "夏")

# 使用select()选择列
temp_species <- forest_data %>%
  select(plot_id, temperature, species_count)

# 选择特定范围的列
core_variables <- forest_data %>%
  select(plot_id:season, species_count)

# 排除特定列
without_year <- forest_data %>%
  select(-year)
```

#### 3. 数据变换与新变量创建
```r
# 使用mutate()创建新变量
forest_enhanced <- forest_data %>%
  mutate(
    temp_category = case_when(
      temperature < 15 ~ "低温",
      temperature < 20 ~ "中温",
      TRUE ~ "高温"
    ),
    diversity_index = species_count / 10,  # 简化的多样性指数
    temp_celsius = temperature,
    temp_fahrenheit = temperature * 9/5 + 32
  )

# 查看结果
forest_enhanced %>%
  select(plot_id, temperature, temp_category, species_count, diversity_index)
```

#### 4. 数据排序与分组汇总
```r
# 使用arrange()排序
forest_data %>%
  arrange(desc(species_count)) %>%
  head()

forest_data %>%
  arrange(plot_id, year, season)

# 使用group_by()和summarise()进行分组统计
plot_summary <- forest_data %>%
  group_by(plot_id) %>%
  summarise(
    n_observations = n(),
    mean_temperature = mean(temperature),
    mean_species = mean(species_count),
    max_species = max(species_count),
    sd_temperature = sd(temperature),
    .groups = 'drop'
  )

print(plot_summary)

# 多变量分组
season_plot_summary <- forest_data %>%
  group_by(season, plot_id) %>%
  summarise(
    mean_temp = mean(temperature),
    mean_species = mean(species_count),
    .groups = 'drop'
  )

print(season_plot_summary)
```

#### 5. 数据重塑：长宽格式转换
```r
# 宽格式转长格式（gather/pivot_longer）
forest_long <- forest_data %>%
  pivot_longer(
    cols = c(temperature, species_count),
    names_to = "variable",
    values_to = "value"
  )

head(forest_long)

# 长格式转宽格式（spread/pivot_wider）
forest_wide <- forest_long %>%
  pivot_wider(
    names_from = variable,
    values_from = value
  )

head(forest_wide)
```

#### 6. 数据连接
```r
# 创建额外的样地信息
plot_info <- tibble(
  plot_id = c("A", "B", "C", "D"),
  elevation = c(1200, 1450, 1800, 1600),
  soil_type = c("壤土", "砂土", "黏土", "壤土"),
  management = c("保护", "管理", "保护", "管理")
)

# 左连接
forest_complete <- forest_data %>%
  left_join(plot_info, by = "plot_id")

head(forest_complete)

# 按管理类型分析
management_analysis <- forest_complete %>%
  group_by(management) %>%
  summarise(
    mean_temperature = mean(temperature),
    mean_species = mean(species_count),
    .groups = 'drop'
  )

print(management_analysis)
```

### R语言知识点详解

#### 1. tidyverse哲学与管道操作

##### 管道操作符 `%>%`
- **作用**：将左侧结果作为右侧函数的第一个参数
- **优势**：
  - 代码更易读：从左到右，从上到下
  - 减少中间变量：避免创建临时对象
  - 链式操作：多个操作连续进行
- **语法**：`data %>% function()`
- **等价写法**：`function(data)`

##### tibble vs data.frame
- **tibble特点**：
  - 更好的打印输出
  - 更严格的子集操作
  - 保持字符串为字符串（不自动转因子）
  - 支持列名包含空格和特殊字符

#### 2. 数据筛选与选择

##### `filter()` - 行筛选
- **语法**：`filter(data, condition1, condition2, ...)`
- **多条件**：
  - 逗号分隔：逻辑与（AND）
  - `|`：逻辑或（OR）
  - `!`：逻辑非（NOT）
- **常用条件**：
  - `==`、`!=`：等于、不等于
  - `>、<、>=、<=`：大小比较
  - `%in%`：成员检查
  - `is.na()`：缺失值检查

##### `select()` - 列选择
- **基本选择**：`select(data, col1, col2)`
- **范围选择**：`select(data, col1:col3)`
- **排除选择**：`select(data, -col1, -col2)`
- **辅助函数**：
  - `starts_with()`：以某字符开头
  - `ends_with()`：以某字符结尾
  - `contains()`：包含某字符
  - `matches()`：正则表达式匹配

#### 3. 数据变换

##### `mutate()` - 新变量创建
- **基本用法**：`mutate(data, new_col = expression)`
- **多变量**：可同时创建多个新变量
- **引用新建变量**：在同一个`mutate()`中可引用前面创建的变量
- **变量类型转换**：
  - `as.numeric()`：转数值
  - `as.character()`：转字符
  - `as.factor()`：转因子

##### `case_when()` - 多条件分类
- **语法**：
  ```r
  case_when(
    condition1 ~ value1,
    condition2 ~ value2,
    TRUE ~ default_value
  )
  ```
- **优势**：替代复杂的嵌套`ifelse()`
- **注意**：条件从上到下评估，满足即停止

#### 4. 数据排序与汇总

##### `arrange()` - 数据排序
- **基本排序**：`arrange(data, col)`
- **降序排序**：`arrange(data, desc(col))`
- **多列排序**：`arrange(data, col1, col2)`

##### `group_by()` 与 `summarise()`
- **分组概念**：将数据按指定变量分组
- **汇总函数**：
  - `n()`：计数
  - `mean()`、`median()`：均值、中位数
  - `sum()`、`min()`、`max()`：求和、最小值、最大值
  - `sd()`、`var()`：标准差、方差
- **`.groups` 参数**：控制结果的分组状态

#### 5. 数据重塑

##### 长宽格式概念
- **宽格式**：每个变量一列，观察单位一行
- **长格式**：变量名和变量值分别存储在不同列中
- **选择原则**：
  - 分析时通常用长格式
  - 展示时通常用宽格式

##### `pivot_longer()` - 宽转长
- **语法**：`pivot_longer(data, cols, names_to, values_to)`
- **参数**：
  - `cols`：要转换的列
  - `names_to`：存储变量名的新列名
  - `values_to`：存储变量值的新列名

##### `pivot_wider()` - 长转宽
- **语法**：`pivot_wider(data, names_from, values_from)`
- **参数**：
  - `names_from`：提供新列名的列
  - `values_from`：提供新列值的列

#### 6. 数据连接

##### 连接类型
- **`left_join()`**：保留左表所有行
- **`right_join()`**：保留右表所有行
- **`inner_join()`**：仅保留匹配行
- **`full_join()`**：保留所有行

##### 连接语法
- **基本语法**：`left_join(x, y, by = "key")`
- **多键连接**：`by = c("key1", "key2")`
- **不同列名**：`by = c("x_key" = "y_key")`

### 课后练习

**题目**：某湿地生物多样性调查数据：
```r
wetland_survey <- tibble(
  site_id = rep(c("W1", "W2", "W3"), each = 8),
  date = rep(c("2022-05", "2022-08", "2022-05", "2022-08"), times = 6),
  plant_species = c(15, 18, 12, 16, 20, 25, 18, 22, 8, 12, 6, 10),
  bird_species = c(8, 12, 6, 9, 15, 18, 12, 14, 4, 7, 3, 5),
  water_level = c(45, 38, 50, 42, 35, 28, 40, 33, 55, 48, 60, 53)
)

site_characteristics <- tibble(
  site_id = c("W1", "W2", "W3"),
  area_ha = c(12, 8, 15),
  protection_status = c("保护区", "缓冲区", "实验区")
)
```

请完成（使用tidyverse工具链，结合之前学过的统计和可视化方法）：
1. 筛选出5月份的调查数据，并计算植物和鸟类物种总数（使用filter()和mutate()）
2. 按站点分组，计算各站点的平均物种数和水位变化范围（使用group_by()和summarise()）
3. 连接站点特征数据，创建物种密度指标（物种数/面积）（使用left_join()和mutate()）
4. 将数据从宽格式转换为长格式，便于后续统计分析（使用pivot_longer()）
5. 根据保护状态和季节，分析不同组合下的生物多样性特征（使用group_by()和统计函数）
6. 使用ggplot2创建专业的可视化图表展示分析结果
7. 与第9课的传统方法对比，体会tidyverse的优势
