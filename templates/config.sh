ss_server_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
	    "server":${server_value},
	    "server_port":${shadowsocksport},
	    "password":"${shadowsockspwd}",
	    "timeout":300,
	    "method":"${shadowsockscipher}",
	    "ipv6_first": ${ipv6First},
	    "nameserver":"8.8.8.8",
	    "mode":"${serverTcpAndUdp}"
	}
	EOF
}

ss_plugin_server_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
	    "server":${server_value},
	    "server_port":${shadowsocksport},
	    "password":"${shadowsockspwd}",
	    "timeout":300,
	    "method":"${shadowsockscipher}",
	    "ipv6_first": ${ipv6First},
	    "nameserver":"8.8.8.8",
	    "mode":"${serverTcpAndUdp}",
	    "plugin":"${serverPluginName}",
	    "plugin_opts":"${serverPluginOpts}"
	}
	EOF
}

kcptun_server_config(){
	cat > ${KCPTUN_CONFIG}<<-EOF
	{
	    "listen": ":${listen_port}",
	    "target": "127.0.0.1:${shadowsocksport}",
	    "key": "${key}",
	    "crypt": "${crypt}",
	    "mode": "${mode}",
	    "mtu": ${MTU},
	    "sndwnd": ${sndwnd},
	    "rcvwnd": ${rcvwnd},
	    "datashard": ${datashard},
	    "parityshard": ${parityshard},
	    "dscp": ${DSCP},
	    "nocomp": ${nocomp},
	    "tcp": ${KP_TCP}
	}
	EOF
}

cloak_server_config(){
	cat > ${CK_SERVER_CONFIG}<<-EOF
	{
	    "ProxyBook":{
	    "shadowsocks":["tcp","127.0.0.1:${shadowsocksport}"]
	    },
	    "BindAddr":[":${firewallNeedOpenPort}",":80"],
	    "BypassUID":[],
	    "RedirAddr":"${ckwebaddr}",
	    "PrivateKey":"${ckpv}",
	    "AdminUID":"${ckauid}",
	    "DatabasePath":"${CK_DB_PATH}/userinfo.db"
	}
	EOF
}

cloak_client_config(){
	cat > ${CK_CLIENT_CONFIG}<<-EOF
	{
	    "Transport":"direct",
	    "ProxyMethod":"shadowsocks",
	    "EncryptionMethod":"${encryptionMethod}",
	    "UID":"${ckauid}",
	    "PublicKey":"${ckpub}",
	    "ServerName":"${domain}",
	    "NumConn":4,
	    "BrowserSig":"chrome",
	    "StreamTimeout":300
	}
	EOF
}

rabbit_tcp_server_config(){
	cat > ${RABBIT_CONFIG}<<-EOF
	{
	    "mode":"s",
	    "rabbit_addr":":${listen_port}",
	    "password":"${rabbitKey}",
	    "verbose":${rabbitLevel}
	}
	EOF
}

ss_client_links(){
    local head cipher ipPort

    head="ss://"
    cipher=$(get_str_base64_encode "${shadowsockscipher}:${shadowsockspwd}")
    ipPort="@${clientIpOrDomain}:${firewallNeedOpenPort}"
    sslinks="${head}${cipher}${ipPort}"
}

ss_plugins_client_links(){
    local head cipher ipPort pluginName pluginOpts

    head="ss://"
    cipher=$(get_str_base64_encode "${shadowsockscipher}:${shadowsockspwd}")
    ipPort="@${clientIpOrDomain}:${firewallNeedOpenPort}"
    pluginName="/?plugin=${clientPluginName}"
    plugin_opts=$(url_encode ";${clientPluginOpts}")
    sslinks="${head}${cipher}${ipPort}${pluginName}${plugin_opts}"
}

ss_config_info(){
    echo -e "                                                     " >> ${HUMAN_CONFIG}
    echo -e " Shadowsocks Configuration information：             " >> ${HUMAN_CONFIG}
    echo -e "                                                     " >> ${HUMAN_CONFIG}
    echo -e " address     : ${Red}${clientIpOrDomain}${suffix}    " >> ${HUMAN_CONFIG}
    echo -e " port     : ${Red}${firewallNeedOpenPort}${suffix}   " >> ${HUMAN_CONFIG}
    echo -e " password     : ${Red}${shadowsockspwd}${suffix}     " >> ${HUMAN_CONFIG}
    echo -e " encryption     : ${Red}${shadowsockscipher}${suffix}" >> ${HUMAN_CONFIG}
}

plugins_config_info(){
    echo -e " Plug -in program : ${Red}${clientPluginName}${suffix}  " >> ${HUMAN_CONFIG}
    echo -e " Plug -in option : ${Red}${clientPluginOpts}${suffix}   " >> ${HUMAN_CONFIG}
    echo -e " Plug -in parameter : ${Red}${clientPluginArgs}${suffix}" >> ${HUMAN_CONFIG}
}

kcptun_config_info(){
    echo -e "                                                         " >> ${HUMAN_CONFIG}
    echo -e " Mobile parameter : ${clientPhoneArgs}                   " >> ${HUMAN_CONFIG}
    echo -e "                                                         " >> ${HUMAN_CONFIG}
}

cloak_config_info(){
    echo -e "                                                         " >> ${HUMAN_CONFIG}
    echo -e " AdminUID : ${ckauid}                                    " >> ${HUMAN_CONFIG}
    echo -e " CK  Public key : ${ckpub}                               " >> ${HUMAN_CONFIG}
    echo -e " CK  Private key : ${ckpv}                               " >> ${HUMAN_CONFIG}
    echo -e "                                                         " >> ${HUMAN_CONFIG}
}

qrcode_config_info(){
    echo -e "                                                   " >> ${HUMAN_CONFIG}
    echo -e " SS QR code : ./ss-plugins.sh scan < ss://links >    " >> ${HUMAN_CONFIG}
    echo -e " SS  Link : ${Green}${sslinks}${suffix}            " >> ${HUMAN_CONFIG}
    echo -e "                                                   " >> ${HUMAN_CONFIG}
}

ss_base_show(){
    ss_config_info
    qrcode_config_info
}

ss_plugins_show(){
    ss_config_info
    plugins_config_info
    qrcode_config_info
}

ss_kcptun_show(){
    ss_config_info
    plugins_config_info
    kcptun_config_info
    qrcode_config_info
}

ss_cloak_show(){
    ss_config_info
    plugins_config_info
    cloak_config_info
    qrcode_config_info
}