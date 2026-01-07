#!/bin/bash
# Author: Rohtash Lakra
# Configure MySQL: Set root password, create database, and create users
# Usage:
#   ./configure.sh --user <username> [--password <password>] [--admin|--regular]  # Create user only
#   ./configure.sh --root-password <password> [--database <dbname>] [--user <username>] [--user-password <password>]
#   ./configure.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
# Note: MySQL is 1 level deep, so use .. instead of ../..
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default values
ROOT_PASSWORD=""
DATABASE_NAME=""
CREATE_USER=""
USER_PASSWORD=""
USER_TYPE="regular"  # regular or admin
SKIP_GRANT_TABLES=false
CURRENT_ROOT_PASSWORD=""
OPERATION_MODE=""  # "user-only", "configure", or "both"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./configure.sh --user <username> [options]${NC}                       # Create user only"
    echo -e "  ${AQUA}./configure.sh --root-password <password> [options]${NC}              # Configure MySQL (set root password, etc.)"
    echo
    echo -e "${DARKBLUE}User Creation Options:${NC}"
    echo -e "  ${AQUA}--user <username>${NC}                ${INDIGO}MySQL username to create${NC}"
    echo -e "  ${AQUA}--password <password>${NC}            ${INDIGO}Password for the new user (optional, will prompt if not provided)${NC}"
    echo -e "  ${AQUA}--admin${NC}                          ${INDIGO}Grant admin privileges (ALL PRIVILEGES on *.*)${NC}"
    echo -e "  ${AQUA}--regular${NC}                        ${INDIGO}Grant regular privileges (default: SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER)${NC}"
    echo
    echo -e "${DARKBLUE}Configuration Options:${NC}"
    echo -e "  ${AQUA}--root-password <password>${NC}       ${INDIGO}Set MySQL root password${NC}"
    echo -e "  ${AQUA}--current-root-password <pwd>${NC}    ${INDIGO}Current root password (if changing existing password)${NC}"
    echo -e "  ${AQUA}--database <dbname>${NC}              ${INDIGO}Create database with this name${NC}"
    echo -e "  ${AQUA}--skip-grant-tables${NC}              ${INDIGO}Use skip-grant-tables mode (for password recovery)${NC}"
    echo -e "  ${AQUA}--help${NC}                           ${INDIGO}Show this help message${NC}"
    echo
    echo -e "${INDIGO}Examples:${NC}"
    echo -e "  ${AQUA}./configure.sh --user testuser${NC}                                   # Create regular user (password will be prompted)"
    echo -e "  ${AQUA}./configure.sh --user testuser --password mypass${NC}                 # Create regular user with password"
    echo -e "  ${AQUA}./configure.sh --user admin --password pass --admin${NC}              # Create admin user"
    echo -e "  ${AQUA}./configure.sh --root-password MyNewPass${NC}                         # Set root password only"
    echo -e "  ${AQUA}./configure.sh --root-password MyNewPass --database MyDB${NC}         # Set root password and create database"
    echo -e "  ${AQUA}./configure.sh --root-password MyNewPass --database MyDB --user dev --user-password devpass${NC}  # Full setup"
    echo -e "  ${AQUA}./configure.sh --current-root-password OldPass --root-password NewPass${NC}  # Change root password"
    echo
    echo -e "${INDIGO}Note:${NC}"
    echo -e "  ${BROWN}If MySQL root has no password, leave --current-root-password empty.${NC}"
    echo -e "  ${BROWN}You will be prompted for MySQL root password when creating users.${NC}"
    echo -e "  ${BROWN}The --skip-grant-tables option is for password recovery scenarios.${NC}"
    echo
}

# Function to prompt for password securely
prompt_password() {
    local prompt_text="$1"
    local password=""
    
    echo -e "${INDIGO}${prompt_text}${NC}"
    read -s password
    echo
    echo "$password"
}

# Function to check if MySQL is running
check_mysql_running() {
    if pgrep -x mysqld > /dev/null 2>&1 || pgrep -f mysql > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to set root password
set_root_password() {
    local new_password="$1"
    local current_password="$2"
    
    print_header "Set MySQL Root Password"
    echo -e "${INDIGO}Setting root password...${NC}"
    echo
    
    # SQL command to set password (MySQL 5.7+ uses ALTER USER, older versions use SET PASSWORD)
    local sql_command="ALTER USER 'root'@'localhost' IDENTIFIED BY '${new_password}';"
    
    # Try ALTER USER first (MySQL 5.7+), fallback to SET PASSWORD for older versions
    if [ -z "$current_password" ]; then
        mysql -u root <<EOF
${sql_command}
FLUSH PRIVILEGES;
EOF
        if [ $? -ne 0 ]; then
            # Try SET PASSWORD for older MySQL versions
            mysql -u root <<EOF
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${new_password}');
FLUSH PRIVILEGES;
EOF
        fi
    else
        mysql -u root -p"${current_password}" <<EOF
${sql_command}
FLUSH PRIVILEGES;
EOF
        if [ $? -ne 0 ]; then
            # Try SET PASSWORD for older MySQL versions
            mysql -u root -p"${current_password}" <<EOF
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${new_password}');
FLUSH PRIVILEGES;
EOF
        fi
    fi
    
    if [ $? -eq 0 ]; then
        echo
        print_success "Root password set successfully!"
        echo
        return 0
    else
        echo
        print_error "Failed to set root password"
        echo
        return 1
    fi
}

# Function to create database
create_database() {
    local db_name="$1"
    local root_password="$2"
    
    print_header "Create MySQL Database"
    echo -e "${INDIGO}Creating database: ${AQUA}${db_name}${NC}"
    echo
    
    local sql_commands="
CREATE DATABASE IF NOT EXISTS \`${db_name}\`;
SHOW DATABASES LIKE '${db_name}';
"
    
    if [ -z "$root_password" ]; then
        mysql -u root <<EOF
${sql_commands}
EOF
    else
        mysql -u root -p"${root_password}" <<EOF
${sql_commands}
EOF
    fi
    
    if [ $? -eq 0 ]; then
        echo
        print_success "Database '${db_name}' created successfully!"
        echo
        return 0
    else
        echo
        print_error "Failed to create database '${db_name}'"
        echo
        return 1
    fi
}

# Function to create regular user
create_regular_user() {
    local username="$1"
    local password="$2"
    local root_password="$3"
    local db_name="$4"
    
    if [ -n "$db_name" ]; then
        print_header "Create MySQL Regular User (Database: ${db_name})"
    else
        print_header "Create MySQL Regular User"
    fi
    echo -e "${INDIGO}Creating regular user: ${AQUA}${username}${NC}"
    echo
    
    local sql_commands="
CREATE USER IF NOT EXISTS '${username}'@'localhost' IDENTIFIED BY '${password}';
"
    
    # Grant privileges based on database or global
    if [ -n "$db_name" ]; then
        sql_commands="${sql_commands}
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON \`${db_name}\`.* TO '${username}'@'localhost';
"
    else
        sql_commands="${sql_commands}
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON *.* TO '${username}'@'localhost';
"
    fi
    
    sql_commands="${sql_commands}
FLUSH PRIVILEGES;
SHOW GRANTS FOR '${username}'@'localhost';
"
    
    if [ -z "$root_password" ]; then
        mysql -u root <<EOF
${sql_commands}
EOF
    else
        mysql -u root -p"${root_password}" <<EOF
${sql_commands}
EOF
    fi
    
    if [ $? -eq 0 ]; then
        echo
        print_success "Regular user '${username}' created successfully!"
        echo
        return 0
    else
        echo
        print_error "Failed to create regular user '${username}'"
        echo
        return 1
    fi
}

# Function to create admin user
create_admin_user() {
    local username="$1"
    local password="$2"
    local root_password="$3"
    local db_name="$4"
    
    if [ -n "$db_name" ]; then
        print_header "Create MySQL Admin User (Database: ${db_name})"
    else
        print_header "Create MySQL Admin User"
    fi
    echo -e "${INDIGO}Creating admin user: ${AQUA}${username}${NC}"
    echo
    
    local sql_commands="
CREATE USER IF NOT EXISTS '${username}'@'localhost' IDENTIFIED BY '${password}';
"
    
    # Grant privileges based on database or global
    if [ -n "$db_name" ]; then
        sql_commands="${sql_commands}
GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${username}'@'localhost' WITH GRANT OPTION;
"
    else
        sql_commands="${sql_commands}
GRANT ALL PRIVILEGES ON *.* TO '${username}'@'localhost' WITH GRANT OPTION;
"
    fi
    
    sql_commands="${sql_commands}
FLUSH PRIVILEGES;
SHOW GRANTS FOR '${username}'@'localhost';
"
    
    if [ -z "$root_password" ]; then
        mysql -u root <<EOF
${sql_commands}
EOF
    else
        mysql -u root -p"${root_password}" <<EOF
${sql_commands}
EOF
    fi
    
    if [ $? -eq 0 ]; then
        echo
        print_success "Admin user '${username}' created successfully!"
        echo
        return 0
    else
        echo
        print_error "Failed to create admin user '${username}'"
        echo
        return 1
    fi
}

# Parse arguments
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            usage
            exit 0
            ;;
        --user)
            if [ -z "$2" ]; then
                print_error "Please provide a username after --user"
                usage
                exit 1
            fi
            CREATE_USER="$2"
            shift
            ;;
        --password|--user-password)
            if [ -z "$2" ]; then
                print_error "Please provide a password after $1"
                usage
                exit 1
            fi
            USER_PASSWORD="$2"
            shift
            ;;
        --admin)
            USER_TYPE="admin"
            ;;
        --regular)
            USER_TYPE="regular"
            ;;
        --root-password)
            if [ -z "$2" ]; then
                print_error "Please provide a password after --root-password"
                usage
                exit 1
            fi
            ROOT_PASSWORD="$2"
            shift
            ;;
        --current-root-password)
            if [ -z "$2" ]; then
                print_error "Please provide a password after --current-root-password"
                usage
                exit 1
            fi
            CURRENT_ROOT_PASSWORD="$2"
            shift
            ;;
        --database)
            if [ -z "$2" ]; then
                print_error "Please provide a database name after --database"
                usage
                exit 1
            fi
            DATABASE_NAME="$2"
            shift
            ;;
        --skip-grant-tables)
            SKIP_GRANT_TABLES=true
            print_warning "Skip-grant-tables mode: This requires manual MySQL server management"
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

# Determine operation mode
if [ -n "$CREATE_USER" ] && [ -z "$ROOT_PASSWORD" ]; then
    OPERATION_MODE="user-only"
elif [ -n "$ROOT_PASSWORD" ] && [ -z "$CREATE_USER" ]; then
    OPERATION_MODE="configure"
elif [ -n "$ROOT_PASSWORD" ] && [ -n "$CREATE_USER" ]; then
    OPERATION_MODE="both"
else
    print_error "No valid operation specified. Use --user to create a user or --root-password to configure MySQL."
    usage
    exit 1
fi

# Validate user creation requirements
if [ -n "$CREATE_USER" ]; then
    # Prompt for password if not provided
    if [ -z "$USER_PASSWORD" ]; then
        USER_PASSWORD=$(prompt_password "Enter password for user '${CREATE_USER}': ")
        if [ -z "$USER_PASSWORD" ]; then
            print_error "Password cannot be empty"
            exit 1
        fi
        echo
        # Confirm password
        confirm_password=$(prompt_password "Confirm password for user '${CREATE_USER}': ")
        echo
        if [ "$USER_PASSWORD" != "$confirm_password" ]; then
            print_error "Passwords do not match"
            exit 1
        fi
    fi
fi

# Check if MySQL is running
if [ "$SKIP_GRANT_TABLES" != "true" ] && ! check_mysql_running; then
    print_warning "MySQL server does not appear to be running"
    echo -e "${INDIGO}Please start MySQL server before running this script.${NC}"
    echo -e "${INDIGO}On macOS, you can start it from System Preferences > MySQL${NC}"
    echo
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Handle root password operations
if [ "$OPERATION_MODE" == "configure" ] || [ "$OPERATION_MODE" == "both" ]; then
    # If current root password is not provided, try to prompt for it
    if [ -z "$CURRENT_ROOT_PASSWORD" ] && [ "$SKIP_GRANT_TABLES" != "true" ]; then
        echo -e "${INDIGO}Enter current MySQL root password (press Enter if no password):${NC}"
        CURRENT_ROOT_PASSWORD=$(prompt_password "")
        echo
    fi
    
    # Set root password
    if ! set_root_password "$ROOT_PASSWORD" "$CURRENT_ROOT_PASSWORD"; then
        print_error "Failed to set root password. Cannot continue."
        exit 1
    fi
    
    # Create database if specified
    if [ -n "$DATABASE_NAME" ]; then
        if ! create_database "$DATABASE_NAME" "$ROOT_PASSWORD"; then
            print_warning "Database creation failed, but continuing..."
        fi
    fi
fi

# Handle user creation
if [ -n "$CREATE_USER" ]; then
    # Get root password for user creation if not already set
    local root_pwd_for_user=""
    if [ "$OPERATION_MODE" == "user-only" ]; then
        # Prompt for root password
        echo -e "${INDIGO}Enter MySQL root password (press Enter if no password):${NC}"
        root_pwd_for_user=$(prompt_password "")
        echo
    else
        # Use the root password we just set
        root_pwd_for_user="$ROOT_PASSWORD"
    fi
    
    # Create user based on type
    if [ "$USER_TYPE" == "admin" ]; then
        if ! create_admin_user "$CREATE_USER" "$USER_PASSWORD" "$root_pwd_for_user" "$DATABASE_NAME"; then
            print_error "User creation failed"
            exit 1
        fi
    else
        if ! create_regular_user "$CREATE_USER" "$USER_PASSWORD" "$root_pwd_for_user" "$DATABASE_NAME"; then
            print_error "User creation failed"
            exit 1
        fi
    fi
fi

# Print completion message
if [ "$OPERATION_MODE" == "user-only" ]; then
    print_completed "User Creation Complete!"
elif [ "$OPERATION_MODE" == "configure" ]; then
    print_completed "MySQL Configuration Complete!"
else
    print_completed "MySQL Configuration and User Creation Complete!"
fi
