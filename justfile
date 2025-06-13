@_default:
    just --list --justfile {{ justfile() }}

# install git-filter-repo 2.47.0
install-git-filter-repo:
    #!/bin/sh
    set -eu
    wget https://github.com/newren/git-filter-repo/releases/download/v2.47.0/git-filter-repo-2.47.0.tar.xz
    xz -d git-filter-repo-2.47.0.tar.xz
    tar xf git-filter-repo-2.47.0.tar
    cp -t ~/.local/bin/ git-filter-repo-2.47.0/git-filter-repo

dirty_history_clone := "original-recipe"
dirty_history_remote := "git@github.com:LDMX-Software/ldmx-sw.git"
clean_history_clone := "extra-crispy"
clean_history_remote := "git@github.com:tomeichlersmith/ldmx-sw.git"

# make a new set of two clones of ldmx-sw
clones:
    #!/bin/sh
    set -eu
    git clone --recursive {{ dirty_history_remote }} {{ dirty_history_clone }}
    git clone --recursive {{ dirty_history_remote }} {{ clean_history_clone }}


# cleanup (remove two clones)
cleanup:
    rm -rf {{ dirty_history_clone }} {{ clean_history_clone }}

# filter extra-crispy clone
filter:
  git -C {{ clean_history_clone }} filter-repo \
    --invert-paths \
    --path-glob '**/gold.root' \
    --path-glob '**/gold.log' \
    --path-glob 'data/**.pkl' \
    --path-glob 'data/**.tar.gz' \
    --path-glob 'Configuration/data/**.pkl' \
    --path-glob 'Configuration/data/**.tar.gz' \
    --path-glob 'Ecal/data/**.pkl' \
    --path-glob 'Ecal/data/**.tar.gz' \
    --path-glob 'docs/html/**' \
    --path-glob '**.ipynb' \
    --path-glob '**/catch.hpp' \
    --path-glob '**.root'
