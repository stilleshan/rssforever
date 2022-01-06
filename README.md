# rssforever
## 简介
本项目为 Nginx + TTRSS / FreshRSS + RSSHub + Watchtower + ACME 整合 docker 容器化快速一键部署方案,支持一键脚本快速安装部署.
> *一键安装脚本已同时支持 X86 和 ARM 架构*

### 前言
[rssforever.com](rssforever.com) 为网友提供免费的 RSS 和 RSSHub 服务已经一年有余,由于服务器压力及个人精力有限等原因已停止提供 RSS 服务.鉴于很多新手用户技术有限,特将 Nginx + TTRSS / FreshRSS + RSSHub + Watchtower + ACME 整合到 docker compose 中,并编写脚本,实现一键部署使用.

### 特点
1. 本项目针对新手用户,提供整合配置,无需繁琐的设置,即使是新手用户最快也只需要几步操作,几分钟即可部署使用.
2. 使用 docker compose 编排配置,所有命令,配置及环境变量集中管理,方便维护和迁移.
3. 更换服务器也仅需打包备份一个文件夹,迁移解压后一条命令即可恢复使用.

**一键安装脚本支持以下八种模式,请根据自身情况选择:**
1. Nginx + TTRSS + RSSHub + Watchtower + ACME 自动申请和续签证书并开启 HTTPS 模式
2. Nginx + TTRSS + RSSHub + Watchtower + 无证书 HTTP 模式
3. Nginx + TTRSS + ACME 自动申请和续签证书并开启 HTTPS 模式
4. Nginx + TTRSS + 无证书 HTTP 模式
5. Nginx + FreshRSS + RSSHub + Watchtower + ACME 自动申请和续签证书并开启 HTTPS 模式
6. Nginx + FreshRSS + RSSHub + Watchtower + 无证书 HTTP 模式
7. Nginx + FreshRSS + ACME 自动申请和续签证书并开启 HTTPS 模式
8. Nginx + FreshRSS + 无证书 HTTP 模式

### 环境需求
- 境外 VPS 服务器 ( 国内服务器网络不佳,可能导致无法下载脚本, clone 仓库, docker 拉取等问题 )
- 拥有自己的域名 ( 托管与 腾讯云 / 阿里云 / Cloudflare 方便申请证书 )
- 服务器未占用 80/443 端口
- 服务器已安装 docker 和 docker compose 环境 ( 未安装可参考下文简易安装指南 )

> 本项目不支持已被其他服务占用 80/443 端口的服务器.请停止相关服务或更换新服务器部署使用.  
> 此项目最多一共会启动 10 个容器,建议 2C2G 及以上配置.  
> 如果服务器上已有 nginx 等占用 80/443 端口的服务,同时又有部署的需求,请联系我进行付费技术支持.


## 安装
### 更新
- **2022-01-06** 更新脚本支持 FreshRSS, 老版本已转移至`ttrss-rsshub`分支,同样也可以继续使用.
- **2021-07-01** 更新一键安装脚本同时支持 X86 和 ARM 架构.
- **2021-06-18** 更新一键安装脚本.

### 前期准备
- 准备 RSS 和 RSSHub 域名并解析至服务器
- 参考[这里](https://ssl.ioiox.com/dnsapi.html)获取域名 DNSAPI 以便脚本申请证书

### 执行脚本
```shell
wget https://raw.githubusercontent.com/stilleshan/rssforever/main/install.sh && chmod +x install.sh && ./install.sh
```

## 注意事项
### docker-compose 版本
建议将 docker-compose 版本升级到 v2.x.x 以上,建议 v2.2.2 版本.  
新版 docker-compose 启动的容器名命名格式于老版本不同,使用旧版会导致`Watchtower`无法监控更新镜像.除此之外无其他影响.

### TTRSS
默认账户: admin  
默认密码: password

### FreshRSS
FreshRSS 首次访问需要设置数据库,选择`PostgreSQL`:
- 主机 freshrss.db
- 用户名 freshrss
- 密码 在`rssforever`目录下的`.env`中`POSTGRES_PASSWORD`变量的值`rssforever.com-xxxxx`为数据库密码
- 数据库 freshrss

![snapshot01.jpg](./snapshot01.jpg)

### 定时更新证书
证书每月`1`日自动更新,请执行以下命令来定时每月重启`nginx`服务刷新证书.也可每月手动执行`docker-compose restart`来重启服务.
```shell
crontab -e
# 添加以下计划任务
0 0 2 * * docker restart rssforever-nginx-1
# 为避免时区问题,将在每月 2 号 0 点执行
```

### 备份恢复
#### 备份
本项目采用 docker compose 部署,所有配置及数据都在`rssforever`目录中,方便备份和迁移.  
**其他所有文件及目录,如不清楚请不要随意修改和删除,否则会导致服务无法启动.**
#### 恢复
将域名重新指向新服务器,将备份的`rssforever`目录解压进入启动即可.
```shell
cd rssforever
# 进入目录
docker-compose up -d
# 启动
```

## 其他
### 感谢
感谢以下大神提供的项目:
- [Awesome TTRSS 官方文档](https://ttrss.henry.wang/)
- [Awesome TTRSS GitHub](https://github.com/HenryQW/Awesome-TTRSS)
- [RSSHub 官方文档](https://docs.rsshub.app/)
- [DIYgod/RSSHub GitHub](https://github.com/DIYgod/RSSHub)

### 链接
- [rssforever.com](https://rssforever.com)  
- [RSSHub 公共服务](https://rsshub.rssforever.com)  
- [泛域名证书申请相关文章](https://www.ioiox.com/tag/SSL/)
- [新手教程 Nginx + TTRSS + RSSHub 整合 docker 容器化快速一键部署方案](https://www.ioiox.com/archives/133.html)
