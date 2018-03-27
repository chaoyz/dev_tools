#!/usr/bin/expect -f

# author: yc
# description: ssh login script

set LOGIN_CMD [lindex $argv 0]
set LOGIN_PSW [lindex $argv 1]
set LOGIN_PARAM [lindex $argv 2]
set timeout 30
spawn ssh "$LOGIN_CMD" "$LOGIN_PARAM"
expect {
    "yes/no" {exp_send "yes\r";exp_continue}
    "password:" {exp_send "${LOGIN_PSW}\r"}
}
interact
