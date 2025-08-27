# git-filter-repo Testing

Needs `just`, `git >= 2.36.0`, and `ansi2html`.

## To Do
- [x] filtering command for ldmx-sw history
- [x] check if merge pulls re-introduce old history (they do)
- [x] check if rebase pulls re-introduce old history (they don't)
- [ ] clean submodule and update submodule refs when filtering ldmx-sw
    - I think this is what we want: https://github.com/newren/git-filter-repo/issues/537
      We `git filter-repo` G4DarkBreM and then use the generated `commit-map` to update
      the commits that affect it while running `git filter-repo` in ldmx-sw.

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

### Make Sure Local Repo is Prepared for Deletion
Folks can make sure their changes to ldmx-sw can be carried through this rewriting by making sure any changes to the files in `git` are committed and pushed to the GitHub repository.

First, we need to make sure that there are no "uncommitted changes" in your local copy of the git repository.
```
$ git status --untracked --ignored
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
    modified: file-with-changes

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	new-file-not-ignored

Ignored files:
  (use "git add -f <file>..." to include in what will be committed)
	file-ignored-by-git

no changes added to commit (use "git add" and/or "git commit -a")
```
Some of these sections may be missing, for example, if there are no changes,
untracked files, and ignored files, then it will say "working tree clean".
```
$ git status --untracked --ignored
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```
and by making sure your local `git stash` is empty.
```
$ git stash list
# if this returns _anything_, that's bad
```
I cannot tell you what you will want to keep, but I have three suggested options for any files
that come up listed with one of these commands.
1. Delete the Changes: If they are old or not needed, you can delete the changes manually to tell `git` and yourself they are not important. Do this by discarding changes with `git restore` if the file is listed under "Changes not staged" or deleting the file if it is listed under "Untracked" or "Ignored". Changes listed in the `git stash` that you want to remove can be deleted with `git stash drop`
2. Save the Changes: If the changes are something important that you are working on, you can create a branch and commit them so they are saved in the repository. `git switch -c <branch-name> && git add <files> && git commit -m "messsage"`
3. Move the files: Especially for Untracked and Ignored files that are large (like data files, images, and jupyter notebooks), the best option is to put them somewhere outside of ldmx-sw.

After you are getting a "working tree clean" message and your `git stash` is empty, we can move on to making sure your branches are pushed to GitHub.
This can be checked by inspecting the output of `git branch -vv`. For example
```
$ git branch -vv
  danger-ahead    56a8890 [origin/danger-ahead: ahead 1] add content
  danger-noup     5e9b12f change on feat
* main            7c2ed30 [origin/main] add to changelog
  nodanger-behind d283f8e [origin/nodanger-behind: behind 1] two more to dos before start of class
```
Notes by the line
1. `danger-ahead`: this branch has a commit that is "ahead" of the "origin" branch (meaning it has not been pushed to GitHub). Switch to that branch and push: `git switch danger-ahead && git push`
2. `danger-noup`: this branch has never been pushed to GitHub. If you want to keep this branch, you need to push it: `git switch danger-noup && git push -u origin danger-noup`.
3. `main`: this branch is in sync with what is on GitHub. Nothing needs to be done.
4. `nodanger-behind`: this branch is "behind" what is on GitHub, but that is fine. I will use what is on GitHub.

When you are satisified with the output of your `git branch`, you can exit and remove your ldmx-sw.
```
cd .. && rm -rf ldmx-sw
```
and then re-clone it after I update the history.

## Experience
To see how a developer with a clone of the old/dirty/heavy history would experience
their remote being updated with the new/clean/light history, we make another copy of ldmx-sw
and then set its remote to the mock "extra crispy" remote.

`just test NAME` opens a shell in this copy of ldmx-sw and records any output into a log which
is then rendered into an HTML file in `tests/NAME.html`. For these test recordings that are committed
into this repository and pushed to GitHub, we can use [html-preview](https://github.com/html-preview/html-preview.github.io) to view the session including the input commands and output results.

- [naive-pull](https://html-preview.github.io/?url=https://github.com/tomeichlersmith/ldmx-sw-rewrite-history-testing/blob/main/tests/naive-pull.html): attempt to do a pull, see error, override it with first suggestion by Git
- [rebase-local-changes](https://html-preview.github.io/?url=https://github.com/tomeichlersmith/ldmx-sw-rewrite-history-testing/blob/main/tests/rebase-local-changes.html)
