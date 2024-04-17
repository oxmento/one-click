get_input_port(){
    while true
    do
        gen_random_prot
        _read "Please enter the monitoring port[1-65535] (default: ${ran_prot}):"
        listen_port="${inputInfo}"
        [ -z "${listen_port}" ] && listen_port="${ran_prot}"
        if ! judge_is_num "${listen_port}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${listen_port}"; then
            _echo -e "Please enter a number of non -0 starts."
            continue
        fi
        if ! judge_num_in_range "${listen_port}" "65535"; then
            _echo -e "Please enter a number between 1-65535."
            continue
        fi
        if judge_is_equal_num "${listen_port}" "${shadowsocksport}"; then
            _echo -e "Please enter a different number from the SS port."
            continue
        fi
        kill_process_if_port_occupy "${listen_port}"
        _echo -r "  port = ${listen_port}"
        break
    done
}

get_input_password(){
    gen_random_str
    _read "Please enter the password (default: ${ran_str12}):"
    rabbitKey="${inputInfo}"
    [ -z "${rabbitKey}" ] && rabbitKey=${ran_str12}
    _echo -r "  password = ${rabbitKey}"
}

get_input_log_level(){
    local LEVEL=(OFF FATAL ERROR WARN INFO DEBUG)

    generate_menu_logic "${LEVEL[*]}" "Diary level" "5"
    rabbitLevel="${inputInfo}"
}

install_prepare_libev_rabbit_tcp(){
    get_input_port
    firewallNeedOpenPort="${listen_port}"
    get_input_password
    get_input_log_level
}