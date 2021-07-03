ngx_get_options()函数的后续步骤

- cycle->conf_prefix = ngx_prefix
  - 如果ngx_prefix结尾不是'/'，补上去
- cycle->prefix = ngx_prefix
  - 如果ngx_prefix结尾不是'/'，补上去
- cycle->conf_file = ngx_conf_file
- cycle->conf_param = ngx_conf_params
- cycle->log->log_level = NGX_LOG_INFO
  - 前提是ngx_test_config = 1

