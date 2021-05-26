sed -i -e "/rss.yourdomain.com/s/rss.yourdomain.com/${RSS_DOMAIN}/g" -e "/yourdomain.com.cer/s/yourdomain.com.cer/${RSS_DOAMIN_CERT}/g" -e "/yourdomain.com.key/s/yourdomain.com.key/${RSS_DOMAIN_KEY}/g" /etc/nginx/conf.d/vhost/rss.conf
sed -i -e "/rsshub.yourdomain.com/s/rsshub.yourdomain.com/${RSSHUB_DOMAIN}/g" -e "/yourdomain.com.cer/s/yourdomain.com.cer/${RSSHUB_DOAMIN_CERT}/g" -e "/yourdomain.com.key/s/yourdomain.com.key/${RSSHUB_DOMAIN_KEY}/g" /etc/nginx/conf.d/vhost/rsshub.conf
nginx -s reload
nginx -g 'daemon off;'
