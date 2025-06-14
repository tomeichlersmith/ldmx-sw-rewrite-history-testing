@_default:
    just --list --justfile {{ justfile() }}

# check latest git version (git-filter-repo needs >= 2.36.0)
check-git:
    #!/bin/sh
    set -eu
    current=$(git --version | cut -f 3 -d ' ')
    minor=$(echo ${current} | cut -f 2 -d .)
    if [ "${minor}" -lt 36 ]; then
      echo "\e[31mCurrent git version ${current} is not >= 2.36.0 needed by git-filter-repo.\e[0m"
      echo "Install latest git version for your system, which may require adding additional repos."
      echo "On Ubuntu, this PPA provides the latest stable upstream Git version:"
      echo "  sudo add-apt-repository ppa:git-core/ppa"
      echo "  sudo apt update && sudo apt install git"
      exit 1
    fi

# install git-filter-repo 2.47.0
install-git-filter-repo: check-git
    #!/bin/sh
    set -eu
    wget https://github.com/newren/git-filter-repo/releases/download/v2.47.0/git-filter-repo-2.47.0.tar.xz
    xz -d git-filter-repo-2.47.0.tar.xz
    tar xf git-filter-repo-2.47.0.tar
    cp -t ~/.local/bin/ git-filter-repo-2.47.0/git-filter-repo

# check that git-filter-repo is installed
@check-git-filter-repo:
    git filter-repo --version

ldmx_sw_github := "git@github.com:LDMX-Software/ldmx-sw.git"

dirty_clone := "original-recipe"
clean_clone := "extra-crispy"
mock_remotes := justfile_directory() / "mock-remotes"
actual_ldmx_sw := mock_remotes / "real_ldmx_sw.git"
test_remote := mock_remotes / "test.git"
test_url := "file://"+test_remote

# make some mock remotes of ldmx-sw for testing
init-mock-remotes:
    git clone --recursive --bare {{ ldmx_sw_github }} {{ actual_ldmx_sw }}
    git -C {{ actual_ldmx_sw }} remote remove origin
    cp -r {{ actual_ldmx_sw }} {{ test_remote }}

# reset test remote to before filtering operation
reset-test-remote:
    rm -rf {{ test_remote }}
    cp -r {{ actual_ldmx_sw }} {{ test_remote }}

# make copies of local ldmx-sw
init-local-clones:
    git clone --recursive --no-local {{ test_url }} {{ dirty_clone }}
    cp -r {{ dirty_clone }} {{ clean_clone }}

# cleanup local copies of ldmx-sw
cleanup-local:
    rm -rf {{ dirty_clone }} {{ clean_clone }} \
           {{ dirty_clone }}-* {{ clean_clone }}-*

# cleanup mock remotes of ldmx-sw
cleanup-mock-remotes:
    rm -rf {{ mock_remotes }}

# filter extra-crispy clone
filter:
  git -C {{ clean_clone }} filter-repo \
    --sensitive-data-removal \
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

# push extra-crispy to clean history remote
push:
    git -C {{ clean_clone }} push --force --mirror origin

# setup a dirty clone for testing
test-setup name:
    cp -r {{ dirty_clone }} {{ dirty_clone }}-{{ name }}


# cleanup dirty clone for testing
test-cleanup name:
    rm -rf {{ dirty_clone }}-{{ name }}


# test a rebase pull from clean history into dirty history
test-rebase-pull name="test-rebase-pull": (test-setup name) && (test-cleanup name)
    #!/bin/sh
    set -eu
    cd {{ dirty_clone }}-{{ name }}
    set -x
    git tag -d $(git tag -l)
    git fetch --all
    git status
    git pull --rebase=true
    git rev-list --count trunk


# test a merge pull from clean history into dirty history
test-merge-pull name="test-merge-pull": (test-setup name) && (test-cleanup name)
    #!/bin/sh
    set -eu
    cd {{ dirty_clone }}-{{ name }}
    set -x
    git tag -d $(git tag -l)
    git fetch --all
    git status
    git pull --rebase=false
    git rev-list --count trunk

