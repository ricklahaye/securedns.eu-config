#!/bin/bash
KEYS_DIR="/usr/local/etc/dnscrypt-wrapper/keys"
STKEYS_DIR="${KEYS_DIR}/short-term"

prune() {
    /usr/bin/find "$STKEYS_DIR" -type f -cmin +1440 -exec rm -f {} \;
}

rotation_needed() {
    if [ $(/usr/bin/find "$STKEYS_DIR" -name '*.cert' -type f -cmin -720 -print -quit | wc -l | sed 's/[^0-9]//g') -le 0 ]; then
        echo true
    else
        echo false
    fi
}

new_key() {
    ts=$(date '+%s')
    /usr/local/sbin/dnscrypt-wrapper --gen-crypt-keypair \
        --crypt-secretkey-file="${STKEYS_DIR}/${ts}.key" &&
    /usr/local/sbin/dnscrypt-wrapper --gen-cert-file \
        --provider-publickey-file="${KEYS_DIR}/public.key" \
        --provider-secretkey-file="${KEYS_DIR}/secret.key" \
        --crypt-secretkey-file="${STKEYS_DIR}/${ts}.key" \
        --provider-cert-file="${STKEYS_DIR}/${ts}.cert" \
        --cert-file-expire-days=1
    [ $? -ne 0 ] && rm -f "${STKEYS_DIR}/${ts}.key" "${STKEYS_DIR}/${ts}.cert"
}

stkeys_files() {
    res=""
    for file in $(ls "$STKEYS_DIR"/[0-9]*.key); do
        res="${res}${file},"
    done
    echo "$res"
}

stcerts_files() {
    res=""
    for file in $(ls "$STKEYS_DIR"/[0-9]*.cert); do
        res="${res}${file},"
    done
    echo "$res"
}


mkdir -p "$STKEYS_DIR"
prune
[ $(rotation_needed) = true ] && new_key

exec /usr/local/sbin/dnscrypt-wrapper -V \
    --user=dnscrypt-wrapper \
    --listen-address=0.0.0.0:5353 \
    --resolver-address=127.0.0.1:53 \
    --provider-name="2.dnscrypt-cert.securedns.eu" \
    --provider-cert-file="$(stcerts_files)" \
    --crypt-secretkey-file=$(stkeys_files) &

exec /usr/local/sbin/dnscrypt-wrapper -V \
    --user=dnscrypt-wrapper \
    --listen-address=[2a03:b0c0:0:1010::e9a:3001]:5353 \
    --resolver-address=127.0.0.1:53 \
    --provider-name="2.dnscrypt-cert.securedns.eu" \
    --provider-cert-file="$(stcerts_files)" \
    --crypt-secretkey-file=$(stkeys_files) &

