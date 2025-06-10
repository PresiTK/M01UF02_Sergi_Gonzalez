#!/bin/bash

PORT="2022"

echo "DMAM 2022 Server"

echo "0. ESCUCHANDO CLIENT"

DATA=`nc -l $PORT`

HEADER=`echo "$DATA" | cut -d " " -f 1`
IP=`echo $DATA | cut -d " " -f 2`

if [ "$HEADER" != "DMAM" ]
then
    echo "ERROR 1: HEADER incorrecta"
    echo "KO_HEADER" | nc -q 0 $IP $PORT
    exit 1
fi

echo "Client IP: $IP"

echo "2. CHECK - Enviando OK_HEADER"
echo "OK_HEADER" | nc -q 0 $IP $PORT
DATA=`nc -l $PORT`

echo "5. COMPROBANDO"

PREFIX=`echo "$DATA" | cut -d ' ' -f 1`
FILENAME=`echo "$DATA" | cut -d ' ' -f 2`
OBTAINED_MD5=`echo "$DATA" | cut -d ' ' -f 3`

if [ "$PREFIX" != "FILENAME" ]
then
    echo "ERROR 2: PREFIX incorrecto"
    echo "KO_FILENAME" | nc -q 0 $IP $PORT
    exit 2
fi

GENERATED_MD5=`echo -n "$FILENAME" | md5sum | cut -d ' ' -f 1`

if [ "$GENERATED_MD5" != "$OBTAINED_MD5" ]
then
    echo "ERROR 3: Hash incorrecto"
    echo "KO_FILENAME_MD5" | nc -q 0 $IP $PORT
    exit 3
fi

echo "6. ENVIO OK_FILENAME"
echo "OK_FILENAME" | nc -q 0 $IP $PORT

DATA=`nc -l $PORT`

echo "9. Recibiendo FILENAME"
mkdir -p server
echo "$DATA" > "server/$FILENAME"

echo "10. HASH DEL CONTENIDO ESPERANDO..."

DATA=`nc -l $PORT`
PREFIX=`echo "$DATA" | cut -d ' ' -f 1`
OBTAINED_FILE_MD5=`echo "$DATA" | cut -d ' ' -f 2`

if [ "$PREFIX" != "FILE_MD5" ]
then
    echo "ERROR 4: PREFIX de HASH"
    echo "KO_FILE_MD5" | -q 0 nc $IP $PORT
    exit 4
fi

GENERATED_FILE_MD5=`md5sum "server/$FILENAME" | cut -d ' ' -f 1`

if [ "$GENERATED_FILE_MD5" != "$OBTAINED_FILE_MD5" ]
then
    echo "ERROR 5: HASH diferente"
    echo "KO_FILE_MD5" | nc -q 0 $IP $PORT
    exit 5
fi

echo "12. ENVIANDO OK_FILE_MD5"
echo "OK_FILE_MD5" | nc -q 0 $IP $PORT
