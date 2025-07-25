@_default:
    just --list --justfile {{ justfile() }}

# check latest git version (git-filter-repo needs >= 2.36.0)
check-git:
    #!/bin/sh set -eu
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
g4db_github := "git@github.com:LDMX-Software/G4DarkBreM.git"

dirty_clone := "original-recipe"
clean_clone := "extra-crispy"
mock_remotes := justfile_directory() / "mock-remotes"
actual_ldmx_sw := mock_remotes / "real_ldmx_sw.git"
actual_g4db := mock_remotes / "real_g4db.git"
test_remote := mock_remotes / "test.git"
test_g4db_remote := mock_remotes / "test_g4db.git"
test_url := "file://"+test_remote
test_g4db_url := "file://"+test_g4db_remote

# use the plain-gitconfig to show git's default behavior
export GIT_CONFIG_GLOBAL := justfile_directory() / "plain-gitconfig"

# make some mock remotes of ldmx-sw for testing
init-mock-remotes:
    git clone --bare {{ g4db_github }} {{ actual_g4db }}
    git -C {{ actual_g4db }} fetch -q --prune --update-head-ok --refmap "" origin +refs/*:refs/*
    git -C {{ actual_g4db }} remote remove origin
    cp -r {{ actual_g4db }} {{ test_g4db_remote }}
    git clone {{ ldmx_sw_github }} {{ actual_ldmx_sw }}
    git -C {{ actual_ldmx_sw }} fetch -q --prune --update-head-ok --refmap "" origin +refs/*:refs/*
    git -C {{ actual_ldmx_sw }} remote remove origin
    cp -r {{ actual_ldmx_sw }} {{ test_remote }}
    git -C {{ test_remote }} submodule set-url SimCore/G4DarkBreM {{ test_g4db_url }}
    git -C {{ test_remote }} commit -m "redirect G4DB submodule link" .gitmodules

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
filter: check-git-filter-repo
    ./filter {{ test_g4db_remote }} {{ clean_clone }}

# push extra-crispy to clean history remote
push:
    git -C {{ clean_clone }} push --force --mirror origin


# open a shell within a test repo recording the session with script
test name:
    #!/bin/sh
    cp -r {{ dirty_clone }} {{ name }}
    cd {{ name }}
    record_filename={{ justfile_directory() / "tests" / name }}
    script -O ${record_filename}.out
    cd ..
    rm -rf {{ name }}
    ansi2html <${record_filename}.out >${record_filename}.html

# test link using html-preview to render HTML in this repo
test_link_stub := "https://html-preview.github.io/?url=https://github.com/tomeichlersmith/ldmx-sw-rewrite-history-testing/blob/main/tests/"

# add a link to a test to the bottom of the README
@add-test-link name:
    echo '- [{{ name }}]({{ test_link_stub + name + ".html" }})' >> README.md
