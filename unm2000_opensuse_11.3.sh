#!/bin/bash

clear
versao=$(cat /etc/*-release | awk '{print tolower($0)}')

if [[ $versao != *"opensuse 11.3"* ]]; then
	echo -e "Sistema Operacional incompativel!\nCompativel somenete com: OpenSuse 11.3"
	exit
fi

echo "Baixando arquivos de instalação..."
wget -q --no-check-certificate https://raw.githubusercontent.com/unm2000/scripts/master/gdown.pl -O gdown.pl && chmod u+x gdown.pl

perl ./gdown.pl 'https://docs.google.com/uc?export=download&id=1kRPrAExcEZVYTK31PUsRIXxm_a12oqfv' unm2000_20171122_OpenSuse11.3.run

chmod +x unm2000_20171122_OpenSuse11.3.run 
. /unm2000_20171122_OpenSuse11.3.run
