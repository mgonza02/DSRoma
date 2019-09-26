#!/bin/bash
SRC=${1##*/}
if [ ! -d "$1" -o -z "$2" -o -z "$SRC" ]; then
        echo "Usage: $0 <orig> <dest>" 1>&2
        echo
        echo "This program tries compress folder and backup"
        echo "compress directory (recursively)"
        echo
        echo "<orig> Orig folder"
        echo "<dest> must be a writable directory with enough free space"
        exit 1
fi
if [ !  -d "$1" ]
then
        echo "Invalid source $1"
        exit 1
fi
if [ !  -d "$2" ]
then
        echo "Invalid target $2"
        exit 1
fi
echo "Iniciando copia de $1 en $2"
BACK="$(date '+%Y%m%d-%H%M')"
TARGET=$2
ZIPFILE="${TARGET}/${SRC}-${BACK}.zip"
TARFILE="${TARGET}/${SRC}-${BACK}.tar.gz"
echo "Packing ${ZIPFILE}"
tar -czf "${TARFILE}"   $1
#zip -r "${ZIPFILE}"  "$1" &> /dev/null
echo "Finalizado"
exit 1
