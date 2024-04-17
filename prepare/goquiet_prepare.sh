get_input_domain(){
    while true
    do
        _read "Please enter the redirection to the domain name (default: cloudfront.com):"
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
        _echo -r "  ServerName = ${domain}"
        break
    done
}

get_input_webaddr(){
    while true
    do
        _read "Please enter the IP corresponding to the corresponding to the domain name (default: ${domain_ip}:443):"
        gqwebaddr="${inputInfo}"
        [ -z "$gqwebaddr" ] && gqwebaddr="${domain_ip}:443"
        if ! judge_is_ip_colon_port_format "${gqwebaddr}"; then
            _echo -e "Please enter the correct and legal IP: 443 combination."
            continue
        fi
        _echo -r "  WebServerAddr = ${gqwebaddr}"
        break
    done
}

get_input_gqkey(){
    gen_random_str
    _read "Please enter the key (default: ${ran_str12}):"
    gqkey="${inputInfo}"
    [ -z "$gqkey" ] && gqkey=${ran_str12}
    _echo -r "  Key = ${gqkey}"
}

install_prepare_libev_goquiet(){
    improt_package "utils" "common_prepare.sh"
    get_input_inbound_port 443
    firewallNeedOpenPort="${INBOUND_PORT}"
    shadowsocksport="${firewallNeedOpenPort}"
    kill_process_if_port_occupy "${firewallNeedOpenPort}"
    get_input_domain
    get_input_webaddr
    get_input_gqkey
}

