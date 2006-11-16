#!/bin/bash 

while [ $1 ] ; do
	echo ${1} | grep -v "^$" | while read ff; do
        	if [ -f /${ff} ] && [ ! -f /${ff}.sunos-original ];  then
                	mv /${ff} /${ff}.sunos-original
                	echo "     /${ff} => /${ff}.sunos-original"
		else
			echo "     ${ff} does not exist"
        	fi
	done
	shift
done

