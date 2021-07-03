- ngx_os_argv：存储char **argv
- ngx_argc：存储argc
- ngx_argv：存储argc个参数内容
- ngx_os_environ：环境变量



环境变量示例

```c
for(int i=0;environ[i]!=NULL;i++){
    ngx_log_error(NGX_LOG_EMERG, cycle->log, 0, "environ[%d]=%s", i, environ[i]);
}
```

```
nginx: [emerg] environ[0]=LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:
nginx: [emerg] environ[1]=SSH_CONNECTION=192.168.56.1 57124 192.168.56.108 22
nginx: [emerg] environ[2]=LESSCLOSE=/usr/bin/lesspipe %s %s
nginx: [emerg] environ[3]=_=/usr/bin/env
nginx: [emerg] environ[4]=LANG=en_US.UTF-8
nginx: [emerg] environ[5]=OLDPWD=/home/zyl/github/nginx
nginx: [emerg] environ[6]=COLORTERM=truecolor
nginx: [emerg] environ[7]=XDG_SESSION_ID=1
nginx: [emerg] environ[8]=USER=zyl
nginx: [emerg] environ[9]=PWD=/home/zyl/github/nginx
nginx: [emerg] environ[10]=LINES=19
nginx: [emerg] environ[11]=HOME=/home/zyl
nginx: [emerg] environ[12]=BROWSER=/home/zyl/.vscode-server/bin/bin/helpers/browser.sh
nginx: [emerg] environ[13]=VSCODE_GIT_ASKPASS_NODE=/home/zyl/.vscode-server/bin/node
nginx: [emerg] environ[14]=TERM_PROGRAM=vscode
nginx: [emerg] environ[15]=SSH_CLIENT=192.168.56.1 57124 22
nginx: [emerg] environ[16]=TERM_PROGRAM_VERSION=1.56.2
nginx: [emerg] environ[17]=XDG_DATA_DIRS=/usr/local/share:/usr/share:/var/lib/snapd/desktop
nginx: [emerg] environ[18]=VSCODE_IPC_HOOK_CLI=/run/user/1000/vscode.sock
nginx: [emerg] environ[19]=COLUMNS=190
nginx: [emerg] environ[20]=MAIL=/var/mail/zyl
nginx: [emerg] environ[21]=VSCODE_GIT_ASKPASS_MAIN=/home/zyl/.vscode-server/bin/extensions/git/dist/askpass-main.js
nginx: [emerg] environ[22]=SHELL=/bin/bash
nginx: [emerg] environ[23]=TERM=xterm-256color
nginx: [emerg] environ[24]=SHLVL=4
nginx: [emerg] environ[25]=VSCODE_GIT_IPC_HANDLE=/run/user/1000/vscode-git.sock
nginx: [emerg] environ[26]=LOGNAME=zyl
nginx: [emerg] environ[27]=GIT_ASKPASS=/home/zyl/.vscode-server/bin/extensions/git/dist/askpass.sh
nginx: [emerg] environ[28]=XDG_RUNTIME_DIR=/run/user/1000
nginx: [emerg] environ[29]=PATH=/home/zyl/.vscode-server/bin/bin:/home/zyl/.vscode-server/bin/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
nginx: [emerg] environ[30]=LESSOPEN=| /usr/bin/lesspipe %s
```