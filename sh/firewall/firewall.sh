#!/bin/bash

## CentOS7~, Rocky Linux

echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] START: ${BASH_SOURCE[0]}"

# 依存ライブラリのインストール
dnf -y install jq

#### Definition ##############################################
wait="sleep 1"
tmp_assets_dir=./assets
usr_assets_dir=/usr/local/etc
usr_ips_dir=${usr_assets_dir}/ips
root_ip="255.255.255.255" # Self global IP adress
root_allow_ports=(52022 9090)
# - ssh: 52022/tcp
# - cockpit: 9090/tcp

## 
# @param $1 zone
# @param $2 array files
make_zone_accept_ip() {
  local zone=$1
  declare -n files=$2

  if [ "${zone}" != "public" ]; then
    firewall-cmd --delete-zone="$zone" --permanent
    $wait
  fi
  firewall-cmd --delete-ipset="$zone" --permanent
  $wait
  firewall-cmd --reload
  $wait
  if [ "${zone}" != "public" ]; then
    firewall-cmd --new-zone="$zone" --permanent
    $wait
  fi
  firewall-cmd --new-ipset="$zone" --type=hash:net --permanent
  $wait
  firewall-cmd --reload
  $wait
  for file in "${files[@]}" ; do
    accept_ip_file="${usr_ips_dir}/${file}"
    if [ ! -f "${accept_ip_file}" ]; then
      continue;
    fi
    firewall-cmd --ipset="$zone" --add-entries-from-file="$accept_ip_file" --permanent
    $wait
  done
  firewall-cmd --info-ipset="$zone" --permanent
  $wait
  firewall-cmd --zone="$zone" --add-source=ipset:"$zone" --permanent
  $wait
  firewall-cmd --reload
  $wait
}

## 
# @param $1 source|service|port|rich-rule|forward-ports
# @param $2 array resource
# @param $3 zone
add_rules_zone() {
  local rule=$1
  declare -n resource=$2
  local zone=$3

  list=$(firewall-cmd --zone="$zone" --list-"${rule}s")
  $wait
  echo -e "[INFO] [Line:$LINENO] list: $list"

  for v in "${resource[@]}"; do
    if [[ "$list" = *"$v"* ]]; then
      echo -e "[INFO] [Line:$LINENO] !skip! $rule: $v"
      continue
    fi
    echo -e "[INFO] [Line:$LINENO] Add $rule: $v"
    firewall-cmd --zone="$zone" --add-"$rule"="$v" --permanent
    $wait
  done
}
##############################################################

# 起動
systemctl restart firewalld
$wait
echo -e "[INFO] [Line:$LINENO] status: \n$(systemctl status firewalld)"
$wait
# setting before
echo -e "[INFO] [Line:$LINENO] list-all: \n$(firewall-cmd --list-all)"
$wait

# 許可／拒否IP スクリプト配置 
\cp -f ${tmp_assets_dir}/accept_ips.sh ${usr_assets_dir}
\cp -rf ${tmp_assets_dir}/ips ${usr_assets_dir}
chmod -R 777 ${usr_assets_dir}

# 許可IP usr_ips_dir 取得  @todo 毎月update
sh ${usr_assets_dir}/accept_ips.sh "get" "$usr_ips_dir"

# Create zone customize
declare -a allow_ip_files=($(ls ${usr_ips_dir} | grep -v "^_"))
make_zone_accept_ip 'customize' allow_ip_files

# zone=public 削除
firewall-cmd --zone=public --remove-port={25/tcp,80/tcp,443/tcp,110/tcp,143/tcp,465/tcp,587/tcp,993/tcp,995/tcp,11211/tcp,9001/tcp} --permanent
$wait
firewall-cmd --zone=public --remove-service={ssh,cockpit,http,https,smtp,smtps,pop3,pop3s,imaps,imaps} --permanent
$wait

# firewall-cmd --zone=customize --add-source=127.0.0.1/32 --permanent
declare -a add_sources=('127.0.0.1/32')
add_rules_zone 'source' add_sources 'customize'

# firewall-cmd --zone=customize --add-service={http,https,smtp,smtps,pop3,pop3s,imap,imaps} --permanent
declare -a add_services=('dhcpv6-client' 'http' 'https' 'smtp' 'smtps' 'pop3' 'pop3s' 'imap' 'imaps')
add_rules_zone 'service' add_services 'customize'

# firewall-cmd --zone=customize --add-port={11211/tcp,9001/tcp} --permanent
declare -a add_ports=('11211/tcp' '9001/tcp')
add_rules_zone 'port' add_ports 'customize'

# firewall-cmd --zone=customize --add-forward-port=port=587:proto=tcp:toport=25 --permanent
declare -a add_forward_ports=('port=587:proto=tcp:toport=25')
add_rules_zone 'forward-port' add_forward_ports 'customize'

# # SYNフラッド攻撃対策
# firewall-cmd --zone=customize --add-rich-rule="rule limit value=\"20/s\" port port=\"80\" protocol=\"tcp\" log prefix=\"[SYNFLOOD] : \" level=\"debug\" drop" --permanent
# $wait
# firewall-cmd --zone=customize --add-rich-rule="rule limit value=\"20/s\" port port=\"443\" protocol=\"tcp\" log prefix=\"[SYNFLOOD] : \" level=\"debug\" drop" --permanent
# $wait

# Allow ICMP (ping) but rate limit
firewall-cmd --zone=customize --add-rich-rule='rule icmp-type name="echo-request" limit value="2/s" log prefix="[PINGDEATH] : " level="debug" accept' --permanent
$wait

# root_ip のみ root_allow_ports 許可
for v in "${root_allow_ports[@]}" ; do
  firewall-cmd --zone=customize --add-rich-rule="rule family=\"ipv4\" source address=\"${root_ip}\" port port=\"${v}\" protocol=\"tcp\" accept" --permanent
  $wait
done

# 反映
firewall-cmd --reload
$wait
systemctl reload firewalld

# # 自動起動ON
enable_service "firewalld"

echo -e "[INFO] [Line:$LINENO] get-active-zones: \n$(firewall-cmd --get-active-zones)"
$wait
for zone in $(firewall-cmd --get-active-zones | grep -v "^  "); do
  echo -e "[INFO] [Line:$LINENO] --zone=$zone --list-all: \n$(firewall-cmd --zone="$zone" --list-all)"
  $wait
done

# Protect against redirect and source route attacks
tmp=$(grep 'accept_redirects' /etc/sysctl.conf)
if [ -z "${tmp}" ]; then
cat << 'EOF' >> /etc/sysctl.conf

# Protect MITM attacks
net.ipv4.conf.all.accept_redirects=0
net.ipv6.conf.all.accept_redirects=0
EOF
fi

tmp=$(grep 'accept_source_route' /etc/sysctl.conf)
if [ -z "${tmp}" ]; then
cat << 'EOF' >> /etc/sysctl.conf

# This terminal is not a router
net.ipv4.conf.all.accept_source_route=0
net.ipv6.conf.all.accept_source_route=0
EOF
fi

# 反映
sysctl -p


echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] END: ${BASH_SOURCE[0]}"



#### note #########################################################
## 手動
# bash /usr/local/etc/accept_ips.sh "get"
# firewall-cmd --new-zone=public --permanent
# firewall-cmd --new-ipset=public --type=hash:net --permanent
# firewall-cmd --ipset=public --add-entries-from-file=/usr/local/etc/ips/jp_ip --permanent
# firewall-cmd --ipset=public --add-entries-from-file=/usr/local/etc/ips/allow_ip --permanent
# firewall-cmd --ipset=public --add-entries-from-file=/usr/local/etc/ips/google_ip --permanent
# firewall-cmd --ipset=public --add-entries-from-file=/usr/local/etc/ips/hotmail_ip --permanent
# firewall-cmd --info-ipset=public --permanent
# firewall-cmd --zone=public --add-source=ipset:public --permanent
# firewall-cmd --zone=public --add-source=127.0.0.1/32 --permanent
# firewall-cmd --zone=public --add-service={http,https,smtp,smtps,pop3,pop3s,imap,imaps} --permanent
# firewall-cmd --zone=public --add-forward-port=port=587:proto=tcp:toport=25 --permanent
# firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="114.156.139.161" port port="52022" protocol="tcp" accept' --permanent
# firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="114.156.139.161" port port="9090" protocol="tcp" accept' --permanent
# firewall-cmd --zone=public --add-rich-rule="rule limit value=\"20/s\" port port=\"80\" protocol=\"tcp\" log prefix=\"[SYNFLOOD] : \" level=\"debug\" drop" --permanent
# firewall-cmd --zone=public --add-rich-rule="rule limit value=\"20/s\" port port=\"443\" protocol=\"tcp\" log prefix=\"[SYNFLOOD] : \" level=\"debug\" drop" --permanent
# firewall-cmd --zone=public --add-rich-rule='rule icmp-type name="echo-request" limit value="2/s" log prefix="[PINGDEATH] : " level="debug" accept' --permanent
# firewall-cmd --reload
# firewall-cmd --get-zones
# firewall-cmd --get-active-zones
# firewall-cmd --zone=public --list-all

# # firewall-cmd --delete-zone=public --permanent
# # firewall-cmd --delete-ipset=public --permanent
# # firewall-cmd --zone=public --remove-rich-rule='' --permanent
# 
# reference :: https://souiunogaii.hatenablog.com/entry/firewalld-domestic-ip#google_vignette

## 許可IP 取得 firewall更新
# bash /usr/local/etc/accept_ips.sh "update"
###################################################################
