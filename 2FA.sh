#!/bin/bash
# Installs packages needed for the script
package_installer() {
    if ! command -v oathtool &> /dev/null; then
        echo "oathtool not found. Installing..."
        sudo apt-get install -y oathtool
    fi

    if ! command -v qrencode &> /dev/null; then
        echo "qrencode not found. Installing..."
        sudo apt-get install -y qrencode 
        
    fi
}
# Function to generate a secret key (user)
generate_secret_key() {
    head -c 20 /dev/urandom | base32 | tr -d '='
}

# Function to generate and display QR code (authenticator app)
generate_qr_code() {
    local user=$1
    local key=$2
    local issuer="SSH"

    local uri="otpauth://totp/$issuer:$user?secret=$key&issuer=$issuer"

    qrencode -t ANSI256 -l L "$uri" # Display QR in terminal
}

# Function to verify the OTP
verify_otp() {
    local key=$1
    local user_input=$2
    local otp_generated=$(oathtool --totp -b "$key")

    if [ "$otp_generated" == "$user_input" ]; then
        echo "Access granted"
        return 0  # Allow access
    else
        echo "Access denied"
        return 1  # Deny access
    fi
}

# Main
package_installer
# Ensure a username is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <user>"
    return 1
fi

user=$1
key=$(generate_secret_key) # Generate a secret key (user)

echo "Your secret key: $key"

generate_qr_code "$user" "$key" # Generate and display QR code (authentication provider)

read -p "Enter the OTP from your authenticator app: " user_input

# Verify the OTP
verify_otp "$key" "$user_input"
sh # Keeps shell open