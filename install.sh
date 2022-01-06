PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"
# fonts color

WORK_PATH=$(dirname $(readlink -f $0))
UNAME=$(uname -m)

welcome (){
    clear
    echo -e "${Green}=========================================================================================${Font}"
    echo -e "${Green}欢迎使用 TTRSS / FreshRSS / RSSHub 一键安装脚本${Font}"
    echo -e "${Red}注意:本脚本需要服务器有 docker 和 docker compose 环境${Font}"
    echo -e "${Green}更新支持 FreshRSS 服务${Font}"
    echo -e "${Green}更新同时支持 X86 和 ARM 架构${Font}"
    echo -e "${Green}=========================================================================================${Font}"
    echo "1) 开始执行环境检查,确保本服务器满足安装条件."
    echo "2) 退出脚本"
    read -p "请输入:" CHOICE_INPUT
    case "$CHOICE_INPUT" in
        1)
        check_env
        ;;
        2)
        echo -e "${Red}已退出脚本.${Font}"
        exit 0
        ;;
        *)
        echo -e "${Red}输入有误,请重新运行脚本.${Font}"
        exit 0
        esac
}

check_env (){
    echo -e "${Green}=========================================================================================${Font}"
    echo -e "${Green}开始检查服务器环境${Font}"
    # if ! type docker >/dev/null 2>&1 ; then
    #     echo -e "${Red}当前系统 docker 未安装,已退出脚本.${Font}"
    #     exit 0
    # fi
    # if ! type docker-compose >/dev/null 2>&1 ; then
    #     echo -e "${Red}当前系统 docker-compose 未安装,已退出脚本.${Font}"
    #     exit 0
    # fi
    # if ! type git >/dev/null 2>&1 ; then
    #     echo -e "${Red}当前系统 git 未安装,已退出脚本.${Font}"
    #     exit 0
    # fi
    if [ -d "${WORK_PATH}/rssforever" ] ; then
        echo -e "${Red}当前目录存在 rssforever 项目.请更换目录,或删除后再次执行脚本.${Font}"
        exit 0
    fi

    echo -e "${Green}服务器完成检查,开始执行脚本.${Font}"
    echo -e "${Green}=========================================================================================${Font}"
    get_info
}

get_info () {
    # 选择 RSS 服务
    echo -e "${Green}选择 RSS 服务${Font}"
    echo "1) TTRSS"
    echo "2) FreshRSS"
    echo "3) 退出脚本"
    read -p "请输入:" CHOICE_RSS_INPUT
    case "$CHOICE_RSS_INPUT" in
        1)
        RSS="TTRSS"
        ;;
        2)
        RSS="FreshRSS"
        ;;
        3)
        echo -e "${Red}已退出脚本.${Font}"
        exit 0
        ;;
        *)
        echo -e "${Red}输入有误,请重新运行脚本.${Font}"
        exit 0
        esac

    # 选择 RSSHub 服务  
    echo -e "${Green}选择 RSSHub 服务${Font}"
    echo "1) 添加 RSSHub 服务"
    echo "2) 无需添加 RSSHub 服务"
    echo "3) 退出脚本"
    read -p "请输入:" CHOICE_RSSHUB_INPUT
    case "$CHOICE_RSSHUB_INPUT" in
        1)
        RSSHUB="yes"
        RSSHUB_SHOW_INFO="已添加"
        ;;
        2)
        RSSHUB="no"
        RSSHUB_SHOW_INFO="未添加"
        ;;
        3)
        echo -e "${Red}已退出脚本.${Font}"
        exit 0
        ;;
        *)
        echo -e "${Red}输入有误,请重新运行脚本.${Font}"
        exit 0
        esac

    # 选择 HTTP 协议  
    echo -e "${Green}选择是否开启 HTTPS 支持${Font}"
    echo "1) HTTPS 协议"
    echo "2) HTTP 协议"
    echo "3) 退出脚本"
    read -p "请输入:" CHOICE_PROTOCOL_INPUT
    case "$CHOICE_PROTOCOL_INPUT" in
        1)
        PROTOCOL="https"
        ;;
        2)
        PROTOCOL="http"
        ;;
        3)
        echo -e "${Red}已退出脚本.${Font}"
        exit 0
        ;;
        *)
        echo -e "${Red}输入有误,请重新运行脚本.${Font}"
        exit 0
        esac

    if [ "${RSSHUB}" == "yes" ] && [ "${PROTOCOL}" == "https" ]; then
        echo -e "${Green}注意:本脚本自带申请域名证书功能. RSS 和 RSSHub 必须为同一域名的子域名.${Font}"
    fi 

    # 输入 RSS 域名信息
    echo -e "${Green}请输入 RSS 使用的域名(例如:rss.ioiox.com):${Font}"
    read -p "请输入:" RSS_DOMAIN_INPUT
    if [ ! -n "${RSS_DOMAIN_INPUT}" ]; then
        echo -e "${Red}输入错误,请重新运行脚本.${Font}"
        exit 0
    fi
    RSS_DOMAIN=$RSS_DOMAIN_INPUT

    # 输入 RSSHub 域名信息
    if [ "${RSSHUB}" == "yes" ] ; then
        echo -e "${Green}请输入 RSSHub 使用的域名(例如:rsshub.ioiox.com):${Font}"
        read -p "请输入:" RSSHUB_DOMAIN_INPUT
        if [ ! -n "${RSSHUB_DOMAIN_INPUT}" ]; then
            echo -e "${Red}输入错误,请重新运行脚本.${Font}"
            exit 0
        fi
        RSSHUB_DOMAIN=$RSSHUB_DOMAIN_INPUT
    fi

    if [ "${PROTOCOL}" == "https" ] ; then
        get_acme_info
    else
        show_info
    fi
}

get_acme_info () {
    echo -e "${Green}输入主域名用于部署和申请证书${Font}"
    echo -e "${Green}请输入需要申请泛域名证书的根域名(例如:ioiox.com):${Font}"
    read -p "请输入:" DOMAIN_INPUT
    if [ ! -n "${DOMAIN_INPUT}" ]; then
        echo -e "${Red}输入错误,请重新运行脚本.${Font}"
        exit 0
    fi
    DOMAIN=$DOMAIN_INPUT

    # 选择证书机构
    echo -e "${Green}请选择域名证书颁发机构:${Font}"
    echo -e "1) ZeroSSL"
    echo -e "2) Let's Encrypt"
    read -p "请选择:" AGENCY_INPUT
    case "$AGENCY_INPUT" in
        1)
        AGENCY='zerossl'
        AGENCY_SHOW_INFO='ZeroSSL'
        ;;
        2)
        AGENCY='letsencrypt'
        AGENCY_SHOW_INFO="Let\'s Encrypt"
        ;;
        *)
        echo -e "${Red}输入错误,请重新运行脚本.${Font}"
        exit 0
        esac

    # 输入域名服务商信息
    echo -e "${Green}请选择域名服务商:${Font}"
    echo -e "1) 腾讯云 dnspod.cn"
    echo -e "2) 阿里云 aliyun"
    echo -e "3) Cloudflare"
    read -p "请选择:" DNSAPI_INPUT
    case "$DNSAPI_INPUT" in
        1)
        PLATFORM_NAME='腾讯云'
        DNSAPI='dns_dp'
        API_ID_HEADER='DP_Id'
        API_KEY_HEADER='DP_Key'
        ;;
        2)
        PLATFORM_NAME='阿里云'
        DNSAPI='dns_ali'
        API_ID_HEADER='Ali_Key'
        API_KEY_HEADER='Ali_Secret'
        ;;
        3)
        ;;
        *)
        echo -e "${Red}输入错误,请重新运行脚本.${Font}"
        exit 0
        esac

    if [ "$DNSAPI_INPUT" == "3" ]; then
        echo -e "${Green}=========================================================================================${Font}"
        echo -e  "${Red}注意: Cloudflare API 有三种:${Font}"
        echo -e  "${Red}请参考 https://github.com/acmesh-official/acme.sh/wiki/dnsapi#1-cloudflare-option 选择.${Font}"
        echo -e  "${Red}推荐使用第二种: 可参考 https://ssl.ioiox.com/dnsapi.html 获取:${Font}"
        echo "1) Using the global API key"
        echo "2) Using the new cloudflare api token"
        echo "3) Using the new cloudflare api token for Single Zone"
        read -p "请选择:" CHOICE_CLOUDFLARE_INPUT
        echo -e "${Green}=========================================================================================${Font}"
        case "$CHOICE_CLOUDFLARE_INPUT" in
            1)
            PLATFORM_NAME='Cloudflare'
            DNSAPI='dns_cf'
            API_ID_HEADER='CF_Key'
            API_KEY_HEADER='CF_Email'
            ;;
            2)
            PLATFORM_NAME='Cloudflare'
            DNSAPI='dns_cf'
            API_ID_HEADER='CF_Token'
            API_KEY_HEADER='CF_Account_ID'
            ;;
            3)
            PLATFORM_NAME='Cloudflare'
            DNSAPI='dns_cf'
            API_ID_HEADER='CF_Token'
            API_KEY_HEADER='CF_Account_ID'
            API_ZONE_HEADER='CF_Zone_ID'
            ;;
            *)
            echo -e "${Red}输入错误,请重新运行脚本.${Font}"
            exit 0
            esac
    fi

    read -p "请输入 $API_ID_HEADER :" API_ID_INPUT
    read -p "请输入 $API_KEY_HEADER :" API_KEY_INPUT
    if [ "$CHOICE_CLOUDFLARE_INPUT" == "3" ]; then
        read -p "请输入 $API_ZONE_HEADER :" API_ZONE_HEADER_INPUT
    fi

    show_info

}


show_info (){
    echo -e "${Green}=========================================================================================${Font}"
    echo -e "${Red}请确认以下信息正确无误!${Font}"
    echo -e "${Green}当前服务器架构为${Font} ${Red}$UNAME${Font}"
    echo -e "${Green}RSS 服务为${Font} ${Red}${RSS}${Font}"
    echo -e "${Green}RSSHub 服务${Font} ${Red}${RSSHUB_SHOW_INFO}${Font}"
    echo -e "${Green}RSS 域名为${Font} ${Red} ${RSS_DOMAIN}${Font}"
    if [ "${RSSHUB}" == "yes" ] ; then
        echo -e "${Green}RSSHub 域名为${Font} ${Red}${RSSHUB_DOMAIN}${Font}"
    fi
    if [ "${PROTOCOL}" == "https" ] ; then
        echo -e "${Green}申请泛域名证书${Font} ${Red}$DOMAIN${Font}"
        echo -e "${Green}证书颁发机构${Font} ${Red}$AGENCY_SHOW_INFO${Font}"
        echo -e "${Green}域名服务商: ${Font}${Red}${PLATFORM_NAME}${Font}"
        echo -e "${Green}${API_ID_HEADER}:${Font} ${Red}${API_ID_INPUT}${Font}"
        echo -e "${Green}${API_KEY_HEADER}:${Font} ${Red}${API_KEY_INPUT}${Font}"
        if [ "$CHOICE_CLOUDFLARE_INPUT" == "3" ]; then
            echo -e "${Green}${API_ZONE_HEADER}:${Font} ${Red}${API_ZONE_HEADER_INPUT}${Font}"
        fi
    fi
    echo -e "${Red}请再次确认以上信息正确无误!${Font}"
    echo -e "${Green}=========================================================================================${Font}"
    echo -e "1) 开始部署"
    echo -e "2) 退出脚本"
    read -p "请输入:" START_INPUT
    case "$START_INPUT" in
        1)
        echo -e "${Green}开始部署中......${Font}"
        start
        ;;
        2)
        exit 0
        ;;
        *)
        echo -e "${Red}输入有误,请重新运行脚本.${Font}"
        exit 0
        esac
}

start () {
    if [ "${PROTOCOL}" == "https" ]; then
        acme
    else
        git_clone
    fi
}


acme () {
    TEMP=${RANDOM}
    mkdir -p ${WORK_PATH}/${TEMP}
    cat >${WORK_PATH}/${TEMP}/account.conf<<EOF
export ${API_ID_HEADER}="${API_ID_INPUT}"
export ${API_KEY_HEADER}="${API_KEY_INPUT}"
EOF
    if [ "$CHOICE_CLOUDFLARE_INPUT" == "3" ]; then
        echo "export ${API_ZONE_HEADER}=\"${API_ZONE_HEADER_INPUT}\"" >> ${WORK_PATH}/${TEMP}/account.conf
    fi
    echo -e "${Green}准备 docker 部署${Font}"
    docker run -itd \
    --name=${TEMP} \
    --restart=always \
    --net=host \
    -v ${WORK_PATH}/${TEMP}:/acme.sh \
    neilpang/acme.sh \
    daemon

    echo -e "${Green}升级 acme.sh 程序${Font}"
    docker exec ${TEMP} --upgrade

    echo -e "${Green}开始申请证书${Font}"
    if [ $AGENCY == "zerossl" ]; then
    docker exec ${TEMP} --register-account -m your@domain.com --server zerossl
    docker exec ${TEMP} --issue --server letsencrypt $* --dns ${DNSAPI} -d ${DOMAIN} -d \*.${DOMAIN}
    fi

    if [ $AGENCY == "letsencrypt" ]; then
    docker exec ${TEMP} --issue --server letsencrypt $* --dns ${DNSAPI} -d ${DOMAIN} -d \*.${DOMAIN}
    fi

    # clean
    docker stop ${TEMP} >/dev/null 2>&1
    docker rm ${TEMP} >/dev/null 2>&1

    # check
    if [ ! -f "${WORK_PATH}/${TEMP}/${DOMAIN}/fullchain.cer" ] ; then
        echo -e "${Green}证书申请失败,请重新尝试,已退出脚本.${Font}"
        exit 0
    else
        echo -e "${Green}证书申请成功,开始部署.${Font}"
        git_clone
    fi
}

git_clone (){
    git clone https://github.com/stilleshan/rssforever.git
    conf_domain
}


conf_domain (){
    sed -i \
        -e "/rss.yourdomain.com/s/rss.yourdomain.com/${RSS_DOMAIN}/g" \
        -e "/rssforever.com/s/rssforever.com/rssforever.com-${TEMP}/g" \
        ${WORK_PATH}/rssforever/.env

    if [ "${RSSHUB}" == "yes" ] ; then
        sed -i "/rsshub.yourdomain.com/s/rsshub.yourdomain.com/${RSSHUB_DOMAIN}/g" ${WORK_PATH}/rssforever/.env
    else
        mv ${WORK_PATH}/rssforever/nginx/vhost/rsshub.conf ${WORK_PATH}/rssforever/nginx/vhost/rsshub.conf.bak
    fi

    if [ "${PROTOCOL}" == "https" ] ; then
        cp ${WORK_PATH}/${TEMP}/${DOMAIN}/fullchain.cer ${WORK_PATH}/rssforever/nginx/ssl/${DOMAIN}.cer
        cp ${WORK_PATH}/${TEMP}/${DOMAIN}/${DOMAIN}.key ${WORK_PATH}/rssforever/nginx/ssl
        sed -i \
            -e '/PROTOCOL=http/s/PROTOCOL=http/PROTOCOL=https/g' \
            -e "/yourdomain.com.cer/s/yourdomain.com.cer/${DOMAIN}.cer/g" \
            -e "/yourdomain.com.key/s/yourdomain.com.key/${DOMAIN}.key/g" \
            ${WORK_PATH}/rssforever/.env
            rm -rf ${WORK_PATH}/${TEMP}
        conf_auto_acme
    fi
    set_deploy
}

conf_auto_acme (){
    cat >${WORK_PATH}/rssforever/acme/account.conf<<EOF
export ${API_ID_HEADER}="${API_ID_INPUT}"
export ${API_KEY_HEADER}="${API_KEY_INPUT}"
export DOMAIN=${DOMAIN}
export DNSAPI=${DNSAPI}
EOF
    if [ "$CHOICE_CLOUDFLARE_INPUT" == "3" ]; then
        sed -i "2a export ${API_ZONE_HEADER}=\"${API_ZONE_HEADER_INPUT}\"" ${WORK_PATH}/rssforever/acme/account.conf
    fi
}

set_deploy () {
    if [ "${RSS}" == "TTRSS" ]; then
        if [ "${RSSHUB}" == "yes" ]; then
            if [ "${PROTOCOL}" == "https" ]; then
                COMPOSE_FILE="ttrss-rsshub-https.yml"
                SUCCESS_MSG="TTRSS / RSSHub / HTTPS"
            fi
            if [ "${PROTOCOL}" == "http" ]; then
                COMPOSE_FILE="ttrss-rsshub-http.yml"
                SUCCESS_MSG="TTRSS / RSSHub / HTTP"
            fi
        fi
        if [ "${RSSHUB}" == "no" ]; then
            if [ "${PROTOCOL}" == "https" ]; then
                COMPOSE_FILE="ttrss-https.yml"
                SUCCESS_MSG="TTRSS / HTTPS"
            fi
            if [ "${PROTOCOL}" == "http" ]; then
                COMPOSE_FILE="ttrss-http.yml"
                SUCCESS_MSG="TTRSS / HTTP"
            fi
        fi
    fi

    if [ "${RSS}" == "FreshRSS" ]; then
        if [ "${RSSHUB}" == "yes" ]; then
            if [ "${PROTOCOL}" == "https" ]; then
                COMPOSE_FILE="freshrss-rsshub-https.yml"
                SUCCESS_MSG="FreshRSS / RSSHub / HTTPS"
            fi
            if [ "${PROTOCOL}" == "http" ]; then
                COMPOSE_FILE="freshrss-rsshub-http.yml"
                SUCCESS_MSG="FreshRSS / RSSHub / HTTP"
            fi
        fi
        if [ "${RSSHUB}" == "no" ]; then
            if [ "${PROTOCOL}" == "https" ]; then
                COMPOSE_FILE="freshrss-https.yml"
                SUCCESS_MSG="FreshRSS / HTTPS"
            fi
            if [ "${PROTOCOL}" == "http" ]; then
                COMPOSE_FILE="freshrss-http.yml"
                SUCCESS_MSG="FreshRSS / HTTP"
            fi
        fi
    fi
    up
}

up () {
    cd ${WORK_PATH}/rssforever
    if [ "${UNAME}" == "x86_64" ]; then
        ARCH=x86
        ARCH_UPCASE=X86
    else
        ARCH=arm
        ARCH_UPCASE=ARM
    fi
    cp compose_files/${ARCH}/${COMPOSE_FILE} ./docker-compose.yml
    docker-compose up -d
    cd ${WORK_PATH}/
    echo -e "${Green}${SUCCESS_MSG} / ${ARCH_UPCASE} 部署成功${Font}"
}

welcome
