install_gost_plugin(){
    cd ${CUR_DIR}
    
    if [ ! "$(command -v unzip)" ]; then
        package_install "unzip" > /dev/null 2>&1
    fi
    pushd ${TEMP_DIR_PATH} > /dev/null 2>&1
    unzip -oq ${gost_plugin_file}.zip
    chmod +x gost-plugin
    mv gost-plugin ${GOST_PLUGIN_INSTALL_PATH}
    if [ $? -eq 0 ]; then
        [ -f ${GOST_PLUGIN_BIN_PATH} ] && ln -fs ${GOST_PLUGIN_BIN_PATH} /usr/bin
        _echo -i "gost-plugin Successful installation."
    else
        _echo -e "gost-plugin installation failed."
        install_cleanup
        exit 1
    fi
    popd > /dev/null 2>&1
}