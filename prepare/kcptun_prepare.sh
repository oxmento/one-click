# kcptun crypt
KCPTUN_CRYPT=(
aes
aes-128
aes-192
salsa20
blowfish
twofish
cast5
3des
tea
xtea
xor
sm4
none
)

# kcptun mode(no manual)
KCPTUN_MODE=(
fast3
fast2
fast
normal
)


get_input_port(){
    # Set the KCPTUN server monitoring port listen_port
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
    # Set KCPTUN password key
    gen_random_str
    _read "Please enter the password (default: ${ran_str12}):"
    key="${inputInfo}"
    [ -z "${key}" ] && key=${ran_str12}
    _echo -r "  key = ${key}"
}

get_input_crypt(){
    # set up Kcptun Encryption crypt
    generate_menu_logic "${KCPTUN_CRYPT[*]}" "Encryption" "13"
    crypt="${optionValue}"
}

get_input_accelerate_mode(){
    # set up Kcptun Acceleration mode mode
    generate_menu_logic "${KCPTUN_MODE[*]}" "Acceleration mode" "2"
    mode="${optionValue}"
    _echo -t "Acceleration mode and sending window size determine the loss of traffic (Manual is not supported)."
}

get_input_mtu(){
   # set up UDP Packet MTU (Maximum transmission unit) value
    while true
    do
        _read "please set up UDP Packet MTU (Maximum transmission unit) value (default: 1350):"
        MTU="${inputInfo}"
        [ -z "${MTU}" ] && MTU=1350
        if ! judge_is_num "${MTU}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${MTU}"; then
            _echo -e "Please enter a number of non -0 starts."
            continue
        fi
        if [ ${MTU} -lt 1 ]; then
            _echo -e "Please enter a number greater than 0."
            continue
        fi
        _echo -r "  MTU = ${MTU}"
        break
    done
}

get_input_sndwnd(){
    # set up Send window size sndwnd
    while true
    do
        _read "Please send the SET UP Window (SNDWND) size (default: 1024):"
        sndwnd="${inputInfo}"
        [ -z "${sndwnd}" ] && sndwnd=1024
        if ! judge_is_num "${sndwnd}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${sndwnd}"; then
            _echo -e "Please enter a number of non -0 starts."
            continue
        fi
        if [ ${sndwnd} -lt 1 ]; then
            _echo -e "Please enter a number greater than 0."
            continue
        fi
        _echo -r "  sndwnd = ${sndwnd}"
        _echo -t "Send a window to waste too much traffic."
        break
    done
}

get_input_rcvwnd(){
    # set up Receive window size rcvwnd
    while true
    do
        _read "Please set up to receive the window(rcvwnd)Size (default: 1024):"
        rcvwnd="${inputInfo}"
        [ -z "${rcvwnd}" ] && rcvwnd=1024
        if ! judge_is_num "${rcvwnd}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${rcvwnd}"; then
            _echo -e "Please enter a number of non -0."
            continue
        fi
        if [ ${rcvwnd} -lt 1 ]; then
            _echo -e "Please enter a number greater than 0."
            continue
        fi
        _echo -r "  rcvwnd = ${rcvwnd}"
        break
    done
}

get_input_datashard(){
    # set up Prefix datashard
    while true
    do
        _read "Please set the error in SET UP forward(datashard) (default: 10):"
        datashard="${inputInfo}"
        [ -z "${datashard}" ] && datashard=10
        if ! judge_is_num "${datashard}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${datashard}"; then
            _echo -e "Please enter a number of non -0 starts."
            continue
        fi
        if [ ${datashard} -lt 1 ]; then
            _echo -e "Please enter a number greater than 0."
            continue
        fi
        _echo -r "  datashard = ${datashard}"
        _echo -t "This parameter must be the same at both ends."
        break
    done
}

get_input_parityshard(){
    # set up Prefix parityshard
    while true
    do
        _read "Please set the error in SET UP forward(parityshard) (default: 3):"
        parityshard="${inputInfo}"
        [ -z "${parityshard}" ] && parityshard=3
        if ! judge_is_num "${parityshard}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${parityshard}"; then
            _echo -e "Please enter a number of non -0 starts."
            continue
        fi
        if [ ${parityshard} -lt 1 ]; then
            _echo -e "Please enter a number greater than 0."
            continue
        fi
        _echo -r "  parityshard = ${parityshard}"
        _echo -t "This parameter must be the same at both ends."
        break
    done
}

get_input_dscp(){
    # set upDifferential service code point DSCP
    while true
    do
        _read "请set upDifferential service code point(DSCP) (default: 46):"
        DSCP="${inputInfo}"
        [ -z "${DSCP}" ] && DSCP=46
        if ! judge_is_num "${DSCP}"; then
            _echo -e "Please enter a valid number."
            continue
        fi
        if judge_is_zero_begin_num "${DSCP}"; then
            _echo -e "Please enter a number of non -0 starts."
            continue
        fi
        if [ ${DSCP} -lt 1 ]; then
            _echo -e "Please enter a number greater than 0."
            continue
        fi
        _echo -r "  DSCP = ${DSCP}"
        break
    done 
}

is_disable_nocomp(){
    #Whether to close data compression nocomp
    while true
    do
		_read "Whether to disable data compression(nocomp) (default: n) [y/n]:"
        local yn="${inputInfo}"
        [ -z "${yn}" ] && yn="N"
        case "${yn:0:1}" in
            y|Y)
                nocomp='true'
                ;;
            n|N)
                nocomp='false'
                ;;
            *)
                _echo -e "If you enter an error, please re -enter!"
                continue
                ;;
        esac
        _echo -r "  nocomp = ${nocomp}"
		break
	done
}

is_enable_simulate_tcp_connection(){
    if [[ ${nocomp} = true ]]; then
        # Whether to open an analog TCP connection TCP
        while true
        do
            _read "Whether to open an analog TCP connection(tcp) (default: n) [y/n]:"
            local yn="${inputInfo}"
            [ -z "${yn}" ] && yn="N"
            case "${yn:0:1}" in
                y|Y)
                    KP_TCP='true'
                    ;;
                n|N)
                    KP_TCP='false'
                    ;;
                *)
                    _echo -e "Input is wrong, please re -enter!"
                    continue
                    ;;
            esac
            _echo -r "  tcp = ${KP_TCP}"
            break
        done
    else
        KP_TCP='false'
    fi
}

install_prepare_libev_kcptun(){
    get_input_port
    firewallNeedOpenPort="${listen_port}"
    get_input_password
    get_input_crypt
    get_input_accelerate_mode
    get_input_mtu
    get_input_sndwnd
    get_input_rcvwnd
    get_input_datashard
    get_input_parityshard
    get_input_dscp
    is_disable_nocomp
    is_enable_simulate_tcp_connection
}