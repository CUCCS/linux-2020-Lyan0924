#!/usr/bin/env bash

source ./config.sh

apt-get update
if [[ $? -ne 0 ]];then
	echo "apt update failed"
	exit
fi

#下载nfs客户端
apt install nfs-common -y
if [[ $? -ne 0 ]];then
	echo "install nfs-common failed"
	exit
fi

#建立共享目录安装点
mkdir -p "$nfs_cr"
mkdir -p "$nfs_crw"

#挂载共享目录
mount "$target_ip":"$nfs_sr" "$nfs_cr"
mount "$target_ip":"$nfs_srw" "$nfs_crw"


