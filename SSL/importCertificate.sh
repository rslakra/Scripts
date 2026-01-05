#!/bin/bash
# Author: Rohtash Lakra
# Import SSL certificate to truststore
# Usage:
#   ./importCertificate.sh <certificate_file>               # Auto-detect type from extension
#   ./importCertificate.sh --cert <type> <certificate_file> # Specify type (if auto-detect fails)
#   ./importCertificate.sh --help                           # Show help

# Bootstrap: Find and source script_utils.sh, then setup environment
# Note: SSL is 1 level deep, so use .. instead of ../..
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Default values
BC_JAR=bcprov-jdk16-146.jar
TRUST_STORE=res/raw/mytruststore.bks
CERT_TYPE=""
CERT_FILE=""

# Supported certificate types
SUPPORTED_TYPES="pem cer crt der p12 pfx"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./importCertificate.sh <certificate_file>${NC}                # Auto-detect type from extension"
    echo -e "  ${AQUA}./importCertificate.sh --cert <type> <certificate_file>${NC}  # Specify type (if no extension or wrong extension)"
    echo -e "  ${AQUA}./importCertificate.sh --help${NC}                            # Show this help"
    echo
    echo -e "${INDIGO}Supported certificate types:${NC}"
    echo -e "  ${BROWN}.pem${NC}  - Privacy Enhanced Mail format (Base64 encoded)"
    echo -e "  ${BROWN}.cer${NC}  - Certificate file (DER or PEM format)"
    echo -e "  ${BROWN}.crt${NC}  - Certificate file (DER or PEM format)"
    echo -e "  ${BROWN}.der${NC}  - Distinguished Encoding Rules (binary format)"
    echo -e "  ${BROWN}.p12${NC}  - PKCS#12 format (contains private key and certificate)"
    echo -e "  ${BROWN}.pfx${NC}  - Personal Information Exchange (same as P12)"
    echo
    echo -e "${INDIGO}Examples:${NC}"
    echo -e "  ${AQUA}./importCertificate.sh certificate.pem${NC}                    # Auto-detect from .pem extension"
    echo -e "  ${AQUA}./importCertificate.sh certificate.p12${NC}                    # Auto-detect from .p12 extension"
    echo -e "  ${AQUA}./importCertificate.sh --cert pem certificate.txt${NC}        # Force PEM type for file with wrong extension"
    echo -e "  ${AQUA}./importCertificate.sh --cert p12 certificate${NC}           # Specify type for file with no extension"
    echo
}

# Function to detect certificate type from file extension
detect_cert_type() {
    local file="$1"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    case "$ext" in
        pem|cer|crt|der|p12|pfx)
            echo "$ext"
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to import certificate
import_certificate() {
    local cert_file="$1"
    local cert_type="$2"
    
    if [ ! -f "$cert_file" ]; then
        print_error "Certificate file not found: ${cert_file}"
        exit 1
    fi
    
    print_header "Import Certificate"
    echo -e "${INDIGO}Certificate file: ${AQUA}${cert_file}${NC}"
    echo -e "${INDIGO}Certificate type: ${AQUA}${cert_type}${NC}"
    echo
    
    # Handle different certificate types
    case "$cert_type" in
        pem|cer|crt)
            # PEM, CER, CRT formats - use PEM format
            echo -e "${INDIGO}Extracting alias from certificate...${NC}"
            ALIAS=$(openssl x509 -inform PEM -subject_hash -noout -in "$cert_file" 2>/dev/null)
            
            if [ -z "$ALIAS" ]; then
                # Try DER format
                ALIAS=$(openssl x509 -inform DER -subject_hash -noout -in "$cert_file" 2>/dev/null)
                if [ -z "$ALIAS" ]; then
                    print_error "Failed to read certificate. Please check the file format."
                    exit 1
                fi
                CERT_FORMAT="DER"
            else
                CERT_FORMAT="PEM"
            fi
            
            echo -e "${INDIGO}Certificate format: ${AQUA}${CERT_FORMAT}${NC}"
            echo -e "${INDIGO}Alias: ${AQUA}${ALIAS}${NC}"
            echo
            
            # Remove existing truststore if it exists
            if [ -f "$TRUST_STORE" ]; then
                echo -e "${INDIGO}Removing existing truststore...${NC}"
                rm "$TRUST_STORE" || exit 1
            fi
            
            echo -e "${INDIGO}Adding certificate to ${AQUA}${TRUST_STORE}${NC}..."
            echo -e "${BROWN}keytool -import -v -trustcacerts -alias ${ALIAS} -file ${cert_file} -keystore ${TRUST_STORE} -storetype BKS -providerclass org.bouncycastle.jce.provider.BouncyCastleProvider -providerpath ${BC_JAR} -storepass secret${NC}"
            echo
            
            keytool -import -v -trustcacerts -alias "$ALIAS" \
                -file "$cert_file" \
                -keystore "$TRUST_STORE" -storetype BKS \
                -providerclass org.bouncycastle.jce.provider.BouncyCastleProvider \
                -providerpath "$BC_JAR" \
                -storepass secret
            
            if [ $? -eq 0 ]; then
                echo
                print_success "Added '${cert_file}' with alias '${ALIAS}' to ${TRUST_STORE}!"
            else
                print_error "Failed to import certificate"
                exit 1
            fi
            ;;
            
        der)
            # DER format (binary)
            echo -e "${INDIGO}Extracting alias from DER certificate...${NC}"
            ALIAS=$(openssl x509 -inform DER -subject_hash -noout -in "$cert_file" 2>/dev/null)
            
            if [ -z "$ALIAS" ]; then
                print_error "Failed to read DER certificate. Please check the file format."
                exit 1
            fi
            
            echo -e "${INDIGO}Alias: ${AQUA}${ALIAS}${NC}"
            echo
            
            # Remove existing truststore if it exists
            if [ -f "$TRUST_STORE" ]; then
                echo -e "${INDIGO}Removing existing truststore...${NC}"
                rm "$TRUST_STORE" || exit 1
            fi
            
            echo -e "${INDIGO}Adding certificate to ${AQUA}${TRUST_STORE}${NC}..."
            echo -e "${BROWN}keytool -import -v -trustcacerts -alias ${ALIAS} -file ${cert_file} -keystore ${TRUST_STORE} -storetype BKS -providerclass org.bouncycastle.jce.provider.BouncyCastleProvider -providerpath ${BC_JAR} -storepass secret${NC}"
            echo
            
            keytool -import -v -trustcacerts -alias "$ALIAS" \
                -file "$cert_file" \
                -keystore "$TRUST_STORE" -storetype BKS \
                -providerclass org.bouncycastle.jce.provider.BouncyCastleProvider \
                -providerpath "$BC_JAR" \
                -storepass secret
            
            if [ $? -eq 0 ]; then
                echo
                print_success "Added '${cert_file}' with alias '${ALIAS}' to ${TRUST_STORE}!"
            else
                print_error "Failed to import certificate"
                exit 1
            fi
            ;;
            
        p12|pfx)
            # PKCS#12 format - contains private key and certificate
            print_warning "P12/PFX files contain private keys. This script imports the certificate chain."
            echo -e "${INDIGO}Extracting certificate from P12/PFX file...${NC}"
            
            # Extract certificate to temporary PEM file
            TEMP_PEM=$(mktemp /tmp/cert_XXXXXX.pem)
            openssl pkcs12 -in "$cert_file" -nokeys -out "$TEMP_PEM" -passin pass: 2>/dev/null || \
            openssl pkcs12 -in "$cert_file" -nokeys -out "$TEMP_PEM" 2>/dev/null
            
            if [ ! -f "$TEMP_PEM" ] || [ ! -s "$TEMP_PEM" ]; then
                print_error "Failed to extract certificate from P12/PFX file. It may be password protected."
                echo -e "${INDIGO}Note: You may need to provide the password interactively or convert to PEM first.${NC}"
                exit 1
            fi
            
            ALIAS=$(openssl x509 -inform PEM -subject_hash -noout -in "$TEMP_PEM" 2>/dev/null)
            
            if [ -z "$ALIAS" ]; then
                print_error "Failed to read extracted certificate."
                rm -f "$TEMP_PEM"
                exit 1
            fi
            
            echo -e "${INDIGO}Alias: ${AQUA}${ALIAS}${NC}"
            echo
            
            # Remove existing truststore if it exists
            if [ -f "$TRUST_STORE" ]; then
                echo -e "${INDIGO}Removing existing truststore...${NC}"
                rm "$TRUST_STORE" || exit 1
            fi
            
            echo -e "${INDIGO}Adding certificate to ${AQUA}${TRUST_STORE}${NC}..."
            echo -e "${BROWN}keytool -import -v -trustcacerts -alias ${ALIAS} -file ${TEMP_PEM} -keystore ${TRUST_STORE} -storetype BKS -providerclass org.bouncycastle.jce.provider.BouncyCastleProvider -providerpath ${BC_JAR} -storepass secret${NC}"
            echo
            
            keytool -import -v -trustcacerts -alias "$ALIAS" \
                -file "$TEMP_PEM" \
                -keystore "$TRUST_STORE" -storetype BKS \
                -providerclass org.bouncycastle.jce.provider.BouncyCastleProvider \
                -providerpath "$BC_JAR" \
                -storepass secret
            
            # Clean up temporary file
            rm -f "$TEMP_PEM"
            
            if [ $? -eq 0 ]; then
                echo
                print_success "Added certificate from '${cert_file}' with alias '${ALIAS}' to ${TRUST_STORE}!"
            else
                print_error "Failed to import certificate"
                exit 1
            fi
            ;;
            
        *)
            print_error "Unsupported certificate type: ${cert_type}"
            echo
            echo -e "${INDIGO}Supported types:${NC} ${SUPPORTED_TYPES}"
            exit 1
            ;;
    esac
    
    echo
}

# Parse arguments
if [ $# -eq 0 ]; then
    print_error "No certificate file specified"
    usage
    exit 1
fi

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    usage
    exit 0
elif [ "$1" == "--cert" ]; then
    if [ -z "$2" ] || [ -z "$3" ]; then
        print_error "Please provide certificate type and file after --cert"
        usage
        exit 1
    fi
    CERT_TYPE=$(echo "$2" | tr '[:upper:]' '[:lower:]')
    CERT_FILE="$3"
    
    # Validate certificate type
    if ! echo "$SUPPORTED_TYPES" | grep -q "\b${CERT_TYPE}\b"; then
        print_error "Unsupported certificate type: ${CERT_TYPE}"
        echo
        echo -e "${INDIGO}Supported types:${NC} ${SUPPORTED_TYPES}"
        exit 1
    fi
else
    # Auto-detect from file extension
    CERT_FILE="$1"
    CERT_TYPE=$(detect_cert_type "$CERT_FILE")
    
    if [ $? -ne 0 ] || [ -z "$CERT_TYPE" ]; then
        print_error "Could not detect certificate type from file extension."
        echo -e "${INDIGO}Please use --cert option to specify the type.${NC}"
        usage
        exit 1
    fi
fi

# Import the certificate
import_certificate "$CERT_FILE" "$CERT_TYPE"
