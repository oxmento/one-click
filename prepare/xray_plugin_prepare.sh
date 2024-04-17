improt_package "utils" "gen_certificates.sh"


XRAY_PLUGIN_TRANSPORT_MODE=(
ws
wss
quic
grpc
)


ws_mode_logic(){
    get_input_ws_path
    is_disable_mux_logic
    improt_package "webServer" "prepare.sh"
    is_enable_web_server
    if [ "${isEnableWeb}" = "disable" ]; then
        get_all_type_domain
        firewallNeedOpenPort="${shadowsocksport}"
    elif [ "${isEnableWeb}" = "enable" ]; then
        reset_if_ss_port_is_443
        get_cdn_or_dnsonly_type_domain
        get_input_inbound_port 443 "TO_COMPARE_PORTS"
        firewallNeedOpenPort="${INBOUND_PORT}"
        kill_process_if_port_occupy "${firewallNeedOpenPort}"
        web_server_menu
    fi
    if [ "${web_flag}" = "1" ]; then
        choose_caddy_version_menu
    elif [ "${web_flag}" = "2" ]; then
        choose_nginx_version_menu
    fi
    if [ "${domainType}" = "DNS-Only" ] && [ "${isEnableWeb}" = "enable" ]; then
        get_input_mirror_site
        acme_get_certificate_by_force "${domain}"
    elif [ "${domainType}" = "CDN" ] && [ "${isEnableWeb}" = "enable" ]; then
        get_input_mirror_site
        acme_get_certificate_by_api_or_manual "${domain}"
    fi
}

wss_mode_logic(){
    get_cdn_or_dnsonly_type_domain
    get_input_inbound_port 443
    firewallNeedOpenPort="${INBOUND_PORT}"
    shadowsocksport="${firewallNeedOpenPort}"
    kill_process_if_port_occupy "${firewallNeedOpenPort}"
    get_input_ws_path
    is_disable_mux_logic
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    elif [ "${domainType}" = "CDN" ]; then
        acme_get_certificate_by_api_or_manual "${domain}"
    fi
}

quic_mode_logic(){
    get_input_inbound_port 443
    firewallNeedOpenPort="${INBOUND_PORT}"
    shadowsocksport="${firewallNeedOpenPort}"
    kill_process_if_port_occupy "${firewallNeedOpenPort}"
    get_specified_type_domain "DNS-Only"
    is_disable_mux_logic
    acme_get_certificate_by_force "${domain}"
}

grpc_mode_logic(){
    get_cdn_or_dnsonly_type_domain
    get_input_inbound_port 443
    firewallNeedOpenPort="${INBOUND_PORT}"
    shadowsocksport="${firewallNeedOpenPort}"
    kill_process_if_port_occupy "${firewallNeedOpenPort}"
    is_disable_mux_logic
    if [ "${domainType}" = "DNS-Only" ]; then
        acme_get_certificate_by_force "${domain}"
    elif [ "${domainType}" = "CDN" ]; then
        acme_get_certificate_by_api_or_manual "${domain}"
    fi
}

install_prepare_libev_xray_plugin(){
    generate_menu_logic "${XRAY_PLUGIN_TRANSPORT_MODE[*]}" "Transmission mode" "1"
    libev_xray_plugin="${inputInfo}"
    improt_package "utils" "common_prepare.sh"
    if [ "${libev_xray_plugin}" = "1" ]; then
        ws_mode_logic
    elif [ "${libev_xray_plugin}" = "2" ]; then
        wss_mode_logic
    elif [ "${libev_xray_plugin}" = "3" ]; then
        quic_mode_logic
    elif [ "${libev_xray_plugin}" = "4" ]; then
        grpc_mode_logic
    fi
}