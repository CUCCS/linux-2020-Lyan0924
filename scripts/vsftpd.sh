#!/usr/bin/env bash

source ./config.sh

apt-get update

command -v vsftpd > /dev/null
#是否下载vsftpd
if [[ $? -ne 0 ]];then
	apt-get install vsftpd -y
	if [[ $? -ne 0 ]];then
		echo "failed to install vsftpd"
		exit
	fi
else
	echo "Successfully install vsftpd"
fi

#创建匿名用户测试用的文件目录
if [[ ! -d "${anonymity_path}" ]];then 
	mkdir -p "$anonymity_path"
	echo"anonymous file is created"
fi
chown nobody:nogroup "$anonymity_path"
echo "vsftpd test file for anonymous user" | tee "${anonymity_path}/test_a.txt"


# 修改配置文件，先检查有没有备份
config=/etc/vsftpd.conf
if [[ ! -f "${config}.bak" ]];then
	cp "$config" "$config".bak
fi

#修改权限，匿名用户只读权限
sed -i -e '/anonymous_enable=/s/NO/YES/g;/anonymous_enable=/s/#//g' "$config" 
sed -i -e '/local_enable=/s/NO/YES/g;/local_enable=/s/#//g' "$config"
sed -i -e '/write_enable=/s/NO/YES/g;/write_enable=/s/#//g' "$config"
sed -i -e '/anon_mkdir_write_enable=/s/YES/NO/g' "$config"
sed -i -e '/anon_upload_enable=/s/YES/NO/g;/anon_upload_enable=/s/#//g' "$config"
sed -i -e '/chroot_local_user=/s/NO/YES/g;/chroot_local_user=/s/#//g' "$config"

#添加支持用户名和密码方式访问的账号
#用户不存在的话则重新创建一个
if [[ $(grep -c "^$user:" /etc/passwd) -eq 0 ]];then
	useradd $user
	echo "created a new user:$user"
else
	echo "user ${user} already exists "
fi

#用户目录不存在的话则创建一个
if [[ ! -d "$user_path" ]];then 
	mkdir -p "$user_path"
	echo "user file is created"
fi

#设置权限
chown nobody:nogroup "$user_path"

user_write_path="${user_path}/files"


#用户读写测试目录不存在的话则创建一个
if [[ ! -d "$user_write_path" ]];then 
	mkdir "$user_write_path"
	echo "user test file is created"
fi

chown "$user":"$user" "$user_write_path"
ls -la "$user_write_path"
echo "vsftpd test file for the login user" | tee "${user_write_path}/test_u.txt"

if [[ -z $(cat "$config" | grep "userlist_file=/etc/vsftpd.userlist") ]];then

#向配置文件添加如下内容
cat<<EOT >>/etc/vsftpd.conf

local_root=/home/%LOCAL_ROOT%/ftp
userlist_file=/etc/vsftpd.userlist
userlist_enable=YES
userlist_deny=NO

anon_root=/var/ftp/
no_anon_password=YES
hide_ids=YES

pasv_min_port=40000
pasv_max_port=50000

#只允许白名单用户访问
tcp_wrappers=YES

EOT
fi

#将用户添加到userlist才能访问
grep -q "$user" /etc/vsftpd.userlist ||  echo "$user" | tee -a /etc/vsftpd.userlist
grep -q "anonymous" /etc/vsftpd.userlist || echo "anonymous" | tee -a /etc/vsftpd.userlist

#添加白名单内容
grep -q "vsftpd:ALL" /etc/hosts.deny || echo "vsftpd:ALL" >> /etc/hosts.deny
grep -q "vsftpd:192.168.203.3" /etc/hosts.allow || echo "vsftpd:192.168.203.3" >> /etc/hosts.allow

service vsftpd restart


