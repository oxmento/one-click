improt_package "utils" "gen_certificates.sh"

# simple-tls version
SIMPLE_TLS_VERSION=(
v0.3.4
v0.4.7
latest
)

# simple-tls Transport mode
MODE_V034=(
tls
wss
)

CERTIFICATE_TYPE=(
"Temporary certificate"
"fixedCertificate"
)


is_enable_random_header_for_v034(){
    while true
    do
        _read "Whether to enable Random Header (512B ~ 16KB) to prevent traffic analysis (RH) (default: n) [y/n]:"
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isEnableRh=enable
                ;;
            n|N)
                isEnableRh=disable
                ;;
            *)
                _echo -e "If you enter an error, please re -enter."
                continue
                ;;
        esac
        _echo -r "  rh = ${isEnableRh}"
        break
    done
}

is_enable_padding_data_for_v047(){
    while true
    do
        _read "Whether to enable the Padding-Data mode to prevent traffic analysis (PD) (default: n) [y/n]:"
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isEnablePd=enable
                ;;
            n|N)
                isEnablePd=disable
                ;;
            *)
                _echo -e "If you enter an error, please re -enter."
                continue
                ;;
        esac
        _echo -r "  pd = ${isEnablePd}"
        break
    done
}

is_enable_auth_for_latest(){
    while true
    do
        echo
        _read "Whether the authentication password is enabled to filter the scanning flow (auth) (default: n) [y/n]: "
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isEnableAuth=enable
                ;;
            n|N)
                isEnableAuth=disable
                ;;
            *)
                _echo -e "If you enter an error, please re -enter."
                continue
                ;;
        esac
        _echo -r "  auth = ${isEnableAuth}"
        break
    done
}

get_input_auth_passwd_for_latest(){
    gen_random_str
    _read "Please enter the authentication password (default: ${ran_str12}):"
    auth="${inputInfo}"
    [ -z "${auth}" ] && auth="${ran_str12}"
    _echo -r "${Red}  auth = ${auth}${suffix}"
}

tls_mode_logic_for_v043(){
    do_you_have_domain
    if [ "${doYouHaveDomian}" = "No" ]; then
        firewallNeedOpenPort="${shadowsocksport}"
        get_all_type_domain
    elif [ "${doYouHaveDomian}" = "Yes" ]; then
        get_input_inbound_port 443
        firewallNeedOpenPort="${INBOUND_PORT}"
        shadowsocksport="${firewallNeedOpenPort}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        get_specified_type_domain "DNS-Only"
    fi
    is_enable_random_header_for_v034
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    fi
}

wss_mode_logic_for_v043(){
    do_you_have_domain
    if [ "${doYouHaveDomian}" = "No" ]; then
        firewallNeedOpenPort="${shadowsocksport}"
        get_all_type_domain
    elif [ "${doYouHaveDomian}" = "Yes" ]; then
        get_input_inbound_port 443
        firewallNeedOpenPort="${INBOUND_PORT}"
        shadowsocksport="${firewallNeedOpenPort}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        get_specified_type_domain "DNS-Only"
    fi
    get_input_ws_path
    is_enable_random_header_for_v034
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    fi
}

version_034_logic(){
    generate_menu_logic "${MODE_V034[*]}" "Transmission mode" "1"
    modeOptsNumV034="${inputInfo}"
    if [ "${modeOptsNumV034}" = "1" ]; then
        tls_mode_logic_for_v043
    elif [ "${modeOptsNumV034}" = "2" ]; then
        wss_mode_logic_for_v043
    fi
}

version_047_logic(){
    do_you_have_domain
    if [ "${doYouHaveDomian}" = "No" ]; then
        firewallNeedOpenPort="${shadowsocksport}"
        get_all_type_domain
    elif [ "${doYouHaveDomian}" = "Yes" ]; then
        get_input_inbound_port 443
        firewallNeedOpenPort="${INBOUND_PORT}"
        shadowsocksport="${firewallNeedOpenPort}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        get_specified_type_domain "DNS-Only"
    fi
    is_enable_padding_data_for_v047
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    fi
}

version_latest_logic(){
    do_you_have_domain
    if [ "${doYouHaveDomian}" = "No" ]; then
        firewallNeedOpenPort="${shadowsocksport}"
        get_all_type_domain
        generate_menu_logic "${CERTIFICATE_TYPE[*]}" "Certificate type (when there is no legal certificate)" "1"
        certificateTypeOptNum="${inputInfo}"
    elif [ "${doYouHaveDomian}" = "Yes" ]; then
        get_input_inbound_port 443
        firewallNeedOpenPort="${INBOUND_PORT}"
        shadowsocksport="${firewallNeedOpenPort}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        get_specified_type_domain "DNS-Only"
    fi
    is_disable_mux_logic
    is_enable_auth_for_latest
    if [ "${isEnableAuth}" = "enable" ]; then
        get_input_auth_passwd_for_latest
    fi
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    fi
}

install_prepare_libev_simple_tls(){
    generate_menu_logic "${SIMPLE_TLS_VERSION[*]}" "simple-tls Version" "3"
    SimpleTlsVer="${inputInfo}"
    improt_package "utils" "common_prepare.sh"
    if [ "${SimpleTlsVer}" = "1" ]; then
        version_034_logic
    elif [ "${SimpleTlsVer}" = "2" ]; then
        version_047_logic
    elif [ "${SimpleTlsVer}" = "3" ]; then
        version_latest_logic
    fi
}