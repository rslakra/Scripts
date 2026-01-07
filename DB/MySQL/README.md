# MySQL Scripts

This directory contains scripts for managing MySQL configuration, users, and databases.

## Installation and Initial Setup

### macOS Installation Steps

1. Install MySQL
2. Open **System Preferences** → **MySQL** → Press **Start MySQL Server** button
3. Navigate to MySQL bin directory:
   ```bash
   cd /usr/local/mysql/bin/
   ```
4. Run secure installation:
   ```bash
   sudo ./mysql_secure_installation
   ```
5. Login as root:
   ```bash
   mysql -pPassw0rd!1234 -u root
   ```

## Scripts

### `configure.sh`

A comprehensive MySQL management script that can:
- Set or change MySQL root password
- Create databases
- Create users with regular or admin privileges
- Handle full MySQL configuration in one command

#### Usage

**Create User Only:**
```bash
./configure.sh --user <username> [--password <password>] [--admin|--regular]
```

**Configure MySQL:**
```bash
./configure.sh --root-password <password> [--database <dbname>] [--user <username>] [--password <password>]
```

#### Options

**User Creation Options:**
- `--user <username>` - MySQL username to create
- `--password <password>` - Password for the new user (optional, will prompt if not provided)
- `--admin` - Grant admin privileges (ALL PRIVILEGES on *.*)
- `--regular` - Grant regular privileges (default: SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER)

**Configuration Options:**
- `--root-password <password>` - Set MySQL root password
- `--current-root-password <pwd>` - Current root password (if changing existing password)
- `--database <dbname>` - Create database with this name
- `--skip-grant-tables` - Use skip-grant-tables mode (for password recovery)
- `--help` - Show help message

#### Examples

```bash
# Create regular user (password will be prompted)
./configure.sh --user testuser

# Create regular user with password
./configure.sh --user testuser --password mypass

# Create admin user
./configure.sh --user admin --password pass --admin

# Set root password only
./configure.sh --root-password MyNewPass

# Set root password and create database
./configure.sh --root-password MyNewPass --database MyDB

# Full setup: root password, database, and user
./configure.sh --root-password MyNewPass --database MyDB --user dev --password devpass

# Change root password
./configure.sh --current-root-password OldPass --root-password NewPass
```

## Manual MySQL Operations

### Method 1: Change Root Password using mysqladmin

**Set root password for the first time:**
```bash
mysqladmin -u root password NEWPASSWORD
```

**Change existing root password:**
```bash
mysqladmin -u root -p'oldpassword' password newpass
```

**Change password for other users:**
```bash
mysqladmin -u username -p'old-password' password new-password
```

### Method 2: Change Root Password using mysql command

1. Login to MySQL server:
   ```bash
   mysql -u root -p
   ```

2. Use mysql database:
   ```sql
   mysql> use mysql;
   ```

3. Change password for user:
   ```sql
   mysql> UPDATE user SET password=PASSWORD("NEWPASSWORD") WHERE User='username';
   ```

4. Reload privileges:
   ```sql
   mysql> FLUSH PRIVILEGES;
   mysql> quit
   ```

## SQL Commands Reference

### Create Database

```sql
CREATE DATABASE MyDB;
```

### Create User

```sql
CREATE USER 'user'@'localhost' IDENTIFIED BY 'User1@Mysql';
GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost';
FLUSH PRIVILEGES;
```

### Grant Permissions

**General Framework:**
```sql
GRANT [type of permission] ON [database name].[table name] TO '[username]'@'localhost';
```

**Example - Grant all privileges on specific database:**
```sql
GRANT ALL PRIVILEGES ON MyDB.* TO 'user'@'localhost';
FLUSH PRIVILEGES;
```

### Revoke Permissions

**General Framework:**
```sql
REVOKE [type of permission] ON [database name].[table name] FROM '[username]'@'localhost';
```

**Example - Revoke all privileges:**
```sql
REVOKE ALL PRIVILEGES ON *.* FROM 'user'@'localhost';
FLUSH PRIVILEGES;
```

**Example - Revoke privileges on specific database:**
```sql
REVOKE ALL PRIVILEGES ON MyDB.* FROM 'user'@'localhost';
FLUSH PRIVILEGES;
```

### Delete User

```sql
DROP USER 'user'@'localhost';
```

### Test User Connection

1. Logout from current session:
   ```sql
   quit
   ```

2. Login with new user:
   ```bash
   mysql -pUser1@Mysql -u user
   ```

## References

- [Basic MySQL Tutorial](https://www.digitalocean.com/community/tutorials/a-basic-mysql-tutorial)
- [How to Create a New User and Grant Permissions in MySQL](https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql)

# Author

- Rohtash Lakra
