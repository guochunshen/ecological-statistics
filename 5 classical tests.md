Classical Tests
========================================================
author: Guochun Shen
date: Mon Mar 24 19:25:23 2014

Occam's razor
========================================================

There is absolutely no point in carring out an analysis that is __more complicated than it needs to be__.

Simplest is best.

Single Samples
========================================================

Typical qestions about inference from the data:
- what is the mean value?
- is the mean value significantly different from current expectation or theory?
- what is the level of uncertainty associated with our estimate of the mean value?

Single Samples
=======================================================

In order to be reasonably confident that our inferences are correct, we need to establish some facts about the distribution of the data:
- Are the values normally distributed or not?
- Are there outliers in the data?
- If data were collected over a period of time, is there evidence for serial correlation?

Data summary
========================================================


```r
par(mfrow=c(2,2))
y=rnorm(100)
plot(y)
boxplot(y)
hist(y,main="")
y2=y
y2[101]=20
plot(y2)
```


***

![plot of chunk unnamed-chunk-2](5_classical_tests-figure/unnamed-chunk-2.png) 


Data summary
=============================================


```r
summary(y)
```

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
-2.9100 -0.6200 -0.0122  0.0183  0.7000  2.5400 
```



```r
qqnorm(y)
qqline(y,lty=2)
```

***

![plot of chunk unnamed-chunk-5](5_classical_tests-figure/unnamed-chunk-5.png) 


Test for normality
=============================================

Shapiro-Wilk Normality Test

```r
shapiro.test(y)
```

```

	Shapiro-Wilk normality test

data:  y
W = 0.987, p-value = 0.4358
```


***


```r
x=exp(rnorm(30))
shapiro.test(x)
```

```

	Shapiro-Wilk normality test

data:  x
W = 0.8178, p-value = 0.0001411
```



Test the mean against expectation
================================================


```r
x=1+rnorm(100)
```

Does the mean of x significantly different with 0?


Test the mean against expectation
================================================

__Student's t-Test__

```r
t.test(x,mu=0)
```

```

	One Sample t-test

data:  x
t = 8.559, df = 99, p-value = 1.497e-13
alternative hypothesis: true mean is not equal to 0
95 percent confidence interval:
 0.6866 1.1009
sample estimates:
mean of x 
   0.8938 
```


Test the mean against expectation
================================================


```r
y=1+log(rnorm(100))
```

Does the mean of y significantly different with 1?

Test the mean against expectation
================================================

When distribution of the data/error is non-normality:  
__Wilcoxon Signed Rank Test__

```r
wilcox.test(y,mu=1)
```

```

	Wilcoxon signed rank test with continuity correction

data:  y
V = 256, p-value = 8.191e-05
alternative hypothesis: true location is not equal to 1
```


Two samples
================================================

The classical tests for two samples includes:
- comparing two variances (Fisher's _F_)
- comparing two sample means with normal errors (Student's t test)
- comparing two means with non-normal errors (Wilcoxon's rank test)
- comparing two proportions (the binomial test)
- correlating two variables (Pearson's or Spearman's rank correlation)
- testing for independence of two variables in a contingency table (chi-squared)

Comparing two variances- Fisher's F test
===============================================


```r
x=rnorm(100,mean=1,sd=2)
y=rnorm(89,mean=0,sd=10)
var.test(x,y)
```

```

	F test to compare two variances

data:  x and y
F = 0.0329, num df = 99, denom df = 88, p-value < 2.2e-16
alternative hypothesis: true ratio of variances is not equal to 1
95 percent confidence interval:
 0.02181 0.04938
sample estimates:
ratio of variances 
            0.0329 
```


Comparing two variances-Fligner-Killeen test
==============================================

it is a non-parametric test, insensitive to outliers. 


```r
y=c(x,y)
g=as.factor(rep(c("x","y"),c(100,89)))
fligner.test(y~g)
```

```

	Fligner-Killeen test of homogeneity of variances

data:  y by g
Fligner-Killeen:med chi-squared = 78.79, df = 1, p-value < 2.2e-16
```


Comparing two means- Student's t test
==============================================

