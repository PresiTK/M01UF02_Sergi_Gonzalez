#!/bin/bash

if [ "$1" == "" ]
then
    echo "Indica la Direccion del servido"
    exit 1
fi

SERVER_IP=$1

CLIENT_IP=`ip a | grep "scope global" | xargs | cut -d " " -f 2 | cut -d "/" -f 1`
PORT="2022"

echo "Client DMAM 2022"

echo "1. ENVÍO DE HEADER"

echo "DMAM $CLIENT_IP" | nc 27.0.0.1 $PORT

DATA=`nc -l $PORT`

echo "3. COMPROBANDO HEADER"
if [ "$DATA" != "HEADER_OK" ] 
then
    echo "ERROR 1: Error Enviando el Header"
    exit 1
fi

echo "4. FILENAME: Enviando"

FILENAME="dragon.txt"
FILENAME_MD5=`echo -n "$FILENAME" | md5sum | cut -d ' ' -f 1`

echo "FILENAME $FILENAME $FILENAME_MD5" | nc $SERVER_IP $PORT

echo "7.COMPROBACION FILENAME"
DATA=`nc -l $PORT`

if [ "$DATA" != "FILENAME_OK" ]
then
    echo "ERROR 2:Envio incorrecto de FILENAME"
    exit 2
fi

echo "8. ENVIO DE CONTENIDO"

cat "client/$FILENAME" | nc $SERVER_IP $PORT

echo "11. ENVIANDO HASH"

FILECONTENT_MD5=`md5sum "client/$FILENAME" | cut -d ' ' -f 1`
echo "FILE_MD5 $FILECONTENT_MD5" | nc $SERVER_IP $PORT

DATA=`nc -l $PORT`

if [ "$DATA" != "FILE_MD5_OK" ]
then
    echo "ERROR 3: Hash incorrecto"
    exit 3
fi

echo "13. PROCESO FINALIZADO"
