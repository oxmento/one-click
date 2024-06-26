view_json_config(){
    local args=$1
    echo
    echo -e "${Green}Configuration path:${suffix}${args}"
    if [ ! "$(command -v jq)" ]; then
        package_install "jq" > /dev/null 2>&1
    fi
    cat ${args} | jq .
}

view_webserver_config(){
    local args=$1
    echo
    echo -e "${Green}Configuration path:${suffix}${args}"
    cat ${args}
}

view_config_logic(){
    if [[ -e ${CADDY_CONF_FILE} ]] || [[ -e ${NGINX_CONFIG} ]]; then
        while true
        do
            read -e -p "Whether to check Web Server Configuration (default: n) [y/n]: " yn
            [ -z "${yn}" ] && yn="N"
            case "${yn:0:1}" in
                y|Y)
                    isEnable=enable
                    ;;
                n|N)
                    isEnable=disable
                    ;;
                *)
                    continue
                    ;;
            esac
            break
        done
    fi

    if [[ ${isEnable} == enable ]]; then
        if [[ -e ${CADDY_CONF_FILE} ]]; then
            view_webserver_config "${CADDY_CONF_FILE}"
        fi

        if [[ -e ${NGINX_CONFIG} ]]; then
            view_webserver_config "${NGINX_CONFIG}"
        fi
    fi

    if [[ -e ${SHADOWSOCKS_CONFIG} ]]; then
        view_json_config "${SHADOWSOCKS_CONFIG}"
    fi

    if [[ -e ${KCPTUN_CONFIG} ]]; then
        view_json_config "${KCPTUN_CONFIG}"
    fi

    if [[ -e ${CK_SERVER_CONFIG} ]]; then
        view_json_config "${CK_SERVER_CONFIG}"
    fi

    if [[ -e ${CK_CLIENT_CONFIG} ]]; then
        view_json_config "${CK_CLIENT_CONFIG}"
    fi

    if [[ -e ${RABBIT_CONFIG} ]]; then
        view_json_config "${RABBIT_CONFIG}"
    fi

    echo
    _echo -i "If there is nothing, it means not installed。"
    echo
}














