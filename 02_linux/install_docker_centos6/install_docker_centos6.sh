#!/bin/bash

#author: yc
#decription: update centos6 and install docker

RED='\e[1;91m'
GREEN='\e[1;92m'
WITE='\e[1;97m'
NC='\e[0m'

CENTOS_RELEASE="/etc/issue"
# check os message
function check() {
    if [ ! -f "$CENTOS_RELEASE" ]; then
        echo -e $RED"OS is not centos."$NC
        return
    fi
    CENTOS_MSG=$(cat "$CENTOS_RELEASE" | grep "CentOS release 6")
    if [ -z "$CENTOS_MSG" ]; then
        echo -e $RED"OS is not centos6."$NC
        return
    fi
    DOCKER=$(rpm -qa | grep docker)
    if [ -n "$DOCKER" ]; then
	echo -e $RED"docker has installed."$NC
	return
    fi
    echo -e $GREEN"check ok"$NC
}

# install docker in centos6
function install () {
	check
	rpm -iUvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	yum update -y
	yum -y install docker-io
	# add my aliyun speed up url
	if [ -f "/etc/sysconfig/docker" ]; then
		OPTION=$(cat /etc/sysconfig/docker | grep "OPTION")
		if [ -z "$OPTION" ]; then
            if [ -n "$ALIYUN_URL" ]; then
			    echo "OPTIONS='--registry-mirror=$ALIYUN_URL'" >> /etc/sysconfig/docker
            fi
		fi
	fi
	service docker start
	chkconfig docker on
	echo -e $GREEN"install ok"$NC
}

# if has something problem
function remove() {
    chkconfig docker off
    service docker stop
    yum -y remove docker-io
    echo -e $GREEN"remove ok"$NC
}

MODE=${1}
ALIYUN_URL=${2}
case $MODE in
    "check")
        check
        ;;

    "install")
        check
        install
        ;;

    "remove")
        remove
        ;;

    *)
        # usage
        echo -e "Usage: $0 { check | isntall | remove }"
        exit 1
        ;;
esac
