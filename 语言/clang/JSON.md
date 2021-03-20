https://github.com/DaveGamble/cJSON

```c
#include <stdio.h>
#include "cJSON.h"

int main() {
    char *str = "{\"abc\":123}";
    printf("%s\n", str);
    cJSON *json = cJSON_Parse(str);
    str = cJSON_Print(json);
    printf("%s\n", str);
    return 0;
}
```

输出

```
{"abc":123}
{
	"abc":	123
}
```