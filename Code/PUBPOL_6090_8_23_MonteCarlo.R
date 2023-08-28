# PUBPOL 6090 
# Monte Carlo Demonstration 
# 8/28/23
# Thelonious Georz 
# %%%%%%%%%%%%%%%%%%%%%%%%%%

# Load required libraries
library(sandwich)
library(lmtest)
library(tidyverse)

set.seed(123)  # Set seed for reproducibility

# Define the onesample function
onesample <- function(n){
  # Generate data
  x <- rnorm(n)
  eps <- rnorm(n) * sqrt(exp(x))
  y <- 2 + 1 * x + eps
  
  # Estimate the model
  model <- lm(y ~ x)
  beta <- coef(model)["x"]
  stderr <- summary(model)$coefficients[2,2]
  
  model_robust <- coeftest(model, vcov = vcovHC(model, type = "HC0"))
  beta_r <- model_robust[2, "Estimate"]
  stderr_r <- model_robust[2, "Std. Error"]
  
  return(data.frame(beta, stderr, beta_r, stderr_r))
}

# Run onesample once as a check
result_check <- onesample(n = 200)
print(result_check)

# Run onesample 1000 times
set.seed(4553)
n_simulations <- 1000
sim_results <- data.frame(beta = c(), stderr = c(),
                          beta_r = c(), stderr_r = c())
  
for (i in 1:1000){
  samp <- onesample(200)
  sim_results[i,"beta"] = samp$beta
              
  sim_results[i, "stderr"] = samp$stderr
  
  sim_results[i,"beta_r"]= samp$beta_r
              
  sim_results[i, "stderr_r"] = samp$stderr_r
}

# Summarize the results

sim_results %>% summarize(
  beta_est = mean(beta),
  se = mean(stderr),
  reject = mean(abs(beta - 1) / stderr > 1.96)
)


sim_results %>% summarize(
  beta_est = mean(beta_r),
  se = mean(stderr_r),
  reject = mean(abs(beta_r - 1) / stderr_r > 1.96)
)
# With the Robust SE, we see that we are rejecting the null closer to .05 compared to the non-robust SEs, which we reject about .15. 

