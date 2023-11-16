dd# Frisch Waugh Lovell by hand 
# Thelonious Goerz 
# 9/4/23

set.seed(100)


# Create DGP
x1 = rnorm(100)
x2 = rnorm(100)
y1 = 1 + x1 - x2 + rnorm(100)

# Target: b1

# 1. Regress y on x2
r1 = residuals(lm(y1 ~ x2))
# 2. Regress x1 on x2
r2 = residuals(lm(x1 ~ x2))

# ols
coef(lm(y1 ~ x1 + x2))


# fwl ols
# Remove intercept
plot(fitted(lm(r1 ~ -1 + r2)))

