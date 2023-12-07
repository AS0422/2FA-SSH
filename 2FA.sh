#!/bin/bash

# Function to generate a secret key (user)
generate_secret_key() {
    head -c 20 /dev/urandom | base64 | tr -d '='
}

# Function to generate and display QR code (authenticator app)
generate_qr_code() {
    local user=$1
    local key=$2
    local issuer="SSH"

    local uri="otpauth://totp/$issuer:$user?secret=$key&issuer=$issuer"

    qrencode -t ANSI256 -l L "$uri"
}

# Function to verify the OTP
verify_otp() {
    local key=$1
    local user_input=$2
    local otp_generated=$(oathtool --totp -b "$key")

    if [ "$otp_generated" == "$user_input" ]; then
        echo "Access granted"
        exit 0  # Allow access
    else
        echo "Access denied"
        exit 1  # Deny access
    fi
}

# Ensure a username is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <user>"
    exit 1
fi

user=$1
key=$(generate_secret_key) # Generate a secret key (user)

echo "Your secret key: $key"

generate_qr_code "$user" "$key" # Generate and display QR code (authentication provider)

read -p "Enter the OTP from your authenticator app: " user_input

# Verify the OTP
verify_otp "$key" "$user_input"