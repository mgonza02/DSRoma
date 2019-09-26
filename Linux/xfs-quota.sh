#!/bin/bash
echo "Bienvenido"
echo "Procesando quota para usuario  $1"
HOME_PATH="/home/"
USER_NAME="$1@dsromasac.com"
if [ ! "$1" != "" ]; then
    echo "Es necesario que  ingrese nombre de usuario"
    exit
fi
file="${HOME_PATH}${USER_NAME}"
if [ ! -f "$file" ]
then
    mkdir  "$file"
    echo "$0: File '${file}' created."
fi
winfile="${file}/win"
if [ ! -f "$winfile" ]
then
    mkdir  "$winfile"
    echo "$0: File '${winfile}' created."
fi
mv ${winfile}/$1/*  ${winfile}/
chmod 700 -R $file
#chown -R dsromasac\\$1:dsromasac\\Usuarios\ del\ dominio $file
chown -R  ${USER_NAME}  $file

xfs_quota -x -c "limit bsoft=4G bhard=5G ${USER_NAME}"  ${HOME_PATH}
echo "Finished"
