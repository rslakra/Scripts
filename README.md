# Scripts

A collection of utility scripts for development, system administration, and automation tasks.

**Version:** 1.0.0

---

## Overview

This repository contains organized shell scripts for various tasks including:
- AWS instance management
- Build tools installation and management
- Database configuration (MySQL)
- Docker operations
- Git version control operations
- Java/JDK management
- Network utilities
- Server management (Apache, JBoss)
- SSL certificate management
- And more...

---

## Quick Start

### Generate Symbolic Links

The `linkGenerator.sh` script creates convenient symbolic links in your home directory for easy access to all scripts:

```bash
./linkGenerator.sh              # Generate all symbolic links
./linkGenerator.sh --remove     # Remove all broken symbolic links in ~
./linkGenerator.sh --soft-links # List all symbolic links in ~
```

After running `linkGenerator.sh`, you can use scripts directly from your home directory, for example:
```bash
~/ipAddress             # Display IP address information
~/portUsage             # Check/free port usage
~/showGitCommits         # View Git commit logs
~/mergeBranches         # Merge Git branches
```

---

## Folder Structure

```
/
├── AWS/                    # AWS EC2 instance management scripts
├── Bluetooth/              # Bluetooth library utilities
├── BuildTools/             # Build tools installation (Homebrew, etc.)
├── DB/                     # Database scripts
│   └── MySQL/              # MySQL configuration and user management
├── Gulp/                   # Gulp installation scripts
├── IaC/                    # Infrastructure as Code
│   └── Docker/             # Docker image and container management
├── IDE/                    # IDE-specific scripts
│   └── Eclipse/            # Eclipse crash cleanup
├── Java/                   # Java/JDK management scripts
│   └── JAR/                # JAR file utilities
├── Logs/                   # Log files directory
├── Mobile/                 # Mobile development scripts
│   └── Android/            # Android ADB and development tools
├── Multimedia/             # Multimedia conversion scripts
│   └── MP3/                # MP3 conversion utilities
├── MyOSConfigs/            # OS configuration files
│   ├── MySQL/              # MySQL configuration files
│   └── OSX/                # macOS configuration files
├── Network/                # Network utilities
│   ├── ipAddress.sh        # Display IP address information
│   └── portUsage.sh        # Port usage management
├── OS/                     # Operating system scripts
│   └── OSX/                # macOS-specific utilities
├── Servers/                # Server management scripts
│   ├── Apache/             # Apache server management
│   └── JBoss/              # JBoss server management
├── SSL/                    # SSL certificate management
├── VCS/                    # Version control system scripts
│   ├── Git/                # Git utilities
│   └── SVN/                # SVN utilities
├── VBScripts/              # VBScript utilities
├── colors.sh               # Color definitions for script output
├── linkGenerator.sh        # Generate symbolic links for scripts
├── script_utils.sh         # Utility functions for scripts
└── README.md               # This file
```

---

## Key Scripts

### Network Utilities

- **`Network/ipAddress.sh`** - Display IP address information with various options
  ```bash
  ./ipAddress.sh                # Show all IPv4 addresses
  ./ipAddress.sh --all          # Show all IP addresses (IPv4 and IPv6)
  ./ipAddress.sh --external     # Show external/public IP address
  ```

- **`Network/portUsage.sh`** - Check and manage port usage
  ```bash
  ./portUsage.sh --check <port>    # Check if port is in use
  ./portUsage.sh --free <port>     # Free/kill processes using the port
  ./portUsage.sh --list            # List all ports in use
  ```

### Git Utilities

- **`VCS/Git/showGitCommits.sh`** - View Git commit logs in various formats
  ```bash
  ./showGitCommits.sh           # Short format with graph (default)
  ./showGitCommits.sh --long    # Long format (oneline with graph)
  ./showGitCommits.sh --stat    # With file statistics and graph
  ```

- **`VCS/Git/mergeBranches.sh`** - Merge source branch into target branch
  ```bash
  ./mergeBranches.sh <SOURCE_BRANCH> <TARGET_BRANCH>
  ```

- **`VCS/Git/tagRemove.sh`** - Remove Git tags
  ```bash
  ./tagRemove.sh <tagName>     # Remove a specific tag
  ./tagRemove.sh --all         # Remove all tags
  ```

### Database Management

- **`DB/MySQL/configure.sh`** - Comprehensive MySQL configuration and user management
  ```bash
  ./configure.sh --user testuser                        # Create regular user
  ./configure.sh --user admin --admin                   # Create admin user
  ./configure.sh --root-password MyPass --database MyDB # Full setup
  ```

### Server Management

- **`Servers/Apache/apache.sh`** - Apache server management
  ```bash
  ./apache.sh start                    # Start Apache
  ./apache.sh stop                     # Stop Apache
  ./apache.sh --grant-permission       # Set permissions
  ./apache.sh tail-logs                # Tail access and error logs
  ```

- **`Servers/JBoss/jboss.sh`** - JBoss server management
  ```bash
  ./jboss.sh start --profile <profile>  # Start JBoss with profile
  ./jboss.sh stop                       # Stop JBoss
  ./jboss.sh clean                      # Clean temp, logs, and deployments
  ```

### SSL Certificate Management

- **`SSL/importCertificate.sh`** - Import certificates into truststore
  ```bash
  ./importCertificate.sh <certificate_file>                 # Auto-detect type
  ./importCertificate.sh --cert <type> <certificate_file>   # Specify type
  ```

- **`SSL/convertCertificate.sh`** - Convert between certificate formats
  ```bash
  ./convertCertificate.sh --from <type> --to <type> <input_file> [output_file]
  ```

---

## Common Commands

### Install OpenJDK 21
```bash
brew install openjdk@21
```

### Setup Scripts Environment

All scripts use a common bootstrap mechanism that:
- Automatically finds and sources `script_utils.sh`
- Sets up `SCRIPTS_HOME` environment variable
- Sources `colors.sh` for colored output
- Works regardless of script directory depth

---

## Script Conventions

All scripts in this repository follow these conventions:

1. **Bootstrap**: Each script includes a bootstrap line to source `script_utils.sh` and setup the environment
2. **Colored Output**: Uses color functions from `colors.sh` for better readability
3. **Help Options**: Most scripts support `--help` or `-h` for usage information
4. **Error Handling**: Proper error messages and exit codes
5. **Documentation**: Usage functions with examples

---

## Contributing

When adding new scripts:

1. Place them in the appropriate directory based on functionality
2. Include the bootstrap line at the top
3. Add a usage function with `--help` support
4. Use color functions for output (`print_header`, `print_success`, `print_error`, etc.)
5. Update `linkGenerator.sh` if the script should be accessible from home directory
6. Add documentation to relevant README files

---

## Author

**Rohtash Lakra**

---

## License

See [LICENSE](LICENSE) file for details.
