#!/bin/bash

clear
versao=$(cat /etc/*-release | awk '{print tolower($0)}')

if [[ $versao != *"8 (jessie)"* ]] && [[ $versao != *"9 (stretch)"* ]]; then
	echo ""
	echo "****************************************************************"
	echo "*         Script compativel somente com: Debian 8, 9           *"
	echo "****************************************************************"
	echo ""
	exit
fi

dir=$PWD

echo "  ********** SCRIPT EXCLUSIVO  **********"              > licencas.txt
echo ""                                                            >> licencas.txt
echo "  Meu nome é Dema, sou especialista em UNM2000"              >> licencas.txt
echo "  Precisando comprar licenca do UNM2000?"                    >> licencas.txt
echo "  "                                                          >> licencas.txt
echo "  Informações da licença:"                                   >> licencas.txt
echo "  "                                                          >> licencas.txt
echo "  Validade........: 2099   "                                 >> licencas.txt
echo "  Qtd de ONUs.....: ILIMITADAS"                              >> licencas.txt
echo "  Qtd de OLTs.....: ILIMITADAS"                              >> licencas.txt
echo "  Limites.........: Todos os recursos ILIMITADOS"            >> licencas.txt
echo "  Renovacao Anual.: NAO"                                     >> licencas.txt
echo "  Pagamento.......: Unico, pode parcelar pelo Mercado Livre" >> licencas.txt
echo ""                                                            >> licencas.txt
echo "                      MEUS DADOS"                            >> licencas.txt
echo ""                                                            >> licencas.txt
echo "        WhatsApp.: (11) 9.9509-0722"                         >> licencas.txt
echo "        Email....: vendasunm2000@gmail.com"                  >> licencas.txt


echo "  Instalacao automatizada do UNM2000"                         > requisitos.txt
echo ""                                                            >> requisitos.txt
echo "  HD  : 200GB (Utilizar todo o espaço para raiz /)"          >> requisitos.txt
echo "  RAM : 8GB"                                                 >> requisitos.txt
echo "  CPU : 8 cores"                                             >> requisitos.txt
echo "  "                                                          >> requisitos.txt
echo "  O requisitos estão corretos?"                              >> requisitos.txt
echo "  deseja continuar?"                                         >> requisitos.txt

wget -q --no-check-certificate https://raw.githubusercontent.com/unm2000/scripts/master/gdown.pl -O gdown.pl && chmod u+x gdown.pl

#Informações sobre licenças
whiptail --title "Venda de Licenças UNM2000" --textbox licencas.txt 25 70

#Requisitos
requisitos=$(cat requisitos.txt)

$(whiptail --title "Requisitos Mínimos" --yes-button "Continuar" --no-button "Cancelar" --yesno "$requisitos" 25 70 3>&1 1>&2 2>&3)
if [ $? = 1 ]; then
    echo "Instalação cancelada pelo usuário!"
	exit 0
fi

#Seleciona a Versao
VERSAO_UNM=$(whiptail --title "Versão UNM2000" --menu "Escolha a versão que deseja instalar" 25 70 4 \
"11/2017" "  unm2000-1.0-linux-installer-20171122-202354.run" \
"01/2018" "  unm2000-1.0-linux-installer-20180131-210295.run" \
"04/2018" "  unm2000-1.0-linux-installer-20180409-215334.run" \
"10/2018" "  unm2000-1.0-linux-installer-20181012-244530.run" 3>&1 1>&2 2>&3)

if [ $? = 1 ]; then
    echo "Instalação cancelada pelo usuário!"
	exit 0
fi


#Endereço IP
ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
continua=false
while [ $continua = false ]
do

	ip=$(whiptail --inputbox "Informe sobre qual IP será instalado o UNM2000" 8 78 $ip --title "IP Servidor" 3>&1 1>&2 2>&3)


	if [[ "$ip" =~ (([01]{,1}[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.([01]{,1}[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.([01]{,1}[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.([01]{,1}[0-9]{1,2}|2[0-4][0-9]|25[0-5]))$ ]]; then
	  continua=true
	else
		whiptail --title "IP inválido" --msgbox "O IP informado não é válido" 9 70
	fi

done

if [ $? = 1 ]; then
    echo "Instalação cancelada pelo usuário!"
	exit 0
fi


#Senha MySQL
pass=false

while [ $pass = false ]
do

	while [ "$pass1" = "" ]
	do
		pass1=$(whiptail --passwordbox "Favor criar uma senha para o servidor MySQL" 8 78 --title "Senha MySQL" 3>&1 1>&2 2>&3)

		if [ $? = 1 ]; then
			echo "Instalação cancelada pelo usuário!"
			exit 0
		fi
	done

	while [ "$pass2" = "" ]
	do
		pass2=$(whiptail --passwordbox "Confirmar Senha do MySQL" 8 78 --title "Senha MySQL" 3>&1 1>&2 2>&3)

		if [ $? = 1 ]; then
			echo "Instalação cancelada pelo usuário!"
			exit 0
		fi
	done

	if [ "$pass1" = "$pass2" ]; then
		pass=true
	else
		pass1=""
		pass2=""
		whiptail --title "Senhas diferentes" --msgbox "As senhas digitadas não são iguais!" 8 70
	fi
done

arquivos_ids=("1czsETi8JGFFhn9hyVsBKS09H_IK74ESN" "1gA00odZjv53Xxru0OzeaxaKj4lR3zK56" "13MNJt0K6OY5xuFPzj4oZoTyk46eH5Of7" "1vqWrwTMd1OTmZneCDyiJmpsdwJVRRfQg" "1OCTfHKhWScaW7KzElSsj7zfMwuP-DLLF" "UNM" )
arquivos_nomes=("60-unm2000.cnf" "chkconfig_11.4.54.60.1.deb" "net-tools_1.60-26.deb" "jdk-6u38-linux-i586-SuSE.bin" "install_unm.sh" "unm")
arquivos_tamanhos=("10" "10" "200" "70050" "1" "")
arquivos_status=("" "" "" "" "" "")
arquivos_md5=("baf36337872b3887c3a969f15f4cd838" "ab866939770963ccb70187ac2a372539" "292f59acb12f07350b5983856f637938" "5bae3dc304d32a7e3c50240eab154e24" "2fb9b802771ab236b58a32a30e3d2f75")

  case "$VERSAO_UNM" in
          "11/2017")
				  arquivos_ids[5]="1iLJgV4A3R-UUEwKBr6RxW10zf8Su0YOs"
				  arquivos_nomes[5]="unm2000-1.0-linux-installer-20171122-202354.run"
				  arquivos_tamanhos[5]="1540750"
				  arquivos_md5[5]="a60f515a388391a2ba73d0325d4a390c"
				  arquivo="unm2000-1.0-linux-installer-20171122-202354.run"
				  ;;
          "01/2018")
				  arquivos_ids[5]="1cXRNEb2HhJBoB-WVgerG_H8kspSdnFVy"
				  arquivos_nomes[5]="unm2000-1.0-linux-installer-20180131-210295.run"
				  arquivos_tamanhos[5]="1722850"
				  arquivos_md5[5]="9d57d582327a127505770c71905e27a9"
				  arquivo="unm2000-1.0-linux-installer-20180131-210295.run"
                  ;;
          "04/2018")
				  arquivos_ids[5]="16ARyBbh2U8OAwJl8bUw2mFH0Jzvo-Fmy"
				  arquivos_nomes[5]="unm2000-1.0-linux-installer-20180409-215334.run"
				  arquivos_tamanhos[5]="1733200"
				  arquivos_md5[5]="e641ab5482896ff03e4eb58275e4bb69"
				  arquivo="unm2000-1.0-linux-installer-20180409-215334.run"
                  ;;
          "10/2018")
				  arquivos_ids[5]="1AV-whqyriv8sNpRqVw7TB4_j3O5QNtgn"
				  arquivos_nomes[5]="unm2000-1.0-linux-installer-20181012-244530.run"
				  arquivos_tamanhos[5]="1823350"
				  arquivos_md5[5]="cd01d8d591d0ead09ee566beaadb2ce8"
				  arquivo="unm2000-1.0-linux-installer-20181012-244530.run"
                  ;;
          *)
				whiptail --fb --title "Erro de seleção" --msgbox "Ocorreu um erro ao selecionar a versão do UNM2000" 10 80
				exit 0
  esac


	function MontaStatus {
		StatusDownload=""
		for i in "${!arquivos_ids[@]}"; do
			arquivo_nome="${arquivos_nomes[$i]}"
			arquivo_status="${arquivos_status[$i]}"
			StatusDownload+=$(echo -e "\n$arquivo_nome $(printf '\x20%.0s' {1..80})" | head -c 80 ; echo -n " $arquivo_status")
		done
	}



	for i in "${!arquivos_ids[@]}"; do

		arquivos_status[$i]="Baixando"
		index="$i"
		id="${arquivos_ids[$index]}"
		name="${arquivos_nomes[$index]}"
		size="${arquivos_tamanhos[$index]}"
		status="${arquivos_status[$index]}"

		MontaStatus

		{
			perl ./gdown.pl "https://docs.google.com/uc?export=download&id=$id" "$name" "-q --show-progress --progress=dot" 2>&1 | grep K | sed -u -e "s,\.,,g" | awk '{print $1}' | sed -u -e "s,\K, $size,g" | awk '{print $1*100/$2}' | awk '{$0=int($0)}1'
			echo "100"
		} | whiptail --title "Download de Arquivos" --gauge "\nBaixando arquivos necessários para instalação\nIsso pode demorar um pouco, dependendo da velocidade de sua internet\n\n$StatusDownload\n\n" 20 100 0

		arquivos_status[$index]="OK"
	done

	rm gdown* > /dev/null 2>&1
	rm cookie* > /dev/null 2>&1
	rm licencas.txt > /dev/null 2>&1
	rm requisitos.txt > /dev/null 2>&1

	#verifica MD5
	for i in "${!arquivos_nomes[@]}"; do
		arquivos_status[$i]="Calculando..."
		arquivo="${arquivos_nomes[$i]}"
		md5_esperado="${arquivos_md5[$i]}"
		md5=$(md5sum $arquivo | awk '{print $1}')

		if [ "$md5" != "$md5_esperado" ]; then
			whiptail --fb --title "Falha de checksum" --msgbox "Ocorreu um erro ao verificar o checksum do arquivo abaixo,\na instalação não poderá continuar.\n\n      Arquivo: $arquivo \n MD5 Esperado: $md5_esperado \n   MD5 Obtido: $md5" 15 80
			exit
		fi
	done



	progresso=("Dependencias" "MariaDB 10" "Variaveis Sistema" "Java JDK" "UNM2000 Server" "Criar Banco de Dados" "Configurar Locales")
	progresso_status=("" "" "" "" "" "" "")

	function MontaProgresso {
		StatusProgresso=""
		for i in "${!progresso[@]}"; do
			nome_progresso="${progresso[$i]}"
			status_progresso="${progresso_status[$i]}"
			StatusProgresso+=$(echo -e "\n$nome_progresso $(printf '\x20%.0s' {1..80})" | head -c 80 ; echo -n " $status_progresso")
			info_install="\nInstalando o UNM2000 ($VERSAO_UNM)\nSeja paciente esse processo poderá demorar um pouco\n\n$StatusProgresso\n\n"
		done
	}

	#Instalando dependencias
	progresso_status[0]="Instalando..."
	MontaProgresso
	{
		apt-get update >> /var/log/instalacao_unm2000.log 2>&1
		dpkg -i chkconfig_11.4.54.60.1.deb >> /var/log/instalacao_unm2000.log 2>&1
		dpkg -i net-tools_1.60-26.deb >> /var/log/instalacao_unm2000.log 2>&1
		apt-get install lib32z1 lib32ncurses5 sysv-rc-conf nginx expect ncurses* -y --no-install-recommends -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 >> /var/log/instalacao_unm2000.log 2>&1
	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[0]="OK"


	#Instalando o MySQL Server
	progresso_status[1]="Instalando..."
	MontaProgresso
	{
		echo "30"
		#apt-get install mysql-server  -y --no-install-recommends -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 >> /var/log/instalacao_unm2000.log 2>&1		
		cp 60-unm2000.cnf /etc/mysql/mariadb.conf.d/
		service mysql restart >> /var/log/instalacao_unm2000.log 2>&1
		sleep 3
		mysqladmin -u root password "$pass1"		
	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[1]="OK"


	#Configurando Variaveis
	progresso_status[2]="Configurando..."
	MontaProgresso
	{
		echo "40"
		echo '' >> /etc/profile
		echo '' >> /etc/profile
		echo 'export UNM_ROOT=/opt/unm2000' >> /etc/profile
		echo '#export PYTHONHOME=/opt/unm2000/platform/thirdparty/suse11_gcc_x64/python27' >> /etc/profile
		echo 'export PATH=$PATH:$UNM_ROOT/server/bin:$PYTHONHOME/bin' >> /etc/profile
		echo 'export UNM_OS_ENV=suse11_gcc_x64' >> /etc/profile
		echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$UNM_ROOT/platform/thirdparty/$UNM_OS_ENV/bin:$UNM_ROOT/platform/bin:$UNM_ROOT/server/bin' >> /etc/profile
		echo '#export LC_ALL=C' >> /etc/profile
		echo '' >> /etc/profile
		echo 'export JAVA_HOME=/usr/local/bin/jdk1.6.0_38' >> /etc/profile
		echo 'export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar' >> /etc/profile
		echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile
		echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[2]="OK"

	#Instalando Java
	progresso_status[3]="Instalando..."
	MontaProgresso
	{
		echo "45"
		chmod +x jdk-6u38-linux-i586-SuSE.bin
		cp jdk-6u38-linux-i586-SuSE.bin /usr/local/bin
		cd /usr/local/bin
		rm -rf jdk1.6.0_38
		./jdk-6u38-linux-i586-SuSE.bin >> /var/log/instalacao_unm2000.log < <(echo y) >> /var/log/instalacao_unm2000.log < <(echo y)
	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[3]="OK"


	#Instalando UNM2000
	progresso_status[4]="Instalando..."
	MontaProgresso
	{
		echo "60"
		cd $dir
		chmod +x install_unm.sh
		chmod +x $arquivo 
		./install_unm.sh $arquivo $ip $pass1 >> /var/log/instalacao_unm2000.log 2>&1

		sed -i -e 's/root   html/root   \/opt\/unm2000\/tools\/nginx\/html/g' /opt/unm2000/tools/nginx/conf/nginx.conf
		mv /etc/nginx/fastcgi.conf /etc/nginx/fastcgi.conf.bk
		mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bk
		mv /etc/nginx/fastcgi_params /etc/nginx/fastcgi_params.bk
		mv /etc/nginx/win-utf /etc/nginx/win-utf.bk
		mv /etc/nginx/koi-win /etc/nginx/koi-win.bk

		ln -s /opt/unm2000/tools/nginx/conf/fastcgi.conf /etc/nginx/fastcgi.conf
		ln -s /opt/unm2000/tools/nginx/html /etc/nginx/html
		ln -s /opt/unm2000/tools/nginx/conf/nginx.conf /etc/nginx/nginx.conf
		ln -s /opt/unm2000/tools/nginx/conf/fastcgi_params /etc/nginx/fastcgi_params
		ln -s /opt/unm2000/tools/nginx/conf/win-utf /etc/nginx/win-utf
		ln -s /opt/unm2000/tools/nginx/conf/koi-win /etc/nginx/koi-win
	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[4]="OK"


	#Criando Base de Dados
	source /etc/profile
	progresso_status[5]="Criando..."
	MontaProgresso
	{
		echo "90"
		. /opt/unm2000/server/tool/installdb.sh --type:mysql --rootpassword:$pass1 --port:3306 --language:1 --inittype:a >> /var/log/instalacao_unm2000.log 2>&1

		apt-get install locales-all --no-install-recommends -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 >> /var/log/instalacao_unm2000.log 2>&1
		locale-gen en_US.UTF-8

		echo "LANG=en_US" > /etc/default/locale
		echo "LANGUAGE=en_US" >> /etc/default/locale
		echo "en_US ISO-8859-1" > /etc/locale.gen
	
		
		locale-gen >> /var/log/instalacao_unm2000.log 2>&1
	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[5]="OK"
	
	
	#Configurando Locales
	progresso_status[6]="Configurando..."
	MontaProgresso
	{
		echo "95"
		apt-get install locales-all --no-install-recommends -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 >> /var/log/instalacao_unm2000.log 2>&1
		locale-gen en_US.UTF-8 >> /var/log/instalacao_unm2000.log
		echo "LANG=en_US" > /etc/default/locale
		echo "LANGUAGE=en_US" >> /etc/default/locale
		echo "en_US ISO-8859-1" > /etc/locale.gen
	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[6]="OK"	
	

	#NADA Apenas Mostrar o ultimo resultado
	MontaProgresso
	{
		echo "100"
		sleep 5
	} | whiptail --title "Instalando o UNM2000" --gauge "\nInstalando o UNM2000 $VERSAO_UNM\nSeja paciente esse processo poderá demorar um pouco\nAtenção a barra de progresso não funciona\n\n\n$StatusProgresso\n\n" 20 100 0


	if (whiptail --title "Instalação Concluída" --yes-button "Sair" --no-button "Visualizar Logs" --yesno "Instalacao concluida!!!\nReinicie o servidor" 10 70); then
		clear
	else
		cat /var/log/instalacao_unm2000.log | less
	fi