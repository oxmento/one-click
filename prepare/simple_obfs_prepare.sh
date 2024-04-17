# Simple-obfs Obfuscation wrapper
OBFUSCATION_WRAPPER=(
http
tls
)


get_input_obfs_mode(){
    generate_menu_logic "${OBFUSCATION_WRAPPER[*]}" "Confusion mode" "1"
    shadowsocklibev_obfs="${optionValue}"
}

get_input_obfs_domain(){
    while true
        do
        _read "Please enter the domain name for Simple-OBFS for confusing (default: cloudfront.com):"
        domain="${inputInfo}"
        [ -z "$domain" ] && domain="cloudfront.com"
        if ! judge_is_domain "${domain}"; then
            _echo -e "Please enter a domain name with correct format."
            continue
        fi
        if ! judge_is_valid_domain "${domain}"; then
            _echo -e "Unable to parse to IP, please enter a correct and effective domain name."
            continue
        fi
        _echo -r "  obfs-host = ${domain}"
        break
    done
}

install_prepare_libev_obfs(){
    get_input_obfs_mode
    get_input_obfs_domain
    firewallNeedOpenPort="${shadowsocksport}"
}

