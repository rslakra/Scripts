# Homebrew

---

The ```Homebrew``` contains various build and installation scripts.



## Folder Structure Conventions

---

```
    /
    ├── <Name>                  # The verson control system
    └── README.md
```



## Homebrew Commands

---

### List Installed Packages

```shell
brew info --installed --json=v1 | jq "map(.name)"
```



# Author

---

- Rohtash Lakra
