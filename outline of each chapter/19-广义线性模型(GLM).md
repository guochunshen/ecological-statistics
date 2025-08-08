## 第19课：广义线性模型（GLM）

### 生态学背景
在生态学研究中，许多响应变量并不符合正态分布假设。例如，物种个体计数数据通常服从泊松分布，物种出现/缺失数据服从二项分布，存活时间数据服从指数分布。传统的线性回归要求响应变量服从正态分布，这限制了其在处理这类数据时的应用。广义线性模型（GLM）通过引入连接函数和指数族分布，扩展了线性模型的适用范围，使我们能够直接对非正态分布的生态数据进行建模分析。

### 演示数据
```r
# 生态学中常见的非正态分布数据
set.seed(123)

# 1. 计数数据：某保护区样方中鸟类个体数
bird_count_data <- data.frame(
  plot_id = paste0("P", sprintf("%02d", 1:60)),
  habitat_type = rep(c("森林", "灌丛", "草地"), each = 20),
  elevation = c(rnorm(20, 1200, 200), rnorm(20, 800, 150), rnorm(20, 500, 100)),
  canopy_cover = c(rnorm(20, 80, 10), rnorm(20, 40, 15), rnorm(20, 10, 5)),
  # 鸟类个体数（泊松分布）
  bird_count = c(rpois(20, 12), rpois(20, 8), rpois(20, 5))
)

# 2. 二项数据：种子萌发试验
germination_data <- data.frame(
  treatment = rep(c("对照", "低温", "高温", "干旱"), each = 15),
  temperature = rep(c(20, 5, 35, 20), each = 15),
  moisture = rep(c(80, 80, 80, 30), each = 15),
  seeds_total = rep(50, 60),  # 总种子数
  # 萌发种子数（二项分布）
  seeds_germinated = c(
    rbinom(15, 50, 0.7),   # 对照组
    rbinom(15, 50, 0.4),   # 低温组  
    rbinom(15, 50, 0.3),   # 高温组
    rbinom(15, 50, 0.2)    # 干旱组
  )
)

# 计算萌发率
germination_data$germination_rate <- germination_data$seeds_germinated / germination_data$seeds_total
```

### 课堂演示过程

#### 1. 泊松回归（计数数据）
```r
# 创建鸟类计数数据
set.seed(123)
bird_data <- data.frame(
  habitat = rep(c("forest", "shrub", "grassland"), each = 20),
  elevation = c(rnorm(20, 1200, 100), rnorm(20, 800, 80), rnorm(20, 400, 60)),
  count = c(rpois(20, lambda = 8), rpois(20, lambda = 5), rpois(20, lambda = 3))
)

# 1. 探索性数据分析
tapply(bird_data$count, bird_data$habitat, summary)
hist(bird_data$count, breaks = 10, main = "鸟类个体数分布")

# 检查均值和方差关系（泊松分布特征）
aggregate(count ~ habitat, bird_data, function(x) c(mean = mean(x), var = var(x)))

# 2. 泊松回归建模
poisson_model <- glm(count ~ habitat + elevation, 
                    data = bird_data, 
                    family = poisson(link = "log"))

summary(poisson_model)

# 3. 模型系数解释
# 对数尺度的系数
coef(poisson_model)

# 原始尺度的系数（比率）
exp(coef(poisson_model))

# 4. 模型预测
new_data <- data.frame(
  habitat = c("forest", "shrub", "grassland"),
  elevation = c(1000, 800, 600)
)

predictions <- predict(poisson_model, new_data, type = "response")
print(predictions)

# 置信区间
conf_intervals <- predict(poisson_model, new_data, 
                         type = "link", se.fit = TRUE)
lower <- exp(conf_intervals$fit - 1.96 * conf_intervals$se.fit)
upper <- exp(conf_intervals$fit + 1.96 * conf_intervals$se.fit)
cbind(predictions, lower, upper)
```

#### 2. 逻辑回归（二项数据）
```r
# 创建种子萌发数据
set.seed(123)
germination_data <- data.frame(
  temperature = rep(c(15, 20, 25, 30), each = 15),
  moisture = rnorm(60, 70, 10),
  success = rbinom(60, 1, prob = plogis(-3 + 0.1*rep(c(15, 20, 25, 30), each = 15) + 
                                       0.02*rnorm(60, 70, 10)))
)

# 1. 逻辑回归建模
logistic_model <- glm(success ~ temperature + moisture, 
                     data = germination_data,
                     family = binomial(link = "logit"))

summary(logistic_model)

# 2. 优势比（Odds Ratio）
exp(coef(logistic_model))

# 3. 模型拟合度评估
# 偏差（Deviance）
print(paste("Null Deviance:", round(logistic_model$null.deviance, 2)))
print(paste("Residual Deviance:", round(logistic_model$deviance, 2)))

# 伪R²
pseudo_r2 <- 1 - (logistic_model$deviance / logistic_model$null.deviance)
print(paste("McFadden's R²:", round(pseudo_r2, 3)))

# 4. 预测概率
new_conditions <- data.frame(
  temperature = c(18, 22, 28),
  moisture = c(60, 70, 80)
)

predicted_probs <- predict(logistic_model, new_conditions, type = "response")
print(predicted_probs)

# 5. 可视化
temperature_seq <- seq(15, 30, length.out = 100)
pred_data <- data.frame(
  temperature = temperature_seq,
  moisture = 70  # 固定湿度
)

pred_probs <- predict(logistic_model, pred_data, type = "response")

plot(temperature_seq, pred_probs, type = "l", 
     xlab = "温度 (°C)", ylab = "萌发概率",
     main = "温度对种子萌发概率的影响")
points(germination_data$temperature, germination_data$success, 
       col = "red", pch = 16, alpha = 0.6)
```

#### 3. 模型诊断
```r
# 1. 泊松回归诊断
# 过度离散检验
# 计算离散参数
residual_deviance <- poisson_model$deviance
df_residual <- poisson_model$df.residual
dispersion_param <- residual_deviance / df_residual
print(paste("离散参数:", round(dispersion_param, 3)))

# 如果离散参数远大于1，说明存在过度离散
if(dispersion_param > 1.5) {
  # 使用准泊松模型
  quasi_poisson_model <- glm(count ~ habitat + elevation, 
                            data = bird_data, 
                            family = quasipoisson(link = "log"))
  summary(quasi_poisson_model)
}

# 2. 残差分析
par(mfrow = c(2, 2))

# 偏差残差vs拟合值
plot(fitted(poisson_model), residuals(poisson_model, type = "deviance"),
     xlab = "拟合值", ylab = "偏差残差",
     main = "偏差残差vs拟合值")
abline(h = 0, col = "red", lty = 2)

# Q-Q图
qqnorm(residuals(poisson_model, type = "deviance"), main = "Q-Q图")
qqline(residuals(poisson_model, type = "deviance"))

# Cook距离
plot(cooks.distance(poisson_model), type = "h", 
     ylab = "Cook距离", main = "影响点分析")

# 杠杆值
plot(hatvalues(poisson_model), type = "h",
     ylab = "杠杆值", main = "杠杆点分析")

par(mfrow = c(1, 1))

# 3. 逻辑回归诊断
# Hosmer-Lemeshow拟合优度检验
library(ResourceSelection)
hl_test <- hoslem.test(germination_data$success, 
                      fitted(logistic_model), g = 6)
print(hl_test)

# ROC曲线和AUC
library(pROC)
roc_obj <- roc(germination_data$success, fitted(logistic_model))
auc_value <- auc(roc_obj)
print(paste("AUC:", round(auc_value, 3)))

plot(roc_obj, main = paste("ROC曲线 (AUC =", round(auc_value, 3), ")"))
```

### R语言知识点详解

#### 1. 广义线性模型框架

##### GLM三要素
1. **随机部分**：响应变量Y服从指数族分布
2. **系统部分**：线性预测子η = Xβ  
3. **连接函数**：g(μ) = η，连接均值μ和线性预测子η

##### 指数族分布
- **正态分布**：连续数据，identity连接函数
- **泊松分布**：计数数据，log连接函数
- **二项分布**：比例数据，logit连接函数
- **Gamma分布**：正偏斜连续数据，inverse连接函数

##### `glm()` 函数语法
- **基本语法**：`glm(formula, family, data, weights, subset)`
- **family参数**：
  - `gaussian(link = "identity")`：正态分布
  - `poisson(link = "log")`：泊松分布
  - `binomial(link = "logit")`：二项分布
  - `Gamma(link = "inverse")`：Gamma分布

#### 2. 泊松回归详解

##### 适用场景
- **计数数据**：非负整数
- **事件发生次数**：固定时间或空间内的事件数
- **稀有事件**：平均发生率较低的事件

##### 模型假设
- **泊松分布**：E(Y|X) = Var(Y|X) = μ
- **对数连接**：log(μ) = Xβ
- **独立性**：观测值相互独立
- **线性关系**：log(μ)与预测变量线性相关

##### 系数解释
- **对数尺度**：βᵢ表示Xᵢ增加1单位时log(μ)的变化
- **原始尺度**：exp(βᵢ)表示Xᵢ增加1单位时μ的乘数效应

##### 过度离散问题
- **定义**：实际方差大于泊松分布假设的方差
- **检验**：离散参数 = 残差偏差/自由度 > 1
- **处理**：使用准泊松模型或负二项模型

#### 3. 逻辑回归详解

##### 适用场景
- **二分类结果**：成功/失败、存在/缺失
- **比例数据**：成功次数/总次数
- **概率建模**：预测事件发生概率

##### 逻辑函数
- **Logit函数**：logit(p) = log(p/(1-p)) = Xβ
- **逆函数**：p = exp(Xβ)/(1 + exp(Xβ))
- **S形曲线**：输出值在0和1之间

##### 优势比解释
- **优势**：Odds = p/(1-p)
- **优势比**：OR = exp(βᵢ)
- **解释**：Xᵢ增加1单位时，成功的优势变为原来的exp(βᵢ)倍

#### 4. 模型评估方法

##### 拟合度评估
- **偏差（Deviance）**：
  - 残差偏差：衡量模型拟合度
  - 空偏差：仅含截距模型的偏差
  - 偏差减少量：模型改进程度
- **AIC/BIC**：模型比较准则
- **伪R²**：McFadden's R² = 1 - (残差偏差/空偏差)

##### 预测评估
- **泊松回归**：
  - 均方误差(MSE)
  - 平均绝对误差(MAE)
- **逻辑回归**：
  - 分类准确率
  - 灵敏度和特异性
  - ROC曲线和AUC
  - Hosmer-Lemeshow检验

#### 5. 高级GLM主题

##### 连接函数选择
- **标准连接**：每个分布族的典型连接函数
- **其他连接**：
  - 二项分布：probit, cloglog
  - 泊松分布：identity, sqrt
- **连接函数比较**：基于AIC和残差分析

##### 模型扩展
- **准似然模型**：处理过度离散
- **负二项回归**：泊松回归的替代
- **Beta回归**：比例数据的专门模型
- **零膨胀模型**：处理过多零值的计数数据

##### 贝叶斯GLM
- **先验分布**：系数的先验信息
- **MCMC采样**：后验分布估计
- **模型平均**：多模型不确定性

### 课后练习

**题目1**：某湿地鸟类调查计数数据：
```r
wetland_birds <- data.frame(
  site_id = paste0("W", 1:48),
  habitat_quality = rep(c("优", "良", "中", "差"), each = 12),
  water_depth = c(rnorm(12, 80, 15), rnorm(12, 60, 12), 
                 rnorm(12, 40, 10), rnorm(12, 20, 8)),
  vegetation_cover = c(rnorm(12, 70, 10), rnorm(12, 60, 8), 
                      rnorm(12, 45, 12), rnorm(12, 30, 15)),
  bird_species_count = c(rpois(12, 15), rpois(12, 10), 
                        rpois(12, 6), rpois(12, 3))
)
```

**题目2**：植物病害感染试验数据：
```r
plant_disease <- data.frame(
  plot_id = paste0("Plot", 1:80),
  temperature = rnorm(80, 25, 5),
  humidity = rnorm(80, 75, 15), 
  fertilizer = rep(c("无", "低", "中", "高"), each = 20),
  plants_total = rep(100, 80),
  plants_infected = c(rbinom(20, 100, 0.1), rbinom(20, 100, 0.15),
                     rbinom(20, 100, 0.25), rbinom(20, 100, 0.4))
)
```

请完成以下GLM分析：

1. **泊松回归分析**（使用题目1数据）：
   - 建立鸟类物种数的泊松回归模型
   - 检验过度离散现象
   - 解释各变量的生态学意义
   - 进行模型预测和可视化

2. **逻辑回归分析**（使用题目2数据）：
   - 建立植物感染概率的逻辑回归模型
   - 计算各变量的优势比
   - 评估模型预测性能（AUC、准确率等）
   - 绘制ROC曲线

3. **模型诊断**：
   - 对两个模型进行残差分析
   - 检查模型假设
   - 识别异常值和影响点

4. **模型比较与选择**：
   - 比较不同连接函数的效果
   - 使用AIC进行模型选择
   - 进行嵌套模型检验

5. **结果解释与应用**：
   - 从生态学角度解释模型结果
   - 讨论GLM相比线性回归的优势
   - 提出研究结果的管理应用建议