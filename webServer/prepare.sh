is_enable_web_server(){
    if [ -e "${CADDY_BIN_PATH}" ] && [ ! -e "${WEB_INSTALL_MARK}" ]; then
        _echo -i "Caddy has been installed：${CADDY_BIN_PATH}，skip enabling web server camouflage settings。"
        return
    elif [ -e "${NGINX_BIN_PATH}" ] && [ ! -e "${WEB_INSTALL_MARK}" ]; then
        _echo -i "Nginx has been installed：${NGINX_BIN_PATH}，skip enabling web server camouflage settings。"
        return
    fi

    while true
    do
        _read "Whether to enable the web server camouflage (default: n) [y/n]:"
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                isEnableWeb=enable
                ;;
            n|N)
                isEnableWeb=disable
                ;;
            *)
                _echo -e "If you enter an error, please re -enter."
                continue
                ;;
        esac
        _echo -r "  web = ${isEnableWeb}"
        break
    done
}

web_server_menu(){
    local WEB_SERVER_STYLE=(caddy nginx)

    generate_menu_logic "${WEB_SERVER_STYLE[*]}" "A web server" "1"
    web_flag="${inputInfo}"
}

choose_nginx_version_menu(){
    local NGINX_PACKAGES_V=(Stable Mainline)

    generate_menu_logic "${NGINX_PACKAGES_V[*]}" "Nginx software package version" "1"
    pkg_flag="${inputInfo}"
}

choose_caddy_version_menu(){
    local CADDY_PACKAGES_V=(Caddy Caddy2)

    generate_menu_logic "${CADDY_PACKAGES_V[*]}" "Caddy Software version" "1"
    caddyVerFlag="${inputInfo}"
}