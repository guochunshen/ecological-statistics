
## 第16课：方差分析（ANOVA）

### 统计学背景
方差分析（Analysis of Variance, ANOVA）是比较三个或更多组别均值是否相等的统计方法。在生态学研究中，我们经常需要比较多个处理组、多个栖息地或多个时间点的差异，如比较不同施肥处理对植物生长的影响，或者比较不同森林类型的物种多样性。ANOVA通过分析总变异中不同来源的贡献来判断组间差异是否显著。

### 演示数据
```r
# 森林生态系统不同管理方式效果比较
set.seed(123)

# 四种森林管理方式下的物种丰富度数据
management_data <- data.frame(
  management_type = rep(c("自然保护", "选择性伐取", "轮伐", "皆伐"), each = 12),
  species_richness = c(
    rnorm(12, mean = 28, sd = 4),    # 自然保护
    rnorm(12, mean = 24, sd = 4),    # 选择性伐取
    rnorm(12, mean = 18, sd = 4),    # 轮伐
    rnorm(12, mean = 12, sd = 4)     # 皆伐
  ),
  site_id = paste0("Site_", 1:48)
)

# 双因子实验：不同土壤类型和水分处理对植物生长的影响
soil_water_experiment <- expand.grid(
  soil_type = c("砂土", "壤土", "粘土"),
  water_treatment = c("干旱", "正常", "充足"),
  rep = 1:8
) %>%
  mutate(
    plant_height = 15 +
      ifelse(soil_type == "壤土", 5, ifelse(soil_type == "粘土", 3, 0)) +
      ifelse(water_treatment == "正常", 3, ifelse(water_treatment == "充足", 6, -2)) +
      ifelse(soil_type == "壤土" & water_treatment == "充足", 4, 0) +  # 交互作用
      rnorm(72, 0, 2)
  )
```

### 课堂演示过程

#### 1. 单因子方差分析（One-way ANOVA）

```r
# 单因子ANOVA：比较四种森林管理方式的效果
print("=== 单因子方差分析 ===")

# 1. 数据探索性分析
# 描述统计
descriptive_stats <- management_data %>%
  group_by(management_type) %>%
  summarise(
    n = n(),
    mean = mean(species_richness),
    sd = sd(species_richness),
    se = sd / sqrt(n),
    .groups = 'drop'
  )

print("各组描述统计:")
print(descriptive_stats)

# 箱线图可视化
library(ggplot2)
boxplot_anova <- ggplot(management_data, aes(x = management_type, y = species_richness)) +
  geom_boxplot(aes(fill = management_type), alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5) +
  stat_summary(fun = mean, geom = "point", size = 3, color = "red", shape = 18) +
  labs(
    title = "不同森林管理方式下的物种丰富度",
    x = "管理方式",
    y = "物种丰富度",
    fill = "管理方式"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(hjust = 0.5)
  )

print(boxplot_anova)

# 2. ANOVA前提假设检验
print("\n=== ANOVA前提假设检验 ===")

# 正态性检验（对每组进行Shapiro-Wilk检验）
normality_tests <- management_data %>%
  group_by(management_type) %>%
  summarise(
    shapiro_p = shapiro.test(species_richness)$p.value,
    .groups = 'drop'
  )

print("各组正态性检验结果:")
print(normality_tests)

# 方差齐性检验（Levene检验）
# 使用car包的leveneTest，这里用简化的方法
levene_result <- bartlett.test(species_richness ~ management_type, 
                              data = management_data)
print(paste("Bartlett方差齐性检验 p值:", round(levene_result$p.value, 4)))

if (levene_result$p.value > 0.05) {
  print("方差齐性假设成立，可以进行经典ANOVA")
} else {
  print("方差不齐，建议使用Welch ANOVA")
}

# 3. 进行单因子ANOVA
anova_result <- aov(species_richness ~ management_type, data = management_data)
anova_summary <- summary(anova_result)

print("\n=== 单因子ANOVA结果 ===")
print(anova_summary)

# 计算效应大小（eta squared）
ss_total <- sum(anova_summary[[1]]$`Sum Sq`)
ss_between <- anova_summary[[1]]$`Sum Sq`[1]
eta_squared <- ss_between / ss_total

print(paste("效应大小 (η²):", round(eta_squared, 3)))

# 效应大小解释
if (eta_squared < 0.01) {
  effect_interpretation <- "很小"
} else if (eta_squared < 0.06) {
  effect_interpretation <- "小"
} else if (eta_squared < 0.14) {
  effect_interpretation <- "中等"
} else {
  effect_interpretation <- "大"
}
print(paste("效应大小解释:", effect_interpretation))

# 4. 多重比较（事后检验）
if (anova_summary[[1]]$`Pr(>F)`[1] < 0.05) {
  print("\n=== 事后检验（Tukey HSD） ===")
  
  # Tukey HSD多重比较
  tukey_result <- TukeyHSD(anova_result)
  print(tukey_result)
  
  # 可视化Tukey检验结果
  plot(tukey_result, las = 2, cex.axis = 0.8)
  title("Tukey HSD多重比较结果")
  
  # 提取显著性差异
  tukey_df <- as.data.frame(tukey_result$management_type)
  significant_pairs <- tukey_df[tukey_df$`p adj` < 0.05, ]
  
  print("\n显著不同的组对:")
  print(significant_pairs)
} else {
  print("ANOVA结果不显著，无需进行事后检验")
}
```

#### 2. 双因子方差分析（Two-way ANOVA）

```r
print("\n=== 双因子方差分析 ===")

# 双因子ANOVA：土壤类型和水分处理对植物生长的影响
print("研究问题：土壤类型和水分处理如何影响植物生长？")

# 1. 数据探索
# 双因子描述统计
two_way_stats <- soil_water_experiment %>%
  group_by(soil_type, water_treatment) %>%
  summarise(
    n = n(),
    mean_height = mean(plant_height),
    sd_height = sd(plant_height),
    .groups = 'drop'
  )

print("各处理组合的描述统计:")
print(two_way_stats)

# 交互作用图
interaction_plot <- ggplot(two_way_stats, 
                          aes(x = water_treatment, y = mean_height, 
                              color = soil_type, group = soil_type)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  labs(
    title = "土壤类型与水分处理的交互作用",
    x = "水分处理",
    y = "平均植物高度 (cm)",
    color = "土壤类型"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(interaction_plot)

# 2. 双因子ANOVA
two_way_anova <- aov(plant_height ~ soil_type * water_treatment, 
                     data = soil_water_experiment)
two_way_summary <- summary(two_way_anova)

print("\n=== 双因子ANOVA结果 ===")
print(two_way_summary)

# 计算各效应的效应大小
ss_values <- two_way_summary[[1]]$`Sum Sq`
ss_total_2way <- sum(ss_values)

eta_soil <- ss_values[1] / ss_total_2way
eta_water <- ss_values[2] / ss_total_2way  
eta_interaction <- ss_values[3] / ss_total_2way

print("\n各效应的效应大小:")
print(paste("土壤类型主效应 η²:", round(eta_soil, 3)))
print(paste("水分处理主效应 η²:", round(eta_water, 3)))
print(paste("交互作用 η²:", round(eta_interaction, 3)))

# 3. 简单效应分析（当交互作用显著时）
if (two_way_summary[[1]]$`Pr(>F)`[3] < 0.05) {
  print("\n=== 交互作用显著，进行简单效应分析 ===")
  
  # 在每种土壤类型下比较水分处理的效果
  print("各土壤类型下水分处理的简单效应:")
  
  for (soil in unique(soil_water_experiment$soil_type)) {
    subset_data <- soil_water_experiment[soil_water_experiment$soil_type == soil, ]
    simple_anova <- aov(plant_height ~ water_treatment, data = subset_data)
    simple_summary <- summary(simple_anova)
    
    cat(paste("\n", soil, "土壤下的水分处理效应:\n"))
    print(simple_summary)
    
    if (simple_summary[[1]]$`Pr(>F)`[1] < 0.05) {
      tukey_simple <- TukeyHSD(simple_anova)
      print(tukey_simple)
    }
  }
}

# 4. 残差分析
print("\n=== 模型诊断 ===")

par(mfrow = c(2, 2))
plot(two_way_anova)
par(mfrow = c(1, 1))

# 残差正态性检验
residuals_normality <- shapiro.test(residuals(two_way_anova))
print(paste("残差正态性检验 p值:", round(residuals_normality$p.value, 4)))
```

#### 3. 重复测量ANOVA

```r
print("\n=== 重复测量ANOVA ===")

# 创建重复测量数据：同一批植物在不同时间点的测量
set.seed(456)
repeated_measures_data <- expand.grid(
  plant_id = paste0("Plant_", 1:20),
  treatment = rep(c("对照", "施肥"), each = 10),
  time_point = c("0周", "4周", "8周", "12周")
) %>%
  arrange(plant_id, time_point) %>%
  mutate(
    time_numeric = as.numeric(factor(time_point)),
    # 基础生长模式 + 处理效应 + 个体差异 + 随机误差
    base_growth = rep(rnorm(20, 20, 3), each = 4),  # 个体基础差异
    treatment_effect = ifelse(treatment == "施肥", 8, 0),
    time_effect = (time_numeric - 1) * 2,  # 时间线性效应
    interaction_effect = ifelse(treatment == "施肥", (time_numeric - 1) * 1.5, 0),
    plant_height = base_growth + treatment_effect + time_effect + 
                   interaction_effect + rnorm(80, 0, 1.5)
  )

# 可视化重复测量数据
rm_plot <- ggplot(repeated_measures_data, 
                  aes(x = time_point, y = plant_height, color = treatment)) +
  stat_summary(fun = mean, geom = "line", aes(group = treatment), size = 1) +
  stat_summary(fun = mean, geom = "point", size = 3) +
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.1) +
  facet_wrap(~ treatment) +
  labs(
    title = "重复测量实验：植物生长的时间变化",
    x = "时间点",
    y = "植物高度 (cm)",
    color = "处理"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(rm_plot)

# 简化的重复测量分析（使用混合效应模型会更准确）
# 这里展示传统方法的概念

print("重复测量数据的描述统计:")
rm_summary <- repeated_measures_data %>%
  group_by(treatment, time_point) %>%
  summarise(
    n = n(),
    mean_height = mean(plant_height),
    sd_height = sd(plant_height),
    se_height = sd_height / sqrt(n),
    .groups = 'drop'
  )
print(rm_summary)

# 注意：真正的重复测量ANOVA需要考虑球形度假设等
# 这里展示概念性分析
print("\n注意：重复测量ANOVA需要专门的分析方法")
print("真实分析中应使用混合效应模型或专门的重复测量函数")
```

#### 4. 非参数替代方法

```r
print("\n=== 非参数ANOVA替代方法 ===")

# 当ANOVA假设不满足时的非参数替代

# 1. Kruskal-Wallis检验（单因子非参数ANOVA）
print("1. Kruskal-Wallis检验:")

# 创建违反正态性假设的数据
set.seed(789)
non_normal_data <- data.frame(
  group = rep(c("A", "B", "C", "D"), each = 15),
  value = c(
    rexp(15, rate = 1/10),    # 指数分布
    rexp(15, rate = 1/15),    
    rexp(15, rate = 1/20),    
    rexp(15, rate = 1/25)     
  )
)

# 检验数据分布
print("各组正态性检验:")
norm_tests_kw <- non_normal_data %>%
  group_by(group) %>%
  summarise(shapiro_p = shapiro.test(value)$p.value, .groups = 'drop')
print(norm_tests_kw)

# Kruskal-Wallis检验
kw_result <- kruskal.test(value ~ group, data = non_normal_data)
print("\nKruskal-Wallis检验结果:")
print(kw_result)

# 如果显著，进行事后比较（Dunn检验）
if (kw_result$p.value < 0.05) {
  print("\nKruskal-Wallis检验显著，需要事后比较")
  print("实际分析中应使用dunn.test包进行配对比较")
  
  # 成对Wilcoxon检验（简化版事后检验）
  groups <- unique(non_normal_data$group)
  comparisons <- combn(groups, 2, simplify = FALSE)
  
  pairwise_results <- data.frame(
    comparison = character(),
    p_value = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (comp in comparisons) {
    group1_data <- non_normal_data$value[non_normal_data$group == comp[1]]
    group2_data <- non_normal_data$value[non_normal_data$group == comp[2]]
    
    wilcox_result <- wilcox.test(group1_data, group2_data)
    
    pairwise_results <- rbind(pairwise_results, data.frame(
      comparison = paste(comp[1], "vs", comp[2]),
      p_value = wilcox_result$p.value
    ))
  }
  
  # Bonferroni校正
  pairwise_results$p_adjusted <- p.adjust(pairwise_results$p_value, method = "bonferroni")
  
  print("\n成对比较结果（Bonferroni校正）:")
  print(pairwise_results)
}

# 2. Friedman检验（重复测量的非参数替代）
print("\n2. Friedman检验（重复测量非参数替代）:")
print("用于重复测量设计但数据不满足参数检验假设的情况")
print("需要数据以特定格式组织，这里仅展示概念")
```

#### 5. 效应大小和检验力分析

```r
print("\n=== 效应大小和检验力分析 ===")

# 1. 效应大小的计算和解释
print("1. ANOVA中的效应大小指标:")

# eta squared (η²) - 已在前面计算
print(paste("Eta squared (η²):", round(eta_squared, 3)))
print("η² = SS_between / SS_total")
print("解释：该因子解释了总变异的", round(eta_squared * 100, 1), "%")

# omega squared (ω²) - 更无偏的估计
ms_between <- anova_summary[[1]]$`Mean Sq`[1]
ms_within <- anova_summary[[1]]$`Mean Sq`[2]
df_between <- anova_summary[[1]]$Df[1]
n_total <- nrow(management_data)

omega_squared <- (ss_between - df_between * ms_within) / (ss_total + ms_within)
print(paste("Omega squared (ω²):", round(omega_squared, 3)))

# 2. 检验力分析
print("\n2. 检验力分析:")

# 使用pwr包进行检验力计算（概念性展示）
print("检验力分析有助于:")
print("- 在实验设计阶段确定需要的样本大小")
print("- 事后评估实验的检验力")
print("- 解释非显著结果是否由于检验力不足")

# 计算观察到的效应大小对应的检验力
f_effect_size <- sqrt(eta_squared / (1 - eta_squared))
print(paste("Cohen's f:", round(f_effect_size, 3)))

# Cohen's f的解释标准
if (f_effect_size < 0.1) {
  f_interpretation <- "很小"
} else if (f_effect_size < 0.25) {
  f_interpretation <- "小"
} else if (f_effect_size < 0.4) {
  f_interpretation <- "中等"
} else {
  f_interpretation <- "大"
}
print(paste("效应大小解释:", f_interpretation))

# 3. 实际意义vs统计显著性
print("\n3. 实际意义评估:")
print("除了统计显著性，还需要考虑:")
print("- 效应大小是否有实际意义？")
print("- 置信区间是否支持实际重要的差异？")
print("- 研究结果是否在生态学上有意义？")

# 计算均值差异的置信区间
mean_differences <- outer(descriptive_stats$mean, descriptive_stats$mean, "-")
rownames(mean_differences) <- descriptive_stats$management_type
colnames(mean_differences) <- descriptive_stats$management_type

print("\n各组均值差异矩阵:")
print(round(mean_differences, 2))
```

### R语言知识点详解

#### 1. ANOVA基本概念

##### 方差分析原理
- **基本思想**：将总变异分解为组间变异和组内变异
- **零假设**：所有组的总体均值相等
- **备择假设**：至少有一组均值不同
- **检验统计量**：F = MS_between / MS_within

##### ANOVA类型
- **单因子ANOVA**：一个分组变量
- **双因子ANOVA**：两个分组变量，可检验交互作用
- **重复测量ANOVA**：同一被试的多次测量
- **多元ANOVA**：多个因变量同时分析

#### 2. R中的ANOVA函数

##### `aov()` 函数
- **语法**：`aov(formula, data)`
- **公式语法**：
  - 单因子：`y ~ factor`
  - 双因子：`y ~ factor1 + factor2`
  - 交互作用：`y ~ factor1 * factor2`
- **返回对象**：aov对象，可用于后续分析

##### `summary()` 和ANOVA表
- **自由度（Df）**：变异来源的自由度
- **平方和（Sum Sq）**：变异大小
- **均方（Mean Sq）**：平方和/自由度
- **F值**：均方比
- **Pr(>F)**：p值

#### 3. ANOVA前提假设

##### 独立性假设
- **要求**：观察值相互独立
- **保证方法**：通过实验设计确保
- **违反后果**：第一类错误率增加

##### 正态性假设
- **要求**：残差服从正态分布
- **检验方法**：Shapiro-Wilk检验、QQ图
- **违反处理**：数据转换或非参数检验

##### 方差齐性假设
- **要求**：各组方差相等
- **检验方法**：Levene检验、Bartlett检验
- **违反处理**：Welch ANOVA或数据转换

#### 4. 多重比较方法

##### Tukey HSD
- **用途**：控制家族错误率的成对比较
- **函数**：`TukeyHSD(aov_object)`
- **适用**：样本量相等或不等均可
- **优点**：控制第一类错误，较为保守

##### 其他校正方法
- **Bonferroni**：`p.adjust(method = "bonferroni")`
- **FDR控制**：`p.adjust(method = "fdr")`
- **Holm方法**：`p.adjust(method = "holm")`

#### 5. 效应大小计算

##### Eta Squared (η²)
- **公式**：η² = SS_between / SS_total
- **解释**：该因子解释的变异比例
- **范围**：0到1
- **问题**：样本量影响，有偏估计

##### Omega Squared (ω²)
- **优点**：较无偏的效应大小估计
- **公式**：ω² = (SS_between - df_between × MS_within) / (SS_total + MS_within)
- **推荐**：优于eta squared

#### 6. 非参数替代方法

##### Kruskal-Wallis检验
- **用途**：单因子ANOVA的非参数替代
- **函数**：`kruskal.test(formula, data)`
- **假设**：只需要分布形状相似
- **事后检验**：Dunn检验

##### Friedman检验
- **用途**：重复测量ANOVA的非参数替代
- **函数**：`friedman.test()`
- **适用**：配对或重复测量设计

### 课后练习

**题目**：某湿地修复项目效果评估，研究三种不同修复方法对水生植物多样性的影响：

```r
# 修复方法实验数据
restoration_experiment <- data.frame(
  method = rep(c("自然恢复", "人工种植", "基质改良"), each = 15),
  diversity_index = c(
    # 自然恢复
    c(2.1, 2.3, 1.9, 2.5, 2.0, 2.4, 2.2, 1.8, 2.6, 2.3, 
      2.1, 2.4, 2.0, 2.2, 2.5),
    # 人工种植  
    c(3.1, 3.4, 2.9, 3.6, 3.2, 3.5, 3.0, 3.3, 3.7, 3.1,
      3.4, 3.2, 3.6, 3.0, 3.3),
    # 基质改良
    c(2.8, 3.0, 2.6, 3.2, 2.9, 3.1, 2.7, 2.5, 3.3, 2.8,
      3.0, 2.9, 2.7, 3.1, 2.6)
  )
)

# 双因子实验：修复方法 × 季节
seasonal_data <- expand.grid(
  method = c("自然恢复", "人工种植", "基质改良"),
  season = c("春季", "夏季", "秋季"),
  rep = 1:8
) %>%
  mutate(
    diversity_index = 2.5 +
      ifelse(method == "人工种植", 0.8, ifelse(method == "基质改良", 0.4, 0)) +
      ifelse(season == "夏季", 0.5, ifelse(season == "秋季", 0.2, 0)) +
      ifelse(method == "人工种植" & season == "夏季", 0.3, 0) +
      rnorm(72, 0, 0.3)
  )

# 非正态分布数据（用于非参数检验）
skewed_data <- data.frame(
  treatment = rep(c("处理A", "处理B", "处理C"), each = 20),
  abundance = c(
    rexp(20, rate = 1/15),    # 指数分布
    rexp(20, rate = 1/25),    
    rexp(20, rate = 1/35)     
  )
)
```

请完成（使用ANOVA及相关方法，整合前面学过的所有统计知识）：

1. **单因子ANOVA分析**：
   - 对修复方法数据进行完整的ANOVA分析
   - 检验所有前提假设（正态性、方差齐性）
   - 计算效应大小并解释其意义
   - 进行适当的多重比较

2. **双因子ANOVA分析**：
   - 分析修复方法和季节的主效应及交互作用
   - 可视化交互作用模式
   - 如果交互作用显著，进行简单效应分析
   - 进行模型诊断

3. **非参数替代分析**：
   - 对偏斜数据进行Kruskal-Wallis检验
   - 与参数ANOVA结果比较
   - 进行适当的事后比较

4. **效应大小与实际意义**：
   - 计算不同类型的效应大小指标
   - 评估统计显著性与实际意义的关系
   - 计算各组差异的置信区间

5. **数据可视化**：
   - 创建专业的箱线图和交互作用图
   - 可视化多重比较结果
   - 制作综合性的结果展示图

6. **结果报告**：
   - 按照学术标准报告ANOVA结果
   - 包括适当的统计量、效应大小和置信区间
   - 从生态学角度解释结果的实际意义

7. **方法选择与局限性讨论**：
   - 讨论何时选择参数vs非参数方法
   - 分析当前研究设计的局限性
   - 提出改进建议

