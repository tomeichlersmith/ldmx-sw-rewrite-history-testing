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

= Plan

== Before Rewrite
1. All code (including WIP) pushed to some branch of ldmx-sw
```sh
git switch -c my-branch
git add # non-data files they want to keep
git commit -m "some message about what I'm working on"
git push -u origin my-branch
```
#link("https://github.com/tomeichlersmith/ldmx-sw-rewrite-history-testing?tab=readme-ov-file#make-sure-local-repo-is-prepared-for-deletion")[More detailed notes on my GitHub for checking for unsaved or unpushed changes.]

2. Remove local copy of ldmx-sw and its *ouch* (old unclean contaminated heavy) history
```sh
rm -rf ldmx-sw
```

#tblock(title: [This is the scary part: see linked notes to ensure saved work])[
  #set text(size: 0.6em)
  If you are unwilling to `rm -rf ldmx-sw`, then I can help guid you through the complicated `git` commands to update your local copy of the ldmx-sw history without removing the repository.
]

== Rewrite
#align(center, text(size: 1.5em, fill: umn-maroon)[On Oct 1])
#link("https://github.com/tomeichlersmith/ldmx-sw-rewrite-history-testing/blob/main/filter")[filter script]
- I've been testing this locally and I think I have a good solution.
- I will mirror the pre-filtered copy of the repository with the *ouch* history to a repository on my personal GitHub for insurance. I will not announce this to anyone on slack, in email, or in a meeting since it should only be utilized if I make a mistake during the filtering process.
- I will run the filtering and then mirror my local new/clean/light history to GitHub (both ldmx-sw and G4DarkBreM)

== After Rewrite
- re-clone ldmx-sw
```sh
git clone git@github.com:LDMX-Software/ldmx-sw.git
```
- new clones will bring new `just init` which may fail, see #link("https://github.com/LDMX-Software/ldmx-sw/releases/tag/v4.5.0")[Side Effects section of v4.5.0]
- *Fello Admins*: Keep an eye out for long `git fetch` -- if *ouch* history is re-introduced on any branch, everyone will re-download it when they `git fetch` that branch
  - removing a branch with the *ouch* history is easy: delete that branch (GitHub and locally)
  - in all honesty, this is easier than the de-submodulification -- we could do it today -- all of the prep is just to avoid branch policing

== Questions
- [x] Can we prevent users from pushing certain commits to GitHub? No -- GitHub does not have this feature and the free cloud version doesn't even allow us to write custom pre-receive hooks which could do this.
- [x] Can we `just filter` again in the future? Technically yes, but it would almost certainly introduce another (third) history that everyone would need to re-sync with so we probably want to avoid another filter.
- [ ] Any other files we want to filter out? I'm removing the CI gold, but also `.pkl`, `.tar.gz`, `.root`, and `.ipynb`
- [x] When? `git push` by Sept 30, filter on Oct 1, `git clone` after Oct 1
- [ ] How to communicate? We want everyone who has a clone of ldmx-sw to delete it (after saving their work), maybe an mme email?

= Appendix
#show: appendix

== Config Advice
You should use rebase-pull in 99% of situations
```sh
git config --global pull.rebase=true
```

== Replacing Branches
If you have a branch with the *ouch* history and you want to replace it, you can "rebase" it onto the updated `trunk` and then force push this updated branch.
```sh
git switch my-branch
git rebase trunk
git push --force origin my-branch
```

#tblock(title: [Warning])[
  This will only work if `trunk` does not have the *ouch* history.
  If your local copy of ldmx-sw was not re-cloned after the filtering, this will not do anything of value.
]

i.e. this procedure would work if person A did not listen and pushes the *ouch* history, Admin B notices, rebases Person A's branch in their new clone, and then informs Person A that they need to `rm -rf ldmx-sw` and re-clone.
