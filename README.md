# git-filter-repo Testing

Needs `just` and `git` installed.

## Setup
- `just install-git-filter-repo` to install `git-filter-repo` 2.47.0
- `just init-mock-remotes` to clone ldmx-sw into a "mock remote" and remote the actual GitHub remote for safety
  - makes an additional copy of this mock remote to pretend to push the cleaned history to
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

## Experience
To see how a developer with a clone of the old/dirty/heavy history would experience
their remote being updated with the new/clean/light history, we make another copy of ldmx-sw
and then set its remote to the mock "extra crispy" remote.

- `just test-merge-pull` shows what happens when you delete the local tags and do a merge-based pull
- `just test-rebase-pull` shows what happens when you delete the local tags and do a rebase pull
