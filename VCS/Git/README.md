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
| 


# Author

---

- Rohtash Lakra
