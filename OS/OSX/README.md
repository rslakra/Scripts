# OSX

---

The ```OSX``` specific commands.



## Folder Structure Conventions

---

```
    /
    ├── Cheatsheets             # The Cheatsheets
    ├── Computer                # The Computer
    ├── Cultural                # The Cultural
    ├── Interview Guide         # An Interview Guide
    └── README.md
```

## Commands

### Clean Build Artifacts

Removes build artifacts and cache files recursively. Can be used to clean default build artifacts or a specific file/folder.

**Default cleanup entries:** `.DS_Store`, `__pycache__`, `.pyc`, `.pyo`, `venv`, `target`, `build`, `dist`

```shell
# Remove default build artifacts
./diskCleanup.sh

# Remove a specific file or folder recursively
./diskCleanup.sh 'file or folder name'
```

**Note:** This script removes both files and folders matching the specified name.

### Find Used Port
```shell
sudo lsof -i :8080
```

OR

```shell
sudo lsof -i -P | grep 8080
```

The ```-i``` restricts ```lsof``` to show IP connections (as opposed to all the other things it can show). ```-P``` turns off port name conversion so that it shows port numbers rather than service names, which is easier when you know the port number you're after.

- Print Process ID:
```shell
sudo lsof -i -P | grep 8080 | awk '{ print $2 }'
sudo kill -9 6235
```

OR

```shell
sudo lsof -i -P | grep 8080 | awk '{ print $2 }' | sudo xargs kill

```



# Author

---

- Rohtash Lakra
