fishFoodMWD
================
2023-08-17

<img src="man/figures/logo.png" align="right" alt="fishFoodMWD" style="height: 139px; margin: 10px"/>

The R package **fishFoodMWD** provides access to… lorem ipsum dolor sit
amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut
labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum
dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum

# Installation

Install the latest development version of **fishFoodMWD** from GitHub:

``` r
if (!require("devtools")) {
  install.packages("devtools")
}
devtools::install_github("FlowWest/fishFoodMWD")
```

# Getting started

Once the package is installed, call the package library to load all the
datasets and access all the calculation and plotting functions.

``` r
library(fishFoodMWD)
```

The names of all the provided datasets and functions are prefixed with
`ff_` for clarity. Use the **[Reference](reference/index.html)** section
of this website to access documentation of all these datasets and
functions.

The following articles dive into greater depth on the R package
functionality and usage.

- [Calculation Functions](articles/calcs.html)
- [Data Structures and Joins](articles/joins.html)
- [Static Maps and Plots](articles/plot.html)

The following articles explore the underlying assumptions and modeling
process behind our results.

- [Modeling Approach and Methods](articles/model.html)
