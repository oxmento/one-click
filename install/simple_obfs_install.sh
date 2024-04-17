install_simple_obfs(){
    cd ${CUR_DIR}
    
    simple_obfs_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/shadowsocks/simple-obfs/releases | grep -o '"tag_name": ".*"' | head -n 1| sed 's/"//g;s/v//g' | sed 's/tag_name: //g')
    [ -z ${simple_obfs_ver} ] && _echo -e "获取 simple-obfs Latest version failed." && exit 1
        
    pushd ${TEMP_DIR_PATH} > /dev/null 2>&1
    git clone https://github.com/shadowsocks/simple-obfs.git
    [ -d simple-obfs ] && cd simple-obfs || _echo -e "git clone simple-obfs fail."
    git submodule update --init --recursive
    
    if centosversion 6; then
        if [ ! "$(command -v autoconf268)" ]; then
            _echo -i "start installation autoconf268."
            yum install -y autoconf268 > /dev/null 2>&1 || _echo -e "autoconf268 installation failed."
        fi
        # replace command autoreconf to autoreconf268
        sed -i 's/autoreconf/autoreconf268/' autogen.sh
        # replace #include <ev.h> to #include <libev/ev.h>
        sed -i 's@^#include <ev.h>@#include <libev/ev.h>@' src/local.h
        sed -i 's@^#include <ev.h>@#include <libev/ev.h>@' src/server.h
    fi
    
    _echo -i "Compile and install simple-obfs-${simple_obfs_ver}."
    ./autogen.sh
    ./configure --disable-documentation
    make
    make install
    if [ ! "$(command -v obfs-server)" ]; then
        _echo -e "simple-obfs-${simple_obfs_ver} installation failed."
        install_cleanup
        exit 1
    fi
    [ -f ${SIMPLE_OBFS_BIN_PATH} ] && ln -fs ${SIMPLE_OBFS_BIN_PATH} /usr/bin
    _echo -i "simple-obfs-${simple_obfs_ver} Successful installation."
    popd > /dev/null 2>&1
}