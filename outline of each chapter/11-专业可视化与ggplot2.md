
## 第11课：专业可视化与ggplot2

### 生态学背景
数据可视化是生态学研究中传达发现和支持论证的关键工具。与基础R绘图相比，ggplot2采用图形语法，能够创建更加专业、美观的科学图表，满足期刊发表和学术报告的高标准要求。

### 演示数据
```r
# 某保护区多年生物多样性监测数据
library(ggplot2)
library(dplyr)

biodiversity_data <- data.frame(
  year = rep(2018:2022, each = 12),
  month = rep(1:12, times = 5),
  temperature = rnorm(60, mean = 15 + 5*sin(2*pi*(rep(1:12, times=5)-1)/12), sd = 2),
  species_richness = rpois(60, lambda = 25 + 10*sin(2*pi*(rep(1:12, times=5)-1)/12)),
  habitat = rep(c("森林", "草地", "湿地"), length.out = 60),
  elevation = rep(c(1200, 1000, 800), length.out = 60)
)
```

### 课堂演示过程

#### 1. ggplot2基础语法
```r
library(ggplot2)
library(dplyr)

# 创建示例数据
bird_data <- data.frame(
  species = c("白头鹎", "麻雀", "喜鹊", "乌鸦", "燕子", "画眉"),
  abundance = c(45, 78, 32, 28, 56, 41),
  habitat = c("森林", "城市", "农田", "城市", "农田", "森林"),
  body_mass = c(25, 15, 180, 350, 18, 35)
)

# 基础散点图
ggplot(bird_data, aes(x = body_mass, y = abundance)) +
  geom_point()

# 添加颜色映射
ggplot(bird_data, aes(x = body_mass, y = abundance, color = habitat)) +
  geom_point(size = 3)

# 添加标题和标签
ggplot(bird_data, aes(x = body_mass, y = abundance, color = habitat)) +
  geom_point(size = 3) +
  labs(
    title = "鸟类体重与丰度关系",
    subtitle = "不同栖息地类型的比较",
    x = "体重 (g)",
    y = "丰度 (个体数)",
    color = "栖息地类型"
  )
```

#### 2. 不同类型的图表
```r
# 创建时间序列数据
time_series_data <- data.frame(
  month = rep(1:12, 3),
  species_count = c(
    20, 25, 35, 45, 55, 60, 58, 52, 42, 32, 25, 22,  # 2020年
    22, 28, 38, 48, 58, 65, 62, 55, 45, 35, 28, 25,  # 2021年
    25, 30, 40, 50, 60, 68, 65, 58, 48, 38, 30, 28   # 2022年
  ),
  year = rep(c("2020", "2021", "2022"), each = 12)
)

# 线图
ggplot(time_series_data, aes(x = month, y = species_count, color = year)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  labs(
    title = "月度物种数量变化",
    x = "月份",
    y = "物种数量",
    color = "年份"
  ) +
  theme_minimal()

# 柱状图
habitat_summary <- bird_data %>%
  group_by(habitat) %>%
  summarise(
    mean_abundance = mean(abundance),
    se_abundance = sd(abundance) / sqrt(n()),
    .groups = 'drop'
  )

ggplot(habitat_summary, aes(x = habitat, y = mean_abundance, fill = habitat)) +
  geom_col() +
  geom_errorbar(
    aes(ymin = mean_abundance - se_abundance, 
        ymax = mean_abundance + se_abundance),
    width = 0.2
  ) +
  labs(
    title = "不同栖息地的鸟类平均丰度",
    x = "栖息地类型",
    y = "平均丰度",
    fill = "栖息地"
  ) +
  theme_classic()

# 箱线图
ggplot(bird_data, aes(x = habitat, y = abundance, fill = habitat)) +
  geom_boxplot() +
  geom_jitter(width = 0.2, alpha = 0.6) +
  labs(
    title = "不同栖息地鸟类丰度分布",
    x = "栖息地类型",
    y = "丰度"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

#### 3. 多面板图形
```r
# 创建多组数据
multi_species_data <- data.frame(
  species = rep(c("鸟类", "哺乳动物", "昆虫"), each = 24),
  month = rep(1:12, 6),
  year = rep(c("2021", "2022"), each = 12, times = 3),
  abundance = c(
    # 鸟类数据
    rnorm(24, mean = 30 + 15*sin(2*pi*(1:24-1)/12), sd = 5),
    # 哺乳动物数据
    rnorm(24, mean = 15 + 8*sin(2*pi*(1:24-1)/12), sd = 3),
    # 昆虫数据
    rnorm(24, mean = 80 + 40*sin(2*pi*(1:24-1)/12), sd = 15)
  )
)

# 分面图
ggplot(multi_species_data, aes(x = month, y = abundance, color = year)) +
  geom_line(size = 1) +
  geom_point() +
  facet_wrap(~ species, scales = "free_y") +
  scale_x_continuous(breaks = c(3, 6, 9, 12)) +
  labs(
    title = "不同类群动物的季节性变化模式",
    x = "月份",
    y = "丰度",
    color = "年份"
  ) +
  theme_bw()
```

#### 4. 专业主题和自定义
```r
# 创建专业期刊风格的图表
publication_plot <- ggplot(bird_data, aes(x = body_mass, y = abundance)) +
  geom_point(aes(color = habitat), size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "black", linetype = "dashed") +
  scale_color_manual(values = c("森林" = "#2E8B57", "城市" = "#DC143C", "农田" = "#DAA520")) +
  labs(
    title = "鸟类体重与种群丰度的关系",
    x = "体重 (g)",
    y = "种群丰度 (个体数)",
    color = "栖息地类型",
    caption = "数据来源：某自然保护区鸟类调查 (2022)"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(size = 8, color = "gray50")
  )

print(publication_plot)

# 保存图片
ggsave("bird_analysis.png", publication_plot, 
       width = 8, height = 6, dpi = 300)
```

#### 5. 复杂的生态学可视化
```r
# 群落组成气泡图
community_data <- data.frame(
  site = rep(c("样地A", "样地B", "样地C"), each = 6),
  species = rep(c("物种1", "物种2", "物种3", "物种4", "物种5", "物种6"), 3),
  abundance = c(25, 15, 8, 32, 12, 6,   # 样地A
                18, 22, 12, 25, 8, 15,  # 样地B
                12, 8, 25, 18, 20, 17), # 样地C
  biomass = c(2.5, 3.2, 1.8, 4.1, 2.0, 1.2,
              3.0, 2.8, 2.2, 3.5, 1.5, 2.5,
              2.2, 1.8, 4.0, 2.9, 3.8, 3.2)
)

ggplot(community_data, aes(x = species, y = site)) +
  geom_point(aes(size = abundance, color = biomass), alpha = 0.7) +
  scale_size_continuous(range = c(2, 12), name = "丰度") +
  scale_color_gradient(low = "lightblue", high = "darkred", name = "生物量(kg)") +
  labs(
    title = "群落物种组成与生物量分布",
    x = "物种",
    y = "样地"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid = element_line(color = "gray90", size = 0.3)
  )
```

### R语言知识点详解

#### 1. ggplot2的图形语法

##### 基本概念
- **数据(Data)**：要可视化的数据集
- **美学映射(Aesthetics)**：数据变量到图形属性的映射
- **几何对象(Geometries)**：用来表示数据的图形元素
- **统计变换(Statistics)**：对原始数据的统计总结
- **坐标系统(Coordinates)**：数据如何映射到平面
- **分面(Facets)**：将数据分割成子集的方法
- **主题(Themes)**：控制图形整体外观

##### 基本语法结构
```r
ggplot(data, aes(x = var1, y = var2)) +
  geom_*() +
  scale_*() +
  labs() +
  theme_*()
```

#### 2. 美学映射系统

##### `aes()` 函数
- **位置映射**：`x`、`y`
- **颜色映射**：`color`（边框）、`fill`（填充）
- **大小映射**：`size`
- **形状映射**：`shape`
- **透明度映射**：`alpha`
- **线型映射**：`linetype`

##### 映射 vs 设定
- **映射**：`aes(color = variable)`，颜色根据变量值变化
- **设定**：`geom_point(color = "red")`，所有点都是红色

#### 3. 几何对象详解

##### 点图相关
- **`geom_point()`**：散点图
- **`geom_jitter()`**：抖动散点图
- **参数**：`size`、`shape`、`alpha`、`stroke`

##### 线图相关
- **`geom_line()`**：线图
- **`geom_path()`**：路径图
- **`geom_smooth()`**：拟合线
- **参数**：`size`、`linetype`、`method`

##### 柱状图相关
- **`geom_col()`**：柱状图（使用实际值）
- **`geom_bar()`**：柱状图（统计计数）
- **`geom_histogram()`**：直方图
- **参数**：`width`、`position`

##### 分布图相关
- **`geom_boxplot()`**：箱线图
- **`geom_violin()`**：小提琴图
- **`geom_density()`**：密度图

#### 4. 标度系统

##### 颜色标度
- **连续型**：
  - `scale_color_gradient()`：双色渐变
  - `scale_color_gradient2()`：三色渐变
  - `scale_color_viridis_c()`：viridis调色板
- **离散型**：
  - `scale_color_manual()`：手动设置颜色
  - `scale_color_brewer()`：ColorBrewer调色板

##### 坐标轴标度
- **连续型**：
  - `scale_x_continuous()`：连续x轴
  - `scale_y_log10()`：对数y轴
- **离散型**：
  - `scale_x_discrete()`：离散x轴
- **日期型**：
  - `scale_x_date()`：日期x轴

#### 5. 分面系统

##### `facet_wrap()`
- **用途**：按一个变量分面，排列成网格
- **语法**：`facet_wrap(~ variable, ncol = 2)`
- **参数**：
  - `ncol`、`nrow`：列数和行数
  - `scales`：坐标轴缩放方式

##### `facet_grid()`
- **用途**：按两个变量分面，形成矩阵
- **语法**：`facet_grid(rows ~ cols)`
- **特殊语法**：
  - `facet_grid(. ~ variable)`：仅按列分面
  - `facet_grid(variable ~ .)`：仅按行分面

#### 6. 主题系统

##### 预设主题
- **`theme_minimal()`**：简洁主题
- **`theme_classic()`**：经典主题
- **`theme_bw()`**：黑白主题
- **`theme_void()`**：空白主题

##### 自定义主题元素
- **文本元素**：`element_text()`
  - `size`：字体大小
  - `color`：字体颜色
  - `face`：字体样式（"bold"、"italic"）
  - `hjust`、`vjust`：水平和垂直对齐
- **线条元素**：`element_line()`
  - `color`：线条颜色
  - `size`：线条粗细
  - `linetype`：线条类型
- **矩形元素**：`element_rect()`
  - `fill`：填充颜色
  - `color`：边框颜色
- **移除元素**：`element_blank()`

#### 7. 图片保存

##### `ggsave()` 函数
- **语法**：`ggsave(filename, plot, width, height, dpi, units)`
- **支持格式**：
  - 矢量格式：PDF、SVG、EPS
  - 位图格式：PNG、JPEG、TIFF
- **推荐设置**：
  - 期刊投稿：300-600 DPI
  - 演示文稿：150-300 DPI
  - 网页使用：72-150 DPI

#### 8. 色彩设计原则

##### 科学可视化色彩指南
- **连续数据**：使用渐变色，避免彩虹色
- **分类数据**：使用对比鲜明的颜色
- **色盲友好**：避免红绿组合，推荐viridis调色板
- **发表要求**：考虑黑白印刷效果

##### 推荐调色板
- **Viridis系列**：色盲友好，打印友好
- **ColorBrewer**：专业的制图调色板
- **自然色彩**：模仿自然界的颜色组合

### 课后练习

**题目**：某国家公园植被多样性调查数据：
```r
vegetation_survey <- data.frame(
  transect = rep(c("山顶", "山腰", "山底"), each = 20),
  species_richness = c(rnorm(20, 15, 3), rnorm(20, 25, 4), rnorm(20, 35, 5)),
  coverage_percent = c(rnorm(20, 60, 10), rnorm(20, 75, 8), rnorm(20, 85, 6)),
  slope_degree = c(rnorm(20, 25, 5), rnorm(20, 15, 3), rnorm(20, 5, 2)),
  soil_depth = c(rnorm(20, 15, 3), rnorm(20, 25, 4), rnorm(20, 40, 6))
)
```

请完成（使用ggplot2高级功能，结合之前学过的所有内容）：
1. 创建物种丰富度与植被覆盖度的散点图，用颜色区分不同海拔带（使用geom_point()和aes()）
2. 绘制三个海拔带物种丰富度的箱线图，添加个体数据点（使用geom_boxplot()和geom_jitter()）
3. 创建多面板图，展示不同海拔带的各项指标分布（使用facet_wrap()）
4. 设计一个期刊级别的综合图表，展示海拔梯度上的植被特征变化（使用多个geom层）
5. 自定义主题，确保图表符合学术发表标准（使用theme()函数）
6. 保存高质量图片用于论文发表（使用ggsave()函数）
7. 与第7课的基础绘图方法对比，总结ggplot2的优势
8. 尝试创建动态或交互式可视化（选做，可查阅相关资料）
