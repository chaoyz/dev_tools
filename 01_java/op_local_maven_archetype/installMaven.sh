#!/bin/bash

# author: yc
# description: 在线安装maven小工具

# 请注意，需要下载bin安装包
MAVEN_PACKAGE_NAME="apache-maven-3.5.2-bin.tar.gz"
MAVEN_DOWNLOAD_URL="http://mirrors.shuosc.org/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz"

RED='\e[1;91m'
GREN='\e[1;92m'
WITE='\e[1;97m'
NC='\e[0m'

function checkJava() {
	JAVA=$(echo $PATH | grep java)
	if [ -z "$JAVA" ]; then
		echo -e $RED"java not install."$NC
		exit -1
	fi
	echo -e $GREN"java installed."$NC
}

checkJava

# 下载maven，并解压到/usr/local下面
if [ ! -f "$MAVEN_PACKAGE_NAME" ]; then
	curl "$MAVEN_DOWNLOAD_URL" > "$MAVEN_PACKAGE_NAME"
fi

DIR=${MAVEN_PACKAGE_NAME/"-bin.tar.gz"}
MAVEN_DEPLOY_DIR="/usr/local/maven/$DIR"

mkdir -p /usr/local/maven
if [ ! -f "/usr/local/maven/$DIR" ]; then
	tar -zxf "$MAVEN_PACKAGE_NAME" -C /usr/local/maven
fi

echo "export M2_HOME=/usr/local/maven/$DIR" >> /etc/profile
echo 'export PATH=$PATH:$M2_HOME/bin' >> /etc/profile
source /etc/profile
