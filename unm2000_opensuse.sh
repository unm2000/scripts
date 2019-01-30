#!/bin/bash

clear
versao=$(cat /etc/*-release | awk '{print tolower($0)}')

if [[ $versao != *"opensuse 11.3"* ]] && [[ $versao != *"opensuse leap 15.0"* ]]; then
	echo -e "Sistema Operacional incompativel!\nCompativel somenete com: [OpenSuse 11.3, OpenSuse Leap 15.0]"
	exit
fi

dir=$PWD

echo " Aguarde, iniciando script..."
zypper install -y newt > /var/log/instalacao_unm2000.log 2>&1
clear


echo "  Meu nome é Dema, sou especialista em UNM2000"               > licencas.txt
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
ip=$(ip route get 8.8.8.8 | awk '{print $7}' | awk 'NR==1{print $1}')
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


if [[ $versao == *"opensuse 11.3"* ]]; then
	arquivos_ids=("1OCTfHKhWScaW7KzElSsj7zfMwuP-DLLF" "1NlTzBgJ5ghQQMsv-u_tRFWn38Gch3L61" "1iZV_FW7HSb2m8Rn8fCMkVssIMpJuQB_9" "1FnQ2OYekcI6mXJKhq80Yr4tnbrPJt3rq" "1dFl762FmlOF5idf9gt_hYNUC6WnkhmRd" "1vqWrwTMd1OTmZneCDyiJmpsdwJVRRfQg" "unm" )
	arquivos_nomes=("install_unm.sh" "my.cnf" "MySQL-server-5.5.38-1.sles11.x86_64.rpm" "MySQL-client-5.5.38-1.sles11.x86_64.rpm" "MySQL-shared-5.5.38-1.sles11.x86_64.rpm" "jdk-6u38-linux-i586-SuSE.bin" "unm")
	arquivos_tamanhos=("10" "10" "34750" "13500" "1500" "70050" "1")
	arquivos_status=("" "" "" "" "" "" "")
	arquivos_md5=("2fb9b802771ab236b58a32a30e3d2f75" "f487e4ef1e813d05fae51f895b05c82f" "aacb08488c17f1469f0180dfbffb8b65" "4b95ce9cd2e2b20fe930eb0d41d4b2a6" "db6b38fcedc0fe5c7ca1827d82c265b6" "5bae3dc304d32a7e3c50240eab154e24" "unm")                                                                          
fi

if [[ $versao == *"opensuse leap 15.0"* ]]; then
	arquivos_ids=("1OHu8oMoEG1HWt8DEMpTw_wbwsHaWIyqy" "1OCTfHKhWScaW7KzElSsj7zfMwuP-DLLF" "1czsETi8JGFFhn9hyVsBKS09H_IK74ESN" "1vqWrwTMd1OTmZneCDyiJmpsdwJVRRfQg" "unm" )
	arquivos_nomes=("net-tools-1.60-741.1.x86_64.rpm" "install_unm.sh" "60-unm2000.cnf" "jdk-6u38-linux-i586-SuSE.bin" "unm")
	arquivos_tamanhos=("230" "1" "10" "10" "70050")
	arquivos_status=("" "" "" "" "")
	arquivos_md5=("0f784477f8ce1bd9cf2fdeddde040dad" "2fb9b802771ab236b58a32a30e3d2f75" "46ead27d0da7bf0e5ff43a321586b831" "5bae3dc304d32a7e3c50240eab154e24" "unm")                                                                          
fi


  case "$VERSAO_UNM" in
          "11/2017")
				  _arquivos_ids="1iLJgV4A3R-UUEwKBr6RxW10zf8Su0YOs"
				  _arquivos_nomes="unm2000-1.0-linux-installer-20171122-202354.run"
				  _arquivos_tamanhos="1540750"
				  _arquivos_md5="a60f515a388391a2ba73d0325d4a390c"
				  arquivo="unm2000-1.0-linux-installer-20171122-202354.run"
				  ;;
          "01/2018")
				  _arquivos_ids="1cXRNEb2HhJBoB-WVgerG_H8kspSdnFVy"
				  _arquivos_nomes="unm2000-1.0-linux-installer-20180131-210295.run"
				  _arquivos_tamanhos="1722850"
				  _arquivos_md5="9d57d582327a127505770c71905e27a9"
				  arquivo="unm2000-1.0-linux-installer-20180131-210295.run"
                  ;;
          "04/2018")
				  _arquivos_ids="16ARyBbh2U8OAwJl8bUw2mFH0Jzvo-Fmy"
				  _arquivos_nomes="unm2000-1.0-linux-installer-20180409-215334.run"
				  _arquivos_tamanhos="1733200"
				  _arquivos_md5="e641ab5482896ff03e4eb58275e4bb69"
				  arquivo="unm2000-1.0-linux-installer-20180409-215334.run"
                  ;;
          "10/2018")
				  _arquivos_ids="1AV-whqyriv8sNpRqVw7TB4_j3O5QNtgn"
				  _arquivos_nomes="unm2000-1.0-linux-installer-20181012-244530.run"
				  _arquivos_tamanhos="1823350"
				  _arquivos_md5="cd01d8d591d0ead09ee566beaadb2ce8"
				  arquivo="unm2000-1.0-linux-installer-20181012-244530.run"
                  ;;
          *)
				whiptail --fb --title "Erro de seleção" --msgbox "Ocorreu um erro ao selecionar a versão do UNM2000" 10 80
				exit 0
  esac
  
  
	if [[ $versao == *"opensuse 11.3"* ]]; then
		arquivos_ids[6]="$_arquivos_ids"
		arquivos_nomes[6]="$_arquivos_nomes"
		arquivos_tamanhos[6]="$_arquivos_tamanhos"
		arquivos_md5[6]="$_arquivos_md5"
	fi

	if [[ $versao == *"opensuse leap 15.0"* ]]; then
		arquivos_ids[4]="$_arquivos_ids"
		arquivos_nomes[4]="$_arquivos_nomes"
		arquivos_tamanhos[4]="$_arquivos_tamanhos"
		arquivos_md5[4]="$_arquivos_md5"
	fi  
  
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
			if [[ $versao == *"opensuse leap 15.0"* ]]; then
				st="--show-progress"
			fi
		
			perl ./gdown.pl "https://docs.google.com/uc?export=download&id=$id" "$name" "-q $st --progress=dot" 2>&1 | grep K | sed -u -e "s,\.,,g" | awk '{print $1}' | sed -u -e "s,\K, $size,g" | awk '{print $1*100/$2}' | awk '{$0=int($0)}1'
			echo "100"
		} | whiptail --title "Download de Arquivos" --gauge "\nBaixando arquivos necessários para instalação\nIsso pode demorar um pouco, dependendo da velocidade de sua internet\n\n$StatusDownload\n\n" 20 100 0

		arquivos_status[$index]="OK"
	done

	rm gdown* > /dev/null 2>&1
	rm cookie* > /dev/null 2>&1
	rm licencas.txt > /dev/null 2>&1
	rm requisitos.txt > /dev/null 2>&1
	
	echo " Verificando Checksum dos arquivos..."
	clear
	

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
	
	
	progresso=("Instalar Dependencias" "Instalar MySQL Server / MariaDB" "Configurar Variaveis Sistema" "Instalar Java JDK" "Instalar UNM2000 Server" "Criar Banco de Dados")
	progresso_status=("" "" "" "" "" "")


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
	
		if [[ $versao == *"opensuse 11.3"* ]]; then
			zypper install -y expect >> /var/log/instalacao_unm2000.log 2>&1
		fi

		if [[ $versao == *"opensuse leap 15.0"* ]]; then
			zypper remove -y hostname traceroute >> /var/log/instalacao_unm2000.log 2>&1
			rpm -ivh net-tools-1.60-741.1.x86_64.rpm >> /var/log/instalacao_unm2000.log 2>&1
			zypper install -y ncurses* insserv-compat >> /var/log/instalacao_unm2000.log 2>&1
		fi	
	

	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[0]="OK"


	#Instalando o MySQL Server
	progresso_status[1]="Instalando..."
	MontaProgresso
	{
		echo "30"
		
		if [[ $versao == *"opensuse 11.3"* ]]; then
			rpm -ivh MySQL-server-5.5.38-1.sles11.x86_64.rpm >> /var/log/instalacao_unm2000.log 2>&1
			rpm -ivh MySQL-client-5.5.38-1.sles11.x86_64.rpm >> /var/log/instalacao_unm2000.log 2>&1
			rpm -ivh MySQL-shared-5.5.38-1.sles11.x86_64.rpm >> /var/log/instalacao_unm2000.log 2>&1
			cp my.cnf /etc >> /var/log/instalacao_unm2000.log 2>&1
			service mysql start >> /var/log/instalacao_unm2000.log 2>&1
			sleep 5
			service mysql status >> /var/log/instalacao_unm2000.log 2>&1		
			
		fi

		if [[ $versao == *"opensuse leap 15.0"* ]]; then
			zypper install -y mariadb >> /var/log/instalacao_unm2000.log 2>&1
			cp 60-unm2000.cnf /etc/my.cnf.d >> /var/log/instalacao_unm2000.log 2>&1
			systemctl start mariadb.service >> /var/log/instalacao_unm2000.log 2>&1
			sleep 5
			systemctl status mariadb.service >> /var/log/instalacao_unm2000.log 2>&1
			ln -s /tmp/mysql.sock /var/run/mysql/mysql.sock
		fi		

		#sleep 5		
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
	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[4]="OK"


	#Criando Base de Dados
	source /etc/profile
	progresso_status[5]="Criando..."
	MontaProgresso
	{
		echo "90"
		. /opt/unm2000/server/tool/installdb.sh --type:mysql --rootpassword:$pass1 --port:3306 --language:1 --inittype:a >> /var/log/instalacao_unm2000.log 2>&1
	} | whiptail --title "Instalando o UNM2000" --gauge "$info_install" 20 100 0
	progresso_status[5]="OK"	
	

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