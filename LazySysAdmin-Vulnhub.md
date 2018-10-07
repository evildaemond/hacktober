# LazySysAdmin Vulnhub Writeup

Link:           [LazySysAdmin by Togie Mcdogie](https://www.vulnhub.com/entry/lazysysadmin-1,205/)

* Details:        Boot2Root Virtual Machine
* Author Rating:  Beginner - Intermediate
* Flag Count:     1
* Flag Location:  /root/flag.txt
* Flag Contents:  flag{c89031ac1b40954bb9a0589adcb6d174}

## Runsheet

Located the Virtual Machine's IP;

```bash
arp-scan 192.168.146.0/24
```

Nmap Host to identify open ports on the machine and attempt to identify the host operating system;

```bash
nmap -sV -O 192.168.146.129
```

```text
22/tcp   open  ssh
80/tcp   open  http
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
3306/tcp open  mysql
6667/tcp open  irc
```

From this, we know we have some things to check out, the web was a bust, but we checked the smb ports `139` and `445` using enum4linux, using this command;

```bash
enum4linux 192.168.146.129
```

What was of interest to us is the following chunks of info;

```text
 ========================================
|    Session Check on 192.168.146.129    |
 ========================================
[+] Server 192.168.146.129 allows sessions using username '', password ''
```

```text
 ============================================
|    Share Enumeration on 192.168.146.129    |
 ============================================

    Sharename       Type      Comment
    ---------       ----      -------
    print$          Disk      Printer Drivers
    share$          Disk      Sumshare
    IPC$            IPC       IPC Service (Web server)
```

```text
[+] Attempting to map shares on 192.168.146.129
//192.168.146.129/print$    Mapping: DENIED, Listing: N/A
//192.168.146.129/share$    Mapping: OK, Listing: OK
//192.168.146.129/IPC$  [E] Can't understand response:
```

These give us some cool pieces of infomation, 1; we can access the SMB share with a null username and password, we have a share called `share` and we can map and list it without authentication. Now lets try connecting to it and see what we can do.

```bash
smbclient \\\\192.168.146.129\\share$ -N -U
```

Doing this gives us access to the directory, and we found a file called `deets.txt`, which tells us there is a password that is `12345` for an account. Going back to the old enum4linux, if we check the output log, we have a enumiration for the users in that machine, which shows us the following;

```text
[+] Enumerating users using SID S-1-22-1 and logon username '', password ''
S-1-22-1-1000 Unix User\togie (Local User)
```

Since we have this user as a Unix User, we can assume it is the local user account, so if we attempt to SSH into the user account on Port 22 using the credentials `togie/12345`, we are greeted with shell.

Now if we check our permissions using `sudo -l`, and it turns out our user has sudo privlages straight away, no requirement to get root. So using `sudo cat /root/proof.txt` we get our flag and complete the CTF.

```text
WX6k7NJtA8gfk*w5J3&T@*Ga6!0o5UP89hMVEQ#PT9851


Well done :)

Hope you learn't a few things along the way.

Regards,

Togie Mcdogie




Enjoy some random strings

WX6k7NJtA8gfk*w5J3&T@*Ga6!0o5UP89hMVEQ#PT9851
2d2v#X6x9%D6!DDf4xC1ds6YdOEjug3otDmc1$#slTET7
pf%&1nRpaj^68ZeV2St9GkdoDkj48Fl$MI97Zt2nebt02
bhO!5Je65B6Z0bhZhQ3W64wL65wonnQ$@yw%Zhy0U19pu
```