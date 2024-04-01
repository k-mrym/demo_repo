#!/bin/bash

### NOTE #######################################################
# bash /home/moriyama/add_mail_address.sh user_name domain forward@mail.com
# 
#  $1 : user_name            : string
#  $2 : mail_domain          : ex) user_name@site_domain
#  $3 : forward_mail_address : ex) forward@email_address.com
################################################################

### variable ###################################################
WHOAMI=$(whoami)
AUTHORITY="root"
USER=$1
DOMAIN=$2
FORWARD_MAIL=$3
USER_MAIL="$USER@$DOMAIN"
PASS_LENGTH=12
PASS=$(echo $RANDOM | md5sum | head -c "$PASS_LENGTH"; echo;)
message=""
FORWARD_CONFIG="/home/$USER/.forward"
DOVECOT_CONFIG="/etc/dovecot.passwd"
################################################################

### functions ##################################################
__exit () {
  echo "$1"
  echo "user_mail    : { $2 }"
  echo "user_pass    : { $3 }"
  echo "forward_mail : { $4 }"
  exit "$5"
}
###############################################################


### process ###################################################

if [ "$WHOAMI" != "$AUTHORITY" ]; then
  message="!ERROR!_Dose_not_have_execut_permission."
  __exit "$message" "" "" "" 1
fi

if [ -z "$USER" ] || [ -z "$DOMAIN" ] ; then
  message="!ERROR!_Empty_aguments."
  __exit "$message" "" "" "" 1
fi

# set user
useradd "$USER"
echo "$PASS" | passwd "$USER" --stdin

# make mail directory
mkdir -p /home/"$USER"/Maildir/cur
mkdir -p /home/"$USER"/Maildir/new
mkdir -p /home/"$USER"/Maildir/tmp

chown -R "$USER":"$USER" /home/"$USER"/Maildir

# check user_id and group_id
USER_ID=$(id -u "$USER")
GROUP_ID=$(id -g "$USER")

# dovecot setting
STR="$USER_MAIL:{plain}$PASS:$USER_ID:$GROUP_ID::/home/$USER:/usr/sbin/nologin"
echo "$STR" >> "$DOVECOT_CONFIG"
service dovecot restart

if [ -z "$FORWARD_MAIL" ] ; then
  message="!Completed!_No_forward_setting."
  __exit "$message" "$USER_MAIL" "$PASS" "$FORWARD_MAIL" 0
fi

# forward setting
touch "$FORWARD_CONFIG"
echo "~/Maildir/" >> "$FORWARD_CONFIG"
echo "$FORWARD_MAIL" >> "$FORWARD_CONFIG"

message="!Completed!_ALL."
__exit "$message" "$USER_MAIL" "$PASS" "$FORWARD_MAIL" 0
