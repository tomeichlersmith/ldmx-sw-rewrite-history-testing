#import "@local/umn-theme:0.0.0": *
#import "@preview/codly:1.3.0": *

#show: codly-init

#show: checklist

#show: umn-theme.with(
  config-info(
    title: [Cleaning `git` History],
    author: [Tom Eichlersmith],
    date: datetime.today(),
    institution: [he/him/his \ University of Minnesota],
  )
)

== Cleaning `git` History
- rewriting the `git` history to remove the large files erroneously committed will make the repo lighter and faster to clone
- `git-filter-repo` is the tool I'm using for this job #link("https://github.com/newren/git-filter-repo")[newren/git-filter-repo]
  - read: #link("https://htmlpreview.github.io/?https://github.com/newren/git-filter-repo/blob/docs/html/git-filter-repo.html#DISCUSSION")[DISCUSSION] section of `git-filter-repo` manual, specifically the "Sensitive Data Removals"

#tblock(title: [Good News])[
  All commits on all branches will be handled automatically.
]

#tblock(title: [Bad News])[
  #link("https://html-preview.github.io/?url=https://github.com/tomeichlersmith/ldmx-sw-rewrite-history-testing/blob/main/tests/naive-pull.html")[A simple `git pull` with default git config guides the user to re-introduce the heavy history.]
]

== Plan
=== All Developers Before Rewrite #link("https://github.com/tomeichlersmith/ldmx-sw-rewrite-history-testing?tab=readme-ov-file#make-sure-local-repo-is-prepared-for-deletion")[My Notes]
1. All code (including WIP) pushed to some branch of ldmx-sw
2. Remove local clone of ldmx-sw

=== Rewrite
#link("https://github.com/tomeichlersmith/ldmx-sw-rewrite-history-testing/blob/main/filter")[filter script]

=== After Rewrite
- new clones will bring new `just init` which may fail, see #link("https://github.com/LDMX-Software/ldmx-sw/releases/tag/v4.5.0")[Side Effects section of v4.5.0]
- Keep an eye out for long `git fetch` -- if old history is re-introduced on any branch, everyone will re-download it when they `git fetch` that branch
  - removing a branch with the heavy history is easy: delete that branch (GitHub and locally)
  - in all honesty, this is easier than the de-submodulification -- we could do it today -- all of the prep is just to avoid branch policing

== Questions
- [x] Can we prevent users from pushing certain commits to GitHub? No -- GitHub does not have this feature and the free cloud version doesn't even allow us to write custom pre-receive hooks which could do this.
- [x] Can we `just filter` again in the future? Technically yes, but it would almost certainly introduce another (third) history that everyone would need to re-sync with so we probably want to avoid another filter.
- [ ] Any other files we want to filter out? I'm removing the CI gold, but also `.pkl`, `.tar.gz`, `.root`, and `.ipynb`
- [ ] When? Probably helpful to pick a day and then work backwards
- [ ] How to communicate? We want everyone who has a clone of ldmx-sw to delete it (after saving their work), maybe an mme email?

== Advice
You should use rebase-pull in 99% of situations
```sh
git config --global pull.rebase=true
```
