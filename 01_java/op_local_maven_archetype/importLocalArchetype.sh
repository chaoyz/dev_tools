#!/bin/bash

# author: yc
# desc: 将导出的archetype，导入到本地maven

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

# 检查archetype——local目录
if [ ! -d "$SHELL_DIR/archetype_local" ]; then
    echo -e $RED"archetype_local not found."$NC
    exit -1
fi

# 检查archetype——local目录中文件是否合法
if [ ! -f "$SHELL_DIR/archetype_local/archetype-catalog.xml" ];then
    echo -e $RED"archetype_local archetype-catalog.xml not found."$NC
    exit -1
fi

# 检查archetype-catalog.xml对应文件夹是否存在
TMP=$(cat $SHELL_DIR/archetype_local/archetype-catalog.xml | grep "groupId")
for line in $TMP
do
    LINE_PATH=$(echo $line | sed s/[[:space:]]//g | cut -d '>' -f2 | cut -d '<' -f1 | sed 's/\./\//g')
    if [ ! -d "$SHELL_DIR/archetype_local/$LINE_PATH" ]; then
        echo -e $RED"archetype_local dir structure error."$NC
        exit -1
    fi
done

# 查找MAVEN安装位置，本地仓库位置
MAVEN_HOME=$(mvn -v | grep "Maven home:" | cut -d ":" -f2 | sed s/[[:space:]]//g)
MAVEN_CONF_DIR="$MAVEN_HOME/conf"
cd $MAVEN_CONF_DIR
LOCAL_REPO_DIR=$(cat settings.xml | grep "<localRepository>" | cut -d '>' -f2 | cut -d '<' -f1)
if [ "$LOCAL_REPO_DIR" = "/path/to/local/repo" ]; then
    # 没有设置过本地仓库地址使用默认地址
    USER_HOME=$(echo ~)
    LOCAL_REPO_DIR="$USER_HOME/.m2/repository"
fi

if [ ! -d "$LOCAL_REPO_DIR" ]; then
    mkdir -p "$LOCAL_REPO_DIR"
fi

if [ ! -f "$LOCAL_REPO_DIR/archetype-catalog.xml" ];then
    # 文件不存在直接拷贝到仓库目录下
    cp "$SHELL_DIR/archetype_local/archetype-catalog.xml" "$LOCAL_REPO_DIR/"
else
    # 文件存在将archetype-catalog.xml解析，判断是否存在相应的archetype，如存在则跳过并提示打印到控制台，不存在则将部分拷贝到repository目录中的配置文件中
    ROWS=$(cat $SHELL_DIR/archetype_local/archetype-catalog.xml | grep "groupId" | wc -l)
    IMPORT_ARTIFACTIDS=$(cat $SHELL_DIR/archetype_local/archetype-catalog.xml | grep "artifactId")
    IMPORT_ARTIFACTIDS_ARR=()
    i=1
    for line in $IMPORT_ARTIFACTIDS
    do
        artifactId=$(echo $line | sed s/[[:space:]]//g | cut -d '>' -f2 | cut -d '<' -f1)
        IMPORT_ARTIFACTIDS_ARR[$i]=$artifactId
        : $(( i++ ))
    done
    IMPORT_VERSIONS=$(cat $SHELL_DIR/archetype_local/archetype-catalog.xml | grep "<version>")
    IMPORT_VERSIONS_ARR=()
    i=1
    for line in $IMPORT_VERSIONS
    do
        version=$(echo $line | sed s/[[:space:]]//g | cut -d '>' -f2 | cut -d '<' -f1)
        IMPORT_VERSIONS_ARR[$i]=$version
        : $(( i++ ))
    done
    # IMPORT_DES=$(cat $SHELL_DIR/archetype_local/archetype-catalog.xml | grep "<description>")
    # IMPORT_DES_ARR=()
    # i=1
    # for line in $IMPORT_DES
    # do
    #     des=$(echo $line | sed s/[[:space:]]//g | cut -d '>' -f2 | cut -d '<' -f1)
    #     IMPORT_DES_ARR[$i]=$des
    #     : $(( i++ ))
    # done
    i=1
    IMPORT_GROUPIDS_ARR=()
    for line in $TMP
    do
        groupId=$(echo $line | sed s/[[:space:]]//g | cut -d '>' -f2 | cut -d '<' -f1)
        IMPORT_GROUPIDS_ARR[$i]=$groupId
        : $(( i++ ))
    done

    # 遍历数组获取版本信息
    for i in "${!IMPORT_GROUPIDS_ARR[@]}";
    do
        echo "i:$i"
        groupId=${IMPORT_GROUPIDS_ARR[$i]}
        artifactId=${IMPORT_ARTIFACTIDS_ARR[$i]}
        version=${IMPORT_VERSIONS_ARR[$i]}
        #  | sed 's/\./\\./g'
        STRING=$(echo "<archetype><groupId>$groupId</groupId><artifactId>$artifactId</artifactId><version>$version</version>")
        # cat $LOCAL_REPO_DIR/archetype-catalog.xml | tr "\n" " " | sed 's/[[:space:]]//g'
        RESULT=$(cat $LOCAL_REPO_DIR/archetype-catalog.xml | tr "\n" " " | sed 's/[[:space:]]//g' | grep "$STRING")
        if [ "$RESULT" == "" ]; then
            # 插入到</archetype>标签之前
            LAST_LABEL_NUM=$(cat $LOCAL_REPO_DIR/archetype-catalog.xml | grep -n "</archetypes>" | cut -d ":" -f1)
            echo "LAST_LABEL_NUM:$LAST_LABEL_NUM"
            # 在这一行上面插入数据
            DATA="<archetype><groupId>$groupId</groupId><artifactId>$artifactId</artifactId><version>$version</version></archetype>"

            # 这里mac基于bsd下sed使用方法 linux下使用方法可能不同
            CONTENT=$(cat "$LOCAL_REPO_DIR/archetype-catalog.xml" | sed "${LAST_LABEL_NUM}i\\
            ${DATA}
            ")
            echo "$CONTENT" > "$LOCAL_REPO_DIR/archetype-catalog.xml"
        fi
    done
    # 覆盖文件
    for i in "${!IMPORT_GROUPIDS_ARR[@]}";
    do
        groupId=${IMPORT_GROUPIDS_ARR[$i]}
        artifactId=${IMPORT_ARTIFACTIDS_ARR[$i]}
        dir=$(echo $groupId | sed s/[[:space:]]//g | cut -d '>' -f2 | cut -d '<' -f1 | sed 's/\./\//g')
        if [ ! -d "$LOCAL_REPO_DIR/$dir" ]; then
            # echo "${dir} not found."
            mkdir -p $LOCAL_REPO_DIR/$dir
        fi
        cp -rf "$SHELL_DIR/archetype_local/${dir}/$artifactId" "$LOCAL_REPO_DIR/${dir}"
    done
fi

# 覆盖文件
#for i in "${!IMPORT_GROUPIDS_ARR[@]}";
#do
#    groupId=${IMPORT_GROUPIDS_ARR[$i]}
#    artifactId=${IMPORT_ARTIFACTIDS_ARR[$i]}
#    dir=$(echo $groupId | sed s/[[:space:]]//g | cut -d '>' -f2 | cut -d '<' -f1 | sed 's/\./\//g')
#    if [ ! -d "$LOCAL_REPO_DIR/$dir" ]; then
#        # echo "${dir} not found."
#        mkdir -p $LOCAL_REPO_DIR/$dir
#    fi
#    cp -rf "$SHELL_DIR/archetype_local/${dir}/$artifactId" "$LOCAL_REPO_DIR/${dir}"
#done

echo -e $GREN"import ok."$NC
