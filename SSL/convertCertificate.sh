#!/bin/bash
# Author: Rohtash Lakra
# Convert SSL certificate from one format to another
# Usage:
#   ./convertCertificate.sh --from <type> --to <type> <input_file> [output_file]
#   ./convertCertificate.sh --help

# Bootstrap: Find and source script_utils.sh, then setup environment
# Note: SSL is 1 level deep, so use .. instead of ../..
_s="${BASH_SOURCE[0]}"; while [ -L "$_s" ]; do _l="$(readlink "$_s")"; [[ "$_l" != /* ]] && _s="$(cd "$(dirname "$_s")" && pwd)/$_l" || _s="$_l"; done; source "$(cd "$(dirname "$_s")/.." && pwd)/script_utils.sh" && setup_scripts_env "${BASH_SOURCE[0]}"

# Supported formats
SUPPORTED_FORMATS="pem cer crt der p12 pfx txt key"

# Usage function
usage() {
    echo
    echo -e "${DARKBLUE}Usage:${NC}"
    echo -e "  ${AQUA}./convertCertificate.sh --from <type> --to <type> <input_file> [output_file]${NC}"
    echo -e "  ${AQUA}./convertCertificate.sh --help${NC}"
    echo
    echo -e "${INDIGO}Supported formats:${NC}"
    echo -e "  ${BROWN}pem${NC}  - Privacy Enhanced Mail format (Base64 encoded)"
    echo -e "  ${BROWN}cer${NC}  - Certificate file (DER or PEM format)"
    echo -e "  ${BROWN}crt${NC}  - Certificate file (DER or PEM format)"
    echo -e "  ${BROWN}der${NC}  - Distinguished Encoding Rules (binary format)"
    echo -e "  ${BROWN}p12${NC}  - PKCS#12 format (contains private key and certificate)"
    echo -e "  ${BROWN}pfx${NC}  - Personal Information Exchange (same as P12)"
    echo -e "  ${BROWN}txt${NC}  - Text format (extracted from P12/PFX)"
    echo -e "  ${BROWN}key${NC}  - Private key file (PEM format)"
    echo
    echo -e "${INDIGO}Examples:${NC}"
    echo -e "  ${AQUA}./convertCertificate.sh --from p12 --to pem certificate.p12${NC}"
    echo -e "  ${AQUA}./convertCertificate.sh --from pem --to der certificate.pem cert.der${NC}"
    echo -e "  ${AQUA}./convertCertificate.sh --from p12 --to txt certificate.p12${NC}"
    echo -e "  ${AQUA}./convertCertificate.sh --from der --to pem certificate.der${NC}"
    echo
}

# Function to generate output filename
generate_output_filename() {
    local input_file="$1"
    local to_format="$2"
    local output_file="$3"
    
    if [ -n "$output_file" ]; then
        echo "$output_file"
    else
        # Generate output filename from input filename
        local base_name="${input_file%.*}"
        echo "${base_name}.${to_format}"
    fi
}

# Function to convert certificate
convert_certificate() {
    local from_format="$1"
    local to_format="$2"
    local input_file="$3"
    local output_file="$4"
    
    if [ ! -f "$input_file" ]; then
        print_error "Input file not found: ${input_file}"
        exit 1
    fi
    
    output_file=$(generate_output_filename "$input_file" "$to_format" "$output_file")
    
    print_header "Convert Certificate"
    echo -e "${INDIGO}Converting from ${AQUA}${from_format}${INDIGO} to ${AQUA}${to_format}${NC}"
    echo -e "${INDIGO}Input file: ${AQUA}${input_file}${NC}"
    echo -e "${INDIGO}Output file: ${AQUA}${output_file}${NC}"
    echo
    
    # Perform conversion based on formats
    case "${from_format}:${to_format}" in
        p12:txt|pfx:txt)
            echo -e "${BROWN}openssl pkcs12 -in ${input_file} -out ${output_file}${NC}"
            openssl pkcs12 -in "$input_file" -out "$output_file"
            ;;
            
        p12:pem|pfx:pem)
            echo -e "${BROWN}openssl pkcs12 -in ${input_file} -out ${output_file} -nodes${NC}"
            openssl pkcs12 -in "$input_file" -out "$output_file" -nodes
            ;;
            
        p12:key|pfx:key)
            echo -e "${BROWN}openssl pkcs12 -in ${input_file} -nocerts -nodes -out ${output_file}${NC}"
            openssl pkcs12 -in "$input_file" -nocerts -nodes -out "$output_file"
            ;;
            
        pem:der|cer:der|crt:der)
            echo -e "${BROWN}openssl x509 -in ${input_file} -outform DER -out ${output_file}${NC}"
            openssl x509 -in "$input_file" -outform DER -out "$output_file"
            ;;
            
        der:pem|der:cer|der:crt)
            echo -e "${BROWN}openssl x509 -inform DER -in ${input_file} -out ${output_file}${NC}"
            openssl x509 -inform DER -in "$input_file" -out "$output_file"
            ;;
            
        pem:pem|cer:cer|crt:crt)
            # Same format, just copy or verify
            echo -e "${BROWN}Copying/verifying certificate...${NC}"
            cp "$input_file" "$output_file"
            ;;
            
        pem:cer|pem:crt|cer:pem|cer:crt|crt:pem|crt:cer)
            # PEM/CER/CRT are essentially the same, just copy
            echo -e "${BROWN}Copying certificate (PEM/CER/CRT formats are compatible)...${NC}"
            cp "$input_file" "$output_file"
            ;;
            
        *)
            print_error "Unsupported conversion: ${from_format} to ${to_format}"
            echo
            echo -e "${INDIGO}Supported conversions:${NC}"
            echo -e "  ${BROWN}P12/PFX → PEM/TXT/KEY${NC}"
            echo -e "  ${BROWN}PEM/CER/CRT → DER${NC}"
            echo -e "  ${BROWN}DER → PEM/CER/CRT${NC}"
            echo -e "  ${BROWN}PEM/CER/CRT ↔ PEM/CER/CRT${NC} (compatible formats)"
            exit 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo
        print_success "Certificate converted successfully!"
        echo -e "${INDIGO}Output saved to: ${AQUA}${output_file}${NC}"
    else
        echo
        print_error "Failed to convert certificate"
        exit 1
    fi
    echo
}

# Parse arguments
FROM_FORMAT=""
TO_FORMAT=""
INPUT_FILE=""
OUTPUT_FILE=""

if [ $# -eq 0 ]; then
    usage
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --from)
            if [ -z "$2" ]; then
                print_error "Please provide source format after --from"
                usage
                exit 1
            fi
            FROM_FORMAT=$(echo "$2" | tr '[:upper:]' '[:lower:]')
            shift 2
            ;;
        --to)
            if [ -z "$2" ]; then
                print_error "Please provide target format after --to"
                usage
                exit 1
            fi
            TO_FORMAT=$(echo "$2" | tr '[:upper:]' '[:lower:]')
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            if [ -z "$INPUT_FILE" ]; then
                INPUT_FILE="$1"
            elif [ -z "$OUTPUT_FILE" ]; then
                OUTPUT_FILE="$1"
            else
                print_error "Unexpected argument: $1"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [ -z "$FROM_FORMAT" ] || [ -z "$TO_FORMAT" ] || [ -z "$INPUT_FILE" ]; then
    print_error "Missing required arguments"
    usage
    exit 1
fi

# Validate formats
if ! echo "$SUPPORTED_FORMATS" | grep -q "\b${FROM_FORMAT}\b"; then
    print_error "Unsupported source format: ${FROM_FORMAT}"
    echo
    echo -e "${INDIGO}Supported formats:${NC} ${SUPPORTED_FORMATS}"
    exit 1
fi

if ! echo "$SUPPORTED_FORMATS" | grep -q "\b${TO_FORMAT}\b"; then
    print_error "Unsupported target format: ${TO_FORMAT}"
    echo
    echo -e "${INDIGO}Supported formats:${NC} ${SUPPORTED_FORMATS}"
    exit 1
fi

# Perform conversion
convert_certificate "$FROM_FORMAT" "$TO_FORMAT" "$INPUT_FILE" "$OUTPUT_FILE"
