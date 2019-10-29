#!/bin/bash
FILEPREFIX="pedidos"
FILEPREFIX=$1
CURRENT_PERIOD="$(date '+%Y%m')"
FECHA_ARCH=`date -d "$(date +%Y-%m-01) -1 day" +%Y%m%d`
PERIODO_ARCH=`date -d "$(date +%Y-%m-01) -1 day" +%Y%m`
PERIODO_ARCH="201909"
cd  /media/backup/sqlserver/
#FILE="$(find  hst/entregas*.bak -mtime +2 -print & ) |   head -n 1"
echo "" > file.tx
(find  backup/${FILEPREFIX}_20*.bak -mtime +2 -print & ) | sort -zr | head -n 1 > file.tx
FILE="$(cat file.tx)"
NAME=${FILE##*/}
if [ -f "$FILE" ]; then
    BACK_FILE="hst/${NAME}"
    if [ -f "$BACK_FILE" ]; then
        mv $BACK_FILE "${BACK_FILE}.copy"
    fi
    mv "${FILE}" "${BACK_FILE}"
    echo "$(date) Archived ${FILE} in ${BACK_FILE}" >> hst/${FILEPREFIX}.${CURRENT_PERIOD}.log
    echo "Procesed hst ${FILE}"
    if [ -f "$BACK_FILE" ]; then
        find  backup/${FILEPREFIX}_20*.bak -mtime +2  -exec mv {} trash/ \;  
    fi
else 
    echo "No Hay Archivo backup ${FILE}"
fi
echo "" > file.tx
(find  hst/${FILEPREFIX}_${PERIODO_ARCH}*.bak -mtime +17 -print & ) | sort -zr | head -n 1 > file.tx
FILE="$(cat file.tx)"
if [ -f "$FILE" ]; then
    BACK_FILE="final/${FILEPREFIX}_${PERIODO_ARCH}.bak"
    if [ -f "$BACK_FILE" ]; then
        mv $BACK_FILE "${BACK_FILE}.copy"
    fi
    mv "${FILE}" "${BACK_FILE}"
    echo "$(date) Archived ${FILE} in ${BACK_FILE}" >> final/${FILEPREFIX}.${PERIODO_ARCH}.log
    echo "Procesed final ${FILE}"
    if [ -f "$BACK_FILE" ]; then
        find  backup/${FILEPREFIX}_20*.bak -mtime +12  -exec mv {} trash/ \;  
    fi
else 
    echo "No Hay Archivo hst ${FILE}"
fi
mv hst/*.copy trash/
mv final/*.copy trash/
echo "Finished"
exit 1