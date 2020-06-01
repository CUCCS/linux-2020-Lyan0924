#!/usr/bin/env bash

source ./config.sh

apt-get update

if [[ $? -ne 0 ]];then
	echo "apt update failed"
	exit
fi

#下载samba
apt install samba -y
if [[ $? -ne 0 ]];then
	echo "install samba failed"
	exit
fi

#下载samba-client
apt install samba-client -y
if [[ $? -ne 0 ]];then
	echo "install samba failed"
	exit
fi

#建立挂载目录
mkdir -p "$mount_path"
if [[ $? -ne 0 ]];then
	echo "mkdir mount_path failed"
	exit
fi

