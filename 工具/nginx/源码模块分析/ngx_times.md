```c
volatile ngx_str_t       ngx_cached_err_log_time;//ngx_log_error_core函数使用的时间信息，格式：1970/09/28 12:00:00
volatile ngx_str_t       ngx_cached_http_time;//格式：Mon, 28 Sep 1970 06:00:00 GMT
volatile ngx_str_t       ngx_cached_http_log_time;//格式：28/Sep/1970:12:00:00 +0600
volatile ngx_str_t       ngx_cached_http_log_iso8601;//格式：1970-09-28T12:00:00+06:00
volatile ngx_str_t       ngx_cached_syslog_time;//格式：Sep 28 12:00:00
```