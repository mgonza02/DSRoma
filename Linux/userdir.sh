#!/bin/bash
##
## Copyright (c) 2020 gm
##
## Create user folder for DSROMASA.COM users
## Version 3. See the file COPYING for more details.
##
USER="$1@dsromasac.com"

USE_MSG=" Modo de uso  ./xxx  <username> <type:1|2>"

if id -u "${USER}" >/dev/null 2>&1; then
    echo $USER exists
else
    echo "Invalid user $USER"
    exit 1
fi
USERDIR="/media/dsroma/cloud/home/${USER}"
USERPATH=${USERDIR}

if [ ! "protected" = "$2" ]; then
    USERPATH="/media/dsroma/backup/home/${USER}"
    if [[ ! -L "$USERDIR" && -d "$USERDIR" ]]; then
        echo "Ya existe ${USERDIR}"
        if [ -d "$USERPATH" ]; then
            echo "Ya existe  ${USERPATH}"
            echo "No se puede continuar"
            exit 1
        fi
        echo "Moviendo carpeta  ${USERDIR} to ${USERPATH}"
        mv "${USERDIR}   ${USERPATH}"
    fi
else
    if [[ ! -L "$USERDIR" && -d "$USERDIR" ]]; then
        echo "Ya se ha creado ${USERPATH}"
    fi

fi
echo "User home directory ${USERDIR}"
echo "User folder location  ${USERPATH}"

if [ ! -d "$USERPATH" ]; then
    echo "creadondo ${USERPATH}"
    mkdir "${USERPATH}"
    echo "creado ${USERPATH}"
fi
echo "Aplicando permisos"
chown -R "${USER}" "${USERPATH}"
chmod -R 700 "${USERPATH}"

if [ ! $USERDIR = $USERPATH ]; then
    if [[ -L "$USERDIR" && -d "$USERDIR" ]]; then
        echo "$USERDIR is a symlink to a directory"
    else
        echo "creado  enlace  ${USERDIR} a  ${USERPATH}"
        ln -s ${USERPATH} ${USERDIR}
    fi
    echo "Aplicando permisos  al enlace"
    chown -R "${USER}" "${USERDIR}"
    chmod -R 700 "${USERDIR}"

fi
