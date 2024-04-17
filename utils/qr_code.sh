gen_qr_code(){
    local ss_url=$1

    if [[ $(echo "${ss_url}" | grep "^ss://") ]]; then
        if [ "$(command -v qrencode)" ]; then
            _echo "Generate a QR code as follows："
            qrencode -m 2 -l L -t ANSIUTF8 -k "${ss_url}"
            _echo -t "Please check whether the configuration is correct after scanning the code. If there is a difference, please adjust manually by yourself."
        else
            _echo -e "Manually generates a QR code failure, please confirm whether Qrencode is installed normally."
        fi
    else
        _echo -d "Usage: ./ss-plugins.sh scan <a ss link>"
        _echo -e "Only supportss:// At the beginning of the link, please confirm whether the usage and the link you want to generate is correct."
        exit 1
    fi
}