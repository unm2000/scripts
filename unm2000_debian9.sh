#!/bin/bash

clear
versao=$(cat /etc/*-release | awk '{print tolower($0)}')

if [[ $versao != *"9 (stretch)"* ]]; then
	echo -e "Sistema Operacional incompativel!\nCompativel somenete com: Debian 9 (stretch)"
	exit
fi

echo "Baixando arquivos de instalação..."
wget -q --no-check-certificate https://raw.githubusercontent.com/unm2000/scripts/master/gdown.pl -O gdown.pl && chmod u+x gdown.pl

perl ./gdown.pl 'https://docs.google.com/uc?export=download&id=1y_lPsha890ZCwOW83MdKv7p6jMmQ010n' unm2000_20171122.run

rm gdown*

chmod +x unm2000_20171122.run 
./unm2000_20171122.run
