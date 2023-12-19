params <-
list(EVAL = TRUE)

## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = params$EVAL
)

## ----include = FALSE----------------------------------------------------------
# Make sure cmdstanr is all set up. But we don't need to show the reader this.
cmdstanr::check_cmdstan_toolchain(fix = TRUE)
cmdstanr::install_cmdstan()

## ----results='markup', comment='', echo=FALSE---------------------------------
cat(readLines("getting_started.stan"), sep = "\n")

## -----------------------------------------------------------------------------
library(cmdstanr)
library(gptoolsStan)

model <- cmdstan_model(
  stan_file="getting_started.stan",
  include_paths=gptools_include_path(),
)

## -----------------------------------------------------------------------------
n <- 100
length_scale <- n / 10
freq <- 1:(n %/% 2 + 1) - 1
# See appendix B of https://arxiv.org/abs/2301.08836 for details on the expression.
cov_rfft <- exp(- 2 * (pi * freq * length_scale / n) ^ 2) + 1e-9

## -----------------------------------------------------------------------------
fit <- model$sample(
  data=list(n=n, cov_rfft=cov_rfft),
  seed=123,
  chains=1,
  iter_warmup=1000,
  iter_sampling=5,
)

## ----fig.width=6, fig.height=5------------------------------------------------
f <- fit$draws("f", format="draws_matrix")
plot(1:n, f[1,], type="l", xlab="covariate x", ylab="Gaussian process f(x)")

