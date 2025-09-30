# Executing Clean

### Clone
Download mirror of G4DarkBreM and ldmx-sw, mirror to insurance location on personal GitHub.
```
./clone | tee clone.log
```
- double check insurance location is up and matching

### Filter
Filter history for both G4DarkBreM and ldmx-sw.
```
./filter | tee filter.log
```

### Push
```
./push | tee push.log
```

### Archive
Add the logs and G4DarkBreM/ldmx-sw commit-maps to this repository for archival purposes.
```
git add *.log G4DarkBreM-commit-map ldmx-sw-commit-map
git commit -m "run logs and commit maps"
```


#### the `pull` refs will be rejected by GitHub because they are "hidden"
I think this is okay since we don't (normally) clone those anyways, they are just there for viewing PRs in the browser. I will ask them to let me replace them, but I doubt they will let me. 
This might break our current PRs but I'm hoping that since I am updating the branches that the PRs are referencing, the pull refs will be auto-updated on GitHub's side (for those PRs).

#### now-removed G4DarkBreM commit
There is one commit in ldmx-sw that was pointing G4DarkBreM to a now-removed commit. I am resolving this by allowing empty commits to remain in G4DarkBreM (`--prune-empty never`) which is annoying but not entirely unexpected.
