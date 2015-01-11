#!/bin/bash
#Script finds drives not listed in fstab, adds an entry, 
#and creates the required mount points, then mounts them

FILES=$(ls /dev/disk/by-uuid/)

DT=$(date)

echo	"# Autoadded entries, added ${DT}" >> /etc/fstab

for f in $FILES
do
	if more /etc/fstab|grep -q  "$f"
	then
		echo "Found disk ${f}, but it is already in fstab."
	else
		echo "Found fisk ${f}, and it's not listed in fstab."
		fs=$(blkid -o value -s TYPE /dev/disk/by-uuid/${f})
		if [ ! -d "/media/$f" ];
		then
			echo "Mount point doesn't exist, creating it."
			mkdir /media/${f}
		fi
		echo "Mounting it in /media/${f}"
##		mount -t ${fs} --source UUID=${f} --target /media/${f}
		echo "UUID=${f} /media/${f} ${fs}  errors=remount-ro 0 1" >> /etc/fstab
		echo "Checking subdirectories"
		BINDS=$(ls -I lost* /media/${f})
		for exp in $BINDS
		do
			if [ -d /media/${f}/${exp} ];
			then
				echo "Found a directory called ${exp}, I'll mount it."
				if [ ! -d /export/${exp} ];
				then
					mkdir -p /export/${exp}
				fi
				echo "/media/${f}/${exp} /export/${exp} none bind 0 0" >> /etc/fstab
##				mount --bind /media/${f}/${exp} /export/${exp}
			else
				echo "Found ${exp}, but it looks like a file so I'll ignore it."
			fi
		done
	fi
done
