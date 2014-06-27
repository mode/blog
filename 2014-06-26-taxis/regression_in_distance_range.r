## R script for model with all inputs
## Data: https://modeanalytics.com/benn/reports/72c16eaaeefc

tracts <- read.csv("model_inputs.csv")
trim_tracts <- subset(tracts, distance_in_miles >= 3)
trim_tracts <- subset(trim_tracts, distance_in_miles <= 4)

##  By white population percent 
full <- lm(trips ~ median_income + population + white_percent + distance_in_miles,data=trim_tracts)
summary(full)

##  Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
##  (Intercept)       -654.57923 5803.44673  -0.113    0.911    
##  median_income        0.10032    0.01571   6.386 2.41e-07 ***
##  population           0.23538    0.16398   1.435    0.160    
##  white_percent      498.61848 2576.73840   0.194    0.848    
##  distance_in_miles -829.45905 1573.32651  -0.527    0.601    
##  ---
##  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
##  
##  Residual standard error: 2599 on 35 degrees of freedom
##  Multiple R-squared:  0.7304,	Adjusted R-squared:  0.6996 
##  F-statistic: 23.71 on 4 and 35 DF,  p-value: 1.501e-09


##  By black population percent
black_only <- lm(trips ~ median_income + population + black_percent + distance_in_miles,data=trim_tracts)
summary(black_only)

##  Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
##  (Intercept)       -1.287e+03  5.765e+03  -0.223    0.825    
##  median_income      9.784e-02  1.163e-02   8.409 6.41e-10 ***
##  population         2.355e-01  1.621e-01   1.453    0.155    
##  black_percent     -1.938e+03  2.107e+03  -0.920    0.364    
##  distance_in_miles -4.121e+02  1.623e+03  -0.254    0.801    
##  ---
##  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
##  
##  Residual standard error: 2570 on 35 degrees of freedom
##  Multiple R-squared:  0.7365,	Adjusted R-squared:  0.7064 
##  F-statistic: 24.46 on 4 and 35 DF,  p-value: 1.015e-09


##  With nightime trips as dependent varible
after_8 <- lm(after_8_trips ~ median_income + population + white_percent + distance_in_miles,data=trim_tracts)
summary(after_8)

##  Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
##  (Intercept)        1.083e+03  1.812e+03   0.598    0.554    
##  median_income      3.059e-02  4.905e-03   6.236 3.78e-07 ***
##  population         5.583e-02  5.119e-02   1.091    0.283    
##  white_percent     -4.654e+02  8.045e+02  -0.579    0.567    
##  distance_in_miles -5.498e+02  4.912e+02  -1.119    0.271    
##  ---
##  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
##  
##  Residual standard error: 811.5 on 35 degrees of freedom
##  Multiple R-squared:  0.6857,	Adjusted R-squared:  0.6498 
##  F-statistic: 19.09 on 4 and 35 DF,  p-value: 2.08e-08


##  With nightime trips as dependent varible
after_8_black_only <- lm(after_8_trips ~ median_income + population + black_percent + distance_in_miles,data=trim_tracts)
summary(after_8_black_only)

##  Coefficients:
##                      Estimate Std. Error t value Pr(>|t|)    
##  (Intercept)        8.294e+02  1.821e+03   0.456    0.652    
##  median_income      2.756e-02  3.675e-03   7.501 8.73e-09 ***
##  population         5.658e-02  5.119e-02   1.105    0.277    
##  black_percent     -3.785e+02  6.655e+02  -0.569    0.573    
##  distance_in_miles -4.579e+02  5.124e+02  -0.894    0.378    
##  ---
##  Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
##  
##  Residual standard error: 811.6 on 35 degrees of freedom
##  Multiple R-squared:  0.6856,	Adjusted R-squared:  0.6496 
##  F-statistic: 19.08 on 4 and 35 DF,  p-value: 2.091e-08