#!/bin/bash

### README #########################################################
# 
## 許可IP 取得
# bash /usr/local/etc/accept_ips.sh "get"

## 許可IP 取得 firewall更新
# bash /usr/local/etc/accept_ips.sh "update"

## 確認
# firewall-cmd --info-ipset=customize --permanent
# firewall-cmd --get-active-zones
# firewall-cmd --zone=public --list-all
# firewall-cmd --zone=customize --list-all
# 
####################################################################

# get || update
mode="$1"
wait="sleep 1"
countries='JP'
apnic_ip_list_url='http://ftp.apnic.net/stats/apnic/delegated-apnic-latest'
google_ip_url='https://www.gstatic.com/ipranges/goog.json'
hotmail_ip_url='https://endpoints.office.com/endpoints/worldwide?clientrequestid=b10c5ed1-bad1-445f-b386-b919946339a7'
ips_dir=$2
jp_ip=$ips_dir/jp_ip
google_ip=$ips_dir/google_ip
hotmail_ip=$ips_dir/hotmail_ip

if [ -z "$mode" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] mode is empty"
  exit 1
fi

### GET ###
if [ "$mode" = "get" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $mode accept ips start"
  dnf -y install jq

  # Get japan ips -> jp_ip
  curl $apnic_ip_list_url > $ips_dir/delegated-apnic-latest
  :> $jp_ip
  for country in $countries
  do
    for ip in $(cat $ips_dir/delegated-apnic-latest | grep "apnic|$country|ipv4|")
    do
      COUNTRY=$(echo $ip | awk -F"|" '{ print $2 }')
      IPADDR=$(echo $ip | awk -F"|" '{ print $4 }')
      TMPCIDR=$(echo $ip | awk -F"|" '{ print $5 }')
      FLTCIDR=32
      while [ $TMPCIDR -ne 1 ];
      do
        TMPCIDR=$((TMPCIDR/2))
        FLTCIDR=$((FLTCIDR-1))
      done
      echo "$IPADDR/$FLTCIDR" >> $jp_ip
    done
  done
  rm -f $ips_dir/delegated-apnic-latest

  # # Get google ips -> google_ip
  # curl $google_ip_url > $ips_dir/google.json
  # :> $google_ip
  # jq -r '.prefixes[] | select(.ipv4Prefix) | .ipv4Prefix' $ips_dir/google.json > $google_ip
  # rm -f $ips_dir/google.json

  # # Get hotmail ips -> hotmail_ip
  # curl $hotmail_ip_url > $ips_dir/hotmail.json
  # :> $hotmail_ip
  # jq -r '.[] | select(.ips) | .ips[] | select(index("::") | not)' $ips_dir/hotmail.json > $hotmail_ip
  # rm -f $ips_dir/hotmail.json

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $mode accept ips completed"

### UPDATE ###
elif [ "$mode" = "update" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $mode accept ips start"

  zone="customize"

  firewall-cmd --delete-ipset=$zone --permanent
  $wait
  firewall-cmd --zone=$zone --remove-source=ipset:$zone --permanent
  $wait
  bash "$0" "get"
  firewall-cmd --new-ipset=$zone --type=hash:net --permanent
  $wait
  ip_files=($(ls "$ips_dir" | grep -v "^_"))
  for file in "${ip_files[@]}"; do
    exec_file="$ips_dir/$file"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] [Line:$LINENO] exec_file: ${exec_file}"
    firewall-cmd --ipset=$zone --add-entries-from-file="$exec_file" --permanent
    $wait
  done
  firewall-cmd --zone=$zone --add-source=ipset:$zone --permanent
  $wait
  firewall-cmd --reload
  $wait

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $mode accept ips completed"

### OTHER ###
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] mode is other: $mode"
  exit 1
fi
