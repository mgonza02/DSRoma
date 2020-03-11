#!/bin/bash
SRC=${3##*/}
echo "Welcome, in this moment will create snapshot"
if [ ! -b "$1" -o -z "$2" -o -z "$3" -o -z "$SRC" ]; then
        echo "Usage: $0 <dev> <dir> <subvolume>" 1>&2
        echo
        echo "Create snapshot from a btrfs subvolume"
        echo
        echo "<dev> Super block for mount "
        echo
        echo "<dir> directory for mount dev"
        echo
        echo "<subvolume> Subvolume name for snapshot"
        exit 1
fi
if [ ! -d "$2" ]; then
        echo "Creating directory $2"
        mkdir $2
fi
echo "Mounting   $1 in $2"
mount $1 $2
echo "Mounted   $1 in $2"
BACK="${SRC}-ss-$(date '+%Y%m%d-%H%M')"
DST="${2}/${BACK}"
echo "Creating snapshot ${2}/$3 in   ${DST} "
btrfs subvolume snapshot ${2}/$3 ${DST}
btrfs subvolume list ${2}
umount $2
echo "Unmounted $2 "
echo "Finished"
