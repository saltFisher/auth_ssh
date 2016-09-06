#!/bin/bash
#双向设置ssh key
function checkHosts {
    local ip=$1
    [[ -e ~/.ssh/known_hosts ]] && grep "$ip" ~/.ssh/known_hosts && return 0
    return 1
}
function checkAuth {
    local idPub=$1
    if [[ -e ~/.ssh/authorized_keys ]]; then
        grep "`cat $idPub`" ~/.ssh/authorized_keys >/dev/null && return 0
    fi
    cat $idPub >> ~/.ssh/authorized_keys && return 0
    return 1
}
function copyToRemote
{
    local ip=$1
    local user=$2
    local passwd=$3
expect << EOF
set cmd_prompt "~.*#?"
spawn ssh-copy-id $user@$ip
expect {
    timeout {
        exit 1
    }
    "(yes/no)?" {
        send "yes\r"
        sleep 1
        exp_continue
    }
    "assword:" {
        send "$passwd\r"
        exp_continue
    }
}
expect eof
EOF
}
ip=$1
user=$2
passwd=$3
fileName=`basename $0`
bash local_ssh.sh
copyToRemote $1 $2 $3
scp "remote_ssh.sh" $2@$1:/tmp || (echo "Upload remote_ssh.sh fail"; exit 1)
sleep 5
expect autoCommand.exp $ip $user "bash /tmp/remote_ssh.sh"
scp $user@$ip:~/.ssh/id_rsa.pub /tmp || (echo "Download id_rsa.pub fail"; exit 1)
checkAuth /tmp/id_rsa.pub && exit 0
exit 1
