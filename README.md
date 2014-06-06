# Crutch
A quick hack allowing you to monitor several miners on the same machine using a web browser as well as take corrective action if a miner gets stunned or crashes.

Why did I write it? Well, ever since I started using my BeagleBone Black SBC as a miner controller, I noticed that the mining software and hardware isn't very stable. I found myself checking on it regularly and finding that it had either crashed (process terminated) or the hardware had failed (overheated or just stunned), requiring a miner process restart. That's when I started writing the crutch script.

True, there are a lot of monitoring scripts out there, some of them quite fancy. I wanted something opposite of fancy. Something that doesn't require a database and is stupidly simple to install and run. More importantly, something you can run on an SBC like a BeagleBone, Raspberry Pi or even a router, without requiring a whole lot of resources like a MySQL database backend.

### FEATURES
Crutch's main goal is simplicity and lightweightedness. I kid you not, this readme is longer than the main crutch script. :)

* Monitor miners regularly (check for process existence and monitor miner log patterns for signs of stunned hardware).
* Applies corrective action when anomaly is detected.
* SBC (e.g. Raspberry Pi or BeagleBoard) friendly - configurable to write all non-essential data to ramdisk (/dev/shm) or tmpfs to reduce wear on SSD storage.
* It isn't technically limited to miners, it can be used to monitor *any* service/process.

### HOW DOES IT WORK?
In a nutshell, the main crutch script runs periodically (cron) and performs the following:

1. Checks to see if all the defined services/processes are running.
2. If a process/service is not running, it restarts it in a dedicated screen session, named after the process/service executable.
3. If a process/service is running, it takes a "screenshot" of its screen session and saves it into a text file.
4. Finally, crutch looks for a predefined string/pattern in the "screenshot" text file, and if it finds a minimum number of occurrences of said string/pattern in the "screenshot" file, it kills the service/process and restarts it.

The optional web/PHP frontent to crutch displays the "screenshot" files, as well as the main crutch log. It's a handy dashboard that you can use to monitor your mining rig.

### INSTALLATION

#### Download
The best way to grab crutch is off github:
```
git clone https://github.com/rouben/crutch.git
```
or
```
wget https://github.com/rouben/crutch/archive/master.zip
```

#### Getting started with configuration

* Decide on a space-separated list of services/processes you need to monitor. These are the executable names that can be looked up with pgrep or ps.
  * Place this list in the **SERVICES** variable.
  * Example:
  ```bash
  SERVICES="bfgminer cgminer"
  ```
* Determine strings/patterns to look for in the outputs of said services/processes that should trigger a service restart. For each pattern also note the number of times it needs to be detected in a single "screenshot" to trigger a restart.
  * Place these strings in variables named **STUN_servicename** for each service in **SERVICES**.
  * Example:
  ```bash
  STUN_bfgminer="requested work update"  # bfgminer
  STUN_cgminer="detected new block"      # cgminer
  ```
* Determine a directory where crutch will store its "screenshots" and log. If you're running this on an embedded system, like a Raspberry Pi or your router, consider using a ramdisk, like /dev/shm or /run/shm in order to avoid unneeded wear on your SSD storage.
  * Place this list in the **OUTDIR** variable. Don't forget the trailing slash!
  * Example:
  ```bash
  OUTDIR="/run/shm/"
  ```
* Indcate the directory where all the service binaries are stored. In my case, since I compiled and installed all miners myself, I use the usual **/usr/local/bin/**, but you could use any path, really.
  * Place this list in the **BINDIR** variable. Don't forget the trailing slash!
  * Example:
  ```bash
  BINDIR="/usr/local/bin/"
  ```

#### Now to test it!

* OK, now you should be able to run the script:
```
chmod 700 crutch.sh     # if you have not yet done this...
./crutch.sh
```
* Check on your "services" by trying to connect to them with screen. If you only have 1 service, you will automatically attach to its screen session. If you have multiple services, here's what you should see:
```
$ screen -r
There are several suitable screens on:
  31601.bfgminer	(05/27/2014 10:08:29 AM)	(Detached)
  26931.cpuminer	(05/27/2014 12:05:02 AM)	(Detached)
  26468.cgminer	(05/26/2014 11:10:02 PM)	(Detached)
Type "screen [-d] -r [pid.]tty.host" to resume one of them.
$
```
  * You can attach, for example, to bfgminer's session like so:
  ```
  screen -r bfgminer
  ```
  * You can detach from any screen session by either quitting the program running within it (e.g. press **Q** to exit bfgminer), or by detaching from the screen session and allowing the service/process to run in the background (press **Ctrl+A**, release, then tap **D**).
  * For more information on using screen, see [this](http://lmgtfy.com/?q=screen+howto).
* Check your **OUTDIR** and make sure that everything looks OK.
* Run the script a few more times to make sure it's functioning OK.

#### Make it official: put it in your crontab

* Finally, add it to your crontab:
```
crontab -e
```
  * You can see the file crontab.sample for an example of how to set up crutch.sh as a scheduled task. I run it every 5 minutes, but you can choose any interval you wish. If your **OUTDIR** happens to be on a ramdisk, you can make this as frequent as every minute.
  * If you need help with cron, check [this](http://lmgtfy.com/?q=crontab+howto) out.

#### Optional: rotate those logs!

* Check out **logrotate.sample**. Obviously you need to edit it to suit your needs and ensure that the logrotate package is installed on your system.

#### Optional: install the web front-end

* Simply copy everything under the www directory into your web root.
* The script is written in PHP, so your web server needs to be set up with PHP.
* The PHP script needs just 2 variables set up: **$services** and **$out_dir**. The idea is exactly the same as with the main crutch script, except the syntax is PHP.
  * Here's an example:
  ```php
  $services = array('bfgminer', 'cgminer');
  $out_dir = '/run/shm/';
  ```
* You can further tweak the PHP script by changing snipplets of HTML code (right after the configuration section, e.g. the **<TITLE>** tag, and the list of links), as well as the last few lines that display the system uptime and include the image tags for the type of board (BeagleBoard) and CPU I'm using. You can put whatever you want there, really.
* If you need a PHP crash course, I suggest [this](http://www.codecademy.com/tracks/php).

### TODO

* Clean up PHP
