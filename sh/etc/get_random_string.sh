#!/bin/bash

loop=10
length=16

for ((i=1; i <= loop; i++))
do
  tr -dc '_a-zA-Z0-9' < /dev/urandom | head -c $length; echo
done

