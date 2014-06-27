## R script for model with all inputs
## Data: https://modeanalytics.com/benn/reports/72c16eaaeefc

tracts <- read.csv("model_inputs.csv")

##  By white population percent 
full <- lm(trips ~ median_income + population + white_percent + distance_in_miles,data=tracts)
summary(full)

##  Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
##  (Intercept)        1.204e+04  2.149e+03   5.600 5.69e-08 ***
##  median_income      6.346e-02  2.006e-02   3.163  0.00176 ** 
##  population        -7.785e-02  1.728e-01  -0.450  0.65282    
##  white_percent      4.748e+03  3.244e+03   1.464  0.14455    
##  distance_in_miles -2.840e+03  3.126e+02  -9.084  < 2e-16 ***
##  ---
##  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
##  
##  Residual standard error: 7664 on 247 degrees of freedom
##  Multiple R-squared:  0.5496,	Adjusted R-squared:  0.5423 
##  F-statistic: 75.35 on 4 and 247 DF,  p-value: < 2.2e-16


##  By black population percent
black_only <- lm(trips ~ median_income + population + black_percent + distance_in_miles,data=tracts)
summary(black_only)

##  Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
##  (Intercept)        1.579e+04  2.199e+03   7.180 8.17e-12 ***
##  median_income      6.815e-02  1.515e-02   4.498 1.05e-05 ***
##  population        -1.101e-01  1.716e-01  -0.641   0.5218    
##  black_percent     -6.943e+03  2.858e+03  -2.429   0.0158 *  
##  distance_in_miles -2.868e+03  2.987e+02  -9.601  < 2e-16 ***
##  ---
##  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
##  
##  Residual standard error: 7607 on 247 degrees of freedom
##  Multiple R-squared:  0.5563,	Adjusted R-squared:  0.5491 
##  F-statistic: 77.42 on 4 and 247 DF,  p-value: < 2.2e-16


##  With nightime trips as dependent varible
after_8 <- lm(after_8_trips ~ median_income + population + white_percent + distance_in_miles,data=tracts)
summary(after_8)

##  Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
##  (Intercept)        4.991e+03  8.641e+02   5.776 2.29e-08 ***
##  median_income     -2.320e-03  8.065e-03  -0.288   0.7739    
##  population        -7.622e-02  6.949e-02  -1.097   0.2738    
##  white_percent      2.950e+03  1.304e+03   2.262   0.0246 *  
##  distance_in_miles -9.634e+02  1.257e+02  -7.666 4.06e-13 ***
##  ---
##  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
##  
##  Residual standard error: 3081 on 247 degrees of freedom
##  Multiple R-squared:  0.3827,	Adjusted R-squared:  0.3727 
##  F-statistic: 38.28 on 4 and 247 DF,  p-value: < 2.2e-16


##  With nightime trips as dependent varible, by black population ony
after_8_black_only <- lm(after_8_trips ~ median_income + population + black_percent + distance_in_miles,data=tracts)
summary(after_8_black_only)

##  Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
##  (Intercept)        7.188e+03  8.790e+02   8.177 1.53e-14 ***
##  median_income      1.510e-03  6.055e-03   0.249 0.803301    
##  population        -9.184e-02  6.859e-02  -1.339 0.181815    
##  black_percent     -3.937e+03  1.142e+03  -3.447 0.000667 ***
##  distance_in_miles -9.869e+02  1.194e+02  -8.266 8.56e-15 ***
##  ---
##  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
##  
##  Residual standard error: 3041 on 247 degrees of freedom
##  Multiple R-squared:  0.3988,	Adjusted R-squared:  0.3891 
##  