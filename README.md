# git-filter-repo Testing

Needs `just`, `git >= 2.36.0`, and `ansi2html`.

## Setup
- `just install-git-filter-repo` to install `git-filter-repo` 2.47.0
- `just init-mock-remotes` to clone ldmx-sw into a "mock remote" and remove the actual GitHub remote for safety
  - makes an additional copy of this mock remote to pretend to push/pull the cleaned history to/from
- `just init-local-clones` clones ldmx-sw from the "mock remote" twice:
  - "original recipe" to keep the old/dirty/heavy history
  - "extra crispy" to be filtered and get the new/clean/light history

I do this "mock remote" so that I don't accidentally push anything to the shared GitHub
and to make testing faster. Cloning and re-cloning ldmx-sw takes a long time.

## Filter
The actual `git-filter-repo` command got long enough, I just keep it in its own
recipe for easier reference.
```
just filter
```
This applies the `git-filter-repo` command to the "extra crispy" clone.
And then `just push` pushes the "extra crispy" repo to its (mock) remote.

### Git Notes
You can use the `GIT_CONFIG_GLOBAL` environment variable to temporarily change the Git configuration for testing.
As an example, I have several configurations that deviate from normal/default behavior (e.g. `pull.rebase=true`),
so I want to remove those configurations to see what a default Git would do.
Defining `GIT_CONFIG_GLOBAL` to the empty string makes Git not load my normal `~/.gitconfig` and thus act
with default behavior.
```
GIT_CONFIG_GLOBAL= git ...
```
However, there are some required global configurations that are done by users after first attempting to commit,
so I use the [plain gitconfig](plain-gitconfig) when testing to see the Git behavior relative to this minimal
configuration.

### GitHub-only Refs
These are refs like `refs/pull/NNNN/merge` or `refs/pull/NNNN/head` that are used by GitHub to display PR diffs
and run PR workflows.
I don't think we will rewrite the history of those refs because
1. [GitHub Support might not even do it](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository#fully-removing-the-data-from-github) -- They say they will not remove non-sensitive data and our files are large but do not contain sensitive data.
2. These refs only exist on GitHub's servers and are only copied down locally if a user does some really fancy git configuration. i.e. users will need to opt in to download these refs that contain the heavy history.
3. Leaving them in place will certainly keep the diff views of past PRs acting like they are currently.
4. Only the PRs updating the gold files themselves would be affected (I think).

## Experience
To see how a developer with a clone of the old/dirty/heavy history would experience
their remote being updated with the new/clean/light history, we make another copy of ldmx-sw
and then set its remote to the mock "extra crispy" remote.

`just test NAME` opens a shell in this copy of ldmx-sw and records any output into a log which
is then rendered into an HTML file in `tests/NAME.html`. For these test recordings that are committed
into this repository and pushed to GitHub, we can use [html-preview](https://github.com/html-preview/html-preview.github.io) to view the session including the input commands and output results.

- [naive-pull](https://html-preview.github.io/?url=https://github.com/tomeichlersmith/ldmx-sw-rewrite-history-testing/blob/main/tests/naive-pull.html): attempt to do a pull, see error, override it with first suggestion by Git
