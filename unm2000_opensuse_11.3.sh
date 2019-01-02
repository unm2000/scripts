#!/bin/bash

clear
versao=$(cat /etc/*-release | awk '{print tolower($0)}')

if [[ $versao != *"opensuse 11.3"* ]]; then
	echo -e "Sistema Operacional incompativel!\nCompativel somenete com: OpenSuse 11.3"
	exit
fi

read -p "IP do Servidor: " IP
read -p "MySQL Criar uma senha: " SENHA


mkdir /unm2000
cd /unm2000
touch instalacao.log


echo "Baixando arquivos de instalação..."
wget -q --no-check-certificate https://raw.githubusercontent.com/unm2000/scripts/master/gdown.pl -O gdown.pl && chmod u+x gdown.pl

perl /unm2000/gdown.pl 'https://docs.google.com/uc?export=download&id=1DppbqMVQvLNknFBjvcEDiOmP5NfDPoA4' unm2000-1.0-linux-installer-20171122-202354.run
perl /unm2000/gdown.pl 'https://docs.google.com/uc?export=download&id=1MjeCOF60vxs_d6b38TD_ZknGunGvL4Jo' MySQL-server-5.5.38-1.sles11.x86_64.rpm
perl /unm2000/gdown.pl 'https://docs.google.com/uc?export=download&id=1hxADOISlrQ-m0YUx7S0rpW175J_2H3bU' MySQL-client-5.5.38-1.sles11.x86_64.rpm
perl /unm2000/gdown.pl 'https://docs.google.com/uc?export=download&id=17-S5rqGrX60hk6xd8anJmBawwfrdWOkY' MySQL-shared-5.5.38-1.sles11.x86_64.rpm
perl /unm2000/gdown.pl 'https://docs.google.com/uc?export=download&id=1f6U_x-zc2pionfnQ7Fw4xT2fMvqO1Ock' jdk-6u38-linux-i586-SuSE.bin
perl /unm2000/gdown.pl 'https://docs.google.com/uc?export=download&id=1881McOb42NMnS1hCCQ_UtDxYTjTJECWy' my.cnf

chmod +x jdk-6u38-linux-i586-SuSE.bin  
chmod +x unm2000-1.0-linux-installer-20171122-202354.run 

cp my.cnf /etc
mv jdk-6u38-linux-i586-SuSE.bin /usr/local/bin

rm -rf /unm2000/gdown*

clear
echo -e "\nConfigurando variaveis do sistema ..."

echo '' >> /etc/profile  
echo '' >> /etc/profile 
echo 'export UNM_ROOT=/opt/unm2000' >> /etc/profile 
echo 'export PYTHONHOME=/opt/unm2000/platform/thirdparty/suse11_gcc_x64/python27' >> /etc/profile 
echo 'export PATH=$PATH:$UNM_ROOT/server/bin:$PYTHONHOME/bin' >> /etc/profile 
echo 'export UNM_OS_ENV=suse11_gcc_x64' >> /etc/profile 
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$UNM_ROOT/platform/thirdparty/$UNM_OS_ENV/bin:$UNM_ROOT/platform/bin:$UNM_ROOT/server/bin' >> /etc/profile 
echo 'export LC_ALL=C' >> /etc/profile 
echo '' >> /etc/profile  
echo 'export JAVA_HOME=/usr/local/bin/jdk1.6.0_38' >> /etc/profile 
echo 'export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar' >> /etc/profile 
echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile 
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile 

source /etc/profile

echo "Instalando MySQL ..."
rpm -ivh MySQL-server-5.5.38-1.sles11.x86_64.rpm >> instalacao.log 2>&1 
rpm -ivh MySQL-client-5.5.38-1.sles11.x86_64.rpm >> instalacao.log 2>&1 
rpm -ivh MySQL-shared-5.5.38-1.sles11.x86_64.rpm >> instalacao.log 2>&1 

service mysql start
mysqladmin -u root password "$SENHA"

echo -e "Instalando JAVA ..."
cd /usr/local/bin
rm -rf jdk1.6.0_38
./jdk-6u38-linux-i586-SuSE.bin >> /unm2000/instalacao.log < <(echo y) >> /unm2000/instalacao.log < <(echo y)


cd /unm2000
echo "Instalando o UNM2000, isso pode demorar um pouco, seja paciente!"
./unm2000-1.0-linux-installer-20171122-202354.run --mode text --unattendedmodeui minimal --lang 1 --ipaddress $IP --dbserverip 127.0.0.1 --dbserverpwd $SENHA
sleep 5

echo "Criando base de dados..."
. /opt/unm2000/server/tool/installdb.sh --type:mysql --rootpassword:$SENHA --port:3306 --language:1 --inittype:a >> instalacao.log 2>&1
echo -e "\nInstalação concluida, rebotando servidor!"
reboot -f


