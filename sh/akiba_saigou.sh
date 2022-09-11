#!/bin/bash
chmod +x akiba_saigou.sh
cd ../../Desktop \
|| wget https://img.gifmagazine.net/gifmagazine/images/2315946/medium_thumb.png -O "akiba_no_saigoutakamori_0.png"

for i in $(seq 5)
do
	cp "akiba_no_saigoutakamori_0.png" "akiba_no_saigoutakamori_${i}.png"
	###winの場合###
	start "akiba_no_saigoutakamori_${i}.png"
	# ###macの場合###
	# open "akiba_no_saigoutakamori_${i}.png"
done
