ACMESH_INSTALL_DIR="/root/.acme.sh"
CF_EMAIL_APIKEY_STORAGE_DIR="/root/.cloudflare"


intall_acme_tool(){
    # Install certificate generator tools
    if [ ! -e ${ACMESH_INSTALL_DIR}/acme.sh ]; then
        _echo -i "The ACME protocol has been installed, which can generate free certificates from Letsencrypt acme.sh "
        curl  https://get.acme.sh | sh
        _echo -i "acme.sh The installation is complete. "
    else
        _echo -i "Certificate generation tool acme.sh Already installed, automatically enter the next step, please select. "
    fi
}

get_latest_acme_sh(){
    _echo -i "upgrade acme.sh To the latest code. "
    ${ACMESH_INSTALL_DIR}/acme.sh --upgrade
}

set_defualt_ca_for_acme_sh(){
    _echo -i "Set the default ca 为  letsencrypt."
    ${ACMESH_INSTALL_DIR}/acme.sh --set-default-ca --server letsencrypt
}

get_input_api_info(){
    while true
    do
        _read "Please enter the cloudflare user name(Mail):"
        CF_Email="${inputInfo}"
        if [ -z "$(echo $CF_Email | grep -E ${EMAIL_RE})" ]; then
            _echo -e "Please enter the correct and legal mailbox."
            continue
        fi
        _echo -r "  email = ${CF_Email}${suffix}"
        break
    done

    while true
    do
        _read "Please enter cloudflare - Global API Key："
        CF_Key="${inputInfo}"
        if [[ $(echo ${#CF_Key}) -ne 37 ]]; then
            _echo -e "Please enter the correct and legal Global API Key."
            continue
        fi
        _echo -r "  key = ${CF_Key}${suffix}"
        break
    done
    if [ ! -e "${CF_EMAIL_APIKEY_STORAGE_DIR}" ]; then
        mkdir -p "${CF_EMAIL_APIKEY_STORAGE_DIR}"
    fi
    echo "CLOUDFLARE_EMAIL=${CF_Email}" > ${CF_EMAIL_APIKEY_STORAGE_DIR}/apiInfo
    echo "CLOUDFLARE_API_KEY=${CF_Key}" >> ${CF_EMAIL_APIKEY_STORAGE_DIR}/apiInfo
    _echo -t "The input cloudflare API information will be stored in${CF_EMAIL_APIKEY_STORAGE_DIR}/apiInfo"
}

choose_api_get_mode(){
    if [ ! -e ${CF_EMAIL_APIKEY_STORAGE_DIR}/apiInfo ]; then
        get_input_api_info
    else
        _echo "detected${Green}${CF_EMAIL_APIKEY_STORAGE_DIR}/apiInfo${suffix}File exists, start to get API information."
        CF_Email=$(cat ${CF_EMAIL_APIKEY_STORAGE_DIR}/apiInfo | grep "CLOUDFLARE_EMAIL" | cut -d= -f2)
        CF_Key=$(cat ${CF_EMAIL_APIKEY_STORAGE_DIR}/apiInfo | grep "CLOUDFLARE_API_KEY" | cut -d= -f2)
        _echo -u "${Red}  email = ${CF_Email}${suffix}"
        _echo -d "${Red}  key = ${CF_Key}${suffix}"
    fi
}

count_down(){
    local seconds=$1

    while [ $seconds -gt 0 ];do
        echo -ne ${Info} Please wait ${seconds} Second...
        sleep 1
        seconds=$(($seconds - 1))
        #\ r The cursor moves to the first, but does not change the line
        # Is equivalent to using the characters after \ r to cover the same length before \ r
        # For example: Echo -E "ABCDEF \ R123" Output: 123DEF
        echo -ne "\r                         \r"
    done
}

_acme_certificate_path(){
    local domain=$1
    local algorithmType=$2

    if [ "${algorithmType}" == "RSA" ]; then
        cerPath="/root/.acme.sh/${domain}/fullchain.cer"
        keyPath="/root/.acme.sh/${domain}/${domain}.key"
    else
        cerPath="/root/.acme.sh/${domain}_ecc/fullchain.cer"
        keyPath="/root/.acme.sh/${domain}_ecc/${domain}.key"
    fi
}

_acme_cmd_by_force(){
    local domain=$1
    local algorithmType=$2

    if [ "${algorithmType}" == "RSA" ]; then
        ${ACMESH_INSTALL_DIR}/acme.sh --issue -d ${domain}   --standalone
    else
        ${ACMESH_INSTALL_DIR}/acme.sh --issue -d ${domain} -k ec-256 --standalone
    fi
    _acme_certificate_path "${domain}" "${algorithmType}"
}

acme_get_certificate_by_force(){
    local domain=$1
    local algorithmType=${2:-"ECC"}

    intall_acme_tool
    get_latest_acme_sh
    set_defualt_ca_for_acme_sh
    if [ ! "$(command -v socat)" ]; then
        _echo -i "Start installing the necessary SOCAT software package when forced generation."
        package_install "socat"
    fi
    _echo -i "Start generating domain names ${domain} Related certificate "
    _acme_cmd_by_force "${domain}" "${algorithmType}"
    _echo -i "${domain} Certificate generation is complete. "
}

_acme_cmd_by_api(){
    local domain=$1
    local algorithmType=$2

    if [ "${algorithmType}" == "RSA" ]; then
        ${ACMESH_INSTALL_DIR}/acme.sh --issue --dns dns_cf -d ${domain}
    else
        ${ACMESH_INSTALL_DIR}/acme.sh --issue --dns dns_cf -d ${domain} -k ec-256
    fi
    _acme_certificate_path "${domain}" "${algorithmType}"
}

acme_get_certificate_by_api(){
    local domain=$1
    local algorithmType=${2:-"ECC"}

    choose_api_get_mode
    intall_acme_tool
    get_latest_acme_sh
    set_defualt_ca_for_acme_sh
    _echo -i "Start generating domain names ${domain} Related certificate "
    export CF_Key=${CF_Key}
    export CF_Email=${CF_Email}
    _acme_cmd_by_api "${domain}" "${algorithmType}"
    _echo -i "${domain} Certificate generation is complete. "
}

_acme_cmd_by_manual(){
    local domain=$1
    local algorithmType=$2
    local isForce=$3

    if [ "${algorithmType}" == "RSA" ]; then
        ${ACMESH_INSTALL_DIR}/acme.sh --issue --dns -d ${domain} --yes-I-know-dns-manual-mode-enough-go-ahead-please ${isForce}
        if [[ $? -ne 0 && $? -ne 2 ]]; then
            _echo -i "Please go to the cloudflare to add a TXT record according to the prompt above, and press the any key after completion."
            _echo -i "If it appears“too many certificates already issued for exact set of domains”Follow, please pressCtrl+C终止。"
            char=`get_char` && count_down 30
            ${ACMESH_INSTALL_DIR}/acme.sh --renew -d ${domain} --yes-I-know-dns-manual-mode-enough-go-ahead-please ${isForce}
        fi
    else
        ${ACMESH_INSTALL_DIR}/acme.sh --issue --dns -d ${domain} -k ec-256 --yes-I-know-dns-manual-mode-enough-go-ahead-please ${isForce}
        if [[ $? -ne 0 && $? -ne 2 ]]; then
            _echo -i "Please go to the cloudflare to add a TXT record according to the prompt above, and press the any key after completion."
            _echo -i "If it appears“too many certificates already issued for exact set of domains”Follow, please pressCtrl+C终止。"
            char=`get_char` && count_down 30
            ${ACMESH_INSTALL_DIR}/acme.sh --renew -d ${domain} --ecc --yes-I-know-dns-manual-mode-enough-go-ahead-please ${isForce}
        fi
    fi
    _acme_certificate_path "${domain}" "${algorithmType}"
}

acme_get_certificate_by_manual(){
    local domain=$1
    local algorithmType=${2:-"ECC"}
    local isForce=${3:-""}

    intall_acme_tool
    get_latest_acme_sh
    set_defualt_ca_for_acme_sh
    _echo -i "Start generating domain names ${domain} Related certificate "
    _acme_cmd_by_manual "${domain}" "${algorithmType}" "${isForce}"
    _echo -i "${domain} Certificate generation is complete. "
}

is_dns_only(){
    local ip=$1

    echo "${ip}" | grep -qP $(get_ip)
    if [[ $? -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

_download_ipcalc(){
    local ipcalc_install_path="/usr/local/bin/ipcalc-0.41"
    local ipcalc_download_url="http://jodies.de/ipcalc-archive/ipcalc-0.41/ipcalc"

    if [ -e "${ipcalc_install_path}" ]; then
        return
    fi
    wget --no-check-certificate -q -c -t3 -T60 -O "${ipcalc_install_path}" "${ipcalc_download_url}"
    if [ $? -ne 0 ]; then
        _echo -e "Dependency package ipcalc download failed."
        exit 1
    fi
    chmod +x "${ipcalc_install_path}"
    [ -f "${ipcalc_install_path}" ] && ln -fs "${ipcalc_install_path}" /usr/bin
}

is_cdn_proxied(){
    local ip=$1
    local ipcalcName aIpRange minIp maxIp minIpDecimal maxIpDecimal ipDecimal isExist
    local ipv4_text_list=`curl -s https://www.cloudflare.com/ips-v4`
    
    ipcalcName='ipcalc-0.41'
    if centosversion 8; then
        ipcalcName='ipcalc'
    else
        _download_ipcalc
    fi
    for aIpRange in ${ipv4_text_list[@]}; do
        minIp=`$ipcalcName $aIpRange | awk '/HostMin:/{print $2}'`
        maxIp=`$ipcalcName $aIpRange | awk '/HostMax:/{print $2}'`
        minIpDecimal=`echo $minIp | awk -F"." '{printf"%.0f",$1*256*256*256+$2*256*256+$3*256+$4}'`
        maxIpDecimal=`echo $maxIp | awk -F"." '{printf"%.0f",$1*256*256*256+$2*256*256+$3*256+$4}'`
        ipDecimal=`echo $ip | awk -F"." '{printf"%.0f",$1*256*256*256+$2*256*256+$3*256+$4}'`
        if [ "$ipDecimal" -ge "$minIpDecimal" ] && [ "$ipDecimal" -le "$maxIpDecimal" ]; then
            isExist="true"
            break
        fi
    done
    if [ "${isExist}" = "true" ]; then
        return 0
    else
        return 1
    fi
}

acme_get_certificate_by_api_or_manual(){
    local domain=$1
    local algorithmType=${2:-"ECC"}
    
    get_domain_ip "${domain}"
    if echo "${domain}" | grep -qE '.cf$|.ga$|.gq$|.ml$|.tk$' && is_cdn_proxied "${domain_ip}"; then
        acme_get_certificate_by_manual "${domain}" "${algorithmType}"
    else
        acme_get_certificate_by_api "${domain}" "${algorithmType}"
    fi
}

acme_get_certificate_by_manual_force(){
    local domain=$1
    local algorithmType
    local isForce="--force"

    get_domain_ip "${domain}"
    if ! (echo "${domain}" | grep -qE '.cf$|.ga$|.gq$|.ml$|.tk$' && is_cdn_proxied "${domain_ip}"); then
        _echo -e "This option is manual application Cloudflare CDNModel certificate (3 months of validity), only supports the suffix as.cf .ga .gq .ml .TK's domain name."
        exit 1
    fi
    if [ -d "/root/.acme.sh/${domain}" ]; then
        algorithmType="RSA"
    elif [ -d "/root/.acme.sh/${domain}_ecc" ]; then
        algorithmType="ECC"
    else
        _echo -e "exist/root/.acme.sh/Can't find a record of $ {domain} in the directory, and do not provide compulsory renewal applications。"
        exit 1
    fi
    acme_get_certificate_by_manual "${domain}" "${algorithmType}" "${isForce}"
}