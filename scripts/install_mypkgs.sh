#!/bin/bash
set -e
## build ARGs
NCPUS=${NCPUS:-"-1"}

NB_USER=${NB_USER:-${DEFAULT_USER:-"rstudio"}}

install2.r --error --skipmissing --skipinstalled -n "$NCPUS" remotes pak radiant miniUI ragg
