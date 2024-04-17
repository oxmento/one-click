install_qtun(){
    cd ${CUR_DIR}
    pushd ${TEMP_DIR_PATH} > /dev/null 2>&1
    tar xf ${qtun_file}.tar.xz
    if [ ! -d ${QTUN_INSTALL_PATH} ]; then
        mkdir -p ${QTUN_INSTALL_PATH}
    fi
    mv qtun-server ${QTUN_BIN_PATH}
    if [ $? -eq 0 ]; then
        [ -f ${QTUN_BIN_PATH} ] && ln -fs ${QTUN_BIN_PATH} /usr/bin
        _echo -i "qtun Successful installation."
    else
        _echo -e "qtun installation failed."
        install_cleanup
        exit 1
    fi
    popd > /dev/null 2>&1
}