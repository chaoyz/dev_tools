#!/bin/bash

# author: yc
# desc: 导出本地maven仓库中的自创建的archetype

RED='\e[1;91m'
GREN='\e[1;92m'
WITE='\e[1;97m'
NC='\e[0m'

SHELL_DIR=$(pwd)

function checkMavenEnv() {
    MAVEN_MSG=$(mvn -v | grep "Maven home:")
    if [ -z "$MAVEN_MSG" ]; then
        echo -e $RED"Maven not found."$NC
        exit -1
    fi
}

checkMavenEnv

MAVEN_HOME=$(mvn -v | grep "Maven home:" | cut -d ":" -f2 | sed s/[[:space:]]//g)
MAVEN_CONF_DIR="$MAVEN_HOME/conf"
cd $MAVEN_CONF_DIR
LOCAL_REPO_DIR=$(cat settings.xml | grep "<localRepository>" | cut -d '>' -f2 | cut -d '<' -f1)
if [ "$LOCAL_REPO_DIR" = "/path/to/local/repo" ]; then
    # 没有设置过本地仓库地址使用默认地址
    USER_HOME=$(echo ~)
    LOCAL_REPO_DIR="$USER_HOME/.m2/repository"
fi

if [ ! -f "$LOCAL_REPO_DIR/archetype-catalog.xml" ];then
    echo -e $GREN"Maven local repository archetype-catalog.xml not found."$NC
    exit -1
fi

# 创建存放目录
ARCHETYPE_LOCAL="$SHELL_DIR/archetype_local"
mkdir -p "$ARCHETYPE_LOCAL"

# 读取仓库内的archetype-catalog.xml文件，拷贝到打包文件下
cp "$LOCAL_REPO_DIR/archetype-catalog.xml" "$ARCHETYPE_LOCAL/"
# 逐行读取archetype-catalog.xml文件分析自定义的archetype，并将指定的groupId目录下拷贝到打包目录
groupIds=$(cat $LOCAL_REPO_DIR/archetype-catalog.xml | grep "groupId")
for line in $groupIds
do
    LINE_PATH=$(echo $line | sed s/[[:space:]]//g | cut -d '>' -f2 | cut -d '<' -f1 | sed 's/\./\//g')
    mkdir -p "$ARCHETYPE_LOCAL/$LINE_PATH"
    cp -rf "$LOCAL_REPO_DIR/$LINE_PATH/*" "$ARCHETYPE_LOCAL/$LINE_PATH"
done

echo -e $GREN"export ok."$NC
