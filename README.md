fishFoodMWD
================

<img src="man/figures/logo.png" align="right" alt="fishFoodMWD" style="height: 139px; margin: 24px"/>

***A spatial database for salmonid rearing on Sacramento Valley rice
fields***

Substantial recent research has demonstrated the food production
benefits of floodplain inundation can increase growth and survival of
rearing juvenile salmonids (see Goertler et al 2018, Katz et al 2017,
Jeffres 2006, Grosholz and Gallo 2005). Approximately 500,000 acres of
rice fields have the potential to produce food (phytoplankton and
zooplankton) that can be delivered to the Delta, the Sacramento River,
and their contributing watersheds to benefit juvenile salmon and other
native fish.

Detailed data on rice field drainage conveyance systems that move water
between farm fields and the Delta and its watershed is essential to
scale up fish food production management actions. This project—a
collaborative effort between FlowWest, RD108, the California Rice
Commission, the Metropolitan Water District of Southern California, and
CalTrout—addresses the significant information gap around the system of
natural channels, canals, and structures that move flows (and in some
cases fish) to and from these fields.

FlowWest assembled a quantitative spatial database of the Sacramento
Valley rice field drainage system, mapping and calculating drainage
system characteristics influencing suitability for fish food production
and/or delivery, such as:

- the locations of outflows from arterial canals into fish-bearing
  streams
- groupings of rice fields by their outflow location
- distance from rice fields to their flow delivery site and the nearest
  fish-bearing stream
- estimated invertebrate food mass production based on rice field
  acreage

The R package **fishFoodMWD**, and this accompanying website, provides
access to the resulting spatial database. Results, including the
distances and relationships between rice fields and their connected
canals and rivers, can be explored and filtered using the [**interactive
map**](https://flowwest.shinyapps.io/fishFoodMWD) on this website. The
datasets and accompanying plotting and calculation functions can be
accessed directly by installing the R package. Datasets are also
available in standard GIS (shapefile) format.

# Installation

Install the latest development version of **fishFoodMWD** from GitHub:

``` r
remotes::install_github("flowwest/fishFoodMWD")
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
