Mixed-Effects Models
========================================================
author: Guochun Shen
date: Wed May 28 15:57:31 2014

Two types of categorical explanatory variables
========================================================

Up to this point, we have treated all ategorical explanatory variables as if they were the same (e.g. analysis of variance).

Eisenhart (1947) realized that there are actually two fundamentally different sorts of categorical explanatory variables:

- __fixed effects__
- __random effects__

Fixed effects & Random effects
========================================================

Statistical explanation:

- fixed effects: influence only the __mean__ of y;
- random effects: influence only the __variance__ of y;

Typical model:
$$y=\alpha + \beta x + \epsilon, \epsilon \implies  N(0,\delta^2)$$

Mixed effect model
$$y=\alpha + \beta x + Z \zeta + \epsilon$$
$$\zeta \implies  N(0,\theta^2)$$
$$\epsilon \implies  N(0,\delta^2)$$


Fixed effects & Random effects
========================================================

Ecological explanation:

- fixed effects: have informative factor levels (e.g. male/female, upland/lowland,Nutrient added or not);
- random effecst: often have uninformative factor levels (Genotype, block within a field,split plot within a plot,individuals with repeated measures);

Random effects
========================================================

Sources of random effects:

- observational studies with hierarchical structure;
- designed experiments with different spatial or temporal scales.


Random effects
========================================================

Random effects have factor levels that are drawn from a large population in which the individuals differ in many ways, but we do not know exactly how or why they differ.

Therefore, there is not much point in concentrating on estimating means of our small subset of factor levels, and no point at all in comparing individual pairs of means for different factor levels.

Random effects
========================================================

This is the _added_ variation caused by differences between the levels of the random effects.

variance component analysis is used to work out percentage contribution of a random effect to the overal variaiton.

Example
=============================================================

The following example refers to a designed field experiment on crop yield with three treatments: irrigation (with two levels, irrigated or not), sowing density (with three levels, low, medium and high) and fertilizer (with three levels, N, P and NP) application.

```r
yields=read.table("./data/splityield.txt",header=T)
attach(yields)
names(yields)
```

```
[1] "yield"      "block"      "irrigation" "density"    "fertilizer"
```


Example
=============================================================


```r
library(nlme)
model.lme=lme(yield~irrigation*density*fertilizer, random=~1|block/irrigation/density,method="ML")
#summary(model.lme)
model.lme.2=update(model.lme,~.-irrigation:density:fertilizer)
anova(model.lme,model.lme.2)
```

```
            Model df   AIC   BIC logLik   Test L.Ratio p-value
model.lme       1 22 573.5 623.6 -264.8                       
model.lme.2     2 18 569.0 610.0 -266.5 1 vs 2   3.494  0.4788
```


Example
=============================================================


```r
#summary(model.lme.2)
model.lme.3=update(model.lme.2,~.-density:fertilizer)
anova(model.lme.3,model.lme.2)
```

```
            Model df   AIC   BIC logLik   Test L.Ratio p-value
model.lme.3     1 14 565.2 597.1 -268.6                       
model.lme.2     2 18 569.0 610.0 -266.5 1 vs 2   4.189  0.3811
```

```r
#summary(model.lme.3)
```


Example
=============================================================


```r
model.lme.4=update(model.lme.3,~.-irrigation:fertilizer)
anova(model.lme.4,model.lme.3)
```

```
            Model df   AIC   BIC logLik   Test L.Ratio p-value
model.lme.4     1 12 572.3 599.7 -274.2                       
model.lme.3     2 14 565.2 597.1 -268.6 1 vs 2   11.14  0.0038
```



Example
=============================================================


```r
model.lme.5=update(model.lme.3,~.-irrigation:density)
anova(model.lme.5,model.lme.3)
```

```
            Model df   AIC   BIC logLik   Test L.Ratio p-value
model.lme.5     1 12 572.9 600.2 -274.4                       
model.lme.3     2 14 565.2 597.1 -268.6 1 vs 2   11.71  0.0029
```


Example
============================================================

compare with simple analysis of variance model

```r
model.simple=aov(yield~irrigation*density*fertilizer-irrigation:density:fertilizer-density:fertilizer+Error(block/irrigation/density))
summary(model.simple)
```

```

Error: block
          Df Sum Sq Mean Sq F value Pr(>F)
Residuals  3    194    64.8               

Error: block:irrigation
           Df Sum Sq Mean Sq F value Pr(>F)  
irrigation  1   8278    8278    17.6  0.025 *
Residuals   3   1412     471                 
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Error: block:irrigation:density
                   Df Sum Sq Mean Sq F value Pr(>F)  
density             2   1758     879    3.78  0.053 .
irrigation:density  2   2747    1374    5.91  0.016 *
Residuals          12   2788     232                 
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Error: Within
                      Df Sum Sq Mean Sq F value  Pr(>F)    
fertilizer             2   1977     989   11.92 7.3e-05 ***
irrigation:fertilizer  2    953     477    5.75  0.0061 ** 
Residuals             44   3648      83                    
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```


Example
============================================================

variance component analysis 


