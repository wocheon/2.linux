#!/bin/bash
#usage : test_param.sh aa bb cc
echo "================="
echo "\$@ section"
echo "================="
for param in "$@"
do
	echo $param,
	done

	echo "================="
	echo "\$* section"
	echo "================="
	for param in "$*"
	do
		echo $param,
		done
