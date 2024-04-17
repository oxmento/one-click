# cloak encryption method
CLOAK_ENCRYPTION_METHOD=(
plain
aes-128-gcm
aes-256-gcm
chacha20-poly1305
)


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

get_input_rediraddr(){
    local tempArray=("${domain}" "${domain_ip}")

    generate_menu_logic "${tempArray[*]}" "Redirect address(RedirAddr):" "1"
    ckwebaddr="${optionValue}"
}

get_cloak_encryption_method(){
    generate_menu_logic "${CLOAK_ENCRYPTION_METHOD[*]}" "Encryption(EncryptionMethod):" "1"
    encryptionMethod="${optionValue}"
}

judge_str_only_contains_comma(){
    local domainStr=$1

    domainStr="$(echo $altNames | tr ',' ' ')"
    if judge_is_nul_str "${domainStr}"; then
        return 0
    else
        return 1
    fi
}

judge_is_separated_by_comma_domain(){
    local domainStr=$1
    local domainRe="(www\.)?[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+(:\d+)*(\/\w+\.\w+)*"

    domainStr="$(echo $altNames | sed -E 's/\ /,/g;s/,+/,/g;s/^,+//g;s/,+$//g' | tr ',' ' ')"
    domainStr="$(echo $domainStr | sed -E "s/${domainRe}//g")"
    if judge_is_nul_str "${domainStr}"; then
        return 0
    else
        return 1
    fi
}

get_input_alternativenames(){
    while true
    do
        _read "Please enter the AlternativeNames parameter (example: Cloudflare.com, github.com) (default: skip)："
        altNames="${inputInfo}"
        if judge_is_nul_str "${altNames}"; then
            NumConn=4
            AlternativeNames=""
            _echo -r "  AlternativeNames = jump over"
            _echo -t "You can set it yourself on your own. If you set it yourself, please pay attention to set NUMCONN to 0."
            break
        fi
        if judge_str_only_contains_comma "${altNames}"; then
            _echo -e "The input character $ {red} only exists only comma $ {suffix}, please re -enter."
            continue
        fi
        if judge_is_separated_by_comma_domain "${altNames}"; then
            _echo -e "The input character exists $ {red} Inferred characters $ {suffix}, please re -enter."
            continue
        fi

        local domain
        local mark=0
        altNamesArray=(`echo $altNames | sed -E 's/\ /,/g;s/,+/,/g;s/^,+//g;s/,+$//g' | tr ',' ' '`)
        for domain in "${altNamesArray[@]}"; do
            if ! judge_is_valid_domain "${domain}"; then
                mark=$(("${mark}" + 1))
                if [ "$mark" -eq 1 ]; then
                    _echo -g "The input invalid characters are as follows："
                fi
                echo -e "  ${domain}"
            fi
        done
        if [ "$mark" -ne 0 ]; then
            _echo -e "Detecting the input character existence${Red}Unable to get the domain name of IP${suffix}，please enter again."
            continue
        fi
        NumConn=0
        AlternativeNames=";AlternativeNames=$(echo $altNames | sed -E 's/\ /,/g;s/,+/,/g;s/^,+//g;s/,+$//g')"
        _echo -r "  AlternativeNames = $(echo $altNames | sed -E 's/\ /,/g;s/,+/,/g;s/^,+//g;s/,+$//g')"
        break
    done
}

install_prepare_libev_cloak(){
    reset_if_ss_port_is_443
    improt_package "utils" "common_prepare.sh"
    get_input_inbound_port 443 "TO_COMPARE_PORTS"
    firewallNeedOpenPort="${INBOUND_PORT}"
    kill_process_if_port_occupy "${firewallNeedOpenPort}"
    get_input_domain
    get_input_rediraddr
    get_cloak_encryption_method
    get_input_alternativenames
}