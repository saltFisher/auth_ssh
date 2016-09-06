#!/bin/bash
#设置ssh key
###检查本地是否有key，没有则建立，有则直接传递
###usage: myscript [--force]
###如果加--force，则意味着强制重新生成ssh-key
function checkLocal {
    ##如果本地未发现id_rsa及id_rsa.pub 则返回0
    [[ ! -e ~/.ssh/id_rsa ]] && [[ ! -e ~/.ssh/id_rsa.pub ]] && return 0
}

function createLocal 
{
expect << EOF
spawn ssh-keygen -t rsa -N "" -q -b 2048
expect {
    timeout {
        exit 1
    }
    "Enter file in which" {
        send "\r"
    }
}
expect {
    eof {
        send_user "eof"
    }
}
EOF
}
function createLocal_force
{
expect << EOF
spawn ssh-keygen -t rsa -N "" -q -b 2048
expect {
    timeout {
        exit 1
    }
    "Enter file in which" {
        send "\r"
    }
}
expect {
    "*(y/n)?" {
        send "y\r"
    }
}
expect eof
EOF
}
if [[ "$1" == --force ]]; then
    checkLocal && createLocal || createLocal_force 
else
    checkLocal && createLocal 
fi
exit 0
