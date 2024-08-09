FROM alpine:3.20.2

ENV UPS_NAME="ups" \
    UPS_DESC="UPS" \
    UPS_DRIVER="" \
    UPS_PORT="" \
    UPS_VENDOR_ID="" \
    UPS_PRODUCT_ID="" \
    UPS_PRODUCT="" \
    UPS_VENDOR="" \
    UPS_ADDITIONAL_UPS_CONF="" \
    UPS_API_PASSWORD="" \
    UPS_ADMIN_PASSWORD=""

RUN set -ex; \
	apk add nut \
	; \
	adduser nut root \
	; \
    # https://gitlab.alpinelinux.org/alpine/aports/-/issues/16216
    ln -s /usr/lib/libusb-1.0.so.0 /usr/lib/libusb-1.0.so \
    ;\
    mkdir /var/run/nut \
    ; \
    chown nut:nut /var/run/nut

COPY --chmod=777 init-script.sh /opt/init-script.sh

EXPOSE 3493

