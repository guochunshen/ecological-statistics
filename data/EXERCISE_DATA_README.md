# 05-correlation.Rmd 综合练习配套数据说明

## 数据文件说明

### 1. exercise1_forest_data.RData
**练习一：森林生态系统多变量相关性分析**
- `forest_data`: 数据框，40个森林样地的多变量数据
- 变量说明：
  - `plot_id`: 样地编号 (1-40)
  - `dbh_cm`: 树木胸径 (厘米)
  - `height_m`: 树高 (米)
  - `stand_density`: 林分密度 (株/公顷)
  - `soil_pH`: 土壤pH值
  - `soil_organic_percent`: 土壤有机质含量 (%)
  - `light_intensity_percent`: 林下光照强度 (%)

### 2. exercise2_bird_data.RData
**练习二：鸟类种群时间序列与空间格局分析**
- `bird_time_series`: 矩阵，10种鸟类15年的种群数量
  - 行：年份 (2005-2019)
  - 列：物种 (species1-species10)
  - 重点关注物种：
    - species1: 稳定型（种群波动小）
    - species2: 增长型（种群总体增长）
    - species3: 周期型（有周期性波动）
- `spatial_data`: 数据框，50个观测点的空间数据
  - `site_id`: 观测点编号
  - `x_coord`: 东向坐标
  - `y_coord`: 北向坐标
  - `bird_richness`: 鸟类丰富度
- `years`: 年份向量 (2005-2019)

### 3. exercise3_plant_data.RData
**练习三：植物功能性状与系统发育相关性分析**
- `phy_tree`: 系统发育树对象，30个木本植物的进化关系
- `trait_data`: 数据框，30个物种的功能性状数据
  - `species`: 物种名称 (species01-species30)
  - `SLA_cm2_g`: 比叶面积 (cm²/g)
  - `leaf_nitrogen_percent`: 叶片氮含量 (%)
  - `photosynthesis_umol_m2_s`: 光合速率 (μmol/m²/s)
  - `wood_density_g_cm3`: 木材密度 (g/cm³)
  - `max_height_m`: 最大树高 (米)

## 使用说明

1. 加载数据：
```r
# 练习一数据
load("data/exercise1_forest_data.RData")

# 练习二数据
load("data/exercise2_bird_data.RData")

# 练习三数据
load("data/exercise3_plant_data.RData")
```

2. 数据已设置随机种子，确保结果可重现。

3. 数据模拟时考虑了生态学合理性，变量间存在预期的相关关系。

## 生成时间
2025-12-31

## 生成工具
R脚本 generate_exercise_data.R

