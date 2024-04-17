do_you_have_domain(){
    while true
    do
        _read "Do you have your own domain name?(default: n) [y/n]:"
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                doYouHaveDomian=Yes
                ;;
            n|N)
                doYouHaveDomian=No
                ;;
            *)
                _echo -e "If you enter an error, please re -enter."
                continue
                ;;
        esac
        _echo -r "  selected = ${doYouHaveDomian}"
        break
    done
}

_get_input_domain(){
    local domainTypeTip=$1

    while true
    do
        _read "Please enter a domain name(${domainTypeTip})："
        domain="${inputInfo}"
        if ! judge_is_domain "${domain}"; then
            _echo -e "Please enter a domain name with correct format."
            continue
        fi
        if ! judge_is_valid_domain "${domain}"; then
            _echo -e "Unable to parse to IP, please enter a correct and effective domain name."
            continue
        fi
        break
   done
}

get_specified_type_domain(){
    # typeTip value：CDN，DNS-Only，Other
    local typeTip=$1

    while true
        do
        _get_input_domain "${typeTip}"
        domainType=$(judge_domain_type "${domain_ip}")
        if [ "${domainType}" = "${typeTip}" ]; then
            _echo -r "  domain = ${domain} (${domainType})"
            break
        else
            _echo -e "Please enter one${typeTip}Type of domain name."
            continue
        fi
    done
}

get_cdn_or_dnsonly_type_domain(){
    local typeTip="CDN or DNS-Only"

    while true
        do
        _get_input_domain "${typeTip}"
        domainType=$(judge_domain_type "${domain_ip}")
        if [ "${domainType}" = "Other" ]; then
            _echo -e "Please enter one${typeTip}Type of domain name."
            continue
        fi
        _echo -r "  domain = ${domain} (${domainType})"
        break
    done
}

get_all_type_domain(){
    while true
    do
        _read "Please enter a domain name (default: cloudfront.com):"
        domain="${inputInfo}"
        [ -z "${domain}" ] && domain="cloudfront.com"
        if ! judge_is_domain "${domain}"; then
            _echo -e "Please enter a domain name with correct format."
            continue
        fi
        if ! judge_is_valid_domain "${domain}"; then
            _echo -e "Unable to parse to IP, please enter a correct and effective domain name."
            continue
        fi
        unset domainType
        _echo -r "  domain = ${domain}"
        break
   done
}

get_input_ws_path(){
    gen_random_str
    while true
    do
        _read "Please enter your websocket diversion path (default：/${ran_str5}):"
        path="${inputInfo}"
        [ -z "${path}" ] && path="/${ran_str5}"
        if ! judge_is_path "${path}"; then
            _echo -e "Please enter the path / beginning."
            continue
        fi
        _echo -r "  path = ${path}"
        break
    done
}

_get_input_mux_max_stream() {
    while true
    do
        _read "Please enter a maximum reuse flow in the actual TCP connection (default: 8):"
        mux="${inputInfo}"
        [ -z "${mux}" ] && mux=8
        expr "${mux}" + 1 &>/dev/null
        if ! judge_is_num "${mux}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${mux}"; then
            _echo -e "Please enter a number of non -0."
            continue
        fi
        if ! judge_num_in_range "${mux}" "1024"; then
            _echo -e "Please enter a number between 1-65535."
            continue
        fi
        echo
        echo -e "${Red}  mux = ${mux}${suffix}"
        echo
        break
    done
}

_is_disable_mux(){
    while true
    do
        _read "Whether to disable MUX (default: n) [y/n]:"
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isDisableMux=disable
                ;;
            n|N)
                isDisableMux=enable
                ;;
            *)
                _echo -e "If you enter an error, please re -enter!"
                continue
                ;;
        esac
        _echo -r "  mux = ${isDisableMux}"
        break
    done
}

is_disable_mux_logic(){
    _is_disable_mux
    if [ "${isDisableMux}" = "enable" ]; then
        _get_input_mux_max_stream
        clientMux=";mux=${mux}"
    fi
}

get_input_mirror_site(){
    while true
    do
        _echo -u "${Tip}The site is recommended to meet (located overseas, supports the HTTPS protocol, and will be used to transmit large traffic ...). It is not recommended to use the default value."
        _read -d "Please enter the site where you need a mirror (default：https://www.bing.com)："
        mirror_site="${inputInfo}"
        [ -z "${mirror_site}" ] && mirror_site="https://www.bing.com"
        if ! judge_is_https_begin_site "${mirror_site}"; then
            _echo -e "Please enter to ${Red} https:// ${suffix}At the beginning, to${Red} domain name ${suffix}End URL."
            continue
        fi
        if ! judge_is_valid_domain "${mirror_site}"; then
            _echo -e "Unable to parse to IP, please enter a correct and effective domain name."
            continue
        fi
        _echo -r "  mirror_site = ${mirror_site}"
        break
    done
}

get_input_inbound_port() {
    while true
    do
        local DEFAULT_PORT="${1}"
        _read "Please enter the in -site monitoring port on the server side (the port to be released in the firewall)[1-65535] (default: ${DEFAULT_PORT}):"
        INBOUND_PORT="${inputInfo}"
        [ -z "${INBOUND_PORT}" ] && INBOUND_PORT="${DEFAULT_PORT}"
        if ! judge_is_num "${INBOUND_PORT}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${INBOUND_PORT}"; then
            _echo -e "Please enter a number of non -0 starts."
            continue
        fi
        if ! judge_num_in_range "${INBOUND_PORT}" "65535"; then
            _echo -e "Please enter a number between 1-65535."
            continue
        fi
        if [ "${domainType}" = "CDN" ]; then
            local CF_CDN_HTTPS_PORTS=(443 2053 2083 2087 2096 8443)
            if [[ ! " ${CF_CDN_HTTPS_PORTS[@]} " =~ " ${INBOUND_PORT} " ]]; then 
                _echo -e "Cloudflare allows HTTPS traffic to take CDN ports: 443 2053 2083 2087 2096 8443"
                continue
            fi
        fi
        local WHETHER_TO_COMPARE_PORTS="${2}"
        if [ "${WHETHER_TO_COMPARE_PORTS}" = "TO_COMPARE_PORTS" ]; then
            if judge_is_equal_num "${INBOUND_PORT}" "${shadowsocksport}"; then
                _echo -e "Please enter a different number from the SS port."
                continue
            fi
            if [ "${INBOUND_PORT}" = 80 ]; then
                _echo -e "Cloak、Caddy、nginx It will occupy port 80, please re -enter."
                continue
            fi
        fi
        kill_process_if_port_occupy "${INBOUND_PORT}"
        _echo -r "  inbound port = ${INBOUND_PORT}"
        break
    done
}