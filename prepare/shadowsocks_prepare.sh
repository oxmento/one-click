# ss development language version
SS_DLV=(
ss-libev
ss-rust
go-ss2
)

SHADOWSOCKS_LIBEV_CIPHERS=(
rc4-md5
salsa20
chacha20
chacha20-ietf
aes-256-cfb
aes-192-cfb
aes-128-cfb
aes-256-ctr
aes-192-ctr
aes-128-ctr
bf-cfb
camellia-128-cfb
camellia-192-cfb
camellia-256-cfb
aes-256-gcm
aes-192-gcm
aes-128-gcm
xchacha20-ietf-poly1305
chacha20-ietf-poly1305
)

SHADOWSOCKS_RUST_CIPHERS=(
none
aes-256-gcm
aes-128-gcm
chacha20-ietf-poly1305
2022-blake3-aes-128-gcm
2022-blake3-aes-256-gcm
2022-blake3-chacha20-poly1305
)

GO_SHADOWSOCKS2_CIPHERS=(
AEAD_AES_128_GCM
AEAD_AES_256_GCM
AEAD_CHACHA20_POLY1305
)


choose_ss_install_version(){
    generate_menu_logic "${SS_DLV[*]}" "Shadowsocks Version" "2"
    SS_VERSION="${optionValue}"
}

install_prepare_port() {
    while true
    do
        gen_random_prot
        _read "Please enter the monitoring port[1-65535] (default: ${ran_prot}):"
        shadowsocksport="${inputInfo}"
        [ -z "${shadowsocksport}" ] && shadowsocksport="${ran_prot}"
        if ! judge_is_num "${shadowsocksport}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${shadowsocksport}"; then
            _echo -e "Please enter a number of non -0 starts a number of non -0 starts."
            continue
        fi
        if ! judge_num_in_range "${shadowsocksport}" "65535"; then
            _echo -e "Please enter a number between 1-65535."
            continue
        fi
        kill_process_if_port_occupy "${shadowsocksport}"
        _echo -r "  port = ${shadowsocksport}"
        break
    done
}

install_prepare_password(){
    gen_random_str
    _read "Please enter the password (default: ${ran_str12}):"
    shadowsockspwd="${inputInfo}"
    [ -z "${shadowsockspwd}" ] && shadowsockspwd="${ran_str12}"
    _echo -r "  password = ${shadowsockspwd}"
}

gen_random_psk(){
    shadowsockspwd=$(openssl rand -base64 "$1")
    _echo -i "You choseAEAD-2022 Encryption, the SS-RUST password is changed to automatic generating PSK, as follows："
    _echo -r "  password = ${shadowsockspwd}"
}

install_prepare_cipher(){
    while true
    do
        if [ "${SS_VERSION}" = "ss-libev" ]; then
            local tempNum=17
            local SHADOWSOCKS_CIPHERS=( "${SHADOWSOCKS_LIBEV_CIPHERS[@]}" )
        elif [ "${SS_VERSION}" = "ss-rust" ]; then
            local tempNum=3
            local SHADOWSOCKS_CIPHERS=( "${SHADOWSOCKS_RUST_CIPHERS[@]}" )
        elif [ "${SS_VERSION}" = "go-ss2" ]; then
            local tempNum=1
            local SHADOWSOCKS_CIPHERS=( "${GO_SHADOWSOCKS2_CIPHERS[@]}" )
        fi
        generate_menu_logic "${SHADOWSOCKS_CIPHERS[*]}" "Shadowsocks Encryption" "${tempNum}"
        shadowsockscipher="${optionValue}"
        if [ "${shadowsockscipher}" == "AEAD_AES_128_GCM" ]; then
            shadowsockscipher="aes-128-gcm"
        elif [ "${shadowsockscipher}" == "AEAD_AES_256_GCM" ]; then
            shadowsockscipher="aes-256-gcm"
        elif [ "${shadowsockscipher}" == "AEAD_CHACHA20_POLY1305" ]; then
            shadowsockscipher="chacha20-ietf-poly1305"
        fi
        if [ "${shadowsockscipher}" = "2022-blake3-aes-128-gcm" ]; then
            gen_random_psk 16
        elif [ "${shadowsockscipher}" = "2022-blake3-aes-256-gcm" ]; then
            gen_random_psk 32
        elif [ "${shadowsockscipher}" = "2022-blake3-chacha20-poly1305" ]; then
            gen_random_psk 32
        else
            CipherMark="Non-AEAD-2022"
        fi
        break
    done
}