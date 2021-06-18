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


menu (){
    clear
    echo -e "${Green}=========================================================================================${Font}"
    echo -e "${Green}欢迎使用 nginx + ttrss + rsshub + watchtower 一键安装脚本${Font}"
    echo -e "${Red}注意:本脚本需要服务器有 docker 和 docker compose 环境${Font}"
    echo -e "${Green}=========================================================================================${Font}"
    echo "1) nginx + ttrss + rsshub + watchtower"
    echo "2) nginx + ttrss"
    echo "3) 退出脚本"
    read -p "请输入:" CHOICE_INPUT
    case "$CHOICE_INPUT" in
        1)
        choice1
        ;;
        2)
        choice2
        ;;
        3)
        echo -e "${Red}已退出脚本.${Font}"
        exit 0
        ;;
        *)
        echo -e "${Red}输入有误,请重新运行脚本.${Font}"
        exit 0
        esac
}


choice1 (){
    echo -e "${Green}当前选择 nginx + ttrss + rsshub + watchtower${Font}"
    echo "1) 全自动申请和续签泛域名证书"
    echo "2) 无需 SSL 证书"
    echo "3) 退出脚本"
    echo -e "${Green}=========================================================================================${Font}"
    read -p "请输入:" CHOICE1_INPUT
    case "$CHOICE1_INPUT" in
        1)
        confirm_domain
        conf_ssl $*
        git_clone
        conf_env
        conf_auto_acme
        up
        ;;
        2)
        confirm_domain
        git_clone
        conf_env
        conf_auto_acme
        up
        ;;
        3)
        echo -e "${Red}已退出脚本.${Font}"
        exit 0
        ;;
        *)
        echo -e "${Red}输入有误,请重新运行脚本.${Font}"
        exit 0
        esac
}

choice2 (){
    echo -e "${Green}当前选择 nginx + ttrss${Font}"
    echo "1) 全自动申请和续签泛域名证书"
    echo "2) 无需 SSL 证书"
    echo "3) 退出脚本"
    echo -e "${Green}=========================================================================================${Font}"
    read -p "请输入:" CHOICE2_INPUT
    case "$CHOICE2_INPUT" in
        1)
        confirm_domain
        conf_ssl $*
        git_clone
        conf_env
        conf_compose_file
        conf_auto_acme
        up
        ;;
        2)
        confirm_domain
        git_clone
        conf_env
        conf_compose_file
        up
        ;;
        3)
        echo -e "${Red}已退出脚本.${Font}"
        exit 0
        ;;
        *)
        echo -e "${Red}输入有误,请重新运行脚本.${Font}"
        exit 0
        esac 
}


confirm_domain (){
    clear
    if [ "${CHOICE1_INPUT}" == "1" ] || [ "${CHOICE2_INPUT}" == "1" ]; then
        echo -e "${Green}请输入需要申请泛域名证书的根域名(例如:ioiox.com):${Font}"
        read -p "请输入:" DOMAIN_INPUT
        if [ ! -n "${DOMAIN_INPUT}" ]; then
            echo -e "${Red}输入错误,请重新运行脚本.${Font}"
            exit 0
        fi
    fi
    DOMAIN=$DOMAIN_INPUT
    echo -e "${Green}请输入 ttrss 使用的域名(例如:rss.ioiox.com):${Font}"
    read -p "请输入:" RSS_DOMAIN_INPUT
    if [ ! -n "${RSS_DOMAIN_INPUT}" ]; then
        echo -e "${Red}输入错误,请重新运行脚本.${Font}"
        exit 0
    fi
    if [ "${CHOICE_INPUT}" == "1" ] ; then
        echo -e "${Green}请输入 rsshub 使用的域名(例如:rsshub.ioiox.com):${Font}"
        read -p "请输入:" RSSHUB_DOMAIN_INPUT
        if [ ! -n "${RSSHUB_DOMAIN_INPUT}" ]; then
            echo -e "${Red}输入错误,请重新运行脚本.${Font}"
            exit 0
        fi
    fi
}

conf_ssl (){
    echo -e "${Green}请选择域名服务商:${Font}"
    echo -e "1) 腾讯云 dnspod.cn"
    echo -e "2) 阿里云 aliyun"
    echo -e "3) Cloudflare"
    read -p "请选择:" DNSAPI_INPUT
    case "$DNSAPI_INPUT" in
        1)
        PLATFORM_NAME='dnspod.cn'
        DNSAPI='dns_dp'
        API_ID_HEADER='DP_Id'
        API_KEY_HEADER='DP_Key'
        ;;
        2)
        PLATFORM_NAME='aliyun'
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


    echo -e "${Green}=========================================================================================${Font}"
    echo -e "${Red}请确认以下信息正确无误!${Font}"
    echo -e "${Green}域名: ${Font}${Red}${DOMAIN}${Font}"
    echo -e "${Green}域名服务商: ${Font}${Red}${PLATFORM_NAME}${Font}"
    echo -e "${Green}${API_ID_HEADER}:${Font} ${Red}${API_ID_INPUT}${Font}"
    echo -e "${Green}${API_KEY_HEADER}:${Font} ${Red}${API_KEY_INPUT}${Font}"
    if [ "$CHOICE_CLOUDFLARE_INPUT" == "3" ]; then
        echo -e "${Green}${API_ZONE_HEADER}:${Font} ${Red}${API_ZONE_HEADER_INPUT}${Font}"
    fi
    echo -e "${Red}请再次确认以上信息正确无误!${Font}"
    echo -e "${Green}=========================================================================================${Font}"
    echo -e "1) 开始部署"
    echo -e "2) 退出脚本"
    read -p "请输入:" START_INPUT
    case "$START_INPUT" in
        1)
        echo -e "${Green}开始部署中......${Font}"
        acme $*
        ;;
        2)
        exit 0
        ;;
        *)
        echo -e "${Red}输入有误,请重新运行脚本.${Font}"
        exit 0
        esac
}

acme (){
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
    docker exec ${TEMP} --issue --server letsencrypt $* --dns ${DNSAPI} -d ${DOMAIN} -d \*.${DOMAIN}

    # clean
    docker stop ${TEMP} >/dev/null 2>&1
    docker rm ${TEMP} >/dev/null 2>&1

    # check
    if [ ! -f "${WORK_PATH}/${TEMP}/${DOMAIN}/fullchain.cer" ] ; then
        echo -e "${Green}证书申请失败,请重新尝试,已退出脚本.${Font}"
        exit 0
    fi
}

git_clone (){
    git clone https://github.com/stilleshan/rssforever.git
}

conf_env (){
    sed -i \
        -e "/rss.yourdomain.com/s/rss.yourdomain.com/${RSS_DOMAIN_INPUT}/g" \
        -e "/rssforever.com/s/rssforever.com/rssforever.com-${TEMP}/g" \
        ${WORK_PATH}/rssforever/.env

    if [ "${CHOICE_INPUT}" == "1" ] ; then
        sed -i "/rsshub.yourdomain.com/s/rsshub.yourdomain.com/${RSSHUB_DOMAIN_INPUT}/g" ${WORK_PATH}/rssforever/.env
    fi

    if [ "${CHOICE1_INPUT}" == "1" ] || [ "${CHOICE2_INPUT}" == "1" ]; then
        cp ${WORK_PATH}/${TEMP}/${DOMAIN}/fullchain.cer ${WORK_PATH}/rssforever/nginx/ssl/${DOMAIN}.cer
        cp ${WORK_PATH}/${TEMP}/${DOMAIN}/${DOMAIN}.key ${WORK_PATH}/rssforever/nginx/ssl
        sed -i \
            -e '/PROTOCOL=http/s/PROTOCOL=http/PROTOCOL=https/g' \
            -e "/yourdomain.com.cer/s/yourdomain.com.cer/${DOMAIN}.cer/g" \
            -e "/yourdomain.com.key/s/yourdomain.com.key/${DOMAIN}.key/g" \
            ${WORK_PATH}/rssforever/.env
            rm -rf ${WORK_PATH}/${TEMP}
    fi
}

conf_compose_file (){
    sed -i '34d' ${WORK_PATH}/rssforever/docker-compose.yml
    sed -i '80,131d' ${WORK_PATH}/rssforever/docker-compose.yml
    mv ${WORK_PATH}/rssforever/nginx/vhost/rsshub.conf ${WORK_PATH}/rssforever/nginx/vhost/rsshub.conf.bak
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

    cat >>${WORK_PATH}/rssforever/docker-compose.yml<<'EOF'
#---------------------------------------- acme.sh ----------------------------------------#
  acme:
    image: neilpang/acme.sh
    # container_name: acme
    volumes:
      - ./acme:/conf
      - ./nginx/ssl:/ssl
    restart: always
    network_mode: host
    command: ["sh", "-c", "/conf/start.sh"]
EOF
}

up (){
    cd ${WORK_PATH}/rssforever
    docker-compose up -d
    if [ "$CHOICE1_INPUT" == "1" ]; then
        echo -e "${Green}nginx + ttrss + rsshub + watchtower + acme 部署完毕${Font}"
        elif [ "$CHOICE1_INPUT" == "2" ]; then
            echo -e "${Green}nginx + ttrss + rsshub + watchtower 部署完毕${Font}"
        elif [ "$CHOICE2_INPUT" == "1" ]; then
            echo -e "${Green}nginx + ttrss + acme 部署完毕${Font}"
        elif [ "$CHOICE2_INPUT" == "2" ]; then
            echo -e "${Green}nginx + ttrss 部署完毕${Font}"
    fi
    cd ${WORK_PATH}/
}


if [ ! type docker >/dev/null 2>&1 ] || [ ! type docker-compose >/dev/null 2>&1 ]; then
    echo -e "${Red}本机未安装 docker 或 docker compose 已退出脚本.${Font}";
    exit 0
fi

if [ -d "${WORK_PATH}/rssforever" ] ; then
    echo -e "${Green}当前目录存在 rssforever 项目.请更换目录,或删除后再次执行脚本.${Font}"
    exit 0
fi

menu $*
rm $0
