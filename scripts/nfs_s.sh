#!/usr/bin/env bash

source ./config.sh

apt-get update

if [[ $? -ne 0 ]];then
	echo "apt update failed"
	exit
fi

下载nfs服务器端
apt install nfs-kernel-server -y
if [[ $? -ne 0 ]];then
	echo "install nfs-kernel-server failed"
	exit
fi

#建立只读访问权限的共享目录
mkdir -p "$nfs_sr"
if [[ $? -ne 0 ]];then
	echo "mkdir nfs_share_rfile failed"
	exit
fi


#建立读写访问权限的共享目录
mkdir -p "$nfs_srw"
if [[ $? -ne 0 ]];then
	echo "mkdir nfs_share_rwfile failed"
	exit
fi


#建立只读访问权限的共享子目录
nfs_child_sr="${nfs_sr}/files"
mkdir "$nfs_child_sr"
if [[ $? -ne 0 ]];then
	echo "mkdir nfs_share_child_rfile failed"
	exit
fi

#建立读写访问权限的共享子目录
nfs_child_srw="${nfs_srw}/files"
mkdir "$nfs_child_srw"
if [[ $? -ne 0 ]];then
	echo "mkdir nfs_share_child_rwfile failed"
	exit
fi


chown -R nobody:nogroup "$nfs_sr"
chown -R nobody:nogroup "$nfs_srw"

config=/etc/exports
#编辑配置文件/etc/exports
if [[ ! -f "${config}.bak" ]];then
	cp "$config" "$config".bak
fi
cat<<EOT >>"$config"

$nfs_sr ${clientip}(ro,sync,no_subtree_check)
$nfs_srw ${clientip}(rw,sync,no_subtree_check)

EOT

systemctl restart nfs-kernel-server

