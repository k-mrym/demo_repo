#!/bin/bash
sh
MY_BASENAME=$(basename "$0")
MY_ABS_PATH=$(cd $(dirname "$0"); pwd)/$MY_BASENAME

chmod +x "$MY_ABS_PATH"

IMG=https://gekibuzz.com/wp-content/uploads/2022/02/gekibuzz-2022-02-02_17-26-15_872706.jpg
PRE_IMAGE_NAME="img___"
EXT=".png"
ORG_IMG_NAME="${PRE_IMAGE_NAME}0${EXT}"
NUM=2

##### ダウンロードさせた場合
cd ~/Desktop || return
# wget $IMG -O $ORG_IMG_NAME
curl $IMG > $ORG_IMG_NAME
for i in $(seq $NUM)
do
	##### OSの判定
	if [ "$(uname)" == "Darwin" ]; then
		### Mac
		cp $ORG_IMG_NAME "${PRE_IMAGE_NAME}${i}${EXT}"
		open "${PRE_IMAGE_NAME}${i}${EXT}"
	elif [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then
		### Windows
		copy $ORG_IMG_NAME "${PRE_IMAGE_NAME}${i}${EXT}"
		start "${PRE_IMAGE_NAME}${i}${EXT}"
	elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
		### Linux
		cp $ORG_IMG_NAME "${PRE_IMAGE_NAME}${i}${EXT}"
		# xdg-open "${PRE_IMAGE_NAME}${i}${EXT}"
		open "${PRE_IMAGE_NAME}${i}${EXT}"
	else
		echo Unknown OS
	fi
done

exit