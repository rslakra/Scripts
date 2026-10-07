# Git/GitHub/GitLab

---

The ```GitLab``` contains various build and installation scripts.



## Folder Structure Conventions

---

```
    /
    ├── <Name>                  # The verson control system
    └── README.md
```



## Git Commands

---

### GitHub SSH Keys

- Generating a new SSH key ([Reference](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key))
```shell
ssh-keygen -t ed25519 -C “email”
eval "$(ssh-agent -s)"
open ~/.ssh/config
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

- Config Settings (including multiple repos)
```shell
#Host github.com
#  AddKeysToAgent yes
#  UseKeychain yes
#  IdentityFile ~/.ssh/id_ed25519

Host work.github.com
      HostName github.com
      User rlakra-work
      IdentityFile ~/.ssh/id_ed25519_work

Host personal.github.com
      HostName github.com
      User rlakra-personal
      IdentityFile ~/.ssh/id_ed25519_personal
```

- Adding a new SSH key to your account ([Reference](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account))
```shell
pbcopy < ~/.ssh/id_ed25519.pub
```

- Test your SSH Connection
```shell
ssh -T git@github.com
```


- Git Default Configs
```shell
git config --global user.name “Rohtash“
git config --global user.email “email”

```

- Verify Git Configs
```shell
git config --list
```


### Set Local User's Name & Emails

```shell
git config --local user.email "work.work@gmail.com"
git config --local user.name "Rohtash Lakra"
```

### Short well-defined (git branch naming) tokens

| Branch  | Description                                                    |
|---------|----------------------------------------------------------------|
| master  | Master branch (production ready)                               |
| stable  | Stable branch (pre-production ready)                           |
| develop | Development branch (QA Ready - must be compilable and running) |
| wip     | Works in progress; stuff I know won't be finished soon         |
| feat    | Features, I'm adding or expanding (<feature-no> pattern)       |
| bug     | Bug fix or experiment (<bug-no> pattern)                       |
| junk    | Throwaway branch; created to experiment                        |




## Scripts

---



### [syncBranches.sh](http://syncBranches.sh)

Syncs Git branches across multiple projects in a workspace. Run it from the workspace directory (the folder that contains your project repos).

**Default branches synced:** `staging`, `develop`, and the repo's default branch (detected from `origin/HEAD`, usually `main` or `master`).

**What it does for each project:**

1. Resolves which projects to sync (from options, `projects.txt`, or all subdirectories).
2. Applies any exclusions from `excludes.txt` or `--sync`.
3. Runs `git fetch origin --prune` to refresh remote refs.
4. Detects the default branch from the remote (`git ls-remote --symref origin HEAD`; not stale local `origin/HEAD`).
5. Syncs `staging` and `develop` first (skipped with a warning if they do not exist).
6. Syncs the default branch **last** and leaves the repo checked out on it. Each branch sync:
   - Optionally runs `git clean -f -d` when `--clean` is set.
   - Checks out the branch (creates a local tracking branch from `origin/<branch>` if needed).
   - Runs `git reset --hard origin/<branch>` so local matches remote (no separate `git pull`).
7. Prints a summary of synced and failed projects.

**Options:**


| Option                                 | Description                                                                |
| -------------------------------------- | -------------------------------------------------------------------------- |
| `--projects <proj1> <proj2> ...`       | Sync only the named project directories                                    |
| `--sync <projects.txt> [excludes.txt]` | Read project list from a file; optional second file lists projects to skip |
| `--clean`                              | Remove untracked files and directories before each branch checkout         |
| `--help`, `-h`                         | Show help                                                                  |


**Auto-detection (no options):** If `projects.txt` and/or `excludes.txt` exist in the current directory, they are used automatically. Otherwise, every subdirectory in the workspace is treated as a project.

**Examples:**

```shell
# From your workspace directory
./syncBranches.sh

# Sync specific projects
./syncBranches.sh --projects api-service web-app

# Use project lists from files
./syncBranches.sh --sync projects.txt excludes.txt

# Sync and discard untracked files in each repo
./syncBranches.sh --clean --projects api-service

# Via symlink created by linkGenerator.sh
cd ~/Workspace && ~/syncBranches
```

**Notes:**

- Each entry must be a directory containing a `.git` folder; others are skipped with a warning.
- Branches that do not exist locally or on `origin` are skipped with a warning.
- The default branch is queried from the remote HEAD symref, so a stale local `origin/HEAD` (e.g. pointing to `qa`) will not be used.
- The default branch is always synced last so it remains the active checkout.
- This script resets local branches to match remote; uncommitted changes can be lost.



# Reference

---

- 


# Author

---

- Rohtash Lakra
