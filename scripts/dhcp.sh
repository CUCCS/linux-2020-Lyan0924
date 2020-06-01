#!/usr/bin/env bash

source ./config.sh

#apt-get update

#if [[ $? -ne 0 ]];then
#	echo "apt update failed"
#	exit
#fi

#下载dhcp服务器
#apt-get install isc-dhcp-server -y
#if [[ $? -ne 0 ]];then
#	echo "install isc-dhcp-server failed"
#	exit
#fi

#修改配置文件，先检查有没有备份
if [[ ! -f "${dhcp_con1}.bak" ]];then
	cp "$dhcp_con1" "$dhcp_con1".bak
fi

if [[ ! -f "${dhcp_con2}.bak" ]];then
	cp "$dhcp_con2" "$dhcp_con2".bak
fi

if [[ ! -f "${dhcp_con3}.bak" ]];then
	cp "$dhcp_con3" "$dhcp_con3".bak
fi

min_time=600
max_time=7200
inter="enp0s9"
subnet="192.168.203.0"
netmask="255.255.255.0"
ip_l="192.168.203.10"
ip_r="192.168.203.100"


#向配置文件中添加如下内容
cat<<EOT >>"$dhcp_con1"
subnet 192.168.203.0 netmask 255.255.255.0 {
	# client's ip address range
	range ${ip_l} ${ip_r};
	default-lease-time ${min_time};
	max-lease-time ${max_time};
}

EOT

cat<<EOT >> "$dhcp_con3"
    enp0s9:
      dhcp4: no
      addresses: [192.168.203.1/24]
EOT


#修改配置文件中内容
sed -i -e "/INTERFACESv4=/s/^[#]//g;/INTERFACESv4=/s/\=.*/=\"${inter}\"/g" "$dhcp_con2"
sed -i -e "/INTERFACESv6=/s/^[#]//g;/INTERFACESv4=/s/\=.*/=\"${inter}\"/g" "$dhcp_con2"
systemctl restart isc-dhcp-server

