# Sending Emails from Dockerized Shiny Apps

Author: Sebastian Kranz (sebastian.kranz@uni-ulm.de)

Running shiny apps in docker containers seems for many really useful for me. Many of my apps used for teaching have a simple login mechanism that needs to send verification emails to students that want to sign up. It took my quite some web search and trial-and-error to manage a set-up that allows shiny apps running inside a docker container to successfully send emails. 

My set-up uses the email progamm, more precisely a message transfer agent (MTA), exim4 hosted on the server. Most helpful was the following blog: 

https://gehrcke.de/2014/07/discourse-docker-container-send-mail-through-exim/

From which I copied the crucial steps.

Here I write things out in some more detail and focussed on containers running R based shiny applications.

## 1. Installing exim4 on the server

To install exim4 on the server I ran the following lines in the shell:

```
sudo apt install exim4
sudo dpkg-reconfigure exim4-config
```
The second command starts an interactive screen that guides you through several specifications. 

I basically always used the default options (first choices). For the system mail name, a fully qualified domain name (FQDM), I used the name of my webserver under which it can be reached in the web (not including www.).

### Uninstalling other MTA
If you have already installed another email programm (MTA) on your server, you have to uninstall it beforehand. I had some problems to successfully uninstall sendmail.

The following commands should normally remove sendmail
```
sudo apt-get remove sendmail
sudo apt-get purge sendmail*
```
Yet there may still be a sendmail process be running (and exim4 may not work then). Call
```
system("ps auxwww | grep sendmail")
```
To see whether there is some process (in addition to this call to grep). You can the kill the process using `sudo kill PID` where `PID` is the process id listed above, e.g. 
```
sudo kill 18688
```

## 2. Try to send an email in R from the host

If you have R (and maybe also RStudio server) installed on your host, you may first try to send an email from the host directly before trying to send one from a docker container. I used the package `mailR` for this purpose. Here is an example code:

```r
library(mailR)
mailR::send.mail(smtp=list(host.name="localhost"), from="sender@myhost.com", subject="Test email",body="Hello!",to="receiver@example.com")
```
This should send an email to `receiver@example.com` with a sender `sender@myhost.com`. You should replace `myhost.com` with the server name you have chosen when configuring exim4.

## 3. Configuring exim4 to relay emails from containers

Outgoing emails will be sent via port 25 (using other ports may lead to frequent rejecting by receivers' email servers.). But port 25 can be directly used only by the host, or if the host does not use it, be exposed just by a single container. Thus if you have several containers that want to send emails or other applications on the host that need to send emails, you somehow must be able to use the host's (or a dedicated container's) mail program. Here we explain, how an R program inside a container can send an email using a configured exim4 server on the host. This can be done since docker allows to access the host or other containers via special IP addresses. 

For some background info, I found these userguides very helpful:

https://docs.docker.com/engine/userguide/networking/
https://docs.docker.com/engine/userguide/networking/work-with-networks/

Here are the necessary steps:

1. We need to look up the IP adress of the docker bridge. We can do this by typing:
```
ifconfig
```
and looking for `docker0` and the field `inet`. I have `172.17.0.1`.

2. We now must adapt the exim configuration file `/etc/exim4/update-exim4.conf.conf` and change the fields:

dc_local_interfaces='127.0.0.1;172.17.0.1'
dc_relay_nets='172.17.0.0/16'

The config update is in place after calling update-exim4.conf and restarting Exim via service exim4 restart.

 
3. We can now send an email a shiny app running in a container with the following R code:

```r
library(mailR)
mailR::send.mail(smtp=list(host.name="172.17.0.1"), from="sender@myhost.com", subject="Test email",body="Hello!",to="receiver@example.com")
```

I just changed the host.name in smtp to the host's IP adress in the docker bridge. 
