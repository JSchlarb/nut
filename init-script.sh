#!/bin/sh

set +e

# Run nut-scanner and store the output
OUTPUT=$(nut-scanner -U -P 2>/dev/null)

# Initialize temporary variables with a prefix
TMP_DRIVER=""
TMP_PORT=""
TMP_VENDOR_ID=""
TMP_PRODUCT_ID=""
TMP_PRODUCT=""
TMP_VENDOR=""

# Parse the output line by line
IFS=',' # Set comma as the field separator
for item in $OUTPUT; do
    case $item in
        *driver=*) TMP_DRIVER=$(echo "$item" | cut -d '=' -f 2 | tr -d '"') ;;
        *port=*) TMP_PORT=$(echo "$item" | cut -d '=' -f 2 | tr -d '"') ;;
        *vendorid=*) TMP_VENDOR_ID=$(echo "$item" | cut -d '=' -f 2 | tr -d '"') ;;
        *productid=*) TMP_PRODUCT_ID=$(echo "$item" | cut -d '=' -f 2 | tr -d '"') ;;
        *product=*) TMP_PRODUCT=$(echo "$item" | cut -d '=' -f 2 | tr -d '"') ;;
        *vendor=*) TMP_VENDOR=$(echo "$item" | cut -d '=' -f 2 | tr -d '"') ;;
    esac
done

# Assign temp variables to final ones with fallback to empty
UPS_DRIVER=${UPS_DRIVER:-$TMP_DRIVER}
UPS_PORT=${UPS_PORT:-$TMP_PORT}
UPS_VENDOR_ID=${UPS_VENDOR_ID:-$TMP_VENDOR_ID}
UPS_PRODUCT_ID=${UPS_PRODUCT_ID:-$TMP_PRODUCT_ID}
UPS_PRODUCT=${UPS_PRODUCT:-$TMP_PRODUCT}
UPS_VENDOR=${UPS_VENDOR:-$TMP_VENDOR}

# Print the final configuration with fallback to default values
cat >/etc/nut/ups.conf <<EOF
[${UPS_NAME}]
    driver = "${UPS_DRIVER}"
    port = "${UPS_PORT}"
    vendorid = "${UPS_VENDOR_ID}"
    productid = "${UPS_PRODUCT_ID}"
    product = "${UPS_PRODUCT}"
    vendor = "${UPS_VENDOR}"
${UPS_ADDITIONAL_UPS_CONF}
EOF

cat >/etc/nut/upsd.conf <<EOF
LISTEN 0.0.0.0 3493
EOF

if [ -z "$UPS_API_PASSWORD" ]
then
   UPS_API_PASSWORD=$(dd if=/dev/urandom bs=18 count=1 2>/dev/null | base64)
fi

if [ -z "$UPS_ADMIN_PASSWORD" ]
then
   UPS_ADMIN_PASSWORD=$(dd if=/dev/urandom bs=18 count=1 2>/dev/null | base64)
fi

cat >/etc/nut/upsd.users <<EOF
[admin]
	password = ${UPS_ADMIN_PASSWORD}
	actions = set
	actions = fsd
	instcmds = all

[monitor]
	password = ${UPS_API_PASSWORD}
	upsmon master
EOF
