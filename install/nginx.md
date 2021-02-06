```
./configure --prefix=/dataz/software/nginx-1.18.0 --with-http_ssl_module --with-http_geoip_module=dynamic --with-http_image_filter_module=dynamic --with-http_xslt_module=dynamic --with-mail=dynamic --with-stream=dynamic
```

## 依赖

### http_geoip_module

geoip

下载编译安装
https://github.com/maxmind/geoip-api-c/releases

### http_image_filter_module

libgd

https://github.com/libgd/libgd/releases


## http_xslt_module

libxslt

http://xmlsoft.org/XSLT/downloads.html

apt install libxml2 libxml2-dev

## ngx_http_rewrite_module

pcre

apt install libpcre3 libpcre3-dev


## SSL modules

apt install libssl-dev

## http_gzip_module

apt install zlib1g-dev

## http_proxy_connect_module

https://github.com/chobits/ngx_http_proxy_connect_module

