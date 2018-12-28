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

echo "Criando diretorios..."
mkdir -p /opt/unm2000
mkdir -p /opt/ApacheTomcat
mkdir -p /opt/ApacheTomcat/work
mkdir -p /opt/ApacheTomcat/webapps
mkdir -p /opt/ApacheTomcat/temp
mkdir -p /opt/ApacheTomcat/logs
mkdir -p /opt/ApacheTomcat/lib
mkdir -p /opt/ApacheTomcat/conf
mkdir -p /opt/ApacheTomcat/bin
mkdir -p /opt/ApacheTomcat/conf/Catalina
mkdir -p /opt/ApacheTomcat/conf/Catalina/localhost
mkdir -p /opt/ApacheTomcat/temp/hsperfdata_liugq
mkdir -p /opt/ApacheTomcat/webapps/manager
mkdir -p /opt/ApacheTomcat/webapps/host-manager
mkdir -p /opt/ApacheTomcat/webapps/examples
mkdir -p /opt/ApacheTomcat/webapps/docs
mkdir -p /opt/ApacheTomcat/webapps/ROOT
mkdir -p /opt/ApacheTomcat/webapps/ROOT/WEB-INF
mkdir -p /opt/ApacheTomcat/webapps/docs/tribes
mkdir -p /opt/ApacheTomcat/webapps/docs/images
mkdir -p /opt/ApacheTomcat/webapps/docs/funcspecs
mkdir -p /opt/ApacheTomcat/webapps/docs/config
mkdir -p /opt/ApacheTomcat/webapps/docs/architecture
mkdir -p /opt/ApacheTomcat/webapps/docs/appdev
mkdir -p /opt/ApacheTomcat/webapps/docs/api
mkdir -p /opt/ApacheTomcat/webapps/docs/WEB-INF
mkdir -p /opt/ApacheTomcat/webapps/docs/appdev/sample
mkdir -p /opt/ApacheTomcat/webapps/docs/appdev/sample/web
mkdir -p /opt/ApacheTomcat/webapps/docs/appdev/sample/src
mkdir -p /opt/ApacheTomcat/webapps/docs/appdev/sample/docs
mkdir -p /opt/ApacheTomcat/webapps/docs/appdev/sample/src/mypackage
mkdir -p /opt/ApacheTomcat/webapps/docs/appdev/sample/web/images
mkdir -p /opt/ApacheTomcat/webapps/docs/appdev/sample/web/WEB-INF
mkdir -p /opt/ApacheTomcat/webapps/docs/architecture/startup
mkdir -p /opt/ApacheTomcat/webapps/docs/architecture/requestProcess
mkdir -p /opt/ApacheTomcat/webapps/examples/servlets
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/tags
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/lib
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/jsp2
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/jsp
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/validators
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/util
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/sessions
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/num
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/listeners
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/jsp2
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/filters
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/examples
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/error
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/dates
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/compressionFilters
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/colors
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/checkbox
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/chat
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/cal
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/jsp2/examples
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/jsp2/examples/simpletag
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/classes/jsp2/examples/el
mkdir -p /opt/ApacheTomcat/webapps/examples/WEB-INF/jsp/applet
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/xml
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/tagplugin
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/snp
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/simpletag
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/sessions
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/security
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/plugin
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/num
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/jsptoserv
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/jsp2
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/include
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/images
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/forward
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/error
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/dates
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/colors
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/checkbox
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/chat
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/cal
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/jsp2/tagfiles
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/jsp2/simpletag
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/jsp2/misc
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/jsp2/jspx
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/jsp2/jspattribute
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/jsp2/el
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/plugin/applet
mkdir -p /opt/ApacheTomcat/webapps/examples/jsp/security/protected
mkdir -p /opt/ApacheTomcat/webapps/examples/servlets/images
mkdir -p /opt/ApacheTomcat/webapps/host-manager/images
mkdir -p /opt/ApacheTomcat/webapps/host-manager/WEB-INF
mkdir -p /opt/ApacheTomcat/webapps/host-manager/META-INF
mkdir -p /opt/ApacheTomcat/webapps/manager/images
mkdir -p /opt/ApacheTomcat/webapps/manager/WEB-INF
mkdir -p /opt/ApacheTomcat/webapps/manager/META-INF
mkdir -p /opt/ApacheTomcat/webapps/manager/WEB-INF/jsp
mkdir -p /opt/ApacheTomcat/work/Catalina
mkdir -p /opt/ApacheTomcat/work/Catalina/localhost
mkdir -p /opt/ApacheTomcat/work/Catalina/localhost/unm2000
mkdir -p /opt/ApacheTomcat/work/Catalina/localhost/manager
mkdir -p /opt/ApacheTomcat/work/Catalina/localhost/host-manager
mkdir -p /opt/ApacheTomcat/work/Catalina/localhost/examples
mkdir -p /opt/ApacheTomcat/work/Catalina/localhost/docs
mkdir -p /opt/ApacheTomcat/work/Catalina/localhost/_

cd /unm2000
echo "Instalando o UNM2000, isso pode demorar um pouco, seja paciente!"
./unm2000-1.0-linux-installer-20171122-202354.run --mode unattended --lang 1 --ipaddress $IP --dbserverip 127.0.0.1 --dbserverpwd $SENHA >> instalacao.log 2>&1
sleep 5

echo "Criando base de dados..."
. /opt/unm2000/server/tool/installdb.sh --type:mysql --rootpassword:$SENHA --port:3306 --language:1 --inittype:a >> instalacao.log 2>&1
echo -e "\nInstalação concluida, rebotando servidor!"
reboot -f


